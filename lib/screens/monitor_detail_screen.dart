import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/app_database.dart';
import '../models/account.dart';
import '../models/monitor.dart';
import '../providers/monitor_providers.dart';
import '../theme/app_theme.dart';
import '../theme/status_style.dart';
import '../widgets/accent_panel.dart';

class MonitorDetailScreen extends ConsumerWidget {
  final MonitorRow monitor;
  final Account? account;

  const MonitorDetailScreen({super.key, required this.monitor, this.account});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Prefer the live cached row (reflects mute toggles / new sync results
    // while this screen is open); fall back to the snapshot passed in nav.
    final live = ref
        .watch(allMonitorsProvider)
        .value
        ?.where((m) => m.id == monitor.id);
    final current = (live != null && live.isNotEmpty) ? live.first : monitor;

    final status = monitorStatusFromCode(current.status);
    final historyAsync = ref.watch(monitorHistoryProvider(current.id));
    final notificationsAsync = ref.watch(
      monitorNotificationsProvider(current.id),
    );
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(current.friendlyName, overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(
            tooltip: current.muted
                ? 'Turn on notifications'
                : 'Turn off notifications',
            icon: Icon(
              current.muted
                  ? Icons.notifications_off
                  : Icons.notifications_active,
            ),
            onPressed: () async {
              await ref.read(monitorRepositoryProvider).setMuted(current.id, !current.muted);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(current.muted ? 'Notifications enabled' : 'Notifications muted')),
                );
              }
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _HeroHeader(monitor: current, account: account, status: status),
          if (current.url.startsWith('https://')) ...[
            const SizedBox(height: 12),
            _SslCard(monitor: current),
          ],
          const SizedBox(height: 28),
          _SectionLabel('Response time'),
          const SizedBox(height: 12),
          SizedBox(
            height: 180,
            child: historyAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(
                child: Text(
                  "Couldn't load history.\n$err",
                  textAlign: TextAlign.center,
                ),
              ),
              data: (history) => _ResponseTimeChart(history: history),
            ),
          ),
          const SizedBox(height: 28),
          _SectionLabel('Status timeline'),
          const SizedBox(height: 12),
          historyAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const SizedBox.shrink(),
            data: (history) => _StatusTimeline(history: history),
          ),
          const SizedBox(height: 28),
          _SectionLabel('Recent alerts'),
          const SizedBox(height: 12),
          notificationsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Text("Couldn't load alerts.\n$err"),
            data: (notifications) => notifications.isEmpty
                ? Text(
                    'No alerts yet — you\'ll see up/down events here.',
                    style: TextStyle(color: colorScheme.onSurfaceVariant),
                  )
                : Column(
                    children: notifications
                        .map((n) => _AlertTile(entry: n))
                        .toList(growable: false),
                  ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text, style: Theme.of(context).textTheme.titleMedium);
  }
}

/// Leads with the two facts that matter most on this screen: current state
/// and the uptime number. Everything else (url, type, account) is
/// supporting context underneath.
class _HeroHeader extends StatelessWidget {
  final MonitorRow monitor;
  final Account? account;
  final MonitorStatus status;

  const _HeroHeader({
    required this.monitor,
    required this.account,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final style = StatusStyle.of(context, status);
    final colorScheme = Theme.of(context).colorScheme;

    return AccentPanel(
      accentColor: style.color,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(style.icon, color: style.color, size: 22),
                    const SizedBox(width: 8),
                    Text(
                      style.label,
                      style: Theme.of(
                        context,
                      ).textTheme.titleLarge?.copyWith(color: style.color),
                    ),
                  ],
                ),
              ),
              Text(
                '${monitor.allTimeUptimeRatio.toStringAsFixed(2)}%',
                style: appMonoStyle(
                  context,
                  fontSize: 32,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              'uptime',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const Divider(height: 24),
          Text(
            monitor.url,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _MetaTag(
                icon: Icons.dns_outlined,
                label: monitorTypeLabel(monitor.type),
              ),
              _MetaTag(
                icon: Icons.speed,
                label: monitor.responseTimeMs == 0 ? '—' : '${monitor.responseTimeMs} ms',
              ),
              _MetaTag(
                icon: Icons.folder_outlined,
                label: account?.label ?? 'Unknown account',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetaTag extends StatelessWidget {
  final IconData icon;
  final String label;
  const _MetaTag({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: colorScheme.onSurfaceVariant),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _SslCard extends StatelessWidget {
  final MonitorRow monitor;
  const _SslCard({required this.monitor});

  @override
  Widget build(BuildContext context) {
    final error = monitor.sslCheckError;
    final expiry = monitor.sslExpiryDate;
    final checkedAt = monitor.sslLastCheckedAt;
    final colorScheme = Theme.of(context).colorScheme;

    late final Color accentColor;
    late final IconData icon;
    late final String title;
    String? subtitle;

    if (error != null) {
      accentColor = StatusStyle.of(context, MonitorStatus.seemsDown).color;
      icon = Icons.warning_amber;
      title = "SSL check failed";
      subtitle = error;
    } else if (expiry == null) {
      accentColor = colorScheme.onSurfaceVariant;
      icon = Icons.lock_clock;
      title = 'SSL certificate not checked yet';
    } else {
      final daysRemaining = expiry.difference(DateTime.now()).inDays;
      accentColor = daysRemaining <= 7
          ? StatusStyle.of(context, MonitorStatus.down).color
          : daysRemaining <= 30
          ? StatusStyle.of(context, MonitorStatus.seemsDown).color
          : StatusStyle.of(context, MonitorStatus.up).color;
      icon = Icons.lock;
      title = daysRemaining <= 0
          ? 'SSL certificate expired'
          : 'SSL certificate expires in $daysRemaining day${daysRemaining == 1 ? '' : 's'}';
      subtitle = 'Valid until ${expiry.toLocal().toString().split(' ').first}';
    }

    return AccentPanel(
      accentColor: accentColor,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: accentColor, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: accentColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          if (checkedAt != null) ...[
            const SizedBox(height: 6),
            Text(
              'Last checked ${checkedAt.toLocal().toString().split('.').first}',
              style: TextStyle(
                fontSize: 11,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ResponseTimeChart extends StatelessWidget {
  final List<StatusHistoryEntry> history;
  const _ResponseTimeChart({required this.history});

  @override
  Widget build(BuildContext context) {
    final samples = history.where((h) => h.responseTimeMs != null).toList();
    final colorScheme = Theme.of(context).colorScheme;
    if (samples.isEmpty) {
      return Center(
        child: Text(
          'Not enough data yet — check back after a few sync cycles.',
          textAlign: TextAlign.center,
          style: TextStyle(color: colorScheme.onSurfaceVariant),
        ),
      );
    }

    final spots = [
      for (var i = 0; i < samples.length; i++)
        FlSpot(i.toDouble(), samples[i].responseTimeMs!.toDouble()),
    ];
    final maxY = spots.map((s) => s.y).reduce((a, b) => a > b ? a : b);
    final primary = Theme.of(context).colorScheme.primary;

    return LineChart(
      LineChartData(
        minY: 0,
        maxY: maxY <= 0 ? 100 : maxY * 1.2,
        gridData: FlGridData(
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) =>
              FlLine(color: colorScheme.outlineVariant, strokeWidth: 1),
        ),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (touched) => touched.map((s) {
              final idx = s.spotIndex;
              final h = samples[idx];
              final dt = h.recordedAt.toLocal().toString().split(' ').first;
              return LineTooltipItem(
                '${h.responseTimeMs} ms\n$dt',
                TextStyle(color: colorScheme.onSurface),
              );
            }).toList(),
          ),
        ),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 22,
              interval: (samples.length / 4).ceilToDouble().clamp(1, 50).toDouble(),
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx < 0 || idx >= samples.length) return const SizedBox.shrink();
                if (idx % ((samples.length / 3).ceil()) != 0) return const SizedBox.shrink();
                final d = samples[idx].recordedAt.toLocal();
                return Text(
                  '${d.month}/${d.day}',
                  style: appMonoStyle(context, fontSize: 9, color: colorScheme.onSurfaceVariant),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) => Text(
                value.toInt().toString(),
                style: appMonoStyle(
                  context,
                  fontSize: 10,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: primary,
            barWidth: 2,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: primary.withValues(alpha: 0.12),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusTimeline extends StatelessWidget {
  final List<StatusHistoryEntry> history;
  const _StatusTimeline({required this.history});

  @override
  Widget build(BuildContext context) {
    if (history.isEmpty) {
      return Text(
        'No history yet.',
        style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: SizedBox(
        height: 28,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: history
                .map(
                  (h) => Tooltip(
                    message:
                        '${monitorStatusFromCode(h.status).name} • ${h.recordedAt.toLocal().toString().split('.').first} • ${h.responseTimeMs == null ? '—' : '${h.responseTimeMs} ms'}',
                    child: Container(
                      width: 6,
                      height: 28,
                      margin: const EdgeInsets.symmetric(horizontal: 0.5),
                      color: StatusStyle.of(
                        context,
                        monitorStatusFromCode(h.status),
                      ).color,
                    ),
                  ),
                )
                .toList(growable: false),
          ),
        ),
      ),
    );
  }
}

class _AlertTile extends StatelessWidget {
  final NotificationLogEntry entry;
  const _AlertTile({required this.entry});

  @override
  Widget build(BuildContext context) {
    final isRecovery = entry.event == 'down_to_up';
    final color = StatusStyle.of(
      context,
      isRecovery ? MonitorStatus.up : MonitorStatus.down,
    ).color;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(
            isRecovery ? Icons.check_circle : Icons.error,
            color: color,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isRecovery ? 'Recovered' : 'Went down',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  entry.sentAt.toLocal().toString().split('.').first,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
