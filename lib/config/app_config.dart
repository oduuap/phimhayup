class AppConfig {
  // The TMDB API key must stay on the Cloudflare Worker, not in the app binary.
  static const String tmdbProxyUrl =
      'https://polished-surf-dec3.nguyendong310501.workers.dev/3';
  static const String tmdbImageBase = 'https://image.tmdb.org/t/p';
  static const String tmdbPosterW500 = '$tmdbImageBase/w500';
  static const String tmdbPosterOriginal = '$tmdbImageBase/original';
  static const String tmdbBackdropW1280 = '$tmdbImageBase/w1280';

  static const String appName = 'PhimHay';
  static const String appVersion = '1.0.0';
  static const String supportEmail = 'support@phimhay.app';
  static const String privacyPolicyUrl = 'https://phimhay.app/privacy';
  static const String termsUrl = 'https://phimhay.app/terms';
  static const String tmdbAttribution =
      'This product uses the TMDB API but is not endorsed or certified by TMDB.';
  static const String language = 'vi-VN';
  static const String region = 'VN';
}
