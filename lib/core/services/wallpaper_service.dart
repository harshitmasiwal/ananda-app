import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

enum WallpaperTarget {
  home(1),
  lock(2),
  both(3);

  final int value;
  const WallpaperTarget(this.value);
}

class WallpaperService {
  WallpaperService._();
  static final WallpaperService instance = WallpaperService._();

  static const MethodChannel _channel =
      MethodChannel('com.elysian.ananda/wallpaper');

  /// Downloads the wallpaper and directly applies it to the device (Home, Lock, or Both).
  Future<bool> setWallpaper({
    required String imageUrl,
    WallpaperTarget target = WallpaperTarget.both,
  }) async {
    try {
      final file = await DefaultCacheManager().getSingleFile(imageUrl);
      final result = await _channel.invokeMethod<bool>('setWallpaper', {
        'filePath': file.path,
        'location': target.value,
      });
      return result ?? false;
    } on MissingPluginException {
      throw Exception(
        'App restart required to initialize the wallpaper service. Please restart the app.',
      );
    } on PlatformException catch (e) {
      throw Exception(e.message ?? 'Failed to set wallpaper');
    } catch (e) {
      throw Exception('Could not apply wallpaper: $e');
    }
  }
}
