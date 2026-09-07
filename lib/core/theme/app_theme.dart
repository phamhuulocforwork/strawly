import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../../presentation/theme/bento_tokens.dart';

class AppTheme {
  AppTheme._();

  static TextTheme _textTheme(Brightness brightness) {
    final base = GoogleFonts.interTextTheme(
      brightness == Brightness.dark
          ? ThemeData.dark().textTheme
          : ThemeData.light().textTheme,
    );
    return base.copyWith(
      displayLarge: base.displayLarge?.copyWith(
        fontSize: BentoTokens.font32,
        fontWeight: FontWeight.w700,
        color: brightness == Brightness.dark
            ? BentoTokens.textDark
            : BentoTokens.text,
      ),
      headlineSmall: base.headlineSmall?.copyWith(
        fontSize: BentoTokens.font24,
        fontWeight: FontWeight.w700,
      ),
      titleLarge: base.titleLarge?.copyWith(
        fontSize: BentoTokens.font20,
        fontWeight: FontWeight.w600,
      ),
      titleMedium: base.titleMedium?.copyWith(
        fontSize: BentoTokens.font16,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: base.bodyLarge?.copyWith(fontSize: BentoTokens.font16),
      bodyMedium: base.bodyMedium?.copyWith(fontSize: BentoTokens.font14),
      bodySmall: base.bodySmall?.copyWith(fontSize: BentoTokens.font12),
      labelSmall: GoogleFonts.jetBrainsMono(
        fontSize: BentoTokens.font12,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  static ShadThemeData lightTheme() {
    return ShadThemeData(
      brightness: Brightness.light,
      colorScheme: const ShadSlateColorScheme.light(
        primary: BentoTokens.primary,
        secondary: BentoTokens.secondary,
        background: BentoTokens.surface,
        foreground: BentoTokens.text,
        destructive: BentoTokens.danger,
      ),
      radius: BentoTokens.tileRadius,
      textTheme: ShadTextTheme(family: GoogleFonts.inter().fontFamily!),
      primaryButtonTheme: const ShadButtonTheme(
        backgroundColor: BentoTokens.primaryButton,
        hoverBackgroundColor: BentoTokens.primaryButtonHover,
        foregroundColor: Colors.white,
      ),
    );
  }

  static ShadThemeData darkTheme() {
    return ShadThemeData(
      brightness: Brightness.dark,
      colorScheme: const ShadSlateColorScheme.dark(
        primary: BentoTokens.primaryDark,
        secondary: BentoTokens.secondaryDark,
        background: BentoTokens.surfaceDark,
        foreground: BentoTokens.textDark,
        destructive: BentoTokens.danger,
      ),
      radius: BentoTokens.tileRadius,
      textTheme: ShadTextTheme(family: GoogleFonts.inter().fontFamily!),
      primaryButtonTheme: const ShadButtonTheme(
        backgroundColor: BentoTokens.primaryButton,
        hoverBackgroundColor: BentoTokens.primaryButtonHover,
        foregroundColor: Colors.white,
      ),
    );
  }

  static ThemeData getMaterialTheme(ShadThemeData shadTheme) {
    final brightness = shadTheme.brightness;
    return ThemeData(
      fontFamily: GoogleFonts.inter().fontFamily,
      textTheme: _textTheme(brightness),
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: shadTheme.colorScheme.primary,
        onPrimary: BentoTokens.text,
        secondary: shadTheme.colorScheme.secondary,
        onSecondary: BentoTokens.text,
        error: shadTheme.colorScheme.destructive,
        onError: Colors.white,
        surface: shadTheme.colorScheme.background,
        onSurface: shadTheme.colorScheme.foreground,
      ),
      scaffoldBackgroundColor: shadTheme.colorScheme.background,
      brightness: brightness,
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: brightness == Brightness.dark
            ? BentoTokens.surfaceElevatedDark
            : Colors.white,
        indicatorColor: BentoTokens.primary.withValues(alpha: 0.35),
        labelTextStyle: WidgetStatePropertyAll(
          GoogleFonts.inter(fontSize: BentoTokens.font12),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: BentoTokens.primaryButton,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
    );
  }
}
