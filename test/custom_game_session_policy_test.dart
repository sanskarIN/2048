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
    'custom session persists without creating built-in mode records',
    () async {
      final controller = AppController(store: LocalStore());
      await controller.initialize();

      await controller.newGame(
        const GameConfig(
          mode: GameMode.target,
          size: 6,
          target: 8192,
          seed: 42,
        ),
        custom: true,
      );

      expect(controller.currentGameIsCustom, isTrue);
      expect(controller.currentGameIsUnranked, isFalse);
      expect(controller.stats.gamesPlayed, 1);
      expect(controller.stats.existingRecordFor(GameMode.target), isNull);

      final restored = AppController(store: LocalStore());
      await restored.initialize();

      expect(restored.currentGameIsCustom, isTrue);
      expect(restored.currentGameIsUnranked, isFalse);
      expect(restored.game?.config.size, 6);
      expect(restored.game?.config.target, 8192);
      expect(restored.stats.existingRecordFor(GameMode.target), isNull);
    },
  );

  test(
    'starting a built-in game clears custom identity and records mode data',
    () async {
      final controller = AppController(store: LocalStore());
      await controller.initialize();
      await controller.newGame(
        const GameConfig(mode: GameMode.target, size: 5, target: 4096),
        custom: true,
      );

      await controller.newGame(
        GameConfig.preset(GameMode.target, target: 4096),
      );

      expect(controller.currentGameIsCustom, isFalse);
      expect(controller.stats.gamesPlayed, 2);
      final record = controller.stats.existingRecordFor(GameMode.target);
      expect(record, isNotNull);
      expect(record!.highestTile, greaterThanOrEqualTo(2));
      expect(record.bestScoreBoardSize, anyOf(isNull, 4));
    },
  );

  test('malformed custom-session marker is repaired safely', () async {
    SharedPreferences.setMockInitialValues({
      'nova.current_game_custom.v1': 'invalid-bool',
    });
    final store = LocalStore();

    expect(await store.loadCurrentGameCustom(), isFalse);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.containsKey('nova.current_game_custom.v1'), isFalse);
  });
}
