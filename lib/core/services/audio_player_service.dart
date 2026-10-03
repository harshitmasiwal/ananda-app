import 'dart:async';
import 'dart:math';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:audio_session/audio_session.dart';
import '../models/bhajan_model.dart';
import '../models/ringtone_model.dart';

/// Singleton audio service: queue, shuffle, auto-advance, media notification.
class AudioPlayerService {
  AudioPlayerService._();
  static final AudioPlayerService instance = AudioPlayerService._();

  final _player = AudioPlayer();
  final _rng = Random();

  // ── Queue state ────────────────────────────────────────────────────────────
  List<BhajanModel> _queue = [];
  int _currentIndex = -1;
  bool _shuffle = false;

  // ── Broadcast streams for UI ───────────────────────────────────────────────
  final _currentBhajanCtrl = StreamController<BhajanModel?>.broadcast();
  final _shuffleCtrl = StreamController<bool>.broadcast();

  Stream<BhajanModel?> get currentBhajanStream => _currentBhajanCtrl.stream;
  Stream<bool> get shuffleStream => _shuffleCtrl.stream;

  BhajanModel? get currentBhajan =>
      (_currentIndex >= 0 && _currentIndex < _queue.length)
          ? _queue[_currentIndex]
          : null;
  bool get shuffle => _shuffle;

  // ── just_audio streams ────────────────────────────────────────────────────
  Stream<PlayerState> get playerStateStream => _player.playerStateStream;
  Stream<Duration?> get durationStream => _player.durationStream;
  Stream<Duration> get positionStream => _player.positionStream;
  Stream<bool> get playingStream => _player.playingStream;

  Duration? get duration => _player.duration;
  Duration get position => _player.position;
  bool get playing => _player.playing;

  /// Call once at app startup — AFTER JustAudioBackground.init().
  Future<void> init() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());

    // Auto-advance when a track completes
    _player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        _autoNext();
      }
    });
  }

  // ── Playback ───────────────────────────────────────────────────────────────

  Future<void> playBhajan(BhajanModel bhajan,
      {List<BhajanModel>? queue}) async {
    if (currentBhajan?.id == bhajan.id) {
      await togglePlayPause();
      return;
    }

    if (queue != null && queue.isNotEmpty) {
      _queue = List<BhajanModel>.from(queue);
    } else if (!_queue.any((b) => b.id == bhajan.id)) {
      _queue = [bhajan];
    }

    _currentIndex = _queue.indexWhere((b) => b.id == bhajan.id);
    if (_currentIndex == -1) {
      _queue.add(bhajan);
      _currentIndex = _queue.length - 1;
    }

    await _loadAndPlay(_queue[_currentIndex]);
  }

  Future<void> _loadAndPlay(BhajanModel bhajan) async {
    _currentBhajanCtrl.add(bhajan);
    try {
      await _player.stop();
      // MediaItem tag → populates the media notification
      final source = AudioSource.uri(
        Uri.parse(bhajan.audioUrl),
        tag: MediaItem(
          id: bhajan.id,
          title: bhajan.title,
          artist: bhajan.artist.isNotEmpty ? bhajan.artist : bhajan.category,
          album: 'Ananda',
          // Use first wallpaper as artwork — replace with dedicated icon if available
          artUri: Uri.parse(
            'https://res.cloudinary.com/dfbcf8uz/image/upload/w_300,h_300,c_fill,q_auto,f_auto/wallpaper_1',
          ),
        ),
      );
      await _player.setAudioSource(source);
      await _player.play();
    } catch (e) {
      // Swallow network/format errors
    }
  }

  Future<void> playRingtone(RingtoneModel ringtone) async {
    try {
      await _player.stop();
      final source = AudioSource.uri(
        Uri.parse(ringtone.audioUrl),
        tag: MediaItem(
          id: ringtone.id,
          title: ringtone.title,
          album: 'Ananda Ringtones',
        ),
      );
      await _player.setAudioSource(source);
      await _player.play();
    } catch (_) {}
  }

  Future<void> togglePlayPause() async {
    _player.playing ? await _player.pause() : await _player.play();
  }

  Future<void> stop() async {
    await _player.stop();
    _queue = [];
    _currentIndex = -1;
    _currentBhajanCtrl.add(null);
  }

  Future<void> seekTo(Duration pos) => _player.seek(pos);

  // ── Skip ──────────────────────────────────────────────────────────────────

  Future<void> skipNext() async {
    if (_queue.isEmpty) return;
    _currentIndex = _shuffle
        ? _rng.nextInt(_queue.length)
        : (_currentIndex + 1) % _queue.length;
    await _loadAndPlay(_queue[_currentIndex]);
  }

  Future<void> skipPrev() async {
    if (_queue.isEmpty) return;
    if (position.inSeconds > 3) {
      await seekTo(Duration.zero);
      return;
    }
    _currentIndex = _shuffle
        ? _rng.nextInt(_queue.length)
        : (_currentIndex - 1 + _queue.length) % _queue.length;
    await _loadAndPlay(_queue[_currentIndex]);
  }

  Future<void> _autoNext() async {
    if (_queue.isEmpty) return;
    _currentIndex = _shuffle
        ? _rng.nextInt(_queue.length)
        : (_currentIndex + 1) % _queue.length;
    await _loadAndPlay(_queue[_currentIndex]);
  }

  // ── Shuffle ───────────────────────────────────────────────────────────────
  void toggleShuffle() {
    _shuffle = !_shuffle;
    _shuffleCtrl.add(_shuffle);
  }

  Future<void> dispose() async {
    await _player.dispose();
    await _currentBhajanCtrl.close();
    await _shuffleCtrl.close();
  }
}
