import 'package:flutter/material.dart';

/// One orchestrated entrance per list, not a hover effect on every card:
/// each item fades and lifts in on a short stagger keyed to its position,
/// the first time it appears. Delay is capped so a long list doesn't leave
/// the last rows waiting.
class Reveal extends StatefulWidget {
  final Widget child;
  final int index;
  const Reveal({super.key, required this.child, required this.index});

  @override
  State<Reveal> createState() => _RevealState();
}

class _RevealState extends State<Reveal> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    final reduceMotion = WidgetsBinding.instance.platformDispatcher.accessibilityFeatures.disableAnimations;
    if (reduceMotion) {
      _visible = true;
      return;
    }
    final delay = Duration(milliseconds: 24 * widget.index.clamp(0, 10));
    Future.delayed(delay, () {
      if (mounted) setState(() => _visible = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSlide(
      offset: _visible ? Offset.zero : const Offset(0, 0.06),
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      child: AnimatedOpacity(
        opacity: _visible ? 1 : 0,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}
