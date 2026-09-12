import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/account.dart';
import '../models/monitor.dart';
import '../providers/account_providers.dart';
import '../providers/monitor_providers.dart';
import '../theme/app_theme.dart';
import '../theme/status_style.dart';
import '../widgets/accent_panel.dart';
import '../widgets/animated_count.dart';
import '../widgets/reveal.dart';
import 'add_account_screen.dart';

class AccountsScreen extends ConsumerStatefulWidget {
  const AccountsScreen({super.key});

  @override
  ConsumerState<AccountsScreen> createState() => _AccountsScreenState();
}

class _AccountsScreenState extends ConsumerState<AccountsScreen> {
  String _query = '';
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          final filtered = _query.isEmpty
              ? accounts
              : accounts
                  .where((a) =>
                      a.label.toLowerCase().contains(_query) ||
                      a.id.toLowerCase().contains(_query))
                  .toList();
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search accounts…',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    suffixIcon: _query.isEmpty
                        ? null
                        : IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () => setState(() {
                              _query = '';
                              _searchController.clear();
                            }),
                          ),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  onChanged: (v) => setState(() => _query = v.trim().toLowerCase()),
                ),
              ),
              if (filtered.length != accounts.length)
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 6, 12, 0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '${filtered.length} of ${accounts.length}',
                      style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
                    ),
                  ),
                ),
              Expanded(
                child: filtered.isEmpty
                    ? Center(
                        child: Text(
                          'No accounts match "$_query"',
                          style: TextStyle(color: colorScheme.onSurfaceVariant),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Reveal(
                            index: index,
                            child: _AccountTile(
                              key: ValueKey(filtered[index].id),
                              account: filtered[index],
                            ),
                          ),
                        ),
                      ),
              ),
            ],
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
  const _AccountTile({super.key, required this.account});

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
          PopupMenuButton<String>(
            tooltip: 'Account actions',
            icon: Icon(Icons.more_vert, size: 18, color: colorScheme.onSurfaceVariant),
            onSelected: (v) {
              if (v == 'rename') _renameAccount(context, ref);
              if (v == 'remove') _confirmRemove(context, ref);
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'rename', child: Text('Rename')),
              PopupMenuItem(value: 'remove', child: Text('Remove')),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _renameAccount(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController(text: account.label);
    final newLabel = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename account'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Label'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, controller.text.trim()), child: const Text('Save')),
        ],
      ),
    );
    if (newLabel != null && newLabel.isNotEmpty && newLabel != account.label) {
      await ref.read(accountsProvider.notifier).renameAccount(account.id, newLabel);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Account renamed')));
      }
    }
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
        AnimatedCount(
          value: count,
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
