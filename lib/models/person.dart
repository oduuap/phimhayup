import 'package:phimhayokup/config/app_config.dart';
import 'package:phimhayokup/models/movie.dart';

class PersonDetail {
  final int id;
  final String name;
  final String biography;
  final String? birthday;
  final String? deathday;
  final String? placeOfBirth;
  final String? profilePath;
  final String knownFor;
  final List<Movie> movies;

  const PersonDetail({
    required this.id,
    required this.name,
    required this.biography,
    this.birthday,
    this.deathday,
    this.placeOfBirth,
    this.profilePath,
    required this.knownFor,
    required this.movies,
  });

  String get profileUrl =>
      profilePath != null ? '${AppConfig.tmdbImageBase}/w300$profilePath' : '';

  String get ageText {
    if (birthday == null) return '';
    final birth = DateTime.tryParse(birthday!);
    if (birth == null) return '';
    final end = deathday != null
        ? DateTime.tryParse(deathday!) ?? DateTime.now()
        : DateTime.now();
    final age = end.year -
        birth.year -
        ((end.month < birth.month ||
                (end.month == birth.month && end.day < birth.day))
            ? 1
            : 0);
    return deathday != null ? '$age tuổi (đã mất)' : '$age tuổi';
  }

  factory PersonDetail.fromJson(Map<String, dynamic> json) {
    final creditsJson = json['movie_credits'] as Map<String, dynamic>?;
    final castList = ((creditsJson?['cast'] as List<dynamic>?) ?? [])
        .where((e) => (e['poster_path'] as String?) != null)
        .map((e) => Movie.fromJson(e as Map<String, dynamic>))
        .toList();
    castList.sort((a, b) => b.voteAverage.compareTo(a.voteAverage));

    return PersonDetail(
      id: json['id'] as int,
      name: json['name'] as String,
      biography: (json['biography'] ?? '') as String,
      birthday: json['birthday'] as String?,
      deathday: json['deathday'] as String?,
      placeOfBirth: json['place_of_birth'] as String?,
      profilePath: json['profile_path'] as String?,
      knownFor: (json['known_for_department'] ?? 'Acting') as String,
      movies: castList.take(20).toList(),
    );
  }
}
