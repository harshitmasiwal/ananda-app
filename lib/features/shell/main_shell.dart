import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/providers/language_provider.dart';
import '../home/home_screen.dart';
import '../bhajans/bhajans_screen.dart';
import '../holy_books/holy_books_screen.dart';

import 'package:permission_handler/permission_handler.dart';

// Tracks the active bottom‑nav tab (0 = Home, 1 = Bhajans, 2 = Books)
final selectedTabProvider = StateProvider<int>((ref) => 0);

class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  static const _screens = [
    HomeScreen(),
    BhajansScreen(),
    HolyBooksScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _requestNotificationPermission();
    });
  }

  Future<void> _requestNotificationPermission() async {
    try {
      final status = await Permission.notification.status;
      if (status.isDenied) {
        await Permission.notification.request();
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final tab = ref.watch(selectedTabProvider);
    final isHindi = ref.watch(isHindiProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(index: tab, children: _screens),
      bottomNavigationBar: _BottomNav(
        selectedIndex: tab,
        isHindi: isHindi,
        onTap: (i) => ref.read(selectedTabProvider.notifier).state = i,
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
  final bool isHindi;
  final ValueChanged<int> onTap;

  const _BottomNav({
    required this.selectedIndex,
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
            color: AppColors.primary.withValues(alpha: 0.18),
            blurRadius: 24,
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
                child: GestureDetector(
                  onTap: () => onTap(i),
                  behavior: HitTestBehavior.opaque,
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
                              ? AppColors.primary.withValues(alpha: 0.12)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Icon(
                          active ? item.activeIcon : item.icon,
                          color: active
                              ? AppColors.primary
                              : AppColors.navInactive,
                          size: 24,
                        ),
                      ),
                      const SizedBox(height: 2),
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 200),
                        style: AppTextStyles.navLabel.copyWith(
                          color: active
                              ? AppColors.primary
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
