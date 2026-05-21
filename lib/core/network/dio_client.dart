import 'dart:async';

import 'package:apna_business_app/core/constants/app_constants.dart';
import 'package:apna_business_app/core/errors/app_exception.dart';
import 'package:apna_business_app/core/storage/local_storage.dart';
import 'package:apna_business_app/core/utils/logger.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

String _resolveBaseUrl() => AppConstants.baseUrl;

String _diagnoseConnectionError(DioException exception) {
  final Uri uri = exception.requestOptions.uri;
  final String host = uri.host;
  final int? port = uri.hasPort ? uri.port : null;
  final String target = port == null ? host : '$host:$port';
  final Object? cause = exception.error;
  final String causeText = cause?.toString() ?? exception.message ?? 'Unknown';

  return 'Could not reach the API at $target. Original error: $causeText';
}

/// Shared [Dio] wrapper with auth and retry behavior.
@lazySingleton
class DioClient {
  /// Creates a configured [Dio] client.
  DioClient(this._localStorage) {
    final String resolvedBaseUrl = _resolveBaseUrl();
    logger.info('Using API base URL: $resolvedBaseUrl');
    _dio = Dio(
      BaseOptions(
        baseUrl: resolvedBaseUrl,
        connectTimeout:
            const Duration(milliseconds: AppConstants.connectTimeoutMs),
        receiveTimeout:
            const Duration(milliseconds: AppConstants.receiveTimeoutMs),
        headers: const <String, String>{
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    )
      ..interceptors.add(_AuthInterceptor(_localStorage))
      ..interceptors.add(_RetryInterceptor())
      ..interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          logPrint: (Object object) => logger.debug(object.toString()),
        ),
      );
  }

  final LocalStorage _localStorage;
  late final Dio _dio;

  /// Exposes the configured client.
  Dio get dio => _dio;
}

class _AuthInterceptor extends Interceptor {
  _AuthInterceptor(this._localStorage);

  final LocalStorage _localStorage;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final String? accessToken = _localStorage.accessToken;
    if (accessToken != null && accessToken.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401) {
      await _localStorage.clearSession();
      handler.reject(
        DioException(
          requestOptions: err.requestOptions,
          response: err.response,
          type: err.type,
          error: const UnauthorizedException(),
        ),
      );
      return;
    }

    handler.next(err);
  }
}

class _RetryInterceptor extends Interceptor {
  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final int attempt = err.requestOptions.extra['attempt'] as int? ?? 0;
    final int? statusCode = err.response?.statusCode;
    final bool retryableServerError = statusCode != null && statusCode >= 500;
    final bool retryableTransportError =
        err.type == DioExceptionType.connectionTimeout ||
            err.type == DioExceptionType.receiveTimeout ||
            err.type == DioExceptionType.connectionError;
    final bool retryableRateLimit = statusCode == 429;
    final bool canRetry = attempt < AppConstants.maxRetries &&
        (retryableTransportError || retryableServerError || retryableRateLimit);

    if (!canRetry) {
      handler.next(err);
      return;
    }

    final int nextAttempt = attempt + 1;
    err.requestOptions.extra['attempt'] = nextAttempt;
    final int delayMultiplier = retryableRateLimit
        ? _retryAfterSeconds(err.response) ?? nextAttempt
        : nextAttempt;
    final Duration delay = Duration(
      milliseconds: AppConstants.retryDelayMs * delayMultiplier,
    );
    await Future<void>.delayed(delay);

    try {
      final Dio retryDio = Dio()
        ..options = BaseOptions(
          baseUrl: err.requestOptions.baseUrl,
          connectTimeout:
              const Duration(milliseconds: AppConstants.connectTimeoutMs),
          receiveTimeout:
              const Duration(milliseconds: AppConstants.receiveTimeoutMs),
          headers: Map<String, Object?>.from(err.requestOptions.headers),
        );
      final Response<dynamic> response = await retryDio.fetch<dynamic>(
        err.requestOptions,
      );
      handler.resolve(response);
    } on DioException catch (error) {
      handler.next(error);
    }
  }

  int? _retryAfterSeconds(Response<dynamic>? response) {
    final Object? rawValue = response?.headers.value('retry-after');
    return int.tryParse(rawValue?.toString() ?? '');
  }
}

/// Converts a [DioException] into an [AppException].
AppException mapDioException(DioException exception) {
  return switch (exception.type) {
    DioExceptionType.connectionTimeout ||
    DioExceptionType.receiveTimeout ||
    DioExceptionType.sendTimeout =>
      const TimeoutException(),
    DioExceptionType.connectionError =>
      NetworkException(_diagnoseConnectionError(exception)),
    DioExceptionType.badResponse =>
      _mapStatusCodeToException(exception.response?.statusCode),
    _ => NetworkException(exception.message ?? 'Network connection failed'),
  };
}

AppException _mapStatusCodeToException(int? statusCode) {
  return switch (statusCode) {
    401 => const UnauthorizedException(),
    404 => const NotFoundException(),
    429 => const RateLimitException(),
    _ when statusCode != null && statusCode >= 500 =>
      ServerException.withCode(statusCode),
    _ => const ServerException(),
  };
}
