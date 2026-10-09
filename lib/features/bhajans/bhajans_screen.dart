import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/constants/app_colors.dart';
import '../../core/providers/content_providers.dart';
import '../../core/providers/audio_providers.dart';
import '../../core/models/bhajan_model.dart';
import '../../core/services/audio_player_service.dart';
import '../../shared/widgets/anand_header.dart';
import '../../shared/widgets/bouncing_tap.dart';
import '../../core/services/cloudinary_service.dart';

class BhajansScreen extends ConsumerStatefulWidget {
  const BhajansScreen({super.key});

  @override
  ConsumerState<BhajansScreen> createState() => _BhajansScreenState();
}

class _BhajansScreenState extends ConsumerState<BhajansScreen> {
  String _selectedCategory = 'All';

  final List<String> _categories = [
    'All',
    'Shiv',
    'Mata Rani',
    'Ganesh',
    'Hanuman Ji',
  ];

  @override
  Widget build(BuildContext context) {
    final catalogAsync = ref.watch(catalogProvider);
    final currentBhajanAsync = ref.watch(currentBhajanProvider);
    final isPlayingAsync = ref.watch(isPlayingProvider);

    final currentBhajan = currentBhajanAsync.valueOrNull ?? AudioPlayerService.instance.currentBhajan;
    final isPlaying = isPlayingAsync.valueOrNull ?? false;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Top App Bar
            const AnandHeader(),

            // Screen Header title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  Text(
                    'Sangeet & Sacred Media',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF2E170C),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),

            // Horizontal Categories Filter Chips
            SizedBox(
              height: 38,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final cat = _categories[index];
                  final isSelected = cat == _selectedCategory;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedCategory = cat),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF8C3B00) : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? const Color(0xFF8C3B00) : const Color(0xFFE8DFD3),
                          width: 1.0,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          cat,
                          style: GoogleFonts.outfit(
                            fontSize: 12.5,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: isSelected ? Colors.white : const Color(0xFF7B6B61),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),

            // Main Content Area based on Category
            Expanded(
              child: _buildCategoryContent(
                catalogAsync: catalogAsync,
                currentBhajan: currentBhajan,
                isPlaying: isPlaying,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryContent({
    required AsyncValue<AppCatalog> catalogAsync,
    required BhajanModel? currentBhajan,
    required bool isPlaying,
  }) {
    return catalogAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: Color(0xFF8C3B00)),
      ),
      error: (err, _) => Center(
        child: Text(
          'Error loading sacred media: $err',
          style: GoogleFonts.outfit(color: const Color(0xFF7B6B61)),
        ),
      ),
      data: (catalog) {
        final bhajans = catalog.bhajans.where((b) {
          if (_selectedCategory == 'All') return true;
          final cat = b.category.toLowerCase().replaceAll('-', '_');
          final title = b.title.toLowerCase();
          if (_selectedCategory == 'Shiv') {
            return cat.contains('shiv') || title.contains('shiv') || title.contains('mahadev');
          }
          if (_selectedCategory == 'Mata Rani') {
            return cat.contains('mata') || cat.contains('devi') || title.contains('maa') || title.contains('ambe') || title.contains('durga');
          }
          if (_selectedCategory == 'Ganesh') {
            return cat.contains('ganesh') || title.contains('ganesh') || title.contains('ganpati');
          }
          if (_selectedCategory == 'Hanuman Ji') {
            return cat.contains('hanuman') || cat.contains('bajrang') || title.contains('hanuman') || title.contains('bajrang');
          }
          return true;
        }).toList();

        if (bhajans.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.music_off_rounded, size: 48, color: Color(0xFFD4C7BA)),
                const SizedBox(height: 12),
                Text(
                  'No tracks currently found for $_selectedCategory',
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    color: const Color(0xFF7B6B61),
                  ),
                ),
              ],
            ),
          );
        }

        final displayList = bhajans;

        return ListView.builder(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 120, top: 4),
          itemCount: displayList.length,
          itemBuilder: (context, index) {
            final track = displayList[index];
            final isCurrent = currentBhajan?.id == track.id;
            final isTrackPlaying = isCurrent && isPlaying;

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isCurrent ? const Color(0xFF8C3B00) : const Color(0xFFEDE4D8),
                  width: isCurrent ? 1.5 : 1.0,
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
                  // Artwork
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      width: 54,
                      height: 54,
                      color: const Color(0xFFFBECE1),
                      child: track.artworkUrl != null && track.artworkUrl!.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: track.artworkUrl!,
                              fit: BoxFit.cover,
                              errorWidget: (_, __, ___) => const Center(
                                child: Icon(Icons.music_note_rounded, color: Color(0xFF8C3B00)),
                              ),
                            )
                          : const Center(
                              child: Icon(Icons.music_note_rounded, color: Color(0xFF8C3B00)),
                            ),
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Track Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          track.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.outfit(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w600,
                            color: isCurrent ? const Color(0xFF8C3B00) : const Color(0xFF2E170C),
                          ),
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            Text(
                              track.artist,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.outfit(
                                fontSize: 12,
                                color: const Color(0xFF7B6B61),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFAF2E8),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                track.category.toUpperCase(),
                                style: GoogleFonts.outfit(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF8C3B00),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Play / Pause Button
                  BouncingTap(
                    onTap: () {
                      AudioPlayerService.instance.playBhajan(track, queue: displayList);
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isTrackPlaying ? const Color(0xFF8C3B00) : const Color(0xFFFBECE1),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Icon(
                          isTrackPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                          size: 22,
                          color: isTrackPlaying ? Colors.white : const Color(0xFF8C3B00),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
