import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  // 싱글턴 인스턴스
  static final SecureStorage _instance = SecureStorage._internal();
  factory SecureStorage() => _instance;

  SecureStorage._internal();

  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  Future<void> write(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  Future<String?> read(String key) async {
    return await _storage.read(key: key);
  }

  Future<void> delete(String key) async {
    await _storage.delete(key: key);
  }

  Future<void> clear() async {
    await _storage.deleteAll();
  }
}
