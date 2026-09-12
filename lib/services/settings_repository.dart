import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettings {
  final ThemeMode themeMode;
  final Duration foregroundInterval;
  final Duration backgroundInterval;

  const AppSettings({
    this.themeMode = ThemeMode.system,
    this.foregroundInterval = const Duration(minutes: 5),
    this.backgroundInterval = const Duration(minutes: 15),
  });

  AppSettings copyWith({
    ThemeMode? themeMode,
    Duration? foregroundInterval,
    Duration? backgroundInterval,
  }) =>
      AppSettings(
        themeMode: themeMode ?? this.themeMode,
        foregroundInterval: foregroundInterval ?? this.foregroundInterval,
        backgroundInterval: backgroundInterval ?? this.backgroundInterval,
      );
}

/// Persists user-tunable settings in shared_preferences (non-sensitive,
/// unlike account API keys which stay in secure storage).
class SettingsRepository {
  static const _themeModeKey = 'settings_theme_mode';
  static const _foregroundMinutesKey = 'settings_foreground_minutes';
  static const _backgroundMinutesKey = 'settings_background_minutes';

  Future<AppSettings> load() async {
    final prefs = await SharedPreferences.getInstance();
    final themeModeName = prefs.getString(_themeModeKey);
    final themeMode = ThemeMode.values.firstWhere(
      (m) => m.name == themeModeName,
      orElse: () => ThemeMode.system,
    );
    final foregroundMinutes = prefs.getInt(_foregroundMinutesKey) ?? 5;
    final backgroundMinutes = prefs.getInt(_backgroundMinutesKey) ?? 15;

    return AppSettings(
      themeMode: themeMode,
      foregroundInterval: Duration(minutes: foregroundMinutes),
      backgroundInterval: Duration(minutes: backgroundMinutes),
    );
  }

  Future<void> save(AppSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeModeKey, settings.themeMode.name);
    await prefs.setInt(_foregroundMinutesKey, settings.foregroundInterval.inMinutes);
    await prefs.setInt(_backgroundMinutesKey, settings.backgroundInterval.inMinutes);
  }
}
