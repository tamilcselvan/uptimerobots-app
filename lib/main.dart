import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'models/monitor.dart';
import 'providers/monitor_providers.dart';
import 'providers/settings_providers.dart';
import 'screens/accounts_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/settings_screen.dart';
import 'services/background_sync_service.dart';
import 'services/foreground_sync_scheduler.dart';
import 'services/notification_service.dart';
import 'services/settings_repository.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await NotificationService().init();

  final settings = await SettingsRepository().load();
  try {
    await registerBackgroundSync(frequency: settings.backgroundInterval);
  } catch (_) {
    // Best-effort: platform may not support background scheduling
    // (or the host has no systemd/BGTaskScheduler available). The
    // foreground scheduler still keeps the app fresh while it's open.
  }

  runApp(const ProviderScope(child: UptimeRobotsApp()));
}

class UptimeRobotsApp extends ConsumerWidget {
  const UptimeRobotsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode =
        ref.watch(settingsProvider).value?.themeMode ?? ThemeMode.system;

    return MaterialApp(
      title: 'UptimeRobots',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      home: const HomeShell(),
    );
  }
}

class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key});

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> {
  int _index = 0;

  static const _screens = [
    DashboardScreen(),
    AccountsScreen(),
    SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final settings = await ref.read(settingsProvider.future);
      if (!mounted) return;
      ref
          .read(foregroundSyncSchedulerProvider)
          .start(interval: settings.foregroundInterval);
    });
  }

  @override
  Widget build(BuildContext context) {
    final monitorsAsync = ref.watch(allMonitorsProvider);
    final downCount = monitorsAsync.maybeWhen(
      data: (list) => list.where((m) {
        final s = monitorStatusFromCode(m.status);
        return s == MonitorStatus.down || s == MonitorStatus.seemsDown;
      }).length,
      orElse: () => 0,
    );
    final syncAsync = ref.watch(monitorSyncProvider);
    final hasError = (syncAsync.value ?? []).any((r) => !r.succeeded);
    return Scaffold(
      body: Column(
        children: [
          if (hasError)
            Material(
              color: Theme.of(context).colorScheme.errorContainer,
              child: InkWell(
                onTap: () => ref.read(monitorSyncProvider.notifier).syncNow(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      Icon(Icons.cloud_off, size: 16, color: Theme.of(context).colorScheme.onErrorContainer),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Some accounts failed to sync — showing cached data. Tap to retry.',
                          style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onErrorContainer),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          Expanded(child: IndexedStack(index: _index, children: _screens)),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) {
          Feedback.forTap(context);
          setState(() => _index = i);
        },
        destinations: [
          NavigationDestination(
            icon: Badge(
              isLabelVisible: downCount > 0,
              label: Text('$downCount'),
              child: const Icon(Icons.dashboard_outlined),
            ),
            selectedIcon: Badge(
              isLabelVisible: downCount > 0,
              label: Text('$downCount'),
              child: const Icon(Icons.dashboard),
            ),
            label: 'Dashboard',
          ),
          const NavigationDestination(
            icon: Icon(Icons.manage_accounts_outlined),
            selectedIcon: Icon(Icons.manage_accounts),
            label: 'Accounts',
          ),
          const NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
