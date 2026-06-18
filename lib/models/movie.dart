import 'package:phimhayokup/config/app_config.dart';

class Movie {
  final int id;
  final String title;
  final String originalTitle;
  final String overview;
  final String? posterPath;
  final String? backdropPath;
  final double voteAverage;
  final int voteCount;
  final String? releaseDate;
  final List<int> genreIds;
  final bool isAdult;
  final String mediaType;

  const Movie({
    required this.id,
    required this.title,
    required this.originalTitle,
    required this.overview,
    this.posterPath,
    this.backdropPath,
    required this.voteAverage,
    required this.voteCount,
    this.releaseDate,
    required this.genreIds,
    required this.isAdult,
    this.mediaType = 'movie',
  });

  String get posterUrl =>
      posterPath != null ? '${AppConfig.tmdbPosterW500}$posterPath' : '';

  String get backdropUrl =>
      backdropPath != null ? '${AppConfig.tmdbBackdropW1280}$backdropPath' : '';

  String get year => releaseDate != null && releaseDate!.isNotEmpty
      ? releaseDate!.substring(0, 4)
      : '';

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'] as int,
      title: (json['title'] ?? json['name'] ?? '') as String,
      originalTitle:
          (json['original_title'] ?? json['original_name'] ?? '') as String,
      overview: (json['overview'] ?? '') as String,
      posterPath: json['poster_path'] as String?,
      backdropPath: json['backdrop_path'] as String?,
      voteAverage: ((json['vote_average'] ?? 0.0) as num).toDouble(),
      voteCount: (json['vote_count'] ?? 0) as int,
      releaseDate:
          (json['release_date'] ?? json['first_air_date']) as String?,
      genreIds: (json['genre_ids'] as List<dynamic>?)
              ?.map((e) => e as int)
              .toList() ??
          [],
      isAdult: (json['adult'] ?? false) as bool,
      mediaType: (json['media_type'] ?? 'movie') as String,
    );
  }
}
