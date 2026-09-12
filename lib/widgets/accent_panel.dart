import 'package:flutter/material.dart';

/// Flat panel: hairline border, no shadow, 3px left color bar signaling
/// status/severity. Used in place of the rounded-card-with-soft-shadow
/// pattern so panels read as data (which one needs attention) rather than
/// decoration (every card looks the same regardless of what's inside it).
///
/// Built on [Material] (like [Card]) rather than a plain [DecoratedBox] so
/// an optional [onTap]'s ink ripple paints correctly instead of being
/// hidden underneath the panel's own opaque background.
class AccentPanel extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final radius = BorderRadius.circular(10);

    return Semantics(
      button: onTap != null,
      label: semanticsLabel,
      child: Material(
        color: colorScheme.surface,
        borderRadius: radius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: radius,
              border: Border.all(color: colorScheme.outlineVariant),
            ),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(width: 3, color: accentColor),
                  Expanded(
                    child: Padding(padding: padding, child: child),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
