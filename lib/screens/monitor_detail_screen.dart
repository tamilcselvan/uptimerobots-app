import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/app_database.dart';
import '../models/account.dart';
import '../models/monitor.dart';
import '../providers/monitor_providers.dart';

class MonitorDetailScreen extends ConsumerWidget {
  final MonitorRow monitor;
  final Account? account;

  const MonitorDetailScreen({super.key, required this.monitor, this.account});

  Color _statusColor(MonitorStatus status) => switch (status) {
        MonitorStatus.up => Colors.green,
        MonitorStatus.down => Colors.red,
        MonitorStatus.seemsDown => Colors.orange,
        MonitorStatus.paused => Colors.grey,
        MonitorStatus.notCheckedYet => Colors.blueGrey,
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Prefer the live cached row (reflects mute toggles / new sync results
    // while this screen is open); fall back to the snapshot passed in nav.
    final live = ref.watch(allMonitorsProvider).value?.where((m) => m.id == monitor.id);
    final current = (live != null && live.isNotEmpty) ? live.first : monitor;

    final status = monitorStatusFromCode(current.status);
    final historyAsync = ref.watch(monitorHistoryProvider(current.id));
    final notificationsAsync = ref.watch(monitorNotificationsProvider(current.id));

    return Scaffold(
      appBar: AppBar(
        title: Text(current.friendlyName, overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(
            tooltip: current.muted ? 'Unmute notifications' : 'Mute notifications',
            icon: Icon(current.muted ? Icons.notifications_off : Icons.notifications_active),
            onPressed: () => ref
                .read(monitorRepositoryProvider)
                .setMuted(current.id, !current.muted),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _HeaderCard(monitor: current, account: account, status: status, color: _statusColor(status)),
          const SizedBox(height: 24),
          Text('Response time', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          SizedBox(
            height: 200,
            child: historyAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Failed to load history: $err')),
              data: (history) => _ResponseTimeChart(history: history),
            ),
          ),
          const SizedBox(height: 24),
          Text('Status timeline', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          historyAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const SizedBox.shrink(),
            data: (history) => _StatusTimeline(history: history, colorOf: _statusColor),
          ),
          const SizedBox(height: 24),
          Text('Recent alerts', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          notificationsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Text('Failed to load alerts: $err'),
            data: (notifications) => notifications.isEmpty
                ? const Text('No alerts yet.', style: TextStyle(color: Colors.grey))
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

class _HeaderCard extends StatelessWidget {
  final MonitorRow monitor;
  final Account? account;
  final MonitorStatus status;
  final Color color;

  const _HeaderCard({
    required this.monitor,
    required this.account,
    required this.status,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(backgroundColor: color, radius: 6),
                const SizedBox(width: 8),
                Text(status.name, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
                const Spacer(),
                Text(monitorTypeLabel(monitor.type),
                    style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 8),
            Text(monitor.url, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 4),
            Text(account?.label ?? 'Unknown account',
                style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 12)),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _Stat(label: 'Uptime', value: '${monitor.allTimeUptimeRatio.toStringAsFixed(2)}%'),
                _Stat(label: 'Response', value: '${monitor.responseTimeMs} ms'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  const _Stat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}

class _ResponseTimeChart extends StatelessWidget {
  final List<StatusHistoryEntry> history;
  const _ResponseTimeChart({required this.history});

  @override
  Widget build(BuildContext context) {
    final samples = history.where((h) => h.responseTimeMs != null).toList();
    if (samples.isEmpty) {
      return const Center(
        child: Text('Not enough data yet — check back after a few sync cycles.',
            textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
      );
    }

    final spots = [
      for (var i = 0; i < samples.length; i++)
        FlSpot(i.toDouble(), samples[i].responseTimeMs!.toDouble()),
    ];
    final maxY = spots.map((s) => s.y).reduce((a, b) => a > b ? a : b);

    return LineChart(
      LineChartData(
        minY: 0,
        maxY: maxY <= 0 ? 100 : maxY * 1.2,
        gridData: const FlGridData(drawVerticalLine: false),
        titlesData: const FlTitlesData(
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40)),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: Colors.teal,
            barWidth: 2,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(show: true, color: Colors.teal.withValues(alpha: 0.15)),
          ),
        ],
      ),
    );
  }
}

class _StatusTimeline extends StatelessWidget {
  final List<StatusHistoryEntry> history;
  final Color Function(MonitorStatus) colorOf;

  const _StatusTimeline({required this.history, required this.colorOf});

  @override
  Widget build(BuildContext context) {
    if (history.isEmpty) {
      return const Text('No history yet.', style: TextStyle(color: Colors.grey));
    }
    return SizedBox(
      height: 32,
      child: Row(
        children: history
            .map((h) => Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 0.5),
                    color: colorOf(monitorStatusFromCode(h.status)),
                  ),
                ))
            .toList(growable: false),
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
    return ListTile(
      dense: true,
      leading: Icon(
        isRecovery ? Icons.check_circle : Icons.error,
        color: isRecovery ? Colors.green : Colors.red,
      ),
      title: Text(isRecovery ? 'Recovered' : 'Went down'),
      subtitle: Text(entry.sentAt.toLocal().toString()),
    );
  }
}
