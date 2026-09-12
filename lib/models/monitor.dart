enum MonitorStatus { paused, notCheckedYet, up, seemsDown, down }

MonitorStatus monitorStatusFromCode(int code) => switch (code) {
  0 => MonitorStatus.paused,
  1 => MonitorStatus.notCheckedYet,
  2 => MonitorStatus.up,
  8 => MonitorStatus.seemsDown,
  9 => MonitorStatus.down,
  _ => MonitorStatus.notCheckedYet,
};

/// UptimeRobot monitor type codes: 1 HTTP(s), 2 keyword, 3 ping, 4 port, 5 heartbeat.
String monitorTypeLabel(int code) => switch (code) {
  1 => 'HTTP(s)',
  2 => 'Keyword',
  3 => 'Ping',
  4 => 'Port',
  5 => 'Heartbeat',
  _ => 'Unknown',
};

/// Parsed view of one monitor for a given [accountId], merging the raw
/// UptimeRobot API payload with the local composite id used for caching.
class MonitorApiData {
  final int uptimeRobotMonitorId;
  final String friendlyName;
  final String url;
  final int type;
  final int status;
  final double allTimeUptimeRatio;
  final int responseTimeMs;

  const MonitorApiData({
    required this.uptimeRobotMonitorId,
    required this.friendlyName,
    required this.url,
    required this.type,
    required this.status,
    required this.allTimeUptimeRatio,
    required this.responseTimeMs,
  });

  factory MonitorApiData.fromJson(Map<String, dynamic> json) {
    final responseTimes = json['response_times'] as List<dynamic>? ?? [];
    final latestResponseTime = responseTimes.isNotEmpty
        ? (responseTimes.first as Map<String, dynamic>)['value'] as int? ?? 0
        : 0;

    return MonitorApiData(
      uptimeRobotMonitorId: json['id'] as int,
      friendlyName: json['friendly_name'] as String? ?? 'Unnamed monitor',
      url: json['url'] as String? ?? '',
      type: json['type'] as int? ?? 0,
      status: json['status'] as int? ?? 0,
      allTimeUptimeRatio:
          double.tryParse(json['all_time_uptime_ratio']?.toString() ?? '') ?? 0,
      responseTimeMs: latestResponseTime,
    );
  }
}
