import 'package:flutter_test/flutter_test.dart';
import 'package:nova_2048/domain/game_state.dart';
import 'package:nova_2048/domain/game_types.dart';

void main() {
  test('timezone-less saved timestamps remain readable and upgrade to UTC', () {
    final restored = GameState.fromJson({
      'schema': GameState.schemaVersion,
      'board': [
        [2, 0, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
      ],
      'config': const GameConfig(
        mode: GameMode.timeChallenge,
        size: 4,
        target: 2048,
        timeLimitSeconds: 180,
        seed: 42,
      ).toJson(),
      'score': 0,
      'bestScore': 0,
      'moves': 0,
      'totalMerges': 0,
      'status': GameStatus.playing.name,
      'hasAcknowledgedWin': false,
      'rngState': 42,
      'startedAt': '2026-08-17T10:30:45.000',
    });

    expect(restored.startedAt.isUtc, isFalse);
    expect(restored.toJson()['startedAt'], endsWith('Z'));
  });
}
