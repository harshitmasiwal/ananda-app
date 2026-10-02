import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary Saffron/Orange palette
  static const Color primary = Color(0xFFFF6B00);
  static const Color primaryLight = Color(0xFFFF9A3C);
  static const Color primaryDark = Color(0xFFD44F00);

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

  // Gradients
  static const LinearGradient saffronGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFF6B00), Color(0xFFFF9A3C)],
  );

  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFD700), Color(0xFFB8860B)],
  );

  static const LinearGradient headerGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFF6B00), Color(0xFFFF9A3C), Color(0xFFFFF8F0)],
    stops: [0.0, 0.6, 1.0],
  );

  // Section card gradients
  static const List<List<Color>> sectionGradients = [
    [Color(0xFFFF6B00), Color(0xFFFFAB40)], // Wallpapers – orange
    [Color(0xFF6A1B9A), Color(0xFFAB47BC)], // Ringtones – purple
    [Color(0xFF1565C0), Color(0xFF42A5F5)], // Horoscope – blue
    [Color(0xFF2E7D32), Color(0xFF66BB6A)], // Holy Books – green
    [Color(0xFFC62828), Color(0xFFEF5350)], // Bhajans – red
  ];

  // Misc
  static const Color divider = Color(0xFFFFE0B2);
  static const Color shimmer = Color(0xFFFFE0B2);
  static const Color shimmerHighlight = Color(0xFFFFF3E0);

  // Nav
  static const Color navActive = Color(0xFFFF6B00);
  static const Color navInactive = Color(0xFF7A4E2D);
}
