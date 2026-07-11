import 'package:flutter/material.dart';

/// Palette pulled directly from the VALIDIKA web client (Button.tsx,
/// HomePage.tsx, styles/index.css) so the mobile app reads as the same
/// product: deep navy headings, institutional blue accents, near-black
/// pill CTAs, soft light-blue surfaces.
class AppColors {
  const AppColors._();

  static const Color lightHeading = Color(0xFF061A33);
  static const Color lightAccent = Color(0xFF0B3D73);
  static const Color lightAccentSoft = Color(0xFF2F80D1);
  static const Color lightCta = Color(0xFF1D1D1F);
  static const Color lightBackground = Color(0xFFF3F7FB);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightText = Color(0xFF1D1D1F);
  static const Color lightTextSecondary = Color(0xFF3A3A3C);
  static const Color lightTextTertiary = Color(0xFF6E6E73);
  static const Color lightBorder = Color(0x14000000);
  static const Color lightSuccess = Color(0xFF1A7F37);
  static const Color lightWarning = Color(0xFFB35900);
  static const Color lightDanger = Color(0xFFC81E1E);

  static const Color darkHeading = Color(0xFFF5F5F7);
  static const Color darkAccent = Color(0xFF78B7F0);
  static const Color darkAccentSoft = Color(0xFF64D2FF);
  static const Color darkCta = Color(0xFFFFFFFF);
  static const Color darkBackground = Color(0xFF0B0E14);
  static const Color darkSurface = Color(0xFF161B24);
  static const Color darkText = Color(0xFFF5F5F7);
  static const Color darkTextSecondary = Color(0xFFB0B0B5);
  static const Color darkTextTertiary = Color(0xFF86868B);
  static const Color darkBorder = Color(0x1FFFFFFF);
  static const Color darkSuccess = Color(0xFF30A46C);
  static const Color darkWarning = Color(0xFFF5A623);
  static const Color darkDanger = Color(0xFFFF6B6B);
}

/// Semantic colors for pharmacist license status badges, resolved against
/// the current theme brightness.
class LicenseStatusColors {
  const LicenseStatusColors._();

  static Color forStatus(BuildContext context, String status) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return switch (status) {
      'active' => isDark ? AppColors.darkSuccess : AppColors.lightSuccess,
      'expired' => isDark ? AppColors.darkWarning : AppColors.lightWarning,
      'suspended' => isDark ? AppColors.darkWarning : AppColors.lightWarning,
      'revoked' => isDark ? AppColors.darkDanger : AppColors.lightDanger,
      _ => isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
    };
  }
}

class AppTheme {
  const AppTheme._();

  static ThemeData light() => _build(
    brightness: Brightness.light,
    heading: AppColors.lightHeading,
    accent: AppColors.lightAccent,
    cta: AppColors.lightCta,
    background: AppColors.lightBackground,
    surface: AppColors.lightSurface,
    text: AppColors.lightText,
    textSecondary: AppColors.lightTextSecondary,
    border: AppColors.lightBorder,
    danger: AppColors.lightDanger,
  );

  static ThemeData dark() => _build(
    brightness: Brightness.dark,
    heading: AppColors.darkHeading,
    accent: AppColors.darkAccent,
    cta: AppColors.darkCta,
    background: AppColors.darkBackground,
    surface: AppColors.darkSurface,
    text: AppColors.darkText,
    textSecondary: AppColors.darkTextSecondary,
    border: AppColors.darkBorder,
    danger: AppColors.darkDanger,
  );

  static ThemeData _build({
    required Brightness brightness,
    required Color heading,
    required Color accent,
    required Color cta,
    required Color background,
    required Color surface,
    required Color text,
    required Color textSecondary,
    required Color border,
    required Color danger,
  }) {
    final isDark = brightness == Brightness.dark;
    final ctaOn = isDark ? const Color(0xFF111317) : Colors.white;

    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: accent,
      onPrimary: Colors.white,
      secondary: cta,
      onSecondary: ctaOn,
      error: danger,
      onError: Colors.white,
      surface: surface,
      onSurface: text,
    );

    final baseTextTheme = isDark ? ThemeData.dark().textTheme : ThemeData.light().textTheme;
    final textTheme = baseTextTheme
        .apply(fontFamily: 'Poppins', bodyColor: text, displayColor: heading)
        .copyWith(
          headlineSmall: baseTextTheme.headlineSmall?.copyWith(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w700,
            color: heading,
            letterSpacing: -0.3,
          ),
          titleLarge: baseTextTheme.titleLarge?.copyWith(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            color: heading,
          ),
          titleMedium: baseTextTheme.titleMedium?.copyWith(fontFamily: 'Poppins', fontWeight: FontWeight.w600),
          titleSmall: baseTextTheme.titleSmall?.copyWith(fontFamily: 'Poppins', fontWeight: FontWeight.w600),
        );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      fontFamily: 'Poppins',
      colorScheme: colorScheme,
      scaffoldBackgroundColor: background,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: heading,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge,
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shadowColor: Colors.black.withValues(alpha: isDark ? 0.5 : 0.10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: border)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? Colors.white.withValues(alpha: 0.06) : const Color(0xFFF3F7FB),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: TextStyle(color: textSecondary.withValues(alpha: 0.7), fontFamily: 'Poppins'),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: accent, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: danger),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: cta,
          foregroundColor: ctaOn,
          minimumSize: const Size.fromHeight(54),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
          textStyle: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600, fontSize: 16),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: text,
          minimumSize: const Size.fromHeight(54),
          side: BorderSide(color: border),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
          textStyle: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600, fontSize: 16),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: accent,
          textStyle: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600),
        ),
      ),
      iconTheme: IconThemeData(color: accent),
      chipTheme: ChipThemeData(
        backgroundColor: surface,
        side: BorderSide(color: border),
        labelStyle: textTheme.labelMedium,
      ),
      dividerTheme: DividerThemeData(color: border, space: 1),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: heading,
        contentTextStyle: TextStyle(color: background, fontFamily: 'Poppins'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        indicatorColor: accent.withValues(alpha: isDark ? 0.24 : 0.14),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            fontFamily: 'Poppins',
            fontSize: 12,
            fontWeight: states.contains(WidgetState.selected) ? FontWeight.w600 : FontWeight.w500,
            color: states.contains(WidgetState.selected) ? accent : textSecondary,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(color: states.contains(WidgetState.selected) ? accent : textSecondary),
        ),
      ),
    );
  }
}
