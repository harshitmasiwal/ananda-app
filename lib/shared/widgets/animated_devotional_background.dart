import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Available devotional color modes matching the app's visual identities.
enum DevotionalMode {
  home,
  bhajans,
  books,
  wallpapers,
  ringtones,
  horoscope,
}

class _DevotionalPalette {
  final List<Color> gradientColors;
  final Color orb1Color;
  final Color orb2Color;

  const _DevotionalPalette({
    required this.gradientColors,
    required this.orb1Color,
    required this.orb2Color,
  });

  static const home = _DevotionalPalette(
    gradientColors: [
      Color(0xFFFFF6ED),
      Color(0xFFFFEDE0),
      Color(0xFFFFDFCE),
      Color(0xFFFFF8F2),
    ],
    orb1Color: Color(0x38FF6F00), // warm amber glow
    orb2Color: Color(0x32FFD54F), // golden light
  );

  static const bhajans = _DevotionalPalette(
    gradientColors: [
      Color(0xFFFAF5FF),
      Color(0xFFF3E8FF),
      Color(0xFFEDE9FE),
      Color(0xFFFAF7FF),
    ],
    orb1Color: Color(0x309C27B0), // royal purple glow
    orb2Color: Color(0x28673AB7), // mystic violet glow
  );

  static const books = _DevotionalPalette(
    gradientColors: [
      Color(0xFFF2F9F5),
      Color(0xFFE8F5E9),
      Color(0xFFDCEDC8),
      Color(0xFFF4FAF6),
    ],
    orb1Color: Color(0x3043A047), // sacred forest green
    orb2Color: Color(0x2800897B), // sacred teal
  );

  static const wallpapers = _DevotionalPalette(
    gradientColors: [
      Color(0xFFFFF8F0),
      Color(0xFFFFECD2),
      Color(0xFFFFDFBA),
      Color(0xFFFFF9F2),
    ],
    orb1Color: Color(0x34FB8C00), // radiant dawn amber
    orb2Color: Color(0x2EF4511E), // deep saffron accent
  );

  static const ringtones = _DevotionalPalette(
    gradientColors: [
      Color(0xFFFAF5FF),
      Color(0xFFEDE7F6),
      Color(0xFFF3E5F5),
      Color(0xFFFAF6FE),
    ],
    orb1Color: Color(0x307E57C2), // spiritual violet
    orb2Color: Color(0x28AB47BC), // melodic magenta
  );

  static const horoscope = _DevotionalPalette(
    gradientColors: [
      Color(0xFFF0F4FA),
      Color(0xFFE8EAF6),
      Color(0xFFE1F5FE),
      Color(0xFFF3F6FB),
    ],
    orb1Color: Color(0x303949AB), // celestial cosmic indigo
    orb2Color: Color(0x280288D1), // starlight blue
  );

  static _DevotionalPalette forMode(DevotionalMode mode) {
    switch (mode) {
      case DevotionalMode.home:
        return home;
      case DevotionalMode.bhajans:
        return bhajans;
      case DevotionalMode.books:
        return books;
      case DevotionalMode.wallpapers:
        return wallpapers;
      case DevotionalMode.ringtones:
        return ringtones;
      case DevotionalMode.horoscope:
        return horoscope;
    }
  }

  static _DevotionalPalette lerp(
      _DevotionalPalette a, _DevotionalPalette b, double t) {
    final clampedT = t.clamp(0.0, 1.0);
    final count = math.min(a.gradientColors.length, b.gradientColors.length);
    final blendedGradients = List.generate(count, (i) {
      return Color.lerp(a.gradientColors[i], b.gradientColors[i], clampedT) ??
          a.gradientColors[i];
    });

    final o1 = Color.lerp(a.orb1Color, b.orb1Color, clampedT) ?? a.orb1Color;
    final o2 = Color.lerp(a.orb2Color, b.orb2Color, clampedT) ?? a.orb2Color;

    return _DevotionalPalette(
      gradientColors: blendedGradients,
      orb1Color: o1,
      orb2Color: o2,
    );
  }
}

/// An animated living devotional background featuring gentle drifting gradient shifts
/// and breathing glowing ambient orbs.
///
/// Can be driven by a [PageController] (for seamless swiping between tabs in MainShell)
/// or by an explicit [DevotionalMode].
class AnimatedDevotionalBackground extends StatefulWidget {
  final Widget child;
  final DevotionalMode mode;
  final PageController? pageController;

  const AnimatedDevotionalBackground({
    super.key,
    required this.child,
    this.mode = DevotionalMode.home,
    this.pageController,
  });

  @override
  State<AnimatedDevotionalBackground> createState() =>
      _AnimatedDevotionalBackgroundState();
}

class _AnimatedDevotionalBackgroundState
    extends State<AnimatedDevotionalBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ambientCtrl;
  double _pageOffset = 0.0;

  @override
  void initState() {
    super.initState();
    _ambientCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);

    if (widget.pageController != null) {
      _pageOffset = widget.pageController!.initialPage.toDouble();
      widget.pageController!.addListener(_handlePageScroll);
    }
  }

  @override
  void didUpdateWidget(covariant AnimatedDevotionalBackground oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pageController != widget.pageController) {
      oldWidget.pageController?.removeListener(_handlePageScroll);
      widget.pageController?.addListener(_handlePageScroll);
      if (widget.pageController != null &&
          widget.pageController!.hasClients &&
          widget.pageController!.page != null) {
        _pageOffset = widget.pageController!.page!;
      }
    }
  }

  @override
  void dispose() {
    widget.pageController?.removeListener(_handlePageScroll);
    _ambientCtrl.dispose();
    super.dispose();
  }

  void _handlePageScroll() {
    if (widget.pageController != null &&
        widget.pageController!.hasClients &&
        widget.pageController!.page != null) {
      final newPage = widget.pageController!.page!;
      if ((newPage - _pageOffset).abs() > 0.005) {
        setState(() {
          _pageOffset = newPage;
        });
      }
    }
  }

  _DevotionalPalette _currentPalette() {
    if (widget.pageController != null) {
      // 3 MainShell tabs: 0 = Home, 1 = Bhajans, 2 = Books
      final p = _pageOffset.clamp(0.0, 2.0);
      if (p <= 1.0) {
        return _DevotionalPalette.lerp(
          _DevotionalPalette.home,
          _DevotionalPalette.bhajans,
          p,
        );
      } else {
        return _DevotionalPalette.lerp(
          _DevotionalPalette.bhajans,
          _DevotionalPalette.books,
          p - 1.0,
        );
      }
    }
    return _DevotionalPalette.forMode(widget.mode);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ambientCtrl,
      builder: (context, staticChild) {
        final palette = _currentPalette();
        return CustomPaint(
          painter: _DevotionalBackgroundPainter(
            animationValue: _ambientCtrl.value,
            palette: palette,
          ),
          child: staticChild,
        );
      },
      child: widget.child,
    );
  }
}

class _DevotionalBackgroundPainter extends CustomPainter {
  final double animationValue;
  final _DevotionalPalette palette;

  _DevotionalBackgroundPainter({
    required this.animationValue,
    required this.palette,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    // 1. Drifting primary linear ambient gradient
    final sinVal = math.sin(animationValue * math.pi);
    final cosVal = math.cos(animationValue * math.pi);

    final beginAlignment = Alignment(
      -0.8 + 0.3 * animationValue,
      -1.0 + 0.2 * sinVal,
    );
    final endAlignment = Alignment(
      0.8 - 0.3 * animationValue,
      1.0 - 0.2 * cosVal,
    );

    final backgroundPaint = Paint()
      ..shader = LinearGradient(
        begin: beginAlignment,
        end: endAlignment,
        colors: palette.gradientColors,
      ).createShader(rect);

    canvas.drawRect(rect, backgroundPaint);

    // 2. Floating Ambient Glow Orb 1 (Top-Right drifting gently)
    final orb1Center = Offset(
      size.width * 0.82 + 25.0 * math.cos(animationValue * 2 * math.pi),
      size.height * 0.22 + 20.0 * math.sin(animationValue * 2 * math.pi),
    );
    final orb1Radius =
        (size.width * 0.55) * (1.0 + 0.12 * sinVal);

    final orb1Paint = Paint()
      ..shader = RadialGradient(
        center: Alignment.center,
        radius: 0.5,
        colors: [
          palette.orb1Color,
          palette.orb1Color.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromCircle(center: orb1Center, radius: orb1Radius));

    canvas.drawCircle(orb1Center, orb1Radius, orb1Paint);

    // 3. Floating Ambient Glow Orb 2 (Bottom-Left drifting gently)
    final orb2Center = Offset(
      size.width * 0.15 - 20.0 * math.sin(animationValue * 2 * math.pi),
      size.height * 0.72 + 25.0 * math.cos(animationValue * 2 * math.pi),
    );
    final orb2Radius =
        (size.width * 0.65) * (1.0 + 0.10 * cosVal);

    final orb2Paint = Paint()
      ..shader = RadialGradient(
        center: Alignment.center,
        radius: 0.5,
        colors: [
          palette.orb2Color,
          palette.orb2Color.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromCircle(center: orb2Center, radius: orb2Radius));

    canvas.drawCircle(orb2Center, orb2Radius, orb2Paint);
  }

  @override
  bool shouldRepaint(covariant _DevotionalBackgroundPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.palette != palette;
  }
}
