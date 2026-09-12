import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/account.dart';
import '../models/monitor.dart';
import '../providers/account_providers.dart';
import '../providers/monitor_providers.dart';
import '../theme/app_theme.dart';
import '../theme/status_style.dart';
import '../widgets/accent_panel.dart';
import 'add_account_screen.dart';

class AccountsScreen extends ConsumerWidget {
  const AccountsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountsAsync = ref.watch(accountsProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Accounts')),
      body: accountsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              "Couldn't load accounts.\n$err",
              textAlign: TextAlign.center,
            ),
          ),
        ),
        data: (accounts) {
          if (accounts.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.dns_outlined,
                      size: 40,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No accounts yet',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Add an UptimeRobot account to see its monitors here.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: accounts.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) =>
                _AccountTile(account: accounts[index]),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Add account',
        onPressed: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const AddAccountScreen())),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _AccountTile extends ConsumerWidget {
  final Account account;
  const _AccountTile({required this.account});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(accountSummaryProvider(account));
    final colorScheme = Theme.of(context).colorScheme;

    final accentColor = summaryAsync.maybeWhen(
      data: (summary) => summary.downMonitors > 0
          ? StatusStyle.of(context, MonitorStatus.down).color
          : StatusStyle.of(context, MonitorStatus.up).color,
      orElse: () => colorScheme.outline,
    );

    return AccentPanel(
      accentColor: accentColor,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  account.label,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                summaryAsync.when(
                  loading: () => Text(
                    'Loading monitors…',
                    style: TextStyle(color: colorScheme.onSurfaceVariant),
                  ),
                  error: (err, _) => Text(
                    "Couldn't load: $err",
                    style: TextStyle(
                      color: StatusStyle.of(context, MonitorStatus.down).color,
                    ),
                  ),
                  data: (summary) => Row(
                    children: [
                      _CountBadge(
                        count: summary.upMonitors,
                        color: StatusStyle.of(context, MonitorStatus.up).color,
                      ),
                      const SizedBox(width: 14),
                      _CountBadge(
                        count: summary.downMonitors,
                        color: StatusStyle.of(
                          context,
                          MonitorStatus.down,
                        ).color,
                      ),
                      const SizedBox(width: 14),
                      _CountBadge(
                        count: summary.pausedMonitors,
                        color: StatusStyle.of(
                          context,
                          MonitorStatus.paused,
                        ).color,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Remove account',
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _confirmRemove(context, ref),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmRemove(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove account?'),
        content: Text(
          'This removes "${account.label}" from this app only. '
          'Nothing changes on UptimeRobot itself.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(monitorRepositoryProvider).removeAccountData(account.id);
      await ref.read(accountsProvider.notifier).removeAccount(account.id);
    }
  }
}

class _CountBadge extends StatelessWidget {
  final int count;
  final Color color;
  const _CountBadge({required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          '$count',
          style: appMonoStyle(
            context,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
