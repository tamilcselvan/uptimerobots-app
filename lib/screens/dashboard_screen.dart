import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/app_database.dart';
import '../models/account.dart';
import '../models/monitor.dart';
import '../providers/account_providers.dart';
import '../providers/monitor_providers.dart';
import '../services/monitor_repository.dart';
import '../theme/app_theme.dart';
import '../theme/status_style.dart';
import '../widgets/monitor_tile.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  MonitorStatus? _statusFilter;
  String? _accountFilter;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(monitorSyncProvider.notifier).syncNow();
    });
  }

  @override
  Widget build(BuildContext context) {
    final monitorsAsync = ref.watch(allMonitorsProvider);
    final accounts = ref.watch(accountsProvider).value ?? [];
    final accountsById = {for (final a in accounts) a.id: a};
    final syncState = ref.watch(monitorSyncProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            tooltip: 'Sync now',
            icon: syncState.isLoading
                ? SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  )
                : const Icon(Icons.refresh),
            onPressed: syncState.isLoading
                ? null
                : () => ref.read(monitorSyncProvider.notifier).syncNow(),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Column(
        children: [
          _SyncErrorBanner(
            failures: (syncState.value ?? [])
                .where((r) => !r.succeeded)
                .toList(),
          ),
          monitorsAsync.maybeWhen(
            data: (monitors) => _SummaryStrip(monitors: monitors),
            orElse: () => const SizedBox.shrink(),
          ),
          _FilterBar(
            accounts: accounts,
            statusFilter: _statusFilter,
            accountFilter: _accountFilter,
            onStatusChanged: (s) => setState(() => _statusFilter = s),
            onAccountChanged: (a) => setState(() => _accountFilter = a),
          ),
          Expanded(
            child: monitorsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    "Couldn't load monitors.\n$err",
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              data: (monitors) {
                var filtered = monitors;
                if (_accountFilter != null) {
                  filtered = filtered
                      .where((m) => m.accountId == _accountFilter)
                      .toList();
                }
                if (_statusFilter != null) {
                  filtered = filtered
                      .where(
                        (m) => monitorStatusFromCode(m.status) == _statusFilter,
                      )
                      .toList();
                }
                if (filtered.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        monitors.isEmpty
                            ? 'No monitors yet.\nAdd an account to start watching your sites.'
                            : 'Nothing matches this filter.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: colorScheme.onSurfaceVariant),
                      ),
                    ),
                  );
                }
                return RefreshIndicator(
                  onRefresh: () =>
                      ref.read(monitorSyncProvider.notifier).syncNow(),
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
                    itemCount: filtered.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, index) => MonitorTile(
                      key: ValueKey(filtered[index].id),
                      monitor: filtered[index],
                      account: accountsById[filtered[index].accountId],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// At-a-glance counts. The one place on this screen where a big number is
/// the right treatment — on a monitoring dashboard, "how many are down
/// right now" genuinely is the single most important fact.
class _SummaryStrip extends StatelessWidget {
  final List<MonitorRow> monitors;
  const _SummaryStrip({required this.monitors});

  @override
  Widget build(BuildContext context) {
    final up = monitors
        .where((m) => monitorStatusFromCode(m.status) == MonitorStatus.up)
        .length;
    final down = monitors
        .where(
          (m) =>
              monitorStatusFromCode(m.status) == MonitorStatus.down ||
              monitorStatusFromCode(m.status) == MonitorStatus.seemsDown,
        )
        .length;
    final paused = monitors
        .where((m) => monitorStatusFromCode(m.status) == MonitorStatus.paused)
        .length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          _SummaryStat(
            value: up,
            label: 'Up',
            color: StatusStyle.of(context, MonitorStatus.up).color,
          ),
          const SizedBox(width: 24),
          _SummaryStat(
            value: down,
            label: 'Down',
            color: StatusStyle.of(context, MonitorStatus.down).color,
          ),
          const SizedBox(width: 24),
          _SummaryStat(
            value: paused,
            label: 'Paused',
            color: StatusStyle.of(context, MonitorStatus.paused).color,
          ),
        ],
      ),
    );
  }
}

class _SummaryStat extends StatelessWidget {
  final int value;
  final String label;
  final Color color;
  const _SummaryStat({
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$value',
          style: appMonoStyle(
            context,
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _SyncErrorBanner extends StatelessWidget {
  final List<AccountSyncResult> failures;
  const _SyncErrorBanner({required this.failures});

  @override
  Widget build(BuildContext context) {
    if (failures.isEmpty) return const SizedBox.shrink();
    final statusColors = StatusStyle.of(context, MonitorStatus.seemsDown);

    return Container(
      width: double.infinity,
      color: statusColors.color.withValues(alpha: 0.12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Icon(Icons.warning_amber, size: 18, color: statusColors.color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              "Couldn't sync ${failures.map((f) => f.account.label).join(', ')}. Showing cached data.",
              style: TextStyle(color: statusColors.color, fontSize: 12.5),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterBar extends StatelessWidget {
  final List<Account> accounts;
  final MonitorStatus? statusFilter;
  final String? accountFilter;
  final ValueChanged<MonitorStatus?> onStatusChanged;
  final ValueChanged<String?> onAccountChanged;

  const _FilterBar({
    required this.accounts,
    required this.statusFilter,
    required this.accountFilter,
    required this.onStatusChanged,
    required this.onAccountChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          DropdownButtonHideUnderline(
            child: DropdownButton<String?>(
              value: accountFilter,
              hint: const Text('All accounts'),
              borderRadius: BorderRadius.circular(10),
              items: [
                const DropdownMenuItem(
                  value: null,
                  child: Text('All accounts'),
                ),
                ...accounts.map(
                  (a) => DropdownMenuItem(value: a.id, child: Text(a.label)),
                ),
              ],
              onChanged: onAccountChanged,
            ),
          ),
          const SizedBox(width: 16),
          Container(
            width: 1,
            height: 20,
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
          const SizedBox(width: 16),
          ...MonitorStatus.values.map((s) {
            final selected = statusFilter == s;
            final style = StatusStyle.of(context, s);
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(style.label),
                avatar: Icon(
                  style.icon,
                  size: 16,
                  color: selected ? style.color : null,
                ),
                selected: selected,
                onSelected: (_) => onStatusChanged(selected ? null : s),
              ),
            );
          }),
        ],
      ),
    );
  }
}
