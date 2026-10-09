import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../home/home_screen.dart';
import '../bhajans/bhajans_screen.dart';
import '../japa/japa_screen.dart';
import '../sadhak/sadhak_screen.dart';
import '../../shared/widgets/mini_audio_player.dart';
import '../../shared/widgets/no_internet_banner.dart';
import '../../shared/widgets/bouncing_tap.dart';
import 'package:permission_handler/permission_handler.dart';

// Tracks the active bottom-nav tab (0 = Pranam, 1 = Sangeet, 2 = Japa, 3 = Sadhak)
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
    JapaScreen(),
    SadhakScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: ref.read(selectedTabProvider));
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

  @override
  Widget build(BuildContext context) {
    final tab = ref.watch(selectedTabProvider);

    // Keep PageView in sync if tab changed externally
    ref.listen<int>(selectedTabProvider, (prev, next) {
      if (_pageController.hasClients && _pageController.page?.round() != next) {
        _pageController.animateToPage(
          next,
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeInOut,
        );
      }
    });

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Color(0xFFFFFFFF),
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Stack(
          children: [
            // Main Page Content
            PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(), // tab navigation only
              children: _screens,
            ),

            // Persistent Floating Mini-Audio Player right above bottom nav
            const Positioned(
              left: 0,
              right: 0,
              bottom: 4,
              child: MiniAudioPlayer(),
            ),

            // No internet notification card if offline
            const Positioned(
              left: 0,
              right: 0,
              bottom: 74,
              child: NoInternetBottomCard(),
            ),
          ],
        ),
        bottomNavigationBar: _BottomNav(
          selectedIndex: tab,
          onTap: (i) {
            ref.read(selectedTabProvider.notifier).state = i;
            _pageController.jumpToPage(i);
          },
        ),
      ),
    );
  }
}

// ─── Nav Item Definition ───────────────────────────────────────────────────────
class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

const _navItems = [
  _NavItem(
    icon: Icons.spa_outlined,
    activeIcon: Icons.spa_rounded,
    label: 'Pranam',
  ),
  _NavItem(
    icon: Icons.music_note_outlined,
    activeIcon: Icons.music_note_rounded,
    label: 'Sangeet',
  ),
  _NavItem(
    icon: Icons.self_improvement_rounded,
    activeIcon: Icons.self_improvement_rounded,
    label: 'Japa',
  ),
  _NavItem(
    icon: Icons.person_outline_rounded,
    activeIcon: Icons.person_rounded,
    label: 'Sadhak',
  ),
];

// ─── Bottom Navigation Bar (Matching Screenshots 1, 2, 3, 4) ──────────────────
class _BottomNav extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const _BottomNav({
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: const Color(0xFFEDE4D8).withValues(alpha: 0.9),
            width: 1.0,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
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
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Active Pill Indicator
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: EdgeInsets.symmetric(
                          horizontal: active ? 20 : 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: active ? const Color(0xFFFBECE1) : Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          active ? item.activeIcon : item.icon,
                          size: 22,
                          color: active ? const Color(0xFF8C3B00) : const Color(0xFF7B6B61),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.label,
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                          color: active ? const Color(0xFF8C3B00) : const Color(0xFF7B6B61),
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
