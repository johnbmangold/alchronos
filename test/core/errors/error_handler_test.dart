import 'package:alchronos/core/errors/app_exceptions.dart';
import 'package:alchronos/core/errors/error_handler.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ErrorHandler', () {
    group('getUserFriendlyMessage', () {
      test('returns user-friendly message for DatabaseException', () {
        // Arrange
        const exception = DatabaseException('Database connection failed');

        // Act
        final message = ErrorHandler.getUserFriendlyMessage(exception);

        // Assert
        expect(message, 'Failed to save data. Please try again.');
      });

      test('returns user-friendly message for StorageException', () {
        // Arrange
        const exception = StorageException('Storage write failed');

        // Act
        final message = ErrorHandler.getUserFriendlyMessage(exception);

        // Assert
        expect(message, 'Failed to save preferences. Please try again.');
      });

      test('returns user-friendly message for TimerException', () {
        // Arrange
        const exception = TimerException('Timer initialization failed');

        // Act
        final message = ErrorHandler.getUserFriendlyMessage(exception);

        // Assert
        expect(message, 'Timer error occurred. Please restart the timer.');
      });

      test('returns user-friendly message for NotificationException', () {
        // Arrange
        const exception =
            NotificationException('Notification permission denied');

        // Act
        final message = ErrorHandler.getUserFriendlyMessage(exception);

        // Assert
        expect(
          message,
          'Notification error occurred. Please check your settings.',
        );
      });

      test('returns user-friendly message for NetworkException', () {
        // Arrange
        const exception = NetworkException('Network timeout');

        // Act
        final message = ErrorHandler.getUserFriendlyMessage(exception);

        // Assert
        expect(message, 'Network error. Please check your connection.');
      });

      test('returns user-friendly message for ValidationException', () {
        // Arrange
        const exception = ValidationException('Invalid input provided');

        // Act
        final message = ErrorHandler.getUserFriendlyMessage(exception);

        // Assert
        expect(message, 'Invalid input provided');
      });

      test('returns generic message for unknown exceptions', () {
        // Arrange
        final exception = Exception('Unknown error');

        // Act
        final message = ErrorHandler.getUserFriendlyMessage(exception);

        // Assert
        expect(message, 'Something went wrong. Please try again.');
      });
    });
  });
}
