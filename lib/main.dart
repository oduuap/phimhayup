import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:phimhayokup/providers/theme_provider.dart';
import 'package:phimhayokup/router.dart';
import 'package:phimhayokup/screens/splash_screen.dart';
import 'package:phimhayokup/utils/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final openCount = (prefs.getInt('open_count') ?? 0) + 1;
  await prefs.setInt('open_count', openCount);

  runApp(ProviderScope(child: PhimHayApp(shouldRequestReview: openCount == 5)));
}

class PhimHayApp extends ConsumerStatefulWidget {
  final bool shouldRequestReview;

  const PhimHayApp({super.key, required this.shouldRequestReview});

  @override
  ConsumerState<PhimHayApp> createState() => _PhimHayAppState();
}

class _PhimHayAppState extends ConsumerState<PhimHayApp> {
  static const _policyConsentKey = 'policy_consent_v1';
  static const _onboardingSeenKey = 'onboarding_seen_v1';

  bool _splashDone = false;
  bool _firstRunDialogsScheduled = false;

  void _onSplashDone() {
    setState(() => _splashDone = true);
    _scheduleFirstRunDialogs();
    if (widget.shouldRequestReview) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final review = InAppReview.instance;
        if (await review.isAvailable()) {
          await review.requestReview();
        }
      });
    }
  }

  void _scheduleFirstRunDialogs() {
    if (_firstRunDialogsScheduled) return;
    _firstRunDialogsScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final prefs = await SharedPreferences.getInstance();
      final context = rootNavigatorKey.currentContext;
      if (context == null || !context.mounted) return;

      final onboardingSeen = prefs.getBool(_onboardingSeenKey) ?? false;
      if (!onboardingSeen) {
        await showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) => _OnboardingDialog(
            onDone: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setBool(_onboardingSeenKey, true);
              if (dialogContext.mounted) {
                Navigator.of(dialogContext).pop();
              }
            },
          ),
        );
      }

      final accepted = prefs.getBool(_policyConsentKey) ?? false;
      if (!mounted || accepted) return;

      final consentContext = rootNavigatorKey.currentContext;
      if (consentContext == null || !consentContext.mounted) return;

      await showDialog<void>(
        context: consentContext,
        barrierDismissible: false,
        builder: (dialogContext) => _PolicyConsentDialog(
          onAccept: () async {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setBool(_policyConsentKey, true);
            if (dialogContext.mounted) {
              Navigator.of(dialogContext).pop();
            }
          },
          onOpenPrivacy: () => router.push('/privacy-policy'),
          onOpenTerms: () => router.push('/terms'),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_splashDone) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: SplashScreen(onDone: _onSplashDone),
      );
    }

    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'phimhayup',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}

class _OnboardingDialog extends StatefulWidget {
  final Future<void> Function() onDone;

  const _OnboardingDialog({required this.onDone});

  @override
  State<_OnboardingDialog> createState() => _OnboardingDialogState();
}

class _OnboardingDialogState extends State<_OnboardingDialog> {
  final _controller = PageController();
  int _index = 0;

  final _items = const [
    _OnboardingItem(
      icon: Icons.movie_filter_outlined,
      title: 'Khám phá phim',
      text: 'Theo dõi phim nổi bật, sắp chiếu, đánh giá cao và tìm theo mood.',
    ),
    _OnboardingItem(
      icon: Icons.smart_display_outlined,
      title: 'Trailer hợp pháp',
      text: 'Xem trailer YouTube công khai và thông tin phim từ TMDB.',
    ),
    _OnboardingItem(
      icon: Icons.bookmark_border_rounded,
      title: 'Lưu gu của bạn',
      text: 'Tạo Watchlist, bộ sưu tập cá nhân và tìm nền tảng xem hợp pháp.',
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _index == _items.length - 1;

    return AlertDialog(
      backgroundColor: Theme.of(context).colorScheme.surface,
      insetPadding: const EdgeInsets.symmetric(horizontal: 22),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      contentPadding: const EdgeInsets.fromLTRB(20, 22, 20, 16),
      content: SizedBox(
        height: 300,
        width: 340,
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _controller,
                onPageChanged: (value) => setState(() => _index = value),
                itemCount: _items.length,
                itemBuilder: (context, index) => _items[index],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _items.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  width: i == _index ? 18 : 6,
                  height: 6,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    color: i == _index
                        ? AppTheme.primary
                        : Theme.of(context).dividerColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: isLast
                    ? widget.onDone
                    : () => _controller.nextPage(
                        duration: const Duration(milliseconds: 260),
                        curve: Curves.easeOutCubic,
                      ),
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                ),
                child: Text(isLast ? 'Bắt đầu' : 'Tiếp tục'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String text;

  const _OnboardingItem({
    required this.icon,
    required this.title,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 66,
          height: 66,
          decoration: BoxDecoration(
            color: AppTheme.primary.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Icon(icon, color: AppTheme.primary, size: 30),
        ),
        const SizedBox(height: 18),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyMedium?.color,
            fontSize: 14,
            height: 1.45,
          ),
        ),
      ],
    );
  }
}

class _PolicyConsentDialog extends StatelessWidget {
  final Future<void> Function() onAccept;
  final VoidCallback onOpenPrivacy;
  final VoidCallback onOpenTerms;

  const _PolicyConsentDialog({
    required this.onAccept,
    required this.onOpenPrivacy,
    required this.onOpenTerms,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Theme.of(context).colorScheme.surface,
      insetPadding: const EdgeInsets.symmetric(horizontal: 22),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      titlePadding: const EdgeInsets.fromLTRB(22, 22, 22, 0),
      contentPadding: const EdgeInsets.fromLTRB(22, 14, 22, 0),
      actionsPadding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      title: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.privacy_tip_outlined,
              color: AppTheme.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Chính sách sử dụng',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Trước khi tiếp tục, vui lòng xác nhận bạn đã đọc và đồng ý với Chính Sách Quyền Riêng Tư và Điều Khoản Sử Dụng của phimhayup.',
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyMedium?.color,
              fontSize: 14,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 14),
          _PolicyLinkButton(
            icon: Icons.privacy_tip_outlined,
            label: 'Xem Chính Sách Quyền Riêng Tư',
            onTap: onOpenPrivacy,
          ),
          const SizedBox(height: 8),
          _PolicyLinkButton(
            icon: Icons.gavel_outlined,
            label: 'Xem Điều Khoản Sử Dụng',
            onTap: onOpenTerms,
          ),
          const SizedBox(height: 12),
          Text(
            'phimhayup không phát trực tuyến, không lưu trữ và không phân phối nội dung phim có bản quyền.',
            style: TextStyle(
              color: Theme.of(context).textTheme.labelSmall?.color,
              fontSize: 12,
              height: 1.4,
            ),
          ),
        ],
      ),
      actions: [
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: onAccept,
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 13),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Tôi đã đọc và đồng ý',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ],
    );
  }
}

class _PolicyLinkButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _PolicyLinkButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).dividerColor),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.primary, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(label, style: const TextStyle(fontSize: 13.5)),
            ),
            const Icon(Icons.chevron_right_rounded, size: 20),
          ],
        ),
      ),
    );
  }
}
