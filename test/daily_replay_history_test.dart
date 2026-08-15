import 'package:flutter_test/flutter_test.dart';
import 'package:nova_2048/domain/daily_record.dart';
import 'package:nova_2048/domain/game_state.dart';
import 'package:nova_2048/domain/game_types.dart';

void main() {
  const config = GameConfig(
    mode: GameMode.daily,
    size: 4,
    target: 2048,
    seed: 20260814,
  );

  GameState state({
    required int score,
    required int highest,
    required int moves,
  }) {
    return GameState(
      board: [
        [highest, 0, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
      ],
      config: config,
      score: score,
      moves: moves,
    );
  }

  test('lower-scoring replay preserves best score and its move count', () {
    final previous = DailyRecord.fromState(
      state(score: 4096, highest: 1024, moves: 180),
    );
    final replay = DailyRecord.fromState(
      state(score: 128, highest: 64, moves: 15),
      previous: previous,
    );

    expect(replay.score, 4096);
    expect(replay.moves, 180);
    expect(replay.highestTile, 1024);
  });

  test('better replay replaces best score metrics and keeps peak tile', () {
    final previous = DailyRecord.fromState(
      state(score: 2048, highest: 1024, moves: 160),
    );
    final replay = DailyRecord.fromState(
      state(score: 5000, highest: 512, moves: 140),
      previous: previous,
    );

    expect(replay.score, 5000);
    expect(replay.moves, 140);
    expect(replay.highestTile, 1024);
  });
}
