import 'package:flutter_test/flutter_test.dart';
import 'package:nova_2048/domain/game_engine.dart';
import 'package:nova_2048/domain/game_state.dart';
import 'package:nova_2048/domain/game_types.dart';

void main() {
  test('timed restore expires at the same absolute deadline', () {
    final localStartedAt = DateTime(2026, 8, 17, 12);
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
        seed: 7,
      ),
      rngState: 7,
      startedAt: localStartedAt,
    );

    final restored = GameState.fromJson(state.toJson());
    final engine = GameEngine(config: restored.config);

    engine.refreshStatus(
      restored,
      now: localStartedAt.add(const Duration(seconds: 179)),
    );
    expect(restored.status, GameStatus.playing);

    engine.refreshStatus(
      restored,
      now: localStartedAt.add(const Duration(seconds: 180)),
    );
    expect(restored.status, GameStatus.lost);
  });
}
