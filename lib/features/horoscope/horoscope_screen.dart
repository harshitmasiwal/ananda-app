import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/providers/language_provider.dart';
import '../../shared/widgets/language_toggle.dart';

class HoroscopeScreen extends ConsumerStatefulWidget {
  final bool showPanchangFirst;
  const HoroscopeScreen({super.key, this.showPanchangFirst = false});

  @override
  ConsumerState<HoroscopeScreen> createState() => _HoroscopeScreenState();
}

class _HoroscopeScreenState extends ConsumerState<HoroscopeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedSign = 'aries';

  static const _signs = [
    ('aries', '♈', 'Aries', 'मेष'),
    ('taurus', '♉', 'Taurus', 'वृषभ'),
    ('gemini', '♊', 'Gemini', 'मिथुन'),
    ('cancer', '♋', 'Cancer', 'कर्क'),
    ('leo', '♌', 'Leo', 'सिंह'),
    ('virgo', '♍', 'Virgo', 'कन्या'),
    ('libra', '♎', 'Libra', 'तुला'),
    ('scorpio', '♏', 'Scorpio', 'वृश्चिक'),
    ('sagittarius', '♐', 'Sagittarius', 'धनु'),
    ('capricorn', '♑', 'Capricorn', 'मकर'),
    ('aquarius', '♒', 'Aquarius', 'कुंभ'),
    ('pisces', '♓', 'Pisces', 'मीन'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.showPanchangFirst ? 0 : 1,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isHindi = ref.watch(isHindiProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // ── Header ──────────────────────────────────────────────────────
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(28),
                bottomRight: Radius.circular(28),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  // Title row
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 16, 0),
                    child: Row(
                      children: [
                        const Icon(Icons.auto_awesome_rounded,
                            color: Colors.white, size: 26),
                        const SizedBox(width: 10),
                        Text(
                          isHindi
                              ? 'ज्योतिष और पंचांग'
                              : 'Astro & Panchang',
                          style: AppTextStyles.appName.copyWith(
                              fontSize: 22, letterSpacing: 0.5),
                        ),
                        const Spacer(),
                        LanguageToggle(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Tab bar
                  TabBar(
                    controller: _tabController,
                    indicatorColor: AppColors.gold,
                    indicatorWeight: 3,
                    labelColor: Colors.white,
                    unselectedLabelColor:
                        Colors.white.withValues(alpha: 0.6),
                    labelStyle: AppTextStyles.h3
                        .copyWith(color: Colors.white, fontSize: 14),
                    tabs: [
                      Tab(text: isHindi ? 'पंचांग' : 'Panchang'),
                      Tab(text: isHindi ? 'राशिफल' : 'Horoscope'),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ── Tab views ───────────────────────────────────────────────────
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _PanchangTab(isHindi: isHindi),
                _HoroscopeTab(
                  isHindi: isHindi,
                  signs: _signs,
                  selectedSign: _selectedSign,
                  onSignChanged: (s) => setState(() => _selectedSign = s),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Panchang Tab ─────────────────────────────────────────────────────────────
class _PanchangTab extends StatelessWidget {
  final bool isHindi;
  const _PanchangTab({required this.isHindi});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final weekdays = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday',
      'Friday', 'Saturday', 'Sunday'
    ];
    final weekdaysHi = [
      'सोमवार', 'मंगलवार', 'बुधवार', 'गुरुवार',
      'शुक्रवार', 'शनिवार', 'रविवार'
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1565C0).withValues(alpha: 0.35),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  '☀️',
                  style: const TextStyle(fontSize: 40),
                ),
                const SizedBox(height: 8),
                Text(
                  isHindi
                      ? 'आज का पंचांग'
                      : "Today's Panchang",
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isHindi
                      ? weekdaysHi[(now.weekday - 1) % 7]
                      : weekdays[(now.weekday - 1) % 7],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '${now.day} / ${now.month} / ${now.year}',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          Text(
            isHindi ? 'पंचांग विवरण' : 'Panchang Details',
            style: AppTextStyles.sectionHeader,
          ),
          const SizedBox(height: 12),

          // Panchang detail rows
          ..._panchangItems(isHindi).map(
            (item) => _PanchangRow(
              label: item.$1,
              value: item.$2,
              icon: item.$3,
            ),
          ),

          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.divider),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded,
                    color: AppColors.primaryLight, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    isHindi
                        ? 'पूर्ण पंचांग जल्द उपलब्ध होगा। कृपया प्रतीक्षा करें।'
                        : 'Full Panchang data coming soon. API integration in Phase 7.',
                    style: AppTextStyles.bodySmall,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<(String, String, IconData)> _panchangItems(bool isHindi) => [
        (isHindi ? 'तिथि' : 'Tithi', isHindi ? 'शुक्ल पक्ष' : 'Shukla Paksha', Icons.brightness_2_rounded),
        (isHindi ? 'नक्षत्र' : 'Nakshatra', isHindi ? 'रोहिणी' : 'Rohini', Icons.star_rounded),
        (isHindi ? 'योग' : 'Yoga', isHindi ? 'सिद्धि' : 'Siddhi', Icons.auto_fix_high_rounded),
        (isHindi ? 'करण' : 'Karan', isHindi ? 'बव' : 'Bava', Icons.circle_outlined),
        (isHindi ? 'वार' : 'Var', isHindi ? 'शुक्रवार' : 'Friday', Icons.calendar_today_rounded),
        (isHindi ? 'राहु काल' : 'Rahu Kaal', '10:30 – 12:00', Icons.do_not_disturb_on_rounded),
      ];
}

class _PanchangRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _PanchangRow({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFF1565C0).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFF1565C0), size: 18),
          ),
          const SizedBox(width: 12),
          Text(label,
              style: AppTextStyles.body
                  .copyWith(color: AppColors.textSecondary)),
          const Spacer(),
          Text(value,
              style: AppTextStyles.h3.copyWith(
                  fontSize: 14, color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}

// ─── Horoscope Tab ────────────────────────────────────────────────────────────
class _HoroscopeTab extends StatelessWidget {
  final bool isHindi;
  final List<(String, String, String, String)> signs;
  final String selectedSign;
  final ValueChanged<String> onSignChanged;

  const _HoroscopeTab({
    required this.isHindi,
    required this.signs,
    required this.selectedSign,
    required this.onSignChanged,
  });

  @override
  Widget build(BuildContext context) {
    final selected =
        signs.firstWhere((s) => s.$1 == selectedSign, orElse: () => signs[0]);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isHindi ? 'राशि चुनें' : 'Choose Your Sign',
            style: AppTextStyles.sectionHeader,
          ),
          const SizedBox(height: 12),

          // Zodiac grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1.0,
            ),
            itemCount: signs.length,
            itemBuilder: (_, i) {
              final sign = signs[i];
              final isActive = sign.$1 == selectedSign;
              return GestureDetector(
                onTap: () => onSignChanged(sign.$1),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: isActive
                        ? AppColors.primary
                        : AppColors.cardBg,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isActive
                          ? AppColors.primaryDark
                          : AppColors.divider,
                      width: 1.5,
                    ),
                    boxShadow: isActive
                        ? [
                            BoxShadow(
                              color: AppColors.primary
                                  .withValues(alpha: 0.35),
                              blurRadius: 8,
                            ),
                          ]
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(sign.$2,
                          style: const TextStyle(fontSize: 22)),
                      const SizedBox(height: 2),
                      Text(
                        isHindi ? sign.$4 : sign.$3,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: isActive
                              ? Colors.white
                              : AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 24),

          // Horoscope result card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1565C0).withValues(alpha: 0.35),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(selected.$2,
                        style: const TextStyle(fontSize: 32)),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isHindi ? selected.$4 : selected.$3,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          isHindi ? 'आज का राशिफल' : "Today's Horoscope",
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    isHindi
                        ? 'राशिफल डेटा लोड हो रहा है... API Phase 7 में एकीकृत किया जाएगा।'
                        : 'Horoscope data will be fetched live from API-Ninjas in Phase 7. Your zodiac sign is selected — stay tuned!',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
