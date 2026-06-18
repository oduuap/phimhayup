import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phimhayokup/screens/explore_screen.dart';
import 'package:phimhayokup/screens/home_screen.dart';
import 'package:phimhayokup/screens/main_shell.dart';
import 'package:phimhayokup/screens/movie_detail_screen.dart';
import 'package:phimhayokup/screens/person_screen.dart';
import 'package:phimhayokup/screens/privacy_policy_screen.dart';
import 'package:phimhayokup/screens/search_screen.dart';
import 'package:phimhayokup/screens/settings_screen.dart';
import 'package:phimhayokup/screens/terms_screen.dart';
import 'package:phimhayokup/screens/top_rated_screen.dart';
import 'package:phimhayokup/screens/trailer_screen.dart';
import 'package:phimhayokup/screens/watch_screen.dart';
import 'package:phimhayokup/screens/watchlist_screen.dart';

CustomTransitionPage<void> _buildSlidePage(Widget child, GoRouterState state) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 280),
    reverseTransitionDuration: const Duration(milliseconds: 220),
    transitionsBuilder: (context, animation, secondary, child) {
      final slide = Tween<Offset>(
        begin: const Offset(1.0, 0.0),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));
      return SlideTransition(position: slide, child: child);
    },
  );
}

final router = GoRouter(
  initialLocation: '/',
  routes: [
    ShellRoute(
      builder: (context, state, child) => MainShell(child: child),
      routes: [
        GoRoute(
          path: '/',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: HomeScreen()),
        ),
        GoRoute(
          path: '/search',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: SearchScreen()),
        ),
        GoRoute(
          path: '/explore',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: ExploreScreen()),
        ),
        GoRoute(
          path: '/top-rated',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: TopRatedScreen()),
        ),
        GoRoute(
          path: '/watchlist',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: WatchlistScreen()),
        ),
      ],
    ),
    GoRoute(
      path: '/movie/:id',
      pageBuilder: (context, state) => _buildSlidePage(
        MovieDetailScreen(movieId: int.parse(state.pathParameters['id']!)),
        state,
      ),
    ),
    GoRoute(
      path: '/watch/:id',
      pageBuilder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        final title = state.uri.queryParameters['title'] ?? '';
        return _buildSlidePage(WatchScreen(movieId: id, movieTitle: title), state);
      },
    ),
    GoRoute(
      path: '/trailer/:key',
      pageBuilder: (context, state) => _buildSlidePage(
        TrailerScreen(videoKey: state.pathParameters['key']!),
        state,
      ),
    ),
    GoRoute(
      path: '/person/:id',
      pageBuilder: (context, state) => _buildSlidePage(
        PersonScreen(personId: int.parse(state.pathParameters['id']!)),
        state,
      ),
    ),
    GoRoute(
      path: '/settings',
      pageBuilder: (context, state) =>
          _buildSlidePage(const SettingsScreen(), state),
    ),
    GoRoute(
      path: '/privacy-policy',
      pageBuilder: (context, state) =>
          _buildSlidePage(const PrivacyPolicyScreen(), state),
    ),
    GoRoute(
      path: '/terms',
      pageBuilder: (context, state) =>
          _buildSlidePage(const TermsScreen(), state),
    ),
  ],
);
