import 'package:flutter/material.dart';

import '../database/app_database.dart';
import '../models/account.dart';
import '../models/monitor.dart';
import '../screens/monitor_detail_screen.dart';

class MonitorTile extends StatelessWidget {
  final MonitorRow monitor;
  final Account? account;

  const MonitorTile({super.key, required this.monitor, required this.account});

  Color _statusColor(MonitorStatus status) => switch (status) {
        MonitorStatus.up => Colors.green,
        MonitorStatus.down => Colors.red,
        MonitorStatus.seemsDown => Colors.orange,
        MonitorStatus.paused => Colors.grey,
        MonitorStatus.notCheckedYet => Colors.blueGrey,
      };

  String _statusLabel(MonitorStatus status) => switch (status) {
        MonitorStatus.up => 'Up',
        MonitorStatus.down => 'Down',
        MonitorStatus.seemsDown => 'Seems down',
        MonitorStatus.paused => 'Paused',
        MonitorStatus.notCheckedYet => 'Not checked yet',
      };

  @override
  Widget build(BuildContext context) {
    final status = monitorStatusFromCode(monitor.status);

    return ListTile(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => MonitorDetailScreen(monitor: monitor, account: account),
        ),
      ),
      leading: CircleAvatar(
        backgroundColor: _statusColor(status),
        child: Text(
          monitorTypeLabel(monitor.type)[0],
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
      ),
      title: Row(
        children: [
          if (monitor.muted) ...[
            const Icon(Icons.notifications_off, size: 14, color: Colors.grey),
            const SizedBox(width: 4),
          ],
          Flexible(
            child: Text(monitor.friendlyName, maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
      subtitle: Text(
        '${account?.label ?? 'Unknown account'} · ${monitor.url}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(_statusLabel(status),
              style: TextStyle(color: _statusColor(status), fontWeight: FontWeight.bold)),
          Text('${monitor.allTimeUptimeRatio.toStringAsFixed(2)}% · ${monitor.responseTimeMs}ms',
              style: const TextStyle(fontSize: 11, color: Colors.grey)),
        ],
      ),
    );
  }
}
