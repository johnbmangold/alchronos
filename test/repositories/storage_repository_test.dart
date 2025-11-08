import 'package:alchronos/home/views/home_start_view.dart';
import 'package:alchronos/repositories/storage_repository.dart';
import 'package:alchronos/services/storage_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'storage_repository_test.mocks.dart';

@GenerateNiceMocks([MockSpec<StorageService>()])
void main() {
  group('StorageRepository', () {
    late StorageRepository storageRepository;
    late MockStorageService mockStorageService;

    setUp(() {
      mockStorageService = MockStorageService();
      storageRepository = StorageRepository(
        storageService: mockStorageService,
      );
    });

    group('writeTimerDurationPreference', () {
      test('writes timer duration preference', () async {
        when(mockStorageService.writeValue(
          storageRepository.timerDurationKey,
          TimerDuration.standard.name,
        ),).thenAnswer((_) async => {});

        await storageRepository.writeTimerDurationPreference(
          TimerDuration.standard,
        );

        verify(
          mockStorageService.writeValue(
            storageRepository.timerDurationKey,
            TimerDuration.standard.name,
          ),
        ).called(1);
      });
    });

    group('readTimerDurationPreference', () {
      test('returns stored timer duration', () async {
        when(mockStorageService.readValue(
          storageRepository.timerDurationKey,
        ),).thenAnswer((_) async => TimerDuration.longer.name);

        final result = await storageRepository.readTimerDurationPreference();

        expect(result, TimerDuration.longer);
      });

      test('returns and saves standard when value is null', () async {
        when(mockStorageService.readValue(
          storageRepository.timerDurationKey,
        ),).thenAnswer((_) async => null);
        when(mockStorageService.writeValue(
          storageRepository.timerDurationKey,
          TimerDuration.standard.name,
        ),).thenAnswer((_) async => {});

        final result = await storageRepository.readTimerDurationPreference();

        expect(result, TimerDuration.standard);
        verify(
          mockStorageService.writeValue(
            storageRepository.timerDurationKey,
            TimerDuration.standard.name,
          ),
        ).called(1);
      });

      test('returns and saves standard when value is empty', () async {
        when(mockStorageService.readValue(
          storageRepository.timerDurationKey,
        ),).thenAnswer((_) async => '');
        when(mockStorageService.writeValue(
          storageRepository.timerDurationKey,
          TimerDuration.standard.name,
        ),).thenAnswer((_) async => {});

        final result = await storageRepository.readTimerDurationPreference();

        expect(result, TimerDuration.standard);
      });
    });

    group('writeCustomDuration', () {
      test('writes custom duration', () async {
        const minutes = 90;

        when(mockStorageService.writeValue(
          storageRepository.customDurationKey,
          minutes.toString(),
        ),).thenAnswer((_) async => {});

        await storageRepository.writeCustomDuration(minutes);

        verify(
          mockStorageService.writeValue(
            storageRepository.customDurationKey,
            minutes.toString(),
          ),
        ).called(1);
      });
    });

    group('readCustomDuration', () {
      test('returns stored custom duration', () async {
        const expectedMinutes = 90;

        when(mockStorageService.readValue(
          storageRepository.customDurationKey,
        ),).thenAnswer((_) async => expectedMinutes.toString());

        final result = await storageRepository.readCustomDuration();

        expect(result, expectedMinutes);
      });

      test('returns default 60 when value is null', () async {
        when(mockStorageService.readValue(
          storageRepository.customDurationKey,
        ),).thenAnswer((_) async => null);

        final result = await storageRepository.readCustomDuration();

        expect(result, 60);
      });

      test('returns default 60 when value is invalid', () async {
        when(mockStorageService.readValue(
          storageRepository.customDurationKey,
        ),).thenAnswer((_) async => 'invalid');

        final result = await storageRepository.readCustomDuration();

        expect(result, 60);
      });
    });

    group('readBool', () {
      test('returns true when value is "true"', () async {
        const key = 'test_key';

        when(mockStorageService.readValue(key)).thenAnswer((_) async => 'true');

        final result = await storageRepository.readBool(key);

        expect(result, isTrue);
      });

      test('returns false when value is "false"', () async {
        const key = 'test_key';

        when(mockStorageService.readValue(key))
            .thenAnswer((_) async => 'false');

        final result = await storageRepository.readBool(key);

        expect(result, isFalse);
      });

      test('returns false when value is null', () async {
        const key = 'test_key';

        when(mockStorageService.readValue(key)).thenAnswer((_) async => null);

        final result = await storageRepository.readBool(key);

        expect(result, isFalse);
      });
    });

    group('writeBool', () {
      test('writes true as string', () async {
        const key = 'test_key';

        when(mockStorageService.writeValue(key, 'true'))
            .thenAnswer((_) async => {});

        await storageRepository.writeBool(key, value: true);

        verify(mockStorageService.writeValue(key, 'true')).called(1);
      });

      test('writes false as string', () async {
        const key = 'test_key';

        when(mockStorageService.writeValue(key, 'false'))
            .thenAnswer((_) async => {});

        await storageRepository.writeBool(key, value: false);

        verify(mockStorageService.writeValue(key, 'false')).called(1);
      });
    });

    group('readInt', () {
      test('returns parsed integer', () async {
        const key = 'test_key';
        const expectedValue = 42;

        when(mockStorageService.readValue(key))
            .thenAnswer((_) async => expectedValue.toString());

        final result = await storageRepository.readInt(key);

        expect(result, expectedValue);
      });

      test('returns null when value is null', () async {
        const key = 'test_key';

        when(mockStorageService.readValue(key)).thenAnswer((_) async => null);

        final result = await storageRepository.readInt(key);

        expect(result, isNull);
      });

      test('returns null when value is invalid', () async {
        const key = 'test_key';

        when(mockStorageService.readValue(key))
            .thenAnswer((_) async => 'invalid');

        final result = await storageRepository.readInt(key);

        expect(result, isNull);
      });
    });

    group('writeInt', () {
      test('writes integer as string', () async {
        const key = 'test_key';
        const value = 42;

        when(mockStorageService.writeValue(key, value.toString()))
            .thenAnswer((_) async => {});

        await storageRepository.writeInt(key, value: value);

        verify(mockStorageService.writeValue(key, value.toString())).called(1);
      });
    });
  });
}
