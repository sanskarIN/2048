import 'autoplay_session.dart';

class SolverBenchmarkCaseResult {
  const SolverBenchmarkCaseResult({
    required this.seed,
    required this.score,
    required this.moves,
    required this.highestTile,
    required this.exploredNodes,
  });

  final int seed;
  final int score;
  final int moves;
  final int highestTile;
  final int exploredNodes;
}

class SolverBenchmarkSummary {
  const SolverBenchmarkSummary({
    required this.strategy,
    required this.moveBudget,
    required this.cases,
  });

  final AutoplayStrategy strategy;
  final int moveBudget;
  final List<SolverBenchmarkCaseResult> cases;

  int get totalScore =>
      cases.fold(0, (total, result) => total + result.score);

  int get totalMoves =>
      cases.fold(0, (total, result) => total + result.moves);

  int get totalExploredNodes =>
      cases.fold(0, (total, result) => total + result.exploredNodes);

  int get peakTile => cases.fold(
        0,
        (highest, result) =>
            result.highestTile > highest ? result.highestTile : highest,
      );

  double get averageScore => cases.isEmpty ? 0 : totalScore / cases.length;

  double get averageMoves => cases.isEmpty ? 0 : totalMoves / cases.length;

  double get averageDecisionNodes =>
      totalMoves == 0 ? 0 : totalExploredNodes / totalMoves;
}

/// Reproducible benchmark runner for the isolated Auto Play strategies.
///
/// Benchmarks deliberately use seeded sandbox sessions. They do not read or
/// write player persistence and therefore cannot affect trusted app records.
class SolverBenchmark {
  const SolverBenchmark._();

  static SolverBenchmarkSummary run({
    required AutoplayStrategy strategy,
    required List<int> seeds,
    required int moveBudget,
  }) {
    if (seeds.isEmpty) {
      throw ArgumentError.value(seeds, 'seeds', 'Must not be empty.');
    }
    if (moveBudget <= 0) {
      throw ArgumentError.value(moveBudget, 'moveBudget', 'Must be positive.');
    }

    final results = <SolverBenchmarkCaseResult>[];
    for (final seed in seeds) {
      final session = AutoplaySession(seed: seed, strategy: strategy);
      var exploredNodes = 0;
      while (!session.isComplete && session.state.moves < moveBudget) {
        final changed = session.step();
        if (!changed) break;
        exploredNodes += session.lastDecisionNodes;
      }
      results.add(
        SolverBenchmarkCaseResult(
          seed: seed,
          score: session.state.score,
          moves: session.state.moves,
          highestTile: session.state.highestTile,
          exploredNodes: exploredNodes,
        ),
      );
    }

    return SolverBenchmarkSummary(
      strategy: strategy,
      moveBudget: moveBudget,
      cases: List<SolverBenchmarkCaseResult>.unmodifiable(results),
    );
  }
}
