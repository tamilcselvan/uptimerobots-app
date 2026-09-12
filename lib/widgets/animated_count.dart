import 'package:flutter/material.dart';

/// Counts up (or down) to [value] whenever it changes, instead of snapping —
/// the one place a number is genuinely the headline (summary stats, badges).
class AnimatedCount extends StatelessWidget {
  final int value;
  final TextStyle? style;
  const AnimatedCount({super.key, required this.value, this.style});

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value.toDouble()),
      duration: reduceMotion ? Duration.zero : const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
      builder: (context, v, _) => Text('${v.round()}', style: style),
    );
  }
}
