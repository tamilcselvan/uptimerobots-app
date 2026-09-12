import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/account_providers.dart';
import '../providers/monitor_providers.dart';
import '../providers/settings_providers.dart';
import '../services/settings_repository.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: settingsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Failed to load settings: $err')),
        data: (settings) => ListView(
          children: [
            const _SectionHeader('Appearance'),
            _ThemeModeTile(settings: settings),
            const Divider(height: 32),
            const _SectionHeader('Sync frequency'),
            _IntervalTile(
              title: 'While app is open',
              subtitle: 'How often the dashboard refreshes in the foreground',
              value: settings.foregroundInterval,
              options: const [1, 2, 5, 10, 15, 30],
              onChanged: (d) => ref
                  .read(settingsProvider.notifier)
                  .updateSettings((s) => s.copyWith(foregroundInterval: d)),
            ),
            _IntervalTile(
              title: 'In the background',
              subtitle: 'Best-effort — the OS decides the exact timing (Android min. 15 min)',
              value: settings.backgroundInterval,
              options: const [15, 30, 60, 120],
              onChanged: (d) => ref
                  .read(settingsProvider.notifier)
                  .updateSettings((s) => s.copyWith(backgroundInterval: d)),
            ),
            const Divider(height: 32),
            const _SectionHeader('History'),
            ListTile(
              title: const Text('Clear history older than 30 days now'),
              subtitle: const Text('Runs automatically after every sync; use this to run it early'),
              trailing: const Icon(Icons.delete_sweep_outlined),
              onTap: () async {
                await ref
                    .read(monitorRepositoryProvider)
                    .pruneHistoryOlderThan(const Duration(days: 30));
                if (context.mounted) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(const SnackBar(content: Text('Old history cleared.')));
                }
              },
            ),
            const Divider(height: 32),
            const _SectionHeader('Accounts backup'),
            ListTile(
              title: const Text('Export accounts to clipboard'),
              subtitle: const Text('Includes raw API keys in plain text — handle the copied data carefully'),
              trailing: const Icon(Icons.upload_outlined),
              onTap: () => _exportAccounts(context, ref),
            ),
            ListTile(
              title: const Text('Import accounts from clipboard'),
              subtitle: const Text('Paste JSON exported from this or another device'),
              trailing: const Icon(Icons.download_outlined),
              onTap: () => _importAccounts(context, ref),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _exportAccounts(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export accounts?'),
        content: const Text(
          'This copies every account label and API key to the clipboard as plain-text JSON. '
          'Anything with clipboard access on this device can read it until it\'s overwritten. '
          'Only paste it somewhere you trust.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Copy')),
        ],
      ),
    );
    if (confirmed != true) return;

    final accounts = ref.read(accountsProvider).value ?? [];
    final json = jsonEncode(accounts.map((a) => {'label': a.label, 'apiKey': a.apiKey}).toList());
    await Clipboard.setData(ClipboardData(text: json));

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${accounts.length} account(s) copied to clipboard.')),
      );
    }
  }

  Future<void> _importAccounts(BuildContext context, WidgetRef ref) async {
    final clipboard = await Clipboard.getData(Clipboard.kTextPlain);
    final text = clipboard?.text ?? '';

    List<dynamic> entries;
    try {
      entries = jsonDecode(text) as List<dynamic>;
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Clipboard doesn\'t contain valid exported JSON.')),
        );
      }
      return;
    }
    if (!context.mounted) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Import accounts?'),
        content: Text('Found ${entries.length} entr${entries.length == 1 ? 'y' : 'ies'} on the '
            'clipboard. Each will be validated against UptimeRobot before saving; '
            'accounts already added are skipped.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Import')),
        ],
      ),
    );
    if (confirmed != true) return;

    final result = await ref
        .read(accountsProvider.notifier)
        .importAccounts(entries.cast<Map<String, dynamic>>());

    if (!context.mounted) return;
    final parts = <String>[
      '${result.added} added',
      if (result.duplicates > 0) '${result.duplicates} already existed',
      if (result.failed.isNotEmpty) '${result.failed.length} failed',
    ];
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(parts.join(', '))));

    if (result.failed.isNotEmpty) {
      showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Some accounts failed to import'),
          content: SingleChildScrollView(child: Text(result.failed.join('\n'))),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
          ],
        ),
      );
    }
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.teal),
      ),
    );
  }
}

class _ThemeModeTile extends ConsumerWidget {
  final AppSettings settings;
  const _ThemeModeTile({required this.settings});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SegmentedButton<ThemeMode>(
        segments: const [
          ButtonSegment(value: ThemeMode.system, label: Text('System'), icon: Icon(Icons.brightness_auto)),
          ButtonSegment(value: ThemeMode.light, label: Text('Light'), icon: Icon(Icons.light_mode)),
          ButtonSegment(value: ThemeMode.dark, label: Text('Dark'), icon: Icon(Icons.dark_mode)),
        ],
        selected: {settings.themeMode},
        onSelectionChanged: (selection) => ref
            .read(settingsProvider.notifier)
            .updateSettings((s) => s.copyWith(themeMode: selection.first)),
      ),
    );
  }
}

class _IntervalTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final Duration value;
  final List<int> options;
  final ValueChanged<Duration> onChanged;

  const _IntervalTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: DropdownButton<int>(
        value: options.contains(value.inMinutes) ? value.inMinutes : options.first,
        items: options
            .map((m) => DropdownMenuItem(value: m, child: Text('${m}m')))
            .toList(growable: false),
        onChanged: (m) {
          if (m != null) onChanged(Duration(minutes: m));
        },
      ),
    );
  }
}
