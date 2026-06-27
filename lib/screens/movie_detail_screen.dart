import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:go_router/go_router.dart';
import 'package:phimhayokup/models/movie.dart';
import 'package:phimhayokup/models/movie_detail.dart';
import 'package:phimhayokup/providers/movie_providers.dart';
import 'package:phimhayokup/providers/user_features_provider.dart';
import 'package:phimhayokup/providers/watchlist_provider.dart';
import 'package:phimhayokup/utils/app_colors.dart';
import 'package:phimhayokup/utils/genre_data.dart';
import 'package:share_plus/share_plus.dart';

class MovieDetailScreen extends ConsumerStatefulWidget {
  final int movieId;

  const MovieDetailScreen({super.key, required this.movieId});

  @override
  ConsumerState<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends ConsumerState<MovieDetailScreen> {
  bool _trackedView = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (_trackedView) return;
      _trackedView = true;
      await incrementDetailViews();
    });
  }

  @override
  Widget build(BuildContext context) {
    final movieAsync = ref.watch(movieDetailProvider(widget.movieId));

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
              Text(
                'Không thể tải thông tin phim',
                style: TextStyle(color: context.cl.textSecondary),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () =>
                    ref.invalidate(movieDetailProvider(widget.movieId)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                ),
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
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTitleSection(context, movie),
                const SizedBox(height: 14),
                _buildFactsPanel(context, movie),
                const SizedBox(height: 16),
                _buildActionButtons(context, movie),
                const SizedBox(height: 24),
                if (movie.overview.isNotEmpty) ...[
                  _buildOverview(context, movie),
                  const SizedBox(height: 24),
                ],
                if (movie.genres.isNotEmpty) ...[
                  _buildGenres(context, movie),
                  const SizedBox(height: 24),
                ],
                if (movie.cast.isNotEmpty) ...[
                  _buildCast(context, movie),
                  const SizedBox(height: 24),
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
      expandedHeight: 320,
      pinned: true,
      backgroundColor: context.cl.background,
      leading: _HeaderIconButton(
        onTap: () => context.pop(),
        icon: Icons.arrow_back_ios_new_rounded,
      ),
      actions: [
        _HeaderIconButton(
          onTap: () => _shareMovie(movie),
          icon: Icons.share_outlined,
        ),
        const SizedBox(width: 8),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            if (movie.backdropUrl.isNotEmpty)
              CachedNetworkImage(
                imageUrl: movie.backdropUrl,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => _buildBackdropFallback(context),
              )
            else
              _buildBackdropFallback(context),
            Container(color: Colors.black.withValues(alpha: 0.16)),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.50),
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.48),
                    context.cl.background,
                  ],
                  stops: const [0.0, 0.32, 0.70, 1.0],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackdropFallback(BuildContext context) {
    return Container(
      color: context.cl.surface,
      child: Center(
        child: Icon(
          Icons.local_movies_outlined,
          color: context.cl.textMuted,
          size: 58,
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
            borderRadius: BorderRadius.circular(12),
            child: CachedNetworkImage(
              imageUrl: movie.posterUrl,
              width: 112,
              height: 168,
              fit: BoxFit.cover,
              errorWidget: (_, __, ___) => Container(
                width: 112,
                height: 168,
                color: context.cl.surfaceVariant,
                child: Icon(
                  Icons.movie_outlined,
                  color: context.cl.textMuted,
                  size: 40,
                ),
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
                  fontSize: 23,
                  fontWeight: FontWeight.w800,
                  height: 1.12,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              if (movie.originalTitle.isNotEmpty &&
                  movie.originalTitle != movie.title) ...[
                const SizedBox(height: 5),
                Text(
                  movie.originalTitle,
                  style: TextStyle(color: context.cl.textMuted, fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              if (movie.tagline != null && movie.tagline!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  movie.tagline!,
                  style: TextStyle(
                    color: context.cl.textSecondary,
                    fontSize: 13,
                    height: 1.35,
                    fontStyle: FontStyle.italic,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 12),
              _buildMetaChips(context, movie),
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
        color: context.cl.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: context.cl.surfaceVariant),
      ),
      child: Text(
        text,
        style: TextStyle(color: context.cl.textSecondary, fontSize: 11),
      ),
    );
  }

  Widget _buildFactsPanel(BuildContext context, MovieDetail movie) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: context.cl.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.cl.surfaceVariant),
      ),
      child: Row(
        children: [
          Expanded(
            child: _factItem(
              context,
              label: 'Đánh giá',
              value: movie.voteAverage.toStringAsFixed(1),
              icon: Icons.star_rounded,
              accentColor: AppColors.gold,
              trailing: '/10',
            ),
          ),
          _factDivider(context),
          Expanded(
            child: _factItem(
              context,
              label: 'Thời lượng',
              value: movie.runtimeFormatted.isNotEmpty
                  ? movie.runtimeFormatted
                  : 'N/A',
              icon: Icons.schedule_rounded,
            ),
          ),
          _factDivider(context),
          Expanded(
            child: _factItem(
              context,
              label: 'Năm',
              value: movie.year.isNotEmpty ? movie.year : 'N/A',
              icon: Icons.calendar_today_outlined,
            ),
          ),
        ],
      ),
    );
  }

  Widget _factDivider(BuildContext context) {
    return Container(
      width: 1,
      height: 42,
      margin: const EdgeInsets.symmetric(horizontal: 10),
      color: context.cl.surfaceVariant,
    );
  }

  Widget _factItem(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
    Color? accentColor,
    String? trailing,
  }) {
    final color = accentColor ?? context.cl.textSecondary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 15),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(color: context.cl.textMuted, fontSize: 11),
            ),
          ],
        ),
        const SizedBox(height: 7),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Flexible(
              child: Text(
                value,
                style: TextStyle(
                  color: context.cl.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  height: 1,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (trailing != null)
              Text(
                trailing,
                style: TextStyle(color: context.cl.textMuted, fontSize: 11),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildRating(BuildContext context, MovieDetail movie) {
    return Row(
      children: [
        RatingBarIndicator(
          rating: movie.voteAverage / 2,
          itemBuilder: (_, __) =>
              const Icon(Icons.star_rounded, color: AppColors.gold),
          itemCount: 5,
          itemSize: 15,
        ),
        const SizedBox(width: 8),
        Text(
          '${movie.voteCount} lượt đánh giá',
          style: TextStyle(color: context.cl.textMuted, fontSize: 12),
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
        final inWatchlist = ref.watch(
          watchlistProvider.select((list) => list.any((m) => m.id == movie.id)),
        );

        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => context.push(
                      '/watch/${movie.id}?title=${Uri.encodeComponent(movie.title)}',
                    ),
                    icon: const Icon(Icons.search_rounded, size: 20),
                    label: const Text(
                      'Tìm nơi xem',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                OutlinedButton(
                  onPressed: () async {
                    await ref.read(watchlistProvider.notifier).toggle(asMovie);
                    if (!inWatchlist) {
                      await incrementWatchlistAdds();
                    }
                  },
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
                      vertical: 15,
                      horizontal: 17,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
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
                  label: const Text(
                    'Xem Trailer',
                    style: TextStyle(fontSize: 14),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: context.cl.textPrimary,
                    side: BorderSide(color: context.cl.surfaceVariant),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () =>
                        _showCollectionsSheet(context, ref, asMovie),
                    icon: const Icon(Icons.library_add_outlined, size: 18),
                    label: const Text('Bộ sưu tập'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: context.cl.textPrimary,
                      side: BorderSide(color: context.cl.surfaceVariant),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                if (_isFutureRelease(movie)) ...[
                  const SizedBox(width: 10),
                  Consumer(
                    builder: (context, ref, _) {
                      final enabled = ref
                          .watch(releaseRemindersProvider)
                          .contains(movie.id);
                      return OutlinedButton(
                        onPressed: () => ref
                            .read(releaseRemindersProvider.notifier)
                            .toggle(movie.id),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: enabled
                              ? AppColors.primary
                              : context.cl.textPrimary,
                          side: BorderSide(
                            color: enabled
                                ? AppColors.primary
                                : context.cl.surfaceVariant,
                          ),
                          padding: const EdgeInsets.symmetric(
                            vertical: 13,
                            horizontal: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Icon(
                          enabled
                              ? Icons.notifications_active_rounded
                              : Icons.notifications_none_rounded,
                          size: 19,
                        ),
                      );
                    },
                  ),
                ],
              ],
            ),
            if (_isFutureRelease(movie)) ...[
              const SizedBox(height: 9),
              Text(
                'Còn ${_daysUntil(movie)} ngày tới ngày phát hành dự kiến',
                style: TextStyle(color: context.cl.textMuted, fontSize: 12),
              ),
            ],
            const SizedBox(height: 12),
            _buildRating(context, movie),
          ],
        );
      },
    );
  }

  Widget _buildOverview(BuildContext context, MovieDetail movie) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(context, 'Nội dung'),
        const SizedBox(height: 10),
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
        _sectionTitle(context, 'Thể loại'),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: movie.genres.map((g) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: context.cl.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: context.cl.surfaceVariant),
              ),
              child: Text(
                genreMap[g.id] ?? g.name,
                style: TextStyle(color: context.cl.textSecondary, fontSize: 12),
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
        _sectionTitle(context, 'Diễn viên'),
        const SizedBox(height: 12),
        SizedBox(
          height: 128,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: movie.cast.length,
            itemBuilder: (context, index) {
              final actor = movie.cast[index];
              return GestureDetector(
                onTap: () => context.push('/person/${actor.id}'),
                child: Container(
                  width: 92,
                  margin: EdgeInsets.only(
                    right: index < movie.cast.length - 1 ? 12 : 0,
                  ),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: context.cl.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: context.cl.surfaceVariant),
                  ),
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(28),
                        child: CachedNetworkImage(
                          imageUrl: actor.profileUrl,
                          width: 56,
                          height: 56,
                          fit: BoxFit.cover,
                          errorWidget: (_, __, ___) => Container(
                            width: 56,
                            height: 56,
                            color: context.cl.surfaceVariant,
                            child: Icon(
                              Icons.person_outline,
                              color: context.cl.textMuted,
                            ),
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
                          color: context.cl.textSecondary,
                          fontSize: 11,
                          height: 1.2,
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

  Widget _buildSimilar(BuildContext context, MovieDetail movie) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(context, 'Phim liên quan'),
        const SizedBox(height: 12),
        SizedBox(
          height: 230,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: movie.similar.length,
            itemBuilder: (context, index) {
              final similar = movie.similar[index];
              return GestureDetector(
                onTap: () => context.push('/movie/${similar.id}'),
                child: Container(
                  width: 122,
                  margin: EdgeInsets.only(
                    right: index < movie.similar.length - 1 ? 12 : 0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
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
                          color: context.cl.textSecondary,
                          fontSize: 12,
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

  Widget _sectionTitle(BuildContext context, String title) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 18,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 9),
        Text(
          title,
          style: TextStyle(
            color: context.cl.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  bool _isFutureRelease(MovieDetail movie) {
    final raw = movie.releaseDate;
    if (raw == null || raw.isEmpty) return false;
    final date = DateTime.tryParse(raw);
    if (date == null) return false;
    final today = DateTime.now();
    return date.isAfter(DateTime(today.year, today.month, today.day));
  }

  int _daysUntil(MovieDetail movie) {
    final date = DateTime.tryParse(movie.releaseDate ?? '');
    if (date == null) return 0;
    final today = DateTime.now();
    final start = DateTime(today.year, today.month, today.day);
    return date.difference(start).inDays;
  }

  void _showCollectionsSheet(BuildContext context, WidgetRef ref, Movie movie) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: context.cl.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (sheetContext) {
        return Consumer(
          builder: (context, ref, _) {
            final collections = ref.watch(movieCollectionsProvider);
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 22),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Thêm vào bộ sưu tập',
                      style: TextStyle(
                        color: context.cl.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 12),
                    for (final collection in MovieCollection.values)
                      _CollectionTile(
                        label: collection.label,
                        selected:
                            collections[collection]?.any(
                              (m) => m.id == movie.id,
                            ) ??
                            false,
                        onTap: () => ref
                            .read(movieCollectionsProvider.notifier)
                            .toggle(collection, movie),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _shareMovie(MovieDetail movie) {
    Share.share(
      '${movie.title}\n'
      '${movie.voteAverage.toStringAsFixed(1)}/10\n\n'
      'Khám phá trên phimhayup',
    );
  }
}

class _CollectionTile extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _CollectionTile({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      onTap: onTap,
      leading: Icon(
        selected ? Icons.check_circle_rounded : Icons.circle_outlined,
        color: selected ? AppColors.primary : context.cl.textMuted,
      ),
      title: Text(label, style: TextStyle(color: context.cl.textPrimary)),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _HeaderIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.48),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
        ),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }
}
