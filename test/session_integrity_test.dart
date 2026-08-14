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

  test('restored win remains accounted after continue and later loss', () async {
    const config = GameConfig(mode: GameMode.classic, size: 4);
    final store = LocalStore();
    final wonGame = GameState(
      board: [
        [2048, 2, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
      ],
      config: config,
      score: 2048,
      status: GameStatus.won,
      startedAt: DateTime.utc(2026, 8, 14, 5),
    );
    await store.saveGame(wonGame);
    await store.saveStats({
      'gamesPlayed': 1,
      'gamesWon': 1,
      'bestScore': 2048,
      'highestTile': 2048,
      'totalMoves': 1,
      'totalMerges': 1,
      'currentStreak': 1,
      'bestStreak': 1,
    });

    final controller = AppController(store: store);
    await controller.initialize();
    expect(controller.game!.status, GameStatus.won);

    await controller.continueAfterWin();
    controller.game!.board
      ..[0] = [2048, 4, 8, 16]
      ..[1] = [32, 64, 128, 256]
      ..[2] = [512, 1024, 4, 8]
      ..[3] = [0, 16, 32, 64];

    await controller.move(Direction.left);

    expect(controller.game!.status, GameStatus.lost);
    expect(controller.stats.gamesWon, 1);
    expect(controller.stats.currentStreak, 1);
  });
}
