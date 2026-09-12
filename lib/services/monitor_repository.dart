import 'package:drift/drift.dart' show Value;

import '../database/app_database.dart';
import '../models/account.dart';
import '../models/monitor.dart';
import 'notification_service.dart';
import 'uptimerobot_api_client.dart';

class AccountSyncResult {
  final Account account;
  final Object? error;
  const AccountSyncResult({required this.account, this.error});

  bool get succeeded => error == null;
}

/// up(2) -> 1, down-like (8, 9) -> -1, paused/not-checked-yet/unknown -> 0 (neutral).
int _statusBucket(int status) {
  if (status == 2) return 1;
  if (status == 8 || status == 9) return -1;
  return 0;
}

/// Bridges the UptimeRobot API and the local drift cache.
/// One account's failure (bad key, network blip, rate limit) never
/// blocks the others — each is synced independently.
class MonitorRepository {
  final AppDatabase _db;
  final NotificationService _notifications;

  MonitorRepository(this._db, {NotificationService? notifications})
      : _notifications = notifications ?? NotificationService();

  static String compositeId(String accountId, int uptimeRobotMonitorId) =>
      '${accountId}_$uptimeRobotMonitorId';

  Stream<List<MonitorRow>> watchAllMonitors() => _db.watchAllMonitors();

  /// Fetches monitors for every account and upserts them into the cache.
  /// Returns per-account outcomes so the UI can surface partial failures.
  Future<List<AccountSyncResult>> syncAll(List<Account> accounts) async {
    final results = <AccountSyncResult>[];
    for (final account in accounts) {
      results.add(await _syncOne(account));
    }
    // Opportunistic retention: sampling every poll (schema v3) means
    // StatusHistory grows unbounded without this.
    await _db.pruneHistoryOlderThan(const Duration(days: 30));
    return results;
  }

  Future<void> setMuted(String monitorId, bool muted) => _db.setMuted(monitorId, muted);

  Future<void> pruneHistoryOlderThan(Duration age) => _db.pruneHistoryOlderThan(age);

  Future<AccountSyncResult> _syncOne(Account account) async {
    try {
      final monitors = await UptimeRobotApiClient(account.apiKey).getMonitors();
      final existingRows = {
        for (final row in await _db.monitorsForAccount(account.id)) row.id: row,
      };
      final now = DateTime.now();
      final rows = <MonitorsCompanion>[];

      for (final m in monitors) {
        final id = compositeId(account.id, m.uptimeRobotMonitorId);
        final existing = existingRows[id];

        // Sampled every poll (not just on status change) so the detail
        // screen can chart response time over time.
        await _db.recordSample(id, m.status, m.responseTimeMs);

        final newLastNotified = await _maybeNotify(
          account: account,
          monitorId: id,
          friendlyName: m.friendlyName,
          existing: existing,
          newStatus: m.status,
        );

        rows.add(MonitorsCompanion.insert(
          id: id,
          accountId: account.id,
          uptimeRobotMonitorId: m.uptimeRobotMonitorId,
          friendlyName: m.friendlyName,
          url: m.url,
          type: m.type,
          status: m.status,
          allTimeUptimeRatio: Value(m.allTimeUptimeRatio),
          responseTimeMs: Value(m.responseTimeMs),
          lastSyncedAt: now,
          lastNotifiedStatus: Value(newLastNotified),
        ));
      }

      await _db.upsertMonitors(rows);
      await _db.pruneMonitors(account.id, rows.map((r) => r.id.value).toSet());

      return AccountSyncResult(account: account);
    } catch (e) {
      return AccountSyncResult(account: account, error: e);
    }
  }

  /// Compares the new status against the last status a notification was
  /// sent for, fires a local notification on a genuine up<->down flip, and
  /// returns the value [lastNotifiedStatus] should be updated to.
  ///
  /// A brand new monitor (no [existing] row) never notifies — there's no
  /// real transition, just initial population. Paused / not-checked-yet
  /// readings are neutral: they don't trigger a notification and don't
  /// overwrite the last decisive (up/down) status, so a later flip back
  /// from before the pause still compares correctly. A muted monitor keeps
  /// tracking its baseline (so unmuting later doesn't fire a stale
  /// notification for a transition that happened while muted) but never
  /// actually notifies.
  Future<int?> _maybeNotify({
    required Account account,
    required String monitorId,
    required String friendlyName,
    required MonitorRow? existing,
    required int newStatus,
  }) async {
    final newBucket = _statusBucket(newStatus);
    if (newBucket == 0) return existing?.lastNotifiedStatus;
    if (existing == null) return newStatus; // baseline, no notification

    final prevNotified = existing.lastNotifiedStatus;
    final isMuted = existing.muted;

    if (!isMuted && prevNotified != null && _statusBucket(prevNotified) != newBucket) {
      final event = newBucket == 1 ? 'down_to_up' : 'up_to_down';
      await _notifications.notifyStatusChange(
        notificationId: stableNotificationId(monitorId),
        accountLabel: account.label,
        friendlyName: friendlyName,
        oldStatus: monitorStatusFromCode(prevNotified),
        newStatus: monitorStatusFromCode(newStatus),
      );
      await _db.recordNotification(monitorId, event);
    }

    return newStatus;
  }

  Future<void> removeAccountData(String accountId) => _db.removeAccountData(accountId);
}
