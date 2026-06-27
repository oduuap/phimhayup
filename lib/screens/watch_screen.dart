import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phimhayokup/providers/user_features_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:phimhayokup/utils/app_colors.dart';

class StreamingPlatform {
  final String name;
  final String logo;
  final Color color;
  final String searchUrl;

  const StreamingPlatform({
    required this.name,
    required this.logo,
    required this.color,
    required this.searchUrl,
  });
}

final _platforms = [
  const StreamingPlatform(
    name: 'Netflix',
    logo: 'N',
    color: Color(0xFFE50914),
    searchUrl: 'https://www.netflix.com/search?q=',
  ),
  const StreamingPlatform(
    name: 'FPT Play',
    logo: 'F',
    color: Color(0xFFFF6B00),
    searchUrl: 'https://fptplay.vn/tim-kiem?keyword=',
  ),
  const StreamingPlatform(
    name: 'Galaxy Play',
    logo: 'G',
    color: Color(0xFF6C3CE1),
    searchUrl: 'https://galaxyplay.vn/search?q=',
  ),
  const StreamingPlatform(
    name: 'HBO Max',
    logo: 'H',
    color: Color(0xFF0D29D0),
    searchUrl: 'https://play.max.com/search?q=',
  ),
  const StreamingPlatform(
    name: 'ClipTV',
    logo: 'C',
    color: Color(0xFF00B4D8),
    searchUrl: 'https://www.cliptv.vn/tim-kiem?search=',
  ),
];

class WatchScreen extends ConsumerWidget {
  final int movieId;
  final String movieTitle;

  const WatchScreen({
    super.key,
    required this.movieId,
    required this.movieTitle,
  });

  Future<void> _openPlatform(StreamingPlatform platform) async {
    final url = Uri.parse(
      '${platform.searchUrl}${Uri.encodeComponent(movieTitle)}',
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preferred = ref.watch(preferredPlatformsProvider);
    final platforms = [..._platforms]
      ..sort((a, b) {
        final aFav = preferred.contains(a.name);
        final bFav = preferred.contains(b.name);
        if (aFav == bFav) return 0;
        return aFav ? -1 : 1;
      });

    return Scaffold(
      backgroundColor: context.cl.background,
      appBar: AppBar(
        backgroundColor: context.cl.background,
        title: const Text('Tìm nơi xem'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 28),
            _buildPlatformGrid(context, ref, platforms, preferred),
            const SizedBox(height: 28),
            _buildNote(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Chọn nền tảng hợp pháp',
          style: TextStyle(
            color: context.cl.textPrimary,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          movieTitle,
          style: TextStyle(
            color: context.cl.textMuted,
            fontSize: 14,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Widget _buildPlatformGrid(
    BuildContext context,
    WidgetRef ref,
    List<StreamingPlatform> platforms,
    List<String> preferred,
  ) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 2.4,
      ),
      itemCount: platforms.length,
      itemBuilder: (context, index) => _PlatformCard(
        platform: platforms[index],
        preferred: preferred.contains(platforms[index].name),
        onTap: () => _openPlatform(platforms[index]),
        onTogglePreferred: () => ref
            .read(preferredPlatformsProvider.notifier)
            .toggle(platforms[index].name),
      ),
    );
  }

  Widget _buildNote(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cl.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: context.cl.textMuted,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'PhimHay không phát trực tuyến hoặc lưu trữ phim. Các nút bên trên chỉ mở trang tìm kiếm của từng nền tảng; bạn cần tài khoản hợp lệ trên dịch vụ đó để xem nội dung.',
              style: TextStyle(
                color: context.cl.textSecondary,
                fontSize: 12,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlatformCard extends StatelessWidget {
  final StreamingPlatform platform;
  final bool preferred;
  final VoidCallback onTap;
  final VoidCallback onTogglePreferred;

  const _PlatformCard({
    required this.platform,
    required this.preferred,
    required this.onTap,
    required this.onTogglePreferred,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: platform.color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: platform.color.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: platform.color,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  platform.logo,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                platform.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: platform.color,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            IconButton(
              onPressed: onTogglePreferred,
              icon: Icon(
                preferred ? Icons.push_pin_rounded : Icons.push_pin_outlined,
                color: platform.color,
                size: 17,
              ),
              constraints: const BoxConstraints.tightFor(width: 34, height: 34),
              padding: EdgeInsets.zero,
              tooltip: preferred ? 'Bỏ ghim' : 'Ghim nền tảng',
            ),
          ],
        ),
      ),
    );
  }
}
