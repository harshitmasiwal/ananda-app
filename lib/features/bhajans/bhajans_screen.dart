import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/providers/language_provider.dart';
import '../../core/providers/content_providers.dart';
import '../../core/models/bhajan_model.dart';
import '../../shared/widgets/language_toggle.dart';

class BhajansScreen extends ConsumerWidget {
  const BhajansScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isHindi = ref.watch(isHindiProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // ── App bar area ─────────────────────────────────────────────────
          _BhajansHeader(isHindi: isHindi),

          // ── Now Playing card ─────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: _NowPlayingCard(isHindi: isHindi),
          ),

          // ── Category chips ───────────────────────────────────────────────
          const _CategoryChips(),

          // ── Bhajan list ──────────────────────────────────────────────────
          const Expanded(child: _BhajanList()),
        ],
      ),
    );
  }
}

// ─── Header ───────────────────────────────────────────────────────────────────
class _BhajansHeader extends StatelessWidget {
  final bool isHindi;
  const _BhajansHeader({required this.isHindi});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.saffronGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 16, 20),
          child: Row(
            children: [
              Icon(Icons.headphones_rounded,
                  color: Colors.white.withValues(alpha: 0.9), size: 28),
              const SizedBox(width: 10),
              Text(
                isHindi ? 'भजन' : 'Bhajans',
                style: AppTextStyles.appName.copyWith(
                    fontSize: 24, letterSpacing: 1.0),
              ),
              const Spacer(),
              LanguageToggle(),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Now Playing card ─────────────────────────────────────────────────────────
class _NowPlayingCard extends ConsumerWidget {
  final bool isHindi;
  const _NowPlayingCard({required this.isHindi});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFC62828), Color(0xFFEF5350)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFC62828).withValues(alpha: 0.4),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          // Album art placeholder
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.white.withValues(alpha: 0.18),
              border: Border.all(
                  color: Colors.white.withValues(alpha: 0.35), width: 1.5),
            ),
            child: const Center(
              child:
                  Text('🎵', style: TextStyle(fontSize: 32)),
            ),
          ),
          const SizedBox(width: 16),
          // Track info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isHindi ? 'अभी चल रहा है' : 'Now Playing',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.75),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isHindi ? 'कोई भजन चुनें' : 'Select a bhajan',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  isHindi ? 'भजन श्रेणी चुनें' : 'Tap a track below',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 12),
                // Player controls
                Row(
                  children: [
                    _PlayerBtn(
                        icon: Icons.skip_previous_rounded, onTap: () {}),
                    const SizedBox(width: 8),
                    _PlayPauseBtn(),
                    const SizedBox(width: 8),
                    _PlayerBtn(
                        icon: Icons.skip_next_rounded, onTap: () {}),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PlayerBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _PlayerBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.18),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}

class _PlayPauseBtn extends StatefulWidget {
  @override
  State<_PlayPauseBtn> createState() => _PlayPauseBtnState();
}

class _PlayPauseBtnState extends State<_PlayPauseBtn> {
  bool _playing = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _playing = !_playing),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.92),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 8,
            ),
          ],
        ),
        child: Icon(
          _playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
          color: const Color(0xFFC62828),
          size: 26,
        ),
      ),
    );
  }
}

// ─── Category Chips ───────────────────────────────────────────────────────────
class _CategoryChips extends ConsumerWidget {
  const _CategoryChips();

  static const _cats = [
    ('all', 'सभी', 'All'),
    ('hanuman', 'हनुमान', 'Hanuman'),
    ('shiv', 'शिव', 'Shiv'),
    ('mata-rani', 'माता रानी', 'Mata Rani'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedBhajanCategoryProvider);
    final isHindi = ref.watch(isHindiProvider);

    return SizedBox(
      height: 54,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        scrollDirection: Axis.horizontal,
        itemCount: _cats.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final cat = _cats[i];
          final catKey = cat.$1 == 'all' ? null : cat.$1;
          final isActive = selected == catKey;
          return GestureDetector(
            onTap: () => ref
                .read(selectedBhajanCategoryProvider.notifier)
                .state = catKey,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: isActive
                    ? AppColors.primary
                    : AppColors.cardBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isActive
                      ? AppColors.primaryDark
                      : AppColors.divider,
                  width: 1.5,
                ),
                boxShadow: isActive
                    ? [
                        BoxShadow(
                          color:
                              AppColors.primary.withValues(alpha: 0.35),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : null,
              ),
              child: Text(
                isHindi ? cat.$2 : cat.$3,
                style: TextStyle(
                  color: isActive
                      ? Colors.white
                      : AppColors.textSecondary,
                  fontWeight: isActive
                      ? FontWeight.w700
                      : FontWeight.w500,
                  fontSize: 13,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─── Bhajan List ──────────────────────────────────────────────────────────────
class _BhajanList extends ConsumerWidget {
  const _BhajanList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isHindi = ref.watch(isHindiProvider);
    final asyncBhajans = ref.watch(filteredBhajansProvider);

    return asyncBhajans.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
      error: (e, _) => Center(
        child: Text('Unable to load bhajans',
            style: AppTextStyles.body),
      ),
      data: (bhajans) => bhajans.isEmpty
          ? Center(
              child: Text(
                isHindi ? 'कोई भजन नहीं मिला' : 'No bhajans found',
                style: AppTextStyles.body,
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              itemCount: bhajans.length,
              physics: const BouncingScrollPhysics(),
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) =>
                  _BhajanTile(bhajan: bhajans[i], isHindi: isHindi),
            ),
    );
  }
}

class _BhajanTile extends StatelessWidget {
  final BhajanModel bhajan;
  final bool isHindi;
  const _BhajanTile({required this.bhajan, required this.isHindi});

  static const _catColors = {
    'hanuman': Color(0xFFFF6B00),
    'shiv': Color(0xFF6A1B9A),
    'mata-rani': Color(0xFFC62828),
  };

  @override
  Widget build(BuildContext context) {
    final accent =
        _catColors[bhajan.category] ?? AppColors.primary;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.divider.withValues(alpha: 0.6),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: accent.withValues(alpha: 0.12),
            border: Border.all(
                color: accent.withValues(alpha: 0.3), width: 1),
          ),
          child: Icon(Icons.music_note_rounded, color: accent, size: 22),
        ),
        title: Text(
          isHindi ? bhajan.titleHi : bhajan.title,
          style: AppTextStyles.h3.copyWith(fontSize: 14),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          isHindi ? bhajan.artistHi : bhajan.artist,
          style: AppTextStyles.bodySmall,
          maxLines: 1,
        ),
        trailing: Icon(Icons.play_circle_outline_rounded,
            color: accent, size: 32),
        onTap: () {},
      ),
    );
  }
}
