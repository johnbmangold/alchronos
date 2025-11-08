import 'package:alchronos/services/storage_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'storage_service_test.mocks.dart';

@GenerateNiceMocks([MockSpec<FlutterSecureStorage>()])
void main() {
  group('StorageService', () {
    late StorageService storageService;
    late MockFlutterSecureStorage mockSecureStorage;

    setUp(() {
      mockSecureStorage = MockFlutterSecureStorage();
      storageService = StorageService(
        flutterSecureStorage: mockSecureStorage,
      );
    });

    test('writeValue calls flutterSecureStorage.write', () async {
      const key = 'test_key';
      const value = 'test_value';

      when(mockSecureStorage.write(key: key, value: value))
          .thenAnswer((_) async => {});

      await storageService.writeValue(key, value);

      verify(mockSecureStorage.write(key: key, value: value)).called(1);
    });

    test('readValue returns value from flutterSecureStorage', () async {
      const key = 'test_key';
      const expectedValue = 'test_value';

      when(mockSecureStorage.read(key: key))
          .thenAnswer((_) async => expectedValue);

      final result = await storageService.readValue(key);

      expect(result, expectedValue);
      verify(mockSecureStorage.read(key: key)).called(1);
    });

    test('readValue returns null when key does not exist', () async {
      const key = 'non_existent_key';

      when(mockSecureStorage.read(key: key)).thenAnswer((_) async => null);

      final result = await storageService.readValue(key);

      expect(result, isNull);
    });

    test('readAll returns all values from flutterSecureStorage', () async {
      final expectedMap = <String, String>{
        'key1': 'value1',
        'key2': 'value2',
      };

      when(mockSecureStorage.readAll()).thenAnswer((_) async => expectedMap);

      final result = await storageService.readAll();

      expect(result, expectedMap);
      verify(mockSecureStorage.readAll()).called(1);
    });

    test('containsKey returns true when key exists', () async {
      const key = 'existing_key';

      when(mockSecureStorage.containsKey(key: key))
          .thenAnswer((_) async => true);

      final result = await storageService.containsKey(key);

      expect(result, isTrue);
      verify(mockSecureStorage.containsKey(key: key)).called(1);
    });

    test('containsKey returns false when key does not exist', () async {
      const key = 'non_existent_key';

      when(mockSecureStorage.containsKey(key: key))
          .thenAnswer((_) async => false);

      final result = await storageService.containsKey(key);

      expect(result, isFalse);
    });

    test('delete calls flutterSecureStorage.delete', () async {
      const key = 'test_key';

      when(mockSecureStorage.delete(key: key)).thenAnswer((_) async => {});

      await storageService.delete(key);

      verify(mockSecureStorage.delete(key: key)).called(1);
    });

    test('deleteAll calls flutterSecureStorage.deleteAll', () async {
      when(mockSecureStorage.deleteAll()).thenAnswer((_) async => {});

      await storageService.deleteAll();

      verify(mockSecureStorage.deleteAll()).called(1);
    });
  });
}
