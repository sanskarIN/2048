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
    expect(restored.updatedAt.isUtc, isTrue);
  });

  test('rejects impossible and wrongly typed daily seeds', () {
    expect(
      () => DailyRecord.fromJson({'seed': 20260230}),
      throwsFormatException,
    );
    expect(
      () => DailyRecord.fromJson({'seed': '20260814'}),
      throwsFormatException,
    );
  });

  test('rejects invalid counters and highest tiles', () {
    expect(
      () => DailyRecord.fromJson({'seed': 20260814, 'score': -1}),
      throwsFormatException,
    );
    expect(
      () => DailyRecord.fromJson({'seed': 20260814, 'moves': 1.5}),
      throwsFormatException,
    );
    expect(
      () => DailyRecord.fromJson({'seed': 20260814, 'highestTile': 3}),
      throwsFormatException,
    );
  });

  test('rejects malformed completion and update metadata', () {
    expect(
      () => DailyRecord.fromJson({'seed': 20260814, 'completed': 'yes'}),
      throwsFormatException,
    );
    expect(
      () => DailyRecord.fromJson({'seed': 20260814, 'won': 1}),
      throwsFormatException,
    );
    expect(
      () => DailyRecord.fromJson({'seed': 20260814, 'updatedAt': 'not-a-date'}),
      throwsFormatException,
    );
  });

  test('a win is always restored as completed', () {
    final restored = DailyRecord.fromJson({
      'seed': 20260814,
      'completed': false,
      'won': true,
      'updatedAt': DateTime.utc(2026, 8, 14).toIso8601String(),
    });

    expect(restored.won, isTrue);
    expect(restored.completed, isTrue);
  });
}
