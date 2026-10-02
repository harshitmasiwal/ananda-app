import '../config/app_config.dart';

class BhajanModel {
  final String id;
  final String title;
  final String titleHi;
  final String artist;
  final String artistHi;
  final String category; // 'hanuman' | 'shiv' | 'mata-rani'
  final String audioPublicId;   // Cloudinary public_id for audio
  final String? coverPublicId;  // optional cover art
  final int? durationSeconds;

  const BhajanModel({
    required this.id,
    required this.title,
    required this.titleHi,
    required this.artist,
    required this.artistHi,
    required this.category,
    required this.audioPublicId,
    this.coverPublicId,
    this.durationSeconds,
  });

  String get audioUrl => AppConfig.audioUrl(audioPublicId);

  String? get coverUrl => coverPublicId != null
      ? AppConfig.imageUrl(coverPublicId!, transformation: AppConfig.thumbTransform)
      : null;

  String get durationLabel {
    if (durationSeconds == null) return '';
    final m = durationSeconds! ~/ 60;
    final s = durationSeconds! % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  factory BhajanModel.fromJson(Map<String, dynamic> json) {
    return BhajanModel(
      id: json['id'] as String,
      title: json['title'] as String,
      titleHi: (json['titleHi'] as String?) ?? json['title'] as String,
      artist: (json['artist'] as String?) ?? '',
      artistHi: (json['artistHi'] as String?) ?? '',
      category: json['category'] as String,
      audioPublicId: json['audioPublicId'] as String,
      coverPublicId: json['coverPublicId'] as String?,
      durationSeconds: json['durationSeconds'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'titleHi': titleHi,
        'artist': artist,
        'artistHi': artistHi,
        'category': category,
        'audioPublicId': audioPublicId,
        'coverPublicId': coverPublicId,
        'durationSeconds': durationSeconds,
      };
}
