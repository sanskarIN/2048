import 'game_state.dart';

/// Builds a read-only replay timeline from the persisted Undo snapshots that
/// already belong to the active game session.
///
/// Replay intentionally reuses existing bounded history instead of introducing
/// another persistence format. Returned frames are defensive copies, so a
/// spectator/replay UI cannot mutate the live game or the stored Undo objects.
class ReplayTimeline {
  const ReplayTimeline._();

  static List<GameState> build({
    required GameState current,
    required Iterable<GameState> history,
  }) {
    final byMove = <int, GameState>{};

    for (final snapshot in history) {
      if (!_belongsToSession(snapshot, current)) continue;
      if (snapshot.moves > current.moves ||
          snapshot.totalMerges > current.totalMerges ||
          snapshot.score > current.score) {
        continue;
      }
      byMove[snapshot.moves] = snapshot.copy();
    }

    final retainedMoves = byMove.keys.toList()..sort();
    final frames = <GameState>[
      for (final move in retainedMoves) byMove[move]!,
    ];

    if (frames.isEmpty || !_sameFrame(frames.last, current)) {
      frames.add(current.copy());
    } else {
      frames[frames.length - 1] = current.copy();
    }

    return List<GameState>.unmodifiable(frames);
  }

  static bool _belongsToSession(GameState candidate, GameState current) {
    final a = candidate.config;
    final b = current.config;
    return candidate.startedAt.isAtSameMomentAs(current.startedAt) &&
        a.mode == b.mode &&
        a.size == b.size &&
        a.target == b.target &&
        a.moveLimit == b.moveLimit &&
        a.timeLimitSeconds == b.timeLimitSeconds &&
        a.seed == b.seed;
  }

  static bool _sameFrame(GameState a, GameState b) {
    if (a.moves != b.moves ||
        a.score != b.score ||
        a.totalMerges != b.totalMerges ||
        a.status != b.status ||
        a.hasAcknowledgedWin != b.hasAcknowledgedWin ||
        a.rngState != b.rngState) {
      return false;
    }
    if (a.board.length != b.board.length) return false;
    for (var row = 0; row < a.board.length; row++) {
      final left = a.board[row];
      final right = b.board[row];
      if (left.length != right.length) return false;
      for (var col = 0; col < left.length; col++) {
        if (left[col] != right[col]) return false;
      }
    }
    return true;
  }
}
