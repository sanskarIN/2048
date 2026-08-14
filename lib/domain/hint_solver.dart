import 'dart:math' as math;

import 'game_types.dart';

class HintSolver {
  const HintSolver({required this.size});

  final int size;

  Direction? recommend(List<List<int>> board) {
    Direction? bestDirection;
    var bestScore = double.negativeInfinity;

    for (final direction in Direction.values) {
      final simulation = _simulate(board, direction);
      if (!simulation.changed) continue;
      final score = _evaluate(simulation.board, simulation.mergeScore) +
          _directionBias(direction);
      if (score > bestScore) {
        bestScore = score;
        bestDirection = direction;
      }
    }
    return bestDirection;
  }

  _Simulation _simulate(List<List<int>> board, Direction direction) {
    final next = [
      for (final row in board) [...row],
    ];
    var mergeScore = 0;
    var changed = false;

    for (var index = 0; index < size; index++) {
      final original = _readLine(board, index, direction);
      final collapsed = _collapse(original);
      mergeScore += collapsed.mergeScore;
      if (!_sameLine(original, collapsed.values)) changed = true;
      _writeLine(next, index, direction, collapsed.values);
    }

    return _Simulation(next, changed, mergeScore);
  }

  double _evaluate(List<List<int>> board, int mergeScore) {
    var emptyCells = 0;
    var smoothnessPenalty = 0.0;
    var monotonicity = 0.0;
    var highest = 0;
    var highestRow = 0;
    var highestCol = 0;

    for (var row = 0; row < size; row++) {
      for (var col = 0; col < size; col++) {
        final value = board[row][col];
        if (value == 0) {
          emptyCells += 1;
          continue;
        }
        if (value > highest) {
          highest = value;
          highestRow = row;
          highestCol = col;
        }
        final exponent = _exponent(value);
        if (col + 1 < size && board[row][col + 1] != 0) {
          smoothnessPenalty +=
              (exponent - _exponent(board[row][col + 1])).abs();
        }
        if (row + 1 < size && board[row + 1][col] != 0) {
          smoothnessPenalty +=
              (exponent - _exponent(board[row + 1][col])).abs();
        }
      }
    }

    for (var row = 0; row < size; row++) {
      monotonicity += _lineMonotonicity(board[row]);
    }
    for (var col = 0; col < size; col++) {
      monotonicity += _lineMonotonicity([
        for (var row = 0; row < size; row++) board[row][col],
      ]);
    }

    final inCorner = highest > 0 &&
        (highestRow == 0 || highestRow == size - 1) &&
        (highestCol == 0 || highestCol == size - 1);
    final cornerReward = inCorner ? _exponent(highest) * 120.0 : 0.0;

    return emptyCells * 1000.0 +
        mergeScore * 3.0 +
        monotonicity * 20.0 +
        cornerReward -
        smoothnessPenalty * 12.0;
  }

  double _lineMonotonicity(List<int> line) {
    var increasing = 0.0;
    var decreasing = 0.0;
    for (var i = 0; i + 1 < line.length; i++) {
      final a = line[i] == 0 ? 0.0 : _exponent(line[i]);
      final b = line[i + 1] == 0 ? 0.0 : _exponent(line[i + 1]);
      if (a > b) {
        decreasing += a - b;
      } else {
        increasing += b - a;
      }
    }
    return math.max(increasing, decreasing);
  }

  double _directionBias(Direction direction) => switch (direction) {
        Direction.down => 0.04,
        Direction.left => 0.03,
        Direction.right => 0.02,
        Direction.up => 0.01,
      };

  double _exponent(int value) => math.log(value) / math.ln2;

  _CollapsedLine _collapse(List<int> values) {
    final nonZero = values.where((value) => value != 0).toList();
    final output = <int>[];
    var mergeScore = 0;
    for (var i = 0; i < nonZero.length; i++) {
      if (i + 1 < nonZero.length && nonZero[i] == nonZero[i + 1]) {
        final merged = nonZero[i] * 2;
        output.add(merged);
        mergeScore += merged;
        i += 1;
      } else {
        output.add(nonZero[i]);
      }
    }
    while (output.length < size) {
      output.add(0);
    }
    return _CollapsedLine(output, mergeScore);
  }

  List<int> _readLine(
    List<List<int>> board,
    int index,
    Direction direction,
  ) {
    return switch (direction) {
      Direction.left => [...board[index]],
      Direction.right => board[index].reversed.toList(),
      Direction.up => [
          for (var row = 0; row < size; row++) board[row][index],
        ],
      Direction.down => [
          for (var row = size - 1; row >= 0; row--) board[row][index],
        ],
    };
  }

  void _writeLine(
    List<List<int>> board,
    int index,
    Direction direction,
    List<int> values,
  ) {
    switch (direction) {
      case Direction.left:
        board[index] = [...values];
      case Direction.right:
        board[index] = values.reversed.toList();
      case Direction.up:
        for (var row = 0; row < size; row++) {
          board[row][index] = values[row];
        }
      case Direction.down:
        for (var row = 0; row < size; row++) {
          board[size - 1 - row][index] = values[row];
        }
    }
  }

  bool _sameLine(List<int> a, List<int> b) {
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

class _Simulation {
  const _Simulation(this.board, this.changed, this.mergeScore);

  final List<List<int>> board;
  final bool changed;
  final int mergeScore;
}

class _CollapsedLine {
  const _CollapsedLine(this.values, this.mergeScore);

  final List<int> values;
  final int mergeScore;
}
