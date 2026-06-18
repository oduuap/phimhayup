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
  final List<Movie> _movies = [];
  int _page = 1;
  bool _isLoading = false;
  bool _hasMore = true;
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
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
      _selectedGenreId = id;
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
          .getByGenre(genreId, page: page);
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
        title: Text('Khám Phá',
            style: TextStyle(color: context.cl.textPrimary)),
      ),
      body: Column(
        children: [
          _buildGenreSelector(),
          Expanded(child: _buildMovieGrid()),
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
                  fontWeight:
                      isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMovieGrid() {
    if (_selectedGenreId == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.category_outlined,
                size: 70, color: context.cl.textMuted),
            const SizedBox(height: 16),
            Text(
              'Chọn thể loại để xem phim',
              style:
                  TextStyle(color: context.cl.textSecondary, fontSize: 15),
            ),
          ],
        ),
      );
    }

    if (_movies.isEmpty && _isLoading) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.primary));
    }

    if (_movies.isEmpty) {
      return Center(
        child: Text('Không có phim',
            style: TextStyle(color: context.cl.textSecondary)),
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
                  color: AppColors.primary, strokeWidth: 2));
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
