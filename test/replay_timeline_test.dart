import 'package:flutter_test/flutter_test.dart';
import 'package:nova_2048/domain/game_state.dart';
import 'package:nova_2048/domain/game_types.dart';
import 'package:nova_2048/domain/replay_timeline.dart';

void main() {
  const config = GameConfig(mode: GameMode.classic, size: 4);
  final startedAt = DateTime.utc(2026, 8, 14, 7);

  GameState state({
    required int moves,
    required int score,
    int merges = 0,
    DateTime? started,
    List<List<int>>? board,
  }) {
    return GameState(
      config: config,
      board: board ??
          [
            [2 << moves.clamp(0, 4), 0, 0, 0],
            [0, 0, 0, 0],
            [0, 0, 0, 0],
            [0, 0, 0, 0],
          ],
      moves: moves,
      score: score,
      bestScore: score,
      totalMerges: merges,
      rngState: moves + 10,
      startedAt: started ?? startedAt,
    );
  }

  test('build keeps only active-session non-future frames in move order', () {
    final current = state(moves: 3, score: 12, merges: 2);
    final stale = state(
      moves: 1,
      score: 4,
      merges: 1,
      started: startedAt.add(const Duration(minutes: 1)),
    );
    final future = state(moves: 4, score: 20, merges: 3);

    final frames = ReplayTimeline.build(
      current: current,
      history: [
        state(moves: 2, score: 8, merges: 1),
        stale,
        state(moves: 0, score: 0),
        future,
        state(moves: 1, score: 4, merges: 1),
      ],
    );

    expect(frames.map((frame) => frame.moves), [0, 1, 2, 3]);
    expect(frames.last.score, 12);
  });

  test('duplicate move snapshots collapse and current frame is authoritative', () {
    final current = state(
      moves: 2,
      score: 8,
      merges: 1,
      board: [
        [4, 4, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
      ],
    );

    final frames = ReplayTimeline.build(
      current: current,
      history: [
        state(moves: 0, score: 0),
        state(moves: 1, score: 4, merges: 1),
        current.copy(),
      ],
    );

    expect(frames.map((frame) => frame.moves), [0, 1, 2]);
    expect(frames.last.board, current.board);
  });

  test('returned frames are defensive copies', () {
    final first = state(moves: 0, score: 0);
    final current = state(moves: 1, score: 4, merges: 1);

    final frames = ReplayTimeline.build(current: current, history: [first]);
    first.board[0][0] = 1024;
    current.board[0][0] = 2048;

    expect(frames.first.board[0][0], 2);
    expect(frames.last.board[0][0], 4);
    expect(() => frames.add(current), throwsUnsupportedError);
  });
}
