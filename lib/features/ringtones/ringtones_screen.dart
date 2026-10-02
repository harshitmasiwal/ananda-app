import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class RingtonesScreen extends StatelessWidget {
  const RingtonesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ringtones'),
        backgroundColor: AppColors.sectionGradients[1][0],
      ),
      body: const Center(
        child: Text('Ringtones — Phase 6'),
      ),
    );
  }
}
