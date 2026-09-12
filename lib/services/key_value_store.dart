import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Minimal key-value contract so [AccountRepository] doesn't depend
/// directly on the secure-storage plugin (keeps it testable / swappable).
abstract class KeyValueStore {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
}

class SecureKeyValueStore implements KeyValueStore {
  final FlutterSecureStorage _storage;
  SecureKeyValueStore([FlutterSecureStorage? storage])
    : _storage = storage ?? const FlutterSecureStorage();

  @override
  Future<String?> read(String key) => _storage.read(key: key);

  @override
  Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value);
}

/// In-memory store for widget/unit tests — no platform channel involved.
class InMemoryKeyValueStore implements KeyValueStore {
  final Map<String, String> _data = {};

  @override
  Future<String?> read(String key) async => _data[key];

  @override
  Future<void> write(String key, String value) async => _data[key] = value;
}
