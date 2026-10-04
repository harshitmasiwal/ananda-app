import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/providers/language_provider.dart';
import '../../core/providers/content_providers.dart';
import '../../core/providers/audio_providers.dart';
import '../../core/models/bhajan_model.dart';
import '../../core/services/audio_player_service.dart';
import '../../shared/widgets/language_toggle.dart';
import '../../shared/widgets/bouncing_tap.dart';

class BhajansScreen extends ConsumerWidget {
  const BhajansScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isHindi = ref.watch(isHindiProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          _BhajansHeader(isHindi: isHindi),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: _NowPlayingCard(isHindi: isHindi),
          ),
          const _CategoryChips(),
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
        gradient: LinearGradient(
          colors: [Color(0xFF4A148C), Color(0xFF6A1B9A), Color(0xFF7B1FA2)],
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
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 16, 20),
          child: Row(
            children: [
              Icon(Icons.headphones_rounded,
                  color: Colors.white.withValues(alpha: 0.9), size: 28),
              const SizedBox(width: 10),
              Text(
                isHindi ? 'भजन' : 'Bhajans',
                style: AppTextStyles.appName
                    .copyWith(fontSize: 24, letterSpacing: 1.0),
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

// ─── Now Playing Card ─────────────────────────────────────────────────────────
class _NowPlayingCard extends ConsumerStatefulWidget {
  final bool isHindi;
  const _NowPlayingCard({required this.isHindi});

  @override
  ConsumerState<_NowPlayingCard> createState() => _NowPlayingCardState();
}

class _NowPlayingCardState extends ConsumerState<_NowPlayingCard>
    with SingleTickerProviderStateMixin {
  double? _draggingValue;
  late AnimationController _vinylCtrl;

  @override
  void initState() {
    super.initState();
    _vinylCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    );
  }

  @override
  void dispose() {
    _vinylCtrl.dispose();
    super.dispose();
  }

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final currentBhajan = ref.watch(currentBhajanProvider).valueOrNull;
    final playerStateAsync = ref.watch(playerStateProvider);
    final positionAsync = ref.watch(positionProvider);
    final durationAsync = ref.watch(durationProvider);
    final shuffleOn = ref.watch(shuffleModeProvider).valueOrNull ?? false;

    final isPlaying = playerStateAsync.valueOrNull?.playing ?? false;
    final processingState =
        playerStateAsync.valueOrNull?.processingState ?? ProcessingState.idle;
    final isLoading = processingState == ProcessingState.loading ||
        processingState == ProcessingState.buffering;
    final position = positionAsync.valueOrNull ?? Duration.zero;
    final duration = durationAsync.valueOrNull ?? Duration.zero;

    // Drive vinyl spin
    if (isPlaying && !_vinylCtrl.isAnimating) {
      _vinylCtrl.repeat();
    } else if (!isPlaying && _vinylCtrl.isAnimating) {
      _vinylCtrl.stop();
    }

    final sliderMax = duration.inMilliseconds.toDouble();
    final sliderValue = _draggingValue ??
        (sliderMax > 0
            ? position.inMilliseconds.toDouble().clamp(0.0, sliderMax)
            : 0.0);

    final hasTrack = currentBhajan != null;
    final displayTitle = hasTrack
        ? (widget.isHindi && currentBhajan.titleHi.isNotEmpty
            ? currentBhajan.titleHi
            : currentBhajan.title)
        : (widget.isHindi ? 'कोई भजन चुनें' : 'Select a bhajan');
    final displaySub = hasTrack
        ? currentBhajan.category
        : (widget.isHindi ? 'नीचे से चुनें' : 'Tap a track below');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4A148C), Color(0xFF7B1FA2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4A148C).withValues(alpha: 0.45),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── Top row: vinyl + track info + shuffle ─────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Spinning vinyl disc
              RotationTransition(
                turns: _vinylCtrl,
                child: _VinylDisc(isLoading: isLoading),
              ),
              const SizedBox(width: 14),
              // Track info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        widget.isHindi ? 'अभी चल रहा है' : 'NOW PLAYING',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      displayTitle,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Icon(Icons.category_rounded,
                            size: 11,
                            color: Colors.white.withValues(alpha: 0.6)),
                        const SizedBox(width: 4),
                        Text(
                          displaySub,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Shuffle button
              GestureDetector(
                onTap: () => AudioPlayerService.instance.toggleShuffle(),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: shuffleOn
                        ? Colors.white.withValues(alpha: 0.25)
                        : Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: shuffleOn
                        ? Border.all(
                            color: Colors.white.withValues(alpha: 0.5),
                            width: 1)
                        : null,
                  ),
                  child: Icon(
                    Icons.shuffle_rounded,
                    color: Colors.white
                        .withValues(alpha: shuffleOn ? 1.0 : 0.5),
                    size: 20,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // ── Seek slider ───────────────────────────────────────────────────
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 3.5,
              thumbShape:
                  const RoundSliderThumbShape(enabledThumbRadius: 6),
              overlayShape:
                  const RoundSliderOverlayShape(overlayRadius: 14),
              activeTrackColor: Colors.white,
              inactiveTrackColor: Colors.white.withValues(alpha: 0.25),
              thumbColor: Colors.white,
              overlayColor: Colors.white.withValues(alpha: 0.15),
            ),
            child: Slider(
              min: 0,
              max: sliderMax > 0 ? sliderMax : 1,
              value: sliderValue.clamp(0.0, sliderMax > 0 ? sliderMax : 1),
              onChangeStart: hasTrack ? (_) => setState(() {}) : null,
              onChanged:
                  hasTrack ? (v) => setState(() => _draggingValue = v) : null,
              onChangeEnd: hasTrack
                  ? (v) {
                      AudioPlayerService.instance
                          .seekTo(Duration(milliseconds: v.toInt()));
                      setState(() => _draggingValue = null);
                    }
                  : null,
            ),
          ),

          // ── Time labels ───────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _fmt(_draggingValue != null
                      ? Duration(milliseconds: _draggingValue!.toInt())
                      : position),
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 11,
                      fontWeight: FontWeight.w600),
                ),
                Text(
                  _fmt(duration),
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 11),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // ── Controls ──────────────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _ControlBtn(
                icon: Icons.skip_previous_rounded,
                size: 30,
                enabled: hasTrack,
                onTap: () => AudioPlayerService.instance.skipPrev(),
              ),
              const SizedBox(width: 12),
              _ControlBtn(
                icon: Icons.replay_10_rounded,
                size: 26,
                enabled: hasTrack,
                onTap: () {
                  final np = position - const Duration(seconds: 10);
                  AudioPlayerService.instance
                      .seekTo(np < Duration.zero ? Duration.zero : np);
                },
              ),
              const SizedBox(width: 16),
              // Big play/pause
              BouncingTap(
                onTap: hasTrack
                    ? () => AudioPlayerService.instance.togglePlayPause()
                    : null,
                scaleFactor: 0.92,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: hasTrack
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.4),
                    shape: BoxShape.circle,
                    boxShadow: hasTrack
                        ? [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            )
                          ]
                        : null,
                  ),
                  child: isLoading
                      ? const Center(
                          child: SizedBox(
                            width: 26,
                            height: 26,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Color(0xFF4A148C),
                            ),
                          ),
                        )
                      : Icon(
                          isPlaying
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          color: const Color(0xFF4A148C),
                          size: 32,
                        ),
                ),
              ),
              const SizedBox(width: 16),
              _ControlBtn(
                icon: Icons.forward_10_rounded,
                size: 26,
                enabled: hasTrack,
                onTap: () {
                  final np = position + const Duration(seconds: 10);
                  AudioPlayerService.instance.seekTo(
                      duration > Duration.zero && np > duration ? duration : np);
                },
              ),
              const SizedBox(width: 12),
              _ControlBtn(
                icon: Icons.skip_next_rounded,
                size: 30,
                enabled: hasTrack,
                onTap: () => AudioPlayerService.instance.skipNext(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Vinyl Disc Widget ────────────────────────────────────────────────────────
class _VinylDisc extends StatelessWidget {
  final bool isLoading;
  const _VinylDisc({required this.isLoading});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 68,
      height: 68,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const RadialGradient(
          colors: [Color(0xFF424242), Color(0xFF212121), Colors.black],
          stops: [0.3, 0.6, 1.0],
        ),
        border:
            Border.all(color: Colors.white.withValues(alpha: 0.25), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          ...List.generate(3, (i) {
            final r = 10.0 + i * 8.0;
            return Container(
              width: r * 2,
              height: r * 2,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                    color: Colors.white.withValues(alpha: 0.06), width: 1),
              ),
            );
          }),
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isLoading ? Colors.amber.shade700 : AppColors.gold,
            ),
            child: Center(
              child: isLoading
                  ? const SizedBox(
                      width: 10,
                      height: 10,
                      child: CircularProgressIndicator(
                        strokeWidth: 1.5,
                        color: Colors.white,
                      ),
                    )
                  : const Text('ॐ',
                      style: TextStyle(
                          fontSize: 10,
                          color: Colors.white,
                          fontWeight: FontWeight.w900)),
            ),
          ),
        ],
      ),
    );
  }
}

class _ControlBtn extends StatelessWidget {
  final IconData icon;
  final double size;
  final bool enabled;
  final VoidCallback onTap;
  const _ControlBtn({
    required this.icon,
    required this.size,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BouncingTap(
      onTap: enabled ? onTap : null,
      scaleFactor: 0.88,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: enabled ? 0.15 : 0.06),
          shape: BoxShape.circle,
        ),
        child: Icon(icon,
            color: Colors.white.withValues(alpha: enabled ? 1.0 : 0.3),
            size: size),
      ),
    );
  }
}

// ─── Category Chips (dynamic from catalog) ────────────────────────────────────
class _CategoryChips extends ConsumerWidget {
  const _CategoryChips();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedBhajanCategoryProvider);
    final isHindi = ref.watch(isHindiProvider);
    final asyncBhajans = ref.watch(bhajansProvider);

    // Build dynamic category list from catalog
    final allBhajans = asyncBhajans.valueOrNull ?? [];
    final dynamicCats = allBhajans.map((b) => b.category).toSet().toList();

    // Hindi labels for known categories
    const hiLabels = {
      'hanuman': 'हनुमान',
      'shiv': 'शिव',
      'mata-rani': 'माता रानी',
      'general': 'सामान्य',
    };

    return SizedBox(
      height: 54,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        scrollDirection: Axis.horizontal,
        children: [
          // "All" chip always first
          _CategoryChip(
            label: isHindi ? 'सभी' : 'All',
            isActive: selected == null,
            onTap: () =>
                ref.read(selectedBhajanCategoryProvider.notifier).state =
                    null,
          ),
          ...dynamicCats.map((cat) {
            final hiLabel = hiLabels[cat] ?? cat;
            return Padding(
              padding: const EdgeInsets.only(left: 8),
              child: _CategoryChip(
                label: isHindi ? hiLabel : _capitalize(cat),
                isActive: selected == cat,
                onTap: () =>
                    ref.read(selectedBhajanCategoryProvider.notifier).state =
                        cat,
              ),
            );
          }),
        ],
      ),
    );
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1).replaceAll('-', ' ');
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  const _CategoryChip(
      {required this.label, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return BouncingTap(
      onTap: onTap,
      scaleFactor: 0.92,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF6A1B9A) : AppColors.cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? const Color(0xFF4A148C) : AppColors.divider,
            width: 1.5,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: const Color(0xFF6A1B9A).withValues(alpha: 0.35),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : AppColors.textSecondary,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            fontSize: 13,
          ),
        ),
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
        child: Text('Unable to load bhajans', style: AppTextStyles.body),
      ),
      data: (bhajans) => bhajans.isEmpty
          ? Center(
              child: Text(
                isHindi ? 'कोई भजन नहीं मिला' : 'No bhajans found',
                style: AppTextStyles.body,
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
              itemCount: bhajans.length,
              physics: const BouncingScrollPhysics(),
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) => _BhajanTile(
                bhajan: bhajans[i],
                queue: bhajans,
                isHindi: isHindi,
              ),
            ),
    );
  }
}

// ─── Bhajan Tile ──────────────────────────────────────────────────────────────
class _BhajanTile extends ConsumerWidget {
  final BhajanModel bhajan;
  final List<BhajanModel> queue; // current filtered list = playback queue
  final bool isHindi;
  const _BhajanTile({
    required this.bhajan,
    required this.queue,
    required this.isHindi,
  });

  static const _catColors = {
    'hanuman': Color(0xFFFF6B00),
    'shiv': Color(0xFF7B1FA2),
    'mata-rani': Color(0xFFC62828),
    'general': AppColors.primary,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Stream-driven: updates automatically on skip/auto-advance
    final currentBhajan = ref.watch(currentBhajanProvider).valueOrNull;
    final isPlaying = ref.watch(isPlayingProvider).valueOrNull ?? false;
    final isCurrent = currentBhajan?.id == bhajan.id;
    final accent = _catColors[bhajan.category] ?? AppColors.primary;

    return BouncingTap(
      onTap: () {
        // Pass the full visible queue so sequential/shuffle playback works
        AudioPlayerService.instance.playBhajan(bhajan, queue: queue);
      },
      scaleFactor: 0.97,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isCurrent
              ? accent.withValues(alpha: 0.08)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isCurrent
                ? accent.withValues(alpha: 0.45)
                : Colors.transparent,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.divider.withValues(alpha: 0.5),
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
              color: accent.withValues(alpha: isCurrent ? 0.2 : 0.1),
              border: Border.all(
                  color: accent.withValues(alpha: isCurrent ? 0.5 : 0.25),
                  width: 1),
            ),
            child: Icon(
              isCurrent && isPlaying
                  ? Icons.equalizer_rounded
                  : Icons.music_note_rounded,
              color: accent,
              size: 22,
            ),
          ),
          title: Text(
            isHindi && bhajan.titleHi.isNotEmpty
                ? bhajan.titleHi
                : bhajan.title,
            style: AppTextStyles.h3.copyWith(
              fontSize: 14,
              color: isCurrent ? accent : null,
              fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 3),
            child: Container(
              alignment: Alignment.centerLeft,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  bhajan.category,
                  style: TextStyle(
                    color: accent,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          trailing: isCurrent
              ? Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: accent,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: accent.withValues(alpha: 0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Icon(
                    isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                )
              : Icon(Icons.play_circle_outline_rounded,
                  color: accent.withValues(alpha: 0.7), size: 32),
        ),
      ),
    );
  }
}
