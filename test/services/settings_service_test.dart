import 'package:alchronos/core/errors/app_exceptions.dart';
import 'package:alchronos/repositories/storage_repository.dart';
import 'package:alchronos/services/settings_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'settings_service_test.mocks.dart';

@GenerateNiceMocks([MockSpec<StorageRepository>()])
void main() {
  group('SettingsService', () {
    late SettingsService settingsService;
    late MockStorageRepository mockStorageRepository;

    setUp(() {
      mockStorageRepository = MockStorageRepository();
      settingsService = SettingsService(mockStorageRepository);
    });

    group('isReminderEnabled', () {
      test('returns true when reminder is enabled', () async {
        when(mockStorageRepository.readBool('reminder_enabled'))
            .thenAnswer((_) async => true);

        final result = await settingsService.isReminderEnabled();

        expect(result, isTrue);
        verify(mockStorageRepository.readBool('reminder_enabled')).called(1);
      });

      test('returns false when reminder is disabled', () async {
        when(mockStorageRepository.readBool('reminder_enabled'))
            .thenAnswer((_) async => false);

        final result = await settingsService.isReminderEnabled();

        expect(result, isFalse);
      });

      test('returns false when storage throws exception', () async {
        when(mockStorageRepository.readBool('reminder_enabled'))
            .thenThrow(const StorageException('Storage error'));

        final result = await settingsService.isReminderEnabled();

        expect(result, isFalse);
      });

      test('returns false when storage returns null', () async {
        when(mockStorageRepository.readBool('reminder_enabled'))
            .thenAnswer((_) async => null);

        final result = await settingsService.isReminderEnabled();

        expect(result, isFalse);
      });
    });

    group('setReminderEnabled', () {
      test('enables reminder when called with true', () async {
        when(mockStorageRepository.writeBool('reminder_enabled', value: true))
            .thenAnswer((_) async => {});

        await settingsService.setReminderEnabled(enabled: true);

        verify(
          mockStorageRepository.writeBool('reminder_enabled', value: true),
        ).called(1);
      });

      test('disables reminder when called with false', () async {
        when(mockStorageRepository.writeBool('reminder_enabled', value: false))
            .thenAnswer((_) async => {});

        await settingsService.setReminderEnabled(enabled: false);

        verify(
          mockStorageRepository.writeBool('reminder_enabled', value: false),
        ).called(1);
      });
    });

    group('getReminderMinutes', () {
      test('returns stored reminder minutes', () async {
        const expectedMinutes = 10;

        when(mockStorageRepository.readInt('reminder_minutes'))
            .thenAnswer((_) async => expectedMinutes);

        final result = await settingsService.getReminderMinutes();

        expect(result, expectedMinutes);
        verify(mockStorageRepository.readInt('reminder_minutes')).called(1);
      });

      test('returns default 5 when storage returns null', () async {
        when(mockStorageRepository.readInt('reminder_minutes'))
            .thenAnswer((_) async => null);

        final result = await settingsService.getReminderMinutes();

        expect(result, 5);
      });

      test('returns default 5 when storage throws exception', () async {
        when(mockStorageRepository.readInt('reminder_minutes'))
            .thenThrow(const StorageException('Storage error'));

        final result = await settingsService.getReminderMinutes();

        expect(result, 5);
      });
    });

    group('setReminderMinutes', () {
      test('saves reminder minutes when valid', () async {
        const minutes = 15;

        when(mockStorageRepository.writeInt('reminder_minutes', value: minutes))
            .thenAnswer((_) async => {});

        await settingsService.setReminderMinutes(minutes: minutes);

        verify(
          mockStorageRepository.writeInt('reminder_minutes', value: minutes),
        ).called(1);
      });

      test('does not save when minutes is 0', () async {
        await settingsService.setReminderMinutes(minutes: 0);

        verifyNever(mockStorageRepository.writeInt(any, value: any));
      });

      test('does not save when minutes is negative', () async {
        await settingsService.setReminderMinutes(minutes: -1);

        verifyNever(mockStorageRepository.writeInt(any, value: any));
      });

      test('does not save when minutes exceeds 60', () async {
        await settingsService.setReminderMinutes(minutes: 61);

        verifyNever(mockStorageRepository.writeInt(any, value: any));
      });

      test('saves when minutes is exactly 60', () async {
        const minutes = 60;

        when(mockStorageRepository.writeInt('reminder_minutes', value: minutes))
            .thenAnswer((_) async => {});

        await settingsService.setReminderMinutes(minutes: minutes);

        verify(
          mockStorageRepository.writeInt('reminder_minutes', value: minutes),
        ).called(1);
      });
    });
  });
}

