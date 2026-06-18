import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
          icon: Icon(Icons.arrow_back_ios_rounded,
              color: context.cl.textPrimary),
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
        _buildLastUpdated(context, '01/06/2025'),
        const SizedBox(height: 20),
        _buildIntro(context),
        const SizedBox(height: 24),
        _buildSection(
          context,
          '1. Thông Tin Chúng Tôi Thu Thập',
          'PhimHay không thu thập, lưu trữ hoặc chia sẻ bất kỳ thông tin cá nhân nào của bạn trên máy chủ của chúng tôi.\n\n'
              'Dữ liệu duy nhất được lưu cục bộ trên thiết bị của bạn là:\n'
              '• Danh sách phim yêu thích (Watchlist) — lưu trong bộ nhớ thiết bị, không đồng bộ lên server\n\n'
              'Dữ liệu này không bao giờ rời khỏi thiết bị của bạn và bạn có thể xóa bất kỳ lúc nào.',
        ),
        _buildSection(
          context,
          '2. Dịch Vụ Bên Thứ Ba',
          'Ứng dụng sử dụng các dịch vụ bên thứ ba sau:\n\n'
              '• TMDB (The Movie Database) — cung cấp thông tin phim, hình ảnh, trailer. Chính sách bảo mật tại: https://www.themoviedb.org/privacy-policy\n\n'
              '• YouTube — phát trailer thông qua YouTube Player. Chính sách bảo mật Google tại: https://policies.google.com/privacy\n\n'
              'Khi bạn xem trailer, YouTube có thể thu thập dữ liệu theo chính sách của họ.',
        ),
        _buildSection(
          context,
          '3. Quyền Truy Cập Thiết Bị',
          'PhimHay yêu cầu các quyền sau:\n\n'
              '• Truy cập Internet — để tải dữ liệu phim từ TMDB và phát trailer từ YouTube\n\n'
              'Ứng dụng không yêu cầu quyền truy cập camera, danh bạ, vị trí, hay bất kỳ dữ liệu cá nhân nào khác.',
        ),
        _buildSection(
          context,
          '4. Trẻ Em',
          'Ứng dụng này không hướng đến đối tượng trẻ em dưới 13 tuổi và chúng tôi không cố ý thu thập thông tin từ trẻ em. Nếu bạn phát hiện trẻ em đã cung cấp thông tin, vui lòng liên hệ với chúng tôi để xóa.',
        ),
        _buildSection(
          context,
          '5. Bảo Mật',
          'Vì PhimHay không thu thập hay truyền dữ liệu cá nhân lên server, rủi ro bảo mật được giảm thiểu tối đa. Danh sách yêu thích được lưu cục bộ và được bảo vệ bởi hệ thống bảo mật của thiết bị.',
        ),
        _buildSection(
          context,
          '6. Thay Đổi Chính Sách',
          'Chúng tôi có thể cập nhật Chính sách Quyền Riêng Tư này theo thời gian. Khi có thay đổi, chúng tôi sẽ cập nhật ngày "Cập nhật lần cuối" ở đầu trang này. Việc tiếp tục sử dụng ứng dụng sau khi có thay đổi đồng nghĩa với việc bạn chấp nhận chính sách mới.',
        ),
        _buildSection(
          context,
          '7. Liên Hệ',
          'Nếu bạn có câu hỏi về Chính sách Quyền Riêng Tư này, vui lòng liên hệ:\n\n'
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
      'PhimHay ("chúng tôi") cam kết bảo vệ quyền riêng tư của bạn. '
      'Chính sách này giải thích cách chúng tôi xử lý thông tin khi bạn sử dụng ứng dụng PhimHay trên Android và iOS.',
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
