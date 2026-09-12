import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/app_database.dart';
import 'account_providers.dart';
import '../services/monitor_repository.dart';

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final monitorRepositoryProvider = Provider<MonitorRepository>((ref) {
  return MonitorRepository(ref.watch(appDatabaseProvider));
});

/// Live view of every cached monitor across all accounts.
final allMonitorsProvider = StreamProvider<List<MonitorRow>>((ref) {
  return ref.watch(monitorRepositoryProvider).watchAllMonitors();
});

/// Response-time/status samples for one monitor, oldest first (chart order).
/// Re-fetches whenever a sync updates the cache (via the [allMonitorsProvider]
/// dependency), so the detail screen stays live while it's open.
final monitorHistoryProvider =
    FutureProvider.family<List<StatusHistoryEntry>, String>((
      ref,
      monitorId,
    ) async {
      ref.watch(allMonitorsProvider);
      return ref.watch(appDatabaseProvider).historyForMonitor(monitorId);
    });

/// Recent notifications sent for one monitor, newest first.
final monitorNotificationsProvider =
    FutureProvider.family<List<NotificationLogEntry>, String>((
      ref,
      monitorId,
    ) async {
      ref.watch(allMonitorsProvider);
      return ref.watch(appDatabaseProvider).notificationsForMonitor(monitorId);
    });

/// Triggers a sync of all accounts against the UptimeRobot API and
/// reports per-account results (so the UI can flag a bad key without
/// hiding data from the other accounts).
class MonitorSyncNotifier extends AsyncNotifier<List<AccountSyncResult>> {
  @override
  Future<List<AccountSyncResult>> build() async => [];

  Future<void> syncNow() async {
    final accounts = ref.read(accountsProvider).value ?? [];
    if (accounts.isEmpty) {
      state = const AsyncData([]);
      return;
    }
    state = const AsyncLoading();
    final results = await ref.read(monitorRepositoryProvider).syncAll(accounts);
    state = AsyncData(results);
  }
}

final monitorSyncProvider =
    AsyncNotifierProvider<MonitorSyncNotifier, List<AccountSyncResult>>(
      MonitorSyncNotifier.new,
    );
