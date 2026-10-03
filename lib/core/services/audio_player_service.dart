import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import '../models/bhajan_model.dart';
import '../models/ringtone_model.dart';

/// Singleton audio player service.
/// Wraps [AudioPlayer] from just_audio and provides a simple API
/// for the rest of the app to play bhajans / ringtones.
class AudioPlayerService {
  AudioPlayerService._();
  static final AudioPlayerService instance = AudioPlayerService._();

  final _player = AudioPlayer();

  BhajanModel? _currentBhajan;
  RingtoneModel? _currentRingtone;

  BhajanModel? get currentBhajan => _currentBhajan;
  RingtoneModel? get currentRingtone => _currentRingtone;

  /// Streams forwarded from [AudioPlayer]
  Stream<PlayerState> get playerStateStream => _player.playerStateStream;
  Stream<Duration?> get durationStream => _player.durationStream;
  Stream<Duration> get positionStream => _player.positionStream;
  Stream<bool> get playingStream => _player.playingStream;

  Duration? get duration => _player.duration;
  Duration get position => _player.position;
  bool get playing => _player.playing;

  /// Configure audio session once at app startup.
  Future<void> init() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());
  }

  /// Play a bhajan. If it's already the current one, toggles play/pause.
  Future<void> playBhajan(BhajanModel bhajan) async {
    if (_currentBhajan?.id == bhajan.id) {
      await togglePlayPause();
      return;
    }
    _currentBhajan = bhajan;
    _currentRingtone = null;
    await _player.stop();
    await _player.setUrl(bhajan.audioUrl);
    await _player.play();
  }

  /// Play a ringtone. If it's already the current one, toggles play/pause.
  Future<void> playRingtone(RingtoneModel ringtone) async {
    if (_currentRingtone?.id == ringtone.id) {
      await togglePlayPause();
      return;
    }
    _currentRingtone = ringtone;
    _currentBhajan = null;
    await _player.stop();
    await _player.setUrl(ringtone.audioUrl);
    await _player.play();
  }

  Future<void> togglePlayPause() async {
    if (_player.playing) {
      await _player.pause();
    } else {
      await _player.play();
    }
  }

  Future<void> stop() async {
    await _player.stop();
    _currentBhajan = null;
    _currentRingtone = null;
  }

  Future<void> seekTo(Duration position) => _player.seek(position);

  Future<void> skipNext(List<BhajanModel> queue) async {
    if (_currentBhajan == null) return;
    final idx = queue.indexWhere((b) => b.id == _currentBhajan!.id);
    if (idx != -1 && idx < queue.length - 1) {
      await playBhajan(queue[idx + 1]);
    }
  }

  Future<void> skipPrev(List<BhajanModel> queue) async {
    if (_currentBhajan == null) return;
    // If > 3 seconds in, seek to start; else go to previous track
    if (position.inSeconds > 3) {
      await seekTo(Duration.zero);
    } else {
      final idx = queue.indexWhere((b) => b.id == _currentBhajan!.id);
      if (idx > 0) await playBhajan(queue[idx - 1]);
    }
  }

  Future<void> dispose() => _player.dispose();
}
