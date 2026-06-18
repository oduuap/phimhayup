import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phimhayokup/models/person.dart';
import 'package:phimhayokup/providers/movie_providers.dart';
import 'package:phimhayokup/utils/app_colors.dart';

class PersonScreen extends ConsumerWidget {
  final int personId;

  const PersonScreen({super.key, required this.personId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final personAsync = ref.watch(personDetailProvider(personId));

    return Scaffold(
      backgroundColor: context.cl.background,
      body: personAsync.when(
        loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primary)),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: context.cl.textMuted, size: 60),
              const SizedBox(height: 16),
              Text(
                'Không thể tải thông tin diễn viên',
                style: TextStyle(color: context.cl.textSecondary),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () =>
                    ref.invalidate(personDetailProvider(personId)),
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary),
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
        data: (person) => _buildContent(context, person),
      ),
    );
  }

  Widget _buildContent(BuildContext context, PersonDetail person) {
    return CustomScrollView(
      slivers: [
        _buildHeader(context, person),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfo(context, person),
                if (person.biography.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  _buildBio(context, person),
                ],
                if (person.movies.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  _buildMovies(context, person),
                  const SizedBox(height: 32),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  SliverAppBar _buildHeader(BuildContext context, PersonDetail person) {
    return SliverAppBar(
      expandedHeight: 320,
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
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            if (person.profileUrl.isNotEmpty)
              CachedNetworkImage(
                imageUrl: person.profileUrl,
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
              )
            else
              Container(
                color: context.cl.surface,
                child: Center(
                  child: Icon(Icons.person_outline,
                      size: 100, color: context.cl.textMuted),
                ),
              ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, context.cl.background],
                  stops: const [0.5, 1.0],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfo(BuildContext context, PersonDetail person) {
    final dept = switch (person.knownFor) {
      'Acting' => 'Diễn Viên',
      'Directing' => 'Đạo Diễn',
      'Writing' => 'Biên Kịch',
      'Production' => 'Sản Xuất',
      _ => person.knownFor,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          person.name,
          style: TextStyle(
            color: context.cl.textPrimary,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        Text(dept,
            style:
                const TextStyle(color: AppColors.primary, fontSize: 13)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            if (person.birthday != null)
              _infoChip(context, Icons.cake_outlined,
                  _formatDate(person.birthday!)),
            if (person.ageText.isNotEmpty)
              _infoChip(context, Icons.person_outline, person.ageText),
            if (person.placeOfBirth != null)
              _infoChip(
                  context, Icons.place_outlined, person.placeOfBirth!),
          ],
        ),
      ],
    );
  }

  Widget _infoChip(BuildContext context, IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: context.cl.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: context.cl.textMuted),
          const SizedBox(width: 6),
          Flexible(
            child: Text(text,
                style: TextStyle(
                    color: context.cl.textSecondary, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  String _formatDate(String date) {
    try {
      final d = DateTime.parse(date);
      return '${d.day}/${d.month}/${d.year}';
    } catch (_) {
      return date;
    }
  }

  Widget _buildBio(BuildContext context, PersonDetail person) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tiểu Sử',
          style: TextStyle(
            color: context.cl.textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          person.biography,
          style: TextStyle(
            color: context.cl.textSecondary,
            fontSize: 14,
            height: 1.6,
          ),
        ),
      ],
    );
  }

  Widget _buildMovies(BuildContext context, PersonDetail person) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Phim Tham Gia',
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
            itemCount: person.movies.length,
            itemBuilder: (context, index) {
              final movie = person.movies[index];
              return GestureDetector(
                onTap: () => context.push('/movie/${movie.id}'),
                child: Container(
                  width: 120,
                  margin: EdgeInsets.only(
                      right: index < person.movies.length - 1 ? 12 : 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: CachedNetworkImage(
                          imageUrl: movie.posterUrl,
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
                        movie.title,
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
}
