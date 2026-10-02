import '../config/app_config.dart';

class WallpaperModel {
  final String id;
  final String title;
  final String titleHi;
  final String category; // e.g. 'hanuman', 'shiv', 'mata-rani', 'nature'
  final String publicId;  // Cloudinary public_id
  final bool isFeatured;

  const WallpaperModel({
    required this.id,
    required this.title,
    required this.titleHi,
    required this.category,
    required this.publicId,
    this.isFeatured = false,
  });

  String get thumbnailUrl =>
      AppConfig.imageUrl(publicId, transformation: AppConfig.wallpaperThumbTransform);

  String get fullUrl =>
      AppConfig.imageUrl(publicId, transformation: AppConfig.wallpaperFullTransform);

  factory WallpaperModel.fromJson(Map<String, dynamic> json) {
    return WallpaperModel(
      id: json['id'] as String,
      title: json['title'] as String,
      titleHi: (json['titleHi'] as String?) ?? json['title'] as String,
      category: json['category'] as String,
      publicId: json['publicId'] as String,
      isFeatured: (json['isFeatured'] as bool?) ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'titleHi': titleHi,
        'category': category,
        'publicId': publicId,
        'isFeatured': isFeatured,
      };
}
