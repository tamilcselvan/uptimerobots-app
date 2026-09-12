import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../models/account.dart';
import '../models/account_summary.dart';
import '../services/account_repository.dart';
import '../services/rate_limiter.dart';
import '../services/uptimerobot_api_client.dart';
import 'monitor_providers.dart';

final accountRepositoryProvider = Provider<AccountRepository>(
  (ref) => AccountRepository(),
);

/// List of saved accounts, persisted to secure storage.
class AccountsNotifier extends AsyncNotifier<List<Account>> {
  AccountRepository get _repo => ref.read(accountRepositoryProvider);

  @override
  Future<List<Account>> build() async {
    List<Account> accounts;
    try {
      accounts = await _repo.loadAll();
    } catch (_) {
      // Secure storage channel unavailable (e.g. test harness) — start empty.
      accounts = [];
    }
    try {
      await ref
          .read(monitorRepositoryProvider)
          .pruneOrphanedAccounts(accounts.map((a) => a.id).toSet());
    } catch (_) {
      // Cache cleanup is best-effort; a failure here shouldn't block
      // showing the accounts that did load.
    }
    return accounts;
  }

  /// Validates the api_key against UptimeRobot before saving.
  /// Throws UptimeRobotApiException if the key is invalid.
  Future<void> addAccount({
    required String label,
    required String apiKey,
  }) async {
    final client = UptimeRobotApiClient(apiKey);
    try {
      await client.getAccountDetails();
    } finally {
      client.close();
    }
    final account = Account(
      id: const Uuid().v4(),
      label: label,
      apiKey: apiKey,
    );
    await _repo.add(account);
    state = AsyncData([...state.value ?? [], account]);
  }

  Future<void> removeAccount(String id) async {
    final removed = (state.value ?? []).firstWhere(
      (a) => a.id == id,
      orElse: () => Account(id: id, label: '', apiKey: ''),
    );
    await _repo.remove(id);
    if (removed.apiKey.isNotEmpty) {
      RateLimiter.removeForApiKey(removed.apiKey);
    }
    state = AsyncData((state.value ?? []).where((a) => a.id != id).toList());
  }

  Future<void> renameAccount(String id, String newLabel) async {
    final accounts = state.value ?? [];
    final index = accounts.indexWhere((a) => a.id == id);
    if (index == -1) return;
    final updated = accounts[index].copyWith(label: newLabel);
    await _repo.update(updated);
    final next = [...accounts];
    next[index] = updated;
    state = AsyncData(next);
  }

  /// Imports a batch of {label, apiKey} entries, skipping any api_key
  /// already present and validating each new one against UptimeRobot
  /// before saving. Never throws — failures are reported per entry.
  Future<ImportResult> importAccounts(
    List<Map<String, dynamic>> entries,
  ) async {
    final existingKeys = (state.value ?? []).map((a) => a.apiKey).toSet();
    var added = 0;
    var duplicates = 0;
    final failed = <String>[];

    for (final entry in entries) {
      final label = entry['label']?.toString().trim() ?? '';
      final apiKey = entry['apiKey']?.toString().trim() ?? '';
      if (apiKey.isEmpty) {
        failed.add(
          '${label.isEmpty ? 'unnamed entry' : label}: missing api key',
        );
        continue;
      }
      if (existingKeys.contains(apiKey)) {
        duplicates++;
        continue;
      }
      try {
        await addAccount(
          label: label.isEmpty ? 'Imported account' : label,
          apiKey: apiKey,
        );
        existingKeys.add(apiKey);
        added++;
      } catch (e) {
        failed.add('${label.isEmpty ? apiKey : label}: $e');
      }
    }

    return ImportResult(added: added, duplicates: duplicates, failed: failed);
  }
}

class ImportResult {
  final int added;
  final int duplicates;
  final List<String> failed;
  const ImportResult({
    required this.added,
    required this.duplicates,
    required this.failed,
  });
}

final accountsProvider = AsyncNotifierProvider<AccountsNotifier, List<Account>>(
  AccountsNotifier.new,
);

/// Per-account live summary (up/down/paused counts), fetched on demand.
final accountSummaryProvider =
    FutureProvider.autoDispose.family<AccountSummary, Account>((ref, account) {
      final client = UptimeRobotApiClient(account.apiKey);
      ref.onDispose(client.close);
      return client.getAccountDetails();
    });
