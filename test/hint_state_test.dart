import 'package:flutter_test/flutter_test.dart';
import 'package:nova_2048/domain/game_engine.dart';
import 'package:nova_2048/domain/game_state.dart';
import 'package:nova_2048/domain/game_types.dart';

void main() {
  const config = GameConfig(mode: GameMode.classic, size: 4);

  test('won and lost games do not expose gameplay hints', () {
    final engine = GameEngine(config: config);
    final won = GameState(
      board: const [
        [2048, 2, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
      ],
      config: config,
      status: GameStatus.won,
    );
    final lost = GameState(
      board: const [
        [2, 4, 2, 4],
        [4, 2, 4, 2],
        [2, 4, 2, 4],
        [4, 2, 4, 2],
      ],
      config: config,
      status: GameStatus.lost,
    );

    expect(engine.hint(won), isNull);
    expect(engine.hint(lost), isNull);
  });
}
