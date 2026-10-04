import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'app.dart';
import 'core/services/audio_player_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── IMPORTANT: init background audio BEFORE AudioPlayer is created ─────────
  // This patches just_audio's AudioPlayer so it can post media notifications.
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.elysian.ananda.audio',
    androidNotificationChannelName: 'Ananda Devotional Player',
    androidNotificationChannelDescription: 'Spiritual music and bhajan controls',
    androidNotificationIcon: 'mipmap/ic_launcher',
    notificationColor: const Color(0xFFFF6F00),
    androidNotificationOngoing: false,
    androidStopForegroundOnPause: true,
    preloadArtwork: true,
    artDownscaleWidth: 500,
    artDownscaleHeight: 500,
  );

  // Configure audio session & auto-advance (creates AudioPlayer internally)
  await AudioPlayerService.instance.init();

  // Force portrait orientation
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Transparent status bar with clean navigation bar
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(
    const ProviderScope(
      child: AnandaApp(),
    ),
  );
}
