/// Base exception class for the application
abstract class AppException implements Exception {
  const AppException(this.message, [this.code]);

  final String message;
  final String? code;

  @override
  String toString() =>
      'AppException: $message${code != null ? ' (Code: $code)' : ''}';
}

/// Exception thrown when database operations fail
class DatabaseException extends AppException {
  const DatabaseException(super.message, [super.code]);
}

/// Exception thrown when storage operations fail
class StorageException extends AppException {
  const StorageException(super.message, [super.code]);
}

/// Exception thrown when timer operations fail
class TimerException extends AppException {
  const TimerException(super.message, [super.code]);
}

/// Exception thrown when notification operations fail
class NotificationException extends AppException {
  const NotificationException(super.message, [super.code]);
}

/// Exception thrown when network operations fail
class NetworkException extends AppException {
  const NetworkException(super.message, [super.code]);
}

/// Exception thrown when validation fails
class ValidationException extends AppException {
  const ValidationException(super.message, [super.code]);
}
