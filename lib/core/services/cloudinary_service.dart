import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
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

  /// Fallback catalog — mirrors the live catalog.json so the app
  /// works without network access.
  static AppCatalog get fallback => AppCatalog.fromJson(_fallbackJson);
}

// ── Cloudinary Service ─────────────────────────────────────────────────────────

class CloudinaryService {
  CloudinaryService._();

  static final CloudinaryService instance = CloudinaryService._();

  AppCatalog? _cachedCatalog;
  DateTime? _lastFetched;
  static const _cacheDuration = Duration(hours: 1);
  static const _catalogCacheKey = 'cached_cloudinary_catalog_json';

  /// Fetch the content catalog from Cloudinary.
  /// Returns in-memory cached version if < 1 hour old.
  /// Persists to SharedPreferences so all content works offline.
  /// Falls back to persisted local cache, then [AppCatalog.fallback] on network error.
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

        // Persist to local disk for offline usage
        try {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(_catalogCacheKey, response.body);
        } catch (_) {}

        return _cachedCatalog!;
      } else {
        return await _loadFromLocalOrFallback();
      }
    } catch (_) {
      return await _loadFromLocalOrFallback();
    }
  }

  Future<AppCatalog> _loadFromLocalOrFallback() async {
    if (_cachedCatalog != null) return _cachedCatalog!;
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedJson = prefs.getString(_catalogCacheKey);
      if (savedJson != null && savedJson.isNotEmpty) {
        final json = jsonDecode(savedJson) as Map<String, dynamic>;
        _cachedCatalog = AppCatalog.fromJson(json);
        return _cachedCatalog!;
      }
    } catch (_) {}
    return AppCatalog.fallback;
  }

  void clearCache() {
    _cachedCatalog = null;
    _lastFetched = null;
  }
}

// ── Fallback catalog (v2.0 — mirrors live catalog.json) ───────────────────────
// Update this whenever you update catalog.json on Cloudinary.

const _fallbackJson = {
  'version': '2.0',
  'wallpapers': [
    {
      'id': 'w1',
      'title': 'Shri Hanuman',
      'titleHi': 'श्री हनुमान जी',
      'category': 'hanuman',
      'publicId': 'wallpaper_2',
      'format': 'png',
      'isFeatured': true,
      'url': 'https://res.cloudinary.com/dfbcf8uz/image/upload/v1790970459/wallpaper_2.png',
    },
    {
      'id': 'w2',
      'title': 'Mahadev Shiva',
      'titleHi': 'महादेव शिव',
      'category': 'shiv',
      'publicId': 'wallpaper_1',
      'format': 'png',
      'isFeatured': true,
      'url': 'https://res.cloudinary.com/dfbcf8uz/image/upload/v1790970413/wallpaper_1.png',
    },
  ],
  'bhajans': [
    {
      'id': 'b1',
      'title': 'Namashivaye Om Namashivaye',
      'titleHi': 'ॐ नमः शिवाय',
      'artist': 'Devotional',
      'artistHi': 'भक्तिमय',
      'category': 'shiv',
      'publicId': '01_AISI_SUBAH_NA_AAYE',
      'format': 'mp3',
      'url': 'https://res.cloudinary.com/dfbcf8uz/video/upload/v1790967968/01_AISI_SUBAH_NA_AAYE.mp3',
      'bytes': 6668973,
    },
    {
      'id': 'b2',
      'title': 'Maa Ka Dil',
      'titleHi': 'माँ का दिल',
      'artist': 'Devotional',
      'artistHi': 'भक्तिमय',
      'category': 'mata-rani',
      'publicId': '01_maa_ka_dil',
      'format': 'mp3',
      'url': 'https://res.cloudinary.com/dfbcf8uz/video/upload/v1790967505/01_maa_ka_dil.mp3',
      'bytes': 12494976,
    },
    {
      'id': 'b3',
      'title': 'Jay Ambe Gouri',
      'titleHi': 'जय अंबे गौरी',
      'artist': 'Devotional',
      'artistHi': 'भक्तिमय',
      'category': 'mata-rani',
      'publicId': '06_Jay_Ambe_Gouri',
      'format': 'mp3',
      'url': 'https://res.cloudinary.com/dfbcf8uz/video/upload/v1790967501/06_Jay_Ambe_Gouri.mp3',
      'bytes': 7522395,
    },
    {
      'id': 'b4',
      'title': 'Hanuman Vandna',
      'titleHi': 'हनुमान वंदना',
      'artist': 'Devotional',
      'artistHi': 'भक्तिमय',
      'category': 'hanuman',
      'publicId': '58_hanuman_vandna',
      'format': 'mp3',
      'url': 'https://res.cloudinary.com/dfbcf8uz/video/upload/v1790967455/58_hanuman_vandna.mp3',
      'bytes': 2321345,
    },
  ],
  'holyBooks': [
    {
      'id': 'hb1',
      'title': 'Holy Book 2',
      'titleHi': '',
      'pdfPublicId': 'holybook_2',
      'pdfUrl': 'https://res.cloudinary.com/dfbcf8uz/image/upload/v1790967544/holybook_2.pdf',
      'coverPublicId': 'holy_book_1',
      'coverUrl': 'https://res.cloudinary.com/dfbcf8uz/image/upload/v1790967558/holy_book_1.png',
    },
    {
      'id': 'hb2',
      'title': 'Holy Book 1',
      'titleHi': '',
      'pdfPublicId': 'holy_book1',
      'pdfUrl': 'https://res.cloudinary.com/dfbcf8uz/image/upload/v1790967543/holy_book1.pdf',
      'coverPublicId': 'holy_book_2',
      'coverUrl': 'https://res.cloudinary.com/dfbcf8uz/image/upload/v1790967559/holy_book_2.png',
    },
  ],
  'ringtones': [
    {
      'id': 'r1',
      'title': 'Jai Jai Shri Ram - Jai Bola',
      'titleHi': 'जय जय श्री राम - जय बोला',
      'category': 'mantra',
      'publicId': 'JAI_BOLA',
      'format': 'mp3',
      'url': 'https://res.cloudinary.com/dfbcf8uz/video/upload/v1790967518/JAI_BOLA.mp3',
      'bytes': 6580157,
    },
    {
      'id': 'r2',
      'title': 'Pawan Sut Vinti Barambar',
      'titleHi': 'पवन सुत विनती बारंबार',
      'category': 'bhajan',
      'publicId': '57_pawan_sut_vinti_barambar',
      'format': 'mp3',
      'url': 'https://res.cloudinary.com/dfbcf8uz/video/upload/v1790967516/57_pawan_sut_vinti_barambar.mp3',
      'bytes': 5492820,
    },
  ],
};
