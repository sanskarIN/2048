import 'package:nova_2048/domain/autoplay_session.dart';

const _defaultSeeds = <int>[2048, 4096, 8192, 20260815];
const _defaultMoveBudget = 200;

void main(List<String> args) {
  final moveBudget = args.isEmpty
      ? _defaultMoveBudget
      : int.tryParse(args.first) ?? _defaultMoveBudget;
  if (moveBudget <= 0) {
    throw ArgumentError.value(moveBudget, 'moveBudget', 'Must be positive.');
  }

  print('2048 Nova solver benchmark');
  print('Move budget per seed: $moveBudget');
  print('Seeds: ${_defaultSeeds.join(', ')}');
  print('');

  for (final strategy in AutoplayStrategy.values) {
    var totalScore = 0;
    var highestTile = 0;
    var totalMoves = 0;
    var totalNodes = 0;

    print('Strategy: ${strategy.name}');
    for (final seed in _defaultSeeds) {
      final session = AutoplaySession(seed: seed, strategy: strategy);
      while (!session.isComplete && session.state.moves < moveBudget) {
        final changed = session.step();
        if (!changed) break;
        totalNodes += session.lastDecisionNodes;
      }

      totalScore += session.state.score;
      totalMoves += session.state.moves;
      if (session.state.highestTile > highestTile) {
        highestTile = session.state.highestTile;
      }

      print(
        '  seed=$seed '
        'score=${session.state.score} '
        'moves=${session.state.moves} '
        'highest=${session.state.highestTile}',
      );
    }

    final averageScore = totalScore / _defaultSeeds.length;
    final averageMoves = totalMoves / _defaultSeeds.length;
    final averageNodes = totalMoves == 0 ? 0.0 : totalNodes / totalMoves;
    print(
      '  averageScore=${averageScore.toStringAsFixed(1)} '
      'averageMoves=${averageMoves.toStringAsFixed(1)} '
      'peakTile=$highestTile '
      'averageDecisionNodes=${averageNodes.toStringAsFixed(1)}',
    );
    print('');
  }
}
