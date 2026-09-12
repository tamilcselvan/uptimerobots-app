import 'dart:convert';

import 'key_value_store.dart';
import '../models/account.dart';

/// Persists accounts (label + api_key) in OS-level secure storage
/// (Keychain on iOS/macOS, Keystore on Android, encrypted file elsewhere).
class AccountRepository {
  static const _storageKey = 'uptimerobot_accounts';

  final KeyValueStore _storage;

  AccountRepository({KeyValueStore? storage})
    : _storage = storage ?? SecureKeyValueStore();

  Future<List<Account>> loadAll() async {
    final raw = await _storage.read(_storageKey);
    if (raw == null || raw.isEmpty) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => Account.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> _saveAll(List<Account> accounts) async {
    final raw = jsonEncode(accounts.map((a) => a.toJson()).toList());
    await _storage.write(_storageKey, raw);
  }

  Future<void> add(Account account) async {
    final accounts = await loadAll();
    accounts.add(account);
    await _saveAll(accounts);
  }

  Future<void> update(Account account) async {
    final accounts = await loadAll();
    final index = accounts.indexWhere((a) => a.id == account.id);
    if (index == -1) return;
    accounts[index] = account;
    await _saveAll(accounts);
  }

  Future<void> remove(String id) async {
    final accounts = await loadAll();
    accounts.removeWhere((a) => a.id == id);
    await _saveAll(accounts);
  }
}
