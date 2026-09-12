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
        error: (err, _) => Center(
          child: Text(
            "Couldn't load settings.\n$err",
            textAlign: TextAlign.center,
          ),
        ),
        data: (settings) => ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: [
            const _SectionHeader('Appearance'),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: _ThemeModeTile(settings: settings),
            ),
            const SizedBox(height: 28),
            const _SectionHeader('Sync frequency'),
            const SizedBox(height: 8),
            _SettingsGroup(
              children: [
                _IntervalRow(
                  title: 'While app is open',
                  subtitle: 'How often the dashboard refreshes',
                  value: settings.foregroundInterval,
                  options: const [1, 2, 5, 10, 15, 30],
                  onChanged: (d) async {
                    await ref.read(settingsProvider.notifier).updateSettings((s) => s.copyWith(foregroundInterval: d));
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Foreground interval set to ${d.inMinutes}m')));
                    }
                  },
                ),
                _IntervalRow(
                  title: 'In the background',
                  subtitle: 'Best-effort — the OS decides exact timing',
                  value: settings.backgroundInterval,
                  options: const [15, 30, 60, 120],
                  onChanged: (d) async {
                    await ref.read(settingsProvider.notifier).updateSettings((s) => s.copyWith(backgroundInterval: d));
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Background interval set to ${d.inMinutes}m')));
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 28),
            const _SectionHeader('History'),
            const SizedBox(height: 8),
            _SettingsGroup(
              children: [
                _ActionRow(
                  icon: Icons.delete_sweep_outlined,
                  title: 'Clear history older than 30 days',
                  subtitle: 'Runs automatically after every sync',
                  onTap: () async {
                    await ref
                        .read(monitorRepositoryProvider)
                        .pruneHistoryOlderThan(const Duration(days: 30));
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Old history cleared.')),
                      );
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 28),
            const _SectionHeader('Accounts backup'),
            const SizedBox(height: 8),
            _SettingsGroup(
              children: [
                _ActionRow(
                  icon: Icons.upload_outlined,
                  title: 'Export accounts to clipboard',
                  subtitle: 'Includes raw API keys as plain text',
                  onTap: () => _exportAccounts(context, ref),
                ),
                _ActionRow(
                  icon: Icons.download_outlined,
                  title: 'Import accounts from clipboard',
                  subtitle: 'Paste JSON exported from another device',
                  onTap: () => _importAccounts(context, ref),
                ),
              ],
            ),
            const SizedBox(height: 28),
            _AboutSection(),
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
          "Anything with clipboard access on this device can read it until it's overwritten. "
          'Only paste it somewhere you trust.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Copy'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final accounts = ref.read(accountsProvider).value ?? [];
    final json = jsonEncode(
      accounts.map((a) => {'label': a.label, 'apiKey': a.apiKey}).toList(),
    );
    await Clipboard.setData(ClipboardData(text: json));

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${accounts.length} account(s) copied to clipboard.'),
        ),
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
          const SnackBar(
            content: Text("Clipboard doesn't contain valid exported JSON."),
          ),
        );
      }
      return;
    }
    if (!context.mounted) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Import accounts?'),
        content: Text(
          'Found ${entries.length} entr${entries.length == 1 ? 'y' : 'ies'} on the '
          'clipboard. Each will be validated against UptimeRobot before saving; '
          'accounts already added are skipped.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Import'),
          ),
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
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(parts.join(', '))));

    if (result.failed.isNotEmpty) {
      showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Some accounts failed to import'),
          content: SingleChildScrollView(child: Text(result.failed.join('\n'))),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
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
    return Text(
      title,
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}

/// Groups related settings rows in one flat bordered container instead of
/// scattering hairline dividers down the page.
class _SettingsGroup extends StatelessWidget {
  final List<Widget> children;
  const _SettingsGroup({required this.children});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        // Material(transparency) so nested ListTiles still get their own
        // ink-splash/highlight painting instead of it being swallowed by
        // this DecoratedBox's background.
        child: Material(
          type: MaterialType.transparency,
          child: Column(
            children: [
              for (var i = 0; i < children.length; i++) ...[
                if (i > 0)
                  Divider(height: 1, color: colorScheme.outlineVariant),
                children[i],
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ThemeModeTile extends ConsumerWidget {
  final AppSettings settings;
  const _ThemeModeTile({required this.settings});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SegmentedButton<ThemeMode>(
      segments: const [
        ButtonSegment(
          value: ThemeMode.system,
          label: Text('System'),
          icon: Icon(Icons.brightness_auto),
        ),
        ButtonSegment(
          value: ThemeMode.light,
          label: Text('Light'),
          icon: Icon(Icons.light_mode),
        ),
        ButtonSegment(
          value: ThemeMode.dark,
          label: Text('Dark'),
          icon: Icon(Icons.dark_mode),
        ),
      ],
      selected: {settings.themeMode},
      onSelectionChanged: (selection) => ref
          .read(settingsProvider.notifier)
          .updateSettings((s) => s.copyWith(themeMode: selection.first)),
    );
  }
}

class _IntervalRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final Duration value;
  final List<int> options;
  final ValueChanged<Duration> onChanged;

  const _IntervalRow({
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
      trailing: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: options.contains(value.inMinutes)
              ? value.inMinutes
              : options.first,
          items: options
              .map((m) => DropdownMenuItem(value: m, child: Text('${m}m')))
              .toList(growable: false),
          onChanged: (m) {
            if (m != null) onChanged(Duration(minutes: m));
          },
        ),
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      onTap: onTap,
    );
  }
}

class _AboutSection extends StatelessWidget {
  const _AboutSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader('About'),
        const SizedBox(height: 8),
        _SettingsGroup(
          children: [
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('UptimeRobots'),
              subtitle: const Text('Version 1.0.1 • Multi-account UptimeRobot dashboard'),
              onTap: () => showAboutDialog(
                context: context,
                applicationName: 'UptimeRobots',
                applicationVersion: '1.0.1+2',
                applicationLegalese: 'Aggregates monitors across multiple UptimeRobot accounts.',
              ),
            ),
          ],
        ),
      ],
    );
  }
}
