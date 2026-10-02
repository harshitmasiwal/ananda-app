import '../config/app_config.dart';

class RingtoneModel {
  final String id;
  final String title;
  final String titleHi;
  final String category; // e.g. 'mantra', 'bhajan', 'flute', 'bells'
  final String audioPublicId;
  final int? durationSeconds;

  const RingtoneModel({
    required this.id,
    required this.title,
    required this.titleHi,
    required this.category,
    required this.audioPublicId,
    this.durationSeconds,
  });

  String get audioUrl => AppConfig.audioUrl(audioPublicId);

  String get durationLabel {
    if (durationSeconds == null) return '';
    final m = durationSeconds! ~/ 60;
    final s = durationSeconds! % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  factory RingtoneModel.fromJson(Map<String, dynamic> json) {
    return RingtoneModel(
      id: json['id'] as String,
      title: json['title'] as String,
      titleHi: (json['titleHi'] as String?) ?? json['title'] as String,
      category: (json['category'] as String?) ?? 'mantra',
      audioPublicId: json['audioPublicId'] as String,
      durationSeconds: json['durationSeconds'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'titleHi': titleHi,
        'category': category,
        'audioPublicId': audioPublicId,
        'durationSeconds': durationSeconds,
      };
}
