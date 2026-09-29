import 'package:flutter/material.dart';
import 'tg_colors.dart';

class TGTheme {
  static ThemeData get dark {
    return ThemeData.dark().copyWith(
      scaffoldBackgroundColor: TGColors.background,
      primaryColor: TGColors.lightning,
      colorScheme: const ColorScheme.dark(
        primary: TGColors.lightning,
        secondary: TGColors.lightningGlow,
        surface: TGColors.surface,
        error: TGColors.severityEmergency,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: TGColors.background,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: TGColors.textPrimary),
        titleTextStyle: TextStyle(
          color: TGColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: TGColors.surface,
        selectedItemColor: TGColors.lightning,
        unselectedItemColor: TGColors.textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: TGColors.card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: TGColors.cardBorder, width: 1),
        ),
        margin: const EdgeInsets.all(0),
      ),
      dividerColor: TGColors.divider,
      textTheme: const TextTheme(
        displayLarge: TextStyle(
            color: TGColors.textPrimary,
            fontSize: 32,
            fontWeight: FontWeight.w800),
        titleLarge: TextStyle(
            color: TGColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700),
        titleMedium: TextStyle(
            color: TGColors.textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(color: TGColors.textPrimary, fontSize: 14),
        bodyMedium: TextStyle(color: TGColors.textSecondary, fontSize: 13),
        bodySmall: TextStyle(color: TGColors.textMuted, fontSize: 11),
        labelSmall: TextStyle(
            color: TGColors.textMuted,
            fontSize: 10,
            letterSpacing: 1.2,
            fontWeight: FontWeight.w600),
      ),
    );
  }
}
