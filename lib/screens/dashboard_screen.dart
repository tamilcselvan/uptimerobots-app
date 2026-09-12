import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/account.dart';
import '../models/monitor.dart';
import '../providers/account_providers.dart';
import '../providers/monitor_providers.dart';
import '../services/monitor_repository.dart';
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
      ref.read(monitorSyncProvider.notifier).syncNow();
    });
  }

  @override
  Widget build(BuildContext context) {
    final monitorsAsync = ref.watch(allMonitorsProvider);
    final accounts = ref.watch(accountsProvider).value ?? [];
    final accountsById = {for (final a in accounts) a.id: a};
    final syncState = ref.watch(monitorSyncProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: syncState.isLoading
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.refresh),
            onPressed: syncState.isLoading
                ? null
                : () => ref.read(monitorSyncProvider.notifier).syncNow(),
          ),
        ],
      ),
      body: Column(
        children: [
          _SyncErrorBanner(failures: (syncState.value ?? []).where((r) => !r.succeeded).toList()),
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
              error: (err, _) => Center(child: Text('Failed to load monitors: $err')),
              data: (monitors) {
                var filtered = monitors;
                if (_accountFilter != null) {
                  filtered = filtered.where((m) => m.accountId == _accountFilter).toList();
                }
                if (_statusFilter != null) {
                  filtered = filtered
                      .where((m) => monitorStatusFromCode(m.status) == _statusFilter)
                      .toList();
                }
                if (filtered.isEmpty) {
                  return Center(
                    child: Text(
                      monitors.isEmpty
                          ? 'No monitors yet. Pull to refresh or check your accounts.'
                          : 'No monitors match the current filter.',
                      textAlign: TextAlign.center,
                    ),
                  );
                }
                return RefreshIndicator(
                  onRefresh: () => ref.read(monitorSyncProvider.notifier).syncNow(),
                  child: ListView.separated(
                    itemCount: filtered.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, index) => MonitorTile(
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

class _SyncErrorBanner extends StatelessWidget {
  final List<AccountSyncResult> failures;
  const _SyncErrorBanner({required this.failures});

  @override
  Widget build(BuildContext context) {
    if (failures.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      color: Colors.red.shade50,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Text(
        'Could not sync: ${failures.map((f) => f.account.label).join(', ')}. '
        'Showing cached data for these accounts.',
        style: TextStyle(color: Colors.red.shade900, fontSize: 12),
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          DropdownButton<String?>(
            value: accountFilter,
            hint: const Text('All accounts'),
            items: [
              const DropdownMenuItem(value: null, child: Text('All accounts')),
              ...accounts.map((a) => DropdownMenuItem(value: a.id, child: Text(a.label))),
            ],
            onChanged: onAccountChanged,
          ),
          const SizedBox(width: 12),
          ...MonitorStatus.values.map((s) {
            final selected = statusFilter == s;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(s.name),
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
