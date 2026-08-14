import 'package:flutter_test/flutter_test.dart';
import 'package:nova_2048/app/state/app_controller.dart';
import 'package:nova_2048/data/local_store.dart';
import 'package:nova_2048/domain/game_types.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('undo restores board state without lowering lifetime best score', () async {
    final controller = AppController(store: LocalStore());
    await controller.initialize();
    await controller.newGame(
      const GameConfig(mode: GameMode.classic, size: 4),
    );
    controller.game!.board
      ..[0] = [512, 512, 0, 0]
      ..[1] = [0, 0, 0, 0]
      ..[2] = [0, 0, 0, 0]
      ..[3] = [0, 0, 0, 0];

    await controller.move(Direction.left);
    expect(controller.stats.bestScore, 1024);
    expect(controller.game!.bestScore, 1024);

    await controller.undo();

    expect(controller.game!.score, 0);
    expect(controller.game!.bestScore, 1024);
    expect(controller.stats.bestScore, 1024);
  });
}
