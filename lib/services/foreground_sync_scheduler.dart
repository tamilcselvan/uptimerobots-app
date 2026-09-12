import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/monitor_providers.dart';

/// Keeps the dashboard fresh while the app is open and in the foreground,
/// independent of the OS-level background scheduler (which is best-effort
/// and, on mobile, throttled to ~15 minute minimums). This is what makes
/// the desktop experience (app left open, watching the dashboard) feel
/// live, and complements — doesn't replace — [registerBackgroundSync].
class ForegroundSyncScheduler {
  static const defaultInterval = Duration(minutes: 5);

  final Ref _ref;
  Timer? _timer;
  Duration _interval = defaultInterval;

  ForegroundSyncScheduler(this._ref);

  void start({Duration? interval}) {
    _interval = interval ?? _interval;
    _timer?.cancel();
    _timer = Timer.periodic(_interval, (_) {
      _ref.read(monitorSyncProvider.notifier).syncNow();
    });
  }

  /// Restarts the timer with a new interval, e.g. after a settings change.
  void updateInterval(Duration interval) => start(interval: interval);

  void stop() {
    _timer?.cancel();
    _timer = null;
  }
}

final foregroundSyncSchedulerProvider = Provider<ForegroundSyncScheduler>((ref) {
  final scheduler = ForegroundSyncScheduler(ref);
  ref.onDispose(scheduler.stop);
  return scheduler;
});
