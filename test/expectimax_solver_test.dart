import 'package:flutter_test/flutter_test.dart';
import 'package:nova_2048/domain/expectimax_solver.dart';
import 'package:nova_2048/domain/game_engine.dart';
import 'package:nova_2048/domain/game_state.dart';
import 'package:nova_2048/domain/game_types.dart';

void main() {
  test('expectimax recommendation is deterministic and legal', () {
    final board = [
      [2, 2, 4, 8],
      [16, 32, 64, 0],
      [0, 0, 0, 0],
      [0, 0, 0, 0],
    ];
    const solver = ExpectimaxSolver(size: 4, searchDepth: 2);

    final first = solver.recommend(board);
    final second = solver.recommend(board);

    expect(first.direction, isNotNull);
    expect(second.direction, first.direction);
    expect(second.expectedValue, first.expectedValue);
    expect(second.exploredNodes, first.exploredNodes);

    const config = GameConfig(
      mode: GameMode.endless,
      size: 4,
      target: 2048,
      seed: 17,
    );
    final state = GameState(
      board: [
        for (final row in board) [...row],
      ],
      config: config,
      rngState: 17,
    );
    final outcome = GameEngine(config: config).move(state, first.direction!);
    expect(outcome.changed, isTrue);
  });

  test('expectimax returns null when no legal move remains', () {
    final board = [
      [2, 4, 2, 4],
      [4, 2, 4, 2],
      [2, 4, 2, 4],
      [4, 2, 4, 2],
    ];

    final result = const ExpectimaxSolver(size: 4).recommend(board);

    expect(result.direction, isNull);
    expect(result.expectedValue.isFinite, isTrue);
  });

  test('expectimax evaluation never mutates its input board', () {
    final board = [
      [2, 0, 2, 0],
      [4, 8, 16, 32],
      [64, 128, 0, 0],
      [0, 0, 0, 0],
    ];
    final before = [
      for (final row in board) [...row],
    ];

    const ExpectimaxSolver(size: 4, searchDepth: 2).recommend(board);

    expect(board, before);
  });

  test('expectimax never exceeds its explicit node budget', () {
    final board = [
      [2, 2, 0, 0],
      [0, 0, 0, 0],
      [0, 0, 0, 0],
      [0, 0, 0, 0],
    ];

    final result = const ExpectimaxSolver(
      size: 4,
      searchDepth: 3,
      maxNodes: 8,
    ).recommend(board);

    expect(result.direction, isNotNull);
    expect(result.exploredNodes, lessThanOrEqualTo(8));
  });

  test('expectimax supports configured larger boards', () {
    final board = [
      [2, 2, 0, 0, 0],
      [4, 8, 16, 32, 0],
      [0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0],
    ];

    final result = const ExpectimaxSolver(
      size: 5,
      searchDepth: 1,
      maxNodes: 2000,
    ).recommend(board);

    expect(result.direction, isNotNull);
    expect(result.exploredNodes, greaterThan(0));
  });

  test('expectimax rejects malformed board dimensions', () {
    expect(
      () => const ExpectimaxSolver(size: 4).recommend([
        [2, 0],
        [0, 2],
      ]),
      throwsArgumentError,
    );
  });
}
