import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/providers/language_provider.dart';
import '../../core/providers/content_providers.dart';
import '../../core/models/holy_book_model.dart';
import '../../shared/widgets/language_toggle.dart';
import '../../shared/widgets/bouncing_tap.dart';
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

  /// Deletes the downloaded PDF file from device storage and updates state.
  Future<bool> deleteBook(String bookId) async {
    try {
      final docDir = await getApplicationDocumentsDirectory();
      final docFile = File('${docDir.path}/${bookId}_scripture.pdf');
      if (docFile.existsSync()) {
        await docFile.delete();
      }

      final extDir = await getExternalStorageDirectory();
      if (extDir != null) {
        final extFile = File('${extDir.path}/${bookId}_scripture.pdf');
        if (extFile.existsSync()) {
          await extFile.delete();
        }
      }

      remove(bookId);
      await refresh();
      return true;
    } catch (_) {
      return false;
    }
  }
}

/// Confirmation dialog for deleting a downloaded PDF scripture.
Future<void> showDeletePdfConfirmationDialog({
  required BuildContext context,
  required HolyBookModel book,
  required bool isHindi,
  required VoidCallback onDeleted,
}) async {
  final title = isHindi ? book.titleHi : book.title;
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          const Icon(Icons.delete_outline_rounded,
              color: Colors.red, size: 24),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              isHindi ? 'ग्रंथ हटाएं?' : 'Delete Scripture?',
              style: AppTextStyles.h3,
            ),
          ),
        ],
      ),
      content: Text(
        isHindi
            ? 'क्या आप "${title.isNotEmpty ? title : 'यह ग्रंथ'}" को डिवाइस से हटाना चाहते हैं?'
            : 'Are you sure you want to delete "$title" from your device storage?',
        style: AppTextStyles.body.copyWith(fontSize: 13, height: 1.4),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: Text(
            isHindi ? 'रद्द करें' : 'Cancel',
            style: const TextStyle(color: AppColors.textSecondary),
          ),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(ctx, true),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red.shade600,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(isHindi ? 'हटाएं' : 'Delete'),
        ),
      ],
    ),
  );

  if (confirmed == true) {
    onDeleted();
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
                child: CircularProgressIndicator(color: Color(0xFF2E7D32)),
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
      color: Colors.transparent,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (Navigator.canPop(context)) ...[
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFBECE1),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFE2C9B6),
                        width: 1.0,
                      ),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 16,
                        color: Color(0xFF8C3B00),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Container(
                width: 38,
                height: 38,
                decoration: const BoxDecoration(
                  color: Color(0xFFFBECE1),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.menu_book_rounded,
                    color: Color(0xFF8C3B00),
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isHindi ? 'पवित्र ग्रंथ' : 'Holy Scriptures',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF2E170C),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isHindi
                          ? 'सनातन वैदिक ग्रंथ एवं टीकाएं'
                          : 'Sacred texts & divine commentaries',
                      style: GoogleFonts.outfit(
                        fontSize: 12.5,
                        color: const Color(0xFF7B6B61),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const LanguageToggle(lightMode: true),
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
    return BouncingTap(
      onTap: () => _openPdfReader(context, ref),
      onLongPress: () => _showBookSheet(context),
      scaleFactor: 0.95,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFFFF8EE),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: const Color(0xFFD4A017).withValues(alpha: 0.85),
            width: 1.2,
          ),
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
            // Cover image (takes majority of card)
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
                  // PDF badge on top-right (green badge as in screenshot)
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
                            color: Colors.black.withValues(alpha: 0.25),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.picture_as_pdf_rounded,
                              color: Colors.white, size: 10),
                          SizedBox(width: 3),
                          Text('PDF',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700)),
                        ],
                      ),
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
            // Bottom bar: [📖  Title   ( > )] matching Screenshot 3
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: const BoxDecoration(
                color: Color(0xFFFFF8EE),
                border: Border(
                  top: BorderSide(color: Color(0xFFE2C49C), width: 0.8),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3DEBE),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFFD4A017).withValues(alpha: 0.6),
                        width: 0.8,
                      ),
                    ),
                    child: const Icon(
                      Icons.menu_book_rounded,
                      color: Color(0xFF8A4A28),
                      size: 14,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      isHindi ? book.titleHi : book.title,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF3B0D0D),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF6B1B1B),
                    ),
                    child: const Icon(
                      Icons.chevron_right_rounded,
                      color: Color(0xFFFFD54F),
                      size: 16,
                    ),
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

// ─── Top Tabs: All Books vs Downloaded (Screenshot 3) ────────────────────────
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
          const SizedBox(width: 6),
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
    return BouncingTap(
      onTap: onTap,
      scaleFactor: 0.94,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF8C3B00) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : const Color(0xFF7B6B61),
            ),
            const SizedBox(width: 6),
            Text(
              title,
              style: GoogleFonts.outfit(
                color: isSelected ? Colors.white : const Color(0xFF7B6B61),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                fontSize: 12.5,
              ),
            ),
            if (badgeCount != null) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : const Color(0xFF8C3B00),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$badgeCount',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? const Color(0xFF8C3B00) : Colors.white,
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

  Future<void> _deletePdf() async {
    showDeletePdfConfirmationDialog(
      context: context,
      book: widget.book,
      isHindi: widget.isHindi,
      onDeleted: () async {
        await ref
            .read(downloadedBookIdsProvider.notifier)
            .deleteBook(widget.book.id);
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                widget.isHindi
                    ? 'पवित्र ग्रंथ डिवाइस स्टोरेज से हटा दिया गया 🗑️'
                    : 'Holy Book deleted from device 🗑️',
              ),
              backgroundColor: Colors.red.shade700,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
      },
    );
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

            // Action buttons: Read PDF & Download / Delete
            Builder(builder: (context) {
              final isDownloaded =
                  ref.watch(downloadedBookIdsProvider).contains(book.id);

              return Row(
                children: [
                  if (isDownloaded)
                    // Delete button
                    Expanded(
                      flex: 2,
                      child: OutlinedButton.icon(
                        onPressed: _deletePdf,
                        icon: const Icon(Icons.delete_outline_rounded,
                            size: 20, color: Colors.red),
                        label: Text(
                          isHindi ? 'हटाएं' : 'Delete',
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, color: Colors.red),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: BorderSide(
                              color: Colors.red.shade400, width: 1.5),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    )
                  else
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
                      icon: const Icon(Icons.chrome_reader_mode_rounded,
                          size: 20),
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
              );
            }),
          ],
        ),
      ),
    );
  }
}

