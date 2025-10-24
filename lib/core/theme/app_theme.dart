import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class AppTheme {
  AppTheme._();

  static const Color primaryLight = Color(0xFFF4A6B5);
  static const Color primaryDark = Color(0xFFD97B8F);

  static const Color secondaryLight = Color(0xFFB5E2F4);
  static const Color secondaryDark = Color(0xFF7BB8D9);

  static const Color accentLight = Color(0xFFE8D4F2);
  static const Color accentDark = Color(0xFFC5A8D9);

  static ShadThemeData lightTheme() {
    return ShadThemeData(
      brightness: Brightness.light,
      colorScheme: const ShadSlateColorScheme.light(
        primary: primaryLight,
        secondary: secondaryLight,
        background: Color(0xFFFFFBF7),
        foreground: Color(0xFF2D2D2D),
      ),
      radius: BorderRadius.circular(12),
    );
  }

  static ShadThemeData darkTheme() {
    return ShadThemeData(
      brightness: Brightness.dark,
      colorScheme: const ShadSlateColorScheme.dark(
        primary: primaryDark,
        secondary: secondaryDark,
        background: Color(0xFF1A1A1A),
        foreground: Color(0xFFE8E8E8),
      ),
      radius: BorderRadius.circular(12),
    );
  }

  static ThemeData getMaterialTheme(ShadThemeData shadTheme) {
    return ThemeData(
      fontFamily: shadTheme.textTheme.family,
      colorScheme: ColorScheme(
        brightness: shadTheme.brightness,
        primary: shadTheme.colorScheme.primary,
        onPrimary: shadTheme.colorScheme.primaryForeground,
        secondary: shadTheme.colorScheme.secondary,
        onSecondary: shadTheme.colorScheme.secondaryForeground,
        error: shadTheme.colorScheme.destructive,
        onError: shadTheme.colorScheme.destructiveForeground,
        surface: shadTheme.colorScheme.background,
        onSurface: shadTheme.colorScheme.foreground,
      ),
      scaffoldBackgroundColor: shadTheme.colorScheme.background,
      brightness: shadTheme.brightness,
    );
  }
}
