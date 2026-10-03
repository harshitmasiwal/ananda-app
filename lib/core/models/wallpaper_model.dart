import '../config/app_config.dart';

class WallpaperModel {
  final String id;
  final String title;
  final String titleHi;
  final String category; // e.g. 'hanuman', 'shiv', 'mata-rani', 'nature'
  final String publicId; // Cloudinary public_id
  final bool isFeatured;
  final String? _directUrl; // direct URL from catalog (v2.0+)

  const WallpaperModel({
    required this.id,
    required this.title,
    required this.titleHi,
    required this.category,
    required this.publicId,
    this.isFeatured = false,
    String? directUrl,
  }) : _directUrl = directUrl;

  /// Thumbnail URL — uses direct URL from catalog when available.
  String get thumbnailUrl =>
      _directUrl ??
      AppConfig.imageUrl(publicId, transformation: AppConfig.wallpaperThumbTransform);

  /// Full-res URL — uses direct URL from catalog when available.
  String get fullUrl =>
      _directUrl ??
      AppConfig.imageUrl(publicId, transformation: AppConfig.wallpaperFullTransform);

  factory WallpaperModel.fromJson(Map<String, dynamic> json) {
    final rawTitle = (json['title'] as String?)?.trim() ?? '';
    final rawTitleHi = (json['titleHi'] as String?)?.trim() ?? '';

    // Use Cloudinary title / titleHi directly without hardcoded overrides
    final String title;
    final String titleHi;

    if (rawTitleHi.isNotEmpty) {
      title = rawTitleHi;
      titleHi = rawTitleHi;
    } else if (rawTitle.isNotEmpty) {
      title = rawTitle;
      titleHi = rawTitle;
    } else {
      title = 'Wallpaper';
      titleHi = 'वॉलपेपर';
    }

    final category = (json['category'] as String?) ?? 'all';

    return WallpaperModel(
      id: json['id'] as String,
      title: title,
      titleHi: titleHi,
      category: category,
      publicId: (json['publicId'] as String?) ?? '',
      isFeatured: (json['isFeatured'] as bool?) ?? true,
      directUrl: json['url'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'titleHi': titleHi,
        'category': category,
        'publicId': publicId,
        'isFeatured': isFeatured,
        if (_directUrl != null) 'url': _directUrl,
      };
}
