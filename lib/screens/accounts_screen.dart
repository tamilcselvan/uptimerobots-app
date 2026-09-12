import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/account.dart';
import '../providers/account_providers.dart';
import '../providers/monitor_providers.dart';
import 'add_account_screen.dart';

class AccountsScreen extends ConsumerWidget {
  const AccountsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountsAsync = ref.watch(accountsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('UptimeRobot Accounts')),
      body: accountsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Failed to load accounts: $err')),
        data: (accounts) {
          if (accounts.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'No accounts yet.\nTap + to connect your first UptimeRobot account.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          return ListView.separated(
            itemCount: accounts.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) => _AccountTile(account: accounts[index]),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const AddAccountScreen()),
        ),
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

    return ListTile(
      title: Text(account.label),
      subtitle: summaryAsync.when(
        loading: () => const Text('Loading monitors...'),
        error: (err, _) => Text('Error: $err', style: const TextStyle(color: Colors.red)),
        data: (summary) => Text(
          '${summary.upMonitors} up · ${summary.downMonitors} down · ${summary.pausedMonitors} paused',
        ),
      ),
      leading: summaryAsync.maybeWhen(
        data: (summary) => CircleAvatar(
          backgroundColor: summary.downMonitors > 0 ? Colors.red : Colors.green,
          child: Text('${summary.downMonitors}',
              style: const TextStyle(color: Colors.white, fontSize: 12)),
        ),
        orElse: () => const CircleAvatar(child: Icon(Icons.dns)),
      ),
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline),
        onPressed: () => _confirmRemove(context, ref),
      ),
    );
  }

  Future<void> _confirmRemove(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove account?'),
        content: Text('This removes "${account.label}" from this app only. '
            'Nothing changes on UptimeRobot itself.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Remove')),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(monitorRepositoryProvider).removeAccountData(account.id);
      await ref.read(accountsProvider.notifier).removeAccount(account.id);
    }
  }
}
