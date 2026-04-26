/// Base exception class for the application
abstract class AppException implements Exception {
  /// Creates an [AppException] with the given [message] and optional [code].
  const AppException(this.message, [this.code]);

  /// A descriptive message detailing the exception.
  final String message;

  /// An optional error code identifying the type of exception.
  final String? code;

  @override
  String toString() =>
      'AppException: $message${code != null ? ' (Code: $code)' : ''}';
}

/// Exception thrown when database operations fail
class DatabaseException extends AppException {
  /// Creates a [DatabaseException].
  const DatabaseException(super.message, [super.code]);
}

/// Exception thrown when storage operations fail
class StorageException extends AppException {
  /// Creates a [StorageException].
  const StorageException(super.message, [super.code]);
}

/// Exception thrown when timer operations fail
class TimerException extends AppException {
  /// Creates a [TimerException].
  const TimerException(super.message, [super.code]);
}

/// Exception thrown when notification operations fail
class NotificationException extends AppException {
  /// Creates a [NotificationException].
  const NotificationException(super.message, [super.code]);
}

/// Exception thrown when network operations fail
class NetworkException extends AppException {
  /// Creates a [NetworkException].
  const NetworkException(super.message, [super.code]);
}

/// Exception thrown when validation fails
class ValidationException extends AppException {
  /// Creates a [ValidationException].
  const ValidationException(super.message, [super.code]);
}
