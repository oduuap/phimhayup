import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phimhayokup/models/movie.dart';
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
                  const SizedBox(height: 18),
                  trending.when(
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                    data: (movies) => movies.isEmpty
                        ? const SizedBox.shrink()
                        : _buildTodayHighlight(context, movies.first),
                  ),
                  const SizedBox(height: 22),
                  _buildMoodRow(context, ref),
                  const SizedBox(height: 22),
                  _buildGenreRow(context),
                  const SizedBox(height: 26),
                  MovieSection(
                    title: 'Đang Chiếu',
                    icon: Icons.movie_filter_outlined,
                    moviesAsync: nowPlaying,
                    onRetry: () => ref.invalidate(nowPlayingProvider),
                  ),
                  const SizedBox(height: 26),
                  MovieSection(
                    title: 'Phổ Biến',
                    icon: Icons.trending_up_rounded,
                    moviesAsync: popular,
                    onRetry: () => ref.invalidate(popularMoviesProvider),
                  ),
                  const SizedBox(height: 26),
                  MovieSection(
                    title: 'Đánh Giá Cao',
                    icon: Icons.star_border_rounded,
                    moviesAsync: topRated,
                    onRetry: () => ref.invalidate(topRatedProvider),
                  ),
                  const SizedBox(height: 26),
                  upcoming.when(
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                    data: (movies) => _buildReleaseCalendar(context, movies),
                  ),
                  const SizedBox(height: 26),
                  MovieSection(
                    title: 'Sắp Chiếu',
                    icon: Icons.calendar_today_outlined,
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
          const Text(
            'phimhayup',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 24,
              fontWeight: FontWeight.w900,
              height: 1.0,
            ),
          ),
          Text(
            'Khám phá phim & trailer',
            style: TextStyle(
              color: context.cl.textMuted,
              fontSize: 11,
              fontWeight: FontWeight.normal,
            ),
          ),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 10),
          child: IconButton.filledTonal(
            onPressed: () {
              ref.read(themeModeProvider.notifier).state = isDark
                  ? ThemeMode.light
                  : ThemeMode.dark;
            },
            icon: Icon(
              isDark ? Icons.wb_sunny_outlined : Icons.nightlight_round,
              color: context.cl.textPrimary,
              size: 20,
            ),
            style: IconButton.styleFrom(
              backgroundColor: context.cl.surface,
              foregroundColor: context.cl.textPrimary,
              minimumSize: const Size(40, 40),
            ),
            tooltip: isDark ? 'Chế độ sáng' : 'Chế độ tối',
          ),
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
                Icons.grid_view_outlined,
                size: 16,
                color: AppColors.primary,
              ),
              const SizedBox(width: 6),
              Text(
                'Thể loại',
                style: TextStyle(
                  color: context.cl.textPrimary,
                  fontSize: 17,
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
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTodayHighlight(BuildContext context, Movie movie) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => context.push('/movie/${movie.id}'),
        child: Container(
          padding: const EdgeInsets.all(14),
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
                  Icons.today_outlined,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hôm nay nổi bật',
                      style: TextStyle(
                        color: context.cl.textMuted,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      movie.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: context.cl.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: context.cl.textMuted,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMoodRow(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Row(
            children: [
              const Icon(
                Icons.auto_awesome_outlined,
                size: 16,
                color: AppColors.primary,
              ),
              const SizedBox(width: 6),
              Text(
                'Chọn mood',
                style: TextStyle(
                  color: context.cl.textPrimary,
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 74,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: moodPresets.length,
            itemBuilder: (context, index) {
              final mood = moodPresets[index];
              return _MoodChip(
                mood: mood,
                onTap: () {
                  ref.read(selectedMoodProvider.notifier).state = mood;
                  ref.read(selectedGenreProvider.notifier).state = null;
                  context.go('/explore');
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildReleaseCalendar(BuildContext context, List<Movie> movies) {
    final dated = movies
        .where((movie) {
          final date = DateTime.tryParse(movie.releaseDate ?? '');
          if (date == null) return false;
          final now = DateTime.now();
          return date.isAfter(DateTime(now.year, now.month, now.day));
        })
        .take(6)
        .toList();

    if (dated.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Row(
            children: [
              const Icon(
                Icons.event_available_outlined,
                size: 16,
                color: AppColors.primary,
              ),
              const SizedBox(width: 6),
              Text(
                'Lịch sắp chiếu',
                style: TextStyle(
                  color: context.cl.textPrimary,
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 92,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: dated.length,
            itemBuilder: (context, index) {
              final movie = dated[index];
              final date = DateTime.parse(movie.releaseDate!);
              final now = DateTime.now();
              final days = date
                  .difference(DateTime(now.year, now.month, now.day))
                  .inDays;
              return InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () => context.push('/movie/${movie.id}'),
                child: Container(
                  width: 178,
                  margin: const EdgeInsets.only(right: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: context.cl.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: context.cl.surfaceVariant),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        days == 0 ? 'Hôm nay' : 'Còn $days ngày',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        movie.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: context.cl.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          height: 1.25,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _MoodChip extends StatelessWidget {
  final MoodPreset mood;
  final VoidCallback onTap;

  const _MoodChip({required this.mood, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        width: 154,
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.all(12),
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
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    mood.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: context.cl.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    mood.subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: context.cl.textMuted, fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GenreChip extends ConsumerWidget {
  final int id;
  final String name;

  const _GenreChip({required this.id, required this.name});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () {
        ref.read(selectedGenreProvider.notifier).state = id;
        context.go('/explore');
      },
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
        decoration: BoxDecoration(
          color: context.cl.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: context.cl.surfaceVariant),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.local_movies_outlined,
              size: 14,
              color: context.cl.textMuted,
            ),
            const SizedBox(width: 7),
            Text(
              name,
              style: TextStyle(
                color: context.cl.textSecondary,
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
