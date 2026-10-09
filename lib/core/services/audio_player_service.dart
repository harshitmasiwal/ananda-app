import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:audio_session/audio_session.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/bhajan_model.dart';
import '../models/ringtone_model.dart';
import 'audio_cache_service.dart';

/// Singleton audio service: queue, shuffle, continuous sequence loop, media notification.
class AudioPlayerService {
  AudioPlayerService._();
  static final AudioPlayerService instance = AudioPlayerService._();

  final _player = AudioPlayer();

  // ── Queue state ────────────────────────────────────────────────────────────
  List<BhajanModel> _queue = [];
  int _currentIndex = -1;
  bool _shuffle = false;
  bool _isPlayingRingtone = false;

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
  bool get isPlayingRingtone => _isPlayingRingtone;

  // ── just_audio streams ────────────────────────────────────────────────────
  Stream<PlayerState> get playerStateStream => _player.playerStateStream;
  Stream<Duration?> get durationStream => _player.durationStream;
  Stream<Duration> get positionStream => _player.positionStream;
  Stream<bool> get playingStream => _player.playingStream;

  Duration? get duration => _player.duration;
  Duration get position => _player.position;
  bool get playing => _player.playing;

  final Map<String, Duration> _knownDurations = {};

  /// Call once at app startup — AFTER JustAudioBackground.init().
  Future<void> init() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());

    // Ensure audio cache directory is initialized
    await AudioCacheService.instance.init();

    // Loop all tracks so the queue never halts and next/prev wrap seamlessly
    await _player.setLoopMode(LoopMode.all);

    // Cache exact audio duration from player stream
    _player.durationStream.listen((d) {
      if (d != null && currentBhajan != null) {
        _knownDurations[currentBhajan!.id] = d;
      }
    });

    // Listen to track index changes (from in-app or from lockscreen/notification shade)
    _player.currentIndexStream.listen((index) {
      if (index != null && index >= 0 && index < _queue.length) {
        _currentIndex = index;
        final track = _queue[_currentIndex];
        _currentBhajanCtrl.add(track);
        AudioCacheService.instance.cacheTrackInBackground(track.id, track.audioUrl);
      }
    });

    // Auto-advance loop fallback if playlist reaches the end
    _player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        if (!_player.hasNext && _queue.isNotEmpty) {
          _player.seek(Duration.zero, index: 0);
          _player.play();
        }
      }
    });
  }

  // ── Playback ───────────────────────────────────────────────────────────────

  Future<void> playBhajan(BhajanModel bhajan,
      {List<BhajanModel>? queue}) async {
    _isPlayingRingtone = false;

    // Ensure notification permission is requested so controls appear on lock screen/shade
    try {
      final status = await Permission.notification.status;
      if (!status.isGranted) {
        await Permission.notification.request();
      }
    } catch (_) {}

    if (currentBhajan?.id == bhajan.id) {
      await togglePlayPause();
      return;
    }

    final newQueue = (queue != null && queue.isNotEmpty)
        ? List<BhajanModel>.from(queue)
        : (_queue.isNotEmpty ? _queue : [bhajan]);

    // Check if newQueue has same IDs as current _queue
    final bool isSameQueue = _queue.length == newQueue.length &&
        _queue.isNotEmpty &&
        List.generate(_queue.length, (i) => _queue[i].id == newQueue[i].id)
            .every((match) => match);

    _queue = newQueue;
    _currentIndex = _queue.indexWhere((b) => b.id == bhajan.id);
    if (_currentIndex == -1) {
      _queue.add(bhajan);
      _currentIndex = _queue.length - 1;
    }

    _currentBhajanCtrl.add(_queue[_currentIndex]);

    try {
      if (isSameQueue && _player.audioSource != null) {
        await _player.seek(Duration.zero, index: _currentIndex);
        await _player.play();
      } else {
        final playlist = ConcatenatingAudioSource(
          useLazyPreparation: true,
          children: _queue.map((b) => _buildAudioSource(b)).toList(),
        );
        await _player.setAudioSource(playlist, initialIndex: _currentIndex);
        // LoopMode.all ensures hasNext / hasPrevious stay active and tracks loop
        await _player.setLoopMode(LoopMode.all);
        if (_shuffle) {
          await _player.setShuffleModeEnabled(true);
        }
        await _player.play();
      }
      AudioCacheService.instance.cacheTrackInBackground(bhajan.id, bhajan.audioUrl);
    } catch (e) {
      debugPrint('Error playing bhajan playlist: $e');
      try {
        await _player.setAudioSource(_buildAudioSource(bhajan));
        await _player.play();
        AudioCacheService.instance.cacheTrackInBackground(bhajan.id, bhajan.audioUrl);
      } catch (e2) {
        debugPrint('Error playing fallback single bhajan: $e2');
      }
    }
  }

  AudioSource _buildAudioSource(BhajanModel bhajan) {
    // High-resolution devotional artwork tailored to category
    final String defaultArtwork = bhajan.category.toLowerCase().contains('hanuman')
        ? 'https://res.cloudinary.com/dfbcf8uz/image/upload/w_500,h_500,c_fill,q_auto,f_auto/v1790970459/wallpaper_2.png'
        : 'https://res.cloudinary.com/dfbcf8uz/image/upload/w_500,h_500,c_fill,q_auto,f_auto/v1790970413/wallpaper_1.png';

    final coverUri = (bhajan.coverUrl != null && bhajan.coverUrl!.isNotEmpty)
        ? Uri.tryParse(bhajan.coverUrl!)
        : Uri.parse(defaultArtwork);

    // Formatted category display name (e.g., 'shiv' -> 'Shiv', 'mata-rani' -> 'Mata Rani')
    final String categoryTitle = bhajan.category
        .split(RegExp(r'[-_\s]+'))
        .where((w) => w.isNotEmpty)
        .map((w) => '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}')
        .join(' ');

    final String artistName = bhajan.artist.isNotEmpty
        ? bhajan.artist
        : (categoryTitle.isNotEmpty ? '$categoryTitle Bhajan' : 'Devotional');

    final Duration duration = _knownDurations[bhajan.id] ??
        (bhajan.durationSeconds != null && bhajan.durationSeconds! > 0
            ? Duration(seconds: bhajan.durationSeconds!)
            : const Duration(minutes: 5));

    final tag = MediaItem(
      id: bhajan.id,
      title: bhajan.title,
      artist: artistName,
      album: 'Ananda Devotional',
      genre: 'Spiritual',
      duration: duration,
      displayTitle: bhajan.title,
      displaySubtitle: artistName,
      displayDescription: 'Ananda • $categoryTitle',
      artUri: coverUri,
    );

    return AudioCacheService.instance.buildAudioSourceSync(
      id: bhajan.id,
      url: bhajan.audioUrl,
      tag: tag,
    );
  }

  Future<void> playRingtone(RingtoneModel ringtone) async {
    try {
      _isPlayingRingtone = true;
      await _player.stop();
      _queue = [];
      _currentIndex = -1;
      _currentBhajanCtrl.add(null);

      final tag = MediaItem(
        id: 'ringtone_${ringtone.id}',
        title: ringtone.title,
        artist: 'Ananda Ringtones',
        album: 'Ananda Ringtones',
      );
      final source = AudioCacheService.instance.buildAudioSourceSync(
        id: 'ringtone_${ringtone.id}',
        url: ringtone.audioUrl,
        tag: tag,
      );
      await _player.setAudioSource(source);
      await _player.play();
      AudioCacheService.instance.cacheTrackInBackground('ringtone_${ringtone.id}', ringtone.audioUrl);
    } catch (e) {
      debugPrint('Error playing ringtone: $e');
    }
  }

  /// Stops ringtone preview specifically
  Future<void> stopRingtone() async {
    if (_isPlayingRingtone) {
      await _player.stop();
      _isPlayingRingtone = false;
    }
  }

  Future<void> togglePlayPause() async {
    _player.playing ? await _player.pause() : await _player.play();
  }

  Future<void> stop() async {
    _isPlayingRingtone = false;
    await _player.stop();
    _queue = [];
    _currentIndex = -1;
    _currentBhajanCtrl.add(null);
  }

  Future<void> seekTo(Duration pos) => _player.seek(pos);
  Future<void> seek(Duration pos) => _player.seek(pos);
  Future<void> skipToNext() => skipNext();
  Future<void> skipToPrevious() => skipPrev();

  // ── Skip ──────────────────────────────────────────────────────────────────

  Future<void> skipNext() async {
    if (_queue.isEmpty) return;
    if (_player.hasNext) {
      await _player.seekToNext();
    } else {
      // Wrap to the starting track
      _currentIndex = 0;
      await _player.seek(Duration.zero, index: 0);
    }
  }

  Future<void> skipPrev() async {
    if (_queue.isEmpty) return;
    if (position.inSeconds > 3) {
      await seekTo(Duration.zero);
      return;
    }
    if (_player.hasPrevious) {
      await _player.seekToPrevious();
    } else {
      // Wrap to the ending track
      _currentIndex = _queue.length - 1;
      await _player.seek(Duration.zero, index: _currentIndex);
    }
  }

  // ── Shuffle ───────────────────────────────────────────────────────────────
  Future<void> toggleShuffle() async {
    _shuffle = !_shuffle;
    await _player.setShuffleModeEnabled(_shuffle);
    _shuffleCtrl.add(_shuffle);
  }

  Future<void> dispose() async {
    await _player.dispose();
    await _currentBhajanCtrl.close();
    await _shuffleCtrl.close();
  }
}
