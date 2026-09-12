import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:uptimerobots_app/database/app_database.dart';
import 'package:uptimerobots_app/main.dart';
import 'package:uptimerobots_app/providers/account_providers.dart';
import 'package:uptimerobots_app/providers/monitor_providers.dart';
import 'package:uptimerobots_app/providers/settings_providers.dart';
import 'package:uptimerobots_app/services/account_repository.dart';
import 'package:uptimerobots_app/services/key_value_store.dart';
import 'package:uptimerobots_app/services/settings_repository.dart';

// Widget tests stub out storage/DB providers entirely — no real secure
// storage, drift database, or shared_preferences platform channel, so
// there's nothing to leak timers/channels or hang on in the sandbox.
// ignore: strict_top_level_inference
_testOverrides() => [
      accountRepositoryProvider.overrideWithValue(
        AccountRepository(storage: InMemoryKeyValueStore()),
      ),
      appDatabaseProvider.overrideWith(
        (ref) => AppDatabase.forTesting(NativeDatabase.memory()),
      ),
      allMonitorsProvider.overrideWith((ref) => Stream.value(const [])),
      settingsProvider.overrideWith(() => _FakeSettingsNotifier()),
    ];

class _FakeSettingsNotifier extends SettingsNotifier {
  @override
  Future<AppSettings> build() async => const AppSettings();
}

void main() {
  testWidgets('Dashboard tab shows empty state with no accounts', (tester) async {
    await tester.pumpWidget(
      ProviderScope(overrides: _testOverrides(), child: const UptimeRobotsApp()),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('Dashboard'), findsNWidgets(2)); // AppBar title + nav label
    expect(find.textContaining('No monitors yet'), findsOneWidget);
  });

  testWidgets('Accounts tab shows empty state with no accounts', (tester) async {
    await tester.pumpWidget(
      ProviderScope(overrides: _testOverrides(), child: const UptimeRobotsApp()),
    );
    await tester.pump();

    await tester.tap(find.text('Accounts'));
    await tester.pump();

    expect(find.text('Accounts'), findsNWidgets(2)); // AppBar title + nav label
    expect(find.textContaining('No accounts yet'), findsOneWidget);
  });

  testWidgets('Settings tab shows appearance and sync sections', (tester) async {
    await tester.pumpWidget(
      ProviderScope(overrides: _testOverrides(), child: const UptimeRobotsApp()),
    );
    await tester.pump();

    await tester.tap(find.text('Settings'));
    await tester.pump();
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    expect(find.text('Appearance'), findsOneWidget);
    expect(find.text('Sync frequency'), findsOneWidget);

    await tester.dragUntilVisible(
      find.text('Accounts backup'),
      find.byType(ListView),
      const Offset(0, -100),
    );
    expect(find.text('Accounts backup'), findsOneWidget);
  });
}
