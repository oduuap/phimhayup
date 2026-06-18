import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phimhayokup/providers/watchlist_provider.dart';
import 'package:phimhayokup/utils/app_colors.dart';
import 'package:phimhayokup/widgets/movie_card.dart';

class WatchlistScreen extends ConsumerWidget {
  const WatchlistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final watchlist = ref.watch(watchlistProvider);

    return Scaffold(
      backgroundColor: context.cl.background,
      appBar: AppBar(
        backgroundColor: context.cl.background,
        title: const Text('Danh Sách Yêu Thích'),
        actions: [
          if (watchlist.isNotEmpty)
            TextButton(
              onPressed: () => _confirmClear(context, ref),
              child: Text(
                'Xóa tất cả',
                style: TextStyle(color: context.cl.textMuted, fontSize: 13),
              ),
            ),
          IconButton(
            icon: Icon(Icons.settings_outlined,
                color: context.cl.textSecondary),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: watchlist.isEmpty
          ? _buildEmpty(context)
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 16,
                childAspectRatio: 0.46,
              ),
              itemCount: watchlist.length,
              itemBuilder: (context, index) {
                final movie = watchlist[index];
                return MovieCard(
                  movie: movie,
                  width: double.infinity,
                  height: 160,
                  onTap: () => context.push('/movie/${movie.id}'),
                );
              },
            ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bookmark_border_rounded,
              size: 80, color: context.cl.textMuted),
          const SizedBox(height: 16),
          Text(
            'Chưa có phim yêu thích',
            style: TextStyle(color: context.cl.textSecondary, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            'Nhấn ♥ trên phim để thêm vào đây',
            style: TextStyle(color: context.cl.textMuted, fontSize: 13),
          ),
        ],
      ),
    );
  }

  void _confirmClear(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.cl.surface,
        title: Text('Xóa tất cả?',
            style: TextStyle(color: context.cl.textPrimary)),
        content: Text('Danh sách yêu thích sẽ bị xóa hoàn toàn.',
            style: TextStyle(color: context.cl.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Hủy',
                style: TextStyle(color: context.cl.textMuted)),
          ),
          TextButton(
            onPressed: () {
              final notifier = ref.read(watchlistProvider.notifier);
              for (final m in List.from(ref.read(watchlistProvider))) {
                notifier.toggle(m);
              }
              Navigator.pop(ctx);
            },
            child: const Text('Xóa',
                style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }
}
