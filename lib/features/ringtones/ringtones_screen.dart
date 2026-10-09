import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/providers/language_provider.dart';
import '../../core/providers/content_providers.dart';
import '../../core/providers/audio_providers.dart';
import '../../core/models/ringtone_model.dart';
import '../../core/services/audio_player_service.dart';
import '../../core/services/ringtone_service.dart';
import '../../shared/widgets/language_toggle.dart';
import '../../shared/widgets/no_internet_banner.dart';
import '../../shared/widgets/animated_devotional_background.dart';
import '../../shared/widgets/bouncing_tap.dart';

// ─── Currently previewing ringtone provider ───────────────────────────────────
final _previewingRingtoneProvider = StateProvider<String?>((ref) => null);

class RingtonesScreen extends ConsumerStatefulWidget {
  const RingtonesScreen({super.key});

  @override
  ConsumerState<RingtonesScreen> createState() => _RingtonesScreenState();
}

class _RingtonesScreenState extends ConsumerState<RingtonesScreen> {
  @override
  void dispose() {
    // Immediately stop ringtone playback when user closes or leaves this screen
    AudioPlayerService.instance.stopRingtone();
    super.dispose();
  }

  void _stopPlayback() {
    AudioPlayerService.instance.stopRingtone();
    ref.read(_previewingRingtoneProvider.notifier).state = null;
  }

  @override
  Widget build(BuildContext context) {
    final isHindi = ref.watch(isHindiProvider);
    final asyncRingtones = ref.watch(sortedRingtonesProvider);

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) {
          _stopPlayback();
        }
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: AnimatedDevotionalBackground(
            mode: DevotionalMode.ringtones,
            child: Stack(
              children: [
                Column(
              children: [
                // ── Header ──────────────────────────────────────────────────────
                _RingtonesHeader(
                  isHindi: isHindi,
                  onBack: () {
                    _stopPlayback();
                    Navigator.pop(context);
                  },
                ),

                // ── Sort Selector: Latest vs Popular ──────────────────────────────
                const _RingtoneSortSelector(),

                // ── Ringtone List ────────────────────────────────────────────────
                Expanded(
                  child: asyncRingtones.when(
                    loading: () => const Center(
                      child: CircularProgressIndicator(color: Color(0xFF6A1B9A)),
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
                                ? 'रिंगटोन लोड नहीं हो सके'
                                : 'Could not load ringtones',
                            style: AppTextStyles.body,
                          ),
                        ],
                      ),
                    ),
                    data: (ringtones) {
                      if (ringtones.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('🎵', style: TextStyle(fontSize: 48)),
                              const SizedBox(height: 12),
                              Text(
                                isHindi
                                    ? 'कोई रिंगटोन नहीं मिला'
                                    : 'No ringtones available',
                                style: AppTextStyles.body,
                              ),
                            ],
                          ),
                        );
                      }
                      return _RingtoneList(
                        ringtones: ringtones,
                        isHindi: isHindi,
                      );
                    },
                  ),
                ),
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
    ),
    );
  }
}

// ─── Header ───────────────────────────────────────────────────────────────────
class _RingtonesHeader extends StatelessWidget {
  final bool isHindi;
  final VoidCallback onBack;
  const _RingtonesHeader({required this.isHindi, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 16, 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isHindi ? 'रिंगटोन' : 'Ringtones',
                      style: GoogleFonts.cinzelDecorative(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFFFD54F),
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      isHindi
                          ? 'भक्तिमय रिंगटोन संग्रह'
                          : 'Devotional ringtone collection',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: const Color(0xFFFFECB3).withValues(alpha: 0.90),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const LanguageToggle(lightMode: true),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onBack,
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xFF380808).withValues(alpha: 0.65),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFD4A017).withValues(alpha: 0.60),
                      width: 1.0,
                    ),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 16,
                    color: Color(0xFFFFD54F),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Sort Selector (Latest vs Popular) ────────────────────────────────────────
class _RingtoneSortSelector extends ConsumerWidget {
  const _RingtoneSortSelector();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isHindi = ref.watch(isHindiProvider);
    final currentSort = ref.watch(ringtoneSortProvider);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF6A1B9A).withValues(alpha: 0.15),
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
              isSelected: currentSort == RingtoneSort.latest,
              onTap: () {
                ref.read(ringtoneSortProvider.notifier).state =
                    RingtoneSort.latest;
              },
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: _SortTabItem(
              title: isHindi ? 'लोकप्रिय' : 'Popular',
              icon: Icons.local_fire_department_rounded,
              isSelected: currentSort == RingtoneSort.popular,
              onTap: () {
                ref.read(ringtoneSortProvider.notifier).state =
                    RingtoneSort.popular;
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
                  colors: [Color(0xFF6A1B9A), Color(0xFFAB47BC)],
                )
              : null,
          color: isSelected ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF6A1B9A).withValues(alpha: 0.3),
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

// ─── Ringtone List (Unified, No Categories) ───────────────────────────────────
class _RingtoneList extends StatelessWidget {
  final List<RingtoneModel> ringtones;
  final bool isHindi;

  const _RingtoneList({
    required this.ringtones,
    required this.isHindi,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
      physics: const BouncingScrollPhysics(),
      itemCount: ringtones.length,
      itemBuilder: (context, index) {
        return _RingtoneCard(
          ringtone: ringtones[index],
          isHindi: isHindi,
        );
      },
    );
  }
}

// ─── Ringtone Card ────────────────────────────────────────────────────────────
class _RingtoneCard extends ConsumerWidget {
  final RingtoneModel ringtone;
  final bool isHindi;

  const _RingtoneCard({
    required this.ringtone,
    required this.isHindi,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final previewingId = ref.watch(_previewingRingtoneProvider);
    final isThisPlaying = previewingId == ringtone.id;
    final playerStateAsync = ref.watch(playerStateProvider);
    final isActuallyPlaying = isThisPlaying &&
        playerStateAsync.whenOrNull(
              data: (s) => s.playing,
            ) ==
            true;

    final title = isHindi ? ringtone.titleHi : ringtone.title;

    return BouncingTap(
      scaleFactor: 0.97,
      onTap: () async {
        if (isThisPlaying) {
          await AudioPlayerService.instance.togglePlayPause();
        } else {
          ref.read(_previewingRingtoneProvider.notifier).state =
              ringtone.id;
          await AudioPlayerService.instance.playRingtone(ringtone);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: isThisPlaying
              ? const Color(0xFF6A1B9A).withValues(alpha: 0.05)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isThisPlaying
                ? const Color(0xFF6A1B9A).withValues(alpha: 0.4)
                : AppColors.divider,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              // Play / Pause Circle
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  gradient: isThisPlaying
                      ? const LinearGradient(
                          colors: [Color(0xFF6A1B9A), Color(0xFFAB47BC)],
                        )
                      : null,
                  color: isThisPlaying
                      ? null
                      : const Color(0xFF6A1B9A).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  isActuallyPlaying
                      ? Icons.pause_rounded
                      : Icons.play_arrow_rounded,
                  color: isThisPlaying
                      ? Colors.white
                      : const Color(0xFF6A1B9A),
                  size: 26,
                ),
              ),
              const SizedBox(width: 12),

              // Title + Duration
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.h3.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Icon(
                          Icons.graphic_eq_rounded,
                          size: 13,
                          color: const Color(0xFF6A1B9A).withValues(alpha: 0.7),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          ringtone.durationLabel.isNotEmpty
                              ? ringtone.durationLabel
                              : (isHindi ? 'भक्तिमय' : 'Devotional'),
                          style: AppTextStyles.bodySmall.copyWith(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

                // Animated Waveform when playing
                if (isActuallyPlaying) ...[
                  _WaveIcon(),
                  const SizedBox(width: 8),
                ],

                // Direct "Set Ringtone" Button
                ElevatedButton.icon(
                  onPressed: () {
                    _showApplyRingtoneDialog(context, ringtone, isHindi);
                  },
                  icon: const Icon(Icons.ring_volume_rounded, size: 16),
                  label: Text(
                    isHindi ? 'लगाएं' : 'Set',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6A1B9A),
                    foregroundColor: Colors.white,
                    elevation: 1,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
  }
}

// ─── Set Ringtone Modal Sheet ────────────────────────────────────────────────
void _showApplyRingtoneDialog(
  BuildContext context,
  RingtoneModel ringtone,
  bool isHindi,
) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (sheetCtx) => _SetRingtoneSheet(
      ringtone: ringtone,
      isHindi: isHindi,
    ),
  );
}

class _SetRingtoneSheet extends StatefulWidget {
  final RingtoneModel ringtone;
  final bool isHindi;

  const _SetRingtoneSheet({
    required this.ringtone,
    required this.isHindi,
  });

  @override
  State<_SetRingtoneSheet> createState() => _SetRingtoneSheetState();
}

class _SetRingtoneSheetState extends State<_SetRingtoneSheet> {
  bool _applying = false;
  String? _statusText;

  Future<void> _apply(RingtoneTarget target) async {
    setState(() {
      _applying = true;
      _statusText = widget.isHindi
          ? 'रिंगटोन सेट की जा रही है...'
          : 'Setting ringtone on device...';
    });

    try {
      // Check write settings permission
      final canWrite = await RingtoneService.instance.canWriteSettings();
      if (!canWrite) {
        setState(() => _applying = false);
        if (mounted) {
          _showPermissionDialog();
        }
        return;
      }

      await RingtoneService.instance.setRingtone(
        audioUrl: widget.ringtone.audioUrl,
        title: widget.ringtone.title,
        target: target,
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.isHindi
                  ? 'रिंगटोन सफलतापूर्वक सेट हो गई! 🔔'
                  : 'Ringtone set successfully on device! 🔔',
            ),
            backgroundColor: const Color(0xFF6A1B9A),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } on RingtonePermissionException {
      setState(() => _applying = false);
      if (mounted) {
        _showPermissionDialog();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _applying = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.isHindi ? 'रिंगटोन सेट विफल: $e' : 'Failed to set ringtone: $e',
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

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.settings_suggest_rounded,
                color: Color(0xFF6A1B9A), size: 26),
            const SizedBox(width: 10),
            Text(
              widget.isHindi ? 'अनुमति की आवश्यकता' : 'Permission Required',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        content: Text(
          widget.isHindi
              ? 'सिस्टम रिंगटोन सेट करने के लिए, अगली स्क्रीन में "सिस्टम सेटिंग्स बदलने की अनुमति" (Modify system settings) को चालू करें।'
              : 'To set this ringtone, please allow Ananda to "Modify system settings" on the next screen.',
          style: const TextStyle(fontSize: 14, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              widget.isHindi ? 'रद्द करें' : 'Cancel',
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await RingtoneService.instance.openWriteSettings();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6A1B9A),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              widget.isHindi ? 'सेटिंग्स खोलें' : 'Open Settings',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final title =
        widget.isHindi ? widget.ringtone.titleHi : widget.ringtone.title;

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
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6A1B9A), Color(0xFFAB47BC)],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.music_note_rounded,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.isHindi
                            ? 'रिंगटोन सेट करें'
                            : 'Set Ringtone',
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
                      color: Color(0xFF6A1B9A),
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
              // Option 1: Phone Ringtone
              _RingtoneOptionTile(
                icon: Icons.phone_in_talk_rounded,
                title: widget.isHindi ? 'फ़ोन रिंगटोन' : 'Phone Ringtone',
                subtitle: widget.isHindi
                    ? 'इनकमिंग कॉल के लिए रिंगटोन सेट करें'
                    : 'Set as incoming call ringtone',
                isHighlighted: true,
                onTap: () => _apply(RingtoneTarget.ringtone),
              ),
              const SizedBox(height: 10),

              // Option 2: Notification Sound
              _RingtoneOptionTile(
                icon: Icons.notifications_active_rounded,
                title: widget.isHindi ? 'सूचना ध्वनि' : 'Notification Sound',
                subtitle: widget.isHindi
                    ? 'मैसेज और ऐप नोटिफिकेशन के लिए'
                    : 'Set as default notification tone',
                onTap: () => _apply(RingtoneTarget.notification),
              ),
              const SizedBox(height: 10),

              // Option 3: Alarm Sound
              _RingtoneOptionTile(
                icon: Icons.alarm_rounded,
                title: widget.isHindi ? 'अलार्म ध्वनि' : 'Alarm Sound',
                subtitle: widget.isHindi
                    ? 'प्रातःकालीन अलार्म के लिए'
                    : 'Set as morning alarm sound',
                onTap: () => _apply(RingtoneTarget.alarm),
              ),
              const SizedBox(height: 10),

              // Option 4: All Sounds
              _RingtoneOptionTile(
                icon: Icons.all_inclusive_rounded,
                title: widget.isHindi ? 'सभी के लिए सेट करें' : 'Set for All',
                subtitle: widget.isHindi
                    ? 'कॉल, नोटिफिकेशन और अलार्म तीनों पर लागू करें'
                    : 'Apply to calls, notifications & alarms',
                onTap: () => _apply(RingtoneTarget.all),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _RingtoneOptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isHighlighted;

  const _RingtoneOptionTile({
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
                    const Color(0xFF6A1B9A).withValues(alpha: 0.10),
                    const Color(0xFFAB47BC).withValues(alpha: 0.06),
                  ],
                )
              : null,
          color: isHighlighted ? null : AppColors.cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isHighlighted
                ? const Color(0xFF6A1B9A).withValues(alpha: 0.4)
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
                    ? const Color(0xFF6A1B9A)
                    : AppColors.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isHighlighted ? Colors.white : const Color(0xFF6A1B9A),
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
                  ? const Color(0xFF6A1B9A)
                  : AppColors.textSecondary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Animated wave icon ───────────────────────────────────────────────────────
class _WaveIcon extends StatefulWidget {
  @override
  State<_WaveIcon> createState() => _WaveIconState();
}

class _WaveIconState extends State<_WaveIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: List.generate(3, (i) {
          final height = 8.0 +
              12.0 *
                  (((_ctrl.value + i * 0.33) % 1.0) < 0.5
                      ? (_ctrl.value + i * 0.33) % 1.0
                      : 1.0 - (_ctrl.value + i * 0.33) % 1.0) *
                  2;
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 1.5),
            width: 3,
            height: height,
            decoration: BoxDecoration(
              color: const Color(0xFF6A1B9A),
              borderRadius: BorderRadius.circular(2),
            ),
          );
        }),
      ),
    );
  }
}
