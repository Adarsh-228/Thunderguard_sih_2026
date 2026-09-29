import 'package:flutter/material.dart';

class AppColors {
  // Dark / Grey Theme Palette (Minimalist & Slate aesthetic)
  static const Color background = Color(0xFF121214);
  static const Color surface = Color(0xFF1E1E22);
  static const Color cardSurface = Color(0xFF26262B);
  static const Color borderGrey = Color(0xFF33333A);

  // Text colors
  static const Color textPrimary = Color(0xFFE8E8EC);
  static const Color textSecondary = Color(0xFF9E9EA8);
  static const Color textMuted = Color(0xFF6E6E78);

  // Minimal Status Indicator Accents
  static const Color gnssActive = Color(0xFF10B981);       // Emerald Green (GNSS+INS Aided)
  static const Color tunnelActive = Color(0xFFF59E0B);     // Soft Amber (Tunnel Dead Reckoning)
  static const Color warningRed = Color(0xFFEF4444);       // Red (Outage Alert)
  static const Color accentBlue = Color(0xFF3B82F6);       // Slate Blue (Vehicle Path)
  static const Color trajectoryTrail = Color(0x803B82F6);  // Transparent Path
  static const Color groundTruthPath = Color(0xFF8B5CF6);  // Purple for Ground Truth comparison
}
