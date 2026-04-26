import 'package:alchronos/data/sources/secure_storage_provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final secureStorageDataSourceProvider =
    Provider<SecureStorageDataSource>((ref) {
  return SecureStorageDataSource(
    flutterSecureStorage: ref.watch(secureStorageProvider),
  );
});

class SecureStorageDataSource {
  const SecureStorageDataSource({required this.flutterSecureStorage});

  final FlutterSecureStorage flutterSecureStorage;

  Future<void> writeValue(String key, String value) async {
    await flutterSecureStorage.write(key: key, value: value);
  }

  Future<String?> readValue(String key) async {
    return flutterSecureStorage.read(key: key);
  }

  Future<Map<String, String>> readAll() async {
    return flutterSecureStorage.readAll();
  }

  Future<bool> containsKey(String key) async {
    return flutterSecureStorage.containsKey(key: key);
  }

  Future<void> delete(String key) async {
    await flutterSecureStorage.delete(key: key);
  }

  Future<void> deleteAll() async {
    await flutterSecureStorage.deleteAll();
  }
}
