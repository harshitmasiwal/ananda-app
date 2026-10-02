import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/providers/language_provider.dart';

class LanguageToggle extends ConsumerWidget {
  const LanguageToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isHindi = ref.watch(isHindiProvider);

    return GestureDetector(
      onTap: () => ref.read(isHindiProvider.notifier).state = !isHindi,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: isHindi
              ? AppColors.goldGradient
              : const LinearGradient(
                  colors: [Colors.white24, Colors.white30],
                ),
          border: Border.all(
            color: isHindi ? AppColors.goldDark : Colors.white54,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'EN',
              style: TextStyle(
                fontSize: 12,
                fontWeight:
                    !isHindi ? FontWeight.w700 : FontWeight.w400,
                color: !isHindi ? AppColors.primary : Colors.white70,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              width: 1,
              height: 12,
              color: Colors.white54,
            ),
            const SizedBox(width: 6),
            Text(
              'हि',
              style: TextStyle(
                fontSize: 12,
                fontWeight:
                    isHindi ? FontWeight.w700 : FontWeight.w400,
                color: isHindi ? AppColors.primary : Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
