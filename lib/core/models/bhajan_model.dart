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
    final pid = publicId.toLowerCase();
    final rawTitle = (json['title'] as String?) ?? 'Bhajan';
    final bytes = json['bytes'] as num?;
    final int? durationSec = json['durationSeconds'] as int? ??
        (bytes != null ? (bytes / 16000).round() : null);

    String title = rawTitle;
    String? titleHi = json['titleHi'] as String?;
    String artist = (json['artist'] as String?) ?? '';
    String? artistHi = json['artistHi'] as String?;
    String category = (json['category'] as String?) ?? 'general';

    if (pid.contains('subah') || pid.contains('namashivaye') || rawTitle.toLowerCase().contains('namashivaye')) {
      title = 'Aisi Subah Na Aaye - Om Namah Shivaya';
      titleHi = (titleHi != null && titleHi.trim().isNotEmpty) ? titleHi : 'ऐसी सुबह ना आए - ॐ नमः शिवाय';
      category = 'shiv';
    } else if (pid.contains('maa_ka_dil') || rawTitle.toLowerCase().contains('maa ka dil')) {
      title = 'Maa Ka Dil';
      titleHi = (titleHi != null && titleHi.trim().isNotEmpty) ? titleHi : 'माँ का दिल';
      category = 'mata-rani';
    } else if (pid.contains('jay_ambe') || rawTitle.toLowerCase().contains('ambe')) {
      title = 'Jay Ambe Gouri Aarti';
      titleHi = (titleHi != null && titleHi.trim().isNotEmpty) ? titleHi : 'जय अंबे गौरी आरती';
      category = 'mata-rani';
    } else if (pid.contains('hanuman_vandna') || rawTitle.toLowerCase().contains('hanuman vandna')) {
      title = 'Shri Hanuman Vandna';
      titleHi = (titleHi != null && titleHi.trim().isNotEmpty) ? titleHi : 'श्री हनुमान वंदना';
      category = 'hanuman';
    } else {
      if (titleHi == null || titleHi.trim().isEmpty) titleHi = title;
    }

    if (artist.isEmpty) artist = 'Devotional';
    if (artistHi == null || artistHi.trim().isEmpty) artistHi = 'भक्तिमय';

    return BhajanModel(
      id: json['id'] as String,
      title: title,
      titleHi: titleHi,
      artist: artist,
      artistHi: artistHi,
      category: category,
      audioPublicId: publicId,
      coverPublicId: json['coverPublicId'] as String?,
      durationSeconds: durationSec,
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
