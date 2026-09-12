import 'package:flutter/material.dart';

import 'status_colors.dart';

/// Font family names, bundled locally as app assets (see pubspec.yaml)
/// rather than fetched at runtime — keeps the app fully offline-first,
/// consistent with its cached-data design. Source: IBM's own
/// github.com/IBM/plex repo (OFL-1.1 licensed).
const _sansFamily = 'IBM Plex Sans';
const _monoFamily = 'IBM Plex Mono';

/// Named base palette. Six hexes, deliberately not the Material default
/// teal/green/red — deepened and desaturated slightly so the app reads as
/// an operations tool (Grafana/PagerDuty register) rather than generic
/// consumer SaaS chrome.
class AppPalette {
  static const ink = Color(0xFF0F1417); // dark base
  static const panel = Color(0xFF17232A); // dark elevated surface
  static const mist = Color(0xFFF5F7F7); // light base
  static const panelLight = Color(0xFFFFFFFF); // light elevated surface
  static const signal = Color(0xFF12968C); // brand teal
  static const signalDark = Color(0xFF3FC2B7); // brand teal, on-dark variant
}

class AppTheme {
  AppTheme._();

  static ThemeData light() => _build(Brightness.light);
  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    final colorScheme = isDark
        ? const ColorScheme.dark(
            brightness: Brightness.dark,
            primary: AppPalette.signalDark,
            onPrimary: Color(0xFF00332F),
            secondary: AppPalette.signalDark,
            onSecondary: Color(0xFF00332F),
            surface: AppPalette.panel,
            onSurface: Color(0xFFE7EDEF),
            surfaceContainerHighest: Color(0xFF1D2A31),
            onSurfaceVariant: Color(0xFFA9BABF),
            outline: Color(0xFF2E3D44),
            outlineVariant: Color(0xFF232F35),
            error: Color(0xFFE0574B),
            onError: Color(0xFF3A0805),
          )
        : const ColorScheme.light(
            brightness: Brightness.light,
            primary: AppPalette.signal,
            onPrimary: Colors.white,
            secondary: AppPalette.signal,
            onSecondary: Colors.white,
            surface: AppPalette.panelLight,
            onSurface: Color(0xFF15201F),
            surfaceContainerHighest: Color(0xFFEDF1F1),
            onSurfaceVariant: Color(0xFF4B5A5D),
            outline: Color(0xFFD6DEDE),
            outlineVariant: Color(0xFFE6ECEC),
            error: Color(0xFFC63C31),
            onError: Colors.white,
          );

    final scaffoldBackground = isDark ? AppPalette.ink : AppPalette.mist;

    final baseTextTheme =
        (isDark ? ThemeData.dark().textTheme : ThemeData.light().textTheme)
            .apply(fontFamily: _sansFamily);
    final textTheme = baseTextTheme
        .copyWith(
          headlineSmall: baseTextTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
            letterSpacing: -0.2,
          ),
          titleLarge: baseTextTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          titleMedium: baseTextTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          bodyMedium: baseTextTheme.bodyMedium?.copyWith(height: 1.4),
          labelLarge: baseTextTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        )
        .apply(
          bodyColor: colorScheme.onSurface,
          displayColor: colorScheme.onSurface,
        );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: scaffoldBackground,
      textTheme: textTheme,
      fontFamily: _sansFamily,
      visualDensity: VisualDensity.standard,
      splashFactory: InkSparkle.splashFactory,
      appBarTheme: AppBarTheme(
        backgroundColor: scaffoldBackground,
        foregroundColor: colorScheme.onSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: isDark ? AppPalette.panel : AppPalette.panelLight,
        indicatorColor: colorScheme.primary.withValues(
          alpha: isDark ? 0.24 : 0.14,
        ),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        height: 64,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return textTheme.labelSmall?.copyWith(
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            color: selected
                ? colorScheme.primary
                : colorScheme.onSurfaceVariant,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected
                ? colorScheme.primary
                : colorScheme.onSurfaceVariant,
          );
        }),
      ),
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),
      cardTheme: CardThemeData(
        color: colorScheme.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: colorScheme.outlineVariant),
        ),
        margin: EdgeInsets.zero,
      ),
      listTileTheme: ListTileThemeData(
        iconColor: colorScheme.onSurfaceVariant,
        textColor: colorScheme.onSurface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: colorScheme.surfaceContainerHighest,
        selectedColor: colorScheme.primary.withValues(
          alpha: isDark ? 0.28 : 0.16,
        ),
        labelStyle: textTheme.labelMedium,
        secondaryLabelStyle: textTheme.labelMedium?.copyWith(
          color: colorScheme.primary,
        ),
        side: BorderSide(color: colorScheme.outlineVariant),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          side: WidgetStatePropertyAll(
            BorderSide(color: colorScheme.outlineVariant),
          ),
          textStyle: WidgetStatePropertyAll(textTheme.labelMedium),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.6),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          textStyle: textTheme.labelLarge,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: isDark ? AppPalette.panel : const Color(0xFF15201F),
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: Colors.white),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      extensions: [isDark ? StatusColors.dark : StatusColors.light],
    );
  }
}

/// Numeric readouts (response time, uptime %, day counts, timestamps) use
/// monospace so digits align in a tabular, scannable column — a functional
/// choice for a data-dense list, not decorative labeling.
TextStyle appMonoStyle(
  BuildContext context, {
  double? fontSize,
  FontWeight? fontWeight,
  Color? color,
}) {
  return TextStyle(
    fontFamily: _monoFamily,
    fontSize: fontSize ?? 13,
    fontWeight: fontWeight ?? FontWeight.w500,
    color: color ?? Theme.of(context).colorScheme.onSurface,
  );
}
