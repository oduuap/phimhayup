import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phimhayokup/providers/movie_providers.dart';
import 'package:phimhayokup/utils/app_colors.dart';
import 'package:phimhayokup/widgets/movie_card.dart';

class TopRatedScreen extends ConsumerWidget {
  const TopRatedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final moviesAsync = ref.watch(topRatedProvider);

    return Scaffold(
      backgroundColor: context.cl.background,
      appBar: AppBar(
        backgroundColor: context.cl.background,
        title: const Text('Đánh Giá Cao'),
      ),
      body: moviesAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (_, __) => Center(
          child: Text('Lỗi tải dữ liệu',
              style: TextStyle(color: context.cl.textSecondary)),
        ),
        data: (movies) => GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 10,
            mainAxisSpacing: 16,
            childAspectRatio: 0.46,
          ),
          itemCount: movies.length,
          itemBuilder: (context, index) {
            final movie = movies[index];
            return Stack(
              children: [
                MovieCard(
                  movie: movie,
                  width: double.infinity,
                  height: 160,
                  onTap: () => context.push('/movie/${movie.id}'),
                ),
                Positioned(
                  top: 6,
                  left: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '#${index + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
