import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:go_router/go_router.dart';
import 'package:phimhayokup/models/movie.dart';
import 'package:phimhayokup/models/movie_detail.dart';
import 'package:phimhayokup/providers/movie_providers.dart';
import 'package:phimhayokup/providers/watchlist_provider.dart';
import 'package:phimhayokup/utils/app_colors.dart';
import 'package:phimhayokup/utils/genre_data.dart';
import 'package:share_plus/share_plus.dart';

class MovieDetailScreen extends ConsumerWidget {
  final int movieId;

  const MovieDetailScreen({super.key, required this.movieId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final movieAsync = ref.watch(movieDetailProvider(movieId));

    return Scaffold(
      backgroundColor: context.cl.background,
      body: movieAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: context.cl.textMuted, size: 60),
              const SizedBox(height: 16),
              Text('Không thể tải thông tin phim',
                  style: TextStyle(color: context.cl.textSecondary)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(movieDetailProvider(movieId)),
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary),
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
        data: (movie) => _buildDetail(context, movie),
      ),
    );
  }

  Widget _buildDetail(BuildContext context, MovieDetail movie) {
    return CustomScrollView(
      slivers: [
        _buildSliverHeader(context, movie),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTitleSection(context, movie),
                const SizedBox(height: 16),
                _buildActionButtons(context, movie),
                const SizedBox(height: 20),
                if (movie.overview.isNotEmpty) ...[
                  _buildOverview(context, movie),
                  const SizedBox(height: 20),
                ],
                if (movie.genres.isNotEmpty) ...[
                  _buildGenres(context, movie),
                  const SizedBox(height: 20),
                ],
                if (movie.cast.isNotEmpty) ...[
                  _buildCast(context, movie),
                  const SizedBox(height: 20),
                ],
                if (movie.similar.isNotEmpty) ...[
                  _buildSimilar(context, movie),
                  const SizedBox(height: 32),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  SliverAppBar _buildSliverHeader(BuildContext context, MovieDetail movie) {
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      backgroundColor: context.cl.background,
      leading: GestureDetector(
        onTap: () => context.pop(),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: context.cl.overlay,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.white, size: 18),
        ),
      ),
      actions: [
        GestureDetector(
          onTap: () => _shareMovie(movie),
          child: Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: context.cl.overlay,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.share_outlined,
                color: Colors.white, size: 18),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            if (movie.backdropUrl.isNotEmpty)
              CachedNetworkImage(
                imageUrl: movie.backdropUrl,
                fit: BoxFit.cover,
              )
            else
              Container(color: context.cl.surface),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, context.cl.background],
                  stops: const [0.4, 1.0],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleSection(BuildContext context, MovieDetail movie) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Hero(
          tag: 'poster-${movie.id}',
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: CachedNetworkImage(
              imageUrl: movie.posterUrl,
              width: 110,
              height: 165,
              fit: BoxFit.cover,
              errorWidget: (_, __, ___) => Container(
                width: 110,
                height: 165,
                color: context.cl.surfaceVariant,
                child: Icon(Icons.movie_outlined,
                    color: context.cl.textMuted, size: 40),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                movie.title,
                style: TextStyle(
                  color: context.cl.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (movie.tagline != null && movie.tagline!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  movie.tagline!,
                  style: TextStyle(
                    color: context.cl.textMuted,
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
              const SizedBox(height: 10),
              _buildMetaChips(context, movie),
              const SizedBox(height: 10),
              _buildRating(context, movie),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMetaChips(BuildContext context, MovieDetail movie) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        if (movie.year.isNotEmpty) _metaChip(context, movie.year),
        if (movie.runtimeFormatted.isNotEmpty)
          _metaChip(context, movie.runtimeFormatted),
        if (movie.productionCountries.isNotEmpty)
          _metaChip(context, movie.productionCountries.first.name),
      ],
    );
  }

  Widget _metaChip(BuildContext context, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: context.cl.surfaceVariant,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(color: context.cl.textSecondary, fontSize: 11),
      ),
    );
  }

  Widget _buildRating(BuildContext context, MovieDetail movie) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              movie.voteAverage.toStringAsFixed(1),
              style: const TextStyle(
                color: AppColors.gold,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '/10',
              style: TextStyle(color: context.cl.textMuted, fontSize: 14),
            ),
            const SizedBox(width: 8),
            RatingBarIndicator(
              rating: movie.voteAverage / 2,
              itemBuilder: (_, __) =>
                  const Icon(Icons.star_rounded, color: AppColors.gold),
              itemCount: 5,
              itemSize: 16,
            ),
          ],
        ),
        Text(
          '${movie.voteCount} lượt đánh giá',
          style: TextStyle(color: context.cl.textMuted, fontSize: 11),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, MovieDetail movie) {
    final asMovie = Movie(
      id: movie.id,
      title: movie.title,
      originalTitle: movie.originalTitle,
      overview: movie.overview,
      posterPath: movie.posterPath,
      backdropPath: movie.backdropPath,
      voteAverage: movie.voteAverage,
      voteCount: movie.voteCount,
      releaseDate: movie.releaseDate,
      genreIds: movie.genres.map((g) => g.id).toList(),
      isAdult: false,
    );

    return Consumer(
      builder: (context, ref, _) {
        final inWatchlist = ref.watch(watchlistProvider
            .select((list) => list.any((m) => m.id == movie.id)));

        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => context.push(
                        '/watch/${movie.id}?title=${Uri.encodeComponent(movie.title)}'),
                    icon: const Icon(Icons.play_arrow_rounded, size: 22),
                    label: const Text('Xem Phim',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                OutlinedButton(
                  onPressed: () =>
                      ref.read(watchlistProvider.notifier).toggle(asMovie),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: inWatchlist
                        ? AppColors.primary
                        : context.cl.textPrimary,
                    side: BorderSide(
                      color: inWatchlist
                          ? AppColors.primary
                          : context.cl.surfaceVariant,
                    ),
                    padding: const EdgeInsets.symmetric(
                        vertical: 13, horizontal: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Icon(
                    inWatchlist
                        ? Icons.bookmark_rounded
                        : Icons.bookmark_border_rounded,
                    size: 20,
                  ),
                ),
              ],
            ),
            if (movie.trailer != null) ...[
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () =>
                      context.push('/trailer/${movie.trailer!.key}'),
                  icon: const Icon(Icons.smart_display_outlined, size: 18),
                  label:
                      const Text('Xem Trailer', style: TextStyle(fontSize: 14)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: context.cl.textPrimary,
                    side: BorderSide(color: context.cl.surfaceVariant),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildOverview(BuildContext context, MovieDetail movie) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Nội Dung',
          style: TextStyle(
            color: context.cl.textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          movie.overview,
          style: TextStyle(
            color: context.cl.textSecondary,
            fontSize: 14,
            height: 1.6,
          ),
        ),
      ],
    );
  }

  Widget _buildGenres(BuildContext context, MovieDetail movie) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Thể Loại',
          style: TextStyle(
            color: context.cl.textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: movie.genres.map((g) {
            return Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.4)),
              ),
              child: Text(
                genreMap[g.id] ?? g.name,
                style:
                    const TextStyle(color: AppColors.primary, fontSize: 12),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildCast(BuildContext context, MovieDetail movie) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Diễn Viên',
          style: TextStyle(
            color: context.cl.textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 110,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: movie.cast.length,
            itemBuilder: (context, index) {
              final actor = movie.cast[index];
              return GestureDetector(
                onTap: () => context.push('/person/${actor.id}'),
                child: Container(
                  width: 75,
                  margin: EdgeInsets.only(
                      right: index < movie.cast.length - 1 ? 12 : 0),
                  child: Column(
                    children: [
                      ClipOval(
                        child: CachedNetworkImage(
                          imageUrl: actor.profileUrl,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorWidget: (_, __, ___) => Container(
                            width: 60,
                            height: 60,
                            color: context.cl.surfaceVariant,
                            child: Icon(Icons.person_outline,
                                color: context.cl.textMuted),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        actor.name,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: context.cl.textSecondary, fontSize: 10),
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

  Widget _buildSimilar(BuildContext context, MovieDetail movie) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Phim Liên Quan',
          style: TextStyle(
            color: context.cl.textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: movie.similar.length,
            itemBuilder: (context, index) {
              final similar = movie.similar[index];
              return GestureDetector(
                onTap: () => context.push('/movie/${similar.id}'),
                child: Container(
                  width: 120,
                  margin: EdgeInsets.only(
                      right: index < movie.similar.length - 1 ? 12 : 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: CachedNetworkImage(
                          imageUrl: similar.posterUrl,
                          width: 120,
                          height: 180,
                          fit: BoxFit.cover,
                          errorWidget: (_, __, ___) => Container(
                            width: 120,
                            height: 180,
                            color: context.cl.surfaceVariant,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        similar.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: context.cl.textSecondary, fontSize: 11),
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

  void _shareMovie(MovieDetail movie) {
    Share.share(
      '🎬 ${movie.title}\n'
      '⭐ ${movie.voteAverage.toStringAsFixed(1)}/10\n\n'
      'Xem trên PhimHay!',
    );
  }
}
