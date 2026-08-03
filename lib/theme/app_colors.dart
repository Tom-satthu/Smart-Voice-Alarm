import 'package:flutter/material.dart';

/// Brand color tokens — one teal accent, calm surfaces, designed light/dark.
abstract final class AppColors {
  static const Color brandTeal = Color(0xFF0F766E);
  static const Color brandTealBright = Color(0xFF14B8A6);
  static const Color brandTealSoft = Color(0xFF5EEAD4);
  static const Color brandTealDeep = Color(0xFF115E59);

  static const Color lightBackground = Color(0xFFF5F7F7);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceMuted = Color(0xFFECF1F0);
  static const Color lightOnBackground = Color(0xFF0B1615);
  static const Color lightOnSurface = Color(0xFF152423);
  static const Color lightOutline = Color(0xFFD5E0DE);
  static const Color lightMuted = Color(0xFF5B716E);

  static const Color darkBackground = Color(0xFF070B0C);
  static const Color darkSurface = Color(0xFF11181A);
  static const Color darkSurfaceMuted = Color(0xFF1A2326);
  static const Color darkOnBackground = Color(0xFFF3F8F7);
  static const Color darkOnSurface = Color(0xFFE6EEEC);
  static const Color darkOutline = Color(0xFF2A3537);
  static const Color darkMuted = Color(0xFF8FA3A0);

  static const Color danger = Color(0xFFE11D48);
  static const Color success = Color(0xFF16A34A);

  static const LinearGradient splashGradientLight = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFE7F6F3), Color(0xFFF5F7F7), Color(0xFFF8FAFA)],
  );

  static const LinearGradient splashGradientDark = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF0A1514), Color(0xFF070B0C), Color(0xFF0A0E10)],
  );

  static const LinearGradient brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF14B8A6), Color(0xFF0F766E), Color(0xFF115E59)],
  );

  static const LinearGradient premiumGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF115E59), Color(0xFF0F766E), Color(0xFF0D9488)],
  );
}
