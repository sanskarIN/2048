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

  GameState state({int highest = 2, GameStatus status = GameStatus.playing}) {
    return GameState(
      board: [
        [highest, 0, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
      ],
      config: config,
      status: status,
      score: highest,
      moves: 10,
    );
  }

  test('marks an active daily challenge as in progress', () {
    final record = DailyRecord.fromState(state());
    expect(record.seed, 20260814);
    expect(record.completed, isFalse);
    expect(record.won, isFalse);
  });

  test('marks target completion as a win', () {
    final record = DailyRecord.fromState(state(highest: 2048));
    expect(record.completed, isTrue);
    expect(record.won, isTrue);
  });

  test('preserves a previous win after continuing beyond target', () {
    final won = DailyRecord.fromState(state(highest: 2048));
    final continued = DailyRecord.fromState(
      state(highest: 1024),
      previous: won,
    );
    expect(continued.completed, isTrue);
    expect(continued.won, isTrue);
  });

  test('serializes and restores a daily record', () {
    final original = DailyRecord.fromState(state(highest: 512));
    final restored = DailyRecord.fromJson(original.toJson());
    expect(restored.seed, original.seed);
    expect(restored.score, original.score);
    expect(restored.highestTile, original.highestTile);
  });
}
