import 'dart:io';

import 'package:nova_2048/domain/autoplay_session.dart';
import 'package:nova_2048/domain/solver_benchmark.dart';

const _defaultSeeds = <int>[2048, 4096, 8192, 20260815];
const _defaultMoveBudget = 200;

void main(List<String> args) {
  final moveBudget = args.isEmpty
      ? _defaultMoveBudget
      : int.tryParse(args.first) ?? _defaultMoveBudget;

  stdout.writeln('2048 Nova solver benchmark');
  stdout.writeln('Move budget per seed: $moveBudget');
  stdout.writeln('Seeds: ${_defaultSeeds.join(', ')}');
  stdout.writeln();

  for (final strategy in AutoplayStrategy.values) {
    final summary = SolverBenchmark.run(
      strategy: strategy,
      seeds: _defaultSeeds,
      moveBudget: moveBudget,
    );

    stdout.writeln('Strategy: ${strategy.name}');
    for (final result in summary.cases) {
      stdout.writeln(
        '  seed=${result.seed} '
        'score=${result.score} '
        'moves=${result.moves} '
        'highest=${result.highestTile} '
        'nodes=${result.exploredNodes}',
      );
    }
    stdout.writeln(
      '  averageScore=${summary.averageScore.toStringAsFixed(1)} '
      'averageMoves=${summary.averageMoves.toStringAsFixed(1)} '
      'peakTile=${summary.peakTile} '
      'averageDecisionNodes=${summary.averageDecisionNodes.toStringAsFixed(1)}',
    );
    stdout.writeln();
  }
}
