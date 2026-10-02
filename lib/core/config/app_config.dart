/// Cloudinary configuration for the Ananda app.
///
/// ✅ Cloud Name and API Key are safe to ship in the app.
/// ❌ NEVER add API Secret here — it belongs only in your Cloudinary dashboard
///    or a secure server-side environment.
class AppConfig {
  AppConfig._();

  static const String cloudName = 'dfbcf8uz';

  static const String _cdnBase = 'https://res.cloudinary.com/$cloudName';

  /// Fixed link, no version number. Re-upload the file with the
  /// Public ID "catalog.json" and the app picks up the new content.
  static const String catalogUrl = '$_cdnBase/raw/upload/catalog.json';

  static String imageUrl(String publicId,
      {String transformation = 'q_auto,f_auto'}) {
    return '$_cdnBase/image/upload/$transformation/$publicId';
  }

  static String audioUrl(String publicId) {
    return '$_cdnBase/video/upload/$publicId';
  }

  // PDFs: if the link 404s, try '$_cdnBase/image/upload/$publicId.pdf'
  static String rawUrl(String publicId) {
    return '$_cdnBase/raw/upload/$publicId';
  }

  static const String thumbTransform = 'w_300,h_300,c_fill,q_auto,f_auto';
  static const String wallpaperThumbTransform = 'w_400,h_700,c_fill,q_auto,f_auto';
  static const String wallpaperFullTransform = 'w_1080,h_1920,c_fill,q_auto,f_auto';
  static const String coverTransform = 'w_200,h_280,c_fill,q_auto,f_auto';
}
