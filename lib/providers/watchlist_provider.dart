import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:phimhayokup/models/movie.dart';

const _kWatchlistKey = 'watchlist_v1';

class WatchlistNotifier extends Notifier<List<Movie>> {
  @override
  List<Movie> build() {
    _load();
    return [];
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_kWatchlistKey) ?? [];
    final movies = raw
        .map((s) => Movie.fromJson(json.decode(s) as Map<String, dynamic>))
        .toList();
    state = movies;
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = state.map((m) => json.encode(_toJson(m))).toList();
    await prefs.setStringList(_kWatchlistKey, raw);
  }

  bool contains(int movieId) => state.any((m) => m.id == movieId);

  Future<void> toggle(Movie movie) async {
    if (contains(movie.id)) {
      state = state.where((m) => m.id != movie.id).toList();
    } else {
      state = [movie, ...state];
    }
    await _save();
  }

  Map<String, dynamic> _toJson(Movie m) => {
    'id': m.id,
    'title': m.title,
    'original_title': m.originalTitle,
    'overview': m.overview,
    'poster_path': m.posterPath,
    'backdrop_path': m.backdropPath,
    'vote_average': m.voteAverage,
    'vote_count': m.voteCount,
    'release_date': m.releaseDate,
    'genre_ids': m.genreIds,
    'adult': m.isAdult,
    'media_type': m.mediaType,
  };
}

final watchlistProvider = NotifierProvider<WatchlistNotifier, List<Movie>>(
  WatchlistNotifier.new,
);
