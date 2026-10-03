import '../config/app_config.dart';

class HolyBookModel {
  final String id;
  final String title;
  final String titleHi;
  final String author;
  final String authorHi;
  final String description;
  final String descriptionHi;
  final String pdfPublicId;   // Cloudinary public_id for PDF
  final String coverPublicId; // Cloudinary public_id for cover image
  final int? pageCount;
  final String? _directPdfUrl;   // direct URL from catalog (v2.0+)
  final String? _directCoverUrl; // direct cover URL from catalog (v2.0+)

  const HolyBookModel({
    required this.id,
    required this.title,
    required this.titleHi,
    required this.author,
    required this.authorHi,
    required this.description,
    required this.descriptionHi,
    required this.pdfPublicId,
    required this.coverPublicId,
    this.pageCount,
    String? directPdfUrl,
    String? directCoverUrl,
  })  : _directPdfUrl = directPdfUrl,
        _directCoverUrl = directCoverUrl;

  /// PDF URL — prefers direct URL from catalog (v2.0+).
  /// NOTE: in the dfbcf8uz account, PDFs were uploaded under /image/upload/,
  /// so we use the direct URL when available to avoid resource-type mismatches.
  String get pdfUrl => _directPdfUrl ?? AppConfig.rawUrl(pdfPublicId);

  /// Cover image URL — prefers direct URL from catalog (v2.0+).
  String get coverUrl =>
      _directCoverUrl ??
      AppConfig.imageUrl(coverPublicId, transformation: AppConfig.coverTransform);

  factory HolyBookModel.fromJson(Map<String, dynamic> json) {
    return HolyBookModel(
      id: json['id'] as String,
      title: json['title'] as String,
      titleHi: (json['titleHi'] as String?) ?? json['title'] as String,
      author: (json['author'] as String?) ?? '',
      authorHi: (json['authorHi'] as String?) ?? '',
      description: (json['description'] as String?) ?? '',
      descriptionHi: (json['descriptionHi'] as String?) ?? '',
      pdfPublicId: (json['pdfPublicId'] as String?) ?? '',
      coverPublicId: (json['coverPublicId'] as String?) ?? '',
      pageCount: json['pageCount'] as int?,
      directPdfUrl: json['pdfUrl'] as String?,
      directCoverUrl: json['coverUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'titleHi': titleHi,
        'author': author,
        'authorHi': authorHi,
        'description': description,
        'descriptionHi': descriptionHi,
        'pdfPublicId': pdfPublicId,
        'coverPublicId': coverPublicId,
        'pageCount': pageCount,
        if (_directPdfUrl != null) 'pdfUrl': _directPdfUrl,
        if (_directCoverUrl != null) 'coverUrl': _directCoverUrl,
      };
}
