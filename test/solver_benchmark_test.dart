import 'package:flutter_test/flutter_test.dart';
import 'package:nova_2048/domain/autoplay_session.dart';
import 'package:nova_2048/domain/solver_benchmark.dart';

void main() {
  test('benchmark summaries are deterministic for fixed seeds', () {
    const seeds = [11, 22];

    final first = SolverBenchmark.run(
      strategy: AutoplayStrategy.expectimax,
      seeds: seeds,
      moveBudget: 8,
    );
    final second = SolverBenchmark.run(
      strategy: AutoplayStrategy.expectimax,
      seeds: seeds,
      moveBudget: 8,
    );

    expect(first.totalScore, second.totalScore);
    expect(first.totalMoves, second.totalMoves);
    expect(first.totalExploredNodes, second.totalExploredNodes);
    expect(first.peakTile, second.peakTile);
    expect(first.averageScore, second.averageScore);
    expect(first.cases.length, seeds.length);
    for (var i = 0; i < first.cases.length; i++) {
      expect(first.cases[i].seed, second.cases[i].seed);
      expect(first.cases[i].score, second.cases[i].score);
      expect(first.cases[i].moves, second.cases[i].moves);
      expect(first.cases[i].highestTile, second.cases[i].highestTile);
      expect(first.cases[i].exploredNodes, second.cases[i].exploredNodes);
    }
  });

  test('heuristic benchmark reports zero search-node work', () {
    final summary = SolverBenchmark.run(
      strategy: AutoplayStrategy.heuristic,
      seeds: const [2048],
      moveBudget: 12,
    );

    expect(summary.cases, hasLength(1));
    expect(summary.totalMoves, greaterThan(0));
    expect(summary.totalExploredNodes, 0);
    expect(summary.averageDecisionNodes, 0);
  });

  test('benchmark validates seeds and move budget', () {
    expect(
      () => SolverBenchmark.run(
        strategy: AutoplayStrategy.heuristic,
        seeds: const [],
        moveBudget: 5,
      ),
      throwsArgumentError,
    );
    expect(
      () => SolverBenchmark.run(
        strategy: AutoplayStrategy.heuristic,
        seeds: const [1],
        moveBudget: 0,
      ),
      throwsArgumentError,
    );
  });
}
