import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureVaultService {
  SecureVaultService._();

  static final SecureVaultService instance = SecureVaultService._();
  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  final Map<String, String> _memoryStore = <String, String>{};
  bool _useMemoryStore = false;

  void useMemoryStoreForTesting() {
    _useMemoryStore = true;
  }

  void resetTestingStore() {
    _memoryStore.clear();
    _useMemoryStore = false;
  }

  Future<void> write(String key, String value) async {
    if (_useMemoryStore) {
      _memoryStore[key] = value;
      return;
    }
    await _storage.write(key: key, value: value);
  }

  Future<String?> read(String key) async {
    if (_useMemoryStore) {
      return _memoryStore[key];
    }
    return _storage.read(key: key);
  }

  Future<void> delete(String key) async {
    if (_useMemoryStore) {
      _memoryStore.remove(key);
      return;
    }
    await _storage.delete(key: key);
  }
}
