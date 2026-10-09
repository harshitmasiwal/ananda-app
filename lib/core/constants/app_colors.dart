import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ── Core Aesthetic Palette (Matching Anand Screenshots) ───────────
  static const Color background     = Color(0xFFFAF7F2); // Warm devotional ivory/cream
  static const Color surface        = Color(0xFFFFFFFF); // Pure white card surface
  static const Color surfaceTint    = Color(0xFFFDFBF7); // Soft tinted card
  static const Color cardBg         = Color(0xFFFFFFFF);
  
  // Primary terracotta / warm saddle brown
  static const Color primary        = Color(0xFF8C3B00); // Deep terracotta (buttons, active states)
  static const Color primaryLight   = Color(0xFFA84E0B); // Lighter terracotta
  static const Color primaryDark    = Color(0xFF5A2503); // Deepest terracotta
  
  // Peach / warm saffron accent & pill tints
  static const Color peachPill      = Color(0xFFFBECE1); // Soft peach badge / pill background
  static const Color peachPillBorder= Color(0xFFF0D8C7);
  static const Color terracottaAccent = Color(0xFF943E00);
  static const Color orangeGradStart= Color(0xFFE56A10);
  static const Color orangeGradEnd  = Color(0xFFB54502);

  // Gold / Amber
  static const Color gold           = Color(0xFFC9883E); // Radiant sun/chakra gold
  static const Color goldLight      = Color(0xFFFDF4E7);
  static const Color goldBright     = Color(0xFFE89A2A);

  // Mini-player background
  static const Color miniPlayerBg   = Color(0xFFEAE5DB); // Warm muted grey-cream

  // Typography colors
  static const Color textPrimary    = Color(0xFF2C1810); // Rich dark warm brown
  static const Color textSecondary  = Color(0xFF7B6B61); // Muted brown-grey
  static const Color textTertiary   = Color(0xFFA5958A); // Subtle grey-brown
  static const Color textTerracotta = Color(0xFF8C3B00); // Terracotta accent text
  static const Color textOnPrimary  = Color(0xFFFFFFFF);
  static const Color textOnDark     = Color(0xFFFFFFFF);

  // Borders & Dividers
  static const Color border         = Color(0xFFEFE9DE); // Subtle card border
  static const Color borderLight    = Color(0xFFF5EFE6);
  static const Color divider        = Color(0xFFEFE9DE);

  // Nav bar
  static const Color navBarBg       = Color(0xFFFAF7F2);
  static const Color navActive      = Color(0xFF8C3B00);
  static const Color navInactive    = Color(0xFF7B6B61);
  static const Color navPill        = Color(0xFFFBECE1);

  // Compatibility aliases for existing screens
  static const Color maroon         = Color(0xFF8C3B00);
  static const Color maroonMid      = Color(0xFFA84E0B);
  static const Color maroonLight    = Color(0xFFC25D14);
  static const Color amber          = Color(0xFFC9883E);
  static const Color amberLight     = Color(0xFFE89A2A);
  static const Color saffron        = Color(0xFFE56A10);
  static const Color cream          = Color(0xFFFAF7F2);
  static const Color surfaceAlt     = Color(0xFFF5EFE6);
  static const Color goldDark       = Color(0xFF9E651D);
  static const Color textGold       = Color(0xFFC9883E);
  static const Color featuredBg     = Color(0xFF8C3B00);
  static const Color featuredBgDark = Color(0xFF5A2503);
  static const Color chipActive     = Color(0xFF8C3B00);
  static const Color chipInactive   = Color(0xFFFBECE1);
  static const Color shimmer        = Color(0xFFEDE6DA);
  static const Color shimmerHighlight = Color(0xFFFFFFFF);

  static const Color modeHome       = Color(0xFF8C3B00);
  static const Color modeBhajans    = Color(0xFF8C3B00);
  static const Color modeBooks      = Color(0xFF6B3A10);
  static const Color modeRingtones  = Color(0xFF8C3B00);
  static const Color modeHoroscope  = Color(0xFF4A2B60);
  static const Color modeWallpapers = Color(0xFF8C3B00);

  // Gradients
  static const LinearGradient headerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFE56A10), Color(0xFFB54502)],
  );

  static const LinearGradient logoGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFE56A10), Color(0xFF943E00)],
  );

  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF8C3B00), Color(0xFFB54502)],
  );

  static const LinearGradient darkSaffronGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF5A2503), Color(0xFF8C3B00)],
  );

  static const LinearGradient saffronGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFE56A10), Color(0xFF943E00)],
  );

  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFE89A2A), Color(0xFFC9883E)],
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFAF7F2), Color(0xFFF5EFE6)],
  );

  static const LinearGradient bhajanHeaderGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF5A2503), Color(0xFF8C3B00)],
  );

  static const LinearGradient booksHeaderGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF5A2503), Color(0xFF8C3B00)],
  );

  static const LinearGradient astroHeaderGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF2C1642), Color(0xFF52285E)],
  );

  static const List<List<Color>> sectionGradients = [
    [Color(0xFFE56A10), Color(0xFFB54502)],
    [Color(0xFF8C3B00), Color(0xFFA84E0B)],
    [Color(0xFF3A2050), Color(0xFF653B82)],
    [Color(0xFF8C3B00), Color(0xFFC9883E)],
    [Color(0xFF8C3B00), Color(0xFFB54502)],
  ];

  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.03),
      blurRadius: 10,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> get elevatedCardShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.06),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];
}
