import 'package:flutter/material.dart';

abstract final class AppTheme {
  static ThemeData light() {
    const seed = Color(0xFF2F80ED);
    final colorScheme = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: Brightness.light,
    ).copyWith(
      primary: const Color(0xFF2F80ED),
      secondary: const Color(0xFF73AFFF),
      onPrimary: Colors.white,
      surface: Colors.white,
      onSurface: const Color(0xFF17324D),
      surfaceContainerLowest: const Color(0xFFFFFFFF),
      surfaceContainerLow: const Color(0xFFF6F9FD),
      surfaceContainer: const Color(0xFFF1F6FC),
      surfaceContainerHigh: const Color(0xFFE9F0F9),
      primaryContainer: const Color(0xFFEAF2FF),
      secondaryContainer: const Color(0xFFF3F7FD),
      outlineVariant: const Color(0xFFD7E2F0),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: const Color(0xFFF8FAFD),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF17324D),
        centerTitle: false,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        clipBehavior: Clip.antiAlias,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
          side: BorderSide(color: colorScheme.outlineVariant),
        ),
        margin: EdgeInsets.zero,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFF2F80ED),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFF2F80ED), width: 1.6),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF17324D),
        contentTextStyle: const TextStyle(color: Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant,
      ),
      textTheme: const TextTheme(
        headlineSmall: TextStyle(color: Color(0xFF17324D)),
        titleLarge: TextStyle(color: Color(0xFF17324D)),
        titleMedium: TextStyle(color: Color(0xFF17324D)),
        bodyLarge: TextStyle(color: Color(0xFF4D647D)),
        bodyMedium: TextStyle(color: Color(0xFF62788F)),
        labelLarge: TextStyle(color: Color(0xFF3E566E)),
      ),
    );
  }
}
