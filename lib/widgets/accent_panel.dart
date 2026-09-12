import 'package:flutter/material.dart';

/// Flat panel: hairline border, no shadow, 3px left color bar signaling
/// status/severity. Used in place of the rounded-card-with-soft-shadow
/// pattern so panels read as data (which one needs attention) rather than
/// decoration (every card looks the same regardless of what's inside it).
///
/// Built on [Material] (like [Card]) rather than a plain [DecoratedBox] so
/// an optional [onTap]'s ink ripple paints correctly instead of being
/// hidden underneath the panel's own opaque background. The accent bar
/// morphs color instead of snapping when a monitor's status changes, and
/// a tappable panel eases down slightly under a press.
class AccentPanel extends StatefulWidget {
  final Widget child;
  final Color accentColor;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final String? semanticsLabel;

  const AccentPanel({
    super.key,
    required this.child,
    required this.accentColor,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    this.semanticsLabel,
  });

  @override
  State<AccentPanel> createState() => _AccentPanelState();
}

class _AccentPanelState extends State<AccentPanel> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (widget.onTap == null) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final radius = BorderRadius.circular(10);
    final reduceMotion = MediaQuery.of(context).disableAnimations;

    return Semantics(
      button: widget.onTap != null,
      label: widget.semanticsLabel,
      child: AnimatedScale(
        scale: _pressed ? 0.985 : 1,
        duration: reduceMotion ? Duration.zero : const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: Material(
          color: colorScheme.surface,
          borderRadius: radius,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: widget.onTap,
            onTapDown: (_) => _setPressed(true),
            onTapCancel: () => _setPressed(false),
            onTapUp: (_) => _setPressed(false),
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: radius,
                border: Border.all(color: colorScheme.outlineVariant),
              ),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AnimatedContainer(
                      duration: reduceMotion ? Duration.zero : const Duration(milliseconds: 400),
                      curve: Curves.easeInOut,
                      width: 3,
                      color: widget.accentColor,
                    ),
                    Expanded(
                      child: Padding(padding: widget.padding, child: widget.child),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
