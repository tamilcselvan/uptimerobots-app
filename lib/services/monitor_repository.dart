import 'package:drift/drift.dart' show Value;

import '../database/app_database.dart';
import '../models/account.dart';
import '../models/monitor.dart';
import 'notification_service.dart';
import 'ssl_certificate_checker.dart';
import 'uptimerobot_api_client.dart';

/// Notify on the tightest (smallest) day-threshold crossed, descending so
/// we always land on the most urgent applicable bucket.
const _sslThresholds = [30, 14, 7, 3, 1, 0];

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
  final SslCertificateChecker _sslChecker;

  MonitorRepository(
    this._db, {
    NotificationService? notifications,
    SslCertificateChecker? sslChecker,
  }) : _notifications = notifications ?? NotificationService(),
       _sslChecker = sslChecker ?? SslCertificateChecker();

  static String compositeId(String accountId, int uptimeRobotMonitorId) =>
      '${accountId}_$uptimeRobotMonitorId';

  Stream<List<MonitorRow>> watchAllMonitors() => _db.watchAllMonitors();

  /// Deletes cached monitors (and their history/notification rows) for any
  /// accountId in the cache that isn't in [validAccountIds] — e.g. an
  /// account whose secure-storage entry is gone (keyring cleared/reset)
  /// but whose synced monitors are still sitting in the drift cache.
  Future<void> pruneOrphanedAccounts(Set<String> validAccountIds) async {
    final cachedAccountIds = await _db.distinctMonitorAccountIds();
    for (final accountId in cachedAccountIds) {
      if (!validAccountIds.contains(accountId)) {
        await _db.removeAccountData(accountId);
      }
    }
  }

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
    await _checkDueSslCertificates(accounts);
    return results;
  }

  /// Client-side SSL expiry check — independent of UptimeRobot's API/plan,
  /// since SSL monitoring there is a paid-tier feature. Only connects to a
  /// monitor's host directly about once a day (see [AppDatabase.monitorsDueForSslCheck]),
  /// batched so many HTTPS monitors don't open dozens of sockets at once.
  Future<void> _checkDueSslCertificates(List<Account> accounts) async {
    final due = await _db.monitorsDueForSslCheck(const Duration(hours: 24));
    if (due.isEmpty) return;

    final accountsById = {for (final a in accounts) a.id: a};
    const batchSize = 4;
    for (var i = 0; i < due.length; i += batchSize) {
      final batch = due.skip(i).take(batchSize);
      await Future.wait(
        batch.map((m) => _checkOneSsl(m, accountsById[m.accountId])),
      );
    }
  }

  Future<void> _checkOneSsl(MonitorRow monitor, Account? account) async {
    final result = await _sslChecker.check(monitor.url);

    if (!result.succeeded) {
      await _db.setSslInfo(
        monitor.id,
        error: result.error,
        notifiedThreshold: monitor.sslLastNotifiedThreshold,
      );
      return;
    }

    final expiryDate = result.expiryDate!;
    final daysRemaining = expiryDate.difference(DateTime.now()).inDays;

    // A cert renewal (new expiry noticeably later than the last one seen)
    // resets the countdown so the next approach re-notifies from scratch.
    var baseline = monitor.sslLastNotifiedThreshold;
    final prevExpiry = monitor.sslExpiryDate;
    if (prevExpiry != null &&
        expiryDate.isAfter(prevExpiry.add(const Duration(days: 1)))) {
      baseline = null;
    }

    final crossedCandidates = _sslThresholds.where((t) => daysRemaining <= t);
    final tightest = crossedCandidates.isEmpty
        ? null
        : crossedCandidates.reduce((a, b) => a < b ? a : b);
    final shouldNotify =
        tightest != null &&
        account != null &&
        !monitor.muted &&
        (baseline == null || tightest < baseline);

    if (shouldNotify) {
      await _notifications.notifySslExpiry(
        notificationId: stableSslNotificationId(monitor.id),
        accountLabel: account.label,
        friendlyName: monitor.friendlyName,
        daysRemaining: daysRemaining,
        expiryDate: expiryDate,
      );
      baseline = tightest;
    }

    await _db.setSslInfo(
      monitor.id,
      expiryDate: expiryDate,
      notifiedThreshold: baseline,
    );
  }

  Future<void> setMuted(String monitorId, bool muted) =>
      _db.setMuted(monitorId, muted);

  Future<void> pruneHistoryOlderThan(Duration age) =>
      _db.pruneHistoryOlderThan(age);

  Future<AccountSyncResult> _syncOne(Account account) async {
    final client = UptimeRobotApiClient(account.apiKey);
    try {
      final monitors = await client.getMonitors();
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

        rows.add(
          MonitorsCompanion.insert(
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
          ),
        );
      }

      await _db.upsertMonitors(rows);
      await _db.pruneMonitors(account.id, rows.map((r) => r.id.value).toSet());

      return AccountSyncResult(account: account);
    } catch (e) {
      return AccountSyncResult(account: account, error: e);
    } finally {
      client.close();
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

    if (!isMuted &&
        prevNotified != null &&
        _statusBucket(prevNotified) != newBucket) {
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

  Future<void> removeAccountData(String accountId) =>
      _db.removeAccountData(accountId);
}
