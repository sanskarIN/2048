import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nova_2048/app/state/app_controller.dart';
import 'package:nova_2048/app/state/app_scope.dart';
import 'package:nova_2048/data/local_store.dart';
import 'package:nova_2048/domain/game_types.dart';
import 'package:nova_2048/features/game/game_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/localized_test_app.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Future<AppController> pumpGame(
    WidgetTester tester, {
    required bool custom,
    Locale? locale,
  }) async {
    final controller = AppController(store: LocalStore());
    await controller.initialize();
    await controller.updateSettings((settings) {
      settings.confirmRestart = false;
      settings.soundEnabled = false;
      settings.hapticsEnabled = false;
    });
    await controller.newGame(
      const GameConfig(
        mode: GameMode.target,
        size: 6,
        target: 8192,
        seed: 20260818,
      ),
      custom: custom,
    );
    await tester.pumpWidget(
      localizedTestApp(
        locale: locale,
        home: AppScope(controller: controller, child: const GameScreen()),
      ),
    );
    await tester.pumpAndSettle();
    return controller;
  }

  testWidgets('custom game shows localized custom-session disclosure', (
    tester,
  ) async {
    await pumpGame(tester, custom: true);

    expect(find.text('Custom game'), findsOneWidget);

    SharedPreferences.setMockInitialValues({});
    await pumpGame(tester, custom: true, locale: const Locale('hi'));

    expect(find.text('कस्टम गेम'), findsOneWidget);
  });

  testWidgets('built-in game does not show custom-session disclosure', (
    tester,
  ) async {
    await pumpGame(tester, custom: false);

    expect(find.text('Custom game'), findsNothing);
  });

  testWidgets('restarting a custom game preserves record isolation', (
    tester,
  ) async {
    final controller = await pumpGame(tester, custom: true);
    final gamesBeforeRestart = controller.stats.gamesPlayed;

    await tester.tap(find.byTooltip('New game'));
    await tester.pumpAndSettle();

    expect(controller.currentGameIsCustom, isTrue);
    expect(controller.stats.gamesPlayed, gamesBeforeRestart + 1);
    expect(controller.stats.existingRecordFor(GameMode.target), isNull);
    expect(controller.game?.config.size, 6);
    expect(controller.game?.config.target, 8192);
    expect(controller.game?.config.seed, 20260818);
    expect(find.text('Custom game'), findsOneWidget);
  });
}
