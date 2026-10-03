import '../config/app_config.dart';

class RingtoneModel {
  final String id;
  final String title;
  final String titleHi;
  final String category; // e.g. 'mantra', 'bhajan', 'flute', 'bells'
  final String audioPublicId;
  final int? durationSeconds;
  final String? _directAudioUrl; // direct URL from catalog (v2.0+)

  const RingtoneModel({
    required this.id,
    required this.title,
    required this.titleHi,
    required this.category,
    required this.audioPublicId,
    this.durationSeconds,
    String? directAudioUrl,
  }) : _directAudioUrl = directAudioUrl;

  /// Audio URL — prefers direct URL from catalog (v2.0+) over built URL.
  String get audioUrl => _directAudioUrl ?? AppConfig.audioUrl(audioPublicId);

  String get durationLabel {
    if (durationSeconds == null) return '';
    final m = durationSeconds! ~/ 60;
    final s = durationSeconds! % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  factory RingtoneModel.fromJson(Map<String, dynamic> json) {
    // v2.0 uses 'publicId'; v1.0 used 'audioPublicId'
    final publicId =
        (json['audioPublicId'] as String?) ?? (json['publicId'] as String?) ?? '';
    return RingtoneModel(
      id: json['id'] as String,
      title: json['title'] as String,
      titleHi: (json['titleHi'] as String?) ?? json['title'] as String,
      category: (json['category'] as String?) ?? 'mantra',
      audioPublicId: publicId,
      durationSeconds: json['durationSeconds'] as int?,
      directAudioUrl: json['url'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'titleHi': titleHi,
        'category': category,
        'audioPublicId': audioPublicId,
        'durationSeconds': durationSeconds,
        if (_directAudioUrl != null) 'url': _directAudioUrl,
      };
}
