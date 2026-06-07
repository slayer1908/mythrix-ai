import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Typography scale — Space Grotesk for display, Inter for UI/body, JetBrains Mono for code.
class AppTypography {
  AppTypography._();

  static TextTheme textTheme(Color onSurface) {
    final display = GoogleFonts.spaceGrotesk;
    final body = GoogleFonts.inter;

    return TextTheme(
      // Display: hero numbers, page titles
      displayLarge: display(
        fontSize: 57,
        fontWeight: FontWeight.w700,
        letterSpacing: -1.4,
        height: 1.05,
        color: onSurface,
      ),
      displayMedium: display(
        fontSize: 45,
        fontWeight: FontWeight.w700,
        letterSpacing: -1.0,
        height: 1.08,
        color: onSurface,
      ),
      displaySmall: display(
        fontSize: 36,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.6,
        height: 1.1,
        color: onSurface,
      ),

      // Headlines: section titles
      headlineLarge: display(
        fontSize: 30,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.4,
        height: 1.15,
        color: onSurface,
      ),
      headlineMedium: display(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
        color: onSurface,
      ),
      headlineSmall: display(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.1,
        color: onSurface,
      ),

      // Titles
      titleLarge: body(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        color: onSurface,
      ),
      titleMedium: body(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        color: onSurface,
      ),
      titleSmall: body(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        color: onSurface,
      ),

      // Body
      bodyLarge: body(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.55,
        color: onSurface,
      ),
      bodyMedium: body(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.55,
        color: onSurface,
      ),
      bodySmall: body(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: onSurface,
      ),

      // Labels (buttons, chips, captions)
      labelLarge: body(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
        color: onSurface,
      ),
      labelMedium: body(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.3,
        color: onSurface,
      ),
      labelSmall: body(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.4,
        color: onSurface,
      ),
    );
  }

  /// Tabular-figures variant for tables, KPI numbers, and money values.
  static TextStyle mono({double size = 14, FontWeight weight = FontWeight.w500, Color? color}) {
    return GoogleFonts.jetBrainsMono(
      fontSize: size,
      fontWeight: weight,
      color: color,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
  }

  /// Numeric display style for KPI cards — large, tabular, tight tracking.
  static TextStyle kpiNumber({double size = 36, Color? color}) {
    return GoogleFonts.spaceGrotesk(
      fontSize: size,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.8,
      color: color,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
  }
}
