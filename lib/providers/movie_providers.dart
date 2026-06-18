import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phimhayokup/models/movie.dart';
import 'package:phimhayokup/models/movie_detail.dart';
import 'package:phimhayokup/models/person.dart';
import 'package:phimhayokup/services/tmdb_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

final tmdbServiceProvider = Provider<TmdbService>((ref) => TmdbService());

final trendingMoviesProvider = FutureProvider<List<Movie>>((ref) {
  return ref.watch(tmdbServiceProvider).getTrending();
});

final popularMoviesProvider = FutureProvider<List<Movie>>((ref) {
  return ref.watch(tmdbServiceProvider).getPopular();
});

final nowPlayingProvider = FutureProvider<List<Movie>>((ref) {
  return ref.watch(tmdbServiceProvider).getNowPlaying();
});

final topRatedProvider = FutureProvider<List<Movie>>((ref) {
  return ref.watch(tmdbServiceProvider).getTopRated();
});

final upcomingProvider = FutureProvider<List<Movie>>((ref) {
  return ref.watch(tmdbServiceProvider).getUpcoming();
});

final movieDetailProvider =
    FutureProvider.family<MovieDetail, int>((ref, id) {
  return ref.watch(tmdbServiceProvider).getMovieDetail(id);
});

final personDetailProvider =
    FutureProvider.family<PersonDetail, int>((ref, id) {
  return ref.watch(tmdbServiceProvider).getPersonDetail(id);
});

final searchQueryProvider = StateProvider<String>((ref) => '');

final searchResultsProvider = FutureProvider<List<Movie>>((ref) {
  final query = ref.watch(searchQueryProvider);
  if (query.isEmpty) return Future.value([]);
  return ref.watch(tmdbServiceProvider).searchMovies(query);
});

final selectedGenreProvider = StateProvider<int?>((ref) => null);

final genreMoviesProvider = FutureProvider<List<Movie>>((ref) {
  final genreId = ref.watch(selectedGenreProvider);
  if (genreId == null) return Future.value([]);
  return ref.watch(tmdbServiceProvider).getByGenre(genreId);
});

class SearchHistoryNotifier extends StateNotifier<List<String>> {
  SearchHistoryNotifier() : super([]) {
    _load();
  }

  static const _key = 'search_history';
  static const _maxItems = 10;

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getStringList(_key) ?? [];
  }

  Future<void> add(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;
    final updated = [
      trimmed,
      ...state.where((s) => s != trimmed),
    ].take(_maxItems).toList();
    state = updated;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, updated);
  }

  Future<void> remove(String query) async {
    final updated = state.where((s) => s != query).toList();
    state = updated;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, updated);
  }

  Future<void> clear() async {
    state = [];
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}

final searchHistoryProvider =
    StateNotifierProvider<SearchHistoryNotifier, List<String>>(
  (ref) => SearchHistoryNotifier(),
);
