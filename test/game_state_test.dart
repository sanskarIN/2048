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

  test('rejects unsupported future save schemas', () {
    expect(
      () => GameState.fromJson({
        'schema': GameState.schemaVersion + 1,
        'config': const GameConfig(
          mode: GameMode.classic,
          size: 4,
        ).toJson(),
        'board': List.generate(4, (_) => List.filled(4, 0)),
      }),
      throwsFormatException,
    );
  });

  test('migrates legacy schema zero top-level configuration', () {
    final restored = GameState.fromJson({
      'schema': 0,
      'mode': GameMode.classic.name,
      'size': 4,
      'target': 2048,
      'board': [
        [2, 4, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
      ],
      'score': 20,
      'moves': 3,
    });

    expect(restored.config.mode, GameMode.classic);
    expect(restored.config.size, 4);
    expect(restored.score, 20);
    expect(restored.moves, 3);
  });

  test('rejects invalid tile values and unsafe configuration bounds', () {
    expect(
      () => GameState.fromJson({
        'schema': GameState.schemaVersion,
        'config': const GameConfig(
          mode: GameMode.classic,
          size: 4,
        ).toJson(),
        'board': [
          [3, 0, 0, 0],
          [0, 0, 0, 0],
          [0, 0, 0, 0],
          [0, 0, 0, 0],
        ],
      }),
      throwsFormatException,
    );

    expect(
      () => GameState.fromJson({
        'schema': GameState.schemaVersion,
        'config': {
          'mode': GameMode.classic.name,
          'size': 1000,
          'target': 2048,
        },
        'board': const [],
      }),
      throwsFormatException,
    );
  });

  test('requires a valid start time for persisted timed challenges', () {
    expect(
      () => GameState.fromJson({
        'schema': GameState.schemaVersion,
        'config': const GameConfig(
          mode: GameMode.timeChallenge,
          size: 4,
          timeLimitSeconds: 180,
        ).toJson(),
        'board': [
          [2, 0, 0, 0],
          [0, 0, 0, 0],
          [0, 0, 0, 0],
          [0, 0, 0, 0],
        ],
        'startedAt': 'not-a-date',
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
