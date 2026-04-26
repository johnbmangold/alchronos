import 'package:alchronos/data/sources/secure_storage_provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Provider for the [SecureStorageDataSource].
final secureStorageDataSourceProvider =
    Provider<SecureStorageDataSource>((ref) {
  return SecureStorageDataSource(
    flutterSecureStorage: ref.watch(secureStorageProvider),
  );
});

/// Data source abstraction for secure storage operations.
class SecureStorageDataSource {
  /// Creates a [SecureStorageDataSource] wrapping [flutterSecureStorage].
  const SecureStorageDataSource({required this.flutterSecureStorage});

  /// The underlying [FlutterSecureStorage] instance.
  final FlutterSecureStorage flutterSecureStorage;

  /// Writes a secure string [value] associated with [key].
  Future<void> writeValue(String key, String value) async {
    await flutterSecureStorage.write(key: key, value: value);
  }

  /// Reads a secure string value by its [key].
  Future<String?> readValue(String key) async {
    return flutterSecureStorage.read(key: key);
  }

  /// Reads all stored secure values as a map.
  Future<Map<String, String>> readAll() async {
    return flutterSecureStorage.readAll();
  }

  /// Checks if a value exists for the given [key].
  Future<bool> containsKey(String key) async {
    return flutterSecureStorage.containsKey(key: key);
  }

  /// Deletes the value associated with the given [key].
  Future<void> delete(String key) async {
    await flutterSecureStorage.delete(key: key);
  }

  /// Deletes all values from secure storage.
  Future<void> deleteAll() async {
    await flutterSecureStorage.deleteAll();
  }
}
