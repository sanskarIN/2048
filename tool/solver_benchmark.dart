import 'package:nova_2048/domain/autoplay_session.dart';
import 'package:nova_2048/domain/solver_benchmark.dart';

const _defaultSeeds = <int>[2048, 4096, 8192, 20260815];
const _defaultMoveBudget = 200;

void main(List<String> args) {
  final moveBudget = args.isEmpty
      ? _defaultMoveBudget
      : int.tryParse(args.first) ?? _defaultMoveBudget;

  print('2048 Nova solver benchmark');
  print('Move budget per seed: $moveBudget');
  print('Seeds: ${_defaultSeeds.join(', ')}');
  print('');

  for (final strategy in AutoplayStrategy.values) {
    final summary = SolverBenchmark.run(
      strategy: strategy,
      seeds: _defaultSeeds,
      moveBudget: moveBudget,
    );

    print('Strategy: ${strategy.name}');
    for (final result in summary.cases) {
      print(
        '  seed=${result.seed} '
        'score=${result.score} '
        'moves=${result.moves} '
        'highest=${result.highestTile} '
        'nodes=${result.exploredNodes}',
      );
    }
    print(
      '  averageScore=${summary.averageScore.toStringAsFixed(1)} '
      'averageMoves=${summary.averageMoves.toStringAsFixed(1)} '
      'peakTile=${summary.peakTile} '
      'averageDecisionNodes=${summary.averageDecisionNodes.toStringAsFixed(1)}',
    );
    print('');
  }
}
