import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:phimhayokup/models/movie.dart';
import 'package:phimhayokup/utils/app_colors.dart';
import 'package:phimhayokup/widgets/movie_card.dart';

class MovieSection extends StatelessWidget {
  final String title;
  final AsyncValue<List<Movie>> moviesAsync;
  final VoidCallback? onSeeAll;
  final VoidCallback? onRetry;
  final IconData? icon;
  final Color? iconColor;

  const MovieSection({
    super.key,
    required this.title,
    required this.moviesAsync,
    this.onSeeAll,
    this.onRetry,
    this.icon,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    // 3 equal cards: leftPad(16) + 3*cardWidth + 2*gap(12) = screenWidth
    final cardWidth = (screenWidth - 40) / 3.0;
    final cardHeight = (cardWidth * 1.5).roundToDouble();
    final sectionHeight = cardHeight + 60;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  if (icon != null) ...[
                    Icon(
                      icon,
                      size: 16,
                      color: iconColor ?? AppColors.primary,
                    ),
                    const SizedBox(width: 6),
                  ],
                  Text(title, style: Theme.of(context).textTheme.titleLarge),
                ],
              ),
              if (onSeeAll != null)
                GestureDetector(
                  onTap: onSeeAll,
                  child: const Text(
                    'Xem tất cả',
                    style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 13,
                        fontWeight: FontWeight.w500),
                  ),
                ),
            ],
          ),
        ),
        SizedBox(
          height: sectionHeight,
          child: moviesAsync.when(
            loading: () => _buildShimmerList(context, cardWidth, cardHeight),
            error: (e, stack) {
              debugPrint('MovieSection error [$title]: $e');
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.wifi_off_rounded,
                        color: context.cl.textMuted, size: 28),
                    const SizedBox(height: 8),
                    Text('Không có kết nối mạng',
                        style: TextStyle(
                            color: context.cl.textMuted, fontSize: 13)),
                    if (onRetry != null) ...[
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: onRetry,
                        child: const Text('Thử lại',
                            style: TextStyle(
                                color: AppColors.primary, fontSize: 13)),
                      ),
                    ],
                  ],
                ),
              );
            },
            data: (movies) => ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(left: 16),
              itemCount: movies.length,
              itemBuilder: (context, index) => Padding(
                padding:
                    EdgeInsets.only(right: index < movies.length - 1 ? 12 : 0),
                child: MovieCard(
                  movie: movies[index],
                  width: cardWidth,
                  height: cardHeight,
                  onTap: () => context.push('/movie/${movies[index].id}'),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildShimmerList(
      BuildContext context, double cardWidth, double cardHeight) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.only(left: 16),
      itemCount: 6,
      itemBuilder: (context, index) => Padding(
        padding: EdgeInsets.only(right: index < 5 ? 12 : 0),
        child: Shimmer.fromColors(
          baseColor: context.cl.surface,
          highlightColor: context.cl.surfaceVariant,
          child: Container(
            width: cardWidth,
            height: cardHeight,
            decoration: BoxDecoration(
              color: context.cl.surface,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ),
    );
  }
}
