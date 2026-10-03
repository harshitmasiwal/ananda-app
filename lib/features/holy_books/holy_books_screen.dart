import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:path_provider/path_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/providers/language_provider.dart';
import '../../core/providers/content_providers.dart';
import '../../core/models/holy_book_model.dart';
import '../../shared/widgets/language_toggle.dart';
import 'pdf_reader_screen.dart';

// ─── Book Tabs ────────────────────────────────────────────────────────────────
enum HolyBookTab { all, downloaded }

final selectedBookTabProvider =
    StateProvider<HolyBookTab>((ref) => HolyBookTab.all);

final downloadedBookIdsProvider =
    StateNotifierProvider<DownloadedBooksNotifier, Set<String>>((ref) {
  return DownloadedBooksNotifier();
});

class DownloadedBooksNotifier extends StateNotifier<Set<String>> {
  DownloadedBooksNotifier() : super({}) {
    refresh();
  }

  Future<void> refresh() async {
    final downloaded = <String>{};
    try {
      final docDir = await getApplicationDocumentsDirectory();
      final extDir = await getExternalStorageDirectory();

      for (final id in ['hb1', 'hb2', 'holybook_1', 'holybook_2']) {
        if (File('${docDir.path}/${id}_scripture.pdf').existsSync()) {
          downloaded.add(id);
        } else if (extDir != null &&
            File('${extDir.path}/${id}_scripture.pdf').existsSync()) {
          downloaded.add(id);
        }
      }

      if (docDir.existsSync()) {
        for (final entity in docDir.listSync()) {
          if (entity is File && entity.path.endsWith('_scripture.pdf')) {
            final fileName = entity.uri.pathSegments.last;
            final id = fileName.replaceAll('_scripture.pdf', '');
            downloaded.add(id);
          }
        }
      }
    } catch (_) {}
    state = downloaded;
  }

  void add(String bookId) {
    state = {...state, bookId};
  }

  void remove(String bookId) {
    state = state.where((id) => id != bookId).toSet();
  }
}

class HolyBooksScreen extends ConsumerWidget {
  const HolyBooksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isHindi = ref.watch(isHindiProvider);
    final asyncBooks = ref.watch(holyBooksProvider);
    final selectedTab = ref.watch(selectedBookTabProvider);
    final downloadedIds = ref.watch(downloadedBookIdsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // ── Header ──────────────────────────────────────────────────────
          _BooksHeader(isHindi: isHindi),

          // ── Two Side Options: All Books vs Downloaded Books ───────────────
          _BooksTabSelector(
            selectedTab: selectedTab,
            downloadedCount: downloadedIds.length,
            isHindi: isHindi,
          ),

          // ── Content ──────────────────────────────────────────────────────
          Expanded(
            child: asyncBooks.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
              error: (_, __) => Center(
                child: Text('Unable to load books', style: AppTextStyles.body),
              ),
              data: (books) {
                final displayBooks = selectedTab == HolyBookTab.all
                    ? books
                    : books.where((b) => downloadedIds.contains(b.id)).toList();

                if (selectedTab == HolyBookTab.downloaded &&
                    displayBooks.isEmpty) {
                  return _EmptyDownloadedView(
                    isHindi: isHindi,
                    onExploreAll: () => ref
                        .read(selectedBookTabProvider.notifier)
                        .state = HolyBookTab.all,
                  );
                }

                if (displayBooks.isEmpty) {
                  return Center(
                    child: Text(
                      isHindi ? 'कोई ग्रंथ उपलब्ध नहीं' : 'No books available',
                      style: AppTextStyles.body,
                    ),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                  physics: const BouncingScrollPhysics(),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: 0.7,
                  ),
                  itemCount: displayBooks.length,
                  itemBuilder: (_, i) => _BookCard(
                    book: displayBooks[i],
                    isHindi: isHindi,
                    isDownloaded: downloadedIds.contains(displayBooks[i].id),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Header ───────────────────────────────────────────────────────────────────
class _BooksHeader extends StatelessWidget {
  final bool isHindi;
  const _BooksHeader({required this.isHindi});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF2E7D32), Color(0xFF66BB6A)],
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
              Icon(Icons.menu_book_rounded,
                  color: Colors.white.withValues(alpha: 0.9), size: 28),
              const SizedBox(width: 10),
              Text(
                isHindi ? 'पवित्र ग्रंथ' : 'Holy Books',
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

// ─── Book Card ────────────────────────────────────────────────────────────────
// ─── Book Card ────────────────────────────────────────────────────────────────
class _BookCard extends ConsumerWidget {
  final HolyBookModel book;
  final bool isHindi;
  final bool isDownloaded;

  const _BookCard({
    required this.book,
    required this.isHindi,
    this.isDownloaded = false,
  });

  void _openPdfReader(BuildContext context, WidgetRef ref) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PdfReaderScreen(book: book, isHindi: isHindi),
      ),
    );
    ref.read(downloadedBookIdsProvider.notifier).refresh();
  }

  void _showBookSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _BookDetailSheet(book: book, isHindi: isHindi),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => _openPdfReader(context, ref),
      onLongPress: () => _showBookSheet(context),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover image (takes ~65% of card)
            Expanded(
              flex: 6,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: book.coverUrl,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(
                      color: AppColors.cardBg,
                      child: const Center(
                        child: Icon(Icons.menu_book_rounded,
                            color: AppColors.primaryLight, size: 40),
                      ),
                    ),
                    errorWidget: (_, __, ___) => Container(
                      color: AppColors.cardBg,
                      child: const Center(
                        child: Icon(Icons.menu_book_rounded,
                            color: AppColors.primary, size: 36),
                      ),
                    ),
                  ),
                  // gradient overlay at bottom of image
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.4),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  // PDF badge on top-right
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2E7D32),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: const Text('PDF',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w700)),
                    ),
                  ),
                  // Offline/Downloaded badge on top-left
                  if (isDownloaded)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1B5E20),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.offline_pin_rounded,
                              size: 11,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              isHindi ? 'ऑफलाइन' : 'Offline',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Title & Author
            Expanded(
              flex: 2,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      isHindi ? book.titleHi : book.title,
                      style: AppTextStyles.h3.copyWith(fontSize: 13),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (book.author.isNotEmpty)
                      Text(
                        isHindi ? book.authorHi : book.author,
                        style: AppTextStyles.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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

// ─── Top Tabs: All Books vs Downloaded ───────────────────────────────────────
class _BooksTabSelector extends ConsumerWidget {
  final HolyBookTab selectedTab;
  final int downloadedCount;
  final bool isHindi;

  const _BooksTabSelector({
    required this.selectedTab,
    required this.downloadedCount,
    required this.isHindi,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 6),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF2E7D32).withValues(alpha: 0.15),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _TabButton(
              title: isHindi ? 'सभी ग्रंथ' : 'All Books',
              icon: Icons.menu_book_rounded,
              isSelected: selectedTab == HolyBookTab.all,
              onTap: () {
                ref.read(selectedBookTabProvider.notifier).state =
                    HolyBookTab.all;
              },
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: _TabButton(
              title: isHindi ? 'डाउनलोड' : 'Downloaded',
              icon: Icons.download_done_rounded,
              badgeCount: downloadedCount > 0 ? downloadedCount : null,
              isSelected: selectedTab == HolyBookTab.downloaded,
              onTap: () {
                ref.read(selectedBookTabProvider.notifier).state =
                    HolyBookTab.downloaded;
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final int? badgeCount;
  final VoidCallback onTap;

  const _TabButton({
    required this.title,
    required this.icon,
    required this.isSelected,
    this.badgeCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2E7D32) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF2E7D32).withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                title,
                style: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 13,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (badgeCount != null) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.25)
                      : const Color(0xFF2E7D32).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$badgeCount',
                  style: TextStyle(
                    color: isSelected ? Colors.white : const Color(0xFF2E7D32),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Empty State for Downloaded Tab ──────────────────────────────────────────
class _EmptyDownloadedView extends StatelessWidget {
  final bool isHindi;
  final VoidCallback onExploreAll;

  const _EmptyDownloadedView({
    required this.isHindi,
    required this.onExploreAll,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFF2E7D32).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.cloud_download_outlined,
                size: 42,
                color: Color(0xFF2E7D32),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              isHindi ? 'कोई ग्रंथ डाउनलोड नहीं हुआ' : 'No Downloaded Books Yet',
              style: AppTextStyles.h2.copyWith(fontSize: 17),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              isHindi
                  ? 'पवित्र ग्रंथों को ऑफलाइन पढ़ने के लिए डाउनलोड करें और कभी भी पढ़ें।'
                  : 'Download sacred scriptures to read them offline anytime without internet.',
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
                fontSize: 13,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onExploreAll,
              icon: const Icon(Icons.auto_stories_rounded, size: 18),
              label: Text(
                isHindi ? 'सभी ग्रंथ देखें' : 'Explore All Books',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Scripture Detail & Reader Bottom Sheet ──────────────────────────────────
class _BookDetailSheet extends ConsumerStatefulWidget {
  final HolyBookModel book;
  final bool isHindi;
  const _BookDetailSheet({required this.book, required this.isHindi});

  @override
  ConsumerState<_BookDetailSheet> createState() => _BookDetailSheetState();
}

class _BookDetailSheetState extends ConsumerState<_BookDetailSheet> {
  bool _downloading = false;

  void _openPdf() {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            PdfReaderScreen(book: widget.book, isHindi: widget.isHindi),
      ),
    );
  }

  Future<void> _downloadPdf() async {
    setState(() => _downloading = true);
    try {
      final file =
          await DefaultCacheManager().getSingleFile(widget.book.pdfUrl);

      // Save to application documents directory
      final docDir = await getApplicationDocumentsDirectory();
      final docTarget = File('${docDir.path}/${widget.book.id}_scripture.pdf');
      await file.copy(docTarget.path);

      // Also copy to external storage directory if available
      final extDir = await getExternalStorageDirectory();
      if (extDir != null) {
        final target = File('${extDir.path}/${widget.book.id}_scripture.pdf');
        await file.copy(target.path);
      }

      // Mark as downloaded in state immediately
      ref.read(downloadedBookIdsProvider.notifier).add(widget.book.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.isHindi
                  ? 'पवित्र ग्रंथ डाउनलोड हो गया 📥'
                  : 'Holy Book saved to device 📥',
            ),
            backgroundColor: const Color(0xFF2E7D32),
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.isHindi ? 'डाउनलोड विफल: $e' : 'Download failed: $e',
            ),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _downloading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final book = widget.book;
    final isHindi = widget.isHindi;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Handle bar
            Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),

            // Book cover image preview
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: SizedBox(
                width: 110,
                height: 150,
                child: CachedNetworkImage(
                  imageUrl: book.coverUrl,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(
                    color: AppColors.cardBg,
                    child: const Center(
                      child: CircularProgressIndicator(
                          color: Color(0xFF2E7D32), strokeWidth: 2),
                    ),
                  ),
                  errorWidget: (_, __, ___) => Container(
                    color: AppColors.cardBg,
                    child: const Icon(Icons.menu_book_rounded,
                        color: Color(0xFF2E7D32), size: 48),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Title
            Text(
              isHindi ? book.titleHi : book.title,
              style: AppTextStyles.h2.copyWith(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),

            // Author
            if (book.author.isNotEmpty) ...[
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.edit_note_rounded,
                      size: 16, color: Color(0xFF2E7D32)),
                  const SizedBox(width: 4),
                  Text(
                    isHindi ? book.authorHi : book.author,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: const Color(0xFF2E7D32),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],

            // Description
            if (book.description.isNotEmpty) ...[
              Text(
                isHindi ? book.descriptionHi : book.description,
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 22),
            ],

            // Action buttons: Read PDF & Download
            Row(
              children: [
                // Download button
                Expanded(
                  flex: 2,
                  child: OutlinedButton.icon(
                    onPressed: _downloading ? null : _downloadPdf,
                    icon: _downloading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color(0xFF2E7D32),
                            ),
                          )
                        : const Icon(Icons.download_rounded, size: 20),
                    label: Text(
                      isHindi ? 'डाउनलोड' : 'Save',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF2E7D32),
                      side: const BorderSide(
                          color: Color(0xFF2E7D32), width: 1.5),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Read PDF button
                Expanded(
                  flex: 3,
                  child: ElevatedButton.icon(
                    onPressed: _openPdf,
                    icon:
                        const Icon(Icons.chrome_reader_mode_rounded, size: 20),
                    label: Text(
                      isHindi ? 'ग्रंथ पढ़ें' : 'Read PDF',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                      foregroundColor: Colors.white,
                      elevation: 2,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

