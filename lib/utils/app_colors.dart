import 'package:flutter/material.dart';

class AppColors {
  final Color background;
  final Color surface;
  final Color surfaceVariant;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color overlay;

  static const Color primary = Color(0xFFE50914);
  static const Color gold = Color(0xFFFFB800);

  const AppColors({
    required this.background,
    required this.surface,
    required this.surfaceVariant,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.overlay,
  });

  static const dark = AppColors(
    background: Color(0xFF0D0D0D),
    surface: Color(0xFF1A1A1A),
    surfaceVariant: Color(0xFF252525),
    textPrimary: Color(0xFFFFFFFF),
    textSecondary: Color(0xFFAAAAAA),
    textMuted: Color(0xFF666666),
    overlay: Color(0x99000000),
  );

  static const light = AppColors(
    background: Color(0xFFF5F5F5),
    surface: Color(0xFFFFFFFF),
    surfaceVariant: Color(0xFFE0E0E0),
    textPrimary: Color(0xFF1A1A1A),
    textSecondary: Color(0xFF616161),
    textMuted: Color(0xFF9E9E9E),
    overlay: Color(0x99000000),
  );
}

extension AppColorsX on BuildContext {
  AppColors get cl =>
      Theme.of(this).brightness == Brightness.dark
          ? AppColors.dark
          : AppColors.light;
}
