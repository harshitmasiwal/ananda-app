import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/wallpaper_model.dart';
import '../models/bhajan_model.dart';
import '../models/holy_book_model.dart';
import '../models/ringtone_model.dart';

/// The full content catalog fetched from Cloudinary.
class AppCatalog {
  final List<WallpaperModel> wallpapers;
  final List<BhajanModel> bhajans;
  final List<HolyBookModel> holyBooks;
  final List<RingtoneModel> ringtones;
  final String version;

  const AppCatalog({
    required this.wallpapers,
    required this.bhajans,
    required this.holyBooks,
    required this.ringtones,
    required this.version,
  });

  factory AppCatalog.fromJson(Map<String, dynamic> json) {
    return AppCatalog(
      version: (json['version'] as String?) ?? '1.0',
      wallpapers: (json['wallpapers'] as List<dynamic>? ?? [])
          .map((e) => WallpaperModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      bhajans: (json['bhajans'] as List<dynamic>? ?? [])
          .map((e) => BhajanModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      holyBooks: (json['holyBooks'] as List<dynamic>? ?? [])
          .map((e) => HolyBookModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      ringtones: (json['ringtones'] as List<dynamic>? ?? [])
          .map((e) => RingtoneModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Fallback catalog with your actual uploaded files.
  /// Update public IDs once files are uploaded to Cloudinary.
  static AppCatalog get fallback => AppCatalog.fromJson(_fallbackJson);
}

/// ── Cloudinary Service ───────────────────────────────────────────────────────

class CloudinaryService {
  CloudinaryService._();

  static final CloudinaryService instance = CloudinaryService._();

  AppCatalog? _cachedCatalog;
  DateTime? _lastFetched;
  static const _cacheDuration = Duration(hours: 1);

  /// Fetch the content catalog from Cloudinary.
  /// Returns cached version if < 1 hour old.
  /// Falls back to [AppCatalog.fallback] on network error.
  Future<AppCatalog> fetchCatalog({bool forceRefresh = false}) async {
    final now = DateTime.now();
    final isFresh = _lastFetched != null &&
        now.difference(_lastFetched!) < _cacheDuration;

    if (!forceRefresh && isFresh && _cachedCatalog != null) {
      return _cachedCatalog!;
    }

    try {
      final response = await http
          .get(Uri.parse(AppConfig.catalogUrl))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        _cachedCatalog = AppCatalog.fromJson(json);
        _lastFetched = now;
        return _cachedCatalog!;
      } else {
        return _cachedCatalog ?? AppCatalog.fallback;
      }
    } catch (_) {
      return _cachedCatalog ?? AppCatalog.fallback;
    }
  }

  void clearCache() {
    _cachedCatalog = null;
    _lastFetched = null;
  }
}

/// Fallback catalog (hardcoded with your actual files).
/// Public IDs follow the pattern: folder/filename (no extension for audio/image)
/// Example: 'ananda/bhajans/hanuman/58_hanuman_vandna'

const _fallbackJson = {
  'version': '1.0',
  'wallpapers': [
    {
      'id': 'w1',
      'title': 'Devotional Wallpaper 1',
      'titleHi': 'भक्ति वॉलपेपर १',
      'category': 'hanuman',
      'publicId': 'ananda/wallpapers/wallpaper_1',
      'isFeatured': true,
    },
    {
      'id': 'w2',
      'title': 'Devotional Wallpaper 2',
      'titleHi': 'भक्ति वॉलपेपर २',
      'category': 'hanuman',
      'publicId': 'ananda/wallpapers/wallpaper_2',
      'isFeatured': false,
    },
  ],
  'bhajans': [
    {
      'id': 'b1',
      'title': 'Pawan Sut Vinti Barambar',
      'titleHi': 'पवन सुत विनती बारंबार',
      'artist': 'Unknown',
      'artistHi': 'अज्ञात',
      'category': 'hanuman',
      'audioPublicId': 'ananda/bhajans/hanuman/57_pawan_sut_vinti_barambar',
    },
    {
      'id': 'b2',
      'title': 'Jai Bola',
      'titleHi': 'जय बोला',
      'artist': 'Unknown',
      'artistHi': 'अज्ञात',
      'category': 'hanuman',
      'audioPublicId': 'ananda/bhajans/hanuman/jai_bola',
    },
    {
      'id': 'b3',
      'title': 'Hanuman Vandna',
      'titleHi': 'हनुमान वंदना',
      'artist': 'Unknown',
      'artistHi': 'अज्ञात',
      'category': 'hanuman',
      'audioPublicId': 'ananda/bhajans/hanuman/58_hanuman_vandna',
    },
    {
      'id': 'b4',
      'title': 'Om Namashivaye',
      'titleHi': 'ॐ नमः शिवाय',
      'artist': 'Unknown',
      'artistHi': 'अज्ञात',
      'category': 'shiv',
      'audioPublicId': 'ananda/bhajans/shiv/01_namashivaye_om_namashivaye',
    },
    {
      'id': 'b5',
      'title': 'Maa Ka Dil',
      'titleHi': 'माँ का दिल',
      'artist': 'Unknown',
      'artistHi': 'अज्ञात',
      'category': 'mata-rani',
      'audioPublicId': 'ananda/bhajans/mata-rani/01_maa_ka_dil',
    },
    {
      'id': 'b6',
      'title': 'Jay Ambe Gouri',
      'titleHi': 'जय अंबे गौरी',
      'artist': 'Unknown',
      'artistHi': 'अज्ञात',
      'category': 'mata-rani',
      'audioPublicId': 'ananda/bhajans/mata-rani/06_jay_ambe_gouri',
    },
  ],
  'holyBooks': [
    {
      'id': 'hb1',
      'title': 'Holy Book 1',
      'titleHi': 'पवित्र ग्रंथ १',
      'author': 'Sacred Scripture',
      'authorHi': 'पवित्र शास्त्र',
      'description': 'A sacred devotional text.',
      'descriptionHi': 'एक पवित्र भक्ति ग्रंथ।',
      'pdfPublicId': 'ananda/holy-books/pdfs/holy_book_1',
      'coverPublicId': 'ananda/holy-books/covers/holy_book_1',
    },
    {
      'id': 'hb2',
      'title': 'Holy Book 2',
      'titleHi': 'पवित्र ग्रंथ २',
      'author': 'Sacred Scripture',
      'authorHi': 'पवित्र शास्त्र',
      'description': 'A sacred devotional text.',
      'descriptionHi': 'एक पवित्र भक्ति ग्रंथ।',
      'pdfPublicId': 'ananda/holy-books/pdfs/holy_book_2',
      'coverPublicId': 'ananda/holy-books/covers/holy_book_2',
    },
  ],
  'ringtones': [
    {
      'id': 'r1',
      'title': 'Jai Bola Ringtone',
      'titleHi': 'जय बोला रिंगटोन',
      'category': 'mantra',
      'audioPublicId': 'ananda/ringtones/jai_bola',
    },
    {
      'id': 'r2',
      'title': 'Pawan Sut Ringtone',
      'titleHi': 'पवन सुत रिंगटोन',
      'category': 'mantra',
      'audioPublicId': 'ananda/ringtones/pawan_sut_vinti_barambar',
    },
  ],
};
