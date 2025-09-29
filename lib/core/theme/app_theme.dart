import 'package:flutter/material.dart';

class AppTheme {
  static const Color defaultSeed = Color(0xFF5B3B8C);

  static ThemeData light({Color? seed}) => _baseTheme(
        brightness: Brightness.light,
        seedColor: seed ?? defaultSeed,
      );

  static ThemeData dark({Color? seed}) => _baseTheme(
        brightness: Brightness.dark,
        seedColor: seed ?? defaultSeed,
      );

  static ThemeData _baseTheme({
    required Brightness brightness,
    required Color seedColor,
  }) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: brightness,
    );

    final typography =
        Typography.material2021(platform: TargetPlatform.android);
    final textTheme = (brightness == Brightness.dark
            ? typography.white
            : typography.black)
        .apply(fontFamily: 'Roboto');

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      textTheme: textTheme,
      typography: typography,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        centerTitle: false,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 6,
        shape: const CircleBorder(),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        indicatorColor: colorScheme.primaryContainer,
        labelTextStyle: WidgetStateProperty.all(
          const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }
}
