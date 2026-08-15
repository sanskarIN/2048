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

  test('imported backup progress never enters per-mode records', () async {
    final controller = AppController(store: LocalStore());
    await controller.initialize();

    await controller.importGameBackup(
      GameState(
        board: [
          [8192, 0, 0, 0],
          [0, 0, 0, 0],
          [0, 0, 0, 0],
          [0, 0, 0, 0],
        ],
        config: const GameConfig(
          mode: GameMode.endless,
          size: 4,
          target: 2048,
        ),
        score: 99999,
        moves: 200,
        totalMerges: 100,
        startedAt: DateTime.utc(2026, 8, 15),
      ),
    );

    expect(controller.currentGameIsUnranked, isTrue);
    expect(controller.stats.existingRecordFor(GameMode.endless), isNull);

    await controller.move(Direction.right);
    expect(controller.stats.existingRecordFor(GameMode.endless), isNull);

    await controller.resetStats();
    expect(controller.stats.existingRecordFor(GameMode.endless), isNull);
  });

  test('locally started seeded games remain ranked for mode records', () async {
    final controller = AppController(store: LocalStore());
    await controller.initialize();
    await controller.newGame(
      const GameConfig(
        mode: GameMode.target,
        size: 4,
        target: 4096,
        seed: 20260815,
      ),
    );

    expect(controller.currentGameIsUnranked, isFalse);
    final record = controller.stats.existingRecordFor(GameMode.target);
    expect(record, isNotNull);
    expect(record!.highestTile, greaterThanOrEqualTo(2));
  });
}
