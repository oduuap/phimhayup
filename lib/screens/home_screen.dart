import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phimhayokup/providers/movie_providers.dart';
import 'package:phimhayokup/providers/theme_provider.dart';
import 'package:phimhayokup/utils/app_colors.dart';
import 'package:phimhayokup/utils/genre_data.dart';
import 'package:phimhayokup/widgets/hero_banner.dart';
import 'package:phimhayokup/widgets/movie_section.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trending = ref.watch(trendingMoviesProvider);
    final nowPlaying = ref.watch(nowPlayingProvider);
    final popular = ref.watch(popularMoviesProvider);
    final topRated = ref.watch(topRatedProvider);
    final upcoming = ref.watch(upcomingProvider);

    return Scaffold(
      backgroundColor: context.cl.background,
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async {
          ref.invalidate(trendingMoviesProvider);
          ref.invalidate(nowPlayingProvider);
          ref.invalidate(popularMoviesProvider);
          ref.invalidate(topRatedProvider);
          ref.invalidate(upcomingProvider);
          try {
            await ref.read(trendingMoviesProvider.future);
          } catch (_) {}
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
          _buildAppBar(context, ref),
          SliverToBoxAdapter(
            child: trending.when(
              loading: () => const SizedBox(height: 340),
              error: (_, __) => const SizedBox.shrink(),
              data: (movies) => HeroBanner(movies: movies.take(5).toList()),
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                _buildGenreRow(context),
                const SizedBox(height: 24),
                MovieSection(
                  title: 'Đang Chiếu',
                  icon: Icons.movie_filter_rounded,
                  moviesAsync: nowPlaying,
                  onRetry: () => ref.invalidate(nowPlayingProvider),
                ),
                const SizedBox(height: 24),
                MovieSection(
                  title: 'Phổ Biến',
                  icon: Icons.local_fire_department_rounded,
                  moviesAsync: popular,
                  onRetry: () => ref.invalidate(popularMoviesProvider),
                ),
                const SizedBox(height: 24),
                MovieSection(
                  title: 'Đánh Giá Cao',
                  icon: Icons.star_rounded,
                  iconColor: AppColors.gold,
                  moviesAsync: topRated,
                  onRetry: () => ref.invalidate(topRatedProvider),
                ),
                const SizedBox(height: 24),
                MovieSection(
                  title: 'Sắp Chiếu',
                  icon: Icons.calendar_today_rounded,
                  moviesAsync: upcoming,
                  onRetry: () => ref.invalidate(upcomingProvider),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark;

    return SliverAppBar(
      floating: true,
      backgroundColor: context.cl.background,
      elevation: 0,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'Phim',
                  style: TextStyle(
                    color: context.cl.textPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const TextSpan(
                  text: 'Hay',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Text(
            'Trailer & Thông Tin Phim',
            style: TextStyle(
              color: context.cl.textMuted,
              fontSize: 11,
              fontWeight: FontWeight.normal,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () {
            ref.read(themeModeProvider.notifier).state =
                isDark ? ThemeMode.light : ThemeMode.dark;
          },
          icon: Icon(
            isDark ? Icons.wb_sunny_outlined : Icons.nightlight_round,
            color: context.cl.textPrimary,
            size: 22,
          ),
          tooltip: isDark ? 'Chế độ sáng' : 'Chế độ tối',
        ),
      ],
    );
  }

  Widget _buildGenreRow(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Row(
            children: [
              const Icon(
                Icons.grid_view_rounded,
                size: 16,
                color: AppColors.primary,
              ),
              const SizedBox(width: 6),
              Text(
                'Thể Loại',
                style: TextStyle(
                  color: context.cl.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: featuredGenres.length,
            itemBuilder: (context, index) {
              final genre = featuredGenres[index];
              return _GenreChip(
                id: genre['id'] as int,
                name: genre['name'] as String,
                icon: genre['icon'] as String,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _GenreChip extends ConsumerWidget {
  final int id;
  final String name;
  final String icon;

  const _GenreChip({
    required this.id,
    required this.name,
    required this.icon,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () {
        ref.read(selectedGenreProvider.notifier).state = id;
        DefaultTabController.of(context);
      },
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: context.cl.surfaceVariant,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(icon, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 6),
            Text(
              name,
              style: TextStyle(
                color: context.cl.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
