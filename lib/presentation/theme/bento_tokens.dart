import 'package:flutter/material.dart';

/// Design tokens: original Strawly palette + bento spacing/typography.
class BentoTokens {
  BentoTokens._();

  // Light palette (original Strawly)
  static const Color primary = Color(0xFFF4A6B5);
  static const Color primaryButton = Color(0xFFC44B6A);
  static const Color primaryButtonHover = Color(0xFFB03E5C);
  static const Color secondary = Color(0xFFB5E2F4);
  static const Color accent = Color(0xFFE8D4F2);
  static const Color success = Color(0xFF16A34A);
  static const Color warning = Color(0xFFD97706);
  static const Color predicted = Color(0xFFF3C98A);
  static const Color danger = Color(0xFFFF5A5A);
  static const Color surface = Color(0xFFFFFBF7);
  static const Color text = Color(0xFF2D2D2D);

  // Dark palette (original Strawly)
  static const Color primaryDark = Color(0xFFD97B8F);
  static const Color secondaryDark = Color(0xFF7BB8D9);
  static const Color accentDark = Color(0xFFC5A8D9);
  static const Color surfaceDark = Color(0xFF1A1A1A);
  static const Color textDark = Color(0xFFE8E8E8);
  static const Color surfaceElevatedDark = Color(0xFF242424);

  // Spacing scale: 4/8/12/16/24/32
  static const double space4 = 4;
  static const double space8 = 8;
  static const double space12 = 12;
  static const double space16 = 16;
  static const double space24 = 24;
  static const double space32 = 32;
  static const double space96 = 96;

  // Radius
  static const double radiusSm = 8;
  static const double radiusMd = 16;

  static const double gridGap = 12;
  static const double tilePadding = 16;

  // Typography scale: 12/14/16/20/24/32
  static const double font12 = 12;
  static const double font14 = 14;
  static const double font16 = 16;
  static const double font20 = 20;
  static const double font24 = 24;
  static const double font32 = 32;

  static BorderRadius get tileRadius => BorderRadius.circular(radiusMd);

  static Color tileBackground(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? surfaceElevatedDark : Colors.white;
  }

  static Color tileBorder(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark
        ? primaryDark.withValues(alpha: 0.25)
        : primary.withValues(alpha: 0.45);
  }

  static Color onSurfaceText(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? textDark : text;
  }

  static Color mutedText(BuildContext context) {
    return onSurfaceText(context).withValues(alpha: 0.65);
  }

  // Stat screen accent colors (theme-aware)
  static Color statCycleBackground(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark
        ? primaryDark.withValues(alpha: 0.22)
        : const Color(0xFFF5DAE3);
  }

  static Color statCycleForeground(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? primaryDark : const Color(0xFF72243E);
  }

  static Color statBlue(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFF6CB4FF) : const Color(0xFF378ADD);
  }

  static Color statPurple(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFFA49DFF) : const Color(0xFF7F77DD);
  }

  static Color statAmber(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFFE5B84A) : const Color(0xFFBA7517);
  }

  static Color statSuccessForeground(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFF86EFAC) : const Color(0xFF3B6D11);
  }
}
