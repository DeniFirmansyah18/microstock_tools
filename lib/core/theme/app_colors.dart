import 'package:flutter/material.dart';

/// Design tokens inspired by Wabi Minimalist aesthetic
class AppColors {
  // Canvas & Surfaces
  static const Color background = Color(0xFFFBFBFD);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFF4F4F6);
  static const Color surfaceGlass = Color(0xEAFFFFFF);
  
  // High contrast & Typography
  static const Color textPrimary = Color(0xFF111114);
  static const Color textSecondary = Color(0xFF6E6E77);
  static const Color textTertiary = Color(0xFF9E9EA7);
  static const Color matteBlack = Color(0xFF16161A);
  
  // Borders & Dividers
  static const Color borderLight = Color(0xFFECECED);
  static const Color borderSubtle = Color(0xFFE2E2E6);
  static const Color borderGlass = Color(0x33FFFFFF);

  // Accents & Signals
  static const Color accentBlue = Color(0xFF2563EB);
  static const Color accentCyan = Color(0xFF06B6D4);
  static const Color accentIndigo = Color(0xFF4F46E5);
  static const Color accentGreen = Color(0xFF10B981);
  static const Color accentAmber = Color(0xFFF59E0B);
  static const Color accentRed = Color(0xFFEF4444);

  // Gradients
  static const LinearGradient moodBoardGradient = LinearGradient(
    colors: [Color(0xFFE0F2FE), Color(0xFFF0F9FF), Color(0xFFFFFFFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient glossyOrbGradient = LinearGradient(
    colors: [Color(0xFF60A5FA), Color(0xFF2563EB), Color(0xFF1E3A8A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
