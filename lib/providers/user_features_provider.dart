import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phimhayokup/models/movie.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum MovieCollection { wantToWatch, watched, favorite }

extension MovieCollectionX on MovieCollection {
  String get key => switch (this) {
    MovieCollection.wantToWatch => 'want_to_watch',
    MovieCollection.watched => 'watched',
    MovieCollection.favorite => 'favorite',
  };

  String get label => switch (this) {
    MovieCollection.wantToWatch => 'Muốn xem',
    MovieCollection.watched => 'Đã xem',
    MovieCollection.favorite => 'Yêu thích',
  };
}

const _collectionsKey = 'movie_collections_v1';
const _releaseRemindersKey = 'release_reminders_v1';
const _preferredPlatformsKey = 'preferred_platforms_v1';
const _detailViewsKey = 'detail_views_v1';
const _watchlistAddsKey = 'watchlist_adds_v1';

Map<String, dynamic> _movieToJson(Movie m) => {
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

class MovieCollectionsNotifier
    extends Notifier<Map<MovieCollection, List<Movie>>> {
  @override
  Map<MovieCollection, List<Movie>> build() {
    _load();
    return {
      for (final collection in MovieCollection.values) collection: <Movie>[],
    };
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_collectionsKey);
    if (raw == null || raw.isEmpty) return;
    final decoded = json.decode(raw) as Map<String, dynamic>;
    state = {
      for (final collection in MovieCollection.values)
        collection: ((decoded[collection.key] as List<dynamic>?) ?? [])
            .map((e) => Movie.fromJson(e as Map<String, dynamic>))
            .toList(),
    };
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = {
      for (final entry in state.entries)
        entry.key.key: entry.value.map(_movieToJson).toList(),
    };
    await prefs.setString(_collectionsKey, json.encode(encoded));
  }

  bool contains(MovieCollection collection, int movieId) {
    return state[collection]?.any((m) => m.id == movieId) ?? false;
  }

  Future<void> toggle(MovieCollection collection, Movie movie) async {
    final current = state[collection] ?? [];
    final updated = contains(collection, movie.id)
        ? current.where((m) => m.id != movie.id).toList()
        : [movie, ...current];
    state = {...state, collection: updated};
    await _save();
  }

  Future<void> clear(MovieCollection collection) async {
    state = {...state, collection: <Movie>[]};
    await _save();
  }
}

final movieCollectionsProvider =
    NotifierProvider<
      MovieCollectionsNotifier,
      Map<MovieCollection, List<Movie>>
    >(MovieCollectionsNotifier.new);

class ReleaseRemindersNotifier extends Notifier<Set<int>> {
  @override
  Set<int> build() {
    _load();
    return <int>{};
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final ids = prefs.getStringList(_releaseRemindersKey) ?? [];
    state = ids.map(int.parse).toSet();
  }

  Future<void> toggle(int movieId) async {
    final updated = {...state};
    updated.contains(movieId) ? updated.remove(movieId) : updated.add(movieId);
    state = updated;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _releaseRemindersKey,
      updated.map((id) => '$id').toList(),
    );
  }
}

final releaseRemindersProvider =
    NotifierProvider<ReleaseRemindersNotifier, Set<int>>(
      ReleaseRemindersNotifier.new,
    );

class PreferredPlatformsNotifier extends Notifier<List<String>> {
  @override
  List<String> build() {
    _load();
    return [];
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getStringList(_preferredPlatformsKey) ?? [];
  }

  Future<void> toggle(String platformName) async {
    final updated = state.contains(platformName)
        ? state.where((name) => name != platformName).toList()
        : [platformName, ...state];
    state = updated;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_preferredPlatformsKey, updated);
  }
}

final preferredPlatformsProvider =
    NotifierProvider<PreferredPlatformsNotifier, List<String>>(
      PreferredPlatformsNotifier.new,
    );

final detailViewsProvider = FutureProvider<int>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getInt(_detailViewsKey) ?? 0;
});

Future<int> incrementDetailViews() async {
  final prefs = await SharedPreferences.getInstance();
  final count = (prefs.getInt(_detailViewsKey) ?? 0) + 1;
  await prefs.setInt(_detailViewsKey, count);
  return count;
}

Future<int> incrementWatchlistAdds() async {
  final prefs = await SharedPreferences.getInstance();
  final count = (prefs.getInt(_watchlistAddsKey) ?? 0) + 1;
  await prefs.setInt(_watchlistAddsKey, count);
  return count;
}
