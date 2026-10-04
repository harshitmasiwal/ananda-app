import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';

/// Service managing persistent on-device caching for bhajans and ringtones.
/// Every audio track played is cached locally so subsequent plays work
/// instantly and completely offline.
class AudioCacheService {
  AudioCacheService._();
  static final AudioCacheService instance = AudioCacheService._();

  Directory? _cacheDir;
  final Set<String> _inFlightDownloads = {};

  Future<void> init() async {
    if (_cacheDir != null) return;
    try {
      final docDir = await getApplicationDocumentsDirectory();
      _cacheDir = Directory('${docDir.path}/ananda_audio_cache');
      if (!await _cacheDir!.exists()) {
        await _cacheDir!.create(recursive: true);
      }
    } catch (e) {
      debugPrint('AudioCacheService init error: $e');
    }
  }

  /// Returns the target cached file for a track ID.
  Future<File> getFileForTrack(String id) async {
    await init();
    return getCachedFileSync(id)!;
  }

  /// Synchronously returns the target File if init() was called.
  File? getCachedFileSync(String id) {
    if (_cacheDir == null) return null;
    final sanitizedId = id.replaceAll(RegExp(r'[^\w\-_\.]'), '_');
    return File('${_cacheDir!.path}/$sanitizedId.mp3');
  }

  /// Synchronously checks if a track is already cached and complete on disk.
  bool isTrackCachedSync(String id) {
    final file = getCachedFileSync(id);
    if (file == null) return false;
    // Track is cached if file exists and has content (> 10KB)
    return file.existsSync() && file.lengthSync() > 10240;
  }

  /// Synchronously builds an AudioSource:
  /// - If already cached on disk, plays directly from local file (zero network).
  /// - If not cached, plays directly from remote URL for instant playback without proxy issues.
  AudioSource buildAudioSourceSync({
    required String id,
    required String url,
    required dynamic tag,
  }) {
    if (isTrackCachedSync(id)) {
      final file = getCachedFileSync(id)!;
      return AudioSource.uri(
        Uri.file(file.path),
        tag: tag,
      );
    }

    return AudioSource.uri(
      Uri.parse(url),
      tag: tag,
    );
  }

  /// Asynchronously builds an AudioSource with guaranteed init().
  Future<AudioSource> buildAudioSource({
    required String id,
    required String url,
    required dynamic tag,
  }) async {
    await init();
    return buildAudioSourceSync(id: id, url: url, tag: tag);
  }

  /// Non-blocking background downloader that caches the audio file to disk.
  /// Fails gracefully if offline or network interrupted.
  Future<void> cacheTrackInBackground(String id, String url) async {
    if (url.isEmpty) return;
    await init();
    if (isTrackCachedSync(id)) return;
    if (_inFlightDownloads.contains(id)) return;

    _inFlightDownloads.add(id);
    final targetFile = getCachedFileSync(id);
    if (targetFile == null) {
      _inFlightDownloads.remove(id);
      return;
    }

    final tempFile = File('${targetFile.path}.tmp');

    try {
      final uri = Uri.parse(url);
      final client = http.Client();
      try {
        final request = http.Request('GET', uri);
        final response =
            await client.send(request).timeout(const Duration(seconds: 40));

        if (response.statusCode == 200) {
          final sink = tempFile.openWrite();
          await response.stream.pipe(sink);
          await sink.flush();
          await sink.close();

          if (await tempFile.exists() && await tempFile.length() > 10240) {
            if (await targetFile.exists()) {
              await targetFile.delete();
            }
            await tempFile.rename(targetFile.path);
            debugPrint('Cached audio track successfully: $id');
          } else {
            if (await tempFile.exists()) await tempFile.delete();
          }
        } else {
          if (await tempFile.exists()) await tempFile.delete();
        }
      } finally {
        client.close();
      }
    } catch (e) {
      debugPrint('Background audio cache failed for $id: $e');
      try {
        if (await tempFile.exists()) await tempFile.delete();
      } catch (_) {}
    } finally {
      _inFlightDownloads.remove(id);
    }
  }
}
