import 'dart:math' as math;

import 'game_types.dart';

/// Result of one bounded expectimax recommendation.
class ExpectimaxResult {
  const ExpectimaxResult({
    required this.direction,
    required this.expectedValue,
    required this.exploredNodes,
  });

  final Direction? direction;
  final double expectedValue;
  final int exploredNodes;
}

/// Deterministic expectimax search used only by the isolated Auto Play Demo.
///
/// Player nodes choose the highest-value legal move. Chance nodes enumerate
/// every empty-cell spawn for both supported tile probabilities (90% tile 2,
/// 10% tile 4). Search depth and explored nodes are bounded so the solver can
/// remain responsive on larger boards and on slower devices.
///
/// This class never mutates the supplied board and never consumes the live
/// game's RNG. It is deliberately separate from [GameEngine.hint], which keeps
/// the fast deterministic heuristic used by normal gameplay.
class ExpectimaxSolver {
  const ExpectimaxSolver({
    required this.size,
    this.searchDepth = 2,
    this.maxNodes = 50000,
  })  : assert(searchDepth >= 1),
        assert(maxNodes >= 1);

  final int size;
  final int searchDepth;
  final int maxNodes;

  ExpectimaxResult recommend(List<List<int>> board) {
    _validateBoard(board);
    final context = _SearchContext(maxNodes);
    Direction? bestDirection;
    var bestValue = double.negativeInfinity;

    for (final direction in Direction.values) {
      final simulation = _simulate(board, direction);
      if (!simulation.changed) continue;

      final value = simulation.mergeScore * 3.0 +
          _chanceValue(simulation.board, searchDepth - 1, context) +
          _directionBias(direction);
      if (value > bestValue) {
        bestValue = value;
        bestDirection = direction;
      }
    }

    if (bestDirection == null) {
      return ExpectimaxResult(
        direction: null,
        expectedValue: _evaluate(board),
        exploredNodes: context.exploredNodes,
      );
    }

    return ExpectimaxResult(
      direction: bestDirection,
      expectedValue: bestValue,
      exploredNodes: context.exploredNodes,
    );
  }

  double _chanceValue(
    List<List<int>> board,
    int depth,
    _SearchContext context,
  ) {
    if (!context.enterNode()) return _evaluate(board);
    if (depth < 0) return _evaluate(board);

    final empties = <(int, int)>[];
    for (var row = 0; row < size; row++) {
      for (var col = 0; col < size; col++) {
        if (board[row][col] == 0) empties.add((row, col));
      }
    }

    if (empties.isEmpty) {
      return _playerValue(board, depth, context);
    }

    var expected = 0.0;
    final locationWeight = 1.0 / empties.length;
    for (final cell in empties) {
      if (context.isExhausted) return _evaluate(board);

      final withTwo = _copyBoard(board);
      withTwo[cell.$1][cell.$2] = 2;
      expected += locationWeight * 0.9 * _playerValue(withTwo, depth, context);

      if (context.isExhausted) return _evaluate(board);

      final withFour = _copyBoard(board);
      withFour[cell.$1][cell.$2] = 4;
      expected += locationWeight * 0.1 * _playerValue(withFour, depth, context);
    }
    return expected;
  }

  double _playerValue(
    List<List<int>> board,
    int depth,
    _SearchContext context,
  ) {
    if (!context.enterNode()) return _evaluate(board);
    if (depth <= 0) return _evaluate(board);

    var best = double.negativeInfinity;
    var foundMove = false;
    for (final direction in Direction.values) {
      final simulation = _simulate(board, direction);
      if (!simulation.changed) continue;
      foundMove = true;

      final value = simulation.mergeScore * 3.0 +
          _chanceValue(simulation.board, depth - 1, context) +
          _directionBias(direction);
      if (value > best) best = value;
      if (context.isExhausted) break;
    }

    if (!foundMove) {
      return _evaluate(board) - 100000.0;
    }
    return best;
  }

  _Simulation _simulate(List<List<int>> board, Direction direction) {
    final next = _copyBoard(board);
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

  double _evaluate(List<List<int>> board) {
    var emptyCells = 0;
    var smoothnessPenalty = 0.0;
    var monotonicity = 0.0;
    var highest = 0;
    var highestRow = 0;
    var highestCol = 0;
    var sumExponents = 0.0;

    for (var row = 0; row < size; row++) {
      for (var col = 0; col < size; col++) {
        final value = board[row][col];
        if (value == 0) {
          emptyCells += 1;
          continue;
        }

        final exponent = _exponent(value);
        sumExponents += exponent;
        if (value > highest) {
          highest = value;
          highestRow = row;
          highestCol = col;
        }
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
    final cornerReward = inCorner ? _exponent(highest) * 140.0 : 0.0;

    return emptyCells * 1100.0 +
        monotonicity * 24.0 +
        cornerReward +
        sumExponents * 2.0 -
        smoothnessPenalty * 14.0;
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
    return -math.min(increasing, decreasing);
  }

  double _directionBias(Direction direction) => switch (direction) {
        Direction.down => 0.004,
        Direction.left => 0.003,
        Direction.right => 0.002,
        Direction.up => 0.001,
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

  List<int> _readLine(List<List<int>> board, int index, Direction direction) {
    return switch (direction) {
      Direction.left => [...board[index]],
      Direction.right => board[index].reversed.toList(),
      Direction.up => [for (var row = 0; row < size; row++) board[row][index]],
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
        break;
      case Direction.right:
        board[index] = values.reversed.toList();
        break;
      case Direction.up:
        for (var row = 0; row < size; row++) {
          board[row][index] = values[row];
        }
        break;
      case Direction.down:
        for (var row = 0; row < size; row++) {
          board[size - 1 - row][index] = values[row];
        }
        break;
    }
  }

  bool _sameLine(List<int> a, List<int> b) {
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  List<List<int>> _copyBoard(List<List<int>> board) => [
        for (final row in board) [...row],
      ];

  void _validateBoard(List<List<int>> board) {
    if (size < 2 || board.length != size) {
      throw ArgumentError('Board dimensions do not match solver size.');
    }
    for (final row in board) {
      if (row.length != size) {
        throw ArgumentError('Board dimensions do not match solver size.');
      }
      for (final value in row) {
        if (value < 0 ||
            (value != 0 && (value < 2 || (value & (value - 1)) != 0))) {
          throw ArgumentError('Board contains an invalid tile value.');
        }
      }
    }
  }
}

class _SearchContext {
  _SearchContext(this.maxNodes);

  final int maxNodes;
  int exploredNodes = 0;

  bool get isExhausted => exploredNodes >= maxNodes;

  bool enterNode() {
    if (isExhausted) return false;
    exploredNodes += 1;
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
