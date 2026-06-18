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

  runApp(ProviderScope(
    child: PhimHayApp(shouldRequestReview: openCount == 5),
  ));
}

class PhimHayApp extends ConsumerStatefulWidget {
  final bool shouldRequestReview;

  const PhimHayApp({super.key, required this.shouldRequestReview});

  @override
  ConsumerState<PhimHayApp> createState() => _PhimHayAppState();
}

class _PhimHayAppState extends ConsumerState<PhimHayApp> {
  bool _splashDone = false;

  void _onSplashDone() {
    setState(() => _splashDone = true);
    if (widget.shouldRequestReview) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final review = InAppReview.instance;
        if (await review.isAvailable()) {
          await review.requestReview();
        }
      });
    }
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
      title: 'PhimHay',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
