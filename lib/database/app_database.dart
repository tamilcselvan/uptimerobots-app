import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

/// UptimeRobot monitor status codes (from the API):
/// 0 paused, 1 not-checked-yet, 2 up, 8 seems-down, 9 down.
@DataClassName('MonitorRow')
class Monitors extends Table {
  TextColumn get id => text()(); // "${accountId}_${uptimeRobotMonitorId}"
  TextColumn get accountId => text()();
  IntColumn get uptimeRobotMonitorId => integer()();
  TextColumn get friendlyName => text()();
  TextColumn get url => text()();
  IntColumn get type => integer()();
  IntColumn get status => integer()();
  RealColumn get allTimeUptimeRatio => real().withDefault(const Constant(0))();
  IntColumn get responseTimeMs => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastSyncedAt => dateTime()();
  // Added in schema v2 — last status a notification was already sent for,
  // so a monitor stuck "down" across many polls doesn't re-notify each time.
  IntColumn get lastNotifiedStatus => integer().nullable()();
  // Added in schema v4 — user-muted monitors are still synced/cached, just
  // never trigger a notification.
  BoolColumn get muted => boolean().withDefault(const Constant(false))();
  // Added in schema v5 — client-side SSL certificate expiry, checked
  // directly against the monitored host (independent of UptimeRobot's
  // plan tier, which gates this on their side).
  DateTimeColumn get sslExpiryDate => dateTime().nullable()();
  DateTimeColumn get sslLastCheckedAt => dateTime().nullable()();
  TextColumn get sslCheckError => text().nullable()();
  IntColumn get sslLastNotifiedThreshold => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('StatusHistoryEntry')
class StatusHistory extends Table {
  IntColumn get rowId => integer().autoIncrement()();
  TextColumn get monitorId => text().references(Monitors, #id)();
  IntColumn get status => integer()();
  DateTimeColumn get recordedAt => dateTime()();
  // Added in schema v3 — sampled every poll (not just on status change) so
  // the detail screen can chart response time over time.
  IntColumn get responseTimeMs => integer().nullable()();
}

// Added in schema v2 — audit trail of notifications actually sent.
@DataClassName('NotificationLogEntry')
class NotificationLog extends Table {
  IntColumn get rowId => integer().autoIncrement()();
  TextColumn get monitorId => text().references(Monitors, #id)();
  TextColumn get event => text()(); // e.g. "up_to_down", "down_to_up"
  DateTimeColumn get sentAt => dateTime()();
}

@DriftDatabase(tables: [Monitors, StatusHistory, NotificationLog])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 5;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.addColumn(monitors, monitors.lastNotifiedStatus);
        await m.createTable(notificationLog);
      }
      if (from < 3) {
        await m.addColumn(statusHistory, statusHistory.responseTimeMs);
      }
      if (from < 4) {
        await m.addColumn(monitors, monitors.muted);
      }
      if (from < 5) {
        await m.addColumn(monitors, monitors.sslExpiryDate);
        await m.addColumn(monitors, monitors.sslLastCheckedAt);
        await m.addColumn(monitors, monitors.sslCheckError);
        await m.addColumn(monitors, monitors.sslLastNotifiedThreshold);
      }
    },
  );

  static QueryExecutor _openConnection() =>
      driftDatabase(name: 'uptimerobots_app');

  Future<List<MonitorRow>> monitorsForAccount(String accountId) =>
      (select(monitors)..where((m) => m.accountId.equals(accountId))).get();

  Stream<List<MonitorRow>> watchAllMonitors() => select(monitors).watch();

  Future<void> upsertMonitors(List<MonitorsCompanion> rows) async {
    await batch((b) => b.insertAllOnConflictUpdate(monitors, rows));
  }

  /// Removes cached monitors for an account that no longer came back
  /// from the API (deleted/renamed on UptimeRobot's side), along with
  /// their history/notification rows (no FK cascade in sqlite by default).
  Future<void> pruneMonitors(String accountId, Set<String> keepIds) async {
    await transaction(() async {
      final staleIds =
          await (selectOnly(monitors)
                ..addColumns([monitors.id])
                ..where(
                  monitors.accountId.equals(accountId) &
                      monitors.id.isNotIn(keepIds),
                ))
              .map((row) => row.read(monitors.id)!)
              .get();
      if (staleIds.isEmpty) return;

      await (delete(
        statusHistory,
      )..where((h) => h.monitorId.isIn(staleIds))).go();
      await (delete(
        notificationLog,
      )..where((n) => n.monitorId.isIn(staleIds))).go();
      await (delete(monitors)..where((m) => m.id.isIn(staleIds))).go();
    });
  }

  Future<void> recordSample(
    String monitorId,
    int status,
    int? responseTimeMs,
  ) async {
    await into(statusHistory).insert(
      StatusHistoryCompanion.insert(
        monitorId: monitorId,
        status: status,
        recordedAt: DateTime.now(),
        responseTimeMs: Value(responseTimeMs),
      ),
    );
  }

  Future<void> recordNotification(String monitorId, String event) async {
    await into(notificationLog).insert(
      NotificationLogCompanion.insert(
        monitorId: monitorId,
        event: event,
        sentAt: DateTime.now(),
      ),
    );
  }

  /// Most recent [limit] samples for one monitor, oldest first (chart order).
  Future<List<StatusHistoryEntry>> historyForMonitor(
    String monitorId, {
    int limit = 200,
  }) async {
    final rows =
        await (select(statusHistory)
              ..where((h) => h.monitorId.equals(monitorId))
              ..orderBy([(h) => OrderingTerm.desc(h.recordedAt)])
              ..limit(limit))
            .get();
    return rows.reversed.toList();
  }

  /// Most recent [limit] notifications for one monitor, newest first.
  Future<List<NotificationLogEntry>> notificationsForMonitor(
    String monitorId, {
    int limit = 20,
  }) {
    return (select(notificationLog)
          ..where((n) => n.monitorId.equals(monitorId))
          ..orderBy([(n) => OrderingTerm.desc(n.sentAt)])
          ..limit(limit))
        .get();
  }

  Future<void> setMuted(String monitorId, bool muted) async {
    await (update(monitors)..where((m) => m.id.equals(monitorId))).write(
      MonitorsCompanion(muted: Value(muted)),
    );
  }

  /// Deletes samples older than [maxAge] across all monitors. Called
  /// opportunistically after each sync — sampling every poll (added in
  /// schema v3, for the response-time chart) means this table grows
  /// unbounded without it.
  Future<void> pruneHistoryOlderThan(Duration maxAge) async {
    final cutoff = DateTime.now().subtract(maxAge);
    await (delete(
      statusHistory,
    )..where((h) => h.recordedAt.isSmallerThanValue(cutoff))).go();
  }

  /// HTTPS monitors (type 1, url starting "https://") whose SSL cert
  /// hasn't been checked in [maxAge] — or never. Keeps the direct
  /// connection to the monitored host to roughly once a day regardless
  /// of how often the regular UptimeRobot sync runs.
  Future<List<MonitorRow>> monitorsDueForSslCheck(Duration maxAge) async {
    final cutoff = DateTime.now().subtract(maxAge);
    return (select(monitors)..where(
          (m) =>
              m.type.equals(1) &
              m.status.equals(0).not() &
              m.url.like('https://%') &
              (m.sslLastCheckedAt.isNull() |
                  m.sslLastCheckedAt.isSmallerThanValue(cutoff)),
        ))
        .get();
  }

  Future<void> setSslInfo(
    String monitorId, {
    DateTime? expiryDate,
    String? error,
    int? notifiedThreshold,
  }) async {
    await (update(monitors)..where((m) => m.id.equals(monitorId))).write(
      MonitorsCompanion(
        sslExpiryDate: Value(expiryDate),
        sslLastCheckedAt: Value(DateTime.now()),
        sslCheckError: Value(error),
        sslLastNotifiedThreshold: Value(notifiedThreshold),
      ),
    );
  }

  Future<Set<String>> distinctMonitorAccountIds() async {
    final rows =
        await (selectOnly(monitors)
              ..addColumns([monitors.accountId])
              ..groupBy([monitors.accountId]))
            .map((row) => row.read(monitors.accountId)!)
            .get();
    return rows.toSet();
  }

  Future<void> removeAccountData(String accountId) async {
    await transaction(() async {
      final ids =
          await (selectOnly(monitors)
                ..addColumns([monitors.id])
                ..where(monitors.accountId.equals(accountId)))
              .map((row) => row.read(monitors.id)!)
              .get();
      if (ids.isEmpty) return;

      await (delete(statusHistory)..where((h) => h.monitorId.isIn(ids))).go();
      await (delete(notificationLog)..where((n) => n.monitorId.isIn(ids))).go();
      await (delete(
        monitors,
      )..where((m) => m.accountId.equals(accountId))).go();
    });
  }
}
