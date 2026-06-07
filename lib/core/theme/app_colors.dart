import 'package:flutter/material.dart';

/// MYTHRIX.AI brand color tokens.
///
/// The palette is deliberately tuned for the "new fusion" aesthetic:
/// deep cosmic blacks + electric violet/cyan gradients + aurora accents.
/// All colors live here so theming, charts, and bespoke widgets share one source of truth.
class AppColors {
  AppColors._();

  // ---------- Brand primaries ----------
  static const Color mythrixViolet = Color(0xFF7C5CFF); // primary brand
  static const Color mythrixIndigo = Color(0xFF5B6CFF);
  static const Color mythrixCyan = Color(0xFF22D3EE);
  static const Color mythrixMagenta = Color(0xFFE879F9);
  static const Color mythrixPink = Color(0xFFFF4D8D);
  static const Color mythrixLime = Color(0xFFA3E635);
  static const Color mythrixAmber = Color(0xFFF59E0B);
  static const Color mythrixCoral = Color(0xFFFF7849);

  // ---------- Semantic ----------
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFEF4444);
  static const Color info = Color(0xFF38BDF8);

  // ---------- Dark surfaces ----------
  static const Color darkBg = Color(0xFF06070C);        // deepest cosmic black
  static const Color darkSurface = Color(0xFF0B0D14);   // base surface
  static const Color darkSurface1 = Color(0xFF11141D);  // elevated
  static const Color darkSurface2 = Color(0xFF171B27);  // higher
  static const Color darkSurface3 = Color(0xFF1F2433);  // highest
  static const Color darkBorder = Color(0x1FFFFFFF);    // 12% white
  static const Color darkBorderStrong = Color(0x33FFFFFF); // 20% white
  static const Color darkOverlay = Color(0x80000000);

  // ---------- Light surfaces ----------
  static const Color lightBg = Color(0xFFF6F7FB);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurface1 = Color(0xFFFAFBFE);
  static const Color lightSurface2 = Color(0xFFF1F3F9);
  static const Color lightSurface3 = Color(0xFFE7EAF3);
  static const Color lightBorder = Color(0x14000000);
  static const Color lightBorderStrong = Color(0x29000000);

  // ---------- Text — dark theme ----------
  static const Color textHigh = Color(0xFFF5F7FA);
  static const Color textMid = Color(0xB3F5F7FA);   // 70%
  static const Color textLow = Color(0x80F5F7FA);   // 50%
  static const Color textDisabled = Color(0x4DF5F7FA); // 30%

  // ---------- Text — light theme ----------
  static const Color textHighLight = Color(0xFF0B0D14);
  static const Color textMidLight = Color(0xB30B0D14);
  static const Color textLowLight = Color(0x800B0D14);
  static const Color textDisabledLight = Color(0x4D0B0D14);

  // ---------- Signature gradients ----------
  static const LinearGradient brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [mythrixViolet, mythrixCyan],
  );

  static const LinearGradient brandGradientWarm = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [mythrixMagenta, mythrixCoral, mythrixAmber],
  );

  static const LinearGradient auroraGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF7C5CFF),
      Color(0xFF22D3EE),
      Color(0xFFA3E635),
    ],
    stops: [0.0, 0.55, 1.0],
  );

  static const LinearGradient successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF22C55E), Color(0xFF14B8A6)],
  );

  static const LinearGradient dangerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFEF4444), Color(0xFFE879F9)],
  );

  /// Subtle radial glow used behind hero elements and AI moments.
  static RadialGradient heroGlow({Color color = mythrixViolet}) => RadialGradient(
        center: Alignment.center,
        radius: 0.9,
        colors: [
          color.withValues(alpha: 0.35),
          color.withValues(alpha: 0.0),
        ],
      );

  /// Categorical palette used for chart series.
  static const List<Color> chartPalette = [
    mythrixViolet,
    mythrixCyan,
    mythrixMagenta,
    mythrixLime,
    mythrixAmber,
    mythrixCoral,
    mythrixIndigo,
    mythrixPink,
  ];
}
