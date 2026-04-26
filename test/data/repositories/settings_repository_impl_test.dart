import 'package:alchronos/data/repositories/settings_repository_impl.dart';
import 'package:alchronos/data/sources/secure_storage_data_source.dart';
import 'package:alchronos/home/views/views.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeSecureStorageDataSource implements SecureStorageDataSource {
  final Map<String, String> _storage = {};

  @override
  Future<String?> readValue(String key) async {
    return _storage[key];
  }

  @override
  Future<void> writeValue(String key, String value) async {
    _storage[key] = value;
  }

  @override
  Future<void> delete(String key) async {
    _storage.remove(key);
  }

  @override
  Future<void> deleteAll() async {
    _storage.clear();
  }

  @override
  Future<bool> containsKey(String key) async {
    return _storage.containsKey(key);
  }

  @override
  Future<Map<String, String>> readAll() async {
    return Map.from(_storage);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late SettingsRepositoryImpl repository;
  late FakeSecureStorageDataSource fakeDataSource;

  setUp(() {
    fakeDataSource = FakeSecureStorageDataSource();
    repository = SettingsRepositoryImpl(dataSource: fakeDataSource);
  });

  group('TimerDuration Preference', () {
    test('readTimerDurationPreference returns standard when no data exists',
        () async {
      // Act
      final result = await repository.readTimerDurationPreference();

      // Assert
      expect(result, TimerDuration.standard);
      // Verify standard is written if missing
      final storedValue =
          await fakeDataSource.readValue(repository.timerDurationKey);
      expect(storedValue, TimerDuration.standard.name);
    });

    test('writeTimerDurationPreference saves correct value', () async {
      // Act
      await repository.writeTimerDurationPreference(TimerDuration.custom);

      // Assert
      final result = await repository.readTimerDurationPreference();
      expect(result, TimerDuration.custom);
    });
  });

  group('Custom Duration', () {
    test('readCustomDuration returns 60 when no data exists', () async {
      // Act
      final result = await repository.readCustomDuration();

      // Assert
      expect(result, 60);
    });

    test('writeCustomDuration saves correct value', () async {
      // Act
      await repository.writeCustomDuration(45);

      // Assert
      final result = await repository.readCustomDuration();
      expect(result, 45);
    });
  });

  group('Reminder Settings', () {
    test('isReminderEnabled returns true by default', () async {
      // Act
      final result = await repository.isReminderEnabled();

      // Assert
      expect(result, isTrue);
    });

    test('setReminderEnabled updates the value', () async {
      // Act
      await repository.setReminderEnabled(enabled: false);

      // Assert
      final result = await repository.isReminderEnabled();
      expect(result, isFalse);
    });

    test('getReminderMinutes returns 5 by default', () async {
      // Act
      final result = await repository.getReminderMinutes();

      // Assert
      expect(result, 5);
    });

    test('setReminderMinutes updates the value', () async {
      // Act
      await repository.setReminderMinutes(10);

      // Assert
      final result = await repository.getReminderMinutes();
      expect(result, 10);
    });
  });
}
