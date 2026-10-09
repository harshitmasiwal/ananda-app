import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/providers/audio_providers.dart';
import '../../core/providers/content_providers.dart';
import '../../core/services/audio_player_service.dart';
import '../../core/models/bhajan_model.dart';
import 'bouncing_tap.dart';

class MiniAudioPlayer extends ConsumerWidget {
  const MiniAudioPlayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentBhajanAsync = ref.watch(currentBhajanProvider);
    final isPlayingAsync = ref.watch(isPlayingProvider);
    final allBhajansAsync = ref.watch(bhajansProvider);

    final currentBhajan = currentBhajanAsync.valueOrNull ?? AudioPlayerService.instance.currentBhajan;
    final isPlaying = isPlayingAsync.valueOrNull ?? AudioPlayerService.instance.playing;
    final allBhajans = allBhajansAsync.valueOrNull ?? [];

    // If nothing playing yet, use the first bhajan from the actual Cloudinary catalog
    final BhajanModel? activeBhajan = currentBhajan ?? (allBhajans.isNotEmpty ? allBhajans.first : null);

    if (activeBhajan == null) {
      // Nothing loaded yet from Cloudinary
      return const SizedBox.shrink();
    }

    final title = activeBhajan.title;
    final artist = activeBhajan.artist;
    final artworkUrl = activeBhajan.artworkUrl;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFEBE6DC),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: const Color(0xFFDFD8CC),
          width: 0.8,
        ),
      ),
      child: Row(
        children: [
          // Album thumbnail
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              width: 44,
              height: 44,
              child: artworkUrl != null && artworkUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: artworkUrl,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => _buildPlaceholder(),
                      errorWidget: (_, __, ___) => _buildPlaceholder(),
                    )
                  : _buildPlaceholder(),
            ),
          ),
          const SizedBox(width: 10),

          // Title & Singer
          Expanded(
            child: GestureDetector(
              onTap: () => _openFullPlayer(context, activeBhajan, isPlaying, allBhajans),
              behavior: HitTestBehavior.opaque,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.outfit(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF2B1810),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    artist,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.outfit(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF7A6A60),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Playback controls
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Skip Previous
              BouncingTap(
                onTap: () {
                  if (currentBhajan == null) {
                    AudioPlayerService.instance.playBhajan(activeBhajan, queue: allBhajans);
                  } else {
                    AudioPlayerService.instance.skipToPrevious();
                  }
                },
                child: const Padding(
                  padding: EdgeInsets.all(6),
                  child: Icon(
                    Icons.skip_previous_rounded,
                    color: Color(0xFF4A2511),
                    size: 22,
                  ),
                ),
              ),

              // Play / Pause Circle
              BouncingTap(
                onTap: () {
                  if (currentBhajan == null) {
                    // Start playing the active bhajan from Cloudinary
                    AudioPlayerService.instance.playBhajan(activeBhajan, queue: allBhajans);
                  } else {
                    AudioPlayerService.instance.togglePlayPause();
                  }
                },
                child: Container(
                  width: 38,
                  height: 38,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: const BoxDecoration(
                    color: Color(0xFF943E00),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x33943E00),
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),

              // Skip Next
              BouncingTap(
                onTap: () {
                  if (currentBhajan == null) {
                    AudioPlayerService.instance.playBhajan(activeBhajan, queue: allBhajans);
                  } else {
                    AudioPlayerService.instance.skipToNext();
                  }
                },
                child: const Padding(
                  padding: EdgeInsets.all(6),
                  child: Icon(
                    Icons.skip_next_rounded,
                    color: Color(0xFF4A2511),
                    size: 22,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: const Color(0xFFDCCFBD),
      child: const Center(
        child: Icon(
          Icons.music_note_rounded,
          color: Color(0xFF8C5D38),
          size: 22,
        ),
      ),
    );
  }

  void _openFullPlayer(BuildContext context, BhajanModel activeBhajan, bool isPlaying, List<BhajanModel> queue) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _FullPlayerSheet(bhajan: activeBhajan, queue: queue),
    );
  }
}

class _FullPlayerSheet extends ConsumerWidget {
  final BhajanModel bhajan;
  final List<BhajanModel> queue;
  const _FullPlayerSheet({required this.bhajan, required this.queue});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentBhajanAsync = ref.watch(currentBhajanProvider);
    final isPlayingAsync = ref.watch(isPlayingProvider);
    final posAsync = ref.watch(positionProvider);
    final durAsync = ref.watch(durationProvider);

    final currentBhajan = currentBhajanAsync.valueOrNull ?? bhajan;
    final isPlaying = isPlayingAsync.valueOrNull ?? false;
    final position = posAsync.valueOrNull ?? Duration.zero;
    final duration = durAsync.valueOrNull ?? Duration.zero;

    final title = currentBhajan.title;
    final artist = currentBhajan.artist;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: const BoxDecoration(
        color: Color(0xFFFAF7F2),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFD5C8B8),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),

            // Artwork
            Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: const Color(0xFFF3ECE1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: currentBhajan.artworkUrl != null &&
                        currentBhajan.artworkUrl!.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: currentBhajan.artworkUrl!,
                        fit: BoxFit.cover,
                      )
                    : const Center(
                        child: Icon(
                          Icons.spa_rounded,
                          size: 72,
                          color: Color(0xFF943E00),
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 24),

            // Title
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.playfairDisplay(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF2B1810),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              artist,
              style: GoogleFonts.outfit(
                fontSize: 14,
                color: const Color(0xFF7A6A60),
              ),
            ),
            const SizedBox(height: 20),

            // Progress Slider
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: const Color(0xFF943E00),
                inactiveTrackColor: const Color(0xFFE5DDD0),
                thumbColor: const Color(0xFF943E00),
                trackHeight: 3,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              ),
              child: Slider(
                value: duration.inMilliseconds > 0
                    ? position.inMilliseconds.clamp(0, duration.inMilliseconds).toDouble()
                    : 0,
                max: duration.inMilliseconds > 0 ? duration.inMilliseconds.toDouble() : 1,
                onChanged: (val) {
                  AudioPlayerService.instance.seek(Duration(milliseconds: val.toInt()));
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_fmt(position), style: GoogleFonts.outfit(fontSize: 12, color: const Color(0xFF7A6A60))),
                  Text(_fmt(duration), style: GoogleFonts.outfit(fontSize: 12, color: const Color(0xFF7A6A60))),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Controls
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.skip_previous_rounded, size: 36, color: Color(0xFF4A2511)),
                  onPressed: () => AudioPlayerService.instance.skipToPrevious(),
                ),
                const SizedBox(width: 16),
                Container(
                  width: 58,
                  height: 58,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF943E00),
                  ),
                  child: IconButton(
                    icon: Icon(
                      isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                      size: 34,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      if (AudioPlayerService.instance.currentBhajan == null) {
                        AudioPlayerService.instance.playBhajan(currentBhajan, queue: queue);
                      } else {
                        AudioPlayerService.instance.togglePlayPause();
                      }
                    },
                  ),
                ),
                const SizedBox(width: 16),
                IconButton(
                  icon: const Icon(Icons.skip_next_rounded, size: 36, color: Color(0xFF4A2511)),
                  onPressed: () => AudioPlayerService.instance.skipToNext(),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  String _fmt(Duration d) {
    final m = d.inMinutes;
    final s = d.inSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }
}
