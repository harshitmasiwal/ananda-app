import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class WallpapersScreen extends StatelessWidget {
  const WallpapersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wallpapers'),
        backgroundColor: AppColors.primary,
      ),
      body: const Center(
        child: Text('Wallpapers — Phase 3'),
      ),
    );
  }
}
