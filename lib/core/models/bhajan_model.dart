import '../config/app_config.dart';

class BhajanModel {
  final String id;
  final String title;
  final String titleHi;
  final String artist;
  final String artistHi;
  final String category; // 'hanuman' | 'shiv' | 'mata-rani'
  final String audioPublicId; // Cloudinary public_id for audio
  final String? coverPublicId; // optional cover art
  final int? durationSeconds;
  final String? _directAudioUrl; // direct URL from catalog (v2.0+)

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
    String? directAudioUrl,
  }) : _directAudioUrl = directAudioUrl;

  /// Audio URL — prefers direct URL from catalog (v2.0+) over built URL.
  String get audioUrl => _directAudioUrl ?? AppConfig.audioUrl(audioPublicId);

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
    // v2.0 uses 'publicId'; v1.0 used 'audioPublicId'
    final publicId =
        (json['audioPublicId'] as String?) ?? (json['publicId'] as String?) ?? '';
    return BhajanModel(
      id: json['id'] as String,
      title: json['title'] as String,
      titleHi: (json['titleHi'] as String?) ?? json['title'] as String,
      artist: (json['artist'] as String?) ?? '',
      artistHi: (json['artistHi'] as String?) ?? '',
      category: (json['category'] as String?) ?? 'general',
      audioPublicId: publicId,
      coverPublicId: json['coverPublicId'] as String?,
      durationSeconds: json['durationSeconds'] as int?,
      directAudioUrl: json['url'] as String?,
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
        if (_directAudioUrl != null) 'url': _directAudioUrl,
      };
}
