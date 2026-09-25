import 'package:flutter/material.dart';

abstract final class Space {
  static const double xs = 4, sm = 8, md = 16, lg = 24, xl = 32, xxl = 48;
}

abstract final class Layout {
  static const double medium = 760,
      expanded = 1180,
      sidebar = 244,
      details = 360;
  static const double radius = 16;
  static const motion = Duration(milliseconds: 140);
}

abstract final class DoeverTheme {
  static const seed = Color(0xff426b59);
  static ThemeData build(Brightness brightness) {
    final dark = brightness == Brightness.dark;
    final colors = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: brightness,
      surface: dark ? const Color(0xff171c19) : const Color(0xfff8f9f5),
    );
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Lato',
      colorScheme: colors,
      scaffoldBackgroundColor: colors.surface,
      visualDensity: VisualDensity.standard,
      appBarTheme: AppBarTheme(
        backgroundColor: colors.surface,
        surfaceTintColor: Colors.transparent,
      ),
      dividerTheme: DividerThemeData(
        color: colors.outlineVariant.withValues(alpha: 0.5),
        thickness: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.surfaceContainerLow,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Layout.radius),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.all(Space.md),
      ),
      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Layout.radius),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: colors.surfaceContainerLowest,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Layout.radius),
          side: BorderSide(
            color: colors.outlineVariant.withValues(alpha: 0.45),
          ),
        ),
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
      ),
      textTheme: Typography.material2021().black
          .merge(
            TextTheme(
              headlineLarge: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.w600,
                letterSpacing: -1.1,
                color: colors.onSurface,
              ),
              titleLarge: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: colors.onSurface,
              ),
            ),
          )
          .apply(
            fontFamily: 'Lato',
            bodyColor: colors.onSurface,
            displayColor: colors.onSurface,
          ),
    );
  }
}
