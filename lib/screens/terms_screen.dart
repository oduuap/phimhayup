import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
          icon: Icon(Icons.arrow_back_ios_rounded,
              color: context.cl.textPrimary),
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
        _buildLastUpdated(context, '01/06/2025'),
        const SizedBox(height: 20),
        _buildIntro(context),
        const SizedBox(height: 24),
        _buildSection(
          context,
          '1. Chấp Nhận Điều Khoản',
          'Bằng cách tải xuống, cài đặt hoặc sử dụng ứng dụng PhimHay, bạn đồng ý tuân theo các Điều khoản Sử dụng này. Nếu bạn không đồng ý, vui lòng không sử dụng ứng dụng.',
        ),
        _buildSection(
          context,
          '2. Mô Tả Dịch Vụ',
          'PhimHay là ứng dụng cung cấp thông tin về phim, bao gồm:\n\n'
              '• Thông tin phim, diễn viên, đánh giá từ TMDB\n'
              '• Xem trailer trên YouTube\n'
              '• Lưu danh sách phim yêu thích cục bộ\n'
              '• Tìm kiếm và khám phá phim\n\n'
              'Ứng dụng không cung cấp dịch vụ phát trực tuyến (streaming) nội dung phim có bản quyền.',
        ),
        _buildSection(
          context,
          '3. Giới Hạn Sử Dụng',
          'Bạn đồng ý không:\n\n'
              '• Sử dụng ứng dụng cho mục đích thương mại\n'
              '• Cố gắng sao chép, chỉnh sửa, dịch ngược hoặc trích xuất mã nguồn\n'
              '• Sử dụng ứng dụng để vi phạm luật pháp hiện hành\n'
              '• Cố gắng vượt qua các biện pháp bảo mật của ứng dụng',
        ),
        _buildSection(
          context,
          '4. Nội Dung Bên Thứ Ba',
          'Toàn bộ thông tin phim, hình ảnh và dữ liệu hiển thị trong ứng dụng được cung cấp bởi TMDB (The Movie Database). PhimHay không chịu trách nhiệm về tính chính xác hay đầy đủ của dữ liệu này.\n\n'
              'Trailer phim được phát qua YouTube và thuộc quyền kiểm soát của Google/các chủ sở hữu nội dung.',
        ),
        _buildSection(
          context,
          '5. Sở Hữu Trí Tuệ',
          'Giao diện, thiết kế và code của ứng dụng PhimHay thuộc sở hữu của nhà phát triển. Dữ liệu phim thuộc TMDB. Hình ảnh và trailer thuộc các nhà sản xuất phim tương ứng.\n\n'
              'Ứng dụng này sử dụng TMDB API nhưng không được TMDB chứng nhận hay tài trợ.',
        ),
        _buildSection(
          context,
          '6. Giới Hạn Trách Nhiệm',
          'PhimHay được cung cấp "nguyên trạng" mà không có bảo đảm nào. Chúng tôi không chịu trách nhiệm về:\n\n'
              '• Sự gián đoạn hoặc lỗi dịch vụ\n'
              '• Mất mát dữ liệu danh sách yêu thích\n'
              '• Thông tin phim không chính xác từ TMDB\n'
              '• Nội dung của các trang web bên thứ ba được liên kết',
        ),
        _buildSection(
          context,
          '7. Chấm Dứt',
          'Chúng tôi có quyền chấm dứt hoặc tạm ngừng quyền truy cập vào ứng dụng bất kỳ lúc nào nếu bạn vi phạm các Điều khoản này.',
        ),
        _buildSection(
          context,
          '8. Thay Đổi Điều Khoản',
          'Chúng tôi có thể cập nhật Điều khoản này theo thời gian. Việc tiếp tục sử dụng ứng dụng sau khi có thay đổi đồng nghĩa với việc bạn chấp nhận điều khoản mới.',
        ),
        _buildSection(
          context,
          '9. Liên Hệ',
          'Mọi câu hỏi về Điều khoản Sử dụng, vui lòng liên hệ:\n\n'
              'Email: support@phimhay.app',
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
      'Vui lòng đọc kỹ các Điều khoản Sử dụng này trước khi sử dụng ứng dụng PhimHay. '
      'Các điều khoản này quy định quyền và nghĩa vụ của bạn khi sử dụng dịch vụ của chúng tôi.',
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
        'This app uses TMDB and the TMDB APIs but is not\nendorsed or certified by TMDB.',
        textAlign: TextAlign.center,
        style: TextStyle(color: context.cl.textMuted, fontSize: 11),
      ),
    );
  }
}
