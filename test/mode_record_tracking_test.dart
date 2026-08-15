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

  test('ranked progress updates and persists its mode record', () async {
    final store = LocalStore();
    final controller = AppController(store: store);
    await controller.initialize();
    await controller.newGame(const GameConfig(mode: GameMode.classic, size: 4));

    controller.game!.board
      ..[0] = [2, 2, 0, 0]
      ..[1] = [0, 0, 0, 0]
      ..[2] = [0, 0, 0, 0]
      ..[3] = [0, 0, 0, 0];
    await controller.move(Direction.left);

    final record = controller.stats.existingRecordFor(GameMode.classic);
    expect(record, isNotNull);
    expect(record!.bestScore, 4);
    expect(record.highestTile, 4);
    expect(record.bestScoreBoardSize, 4);
    expect(record.bestScoreTarget, 2048);

    final restored = AppController(store: LocalStore());
    await restored.initialize();
    final restoredRecord = restored.stats.existingRecordFor(GameMode.classic);
    expect(restoredRecord, isNotNull);
    expect(restoredRecord!.bestScore, 4);
    expect(restoredRecord.highestTile, 4);
  });

  test('legacy ranked current game seeds its mode record on restore', () async {
    const config = GameConfig(mode: GameMode.target, size: 4, target: 4096);
    final store = LocalStore();
    await store.saveStats({
      'gamesPlayed': 1,
      'bestScore': 4096,
      'highestTile': 512,
    });
    await store.saveGame(
      GameState(
        board: [
          [128, 0, 0, 0],
          [0, 0, 0, 0],
          [0, 0, 0, 0],
          [0, 0, 0, 0],
        ],
        config: config,
        score: 128,
        moves: 12,
        totalMerges: 6,
        startedAt: DateTime.utc(2026, 8, 15),
      ),
    );

    final controller = AppController(store: store);
    await controller.initialize();
    final record = controller.stats.existingRecordFor(GameMode.target);

    expect(record, isNotNull);
    expect(record!.bestScore, 128);
    expect(record.highestTile, 128);
    expect(record.bestScoreBoardSize, 4);
    expect(record.bestScoreTarget, 4096);

    final restoredAgain = AppController(store: LocalStore());
    await restoredAgain.initialize();
    expect(
      restoredAgain.stats.existingRecordFor(GameMode.target)?.bestScore,
      128,
    );
  });

  test('statistics reset keeps only the ranked active mode baseline', () async {
    final controller = AppController(store: LocalStore());
    await controller.initialize();
    await controller.newGame(const GameConfig(mode: GameMode.classic, size: 4));
    controller.game!.board
      ..[0] = [2, 2, 0, 0]
      ..[1] = [0, 0, 0, 0]
      ..[2] = [0, 0, 0, 0]
      ..[3] = [0, 0, 0, 0];
    await controller.move(Direction.left);

    await controller.newGame(GameConfig.preset(GameMode.quick));
    expect(controller.stats.existingRecordFor(GameMode.classic), isNotNull);
    expect(controller.stats.existingRecordFor(GameMode.quick), isNotNull);

    await controller.resetStats();

    expect(controller.stats.existingRecordFor(GameMode.classic), isNull);
    final quick = controller.stats.existingRecordFor(GameMode.quick);
    expect(quick, isNotNull);
    expect(quick!.highestTile, greaterThanOrEqualTo(2));
  });
}
