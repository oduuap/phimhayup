import 'package:flutter/material.dart';
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

final movieDetailProvider = FutureProvider.family<MovieDetail, int>((ref, id) {
  return ref.watch(tmdbServiceProvider).getMovieDetail(id);
});

final personDetailProvider = FutureProvider.family<PersonDetail, int>((
  ref,
  id,
) {
  return ref.watch(tmdbServiceProvider).getPersonDetail(id);
});

final searchQueryProvider = StateProvider<String>((ref) => '');

final searchResultsProvider = FutureProvider<List<Movie>>((ref) {
  final query = ref.watch(searchQueryProvider);
  if (query.isEmpty) return Future.value([]);
  return ref.watch(tmdbServiceProvider).searchMovies(query);
});

final selectedGenreProvider = StateProvider<int?>((ref) => null);

class MoodPreset {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final int genreId;
  final String sortBy;
  final double? minVote;

  const MoodPreset({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.genreId,
    required this.sortBy,
    this.minVote,
  });
}

final moodPresets = <MoodPreset>[
  const MoodPreset(
    id: 'tonight',
    title: 'Tối nay xem gì',
    subtitle: 'Dễ xem, nhiều người thích',
    icon: Icons.nightlight_round,
    genreId: 35,
    sortBy: 'popularity.desc',
    minVote: 6.5,
  ),
  const MoodPreset(
    id: 'mind',
    title: 'Căng não',
    subtitle: 'Bí ẩn và hồi hộp',
    icon: Icons.psychology_alt_outlined,
    genreId: 9648,
    sortBy: 'vote_average.desc',
    minVote: 6.8,
  ),
  const MoodPreset(
    id: 'fast',
    title: 'Hành động nhanh',
    subtitle: 'Nhịp mạnh, ít dài dòng',
    icon: Icons.bolt_rounded,
    genreId: 28,
    sortBy: 'popularity.desc',
    minVote: 6.2,
  ),
  const MoodPreset(
    id: 'family',
    title: 'Xem cùng nhà',
    subtitle: 'Gia đình và hoạt hình',
    icon: Icons.groups_2_outlined,
    genreId: 10751,
    sortBy: 'popularity.desc',
    minVote: 6.0,
  ),
];

final selectedMoodProvider = StateProvider<MoodPreset?>((ref) => null);

final moodMoviesProvider = FutureProvider<List<Movie>>((ref) {
  final mood = ref.watch(selectedMoodProvider);
  if (mood == null) return Future.value([]);
  return ref
      .watch(tmdbServiceProvider)
      .discoverMovies(
        genreId: mood.genreId,
        sortBy: mood.sortBy,
        minVote: mood.minVote,
      );
});

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
