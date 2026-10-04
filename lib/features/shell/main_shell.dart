import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/providers/language_provider.dart';
import '../home/home_screen.dart';
import '../bhajans/bhajans_screen.dart';
import '../holy_books/holy_books_screen.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../shared/widgets/no_internet_banner.dart';

import '../../shared/widgets/animated_devotional_background.dart';
import '../../shared/widgets/bouncing_tap.dart';

// Tracks the active bottom‑nav tab (0 = Home, 1 = Bhajans, 2 = Books)
final selectedTabProvider = StateProvider<int>((ref) => 0);

class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  late final PageController _pageController;

  static const _screens = [
    HomeScreen(),
    BhajansScreen(),
    HolyBooksScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _pageController =
        PageController(initialPage: ref.read(selectedTabProvider));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _requestNotificationPermission();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _requestNotificationPermission() async {
    try {
      final status = await Permission.notification.status;
      if (status.isDenied) {
        await Permission.notification.request();
      }
    } catch (_) {}
  }

  Color _getActiveModeColor(int tab) {
    switch (tab) {
      case 0:
        return AppColors.modeHome;     // Deep Dark Saffron Orange for Home
      case 1:
        return AppColors.modeBhajans;  // Royal Devotional Purple for Bhajans
      case 2:
        return AppColors.modeBooks;    // Sacred Forest Green for Books
      default:
        return AppColors.modeHome;
    }
  }

  @override
  Widget build(BuildContext context) {
    final tab = ref.watch(selectedTabProvider);
    final isHindi = ref.watch(isHindiProvider);
    final activeColor = _getActiveModeColor(tab);

    // Keep PageView in sync if tab is changed externally
    ref.listen<int>(selectedTabProvider, (prev, next) {
      if (_pageController.hasClients &&
          _pageController.page?.round() != next) {
        _pageController.animateToPage(
          next,
          duration: const Duration(milliseconds: 320),
          curve: Curves.easeInOut,
        );
      }
    });

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: AnimatedDevotionalBackground(
          pageController: _pageController,
          child: Stack(
            children: [
              // Horizontal swipe between Home, Bhajans, and Books
              PageView(
                controller: _pageController,
                physics: const BouncingScrollPhysics(),
                onPageChanged: (i) {
                  ref.read(selectedTabProvider.notifier).state = i;
                },
                children: _screens,
              ),
              const Positioned(
                left: 0,
                right: 0,
                bottom: 4,
                child: NoInternetBottomCard(),
              ),
            ],
          ),
        ),
        bottomNavigationBar: _BottomNav(
          selectedIndex: tab,
          activeColor: activeColor,
          isHindi: isHindi,
          onTap: (i) {
            ref.read(selectedTabProvider.notifier).state = i;
            _pageController.animateToPage(
              i,
              duration: const Duration(milliseconds: 320),
              curve: Curves.easeInOut,
            );
          },
        ),
      ),
    );
  }
}

// ─── Nav items ────────────────────────────────────────────────────────────────
class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String labelHi;
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.labelHi,
  });
}

const _navItems = [
  _NavItem(
    icon: Icons.home_outlined,
    activeIcon: Icons.home_rounded,
    label: 'Home',
    labelHi: 'होम',
  ),
  _NavItem(
    icon: Icons.headphones_outlined,
    activeIcon: Icons.headphones_rounded,
    label: 'Bhajans',
    labelHi: 'भजन',
  ),
  _NavItem(
    icon: Icons.menu_book_outlined,
    activeIcon: Icons.menu_book_rounded,
    label: 'Books',
    labelHi: 'ग्रंथ',
  ),
];

// ─── Bottom Nav bar ───────────────────────────────────────────────────────────
class _BottomNav extends StatelessWidget {
  final int selectedIndex;
  final Color activeColor;
  final bool isHindi;
  final ValueChanged<int> onTap;

  const _BottomNav({
    required this.selectedIndex,
    required this.activeColor,
    required this.isHindi,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: activeColor.withValues(alpha: 0.14),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
        border: const Border(
            top: BorderSide(color: AppColors.divider, width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: List.generate(_navItems.length, (i) {
              final item = _navItems[i];
              final active = i == selectedIndex;
              return Expanded(
                child: BouncingTap(
                  onTap: () => onTap(i),
                  behavior: HitTestBehavior.opaque,
                  scaleFactor: 0.92,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 260),
                        curve: Curves.easeInOut,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 6),
                        decoration: BoxDecoration(
                          color: active
                              ? activeColor.withValues(alpha: 0.12)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Icon(
                          active ? item.activeIcon : item.icon,
                          color: active
                              ? activeColor
                              : AppColors.navInactive,
                          size: 24,
                        ),
                      ),
                      const SizedBox(height: 2),
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 200),
                        style: AppTextStyles.navLabel.copyWith(
                          color: active
                              ? activeColor
                              : AppColors.navInactive,
                          fontWeight: active
                              ? FontWeight.w700
                              : FontWeight.w400,
                        ),
                        child: Text(
                          isHindi ? item.labelHi : item.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
