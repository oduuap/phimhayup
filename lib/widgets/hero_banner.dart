import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:phimhayokup/models/movie.dart';
import 'package:phimhayokup/utils/app_colors.dart';

class HeroBanner extends StatefulWidget {
  final List<Movie> movies;

  const HeroBanner({super.key, required this.movies});

  @override
  State<HeroBanner> createState() => _HeroBannerState();
}

class _HeroBannerState extends State<HeroBanner> {
  int _current = 0;
  late final PageController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
    _startAutoPlay();
  }

  void _startAutoPlay() {
    Future.delayed(const Duration(seconds: 4), () {
      if (!mounted) return;
      final next = (_current + 1) % widget.movies.length;
      _controller.animateToPage(
        next,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
      _startAutoPlay();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.movies.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 340,
      child: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            onPageChanged: (i) => setState(() => _current = i),
            itemCount: widget.movies.length,
            itemBuilder: (context, index) =>
                _buildPage(context, widget.movies[index]),
          ),
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: _buildIndicators(context),
          ),
        ],
      ),
    );
  }

  Widget _buildPage(BuildContext context, Movie movie) {
    return GestureDetector(
      onTap: () => context.push('/movie/${movie.id}'),
      child: Stack(
        fit: StackFit.expand,
        children: [
          CachedNetworkImage(
            imageUrl: movie.backdropUrl.isNotEmpty
                ? movie.backdropUrl
                : movie.posterUrl,
            fit: BoxFit.cover,
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  const Color(0x60000000),
                  const Color(0xDD000000),
                  context.cl.background,
                ],
                stops: const [0.0, 0.4, 0.75, 1.0],
              ),
            ),
          ),
          Positioned(
            bottom: 50,
            left: 16,
            right: 16,
            child: _buildInfo(context, movie),
          ),
        ],
      ),
    );
  }

  Widget _buildInfo(BuildContext context, Movie movie) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          movie.title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            if (movie.year.isNotEmpty) ...[
              const Text('',
                  style: TextStyle(color: Colors.white70, fontSize: 13)),
              Text(movie.year,
                  style:
                      const TextStyle(color: Colors.white70, fontSize: 13)),
              const SizedBox(width: 10),
            ],
            const Icon(Icons.star_rounded, color: AppColors.gold, size: 14),
            const SizedBox(width: 4),
            Text(
              movie.voteAverage.toStringAsFixed(1),
              style: const TextStyle(
                  color: AppColors.gold,
                  fontSize: 13,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _buildButton(
              context: context,
              icon: Icons.play_arrow_rounded,
              label: 'Xem Phim',
              isPrimary: true,
              onTap: () => context.push('/movie/${movie.id}'),
            ),
            const SizedBox(width: 10),
            _buildButton(
              context: context,
              icon: Icons.info_outline_rounded,
              label: 'Chi Tiết',
              isPrimary: false,
              onTap: () => context.push('/movie/${movie.id}'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required bool isPrimary,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: isPrimary
              ? AppColors.primary
              : context.cl.surface.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 5),
            Text(
              label,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIndicators(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        widget.movies.length,
        (i) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: i == _current ? 20 : 6,
          height: 6,
          decoration: BoxDecoration(
            color: i == _current ? AppColors.primary : context.cl.textMuted,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
      ),
    );
  }
}
