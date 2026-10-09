import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../shared/widgets/anand_header.dart';
import '../../shared/widgets/bouncing_tap.dart';

class SadhakScreen extends ConsumerStatefulWidget {
  const SadhakScreen({super.key});

  @override
  ConsumerState<SadhakScreen> createState() => _SadhakScreenState();
}

class _SadhakScreenState extends ConsumerState<SadhakScreen> {
  // Demo state matching Screenshots 1 & 2: items 0 and 1 checked (2/4 Done)
  final List<bool> _checklist = [true, true, false, false];

  int get _doneCount => _checklist.where((c) => c).length;

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
                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),

                    // ── Profile Card (Screenshot 1) ──────────────────────────
                    Container(
                      padding: const EdgeInsets.all(18),
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
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Avatar with Golden Verified Badge
                              Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  Container(
                                    width: 76,
                                    height: 76,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: const Color(0xFFE2C9B6),
                                        width: 2.0,
                                      ),
                                      color: const Color(0xFFF3ECE0),
                                    ),
                                    child: ClipOval(
                                      child: Image.network(
                                        'https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?w=200&q=80',
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => const Icon(
                                          Icons.person_rounded,
                                          size: 46,
                                          color: Color(0xFF8C3B00),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 2,
                                    child: Container(
                                      width: 20,
                                      height: 20,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFE59400),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Center(
                                        child: Icon(
                                          Icons.check_rounded,
                                          size: 14,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 14),

                              // Name, Streak & Path
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // 42 Days Sacred Streak badge
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFBECE1),
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Text('🔥', style: TextStyle(fontSize: 11)),
                                          const SizedBox(width: 4),
                                          Text(
                                            '42 Days Sacred Streak',
                                            style: GoogleFonts.outfit(
                                              fontSize: 11.5,
                                              fontWeight: FontWeight.w600,
                                              color: const Color(0xFF8C3B00),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 6),

                                    // Name
                                    Text(
                                      'Aarav Sharma',
                                      style: GoogleFonts.playfairDisplay(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFF2E170C),
                                      ),
                                    ),
                                    const SizedBox(height: 2),

                                    // Subtitle: Sadhak • Nitya Karma Marg
                                    Row(
                                      children: [
                                        Text(
                                          'Sadhak',
                                          style: GoogleFonts.outfit(
                                            fontSize: 12.5,
                                            fontWeight: FontWeight.w500,
                                            color: const Color(0xFF7B6B61),
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        const Text('•', style: TextStyle(color: Color(0xFF8C7C72), fontSize: 11)),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Nitya Karma Marg',
                                          style: GoogleFonts.playfairDisplay(
                                            fontSize: 13,
                                            fontStyle: FontStyle.italic,
                                            fontWeight: FontWeight.w600,
                                            color: const Color(0xFF8C3B00),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 14),

                          // Badges Row
                          Row(
                            children: [
                              _buildPillTag('⏰', 'Brahmamuhurta Sadhak'),
                              const SizedBox(width: 8),
                              _buildPillTag('📿', 'Japa Practitioner'),
                            ],
                          ),

                          const SizedBox(height: 14),

                          // Share Devotional Journey Button
                          BouncingTap(
                            onTap: () {},
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: const Color(0xFF8C3B00),
                                borderRadius: BorderRadius.circular(22),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF8C3B00).withValues(alpha: 0.25),
                                    blurRadius: 10,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.share_outlined,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Share Devotional Journey',
                                    style: GoogleFonts.outfit(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 22),

                    // ── Sacred Sadhana Streak Section ────────────────────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Sacred Sadhana Streak',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF2E170C),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFBECE1),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(
                            'Week 7 • Shravana',
                            style: GoogleFonts.outfit(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF8C3B00),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Conscious commitment through unhurried devotion',
                      style: GoogleFonts.outfit(
                        fontSize: 12.5,
                        color: const Color(0xFF7B6B61),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Weekly Lotus Alignment Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFFEDE4D8),
                          width: 1.0,
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.calendar_month_outlined,
                                    size: 16,
                                    color: Color(0xFF8C3B00),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Weekly Lotus Alignment',
                                    style: GoogleFonts.outfit(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF2E170C),
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                '7 of 7 Completed',
                                style: GoogleFonts.outfit(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF8C3B00),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // 7 Days Lotus Badges (Mon - Sun)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              _LotusDay(day: 'Mon'),
                              _LotusDay(day: 'Tue'),
                              _LotusDay(day: 'Wed'),
                              _LotusDay(day: 'Thu'),
                              _LotusDay(day: 'Fri'),
                              _LotusDay(day: 'Sat'),
                              _LotusDay(day: 'Sun'),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ── Two Stats Cards Row ──────────────────────────────────
                    Row(
                      children: [
                        // Card 1: 432 Malas
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: const Color(0xFFEDE4D8),
                                width: 1.0,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.all_inclusive_rounded,
                                  size: 20,
                                  color: Color(0xFF8C3B00),
                                ),
                                const SizedBox(height: 12),
                                RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: '432 ',
                                        style: GoogleFonts.playfairDisplay(
                                          fontSize: 22,
                                          fontWeight: FontWeight.w700,
                                          color: const Color(0xFF2E170C),
                                        ),
                                      ),
                                      TextSpan(
                                        text: 'Malas',
                                        style: GoogleFonts.outfit(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF8C3B00),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Total Japa Chanted',
                                  style: GoogleFonts.outfit(
                                    fontSize: 11.5,
                                    color: const Color(0xFF7B6B61),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Card 2: 1,240 Mins
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: const Color(0xFFEDE4D8),
                                width: 1.0,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.self_improvement_rounded,
                                  size: 20,
                                  color: Color(0xFF8C3B00),
                                ),
                                const SizedBox(height: 12),
                                RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: '1,240 ',
                                        style: GoogleFonts.playfairDisplay(
                                          fontSize: 22,
                                          fontWeight: FontWeight.w700,
                                          color: const Color(0xFF2E170C),
                                        ),
                                      ),
                                      TextSpan(
                                        text: 'Mins',
                                        style: GoogleFonts.outfit(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF8C3B00),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Mindful Sadhana',
                                  style: GoogleFonts.outfit(
                                    fontSize: 11.5,
                                    color: const Color(0xFF7B6B61),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 22),

                    // ── Daily Sadhana Checklist Section ──────────────────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Daily Sadhana Checklist',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF2E170C),
                          ),
                        ),
                        Text(
                          '$_doneCount/4 Done',
                          style: GoogleFonts.outfit(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF8C3B00),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Checklist items
                    _ChecklistItem(
                      icon: Icons.wb_sunny_outlined,
                      title: 'Mangala Darshan',
                      subtitle: 'Witness Ayodhya Ram Mandir morning darshan',
                      isChecked: _checklist[0],
                      onChanged: (v) => setState(() => _checklist[0] = v),
                    ),
                    const SizedBox(height: 10),

                    _ChecklistItem(
                      icon: Icons.spa_outlined,
                      title: 'Gayatri Maha Mantra',
                      subtitle: '108 Sacred repetitions at Amritvela',
                      isChecked: _checklist[1],
                      onChanged: (v) => setState(() => _checklist[1] = v),
                    ),
                    const SizedBox(height: 10),

                    _ChecklistItem(
                      icon: Icons.menu_book_outlined,
                      title: 'Bhagavad Gita Adhyay',
                      subtitle: 'Contemplate Chapter 2, Verse 47',
                      isChecked: _checklist[2],
                      onChanged: (v) => setState(() => _checklist[2] = v),
                    ),
                    const SizedBox(height: 10),

                    _ChecklistItem(
                      icon: Icons.local_fire_department_outlined,
                      title: 'Sandhya Deepam',
                      subtitle: 'Kindle the sacred evening ghee lamp',
                      isChecked: _checklist[3],
                      onChanged: (v) => setState(() => _checklist[3] = v),
                    ),

                    const SizedBox(height: 24),

                    // ── Sacred Milestones Section ────────────────────────────
                    Text(
                      'Sacred Milestones',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF2E170C),
                      ),
                    ),
                    const SizedBox(height: 14),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: const [
                        _MilestoneBadge(
                          icon: Icons.wb_twilight_rounded,
                          title: 'Amritvela',
                          subtitle: 'Early Riser',
                          bgColor: Color(0xFFF7EEDF),
                          iconColor: Color(0xFF8C3B00),
                        ),
                        _MilestoneBadge(
                          icon: Icons.auto_awesome,
                          title: '108 Mala',
                          subtitle: 'Master Chanted',
                          bgColor: Color(0xFFFAECE1),
                          iconColor: Color(0xFF8C3B00),
                        ),
                        _MilestoneBadge(
                          icon: Icons.music_note_rounded,
                          title: 'Sangeet Seeker',
                          subtitle: '50+ Bhajans',
                          bgColor: Color(0xFFF9E4E2),
                          iconColor: Color(0xFF8C3B00),
                        ),
                      ],
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

  Widget _buildPillTag(String emoji, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF2E8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEBE0D2), width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 11)),
          const SizedBox(width: 4),
          Text(
            text,
            style: GoogleFonts.outfit(
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF7B6B61),
            ),
          ),
        ],
      ),
    );
  }
}

class _LotusDay extends StatelessWidget {
  final String day;
  const _LotusDay({required this.day});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: const BoxDecoration(
            color: Color(0xFF8C3B00),
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Icon(
              Icons.spa_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          day,
          style: GoogleFonts.outfit(
            fontSize: 11.5,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF7B6B61),
          ),
        ),
      ],
    );
  }
}

class _ChecklistItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isChecked;
  final ValueChanged<bool> onChanged;

  const _ChecklistItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isChecked,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!isChecked),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: const Color(0xFFEDE4D8),
            width: 1.0,
          ),
        ),
        child: Row(
          children: [
            // Left circular icon
            Container(
              width: 38,
              height: 38,
              decoration: const BoxDecoration(
                color: Color(0xFFFBECE1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  icon,
                  size: 19,
                  color: const Color(0xFF8C3B00),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Title & Subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF2E170C),
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    subtitle,
                    style: GoogleFonts.outfit(
                      fontSize: 11.5,
                      color: const Color(0xFF7B6B61),
                    ),
                  ),
                ],
              ),
            ),

            // Checkbox
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: isChecked ? const Color(0xFF8C3B00) : Colors.transparent,
                borderRadius: BorderRadius.circular(5),
                border: Border.all(
                  color: isChecked ? const Color(0xFF8C3B00) : const Color(0xFF9E8E81),
                  width: 1.5,
                ),
              ),
              child: isChecked
                  ? const Center(
                      child: Icon(
                        Icons.check_rounded,
                        size: 16,
                        color: Colors.white,
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _MilestoneBadge extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color bgColor;
  final Color iconColor;

  const _MilestoneBadge({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.bgColor,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            color: bgColor,
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFFEADBCE),
              width: 1.0,
            ),
          ),
          child: Center(
            child: Icon(
              icon,
              size: 26,
              color: iconColor,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: GoogleFonts.outfit(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF2E170C),
          ),
        ),
        Text(
          subtitle,
          style: GoogleFonts.outfit(
            fontSize: 11,
            color: const Color(0xFF7B6B61),
          ),
        ),
      ],
    );
  }
}
