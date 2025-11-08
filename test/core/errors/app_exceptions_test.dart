import 'package:alchronos/core/errors/app_exceptions.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppException', () {
    test('creates exception with message', () {
      const exception = DatabaseException('Test message');

      expect(exception.message, 'Test message');
      expect(exception.code, isNull);
    });

    test('creates exception with message and code', () {
      const exception = DatabaseException('Test message', 'ERR001');

      expect(exception.message, 'Test message');
      expect(exception.code, 'ERR001');
    });

    test('toString includes message', () {
      const exception = DatabaseException('Test message');

      expect(exception.toString(), contains('Test message'));
    });

    test('toString includes code when provided', () {
      const exception = DatabaseException('Test message', 'ERR001');

      expect(exception.toString(), contains('Test message'));
      expect(exception.toString(), contains('ERR001'));
    });
  });

  group('DatabaseException', () {
    test('is instance of AppException', () {
      const exception = DatabaseException('Database error');

      expect(exception, isA<AppException>());
    });
  });

  group('StorageException', () {
    test('is instance of AppException', () {
      const exception = StorageException('Storage error');

      expect(exception, isA<AppException>());
    });
  });

  group('TimerException', () {
    test('is instance of AppException', () {
      const exception = TimerException('Timer error');

      expect(exception, isA<AppException>());
    });
  });

  group('NotificationException', () {
    test('is instance of AppException', () {
      const exception = NotificationException('Notification error');

      expect(exception, isA<AppException>());
    });
  });

  group('NetworkException', () {
    test('is instance of AppException', () {
      const exception = NetworkException('Network error');

      expect(exception, isA<AppException>());
    });
  });

  group('ValidationException', () {
    test('is instance of AppException', () {
      const exception = ValidationException('Validation error');

      expect(exception, isA<AppException>());
    });
  });
}
