import 'package:flutter/material.dart';

import '../core/theme/nova_theme.dart';
import '../features/about/about_screen.dart';
import '../features/achievements/achievements_screen.dart';
import '../features/game/game_screen.dart';
import '../features/guide/guide_screen.dart';
import '../features/home/home_screen.dart';
import '../features/modes/mode_selection_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/statistics/statistics_screen.dart';
import '../features/support/support_screen.dart';
import 'state/app_controller.dart';
import 'state/app_scope.dart';

class NovaApp extends StatelessWidget {
  const NovaApp({required this.controller, super.key});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return AppScope(
      controller: controller,
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          return MaterialApp(
            title: '2048 Nova',
            debugShowCheckedModeBanner: false,
            theme: NovaTheme.light(controller.settings.highContrast),
            darkTheme: NovaTheme.dark(controller.settings.highContrast),
            themeMode: controller.settings.themeMode,
            initialRoute: '/',
            routes: {
              '/': (_) => const HomeScreen(),
              '/modes': (_) => const ModeSelectionScreen(),
              '/game': (_) => const GameScreen(),
              '/statistics': (_) => const StatisticsScreen(),
              '/achievements': (_) => const AchievementsScreen(),
              '/settings': (_) => const SettingsScreen(),
              '/guide': (_) => const GuideScreen(),
              '/about': (_) => const AboutScreen(),
              '/support': (_) => const SupportScreen(),
            },
          );
        },
      ),
    );
  }
}
