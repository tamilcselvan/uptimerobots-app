import 'package:flutter/material.dart';

import '../models/monitor.dart';
import 'status_colors.dart';

/// Single source of truth for how a [MonitorStatus] reads on screen: color
/// (from the theme, so light/dark stay in sync), label, and icon. Status is
/// never color-only — every place this is used pairs the color with the
/// label or icon so the state reads correctly for colorblind users too.
class StatusStyle {
  final Color color;
  final String label;
  final IconData icon;
  const StatusStyle({
    required this.color,
    required this.label,
    required this.icon,
  });

  static StatusStyle of(BuildContext context, MonitorStatus status) {
    final colors =
        Theme.of(context).extension<StatusColors>() ?? StatusColors.light;
    return switch (status) {
      MonitorStatus.up => StatusStyle(
        color: colors.up,
        label: 'Up',
        icon: Icons.check_circle,
      ),
      MonitorStatus.down => StatusStyle(
        color: colors.down,
        label: 'Down',
        icon: Icons.error,
      ),
      MonitorStatus.seemsDown => StatusStyle(
        color: colors.seemsDown,
        label: 'Seems down',
        icon: Icons.warning_amber,
      ),
      MonitorStatus.paused => StatusStyle(
        color: colors.paused,
        label: 'Paused',
        icon: Icons.pause_circle_outline,
      ),
      MonitorStatus.notCheckedYet => StatusStyle(
        color: colors.notCheckedYet,
        label: 'Not checked yet',
        icon: Icons.schedule,
      ),
    };
  }
}
