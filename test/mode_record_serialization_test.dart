import 'package:flutter_test/flutter_test.dart';
import 'package:nova_2048/app/state/app_controller.dart';
import 'package:nova_2048/domain/game_types.dart';

void main() {
  test('per-mode records round trip through PlayerStats JSON', () {
    final stats = PlayerStats();
    stats.recordFor(GameMode.target)
      ..bestScore = 16384
      ..highestTile = 4096
      ..bestScoreBoardSize = 5
      ..bestScoreTarget = 8192;

    final restored = PlayerStats.fromJson(stats.toJson());
    final restoredRecord = restored.existingRecordFor(GameMode.target);

    expect(restoredRecord, isNotNull);
    expect(restoredRecord!.bestScore, 16384);
    expect(restoredRecord.highestTile, 4096);
    expect(restoredRecord.bestScoreBoardSize, 5);
    expect(restoredRecord.bestScoreTarget, 8192);
  });

  test('malformed and unknown mode records are ignored safely', () {
    final stats = PlayerStats.fromJson({
      'modeRecords': {
        'classic': {
          'bestScore': -4,
          'highestTile': 3,
          'bestScoreBoardSize': 99,
          'bestScoreTarget': 6,
        },
        'quick': {
          'bestScore': 128,
          'highestTile': 64,
          'bestScoreBoardSize': 3,
          'bestScoreTarget': 512,
        },
        'futureMode': {'bestScore': 999999, 'highestTile': 8192},
      },
    });

    expect(stats.existingRecordFor(GameMode.classic), isNull);
    final quick = stats.existingRecordFor(GameMode.quick);
    expect(quick, isNotNull);
    expect(quick!.bestScore, 128);
    expect(quick.highestTile, 64);
    expect(quick.bestScoreBoardSize, 3);
    expect(quick.bestScoreTarget, 512);
    expect(stats.modeRecords, hasLength(1));
  });

  test('legacy statistics payloads remain backward compatible', () {
    final stats = PlayerStats.fromJson({
      'gamesPlayed': 8,
      'gamesWon': 3,
      'bestScore': 4096,
      'highestTile': 512,
      'totalMoves': 120,
      'totalMerges': 75,
      'currentStreak': 1,
      'bestStreak': 2,
    });

    expect(stats.gamesPlayed, 8);
    expect(stats.gamesWon, 3);
    expect(stats.bestScore, 4096);
    expect(stats.modeRecords, isEmpty);
  });
}
