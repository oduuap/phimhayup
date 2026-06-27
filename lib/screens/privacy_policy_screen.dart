import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phimhayokup/config/app_config.dart';
import 'package:phimhayokup/utils/app_colors.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

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
        title: const Text('Chính Sách Quyền Riêng Tư'),
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: _PolicyContent(),
      ),
    );
  }
}

class _PolicyContent extends StatelessWidget {
  const _PolicyContent();

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
          '1. Dữ Liệu PhimHay Lưu Trữ',
          'PhimHay không yêu cầu đăng nhập và không thu thập tên, email, số điện thoại, vị trí, danh bạ, ảnh, camera hoặc dữ liệu nhạy cảm của bạn.\n\n'
              'Ứng dụng chỉ lưu cục bộ trên thiết bị các dữ liệu phục vụ tính năng:\n'
              '- Danh sách phim yêu thích (Watchlist)\n'
              '- Lịch sử tìm kiếm gần đây\n'
              '- Số lần mở ứng dụng để hiển thị hộp thoại đánh giá phù hợp\n\n'
              'Các dữ liệu này nằm trong bộ nhớ thiết bị của bạn và có thể được xóa bằng cách xóa dữ liệu ứng dụng hoặc gỡ cài đặt ứng dụng.',
        ),
        _buildSection(
          context,
          '2. Dữ Liệu Được Gửi Ra Ngoài Thiết Bị',
          'Khi bạn sử dụng các tính năng tra cứu phim, PhimHay gửi truy vấn tìm kiếm, mã phim, thể loại hoặc trang dữ liệu cần tải tới máy chủ proxy của PhimHay để gọi TMDB. Các yêu cầu này dùng để trả về thông tin phim, hình ảnh, diễn viên, trailer và đánh giá.\n\n'
              'PhimHay không bán dữ liệu người dùng và không dùng dữ liệu này để quảng cáo cá nhân hóa.',
        ),
        _buildSection(
          context,
          '3. Dịch Vụ Bên Thứ Ba',
          'PhimHay sử dụng các dịch vụ bên thứ ba sau:\n\n'
              '- TMDB (The Movie Database): cung cấp thông tin phim, hình ảnh, diễn viên và đánh giá. Chính sách bảo mật: https://www.themoviedb.org/privacy-policy\n'
              '- YouTube/Google: phát trailer thông qua YouTube Player. Chính sách bảo mật: https://policies.google.com/privacy\n'
              '- Các nền tảng xem phim hợp pháp như Netflix, FPT Play, Galaxy Play, Max và ClipTV: PhimHay chỉ mở trang tìm kiếm bên ngoài ứng dụng khi bạn chọn nền tảng.\n\n'
              'Khi bạn mở trailer hoặc nền tảng bên ngoài, dịch vụ đó có thể xử lý dữ liệu theo chính sách riêng của họ.',
        ),
        _buildSection(
          context,
          '4. Quyền Truy Cập Thiết Bị',
          'PhimHay chỉ yêu cầu quyền truy cập Internet và trạng thái mạng để tải dữ liệu phim, hình ảnh và trailer. Ứng dụng không yêu cầu quyền camera, microphone, danh bạ, vị trí hoặc tệp cá nhân.',
        ),
        _buildSection(
          context,
          '5. Trẻ Em',
          'Ứng dụng không hướng đến trẻ em dưới 13 tuổi. PhimHay không cố ý thu thập thông tin cá nhân từ trẻ em.',
        ),
        _buildSection(
          context,
          '6. Bảo Mật',
          'Các kết nối mạng của ứng dụng sử dụng HTTPS. Dữ liệu cục bộ như Watchlist và lịch sử tìm kiếm được lưu trên thiết bị của bạn.',
        ),
        _buildSection(
          context,
          '7. Liên Hệ',
          'Nếu bạn có câu hỏi về Chính sách Quyền Riêng Tư này, vui lòng liên hệ:\n\n'
              'Email: ${AppConfig.supportEmail}\n'
              'Privacy URL: ${AppConfig.privacyPolicyUrl}',
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
      'PhimHay là ứng dụng tra cứu thông tin phim, xem trailer và tìm nền tảng xem hợp pháp. Chính sách này giải thích cách ứng dụng xử lý dữ liệu khi bạn sử dụng PhimHay.',
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
