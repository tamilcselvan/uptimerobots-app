import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/app_database.dart';
import '../models/account.dart';
import '../models/monitor.dart';
import '../providers/monitor_providers.dart';
import '../screens/monitor_detail_screen.dart';
import '../theme/app_theme.dart';
import '../theme/status_style.dart';
import 'accent_panel.dart';

class MonitorTile extends ConsumerWidget {
  final MonitorRow monitor;
  final Account? account;

  const MonitorTile({super.key, required this.monitor, required this.account});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final style = StatusStyle.of(
      context,
      monitorStatusFromCode(monitor.status),
    );
    final colorScheme = Theme.of(context).colorScheme;

    return AccentPanel(
      accentColor: style.color,
      semanticsLabel: '${monitor.friendlyName}, ${style.label}',
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) =>
              MonitorDetailScreen(monitor: monitor, account: account),
        ),
      ),
      child: Row(
        children: [
          Semantics(
            label: '${style.label} status',
            child: Icon(style.icon, color: style.color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        monitor.friendlyName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (monitor.muted) ...[
                      const SizedBox(width: 6),
                      Icon(
                        Icons.notifications_off,
                        size: 14,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  monitor.url,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${monitor.allTimeUptimeRatio.toStringAsFixed(2)}%',
                style: appMonoStyle(context, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 2),
              Text(
                monitor.responseTimeMs == 0 ? '—' : '${monitor.responseTimeMs} ms',
                style: appMonoStyle(
                  context,
                  fontSize: 11,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 4),
              Tooltip(
                message: account?.label ?? 'Unknown',
                child: _AccountTag(label: account?.label ?? 'Unknown'),
              ),
            ],
          ),
          PopupMenuButton<String>(
            tooltip: 'More actions',
            icon: Icon(Icons.more_vert, size: 18, color: colorScheme.onSurfaceVariant),
            onSelected: (v) async {
              switch (v) {
                case 'copy':
                  await Clipboard.setData(ClipboardData(text: monitor.url));
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('URL copied')),
                    );
                  }
                  break;
                case 'mute':
                  await ref.read(monitorRepositoryProvider).setMuted(monitor.id, !monitor.muted);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(monitor.muted ? 'Notifications enabled' : 'Notifications muted')),
                    );
                  }
                  break;
                case 'open':
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'copy', child: Text('Copy URL')),
              PopupMenuItem(value: 'mute', child: Text(monitor.muted ? 'Enable notifications' : 'Mute notifications')),
            ],
          ),
        ],
      ),
    );
  }
}

/// Small identifying tag — genuinely useful here since the whole app's
/// point is aggregating monitors across accounts, not decoration.
class _AccountTag extends StatelessWidget {
  final String label;
  const _AccountTag({required this.label});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(6),
      ),
      constraints: const BoxConstraints(maxWidth: 120),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(
          context,
        ).textTheme.labelSmall?.copyWith(color: colorScheme.onSurfaceVariant),
      ),
    );
  }
}
