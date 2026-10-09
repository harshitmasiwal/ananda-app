import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../shared/widgets/anand_header.dart';
import '../../shared/widgets/bouncing_tap.dart';

class JapaScreen extends ConsumerStatefulWidget {
  const JapaScreen({super.key});

  @override
  ConsumerState<JapaScreen> createState() => _JapaScreenState();
}

class _JapaScreenState extends ConsumerState<JapaScreen> {
  // Demo state matching Screenshot 4: 27 reps done of 108 target, 4 malas completed
  int _currentReps = 27;
  int _selectedTarget = 108;
  int _malasCompleted = 4;
  String _selectedSankalpa = '108 Mala';

  final List<String> _sankalpaOptions = ['11', '21', '54', '108 Mala'];

  void _tapToChant() {
    setState(() {
      _currentReps++;
      if (_currentReps >= _selectedTarget) {
        _currentReps = 0;
        _malasCompleted++;
      }
    });
  }

  void _resetCounter() {
    setState(() {
      _currentReps = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Top App Bar
            const AnandHeader(),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Subheader: "Maha Mantra Sadhana"
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Maha Mantra Sadhana',
                                  style: GoogleFonts.playfairDisplay(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF2E170C),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Continuous focus & sacred japa mala meditation',
                                  style: GoogleFonts.outfit(
                                    fontSize: 12.5,
                                    color: const Color(0xFF7B6B61),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Chime pill button
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFBECE1),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: const Color(0xFFF0D8C7),
                                width: 0.8,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.notifications_active_outlined,
                                  size: 15,
                                  color: Color(0xFF8C3B00),
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  'Chime',
                                  style: GoogleFonts.outfit(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF8C3B00),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Sankalpa Reps Row
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.all_inclusive_rounded,
                            size: 18,
                            color: Color(0xFF8C3B00),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Sankalpa Reps:',
                            style: GoogleFonts.outfit(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF2E170C),
                            ),
                          ),
                          const Spacer(),
                          // Options pills: 11, 21, 54, 108 Mala
                          ..._sankalpaOptions.map((opt) {
                            final isSelected = opt == _selectedSankalpa;
                            return Padding(
                              padding: const EdgeInsets.only(left: 6),
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedSankalpa = opt;
                                    if (opt == '11') {
                                      _selectedTarget = 11;
                                    } else if (opt == '21') {
                                      _selectedTarget = 21;
                                    } else if (opt == '54') {
                                      _selectedTarget = 54;
                                    } else {
                                      _selectedTarget = 108;
                                    }
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? const Color(0xFF8C3B00)
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: isSelected
                                          ? const Color(0xFF8C3B00)
                                          : const Color(0xFFE8DFD3),
                                      width: 0.8,
                                    ),
                                  ),
                                  child: Text(
                                    opt,
                                    style: GoogleFonts.outfit(
                                      fontSize: 11.5,
                                      fontWeight: isSelected
                                          ? FontWeight.w700
                                          : FontWeight.w500,
                                      color: isSelected
                                          ? Colors.white
                                          : const Color(0xFF7B6B61),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Main Sadhana Card
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: const Color(0xFFEDE4D8),
                          width: 1.0,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 14,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Kaliyuga Taraka Mantra badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFBECE1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.auto_awesome,
                                  size: 13,
                                  color: Color(0xFF8C3B00),
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  'Kaliyuga Tāraka Mantra',
                                  style: GoogleFonts.outfit(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF8C3B00),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 18),

                          // Hindi Devanagari Mantra
                          Text(
                            'हरे कृष्ण हरे कृष्ण कृष्ण कृष्ण हरे हरे\nहरे राम हरे राम राम राम हरे हरे',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.rozhaOne(
                              fontSize: 19,
                              fontWeight: FontWeight.w600,
                              height: 1.45,
                              color: const Color(0xFF8C3B00),
                            ),
                          ),

                          const SizedBox(height: 12),

                          // English Transliteration
                          Text(
                            '"Hare Krishna Hare Krishna Krishna Krishna Hare Hare\nHare Rama Hare Rama Rama Rama Hare Hare"',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.outfit(
                              fontSize: 11.5,
                              fontStyle: FontStyle.italic,
                              height: 1.35,
                              color: const Color(0xFF7B6B61),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Circular Japa Dial Counter
                          GestureDetector(
                            onTap: _tapToChant,
                            child: SizedBox(
                              width: 200,
                              height: 200,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  // Progress Dial Painter
                                  CustomPaint(
                                    size: const Size(200, 200),
                                    painter: _JapaDialPainter(
                                      progress: (_currentReps / _selectedTarget)
                                          .clamp(0.0, 1.0),
                                    ),
                                  ),

                                  // Inner Content
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // Sun / Radiant Icon
                                      const Icon(
                                        Icons.wb_sunny_outlined,
                                        size: 22,
                                        color: Color(0xFFC9883E),
                                      ),
                                      const SizedBox(height: 2),

                                      // Big Reps Number
                                      Text(
                                        '$_currentReps',
                                        style: GoogleFonts.playfairDisplay(
                                          fontSize: 40,
                                          fontWeight: FontWeight.w700,
                                          color: const Color(0xFF8C3B00),
                                          height: 1.0,
                                        ),
                                      ),
                                      const SizedBox(height: 2),

                                      // Target label
                                      Text(
                                        '/ $_selectedTarget Reps',
                                        style: GoogleFonts.outfit(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: const Color(0xFF8C7C72),
                                        ),
                                      ),
                                      const SizedBox(height: 8),

                                      // Tap to Chant pill
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFBECE1),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Text('📿', style: TextStyle(fontSize: 11)),
                                            const SizedBox(width: 4),
                                            Text(
                                              'Tap to Chant',
                                              style: GoogleFonts.outfit(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                                color: const Color(0xFF8C3B00),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 22),

                          // Bottom Row: Malas Completed & Reset
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFBECE1),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.check_circle_rounded,
                                      size: 15,
                                      color: Color(0xFF8C3B00),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Malas Completed: $_malasCompleted',
                                      style: GoogleFonts.outfit(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF8C3B00),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 14),
                              BouncingTap(
                                onTap: _resetCounter,
                                child: Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: const Color(0xFFDACFC2),
                                      width: 1.0,
                                    ),
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.refresh_rounded,
                                      size: 18,
                                      color: Color(0xFF7B6B61),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom Painter for circular dial like Screenshot 4
class _JapaDialPainter extends CustomPainter {
  final double progress;
  _JapaDialPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - 10;

    // Outer subtle boundary ring
    final outerRingPaint = Paint()
      ..color = const Color(0xFFEDE5D8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawCircle(center, radius + 6, outerRingPaint);

    // Track circle background
    final trackPaint = Paint()
      ..color = const Color(0xFFF3ECE0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 9.0;
    canvas.drawCircle(center, radius, trackPaint);

    // Active progress arc in Terracotta
    final progressPaint = Paint()
      ..color = const Color(0xFF8C3B00)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 9.0;

    // Start angle at top right or standard top (-pi / 2)
    const startAngle = -math.pi / 2;
    final sweepAngle = 2 * math.pi * progress;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _JapaDialPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
