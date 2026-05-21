/// Base exception type for application failures.
sealed class AppException implements Exception {
  /// Creates a custom application exception.
  const AppException(this.message);

  /// Developer-safe message for logging.
  final String message;
}

/// Indicates the device could not reach the network.
final class NetworkException extends AppException {
  /// Creates a [NetworkException].
  const NetworkException([super.message = 'Network connection failed']);
}

/// Indicates the request timed out.
final class TimeoutException extends AppException {
  /// Creates a [TimeoutException].
  const TimeoutException([super.message = 'The request timed out']);
}

/// Indicates too many requests were sent.
final class RateLimitException extends AppException {
  /// Creates a [RateLimitException].
  const RateLimitException([super.message = 'Too many requests']);
}

/// Indicates the current session is unauthorized.
final class UnauthorizedException extends AppException {
  /// Creates an [UnauthorizedException].
  const UnauthorizedException([super.message = 'Unauthorized']);
}

/// Indicates the resource was not found.
final class NotFoundException extends AppException {
  /// Creates a [NotFoundException].
  const NotFoundException([super.message = 'Resource not found']);
}

/// Indicates a server-side error.
final class ServerException extends AppException {
  /// Creates a [ServerException].
  const ServerException([super.message = 'Server error']) : statusCode = 500;

  /// Creates a [ServerException] with an HTTP status code.
  const ServerException.withCode(this.statusCode, [super.message = 'Server error']);

  /// HTTP status code.
  final int statusCode;
}

/// Indicates local persistence failed.
final class CacheException extends AppException {
  /// Creates a [CacheException].
  const CacheException([super.message = 'Local cache error']);
}

/// Indicates malformed or unexpected data.
final class ParsingException extends AppException {
  /// Creates a [ParsingException].
  const ParsingException([super.message = 'Unable to parse response']);
}
