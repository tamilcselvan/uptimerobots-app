import 'package:flutter/material.dart';

/// Semantic status colors as a proper [ThemeExtension], so every screen
/// reads status color from `Theme.of(context)` instead of each widget
/// re-declaring its own switch statement (previously duplicated across
/// the tile, detail, and accounts screens).
class StatusColors extends ThemeExtension<StatusColors> {
  final Color up;
  final Color down;
  final Color seemsDown;
  final Color paused;
  final Color notCheckedYet;
  final Color warn;

  const StatusColors({
    required this.up,
    required this.down,
    required this.seemsDown,
    required this.paused,
    required this.notCheckedYet,
    required this.warn,
  });

  static const light = StatusColors(
    up: Color(0xFF1E8A57),
    down: Color(0xFFC63C31),
    seemsDown: Color(0xFFB9791E),
    paused: Color(0xFF6B7780),
    notCheckedYet: Color(0xFF5B7A82),
    warn: Color(0xFFB9791E),
  );

  static const dark = StatusColors(
    up: Color(0xFF2FA66B),
    down: Color(0xFFE0574B),
    seemsDown: Color(0xFFDCA53C),
    paused: Color(0xFF7C8990),
    notCheckedYet: Color(0xFF7FA3AC),
    warn: Color(0xFFDCA53C),
  );

  @override
  StatusColors copyWith({
    Color? up,
    Color? down,
    Color? seemsDown,
    Color? paused,
    Color? notCheckedYet,
    Color? warn,
  }) {
    return StatusColors(
      up: up ?? this.up,
      down: down ?? this.down,
      seemsDown: seemsDown ?? this.seemsDown,
      paused: paused ?? this.paused,
      notCheckedYet: notCheckedYet ?? this.notCheckedYet,
      warn: warn ?? this.warn,
    );
  }

  @override
  StatusColors lerp(ThemeExtension<StatusColors>? other, double t) {
    if (other is! StatusColors) return this;
    return StatusColors(
      up: Color.lerp(up, other.up, t)!,
      down: Color.lerp(down, other.down, t)!,
      seemsDown: Color.lerp(seemsDown, other.seemsDown, t)!,
      paused: Color.lerp(paused, other.paused, t)!,
      notCheckedYet: Color.lerp(notCheckedYet, other.notCheckedYet, t)!,
      warn: Color.lerp(warn, other.warn, t)!,
    );
  }
}
