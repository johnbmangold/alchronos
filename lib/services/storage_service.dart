import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageService {
  const StorageService({required this.flutterSecureStorage});

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
