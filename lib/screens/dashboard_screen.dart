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
  String _searchQuery = '';
  final _searchController = TextEditingController();
  bool _groupByAccount = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(monitorSyncProvider.notifier).syncNow();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  int _statusSortKey(int status) {
    final s = monitorStatusFromCode(status);
    if (s == MonitorStatus.down || s == MonitorStatus.seemsDown) return 0;
    if (s == MonitorStatus.up) return 1;
    if (s == MonitorStatus.paused) return 2;
    return 3;
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
            data: (monitors) => _SummaryStrip(
              monitors: monitors,
              statusFilter: _statusFilter,
              onTap: (s) => setState(() => _statusFilter = _statusFilter == s ? null : s),
            ),
            orElse: () => const SizedBox.shrink(),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search monitors by name or URL…',
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: _searchQuery.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () => setState(() {
                          _searchQuery = '';
                          _searchController.clear();
                        }),
                      ),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
              onChanged: (v) => setState(() => _searchQuery = v.trim().toLowerCase()),
            ),
          ),
          _FilterBar(
            accounts: accounts,
            statusFilter: _statusFilter,
            accountFilter: _accountFilter,
            groupByAccount: _groupByAccount,
            onStatusChanged: (s) => setState(() => _statusFilter = s),
            onAccountChanged: (a) => setState(() => _accountFilter = a),
            onGroupChanged: (v) => setState(() => _groupByAccount = v),
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
                var filtered = [...monitors];
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
                if (_searchQuery.isNotEmpty) {
                  filtered = filtered
                      .where((m) =>
                          m.friendlyName.toLowerCase().contains(_searchQuery) ||
                          m.url.toLowerCase().contains(_searchQuery))
                      .toList();
                }
                filtered.sort((a, b) {
                  final c = _statusSortKey(a.status).compareTo(_statusSortKey(b.status));
                  if (c != 0) return c;
                  return a.friendlyName.toLowerCase().compareTo(b.friendlyName.toLowerCase());
                });
                if (filtered.isEmpty) {
                  final isFiltered = monitors.isNotEmpty;
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            monitors.isEmpty
                                ? 'No monitors yet.\nAdd an account to start watching your sites.'
                                : 'Nothing matches this filter.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: colorScheme.onSurfaceVariant),
                          ),
                          if (isFiltered) ...[
                            const SizedBox(height: 8),
                            Text(
                              'Showing 0 of ${monitors.length}',
                              style: TextStyle(
                                fontSize: 12,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ] else ...[
                            const SizedBox(height: 16),
                            FilledButton.icon(
                              icon: const Icon(Icons.manage_accounts_outlined),
                              label: const Text('Add account'),
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Go to Accounts tab to add an account')),
                                );
                              },
                            ),
                          ],
                          if (isFiltered) ...[
                            const SizedBox(height: 12),
                            TextButton(
                              onPressed: () => setState(() {
                                _statusFilter = null;
                                _accountFilter = null;
                                _searchQuery = '';
                                _searchController.clear();
                              }),
                              child: const Text('Clear filters'),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                }
                final countLabel = filtered.length == monitors.length
                    ? '${filtered.length} monitors'
                    : '${filtered.length} of ${monitors.length}';
                if (_groupByAccount && _accountFilter == null) {
                  final grouped = <String, List<MonitorRow>>{};
                  for (final m in filtered) {
                    grouped.putIfAbsent(m.accountId, () => []).add(m);
                  }
                  final accountIds = grouped.keys.toList()
                    ..sort((a, b) => (accountsById[a]?.label ?? a)
                        .compareTo(accountsById[b]?.label ?? b));
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            countLabel,
                            style: TextStyle(
                              fontSize: 12,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: RefreshIndicator(
                          onRefresh: () => ref.read(monitorSyncProvider.notifier).syncNow(),
                          child: ListView.builder(
                            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                            itemCount: accountIds.length,
                            itemBuilder: (context, idx) {
                              final accId = accountIds[idx];
                              final acc = accountsById[accId];
                              final list = grouped[accId]!;
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(4, 12, 4, 6),
                                    child: Text(
                                      acc?.label ?? 'Unknown account',
                                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                            color: colorScheme.onSurfaceVariant,
                                          ),
                                    ),
                                  ),
                                  ...list.map((m) => Padding(
                                        padding: const EdgeInsets.only(bottom: 8),
                                        child: MonitorTile(
                                          key: ValueKey(m.id),
                                          monitor: m,
                                          account: accountsById[m.accountId],
                                        ),
                                      )),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  );
                }
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          countLabel,
                          style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final isWide = constraints.maxWidth > 700;
                          if (isWide) {
                            return RefreshIndicator(
                              onRefresh: () => ref.read(monitorSyncProvider.notifier).syncNow(),
                              child: GridView.builder(
                                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 8,
                                  mainAxisSpacing: 8,
                                  childAspectRatio: 3.2,
                                ),
                                itemCount: filtered.length,
                                itemBuilder: (context, index) => MonitorTile(
                                  key: ValueKey(filtered[index].id),
                                  monitor: filtered[index],
                                  account: accountsById[filtered[index].accountId],
                                ),
                              ),
                            );
                          }
                          return RefreshIndicator(
                            onRefresh: () => ref.read(monitorSyncProvider.notifier).syncNow(),
                            child: ListView.separated(
                              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
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
  final MonitorStatus? statusFilter;
  final ValueChanged<MonitorStatus> onTap;
  const _SummaryStrip({
    required this.monitors,
    required this.statusFilter,
    required this.onTap,
  });

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
            selected: statusFilter == MonitorStatus.up,
            onTap: () => onTap(MonitorStatus.up),
          ),
          const SizedBox(width: 24),
          _SummaryStat(
            value: down,
            label: 'Down',
            color: StatusStyle.of(context, MonitorStatus.down).color,
            selected: statusFilter == MonitorStatus.down || statusFilter == MonitorStatus.seemsDown,
            onTap: () => onTap(MonitorStatus.down),
          ),
          const SizedBox(width: 24),
          _SummaryStat(
            value: paused,
            label: 'Paused',
            color: StatusStyle.of(context, MonitorStatus.paused).color,
            selected: statusFilter == MonitorStatus.paused,
            onTap: () => onTap(MonitorStatus.paused),
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
  final bool selected;
  final VoidCallback? onTap;
  const _SummaryStat({
    required this.value,
    required this.label,
    required this.color,
    this.selected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final content = Column(
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
            color: selected ? color : Theme.of(context).colorScheme.onSurfaceVariant,
            fontWeight: selected ? FontWeight.w600 : null,
          ),
        ),
      ],
    );
    if (onTap == null) return content;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: content,
      ),
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
  final bool groupByAccount;
  final ValueChanged<MonitorStatus?> onStatusChanged;
  final ValueChanged<String?> onAccountChanged;
  final ValueChanged<bool> onGroupChanged;

  const _FilterBar({
    required this.accounts,
    required this.statusFilter,
    required this.accountFilter,
    required this.groupByAccount,
    required this.onStatusChanged,
    required this.onAccountChanged,
    required this.onGroupChanged,
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
          const SizedBox(width: 8),
          FilterChip(
            label: const Text('Group'),
            avatar: const Icon(Icons.group_outlined, size: 16),
            selected: groupByAccount,
            onSelected: onGroupChanged,
          ),
        ],
      ),
    );
  }
}
