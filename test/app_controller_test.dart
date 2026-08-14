import 'package:flutter_test/flutter_test.dart';
import 'package:nova_2048/app/state/app_controller.dart';
import 'package:nova_2048/core/theme/nova_theme.dart';
import 'package:nova_2048/data/local_store.dart';
import 'package:nova_2048/domain/game_types.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('settings persist theme palette and accessibility options', () async {
    final controller = AppController(store: LocalStore());
    await controller.initialize();
    await controller.updateSettings((settings) {
      settings.palette = NovaPalette.ocean;
      settings.highContrast = true;
      settings.reducedMotion = true;
    });

    final restored = AppController(store: LocalStore());
    await restored.initialize();

    expect(restored.settings.palette, NovaPalette.ocean);
    expect(restored.settings.highContrast, isTrue);
    expect(restored.settings.reducedMotion, isTrue);
  });

  test('concurrent move requests are serialized', () async {
    final controller = AppController(store: LocalStore());
    await controller.initialize();
    await controller.newGame(
      const GameConfig(mode: GameMode.classic, size: 4),
    );
    final direction = controller.hint();
    expect(direction, isNotNull);

    final results = await Future.wait([
      controller.move(direction!),
      controller.move(direction),
    ]);

    expect(results.whereType<Object>(), hasLength(1));
  });

  test('losing after continuing a win does not erase the win streak', () async {
    final controller = AppController(store: LocalStore());
    await controller.initialize();
    await controller.newGame(
      const GameConfig(mode: GameMode.classic, size: 4, target: 4),
    );

    controller.game!.board
      ..[0] = [2, 2, 0, 0]
      ..[1] = [0, 0, 0, 0]
      ..[2] = [0, 0, 0, 0]
      ..[3] = [0, 0, 0, 0];

    await controller.move(Direction.left);
    expect(controller.game!.status, GameStatus.won);
    expect(controller.stats.gamesWon, 1);
    expect(controller.stats.currentStreak, 1);

    await controller.continueAfterWin();
    controller.game!.board
      ..[0] = [4, 8, 16, 32]
      ..[1] = [64, 128, 256, 512]
      ..[2] = [1024, 4, 8, 16]
      ..[3] = [0, 32, 64, 128];

    await controller.move(Direction.left);

    expect(controller.game!.status, GameStatus.lost);
    expect(controller.stats.gamesWon, 1);
    expect(controller.stats.currentStreak, 1);
  });

  test('clear all restores in-memory defaults', () async {
    final controller = AppController(store: LocalStore());
    await controller.initialize();
    await controller.newGame(
      const GameConfig(mode: GameMode.classic, size: 4),
    );
    await controller.updateSettings(
      (settings) => settings.palette = NovaPalette.sunset,
    );

    await controller.clearAllData();

    expect(controller.hasGame, isFalse);
    expect(controller.settings.palette, NovaPalette.classic);
    expect(controller.stats.gamesPlayed, 0);
    expect(controller.dailyHistory, isEmpty);
  });
}
