import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';

class NoInternetCard extends StatelessWidget {
  final bool isHindi;
  final String? customMessage;
  final String? customMessageHi;
  final Future<void> Function()? onRetry;

  const NoInternetCard({
    super.key,
    required this.isHindi,
    this.customMessage,
    this.customMessageHi,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final title = isHindi ? 'इंटरनेट कनेक्शन नहीं है' : 'No Internet Connection';
    final defaultMsg = isHindi
        ? 'यह सामग्री डिवाइस पर कैश्ड नहीं है। कृपया इसे लोड करने के लिए इंटरनेट से जुड़ें।'
        : 'This content is not cached on your device. Please connect to the internet to load it.';
    final msg = isHindi
        ? (customMessageHi ?? defaultMsg)
        : (customMessage ?? defaultMsg);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: const Color(0xFFFF6B00).withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.wifi_off_rounded,
                size: 46,
                color: Color(0xFFFF6B00),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: AppTextStyles.h2.copyWith(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              msg,
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
                fontSize: 13,
                height: 1.45,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => onRetry!(),
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: Text(
                  isHindi ? 'पुनः प्रयास करें' : 'Retry Connection',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6B00),
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 2,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
