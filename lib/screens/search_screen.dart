import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phimhayokup/models/movie.dart';
import 'package:phimhayokup/providers/movie_providers.dart';
import 'package:phimhayokup/utils/app_colors.dart';
import 'package:phimhayokup/widgets/movie_card.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();
  late final ScrollController _scrollController;

  final List<Movie> _movies = [];
  int _page = 1;
  bool _isLoading = false;
  bool _hasMore = true;
  String _lastQuery = '';

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final query = ref.read(searchQueryProvider);
      if (query.isNotEmpty) _resetAndLoad(query);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 300) {
      _fetchPage(_lastQuery);
    }
  }

  void _resetAndLoad(String query) {
    if (query == _lastQuery && _movies.isNotEmpty) return;
    _lastQuery = query;
    setState(() {
      _movies.clear();
      _page = 1;
      _hasMore = true;
    });
    _fetchPage(query);
  }

  Future<void> _fetchPage(String query) async {
    if (_isLoading || !_hasMore || query.isEmpty) return;
    if (query != _lastQuery) return;
    final page = _page;

    setState(() => _isLoading = true);
    try {
      final results = await ref
          .read(tmdbServiceProvider)
          .searchMovies(query, page: page);
      if (!mounted || query != _lastQuery) return;
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
    ref.listen<String>(searchQueryProvider, (previous, next) {
      if (next != _lastQuery) {
        _controller.text = next;
        if (next.isEmpty) {
          setState(() {
            _movies.clear();
            _lastQuery = '';
            _page = 1;
            _hasMore = true;
          });
        } else {
          _resetAndLoad(next);
        }
      }
    });

    final query = ref.watch(searchQueryProvider);

    return Scaffold(
      backgroundColor: context.cl.background,
      appBar: AppBar(
        backgroundColor: context.cl.background,
        title: TextField(
          controller: _controller,
          autofocus: true,
          style: TextStyle(color: context.cl.textPrimary),
          decoration: InputDecoration(
            hintText: 'Tìm kiếm phim...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: context.cl.textMuted),
          ),
          onChanged: (value) {
            ref.read(searchQueryProvider.notifier).state = value;
          },
        ),
        actions: [
          if (query.isNotEmpty)
            IconButton(
              icon: Icon(Icons.clear, color: context.cl.textSecondary),
              onPressed: () {
                _controller.clear();
                ref.read(searchQueryProvider.notifier).state = '';
              },
            ),
        ],
      ),
      body: query.isEmpty ? _buildEmptyState() : _buildSearchResults(query),
    );
  }

  Widget _buildSearchResults(String query) {
    if (_movies.isEmpty && _isLoading) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.primary));
    }
    if (_movies.isEmpty) {
      return _buildNoResults(query);
    }

    final itemCount = _movies.length + (_isLoading ? 1 : 0);

    return GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 16,
        childAspectRatio: 0.50,
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
          height: 140,
          heroTag: 'poster-${movie.id}',
          onTap: () {
            ref.read(searchHistoryProvider.notifier).add(query);
            context.push('/movie/${movie.id}');
          },
        );
      },
    );
  }

  Widget _buildEmptyState() {
    final history = ref.watch(searchHistoryProvider);
    if (history.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_rounded, size: 80, color: context.cl.textMuted),
            const SizedBox(height: 16),
            Text(
              'Tìm kiếm phim yêu thích',
              style:
                  TextStyle(color: context.cl.textSecondary, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Nhập tên phim để bắt đầu tìm kiếm',
              style: TextStyle(color: context.cl.textMuted, fontSize: 13),
            ),
          ],
        ),
      );
    }
    return _buildHistory(history);
  }

  Widget _buildHistory(List<String> history) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tìm kiếm gần đây',
                style: TextStyle(
                  color: context.cl.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextButton(
                onPressed: () =>
                    ref.read(searchHistoryProvider.notifier).clear(),
                child: Text(
                  'Xóa tất cả',
                  style: TextStyle(
                      color: context.cl.textMuted, fontSize: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: history
                .map((item) => InputChip(
                      label: Text(item,
                          style: TextStyle(
                              color: context.cl.textSecondary,
                              fontSize: 13)),
                      backgroundColor: context.cl.surfaceVariant,
                      deleteIconColor: context.cl.textMuted,
                      side: BorderSide.none,
                      onPressed: () {
                        _controller.text = item;
                        ref.read(searchQueryProvider.notifier).state = item;
                      },
                      onDeleted: () => ref
                          .read(searchHistoryProvider.notifier)
                          .remove(item),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResults(String query) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.movie_filter_outlined,
              size: 70, color: context.cl.textMuted),
          const SizedBox(height: 16),
          Text(
            'Không tìm thấy kết quả',
            style: TextStyle(color: context.cl.textSecondary, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            '"$query"',
            style: TextStyle(
                color: context.cl.textMuted,
                fontSize: 13,
                fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }
}
