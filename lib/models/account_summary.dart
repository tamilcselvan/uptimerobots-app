class AccountSummary {
  final int monitorLimit;
  final int monitorInterval;
  final int upMonitors;
  final int downMonitors;
  final int pausedMonitors;

  const AccountSummary({
    required this.monitorLimit,
    required this.monitorInterval,
    required this.upMonitors,
    required this.downMonitors,
    required this.pausedMonitors,
  });

  factory AccountSummary.fromJson(Map<String, dynamic> json) {
    final account = json['account'] as Map<String, dynamic>;
    return AccountSummary(
      monitorLimit: account['monitor_limit'] as int,
      monitorInterval: account['monitor_interval'] as int,
      upMonitors: account['up_monitors'] as int,
      downMonitors: account['down_monitors'] as int,
      pausedMonitors: account['paused_monitors'] as int,
    );
  }
}
