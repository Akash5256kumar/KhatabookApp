import 'package:apna_business_app/core/errors/app_exception.dart';
import 'package:equatable/equatable.dart';

/// Base failure exposed to the domain and presentation layers.
sealed class Failure extends Equatable {
  /// Creates a failure with a user-friendly message.
  const Failure(this.message);

  /// Human-readable message safe for UI presentation.
  final String message;

  @override
  List<Object?> get props => <Object?>[message];
}

/// Indicates the request could not reach the server.
final class NetworkFailure extends Failure {
  /// Creates a [NetworkFailure].
  const NetworkFailure([
    super.message = 'Internet connection unavailable. Please try again.',
  ]);
}

/// Indicates the request timed out.
final class TimeoutFailure extends Failure {
  /// Creates a [TimeoutFailure].
  const TimeoutFailure([
    super.message = 'The request took too long. Please try again.',
  ]);
}

/// Indicates the user has been signed out.
final class UnauthorizedFailure extends Failure {
  /// Creates an [UnauthorizedFailure].
  const UnauthorizedFailure([
    super.message = 'Your session expired. Please log in again.',
  ]);
}

/// Indicates a server-side issue.
final class ServerFailure extends Failure {
  /// Creates a [ServerFailure].
  const ServerFailure([
    super.message = 'We are having trouble on our side. Please try again.',
  ]);
}

/// Indicates a missing resource.
final class NotFoundFailure extends Failure {
  /// Creates a [NotFoundFailure].
  const NotFoundFailure([
    super.message = 'We could not find what you were looking for.',
  ]);
}

/// Indicates form or business validation failed.
final class ValidationFailure extends Failure {
  /// Creates a [ValidationFailure].
  const ValidationFailure(super.message);
}

/// Indicates local storage failed.
final class CacheFailure extends Failure {
  /// Creates a [CacheFailure].
  const CacheFailure([
    super.message = 'We could not load saved information right now.',
  ]);
}

/// Indicates a rate-limited request.
final class RateLimitFailure extends Failure {
  /// Creates a [RateLimitFailure].
  const RateLimitFailure([
    super.message = 'Too many requests. Please wait a moment and retry.',
  ]);
}

/// Indicates an unexpected condition.
final class UnknownFailure extends Failure {
  /// Creates an [UnknownFailure].
  const UnknownFailure([
    super.message = 'Something unexpected happened. Please try again.',
  ]);
}

/// Converts an [AppException] into a [Failure].
Failure mapExceptionToFailure(AppException exception) {
  return switch (exception) {
    NetworkException() => NetworkFailure(exception.message),
    TimeoutException() => TimeoutFailure(exception.message),
    UnauthorizedException() => UnauthorizedFailure(exception.message),
    NotFoundException() => NotFoundFailure(exception.message),
    CacheException() => CacheFailure(exception.message),
    RateLimitException() => RateLimitFailure(exception.message),
    ServerException() => ServerFailure(exception.message),
    ParsingException() => const UnknownFailure(
        'We received an unexpected response. Please try again.',
      ),
  };
}
