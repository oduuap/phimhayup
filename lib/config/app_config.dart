class AppConfig {
  static const String tmdbApiKey = '537e3cc37a8348e2f9c181f17ee7b9dd';
  static const String tmdbBearerToken =
      'eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiI1MzdlM2NjMzdhODM0OGUyZjljMTgxZjE3ZWU3YjlkZCIsIm5iZiI6MTc4MTI2NzMyMS4xNjEsInN1YiI6IjZhMmJmYjc5Yzc1OWNhYjRmMGMzYTE1ZCIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.gXP0yIucqAtxQluuvAwRy0UV17PWU34S2yoaOgrnuaA';

  // Replace with your Cloudflare Worker URL after deploying cloudflare-worker/worker.js
  // Example: 'https://tmdb-proxy.yourname.workers.dev/3'
  static const String tmdbBaseUrl = 'https://api.themoviedb.org/3';
  static const String tmdbImageBase = 'https://image.tmdb.org/t/p';
  static const String tmdbPosterW500 = '$tmdbImageBase/w500';
  static const String tmdbPosterOriginal = '$tmdbImageBase/original';
  static const String tmdbBackdropW1280 = '$tmdbImageBase/w1280';

  static const String appName = 'PhimHay';
  static const String language = 'vi-VN';
  static const String region = 'VN';
}
