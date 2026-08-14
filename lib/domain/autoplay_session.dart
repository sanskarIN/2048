import 'game_engine.dart';
import 'game_state.dart';
import 'game_types.dart';

/// An isolated deterministic autoplay session used by the Solver Demo.
///
/// This type intentionally does not depend on app persistence, statistics,
/// achievements, or Flutter widgets. Resetting the session recreates the
/// seeded engine so the same seed produces the same starting board and move
/// sequence when the heuristic recommendation remains deterministic.
class AutoplaySession {
  AutoplaySession({this.seed = 2048, this.size = 4}) {
    _resetInternal();
  }

  final int seed;
  final int size;

  late GameConfig config;
  late GameEngine engine;
  late GameState state;
  Direction? lastDirection;

  bool get isComplete => state.status != GameStatus.playing;

  /// Performs one heuristic-recommended move.
  ///
  /// Returns `true` only when the board changed. If the session has reached a
  /// terminal state or no legal recommendation remains, the engine refreshes
  /// terminal status and `false` is returned.
  bool step() {
    if (state.status != GameStatus.playing) return false;

    final direction = engine.hint(state);
    if (direction == null) {
      engine.refreshStatus(state);
      return false;
    }

    final outcome = engine.move(state, direction);
    if (outcome.changed) {
      lastDirection = direction;
      return true;
    }

    engine.refreshStatus(state);
    return false;
  }

  /// Restarts from the original deterministic seed.
  void reset() {
    _resetInternal();
  }

  void _resetInternal() {
    config = GameConfig(
      mode: GameMode.endless,
      size: size,
      target: 2048,
      seed: seed,
    );
    engine = GameEngine(config: config);
    state = engine.createGame();
    lastDirection = null;
  }
}
