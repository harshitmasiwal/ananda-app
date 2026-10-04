import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/providers/language_provider.dart';
import '../../shared/widgets/language_toggle.dart';
import '../wallpapers/wallpapers_screen.dart';
import '../ringtones/ringtones_screen.dart';
import '../horoscope/horoscope_screen.dart';
import '../../shared/widgets/bouncing_tap.dart';

// ─── Daily Shlokas ─────────────────────────────────────────────────────────────
const _shlokas = [
  (
    'कर्मण्येवाधिकारस्ते मा फलेषु कदाचन।',
    'You have the right to perform your duties, but not to the fruits of action.',
    'कर्म करो, फल की चिंता मत करो।',
  ),
  (
    'सत्यं शिवं सुन्दरम्',
    'Truth is God and God is Beauty.',
    'सत्य ही ईश्वर है और ईश्वर ही सौन्दर्य।',
  ),
  (
    'तमसो मा ज्योतिर्गमय',
    'Lead me from darkness to light.',
    'अंधकार से प्रकाश की ओर ले चलो।',
  ),
  (
    'सर्वे भवन्तु सुखिनः',
    'May all beings be happy and free from suffering.',
    'सभी प्राणी सुखी हों।',
  ),
  (
    'यत्र नार्यस्तु पूज्यन्ते, रमन्ते तत्र देवताः',
    'Where women are revered, gods rejoice.',
    'जहाँ नारी का सम्मान होता है, वहाँ देवता निवास करते हैं।',
  ),
  (
    'अहं ब्रह्मास्मि',
    'I am Brahman — the ultimate reality.',
    'मैं ब्रह्म हूँ।',
  ),
  (
    'वसुधैव कुटुम्बकम्',
    'The whole world is one family.',
    'पूरा विश्व एक परिवार है।',
  ),
];

(String, String, String) _todayShloka() {
  final idx = DateTime.now().day % _shlokas.length;
  return _shlokas[idx];
}

// ─── Home Screen ──────────────────────────────────────────────────────────────
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  String _greeting(bool isHindi) {
    final h = DateTime.now().hour;
    if (isHindi) {
      if (h < 12) return AppStrings.morningGreetingHi;
      if (h < 17) return AppStrings.afternoonGreetingHi;
      return AppStrings.eveningGreetingHi;
    }
    if (h < 12) return AppStrings.morningGreeting;
    if (h < 17) return AppStrings.afternoonGreeting;
    return AppStrings.eveningGreeting;
  }

  String _greetingEmoji() {
    final h = DateTime.now().hour;
    if (h < 12) return '🌅';
    if (h < 17) return '☀️';
    return '🌙';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isHindi = ref.watch(isHindiProvider);
    final shloka = _todayShloka();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Curved Header Card (matching Bhajans & Books) ─────────────────
          SliverToBoxAdapter(
            child: _HomeHeader(
              isHindi: isHindi,
              greeting: _greeting(isHindi),
              greetingEmoji: _greetingEmoji(),
            ),
          ),

          // ── Daily Greeting Card ────────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
            sliver: SliverToBoxAdapter(
              child: _GreetingCard(
                isHindi: isHindi,
                shloka: shloka,
              ),
            ),
          ),

          // ── Section label ──────────────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 28, 20, 12),
            sliver: SliverToBoxAdapter(
              child: Row(
                children: [
                  Text(
                    isHindi ? 'सुविधाएँ' : 'Explore',
                    style: AppTextStyles.sectionHeader,
                  ),
                  const Spacer(),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      isHindi ? '6 सुविधाएँ' : '6 Features',
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.primary, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Feature cards (2-column grid) ─────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 1.0,
              ),
              delegate: SliverChildListDelegate([
                _FeatureCard(
                  icon: Icons.wallpaper_rounded,
                  label: isHindi
                      ? AppStrings.wallpapersTitleHi
                      : AppStrings.wallpapersTitle,
                  subtitle: isHindi
                      ? AppStrings.wallpapersDescHi
                      : AppStrings.wallpapersDesc,
                  gradient: AppColors.sectionGradients[0],
                  onTap: () => _push(context, const WallpapersScreen()),
                ),
                _FeatureCard(
                  icon: Icons.music_note_rounded,
                  label: isHindi
                      ? AppStrings.ringtonesTitleHi
                      : AppStrings.ringtonesTitle,
                  subtitle: isHindi
                      ? AppStrings.ringtonesDescHi
                      : AppStrings.ringtonesDesc,
                  gradient: AppColors.sectionGradients[1],
                  onTap: () => _push(context, const RingtonesScreen()),
                ),
                _FeatureCard(
                  icon: Icons.auto_awesome_rounded,
                  label: isHindi
                      ? AppStrings.horoscopeTitleHi
                      : AppStrings.horoscopeTitle,
                  subtitle: isHindi
                      ? AppStrings.horoscopeDescHi
                      : AppStrings.horoscopeDesc,
                  gradient: AppColors.sectionGradients[2],
                  onTap: () => _push(context, const HoroscopeScreen()),
                ),
                _FeatureCard(
                  icon: Icons.calendar_today_rounded,
                  label: isHindi ? 'पंचांग' : 'Panchang',
                  subtitle:
                      isHindi ? 'आज का पंचांग देखें' : 'View today\'s Panchang',
                  gradient: const [Color(0xFF6D4C41), Color(0xFFA1887F)],
                  onTap: () => _push(
                    context,
                    const HoroscopeScreen(showPanchangFirst: true),
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  void _push(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }
}

// ─── Home Header ──────────────────────────────────────────────────────────────
class _HomeHeader extends StatelessWidget {
  final bool isHindi;
  final String greeting;
  final String greetingEmoji;
  const _HomeHeader({
    required this.isHindi,
    required this.greeting,
    required this.greetingEmoji,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.headerGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x38BF360C),
            blurRadius: 18,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 16, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Om circle
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.18),
                      border: Border.all(
                        color: AppColors.gold.withValues(alpha: 0.6),
                        width: 1.5,
                      ),
                    ),
                    child: const Center(
                      child: Text(
                        'ॐ',
                        style: TextStyle(
                          fontSize: 24,
                          color: AppColors.gold,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isHindi ? AppStrings.appNameHi : AppStrings.appName,
                          style: AppTextStyles.appName.copyWith(
                            color: Colors.white,
                            fontSize: 23,
                            fontWeight: FontWeight.w800,
                            shadows: const [
                              Shadow(
                                color: Colors.black45,
                                blurRadius: 10,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Text(greetingEmoji,
                                style: const TextStyle(fontSize: 14)),
                            const SizedBox(width: 6),
                            Text(
                              greeting,
                              style: AppTextStyles.greeting.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                shadows: const [
                                  Shadow(
                                    color: Colors.black38,
                                    blurRadius: 6,
                                    offset: Offset(0, 1),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  LanguageToggle(),
                ],
              ),
              const SizedBox(height: 14),
              // Constant Devotional & Faith Tagline
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.22),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.gold.withValues(alpha: 0.35),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.auto_awesome_rounded,
                      size: 15,
                      color: AppColors.gold,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        isHindi
                            ? 'आस्था, भक्ति और आत्मिक शांति का पावन धाम'
                            : 'Your Daily Sanctuary of Faith, Devotion & Peace',
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.2,
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
    );
  }
}

// ─── Daily Greeting Card ──────────────────────────────────────────────────────
class _GreetingCard extends StatefulWidget {
  final bool isHindi;
  final (String, String, String) shloka;
  const _GreetingCard({required this.isHindi, required this.shloka});

  @override
  State<_GreetingCard> createState() => _GreetingCardState();
}

class _GreetingCardState extends State<_GreetingCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerCtrl;
  late Animation<double> _shimmerAnim;

  @override
  void initState() {
    super.initState();
    _shimmerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _shimmerAnim = Tween<double>(begin: -1.5, end: 1.5).animate(
      CurvedAnimation(parent: _shimmerCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _shimmerCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final weekdays = [
      'Monday', 'Tuesday', 'Wednesday',
      'Thursday', 'Friday', 'Saturday', 'Sunday',
    ];
    final weekdaysHi = [
      'सोमवार', 'मंगलवार', 'बुधवार',
      'गुरुवार', 'शुक्रवार', 'शनिवार', 'रविवार',
    ];
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final dayName = widget.isHindi
        ? weekdaysHi[now.weekday - 1]
        : weekdays[now.weekday - 1];

    return BouncingTap(
      scaleFactor: 0.98,
      onTap: () {},
      child: AnimatedBuilder(
        animation: _shimmerAnim,
        builder: (context, child) {
          return Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFBF360C), Color(0xFFD84315), Color(0xFFE65100)],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFBF360C).withValues(alpha: 0.45),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: child,
          );
        },
      child: Stack(
        children: [
          // Decorative circle top right
          Positioned(
            right: -30,
            top: -30,
            child: Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),
          // Decorative circle bottom left
          Positioned(
            left: -20,
            bottom: -20,
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.06),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Top row: date + om ──────────────────────────────
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Date block
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          dayName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '${now.day} ${months[now.month - 1]}, ${now.year}',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    // Om emblem
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.2),
                        border: Border.all(
                            color: AppColors.gold.withValues(alpha: 0.6),
                            width: 1.5),
                      ),
                      child: const Center(
                        child: Text('ॐ',
                            style: TextStyle(
                                fontSize: 26,
                                color: Colors.white,
                                fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // ── Divider ─────────────────────────────────────────
                Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withValues(alpha: 0.0),
                        Colors.white.withValues(alpha: 0.3),
                        Colors.white.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // ── Sanskrit shloka ─────────────────────────────────
                Text(
                  widget.shloka.$1,
                  style: const TextStyle(
                    color: AppColors.gold,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    fontStyle: FontStyle.italic,
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 10),

                // ── Meaning ─────────────────────────────────────────
                Text(
                  widget.isHindi ? widget.shloka.$3 : widget.shloka.$2,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    height: 1.6,
                    fontWeight: FontWeight.w400,
                  ),
                ),

                const SizedBox(height: 16),

                // ── Bottom: label ───────────────────────────────────
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.auto_awesome_rounded,
                              size: 11, color: AppColors.gold),
                          const SizedBox(width: 5),
                          Text(
                            widget.isHindi
                                ? 'आज का श्लोक'
                                : 'Shloka of the Day',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    const Text('🙏', style: TextStyle(fontSize: 20)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ),
    );
  }
}

// ─── Feature Card ─────────────────────────────────────────────────────────────
class _FeatureCard extends StatefulWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final List<Color> gradient;
  final VoidCallback onTap;

  const _FeatureCard({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.gradient,
    required this.onTap,
  });

  @override
  State<_FeatureCard> createState() => _FeatureCardState();
}

class _FeatureCardState extends State<_FeatureCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.94,
      upperBound: 1.0,
    )..value = 1.0;
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.reverse(),
      onTapUp: (_) {
        _ctrl.forward();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.forward(),
      child: ScaleTransition(
        scale: _ctrl,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: widget.gradient,
            ),
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: widget.gradient.last.withValues(alpha: 0.4),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Decorative circles
              Positioned(
                right: -14,
                top: -14,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                ),
              ),
              Positioned(
                left: -10,
                bottom: -20,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.07),
                  ),
                ),
              ),
              // Content
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Icon container
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.22),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(widget.icon, color: Colors.white, size: 22),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.label,
                            style: AppTextStyles.cardTitle
                                .copyWith(fontSize: 15)),
                        const SizedBox(height: 2),
                        Text(widget.subtitle,
                            style: AppTextStyles.cardSubtitle,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
