import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phimhayokup/config/app_config.dart';
import 'package:phimhayokup/utils/app_colors.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

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
        title: const Text('Điều Khoản Sử Dụng'),
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: _TermsContent(),
      ),
    );
  }
}

class _TermsContent extends StatelessWidget {
  const _TermsContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLastUpdated(context, '25/06/2026'),
        const SizedBox(height: 20),
        _buildIntro(context),
        const SizedBox(height: 24),
        _buildSection(
          context,
          '1. Mô Tả Dịch Vụ',
          'PhimHay cung cấp các tính năng khám phá phim, bao gồm thông tin phim, diễn viên, đánh giá, trailer YouTube, Watchlist cục bộ, tìm kiếm và gợi ý nền tảng xem hợp pháp.\n\n'
              'PhimHay không lưu trữ, phát trực tuyến, tải xuống, phân phối hoặc bán quyền truy cập vào nội dung phim có bản quyền.',
        ),
        _buildSection(
          context,
          '2. Nền Tảng Xem Phim',
          'Khi bạn chọn "Tìm nơi xem", ứng dụng chỉ mở trang tìm kiếm của các nền tảng bên ngoài như Netflix, FPT Play, Galaxy Play, Max, ClipTV hoặc dịch vụ tương tự. Việc xem nội dung phụ thuộc vào tài khoản, khu vực, giấy phép và điều khoản của từng nền tảng.',
        ),
        _buildSection(
          context,
          '3. Dữ Liệu Bên Thứ Ba',
          'Thông tin phim, hình ảnh, diễn viên và đánh giá được cung cấp bởi TMDB. Trailer được phát qua YouTube và thuộc quyền kiểm soát của Google/các chủ sở hữu nội dung.\n\n'
              'PhimHay không tuyên bố được TMDB, YouTube hoặc các nền tảng streaming chứng nhận, tài trợ hay liên kết chính thức.',
        ),
        _buildSection(
          context,
          '4. Giới Hạn Sử Dụng',
          'Bạn đồng ý không sử dụng ứng dụng để vi phạm pháp luật, xâm phạm quyền sở hữu trí tuệ, cố gắng trích xuất trái phép dữ liệu hoặc gây gián đoạn dịch vụ.',
        ),
        _buildSection(
          context,
          '5. Sở Hữu Trí Tuệ',
          'Giao diện, thiết kế và mã nguồn của PhimHay thuộc sở hữu của nhà phát triển. Dữ liệu phim thuộc TMDB. Hình ảnh, trailer, nhãn hiệu và nội dung phim thuộc các chủ sở hữu tương ứng.',
        ),
        _buildSection(
          context,
          '6. Giới Hạn Trách Nhiệm',
          'PhimHay được cung cấp theo hiện trạng. Chúng tôi không chịu trách nhiệm về sự thay đổi dữ liệu từ TMDB, lỗi hoặc gián đoạn của dịch vụ bên thứ ba, khả năng có sẵn của phim trên từng nền tảng, hoặc nội dung của trang web bên ngoài được mở từ ứng dụng.',
        ),
        _buildSection(
          context,
          '7. Liên Hệ',
          'Mọi câu hỏi về Điều Khoản Sử Dụng, vui lòng liên hệ:\n\n'
              'Email: ${AppConfig.supportEmail}\n'
              'Terms URL: ${AppConfig.termsUrl}',
        ),
        const SizedBox(height: 32),
        _buildFooter(context),
      ],
    );
  }

  Widget _buildLastUpdated(BuildContext context, String date) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: context.cl.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.update_rounded, size: 14, color: context.cl.textMuted),
          const SizedBox(width: 6),
          Text(
            'Cập nhật lần cuối: $date',
            style: TextStyle(color: context.cl.textMuted, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildIntro(BuildContext context) {
    return Text(
      'Vui lòng đọc kỹ các điều khoản này trước khi sử dụng PhimHay.',
      style: TextStyle(
        color: context.cl.textSecondary,
        fontSize: 14,
        height: 1.6,
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: context.cl.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            content,
            style: TextStyle(
              color: context.cl.textSecondary,
              fontSize: 14,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Center(
      child: Text(
        AppConfig.tmdbAttribution,
        textAlign: TextAlign.center,
        style: TextStyle(color: context.cl.textMuted, fontSize: 11),
      ),
    );
  }
}
