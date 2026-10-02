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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isHindi = ref.watch(isHindiProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Collapsing Header ──────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            stretch: true,
            backgroundColor: AppColors.primary,
            elevation: 0,
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Center(child: LanguageToggle()),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [StretchMode.zoomBackground],
              collapseMode: CollapseMode.parallax,
              background: _HomeHeader(
                isHindi: isHindi,
                greeting: _greeting(isHindi),
              ),
            ),
          ),

          // ── "Namaste" Hero Card ────────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
            sliver: SliverToBoxAdapter(
              child: _NamasteCard(isHindi: isHindi),
            ),
          ),

          // ── Section label ──────────────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 28, 20, 12),
            sliver: SliverToBoxAdapter(
              child: Text(
                isHindi ? 'सुविधाएँ' : 'Explore',
                style: AppTextStyles.sectionHeader,
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
                  label: isHindi ? AppStrings.wallpapersTitleHi : AppStrings.wallpapersTitle,
                  subtitle: isHindi ? AppStrings.wallpapersDescHi : AppStrings.wallpapersDesc,
                  gradient: AppColors.sectionGradients[0],
                  onTap: () => _push(context, const WallpapersScreen()),
                ),
                _FeatureCard(
                  icon: Icons.music_note_rounded,
                  label: isHindi ? AppStrings.ringtonesTitleHi : AppStrings.ringtonesTitle,
                  subtitle: isHindi ? AppStrings.ringtonesDescHi : AppStrings.ringtonesDesc,
                  gradient: AppColors.sectionGradients[1],
                  onTap: () => _push(context, const RingtonesScreen()),
                ),
                _FeatureCard(
                  icon: Icons.auto_awesome_rounded,
                  label: isHindi ? AppStrings.horoscopeTitleHi : AppStrings.horoscopeTitle,
                  subtitle: isHindi ? AppStrings.horoscopeDescHi : AppStrings.horoscopeDesc,
                  gradient: AppColors.sectionGradients[2],
                  onTap: () => _push(context, const HoroscopeScreen()),
                ),
                _FeatureCard(
                  icon: Icons.calendar_today_rounded,
                  label: isHindi ? 'पंचांग' : 'Panchang',
                  subtitle: isHindi ? 'आज का पंचांग' : "Today's Panchang",
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
    Navigator.push(
        context, MaterialPageRoute(builder: (_) => screen));
  }
}

// ─── Home Header (parallax) ───────────────────────────────────────────────────
class _HomeHeader extends StatelessWidget {
  final bool isHindi;
  final String greeting;
  const _HomeHeader({required this.isHindi, required this.greeting});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.headerGradient),
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Row(
              children: [
                // Om circle
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.18),
                    border: Border.all(
                        color: AppColors.gold.withValues(alpha: 0.6),
                        width: 1.5),
                  ),
                  child: const Center(
                    child: Text('ॐ',
                        style: TextStyle(
                            fontSize: 22,
                            color: AppColors.gold,
                            fontWeight: FontWeight.w700)),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isHindi ? AppStrings.appNameHi : AppStrings.appName,
                      style: AppTextStyles.appName,
                    ),
                    Text(greeting, style: AppTextStyles.greeting),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Quick stat pills
            Row(
              children: [
                _StatPill(icon: Icons.headphones_rounded,
                    label: isHindi ? '50+ भजन' : '50+ Bhajans'),
                const SizedBox(width: 8),
                _StatPill(icon: Icons.wallpaper_rounded,
                    label: isHindi ? '100+ वॉलपेपर' : '100+ Wallpapers'),
                const SizedBox(width: 8),
                _StatPill(icon: Icons.menu_book_rounded,
                    label: isHindi ? '20+ ग्रंथ' : '20+ Books'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final IconData icon;
  final String label;
  const _StatPill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: Colors.white.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.gold),
          const SizedBox(width: 4),
          Text(label,
              style: const TextStyle(
                  fontSize: 10,
                  color: Colors.white,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

// ─── Namaste Hero Card ────────────────────────────────────────────────────────
class _NamasteCard extends StatelessWidget {
  final bool isHindi;
  const _NamasteCard({required this.isHindi});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFF6B00), Color(0xFFFFAB40)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          // Left: text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isHindi ? 'नमस्ते 🙏' : 'Namaste 🙏',
                  style: AppTextStyles.appName.copyWith(
                    fontSize: 28,
                    color: Colors.white,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  isHindi
                      ? AppStrings.taglineHi
                      : AppStrings.tagline,
                  style: AppTextStyles.tagline.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Right: praying hands
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.2),
              border: Border.all(
                  color: AppColors.gold.withValues(alpha: 0.5), width: 2),
            ),
            child: const Center(
              child: Text('🙏',
                  style: TextStyle(fontSize: 36)),
            ),
          ),
        ],
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
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.22),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child:
                          Icon(widget.icon, color: Colors.white, size: 22),
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
