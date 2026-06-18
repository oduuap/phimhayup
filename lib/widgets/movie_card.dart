import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:phimhayokup/models/movie.dart';
import 'package:phimhayokup/utils/app_colors.dart';

class MovieCard extends StatelessWidget {
  final Movie movie;
  final VoidCallback onTap;
  final double width;
  final double height;
  final String? heroTag;

  const MovieCard({
    super.key,
    required this.movie,
    required this.onTap,
    this.width = 130,
    this.height = 195,
    this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: width,
        child: LayoutBuilder(
          builder: (ctx, bc) {
            final double ph = bc.maxHeight.isFinite
                ? (bc.maxHeight - 64).clamp(40.0, height)
                : height;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildPoster(context, ph),
                const SizedBox(height: 6),
                _buildInfo(context),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildPoster(BuildContext context, double ph) {
    final poster = Container(
        width: width,
        height: ph,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: context.cl.surfaceVariant, width: 1),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(9),
          child: Stack(
            children: [
              CachedNetworkImage(
                imageUrl: movie.posterUrl,
                width: width,
                height: ph,
                fit: BoxFit.cover,
                placeholder: (context, url) => Shimmer.fromColors(
                  baseColor: context.cl.surface,
                  highlightColor: context.cl.surfaceVariant,
                  child: Container(
                    width: width,
                    height: ph,
                    color: context.cl.surface,
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  width: width,
                  height: ph,
                  color: context.cl.surfaceVariant,
                  child: Center(
                    child: Icon(Icons.movie_outlined,
                        color: context.cl.textMuted, size: 40),
                  ),
                ),
              ),
              Positioned(
                top: 6,
                right: 6,
                child: _buildRatingBadge(context),
              ),
            ],
          ),
        ),
    );
    if (heroTag != null) return Hero(tag: heroTag!, child: poster);
    return poster;
  }

  Widget _buildRatingBadge(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: context.cl.overlay,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, color: AppColors.gold, size: 12),
          const SizedBox(width: 2),
          Text(
            movie.voteAverage.toStringAsFixed(1),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          movie.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: context.cl.textPrimary,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        if (movie.year.isNotEmpty) ...[
          const SizedBox(height: 2),
          Text(
            movie.year,
            style: TextStyle(
              color: context.cl.textMuted,
              fontSize: 11,
            ),
          ),
        ],
      ],
    );
  }
}
