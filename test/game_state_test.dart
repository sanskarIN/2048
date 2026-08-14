import 'package:flutter_test/flutter_test.dart';
import 'package:nova_2048/domain/game_state.dart';
import 'package:nova_2048/domain/game_types.dart';

void main() {
  test('game state serializes and restores all integrity fields', () {
    final original = GameState(
      board: [
        [2, 4, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
      ],
      config: const GameConfig(mode: GameMode.classic, size: 4),
      score: 42,
      moves: 7,
      totalMerges: 3,
      rngState: 123456,
    );
    final restored = GameState.fromJson(original.toJson());
    expect(restored.board, original.board);
    expect(restored.score, 42);
    expect(restored.moves, 7);
    expect(restored.totalMerges, 3);
    expect(restored.rngState, 123456);
  });

  test('rejects invalid dimensions', () {
    expect(
      () => GameState.fromJson({
        'config': const GameConfig(
          mode: GameMode.classic,
          size: 4,
        ).toJson(),
        'board': [
          [2, 0],
        ],
      }),
      throwsFormatException,
    );
  });

  test('highest tile is derived from board state', () {
    final game = GameState(
      board: [
        [2, 4, 8, 16],
        [32, 64, 128, 256],
        [512, 1024, 2048, 4096],
        [0, 0, 0, 0],
      ],
      config: const GameConfig(mode: GameMode.endless, size: 4),
    );
    expect(game.highestTile, 4096);
  });
}
