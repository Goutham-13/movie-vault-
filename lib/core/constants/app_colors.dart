import 'package:flutter/material.dart';

class AppColors {
  // Backgrounds
  static const Color background = Color(0xFF07080C);
  static const Color secondaryBackground = Color(0xFF0D0F14);
  static const Color card = Color(0xFF13161D);
  static const Color cardElevated = Color(0xFF191C24);
  static const Color cardBorder = Color(0xFF222632);
  
  // Accents
  static const Color primaryAccent = Color(0xFFE50914); // Electric Crimson / Cinema Red
  static const Color secondaryAccent = Color(0xFF8B5CF6); // Electric Violet
  static const Color cyanAccent = Color(0xFF00F2FE); // Futuristic Cyan
  static const Color amberRating = Color(0xFFFFB800); // Warm Gold Rating Stars
  static const Color emeraldSuccess = Color(0xFF10B981); // Watched Green Badge
  
  // Status Colors
  static const Color wishlistChip = Color(0xFF3B82F6); // Blue
  static const Color watchingChip = Color(0xFFF59E0B); // Amber
  static const Color watchedChip = Color(0xFF10B981); // Emerald
  static const Color favoritePink = Color(0xFFEC4899); // Neon Pink
  
  // Typography Colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF9DA3B0);
  static const Color textMuted = Color(0xFF626875);
  
  // Overlay & Gradients
  static const Color overlayDark = Color(0xCC07080C);
  static const Color glassBorder = Color(0x1AFFFFFF);
  static const Color glassBackground = Color(0x14FFFFFF);
  
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFE50914), Color(0xFFB81D24)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkFadeGradient = LinearGradient(
    colors: [
      Color(0x0007080C),
      Color(0x8007080C),
      Color(0xFF07080C),
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    stops: [0.0, 0.6, 1.0],
  );
}
