import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/country/country_screen.dart';
import '../../features/currency/currency_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/phrasebook/phrasebook_screen.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/toolkit/toolkit_screen.dart';
import '../../features/translate/presentation/result_screen.dart';

CustomTransitionPage<void> _fade(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondary, child) =>
        FadeTransition(opacity: animation, child: child),
  );
}

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', pageBuilder: (c, s) => _fade(s, const SplashScreen())),
    GoRoute(
        path: '/country',
        pageBuilder: (c, s) => _fade(s, const CountryScreen())),
    GoRoute(path: '/home', pageBuilder: (c, s) => _fade(s, const HomeScreen())),
    GoRoute(
        path: '/result',
        pageBuilder: (c, s) => _fade(s, const ResultScreen())),
    GoRoute(
        path: '/currency',
        pageBuilder: (c, s) => _fade(s, const CurrencyScreen())),
    GoRoute(
        path: '/tts',
        pageBuilder: (c, s) => _fade(s, const PhrasebookScreen())),
    GoRoute(
        path: '/phrasebook',
        pageBuilder: (c, s) => _fade(s, const PhrasebookScreen())),
    GoRoute(
        path: '/toolkit',
        pageBuilder: (c, s) => _fade(s, const ToolkitScreen())),
  ],
);