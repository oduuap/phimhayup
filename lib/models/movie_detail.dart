import 'package:phimhayokup/config/app_config.dart';

class Genre {
  final int id;
  final String name;

  const Genre({required this.id, required this.name});

  factory Genre.fromJson(Map<String, dynamic> json) =>
      Genre(id: json['id'] as int, name: json['name'] as String);
}

class ProductionCountry {
  final String code;
  final String name;

  const ProductionCountry({required this.code, required this.name});

  factory ProductionCountry.fromJson(Map<String, dynamic> json) =>
      ProductionCountry(
        code: json['iso_3166_1'] as String,
        name: json['name'] as String,
      );
}

class Video {
  final String id;
  final String key;
  final String name;
  final String site;
  final String type;

  const Video({
    required this.id,
    required this.key,
    required this.name,
    required this.site,
    required this.type,
  });

  bool get isYouTubeTrailer =>
      site == 'YouTube' && (type == 'Trailer' || type == 'Teaser');

  factory Video.fromJson(Map<String, dynamic> json) => Video(
        id: json['id'] as String,
        key: json['key'] as String,
        name: json['name'] as String,
        site: json['site'] as String,
        type: json['type'] as String,
      );
}

class CastMember {
  final int id;
  final String name;
  final String character;
  final String? profilePath;

  const CastMember({
    required this.id,
    required this.name,
    required this.character,
    this.profilePath,
  });

  String get profileUrl =>
      profilePath != null ? '${AppConfig.tmdbImageBase}/w185$profilePath' : '';

  factory CastMember.fromJson(Map<String, dynamic> json) => CastMember(
        id: json['id'] as int,
        name: json['name'] as String,
        character: (json['character'] ?? '') as String,
        profilePath: json['profile_path'] as String?,
      );
}

class MovieDetail {
  final int id;
  final String title;
  final String originalTitle;
  final String overview;
  final String? posterPath;
  final String? backdropPath;
  final double voteAverage;
  final int voteCount;
  final String? releaseDate;
  final int? runtime;
  final List<Genre> genres;
  final List<ProductionCountry> productionCountries;
  final String status;
  final String? tagline;
  final List<Video> videos;
  final List<CastMember> cast;
  final List<MovieDetail> similar;

  const MovieDetail({
    required this.id,
    required this.title,
    required this.originalTitle,
    required this.overview,
    this.posterPath,
    this.backdropPath,
    required this.voteAverage,
    required this.voteCount,
    this.releaseDate,
    this.runtime,
    required this.genres,
    required this.productionCountries,
    required this.status,
    this.tagline,
    required this.videos,
    required this.cast,
    required this.similar,
  });

  String get posterUrl =>
      posterPath != null ? '${AppConfig.tmdbPosterW500}$posterPath' : '';

  String get backdropUrl =>
      backdropPath != null ? '${AppConfig.tmdbBackdropW1280}$backdropPath' : '';

  String get year => releaseDate != null && releaseDate!.isNotEmpty
      ? releaseDate!.substring(0, 4)
      : '';

  String get runtimeFormatted {
    if (runtime == null || runtime == 0) return '';
    final h = runtime! ~/ 60;
    final m = runtime! % 60;
    return h > 0 ? '${h}g ${m}p' : '${m}p';
  }

  Video? get trailer =>
      videos.where((v) => v.isYouTubeTrailer).isNotEmpty
          ? videos.firstWhere((v) => v.isYouTubeTrailer)
          : null;

  factory MovieDetail.fromJson(Map<String, dynamic> json) {
    final creditsJson = json['credits'] as Map<String, dynamic>?;
    final videosJson = json['videos'] as Map<String, dynamic>?;
    final similarJson = json['similar'] as Map<String, dynamic>?;

    return MovieDetail(
      id: json['id'] as int,
      title: (json['title'] ?? json['name'] ?? '') as String,
      originalTitle:
          (json['original_title'] ?? json['original_name'] ?? '') as String,
      overview: (json['overview'] ?? '') as String,
      posterPath: json['poster_path'] as String?,
      backdropPath: json['backdrop_path'] as String?,
      voteAverage: ((json['vote_average'] ?? 0.0) as num).toDouble(),
      voteCount: (json['vote_count'] ?? 0) as int,
      releaseDate: (json['release_date'] ?? json['first_air_date']) as String?,
      runtime: json['runtime'] as int?,
      genres: (json['genres'] as List<dynamic>?)
              ?.map((e) => Genre.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      productionCountries:
          (json['production_countries'] as List<dynamic>?)
              ?.map((e) =>
                  ProductionCountry.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      status: (json['status'] ?? '') as String,
      tagline: json['tagline'] as String?,
      videos: (videosJson?['results'] as List<dynamic>?)
              ?.map((e) => Video.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      cast: (creditsJson?['cast'] as List<dynamic>?)
              ?.take(15)
              .map((e) => CastMember.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      similar: (similarJson?['results'] as List<dynamic>?)
              ?.take(10)
              .map((e) => MovieDetail._fromSimpleJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  factory MovieDetail._fromSimpleJson(Map<String, dynamic> json) {
    return MovieDetail(
      id: json['id'] as int,
      title: (json['title'] ?? json['name'] ?? '') as String,
      originalTitle:
          (json['original_title'] ?? json['original_name'] ?? '') as String,
      overview: (json['overview'] ?? '') as String,
      posterPath: json['poster_path'] as String?,
      backdropPath: json['backdrop_path'] as String?,
      voteAverage: ((json['vote_average'] ?? 0.0) as num).toDouble(),
      voteCount: (json['vote_count'] ?? 0) as int,
      releaseDate: json['release_date'] as String?,
      genres: [],
      productionCountries: [],
      status: '',
      videos: [],
      cast: [],
      similar: [],
    );
  }
}
