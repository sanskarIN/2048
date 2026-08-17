import 'package:flutter_test/flutter_test.dart';
import 'package:nova_2048/domain/game_state.dart';
import 'package:nova_2048/domain/game_types.dart';

void main() {
  test('game state serializes start time as an absolute UTC instant', () {
    final localStartedAt = DateTime(2026, 8, 17, 10, 30, 45);
    final state = GameState(
      board: [
        [2, 0, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
      ],
      config: const GameConfig(
        mode: GameMode.timeChallenge,
        size: 4,
        target: 2048,
        timeLimitSeconds: 180,
        seed: 42,
      ),
      rngState: 42,
      startedAt: localStartedAt,
    );

    final encoded = state.toJson();
    final serialized = encoded['startedAt'] as String;
    final restored = GameState.fromJson(encoded);

    expect(localStartedAt.isUtc, isFalse);
    expect(serialized, endsWith('Z'));
    expect(restored.startedAt.isUtc, isTrue);
    expect(restored.startedAt.isAtSameMomentAs(localStartedAt), isTrue);
  });
}
