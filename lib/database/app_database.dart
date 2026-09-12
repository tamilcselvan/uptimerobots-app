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
  int get schemaVersion => 4;

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
      final staleIds = await (selectOnly(monitors)
            ..addColumns([monitors.id])
            ..where(monitors.accountId.equals(accountId) & monitors.id.isNotIn(keepIds)))
          .map((row) => row.read(monitors.id)!)
          .get();
      if (staleIds.isEmpty) return;

      await (delete(statusHistory)..where((h) => h.monitorId.isIn(staleIds))).go();
      await (delete(notificationLog)..where((n) => n.monitorId.isIn(staleIds))).go();
      await (delete(monitors)..where((m) => m.id.isIn(staleIds))).go();
    });
  }

  Future<void> recordSample(String monitorId, int status, int? responseTimeMs) async {
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
  Future<List<StatusHistoryEntry>> historyForMonitor(String monitorId, {int limit = 200}) async {
    final rows = await (select(statusHistory)
          ..where((h) => h.monitorId.equals(monitorId))
          ..orderBy([(h) => OrderingTerm.desc(h.recordedAt)])
          ..limit(limit))
        .get();
    return rows.reversed.toList();
  }

  /// Most recent [limit] notifications for one monitor, newest first.
  Future<List<NotificationLogEntry>> notificationsForMonitor(String monitorId,
      {int limit = 20}) {
    return (select(notificationLog)
          ..where((n) => n.monitorId.equals(monitorId))
          ..orderBy([(n) => OrderingTerm.desc(n.sentAt)])
          ..limit(limit))
        .get();
  }

  Future<void> setMuted(String monitorId, bool muted) async {
    await (update(monitors)..where((m) => m.id.equals(monitorId)))
        .write(MonitorsCompanion(muted: Value(muted)));
  }

  /// Deletes samples older than [maxAge] across all monitors. Called
  /// opportunistically after each sync — sampling every poll (added in
  /// schema v3, for the response-time chart) means this table grows
  /// unbounded without it.
  Future<void> pruneHistoryOlderThan(Duration maxAge) async {
    final cutoff = DateTime.now().subtract(maxAge);
    await (delete(statusHistory)..where((h) => h.recordedAt.isSmallerThanValue(cutoff))).go();
  }

  Future<void> removeAccountData(String accountId) async {
    await transaction(() async {
      final ids = await (selectOnly(monitors)
            ..addColumns([monitors.id])
            ..where(monitors.accountId.equals(accountId)))
          .map((row) => row.read(monitors.id)!)
          .get();
      if (ids.isEmpty) return;

      await (delete(statusHistory)..where((h) => h.monitorId.isIn(ids))).go();
      await (delete(notificationLog)..where((n) => n.monitorId.isIn(ids))).go();
      await (delete(monitors)..where((m) => m.accountId.equals(accountId))).go();
    });
  }
}
