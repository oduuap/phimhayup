import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phimhayokup/config/app_config.dart';
import 'package:phimhayokup/utils/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _openUrl(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    final launched =
        await launchUrl(uri, mode: LaunchMode.externalApplication) ||
        await launchUrl(uri, mode: LaunchMode.platformDefault);

    if (!launched && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Không thể mở liên kết')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.cl.background,
      appBar: AppBar(
        backgroundColor: context.cl.background,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_rounded,
            color: context.cl.textPrimary,
          ),
          onPressed: () => context.pop(),
        ),
        title: const Text('Cài Đặt & Thông Tin'),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 8),
          _buildSection(
            context,
            title: 'Về Ứng Dụng',
            children: [
              _buildInfoTile(
                context,
                icon: Icons.movie_filter_rounded,
                title: AppConfig.appName,
                subtitle:
                    'Phiên bản ${AppConfig.appVersion} - tra cứu phim, trailer và nền tảng xem hợp pháp.',
              ),
              _buildInfoTile(
                context,
                icon: Icons.info_outline_rounded,
                title: 'Không phát trực tuyến',
                subtitle:
                    'PhimHay không lưu trữ, phát hoặc phân phối nội dung phim có bản quyền.',
              ),
            ],
          ),
          _buildSection(
            context,
            title: 'Nguồn Dữ Liệu & Credits',
            children: [
              _buildInfoTile(
                context,
                icon: Icons.data_object_rounded,
                title: 'TMDB',
                subtitle:
                    'Thông tin phim, diễn viên, hình ảnh và đánh giá được cung cấp bởi TMDB.',
              ),
              _buildInfoTile(
                context,
                icon: Icons.verified_outlined,
                title: 'TMDB Attribution',
                subtitle: AppConfig.tmdbAttribution,
              ),
              _buildNavTile(
                context,
                icon: Icons.open_in_new_rounded,
                title: 'Chính sách TMDB',
                subtitle: 'Mở trang The Movie Database',
                onTap: () => _openUrl(
                  context,
                  'https://www.themoviedb.org/privacy-policy',
                ),
              ),
            ],
          ),
          _buildSection(
            context,
            title: 'Pháp Lý',
            children: [
              _buildNavTile(
                context,
                icon: Icons.privacy_tip_outlined,
                title: 'Chính Sách Quyền Riêng Tư',
                subtitle: 'Cách PhimHay xử lý dữ liệu và dịch vụ bên thứ ba',
                onTap: () => context.push('/privacy-policy'),
              ),
              _buildNavTile(
                context,
                icon: Icons.gavel_rounded,
                title: 'Điều Khoản Sử Dụng',
                subtitle: 'Quy định khi sử dụng ứng dụng',
                onTap: () => context.push('/terms'),
              ),
              _buildInfoTile(
                context,
                icon: Icons.mail_outline_rounded,
                title: 'Liên hệ hỗ trợ',
                subtitle: AppConfig.supportEmail,
              ),
            ],
          ),
          const SizedBox(height: 32),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'PhimHay là ứng dụng khám phá phim. Ứng dụng chỉ mở tìm kiếm trên các nền tảng hợp pháp và không cung cấp dịch vụ streaming.',
                textAlign: TextAlign.center,
                style: TextStyle(color: context.cl.textMuted, fontSize: 12),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
          child: Text(
            title.toUpperCase(),
            style: TextStyle(
              color: context.cl.textMuted,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: context.cl.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildInfoTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: context.cl.surfaceVariant,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.primary, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: context.cl.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(color: context.cl.textMuted, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: context.cl.surfaceVariant,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: AppColors.primary, size: 18),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: context.cl.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(color: context.cl.textMuted, fontSize: 12),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: context.cl.textMuted,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
