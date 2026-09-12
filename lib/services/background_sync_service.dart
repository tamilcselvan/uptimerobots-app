import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:workmanager/workmanager.dart';

import '../database/app_database.dart';
import 'account_repository.dart';
import 'monitor_repository.dart';
import 'notification_service.dart';

const backgroundSyncTaskName = 'uptimerobots_background_sync';

/// Runs in a separate isolate with no access to the app's Riverpod
/// container, so it builds its own instances of everything it needs.
@pragma('vm:entry-point')
void backgroundSyncCallbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    WidgetsFlutterBinding.ensureInitialized();

    final db = AppDatabase();
    try {
      final accounts = await AccountRepository().loadAll();
      if (accounts.isEmpty) return true;

      final repository = MonitorRepository(
        db,
        notifications: NotificationService(),
      );
      await repository.syncAll(accounts);
      return true;
    } catch (e, stack) {
      debugPrint('Background sync failed: $e\n$stack');
      return false;
    } finally {
      await db.close();
    }
  });
}

/// Registers periodic background sync. Supported (best-effort) on Android,
/// iOS, macOS and Linux (systemd) via the `workmanager` federated plugin;
/// Windows has no background-task backend, so it relies solely on the
/// foreground timer (see ForegroundSyncScheduler) while the app is open.
///
/// [frequency] is clamped to Android's 15-minute minimum for periodic work
/// by the platform itself if a shorter value is passed.
Future<void> registerBackgroundSync({
  Duration frequency = const Duration(minutes: 15),
}) async {
  if (Platform.isWindows) return;

  await Workmanager().initialize(backgroundSyncCallbackDispatcher);
  await Workmanager().registerPeriodicTask(
    backgroundSyncTaskName,
    backgroundSyncTaskName,
    frequency: frequency,
    constraints: Constraints(networkType: NetworkType.connected),
    existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
  );
}

/// Re-registers the periodic task with a new frequency, e.g. after a
/// settings change. `keep` is only useful for the initial registration —
/// changing the interval requires replacing the existing task outright.
Future<void> updateBackgroundSyncFrequency(Duration frequency) async {
  if (Platform.isWindows) return;

  await Workmanager().cancelByUniqueName(backgroundSyncTaskName);
  await Workmanager().registerPeriodicTask(
    backgroundSyncTaskName,
    backgroundSyncTaskName,
    frequency: frequency,
    constraints: Constraints(networkType: NetworkType.connected),
    existingWorkPolicy: ExistingPeriodicWorkPolicy.replace,
  );
}
