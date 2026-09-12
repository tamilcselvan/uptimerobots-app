import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/background_sync_service.dart';
import '../services/foreground_sync_scheduler.dart';
import '../services/settings_repository.dart';

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) => SettingsRepository());

class SettingsNotifier extends AsyncNotifier<AppSettings> {
  SettingsRepository get _repo => ref.read(settingsRepositoryProvider);

  @override
  Future<AppSettings> build() => _repo.load();

  Future<void> updateSettings(AppSettings Function(AppSettings) updater) async {
    final current = state.value ?? const AppSettings();
    final next = updater(current);
    state = AsyncData(next);
    await _repo.save(next);

    if (next.foregroundInterval != current.foregroundInterval) {
      ref.read(foregroundSyncSchedulerProvider).updateInterval(next.foregroundInterval);
    }
    if (next.backgroundInterval != current.backgroundInterval) {
      await updateBackgroundSyncFrequency(next.backgroundInterval);
    }
  }
}

final settingsProvider = AsyncNotifierProvider<SettingsNotifier, AppSettings>(SettingsNotifier.new);
