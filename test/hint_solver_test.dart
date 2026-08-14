import 'package:flutter_test/flutter_test.dart';
import 'package:nova_2048/domain/game_types.dart';
import 'package:nova_2048/domain/hint_solver.dart';

void main() {
  test('returns null when no legal board-changing direction exists', () {
    const solver = HintSolver(size: 4);
    final direction = solver.recommend(const [
      [2, 4, 2, 4],
      [4, 2, 4, 2],
      [2, 4, 2, 4],
      [4, 2, 4, 2],
    ]);

    expect(direction, isNull);
  });

  test('prefers a merge that keeps the highest tile in a corner', () {
    const solver = HintSolver(size: 4);
    final direction = solver.recommend(const [
      [8, 4, 2, 2],
      [0, 0, 0, 0],
      [0, 0, 0, 0],
      [0, 0, 0, 0],
    ]);

    expect(direction, Direction.left);
  });

  test('does not mutate the board while evaluating hints', () {
    const solver = HintSolver(size: 4);
    final board = [
      [0, 2, 0, 0],
      [0, 0, 0, 0],
      [0, 0, 0, 0],
      [0, 0, 0, 0],
    ];
    final before = [
      for (final row in board) [...row],
    ];

    expect(solver.recommend(board), isNotNull);
    expect(board, before);
  });

  test('supports larger configured board sizes', () {
    const solver = HintSolver(size: 6);
    final direction = solver.recommend(const [
      [0, 2, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0],
    ]);

    expect(direction, isNotNull);
  });
}
