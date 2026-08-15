import 'package:flutter_test/flutter_test.dart';
import 'package:nova_2048/app/state/app_controller.dart';
import 'package:nova_2048/data/local_store.dart';
import 'package:nova_2048/domain/game_types.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test(
    'undo after statistics reset cannot restore a historical best score',
    () async {
      final store = LocalStore();
      final controller = AppController(store: store);
      await controller.initialize();
      await controller.newGame(
        const GameConfig(mode: GameMode.classic, size: 4),
      );

      controller.stats.bestScore = 9999;
      controller.game!.bestScore = 9999;
      controller.game!.board
        ..[0] = [2, 2, 0, 0]
        ..[1] = [0, 0, 0, 0]
        ..[2] = [0, 0, 0, 0]
        ..[3] = [0, 0, 0, 0];

      await controller.move(Direction.left);
      expect(controller.canUndo, isTrue);
      expect(controller.game!.bestScore, 9999);

      await controller.resetStats();
      final resetBaseline = controller.game!.score;
      expect(controller.stats.bestScore, resetBaseline);
      expect(controller.game!.bestScore, resetBaseline);

      await controller.undo();

      expect(controller.game!.score, 0);
      expect(controller.game!.bestScore, resetBaseline);
      expect(controller.stats.bestScore, resetBaseline);

      controller.game!.board
        ..[0] = [2, 2, 0, 0]
        ..[1] = [0, 0, 0, 0]
        ..[2] = [0, 0, 0, 0]
        ..[3] = [0, 0, 0, 0];
      await controller.move(Direction.left);

      expect(controller.stats.bestScore, lessThan(9999));
      expect(controller.game!.bestScore, lessThan(9999));
    },
  );
}
