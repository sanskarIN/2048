import 'game_state.dart';
import 'game_types.dart';
import 'random_source.dart';

class MoveOutcome {
  const MoveOutcome({
    required this.changed,
    required this.scoreGain,
    required this.merges,
  });

  final bool changed;
  final int scoreGain;
  final int merges;
}

class GameEngine {
  GameEngine({required this.config, RandomSource? random})
      : random = random ??
            SeededRandomSource(
              config.seed ?? DateTime.now().microsecondsSinceEpoch,
            );

  final GameConfig config;
  final RandomSource random;

  GameState createGame({int bestScore = 0}) {
    final board = List.generate(
      config.size,
      (_) => List.filled(config.size, 0),
    );
    final state = GameState(
      board: board,
      config: config,
      bestScore: bestScore,
      rngState: random.state,
    );
    spawnTile(state);
    spawnTile(state);
    return state;
  }

  MoveOutcome move(GameState state, Direction direction) {
    refreshStatus(state);
    if (state.status != GameStatus.playing) {
      return const MoveOutcome(changed: false, scoreGain: 0, merges: 0);
    }

    final before = _signature(state.board);
    var scoreGain = 0;
    var mergeCount = 0;

    for (var index = 0; index < config.size; index++) {
      final original = _readLine(state.board, index, direction);
      final result = _collapse(original);
      scoreGain += result.scoreGain;
      mergeCount += result.merges;
      _writeLine(state.board, index, direction, result.values);
    }

    final changed = before != _signature(state.board);
    if (!changed) {
      refreshStatus(state);
      return const MoveOutcome(changed: false, scoreGain: 0, merges: 0);
    }

    state.score += scoreGain;
    if (state.score > state.bestScore) state.bestScore = state.score;
    state.moves += 1;
    state.totalMerges += mergeCount;
    spawnTile(state);
    refreshStatus(state);
    return MoveOutcome(
      changed: true,
      scoreGain: scoreGain,
      merges: mergeCount,
    );
  }

  void spawnTile(GameState state) {
    final empties = <(int, int)>[];
    for (var row = 0; row < config.size; row++) {
      for (var col = 0; col < config.size; col++) {
        if (state.board[row][col] == 0) empties.add((row, col));
      }
    }
    if (empties.isEmpty) return;
    random.state = state.rngState;
    final chosen = empties[random.nextInt(empties.length)];
    state.board[chosen.$1][chosen.$2] = random.nextDouble() < 0.9 ? 2 : 4;
    state.rngState = random.state;
  }

  bool canMove(GameState state) {
    for (final row in state.board) {
      if (row.contains(0)) return true;
    }
    for (var row = 0; row < config.size; row++) {
      for (var col = 0; col < config.size; col++) {
        final value = state.board[row][col];
        if (row + 1 < config.size && state.board[row + 1][col] == value) {
          return true;
        }
        if (col + 1 < config.size && state.board[row][col + 1] == value) {
          return true;
        }
      }
    }
    return false;
  }

  Direction? hint(GameState state) {
    if (state.status != GameStatus.playing) return null;
    const preference = [
      Direction.left,
      Direction.down,
      Direction.right,
      Direction.up,
    ];
    for (final direction in preference) {
      final clone = state.copy();
      final before = _signature(clone.board);
      for (var i = 0; i < config.size; i++) {
        final result = _collapse(_readLine(clone.board, i, direction));
        _writeLine(clone.board, i, direction, result.values);
      }
      if (before != _signature(clone.board)) return direction;
    }
    return null;
  }

  void refreshStatus(GameState state, {DateTime? now}) {
    final reachedTarget = state.highestTile >= config.target;
    final isEndless =
        config.mode == GameMode.endless || config.mode == GameMode.zen;

    if (reachedTarget && !isEndless && !state.hasAcknowledgedWin) {
      state.status = GameStatus.won;
      return;
    }

    final moveLimit = config.moveLimit;
    if (moveLimit != null && state.moves >= moveLimit && !reachedTarget) {
      state.status = GameStatus.lost;
      return;
    }

    final timeLimit = config.timeLimitSeconds;
    if (timeLimit != null) {
      final elapsed =
          (now ?? DateTime.now()).difference(state.startedAt).inSeconds;
      if (elapsed >= timeLimit && !reachedTarget) {
        state.status = GameStatus.lost;
        return;
      }
    }

    if (!canMove(state)) {
      state.status = GameStatus.lost;
      return;
    }

    if (state.status != GameStatus.won || state.hasAcknowledgedWin) {
      state.status = GameStatus.playing;
    }
  }

  _LineResult _collapse(List<int> values) {
    final nonZero = values.where((value) => value != 0).toList();
    final output = <int>[];
    var scoreGain = 0;
    var merges = 0;
    for (var i = 0; i < nonZero.length; i++) {
      if (i + 1 < nonZero.length && nonZero[i] == nonZero[i + 1]) {
        final merged = nonZero[i] * 2;
        output.add(merged);
        scoreGain += merged;
        merges += 1;
        i += 1;
      } else {
        output.add(nonZero[i]);
      }
    }
    while (output.length < config.size) {
      output.add(0);
    }
    return _LineResult(output, scoreGain, merges);
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
          for (var row = 0; row < config.size; row++) board[row][index],
        ],
      Direction.down => [
          for (var row = config.size - 1; row >= 0; row--) board[row][index],
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
        for (var row = 0; row < config.size; row++) {
          board[row][index] = values[row];
        }
        break;
      case Direction.down:
        for (var row = 0; row < config.size; row++) {
          board[config.size - 1 - row][index] = values[row];
        }
        break;
    }
  }

  String _signature(List<List<int>> board) =>
      board.map((row) => row.join(',')).join('|');
}

class _LineResult {
  const _LineResult(this.values, this.scoreGain, this.merges);

  final List<int> values;
  final int scoreGain;
  final int merges;
}
