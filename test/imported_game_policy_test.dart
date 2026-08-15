import 'package:flutter_test/flutter_test.dart';
import 'package:nova_2048/app/state/app_controller.dart';
import 'package:nova_2048/data/local_store.dart';
import 'package:nova_2048/domain/game_state.dart';
import 'package:nova_2048/domain/game_types.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  GameState imported({
    GameMode mode = GameMode.classic,
    int? seed,
    int target = 2048,
    GameStatus status = GameStatus.playing,
    int score = 0,
    int bestScore = 9999,
  }) {
    return GameState(
      config: GameConfig(mode: mode, size: 4, target: target, seed: seed),
      board: [
        [2, 2, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
      ],
      score: score,
      bestScore: bestScore,
      status: status,
      rngState: 321,
      startedAt: DateTime.utc(2026, 8, 14, 9),
    );
  }

  test(
    'import restores current game but ignores imported lifetime best',
    () async {
      final controller = AppController(store: LocalStore());
      await controller.initialize();
      controller.stats.bestScore = 500;

      await controller.importGameBackup(imported());

      expect(controller.hasGame, isTrue);
      expect(controller.currentGameIsUnranked, isTrue);
      expect(controller.game!.bestScore, 500);
      expect(controller.stats.bestScore, 500);
      expect(controller.canUndo, isFalse);
    },
  );

  test(
    'unranked imported moves do not affect player records or Daily history',
    () async {
      final store = LocalStore();
      final controller = AppController(store: store);
      await controller.initialize();
      controller.stats.gamesPlayed = 3;
      controller.stats.gamesWon = 1;
      controller.stats.bestScore = 256;
      controller.stats.highestTile = 128;
      controller.stats.totalMoves = 30;
      controller.stats.totalMerges = 12;
      controller.stats.currentStreak = 1;
      controller.stats.bestStreak = 2;

      await controller.importGameBackup(
        imported(mode: GameMode.daily, seed: 20260814),
      );
      final outcome = await controller.move(Direction.left);

      expect(outcome?.changed, isTrue);
      expect(controller.currentGameIsUnranked, isTrue);
      expect(controller.stats.gamesPlayed, 3);
      expect(controller.stats.gamesWon, 1);
      expect(controller.stats.bestScore, 256);
      expect(controller.stats.highestTile, 128);
      expect(controller.stats.totalMoves, 30);
      expect(controller.stats.totalMerges, 12);
      expect(controller.stats.currentStreak, 1);
      expect(controller.stats.bestStreak, 2);
      expect(controller.dailyHistory, isEmpty);
      expect(
        controller.achievements.where((achievement) => achievement.unlocked),
        isEmpty,
      );
    },
  );

  test(
    'unranked marker survives restart and keeps later moves unranked',
    () async {
      final store = LocalStore();
      final first = AppController(store: store);
      await first.initialize();
      first.stats.totalMoves = 8;
      await first.importGameBackup(imported());
      await first.move(Direction.left);

      final restored = AppController(store: store);
      await restored.initialize();

      expect(restored.currentGameIsUnranked, isTrue);
      expect(restored.stats.totalMoves, 8);

      restored.game!.board
        ..[0] = [2, 2, 0, 0]
        ..[1] = [0, 0, 0, 0]
        ..[2] = [0, 0, 0, 0]
        ..[3] = [0, 0, 0, 0];
      await restored.move(Direction.left);

      expect(restored.stats.totalMoves, 8);
      expect(restored.currentGameIsUnranked, isTrue);
    },
  );

  test('starting a normal new game exits unranked policy', () async {
    final controller = AppController(store: LocalStore());
    await controller.initialize();
    await controller.importGameBackup(imported());

    await controller.newGame(
      const GameConfig(mode: GameMode.classic, size: 4, seed: 77),
    );

    expect(controller.currentGameIsUnranked, isFalse);
    expect(controller.stats.gamesPlayed, 1);

    controller.game!.board
      ..[0] = [2, 2, 0, 0]
      ..[1] = [0, 0, 0, 0]
      ..[2] = [0, 0, 0, 0]
      ..[3] = [0, 0, 0, 0];
    await controller.move(Direction.left);

    expect(controller.stats.totalMoves, 1);
    expect(controller.stats.totalMerges, 1);
  });

  test('terminal imported game never awards a local win', () async {
    final controller = AppController(store: LocalStore());
    await controller.initialize();

    await controller.importGameBackup(
      imported(target: 2, status: GameStatus.won, score: 16),
    );
    await controller.refreshChallengeStatus();

    expect(controller.currentGameIsUnranked, isTrue);
    expect(controller.stats.gamesPlayed, 0);
    expect(controller.stats.gamesWon, 0);
    expect(controller.stats.currentStreak, 0);
  });
}
