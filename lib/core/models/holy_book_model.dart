import '../config/app_config.dart';

class HolyBookModel {
  final String id;
  final String title;
  final String titleHi;
  final String author;
  final String authorHi;
  final String description;
  final String descriptionHi;
  final String pdfPublicId;    // Cloudinary raw public_id for PDF
  final String coverPublicId;  // Cloudinary image public_id for cover
  final int? pageCount;

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
  });

  String get pdfUrl => AppConfig.rawUrl(pdfPublicId);

  String get coverUrl =>
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
      pdfPublicId: json['pdfPublicId'] as String,
      coverPublicId: json['coverPublicId'] as String,
      pageCount: json['pageCount'] as int?,
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
      };
}
