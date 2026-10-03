import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import '../models/bhajan_model.dart';
import '../services/audio_player_service.dart';

// ── Current playing bhajan (driven by service stream) ─────────────────────────
/// Automatically updates whenever the service changes tracks (tap, skip, auto).
final currentBhajanProvider = StreamProvider<BhajanModel?>((ref) {
  return AudioPlayerService.instance.currentBhajanStream;
});

// ── Shuffle mode ──────────────────────────────────────────────────────────────
final shuffleModeProvider = StreamProvider<bool>((ref) {
  return AudioPlayerService.instance.shuffleStream;
});

// ── Player state stream ───────────────────────────────────────────────────────
final playerStateProvider = StreamProvider<PlayerState>((ref) {
  return AudioPlayerService.instance.playerStateStream;
});

// ── Is playing ────────────────────────────────────────────────────────────────
final isPlayingProvider = StreamProvider<bool>((ref) {
  return AudioPlayerService.instance.playingStream;
});

// ── Position stream ───────────────────────────────────────────────────────────
final positionProvider = StreamProvider<Duration>((ref) {
  return AudioPlayerService.instance.positionStream;
});

// ── Duration stream ───────────────────────────────────────────────────────────
final durationProvider = StreamProvider<Duration?>((ref) {
  return AudioPlayerService.instance.durationStream;
});
