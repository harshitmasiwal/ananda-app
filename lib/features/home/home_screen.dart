import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../shared/widgets/anand_header.dart';
import '../../shared/widgets/bouncing_tap.dart';
import '../wallpapers/wallpapers_screen.dart';
import '../holy_books/holy_books_screen.dart';
import '../horoscope/horoscope_screen.dart';
import '../shell/main_shell.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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

            // Scrollable Home Content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 6),

                    // ── Search Bar (Screenshot 3) ────────────────────────────
                    Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: const Color(0xFFEDE4D8),
                          width: 1.0,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.02),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 14),
                          const Icon(
                            Icons.search_rounded,
                            size: 20,
                            color: Color(0xFF8C7C72),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              style: GoogleFonts.outfit(
                                fontSize: 13.5,
                                color: const Color(0xFF2E170C),
                              ),
                              decoration: InputDecoration(
                                isDense: true,
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                filled: false,
                                contentPadding: EdgeInsets.zero,
                                hintText: 'Search Bhajans, Mantras, Aartis...',
                                hintStyle: GoogleFonts.outfit(
                                  fontSize: 13.5,
                                  color: const Color(0xFF9E8E81),
                                ),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.mic_none_rounded,
                              size: 20,
                              color: Color(0xFF8C7C72),
                            ),
                            onPressed: () {},
                          ),
                          const SizedBox(width: 4),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ── Shubh Prabhat Card (Screenshot 3) ────────────────────
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: const Color(0xFFEDE4D8),
                          width: 1.0,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.02),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Top Row: SHUBH PRABHAT + Ekadashi Vrat
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'SHUBH PRABHAT',
                                style: GoogleFonts.outfit(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.2,
                                  color: const Color(0xFF8C3B00),
                                ),
                              ),
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
                                    const Text('🌱', style: TextStyle(fontSize: 11)),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Ekadashi Vrat',
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
                          const SizedBox(height: 6),

                          // Title: Namaste, Devotee
                          Text(
                            'Namaste, Devotee',
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF2E170C),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // 3 Metric Stats with vertical dividers
                          Row(
                            children: [
                              // Col 1: Tithi
                              Expanded(
                                child: _buildPanchangStat(
                                  iconEmoji: '🌅',
                                  label: 'Tithi',
                                  value: 'Shukla 11',
                                ),
                              ),
                              Container(
                                width: 1,
                                height: 32,
                                color: const Color(0xFFEDE4D8),
                              ),
                              // Col 2: Sunrise
                              Expanded(
                                child: _buildPanchangStat(
                                  iconEmoji: '☀️',
                                  label: 'Sunrise',
                                  value: '06:12 AM',
                                ),
                              ),
                              Container(
                                width: 1,
                                height: 32,
                                color: const Color(0xFFEDE4D8),
                              ),
                              // Col 3: Muhurta
                              Expanded(
                                child: _buildPanchangStat(
                                  iconEmoji: '🌙',
                                  label: 'Muhurta',
                                  value: 'Brahma 4:48',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    // ── Today's Sacred Darshan Banner (Screenshot 3) ─────────
                    Container(
                      height: 220,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(22),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            // Background Image
                            Image.network(
                              'https://images.unsplash.com/photo-1590076212555-5c024505f013?w=800&q=80',
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Image.asset(
                                'assets/images/temple_sunset_bg.jpg',
                                fit: BoxFit.cover,
                              ),
                            ),

                            // Dark Gradient Overlay for text readability
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.black.withValues(alpha: 0.15),
                                    Colors.black.withValues(alpha: 0.45),
                                    Colors.black.withValues(alpha: 0.85),
                                  ],
                                  stops: const [0.0, 0.5, 1.0],
                                ),
                              ),
                            ),

                            // Top Left Pill: • TODAY'S SACRED DARSHAN
                            Positioned(
                              top: 14,
                              left: 14,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.92),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 6,
                                      height: 6,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFD32F2F),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      "TODAY'S SACRED DARSHAN",
                                      style: GoogleFonts.outfit(
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.8,
                                        color: const Color(0xFF8C3B00),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // Bottom Content & Play Button
                            Positioned(
                              bottom: 16,
                              left: 16,
                              right: 16,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'AYODHYA RAM MANDIR',
                                          style: GoogleFonts.outfit(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: 1.2,
                                            color: Colors.white70,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'Mangala Aarti Darshan',
                                          style: GoogleFonts.playfairDisplay(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'Begins with consecrated Vedic stutis',
                                          style: GoogleFonts.outfit(
                                            fontSize: 11.5,
                                            color: Colors.white.withValues(alpha: 0.85),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),

                                  // Terracotta Play Circle
                                  BouncingTap(
                                    onTap: () {
                                      // Switch to Sangeet tab to listen to darshan aarti
                                      ref.read(selectedTabProvider.notifier).state = 1;
                                    },
                                    child: Container(
                                      width: 48,
                                      height: 48,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF943E00),
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Color(0x55943E00),
                                            blurRadius: 10,
                                            offset: Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: const Center(
                                        child: Icon(
                                          Icons.play_arrow_rounded,
                                          size: 30,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 22),

                    // ── Sacred Portals Section (Exactly 3 Options: Horoscope, Panchang, Wallpapers) ──
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Sacred Portals',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF2E170C),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // 3 Visible Cards side-by-side
                    Row(
                      children: [
                        // 1. Horoscope
                        Expanded(
                          child: _buildPortalCard(
                            icon: Icons.auto_awesome_rounded,
                            title: 'Horoscope',
                            subtitle: 'Daily Rashi',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const HoroscopeScreen(showPanchangFirst: false),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 10),

                        // 2. Panchang
                        Expanded(
                          child: _buildPortalCard(
                            icon: Icons.calendar_month_rounded,
                            title: 'Panchang',
                            subtitle: 'Tithi & Muhurta',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const HoroscopeScreen(showPanchangFirst: true),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 10),

                        // 3. Wallpapers
                        Expanded(
                          child: _buildPortalCard(
                            icon: Icons.image_outlined,
                            title: 'Wallpapers',
                            subtitle: 'Divine HD',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const WallpapersScreen()),
                              );
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // ── Pavitra Granth Section (Scriptures Only) ──────────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Pavitra Granth',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF2E170C),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const HolyBooksScreen()),
                            );
                          },
                          child: Text(
                            'View All >',
                            style: GoogleFonts.outfit(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF8C3B00),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Single Featured Holy Books Card (Wallpaper removed as requested)
                    BouncingTap(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const HolyBooksScreen()),
                        );
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: const Color(0xFFEDE4D8),
                            width: 1.0,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.02),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 52,
                              height: 52,
                              decoration: const BoxDecoration(
                                color: Color(0xFFFBECE1),
                                shape: BoxShape.circle,
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.menu_book_rounded,
                                  color: Color(0xFF8C3B00),
                                  size: 26,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Sacred Scriptures & PDFs',
                                    style: GoogleFonts.playfairDisplay(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF2E170C),
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    'Read Shrimad Bhagavad Gita, Ramcharitmanas & Vedic Granth offline',
                                    style: GoogleFonts.outfit(
                                      fontSize: 12,
                                      color: const Color(0xFF7B6B61),
                                      height: 1.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              width: 34,
                              height: 34,
                              decoration: const BoxDecoration(
                                color: Color(0xFFFBECE1),
                                shape: BoxShape.circle,
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  size: 14,
                                  color: Color(0xFF8C3B00),
                                ),
                              ),
                            ),
                          ],
                        ),
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

  Widget _buildPanchangStat({
    required String iconEmoji,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(iconEmoji, style: const TextStyle(fontSize: 13)),
            const SizedBox(width: 5),
            Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: 11.5,
                color: const Color(0xFF7B6B61),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.outfit(
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF2E170C),
          ),
        ),
      ],
    );
  }

  Widget _buildPortalCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return BouncingTap(
      onTap: onTap,
      child: Container(
        width: 125,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFFEDE4D8),
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // Circular peach icon container
            Container(
              width: 52,
              height: 52,
              decoration: const BoxDecoration(
                color: Color(0xFFFBECE1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  icon,
                  size: 24,
                  color: const Color(0xFF8C3B00),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: GoogleFonts.outfit(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2E170C),
              ),
            ),
            const SizedBox(height: 1),
            Text(
              subtitle,
              style: GoogleFonts.outfit(
                fontSize: 11,
                color: const Color(0xFF7B6B61),
              ),
            ),
          ],

        ),
      ),
    );
  }
}
