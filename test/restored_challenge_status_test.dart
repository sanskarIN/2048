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

  test('expired timed game is reconciled before the UI can resume it',
      () async {
    const config = GameConfig(
      mode: GameMode.timeChallenge,
      size: 4,
      timeLimitSeconds: 1,
    );
    final store = LocalStore();
    await store.saveGame(
      GameState(
        board: const [
          [2, 0, 0, 0],
          [0, 0, 0, 0],
          [0, 0, 0, 0],
          [0, 0, 0, 0],
        ],
        config: config,
        startedAt: DateTime.now().subtract(const Duration(minutes: 1)),
      ),
    );
    await store.saveStats({
      'gamesPlayed': 1,
      'gamesWon': 0,
      'currentStreak': 4,
      'bestStreak': 4,
    });

    final controller = AppController(store: store);
    await controller.initialize();

    expect(controller.game!.status, GameStatus.lost);
    expect(controller.stats.currentStreak, 0);
    expect((await store.loadGame())!.status, GameStatus.lost);
  });
}
