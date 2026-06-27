import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phimhayokup/models/movie.dart';
import 'package:phimhayokup/providers/movie_providers.dart';
import 'package:phimhayokup/utils/app_colors.dart';
import 'package:phimhayokup/utils/genre_data.dart';
import 'package:phimhayokup/widgets/movie_card.dart';

class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({super.key});

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen> {
  int? _selectedGenreId;
  MoodPreset? _selectedMood;
  String _sortBy = 'popularity.desc';
  int? _year;
  double? _minVote;
  final List<Movie> _movies = [];
  int _page = 1;
  bool _isLoading = false;
  bool _hasMore = true;
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
    final initialMood = ref.read(selectedMoodProvider);
    final initialGenreId = ref.read(selectedGenreProvider);
    if (initialMood != null) {
      _selectedMood = initialMood;
      _selectedGenreId = initialMood.genreId;
      _sortBy = initialMood.sortBy;
      _minVote = initialMood.minVote;
      WidgetsBinding.instance.addPostFrameCallback((_) => _fetchPage());
    } else if (initialGenreId != null) {
      _selectedGenreId = initialGenreId;
      WidgetsBinding.instance.addPostFrameCallback((_) => _fetchPage());
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 300) {
      _fetchPage();
    }
  }

  void _selectGenre(int id) {
    if (_selectedGenreId == id) return;
    setState(() {
      _selectedMood = null;
      _selectedGenreId = id;
      _movies.clear();
      _page = 1;
      _hasMore = true;
    });
    ref.read(selectedMoodProvider.notifier).state = null;
    _fetchPage();
  }

  void _applyFilter({String? sortBy, int? year, double? minVote}) {
    setState(() {
      _sortBy = sortBy ?? _sortBy;
      _year = year;
      _minVote = minVote;
      _movies.clear();
      _page = 1;
      _hasMore = true;
    });
    _fetchPage();
  }

  Future<void> _fetchPage() async {
    if (_isLoading || !_hasMore || _selectedGenreId == null) return;
    final genreId = _selectedGenreId!;
    final page = _page;

    setState(() => _isLoading = true);
    try {
      final results = await ref
          .read(tmdbServiceProvider)
          .discoverMovies(
            genreId: genreId,
            page: page,
            sortBy: _sortBy,
            year: _year,
            minVote: _minVote,
          );
      if (!mounted) return;
      setState(() {
        _movies.addAll(results);
        _page = page + 1;
        _hasMore = results.isNotEmpty;
      });
    } catch (_) {
      if (!mounted) return;
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.cl.background,
      appBar: AppBar(
        backgroundColor: context.cl.background,
        title: Text(
          'Khám Phá',
          style: TextStyle(color: context.cl.textPrimary),
        ),
      ),
      body: Column(
        children: [
          if (_selectedMood != null) _buildMoodHeader(),
          _buildGenreSelector(),
          _buildFilterRow(),
          Expanded(child: _buildMovieGrid()),
        ],
      ),
    );
  }

  Widget _buildMoodHeader() {
    final mood = _selectedMood!;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 6, 16, 4),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.cl.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.cl.surfaceVariant),
      ),
      child: Row(
        children: [
          Icon(mood.icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mood.title,
                  style: TextStyle(
                    color: context.cl.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  mood.subtitle,
                  style: TextStyle(color: context.cl.textMuted, fontSize: 12),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              ref.read(selectedMoodProvider.notifier).state = null;
              setState(() => _selectedMood = null);
            },
            icon: Icon(Icons.close_rounded, color: context.cl.textMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildGenreSelector() {
    return SizedBox(
      height: 52,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: featuredGenres.length,
        itemBuilder: (context, index) {
          final genre = featuredGenres[index];
          final id = genre['id'] as int;
          final isSelected = _selectedGenreId == id;
          return GestureDetector(
            onTap: () => _selectGenre(id),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary
                    : context.cl.surfaceVariant,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${genre['icon']} ${genre['name']}',
                style: TextStyle(
                  color: isSelected ? Colors.white : context.cl.textSecondary,
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterRow() {
    final currentYear = DateTime.now().year;
    final years = <int?>[null, currentYear, currentYear - 1, currentYear - 2];
    final scores = <double?>[null, 6.0, 7.0, 8.0];

    return SizedBox(
      height: 46,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        children: [
          _FilterMenu<String>(
            label: _sortLabel(_sortBy),
            values: const [
              'popularity.desc',
              'vote_average.desc',
              'release_date.desc',
            ],
            itemLabel: _sortLabel,
            onSelected: (value) =>
                _applyFilter(sortBy: value, year: _year, minVote: _minVote),
          ),
          const SizedBox(width: 8),
          _FilterMenu<int?>(
            label: _year == null ? 'Mọi năm' : 'Năm $_year',
            values: years,
            itemLabel: (value) => value == null ? 'Mọi năm' : '$value',
            onSelected: (value) =>
                _applyFilter(sortBy: _sortBy, year: value, minVote: _minVote),
          ),
          const SizedBox(width: 8),
          _FilterMenu<double?>(
            label: _minVote == null
                ? 'Mọi điểm'
                : 'Từ ${_minVote!.toStringAsFixed(0)}+',
            values: scores,
            itemLabel: (value) =>
                value == null ? 'Mọi điểm' : '${value.toStringAsFixed(0)}+',
            onSelected: (value) =>
                _applyFilter(sortBy: _sortBy, year: _year, minVote: value),
          ),
        ],
      ),
    );
  }

  String _sortLabel(String value) => switch (value) {
    'vote_average.desc' => 'Đánh giá cao',
    'release_date.desc' => 'Mới nhất',
    _ => 'Phổ biến',
  };

  Widget _buildMovieGrid() {
    if (_selectedGenreId == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.category_outlined,
              size: 70,
              color: context.cl.textMuted,
            ),
            const SizedBox(height: 16),
            Text(
              'Chọn thể loại để xem phim',
              style: TextStyle(color: context.cl.textSecondary, fontSize: 15),
            ),
          ],
        ),
      );
    }

    if (_movies.isEmpty && _isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (_movies.isEmpty) {
      return Center(
        child: Text(
          'Không có phim',
          style: TextStyle(color: context.cl.textSecondary),
        ),
      );
    }

    final itemCount = _movies.length + (_isLoading ? 1 : 0);

    return GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 16,
        childAspectRatio: 0.46,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        if (index >= _movies.length) {
          return const Center(
            child: CircularProgressIndicator(
              color: AppColors.primary,
              strokeWidth: 2,
            ),
          );
        }
        final movie = _movies[index];
        return MovieCard(
          movie: movie,
          width: double.infinity,
          height: 160,
          heroTag: 'poster-${movie.id}',
          onTap: () => context.push('/movie/${movie.id}'),
        );
      },
    );
  }
}

class _FilterMenu<T> extends StatelessWidget {
  final String label;
  final List<T> values;
  final String Function(T value) itemLabel;
  final ValueChanged<T> onSelected;

  const _FilterMenu({
    required this.label,
    required this.values,
    required this.itemLabel,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<T>(
      onSelected: onSelected,
      itemBuilder: (context) => values
          .map(
            (value) =>
                PopupMenuItem<T>(value: value, child: Text(itemLabel(value))),
          )
          .toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: context.cl.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: context.cl.surfaceVariant),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(color: context.cl.textSecondary, fontSize: 12),
            ),
            const SizedBox(width: 6),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              color: context.cl.textMuted,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}
