import 'package:flutter_test/flutter_test.dart';
import 'package:nova_2048/app/state/app_controller.dart';
import 'package:nova_2048/core/theme/nova_theme.dart';
import 'package:nova_2048/data/local_store.dart';
import 'package:nova_2048/domain/game_state.dart';
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

  test('malformed settings values fall back to safe defaults', () {
    final settings = AppSettings.fromJson({
      'themeMode': 42,
      'palette': false,
      'highContrast': 'yes',
      'reducedMotion': 1,
      'soundEnabled': null,
      'hapticsEnabled': 'no',
      'confirmRestart': [],
    });

    expect(settings.themeMode, ThemeMode.system);
    expect(settings.palette, NovaPalette.classic);
    expect(settings.highContrast, isFalse);
    expect(settings.reducedMotion, isFalse);
    expect(settings.soundEnabled, isTrue);
    expect(settings.hapticsEnabled, isTrue);
    expect(settings.confirmRestart, isTrue);
  });

  test('malformed statistics are sanitized to consistent values', () {
    final stats = PlayerStats.fromJson({
      'gamesPlayed': 'broken',
      'gamesWon': 99,
      'bestScore': -1,
      'highestTile': 3,
      'totalMoves': 1.5,
      'totalMerges': -4,
      'currentStreak': 4,
      'bestStreak': 2,
    });

    expect(stats.gamesPlayed, 0);
    expect(stats.gamesWon, 0);
    expect(stats.bestScore, 0);
    expect(stats.highestTile, 0);
    expect(stats.totalMoves, 0);
    expect(stats.totalMerges, 0);
    expect(stats.currentStreak, 4);
    expect(stats.bestStreak, 4);
  });

  test('malformed achievement timestamps do not break initialization', () async {
    SharedPreferences.setMockInitialValues({
      'nova.achievements.v1':
          '{"first_merge":42,"tile_128":"not-a-date","tile_256":true}',
    });

    final controller = AppController(store: LocalStore());
    await controller.initialize();

    expect(controller.achievements.every((item) => !item.unlocked), isTrue);
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

  test('timed challenge expiry resets an active streak', () async {
    const config = GameConfig(
      mode: GameMode.timeChallenge,
      size: 4,
      timeLimitSeconds: 1,
    );
    final controller = AppController(store: LocalStore());
    await controller.initialize();
    controller.stats.currentStreak = 3;
    controller.stats.bestStreak = 3;
    await controller.newGame(config);
    controller.game = GameState(
      board: [
        [2, 0, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
      ],
      config: config,
      startedAt: DateTime.now().subtract(const Duration(seconds: 2)),
    );

    await controller.refreshChallengeStatus();

    expect(controller.game!.status, GameStatus.lost);
    expect(controller.stats.currentStreak, 0);
    expect(controller.stats.bestStreak, 3);
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
