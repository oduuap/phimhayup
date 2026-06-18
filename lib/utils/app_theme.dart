import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTheme {
  static const Color primary = Color(0xFFE50914);
  static const Color background = Color(0xFF0D0D0D);
  static const Color surface = Color(0xFF1A1A1A);
  static const Color surfaceVariant = Color(0xFF252525);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFAAAAAA);
  static const Color textMuted = Color(0xFF666666);
  static const Color gold = Color(0xFFFFB800);
  static const Color overlay = Color(0x99000000);

  static const Color _lightBackground = Color(0xFFF5F5F5);
  static const Color _lightSurface = Color(0xFFFFFFFF);
  static const Color _lightSurfaceVariant = Color(0xFFE0E0E0);
  static const Color _lightTextPrimary = Color(0xFF1A1A1A);
  static const Color _lightTextSecondary = Color(0xFF616161);
  static const Color _lightTextMuted = Color(0xFF9E9E9E);

  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        surface: surface,
        onSurface: textPrimary,
      ),
      scaffoldBackgroundColor: background,
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(color: textPrimary),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
            color: textPrimary, fontSize: 28, fontWeight: FontWeight.bold),
        headlineMedium: TextStyle(
            color: textPrimary, fontSize: 22, fontWeight: FontWeight.bold),
        titleLarge: TextStyle(
            color: textPrimary, fontSize: 18, fontWeight: FontWeight.w600),
        titleMedium: TextStyle(
            color: textPrimary, fontSize: 16, fontWeight: FontWeight.w500),
        bodyLarge: TextStyle(color: textSecondary, fontSize: 15, height: 1.5),
        bodyMedium: TextStyle(color: textSecondary, fontSize: 13),
        labelSmall: TextStyle(color: textMuted, fontSize: 11),
      ),
      cardTheme: const CardThemeData(
        color: surface,
        elevation: 0,
        margin: EdgeInsets.zero,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: primary,
        unselectedItemColor: textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        hintStyle: const TextStyle(color: textMuted),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: primary,
        surface: _lightSurface,
        onSurface: _lightTextPrimary,
      ),
      scaffoldBackgroundColor: _lightBackground,
      appBarTheme: const AppBarTheme(
        backgroundColor: _lightBackground,
        elevation: 0,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
        titleTextStyle: TextStyle(
          color: _lightTextPrimary,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(color: _lightTextPrimary),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
            color: _lightTextPrimary, fontSize: 28, fontWeight: FontWeight.bold),
        headlineMedium: TextStyle(
            color: _lightTextPrimary, fontSize: 22, fontWeight: FontWeight.bold),
        titleLarge: TextStyle(
            color: _lightTextPrimary, fontSize: 18, fontWeight: FontWeight.w600),
        titleMedium: TextStyle(
            color: _lightTextPrimary, fontSize: 16, fontWeight: FontWeight.w500),
        bodyLarge: TextStyle(
            color: _lightTextSecondary, fontSize: 15, height: 1.5),
        bodyMedium: TextStyle(color: _lightTextSecondary, fontSize: 13),
        labelSmall: TextStyle(color: _lightTextMuted, fontSize: 11),
      ),
      cardTheme: const CardThemeData(
        color: _lightSurface,
        elevation: 0,
        margin: EdgeInsets.zero,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: _lightSurface,
        selectedItemColor: primary,
        unselectedItemColor: _lightTextMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _lightSurfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        hintStyle: const TextStyle(color: _lightTextMuted),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}
