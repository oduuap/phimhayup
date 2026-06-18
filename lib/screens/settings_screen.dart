import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phimhayokup/utils/app_colors.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.cl.background,
      appBar: AppBar(
        backgroundColor: context.cl.background,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded,
              color: context.cl.textPrimary),
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
                title: 'PhimHay',
                subtitle: 'Phiên bản 1.0.0',
              ),
              _buildInfoTile(
                context,
                icon: Icons.data_object_rounded,
                title: 'Dữ liệu phim',
                subtitle: 'Cung cấp bởi TMDB (The Movie Database)',
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
                subtitle: 'Cách chúng tôi xử lý dữ liệu của bạn',
                route: '/privacy-policy',
              ),
              _buildNavTile(
                context,
                icon: Icons.gavel_rounded,
                title: 'Điều Khoản Sử Dụng',
                subtitle: 'Quy định khi sử dụng ứng dụng',
                route: '/terms',
              ),
            ],
          ),
          const SizedBox(height: 32),
          Center(
            child: Text(
              'Dữ liệu phim được cung cấp bởi TMDB.\nỨng dụng không lưu trữ hay phát trực tuyến nội dung phim.',
              textAlign: TextAlign.center,
              style: TextStyle(color: context.cl.textMuted, fontSize: 12),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context,
      {required String title, required List<Widget> children}) {
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
                Text(title,
                    style: TextStyle(
                        color: context.cl.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style:
                        TextStyle(color: context.cl.textMuted, fontSize: 12)),
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
    required String route,
  }) {
    return InkWell(
      onTap: () => context.push(route),
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
                  Text(title,
                      style: TextStyle(
                          color: context.cl.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w500)),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: TextStyle(
                          color: context.cl.textMuted, fontSize: 12)),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                color: context.cl.textMuted, size: 20),
          ],
        ),
      ),
    );
  }
}
