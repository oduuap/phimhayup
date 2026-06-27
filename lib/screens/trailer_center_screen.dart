import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phimhayokup/models/movie.dart';
import 'package:phimhayokup/providers/movie_providers.dart';
import 'package:phimhayokup/utils/app_colors.dart';
import 'package:phimhayokup/widgets/movie_card.dart';

class TrailerCenterScreen extends ConsumerWidget {
  const TrailerCenterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trending = ref.watch(trendingMoviesProvider);
    final upcoming = ref.watch(upcomingProvider);

    return Scaffold(
      backgroundColor: context.cl.background,
      appBar: AppBar(
        backgroundColor: context.cl.background,
        title: const Text('Trailer Center'),
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async {
          ref.invalidate(trendingMoviesProvider);
          ref.invalidate(upcomingProvider);
          try {
            await ref.read(trendingMoviesProvider.future);
          } catch (_) {}
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
          children: [
            _HeaderCard(
              title: 'Trailer nổi bật',
              subtitle:
                  'Chọn phim để xem trailer YouTube chính thức nếu phim có trailer công khai.',
            ),
            const SizedBox(height: 20),
            _MovieGridBlock(title: 'Đang được quan tâm', moviesAsync: trending),
            const SizedBox(height: 24),
            _MovieGridBlock(title: 'Sắp ra mắt', moviesAsync: upcoming),
          ],
        ),
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  final String title;
  final String subtitle;

  const _HeaderCard({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cl.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.cl.surfaceVariant),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.smart_display_outlined,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: context.cl.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: context.cl.textMuted,
                    fontSize: 12,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MovieGridBlock extends StatelessWidget {
  final String title;
  final AsyncValue<List<Movie>> moviesAsync;

  const _MovieGridBlock({required this.title, required this.moviesAsync});

  @override
  Widget build(BuildContext context) {
    return moviesAsync.when(
      loading: () => const SizedBox(
        height: 180,
        child: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      ),
      error: (_, __) => Text(
        'Không thể tải dữ liệu',
        style: TextStyle(color: context.cl.textMuted),
      ),
      data: (movies) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: context.cl.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 16,
              childAspectRatio: 0.46,
            ),
            itemCount: movies.take(9).length,
            itemBuilder: (context, index) {
              final movie = movies[index];
              return MovieCard(
                movie: movie,
                width: double.infinity,
                height: 160,
                onTap: () => context.push('/movie/${movie.id}'),
              );
            },
          ),
        ],
      ),
    );
  }
}
