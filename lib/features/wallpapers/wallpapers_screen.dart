import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/providers/language_provider.dart';
import '../../core/providers/content_providers.dart';
import '../../core/models/wallpaper_model.dart';
import '../../core/services/wallpaper_service.dart';
import '../../shared/widgets/language_toggle.dart';
import '../../shared/widgets/no_internet_banner.dart';
import '../../shared/widgets/animated_devotional_background.dart';
import '../../shared/widgets/bouncing_tap.dart';

class WallpapersScreen extends ConsumerWidget {
  const WallpapersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isHindi = ref.watch(isHindiProvider);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: AnimatedDevotionalBackground(
          mode: DevotionalMode.wallpapers,
          child: Stack(
            children: [
              Column(
                children: [
                  // ── Header ──────────────────────────────────────────────────────
                  _WallpapersHeader(isHindi: isHindi),

                  // ── Sort Selector: Latest vs Popular ──────────────────────────────
                  const _WallpaperSortSelector(),

                  // ── Wallpaper Grid ───────────────────────────────────────────────
                  const Expanded(child: _WallpaperGrid()),
                ],
              ),
              const Positioned(
                left: 0,
                right: 0,
                bottom: 4,
                child: SafeArea(
                  top: false,
                  child: NoInternetBottomCard(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Header ───────────────────────────────────────────────────────────────────
class _WallpapersHeader extends StatelessWidget {
  final bool isHindi;
  const _WallpapersHeader({required this.isHindi});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFF6B00), Color(0xFFFFAB40)],
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
              const Icon(Icons.wallpaper_rounded,
                  color: Colors.white, size: 28),
              const SizedBox(width: 10),
              Text(
                isHindi ? 'वॉलपेपर' : 'Wallpapers',
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

// ─── Sort Selector (Latest vs Popular) ────────────────────────────────────────
class _WallpaperSortSelector extends ConsumerWidget {
  const _WallpaperSortSelector();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isHindi = ref.watch(isHindiProvider);
    final currentSort = ref.watch(wallpaperSortProvider);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFFF6B00).withValues(alpha: 0.15),
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
            child: _SortTabItem(
              title: isHindi ? 'नवीनतम' : 'Latest',
              icon: Icons.access_time_rounded,
              isSelected: currentSort == WallpaperSort.latest,
              onTap: () {
                ref.read(wallpaperSortProvider.notifier).state =
                    WallpaperSort.latest;
              },
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: _SortTabItem(
              title: isHindi ? 'लोकप्रिय' : 'Popular',
              icon: Icons.local_fire_department_rounded,
              isSelected: currentSort == WallpaperSort.popular,
              onTap: () {
                ref.read(wallpaperSortProvider.notifier).state =
                    WallpaperSort.popular;
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SortTabItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _SortTabItem({
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BouncingTap(
      onTap: onTap,
      scaleFactor: 0.94,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Color(0xFFFF6B00), Color(0xFFFFAB40)],
                )
              : null,
          color: isSelected ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFFFF6B00).withValues(alpha: 0.3),
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
            Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Wallpaper Grid ───────────────────────────────────────────────────────────
class _WallpaperGrid extends ConsumerWidget {
  const _WallpaperGrid();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncWallpapers = ref.watch(sortedWallpapersProvider);
    final isHindi = ref.watch(isHindiProvider);

    return asyncWallpapers.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
      error: (_, __) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_rounded,
                color: AppColors.textSecondary, size: 48),
            const SizedBox(height: 12),
            Text(
              isHindi
                  ? 'वॉलपेपर लोड नहीं हो सके'
                  : 'Could not load wallpapers',
              style: AppTextStyles.body,
            ),
          ],
        ),
      ),
      data: (wallpapers) {
        if (wallpapers.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🖼️', style: TextStyle(fontSize: 48)),
                const SizedBox(height: 12),
                Text(
                  isHindi ? 'कोई वॉलपेपर नहीं मिला' : 'No wallpapers available',
                  style: AppTextStyles.body,
                ),
              ],
            ),
          );
        }
        return GridView.builder(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          physics: const BouncingScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: 0.64,
          ),
          itemCount: wallpapers.length,
          itemBuilder: (_, i) => _WallpaperCard(
            wallpaper: wallpapers[i],
            allWallpapers: wallpapers,
            initialIndex: i,
            isHindi: isHindi,
          ),
        );
      },
    );
  }
}

// ─── Wallpaper Card ───────────────────────────────────────────────────────────
class _WallpaperCard extends StatelessWidget {
  final WallpaperModel wallpaper;
  final List<WallpaperModel> allWallpapers;
  final int initialIndex;
  final bool isHindi;

  const _WallpaperCard({
    required this.wallpaper,
    required this.allWallpapers,
    required this.initialIndex,
    required this.isHindi,
  });

  void _openViewer(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _WallpaperViewer(
          wallpapers: allWallpapers,
          initialIndex: initialIndex,
          isHindi: isHindi,
        ),
      ),
    );
  }

  void _showSetSheet(BuildContext context) {
    _showApplyWallpaperDialog(context, wallpaper, isHindi);
  }

  @override
  Widget build(BuildContext context) {
    final title = isHindi ? wallpaper.titleHi : wallpaper.title;

    return BouncingTap(
      onTap: () => _openViewer(context),
      onLongPress: () => _showSetSheet(context),
      scaleFactor: 0.95,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Thumbnail
            CachedNetworkImage(
              imageUrl: wallpaper.thumbnailUrl,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(
                color: AppColors.cardBg,
                child: const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFFFF6B00),
                    strokeWidth: 2,
                  ),
                ),
              ),
              errorWidget: (_, __, ___) => Container(
                color: AppColors.cardBg,
                child: const Center(
                  child: Icon(Icons.broken_image_rounded,
                      color: AppColors.primaryLight, size: 40),
                ),
              ),
            ),

            // Gradient overlay at bottom
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 74,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.75),
                      Colors.transparent,
                    ],
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(10, 0, 8, 10),
                alignment: Alignment.bottomLeft,
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    // Quick apply icon button on the card!
                    GestureDetector(
                      onTap: () => _showSetSheet(context),
                      child: Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF6B00),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.wallpaper_rounded,
                          color: Colors.white,
                          size: 15,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Featured star badge if featured
            if (wallpaper.isFeatured)
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.gold,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.25),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: const Text('⭐', style: TextStyle(fontSize: 10)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─── Set Wallpaper Modal Sheet ────────────────────────────────────────────────
void _showApplyWallpaperDialog(
  BuildContext context,
  WallpaperModel wallpaper,
  bool isHindi,
) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (sheetCtx) => _SetWallpaperSheet(
      wallpaper: wallpaper,
      isHindi: isHindi,
    ),
  );
}

class _SetWallpaperSheet extends StatefulWidget {
  final WallpaperModel wallpaper;
  final bool isHindi;

  const _SetWallpaperSheet({
    required this.wallpaper,
    required this.isHindi,
  });

  @override
  State<_SetWallpaperSheet> createState() => _SetWallpaperSheetState();
}

class _SetWallpaperSheetState extends State<_SetWallpaperSheet> {
  bool _applying = false;
  String? _statusText;

  Future<void> _apply(WallpaperTarget target) async {
    setState(() {
      _applying = true;
      _statusText = widget.isHindi
          ? 'वॉलपेपर लगाया जा रहा है...'
          : 'Applying wallpaper...';
    });

    try {
      await WallpaperService.instance.setWallpaper(
        imageUrl: widget.wallpaper.fullUrl,
        target: target,
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.isHindi
                  ? 'वॉलपेपर सफलतापूर्वक सेट हो गया! ✨'
                  : 'Wallpaper applied successfully! ✨',
            ),
            backgroundColor: const Color(0xFFFF6B00),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _applying = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.isHindi
                  ? 'वॉलपेपर सेट करने में विफल: $e'
                  : 'Failed to set wallpaper: $e',
            ),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final title =
        widget.isHindi ? widget.wallpaper.titleHi : widget.wallpaper.title;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 32),
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
            const SizedBox(height: 18),

            // Mini Preview & Title
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: SizedBox(
                    width: 46,
                    height: 62,
                    child: CachedNetworkImage(
                      imageUrl: widget.wallpaper.thumbnailUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.isHindi
                            ? 'वॉलपेपर सेट करें'
                            : 'Set as Wallpaper',
                        style: AppTextStyles.h2.copyWith(fontSize: 17),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        title,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            if (_applying) ...[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Column(
                  children: [
                    const CircularProgressIndicator(
                      color: Color(0xFFFF6B00),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      _statusText ?? '',
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              // Option 1: Home Screen
              _WallpaperOptionTile(
                icon: Icons.home_rounded,
                title: widget.isHindi ? 'होम स्क्रीन' : 'Home Screen',
                subtitle: widget.isHindi
                    ? 'केवल मुख्य स्क्रीन पर लागू करें'
                    : 'Apply to main screen only',
                onTap: () => _apply(WallpaperTarget.home),
              ),
              const SizedBox(height: 10),

              // Option 2: Lock Screen
              _WallpaperOptionTile(
                icon: Icons.lock_outline_rounded,
                title: widget.isHindi ? 'लॉक स्क्रीन' : 'Lock Screen',
                subtitle: widget.isHindi
                    ? 'केवल लॉक स्क्रीन पर लागू करें'
                    : 'Apply to lock screen only',
                onTap: () => _apply(WallpaperTarget.lock),
              ),
              const SizedBox(height: 10),

              // Option 3: Both Screens (Recommended)
              _WallpaperOptionTile(
                icon: Icons.devices_rounded,
                title: widget.isHindi
                    ? 'होम और लॉक स्क्रीन दोनों'
                    : 'Both Screens',
                subtitle: widget.isHindi
                    ? 'पूरे डिवाइस पर लागू करें (अनुशंसित)'
                    : 'Apply to both home and lock (Recommended)',
                isHighlighted: true,
                onTap: () => _apply(WallpaperTarget.both),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _WallpaperOptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isHighlighted;

  const _WallpaperOptionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          gradient: isHighlighted
              ? LinearGradient(
                  colors: [
                    const Color(0xFFFF6B00).withValues(alpha: 0.12),
                    const Color(0xFFFFAB40).withValues(alpha: 0.08),
                  ],
                )
              : null,
          color: isHighlighted ? null : AppColors.cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isHighlighted
                ? const Color(0xFFFF6B00).withValues(alpha: 0.4)
                : AppColors.divider,
            width: isHighlighted ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isHighlighted
                    ? const Color(0xFFFF6B00)
                    : AppColors.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isHighlighted
                    ? Colors.white
                    : const Color(0xFFFF6B00),
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: isHighlighted
                          ? FontWeight.bold
                          : FontWeight.w600,
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: isHighlighted
                  ? const Color(0xFFFF6B00)
                  : AppColors.textSecondary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Wallpaper Gallery Sliding Viewer ─────────────────────────────────────────
class _WallpaperViewer extends StatefulWidget {
  final List<WallpaperModel> wallpapers;
  final int initialIndex;
  final bool isHindi;

  const _WallpaperViewer({
    required this.wallpapers,
    required this.initialIndex,
    required this.isHindi,
  });

  @override
  State<_WallpaperViewer> createState() => _WallpaperViewerState();
}

class _WallpaperViewerState extends State<_WallpaperViewer> {
  late final PageController _pageController;
  late int _currentIndex;
  bool _fillScreen = true;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  WallpaperModel get _currentWallpaper => widget.wallpapers[_currentIndex];

  void _nextPage() {
    if (_currentIndex < widget.wallpapers.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _prevPage() {
    if (_currentIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentTitle = widget.isHindi
        ? _currentWallpaper.titleHi
        : _currentWallpaper.title;

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              currentTitle,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (widget.wallpapers.length > 1)
              Text(
                '${_currentIndex + 1} / ${widget.wallpapers.length}',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.75),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: _fillScreen ? 'Fit to screen' : 'Fill screen',
            icon: Icon(
              _fillScreen ? Icons.fit_screen_rounded : Icons.fullscreen_rounded,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() => _fillScreen = !_fillScreen);
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // ── Gallery Sliding PageView ────────────────────────────────
          PageView.builder(
            controller: _pageController,
            physics: const BouncingScrollPhysics(),
            itemCount: widget.wallpapers.length,
            onPageChanged: (index) {
              setState(() => _currentIndex = index);
            },
            itemBuilder: (context, index) {
              final wallpaper = widget.wallpapers[index];
              return SizedBox.expand(
                child: InteractiveViewer(
                  minScale: 1.0,
                  maxScale: 4.0,
                  child: CachedNetworkImage(
                    imageUrl: wallpaper.fullUrl,
                    width: double.infinity,
                    height: double.infinity,
                    fit: _fillScreen ? BoxFit.cover : BoxFit.contain,
                    alignment: Alignment.center,
                    placeholder: (_, __) => const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFFF6B00),
                      ),
                    ),
                    errorWidget: (_, __, ___) => const Center(
                      child: Icon(Icons.broken_image_rounded,
                          color: Colors.white54, size: 64),
                    ),
                  ),
                ),
              );
            },
          ),

          // ── Previous Button (Left Arrow) ────────────────────────────
          if (_currentIndex > 0)
            Positioned(
              left: 12,
              top: 0,
              bottom: 0,
              child: Center(
                child: GestureDetector(
                  onTap: _prevPage,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.45),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.25),
                        width: 1,
                      ),
                    ),
                    child: const Icon(
                      Icons.chevron_left_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
              ),
            ),

          // ── Next Button (Right Arrow) ───────────────────────────────
          if (_currentIndex < widget.wallpapers.length - 1)
            Positioned(
              right: 12,
              top: 0,
              bottom: 0,
              child: Center(
                child: GestureDetector(
                  onTap: _nextPage,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.45),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.25),
                        width: 1,
                      ),
                    ),
                    child: const Icon(
                      Icons.chevron_right_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
              ),
            ),

          // ── Bottom Action Bar (Only Set as Wallpaper, No Save) ──────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.9),
                    Colors.transparent,
                  ],
                ),
              ),
              padding: const EdgeInsets.fromLTRB(20, 36, 20, 36),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Dot indicators for gallery position
                    if (widget.wallpapers.length > 1) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          widget.wallpapers.length,
                          (i) => AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            width: _currentIndex == i ? 22 : 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: _currentIndex == i
                                  ? const Color(0xFFFF6B00)
                                  : Colors.white.withValues(alpha: 0.35),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Direct "Set as Wallpaper" Button
                    GestureDetector(
                      onTap: () => _showApplyWallpaperDialog(
                        context,
                        _currentWallpaper,
                        widget.isHindi,
                      ),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFF6B00), Color(0xFFFFAB40)],
                          ),
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFF6B00)
                                  .withValues(alpha: 0.45),
                              blurRadius: 14,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.wallpaper_rounded,
                              color: Colors.white,
                              size: 22,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              widget.isHindi
                                  ? 'वॉलपेपर लगाएं'
                                  : 'Set as Wallpaper',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
