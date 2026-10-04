import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary Dark Saffron/Orange palette (rich, high-contrast, devotional)
  static const Color primary = Color(0xFFD84315);
  static const Color primaryLight = Color(0xFFE65100);
  static const Color primaryDark = Color(0xFFBF360C);

  // Gold accent
  static const Color gold = Color(0xFFFFD700);
  static const Color goldDark = Color(0xFFB8860B);
  static const Color goldLight = Color(0xFFFFF0A0);

  // Background
  static const Color background = Color(0xFFFFF8F0);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color cardBg = Color(0xFFFFF3E0);

  // Text
  static const Color textPrimary = Color(0xFF3E1F00);
  static const Color textSecondary = Color(0xFF7A4E2D);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Deep Saffron Gradients (High contrast for white text)
  static const LinearGradient darkSaffronGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFBF360C), Color(0xFFD84315), Color(0xFFE65100)],
  );

  static const LinearGradient saffronGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFBF360C), Color(0xFFD84315)],
  );

  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFD700), Color(0xFFB8860B)],
  );

  static const LinearGradient headerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFBF360C), Color(0xFFD84315), Color(0xFFE65100)],
  );

  // Distinct mode theme colors
  static const Color modeHome = Color(0xFFD84315);       // Deep Dark Saffron
  static const Color modeBhajans = Color(0xFF6A1B9A);    // Royal Purple
  static const Color modeBooks = Color(0xFF2E7D32);      // Sacred Green
  static const Color modeRingtones = Color(0xFF6A1B9A);  // Mystic Violet
  static const Color modeHoroscope = Color(0xFF1565C0);  // Cosmic Blue
  static const Color modeWallpapers = Color(0xFFFF6B00); // Amber Orange

  // Mode header gradients
  static const LinearGradient bhajanHeaderGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF4A148C), Color(0xFF6A1B9A), Color(0xFF7B1FA2)],
  );

  static const LinearGradient booksHeaderGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1B5E20), Color(0xFF2E7D32), Color(0xFF388E3C)],
  );

  // Section card gradients
  static const List<List<Color>> sectionGradients = [
    [Color(0xFFFF6B00), Color(0xFFFFAB40)], // Wallpapers – amber orange
    [Color(0xFF6A1B9A), Color(0xFFAB47BC)], // Ringtones – purple
    [Color(0xFF1565C0), Color(0xFF42A5F5)], // Horoscope – blue
    [Color(0xFF2E7D32), Color(0xFF66BB6A)], // Holy Books – green
    [Color(0xFF6A1B9A), Color(0xFF8E24AA)], // Bhajans – royal purple
  ];

  // Misc
  static const Color divider = Color(0xFFFFE0B2);
  static const Color shimmer = Color(0xFFFFE0B2);
  static const Color shimmerHighlight = Color(0xFFFFF3E0);

  // Nav
  static const Color navActive = Color(0xFFD84315);
  static const Color navInactive = Color(0xFF7A4E2D);
}
