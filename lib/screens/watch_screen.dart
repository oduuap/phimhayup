import 'package:flutter/material.dart';
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
    searchUrl: 'https://galaxyplay.vn/tim-kiem?q=',
  ),
  const StreamingPlatform(
    name: 'HBO Max',
    logo: 'H',
    color: Color(0xFF0D29D0),
    searchUrl: 'https://play.max.com/search?q=',
  ),
  const StreamingPlatform(
    name: 'Disney+',
    logo: 'D+',
    color: Color(0xFF0063E5),
    searchUrl: 'https://www.disneyplus.com/search?q=',
  ),
  const StreamingPlatform(
    name: 'ClipTV',
    logo: 'C',
    color: Color(0xFF00B4D8),
    searchUrl: 'https://www.cliptv.vn/tim-kiem?search=',
  ),
];

class WatchScreen extends StatelessWidget {
  final int movieId;
  final String movieTitle;

  const WatchScreen({
    super.key,
    required this.movieId,
    required this.movieTitle,
  });

  Future<void> _openPlatform(StreamingPlatform platform) async {
    final url =
        Uri.parse('${platform.searchUrl}${Uri.encodeComponent(movieTitle)}');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.cl.background,
      appBar: AppBar(
        backgroundColor: context.cl.background,
        title: const Text('Xem Phim'),
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
            _buildPlatformGrid(context),
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
          'Chọn nền tảng để xem',
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

  Widget _buildPlatformGrid(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 2.4,
      ),
      itemCount: _platforms.length,
      itemBuilder: (context, index) => _PlatformCard(
        platform: _platforms[index],
        onTap: () => _openPlatform(_platforms[index]),
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
          Icon(Icons.info_outline_rounded,
              color: context.cl.textMuted, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Nhấn vào nền tảng để tìm kiếm phim. Bạn cần tài khoản đăng ký trên từng nền tảng để xem nội dung.',
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
  final VoidCallback onTap;

  const _PlatformCard({required this.platform, required this.onTap});

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
            Text(
              platform.name,
              style: TextStyle(
                color: platform.color,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
