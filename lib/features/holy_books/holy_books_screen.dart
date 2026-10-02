import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/providers/language_provider.dart';
import '../../core/providers/content_providers.dart';
import '../../core/models/holy_book_model.dart';
import '../../shared/widgets/language_toggle.dart';

class HolyBooksScreen extends ConsumerWidget {
  const HolyBooksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isHindi = ref.watch(isHindiProvider);
    final asyncBooks = ref.watch(holyBooksProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // ── Header ──────────────────────────────────────────────────────
          _BooksHeader(isHindi: isHindi),
          // ── Grid ────────────────────────────────────────────────────────
          Expanded(
            child: asyncBooks.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
              error: (_, __) => Center(
                child: Text('Unable to load books',
                    style: AppTextStyles.body),
              ),
              data: (books) => GridView.builder(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
                physics: const BouncingScrollPhysics(),
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 0.7,
                ),
                itemCount: books.length,
                itemBuilder: (_, i) =>
                    _BookCard(book: books[i], isHindi: isHindi),
              ),
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
class _BookCard extends StatelessWidget {
  final HolyBookModel book;
  final bool isHindi;
  const _BookCard({required this.book, required this.isHindi});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Phase 4: open PDF viewer
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isHindi
                  ? '${book.titleHi} खुल रहा है...'
                  : 'Opening ${book.title}...',
            ),
            backgroundColor: const Color(0xFF2E7D32),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            duration: const Duration(seconds: 1),
          ),
        );
      },
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
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.menu_book_rounded,
                                color: AppColors.primary, size: 36),
                            const SizedBox(height: 4),
                            Text('📖',
                                style:
                                    const TextStyle(fontSize: 28)),
                          ],
                        ),
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
                  // PDF badge
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2E7D32),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text('PDF',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ),
            // Title
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
