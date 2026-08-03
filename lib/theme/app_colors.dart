import 'package:flutter/material.dart';

/// Brand color tokens for Smart Voice Alarm.
/// Teal primary with warm amber accents — premium, calm, distinct.
abstract final class AppColors {
  static const Color brandTeal = Color(0xFF0D9488);
  static const Color brandTealLight = Color(0xFF2DD4BF);
  static const Color brandTealDeep = Color(0xFF0F766E);
  static const Color brandAmber = Color(0xFFF59E0B);
  static const Color brandAmberSoft = Color(0xFFFBBF24);

  static const Color lightBackground = Color(0xFFF3F6F5);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceMuted = Color(0xFFE8EFED);
  static const Color lightOnBackground = Color(0xFF0F1A1A);
  static const Color lightOnSurface = Color(0xFF1A2B2A);
  static const Color lightOutline = Color(0xFFD0DBD8);
  static const Color lightMuted = Color(0xFF5C736F);

  static const Color darkBackground = Color(0xFF0A1012);
  static const Color darkSurface = Color(0xFF131A1D);
  static const Color darkSurfaceMuted = Color(0xFF1C2629);
  static const Color darkOnBackground = Color(0xFFF2F7F6);
  static const Color darkOnSurface = Color(0xFFE4EEEC);
  static const Color darkOutline = Color(0xFF2A3836);
  static const Color darkMuted = Color(0xFF8AA39E);

  static const Color danger = Color(0xFFEF4444);
  static const Color success = Color(0xFF22C55E);

  static const LinearGradient splashGradientLight = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFE8F7F4),
      Color(0xFFF3F6F5),
      Color(0xFFFFF8EB),
    ],
  );

  static const LinearGradient splashGradientDark = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF0A1614),
      Color(0xFF0A1012),
      Color(0xFF16120A),
    ],
  );

  static const LinearGradient premiumGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF0F766E),
      Color(0xFF0D9488),
      Color(0xFFD97706),
    ],
  );

  static const LinearGradient heroGlow = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0x332DD4BF),
      Color(0x000D9488),
    ],
  );
}
