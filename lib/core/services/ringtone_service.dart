import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

enum RingtoneTarget {
  ringtone(1),
  notification(2),
  alarm(3),
  all(4);

  final int value;
  const RingtoneTarget(this.value);
}

class RingtonePermissionException implements Exception {
  final String message;
  const RingtonePermissionException([this.message = 'Permission required to modify system settings']);

  @override
  String toString() => message;
}

class RingtoneService {
  RingtoneService._();
  static final RingtoneService instance = RingtoneService._();

  static const MethodChannel _channel =
      MethodChannel('com.elysian.ananda/ringtone');

  /// Check if the app has permission to write system settings.
  Future<bool> canWriteSettings() async {
    try {
      final res = await _channel.invokeMethod<bool>('canWriteSettings');
      return res ?? false;
    } catch (_) {
      return true;
    }
  }

  /// Open system settings page to grant WRITE_SETTINGS permission.
  Future<bool> openWriteSettings() async {
    try {
      final res = await _channel.invokeMethod<bool>('openWriteSettings');
      return res ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Download the audio and set it directly as system ringtone/notification/alarm.
  Future<bool> setRingtone({
    required String audioUrl,
    required String title,
    RingtoneTarget target = RingtoneTarget.ringtone,
  }) async {
    try {
      final file = await DefaultCacheManager().getSingleFile(audioUrl);
      final result = await _channel.invokeMethod<bool>('setRingtone', {
        'filePath': file.path,
        'title': title,
        'type': target.value,
      });
      return result ?? false;
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        throw const RingtonePermissionException();
      }
      throw Exception(e.message ?? 'Failed to set ringtone');
    } catch (e) {
      if (e is RingtonePermissionException) rethrow;
      throw Exception('Could not apply ringtone: $e');
    }
  }
}
