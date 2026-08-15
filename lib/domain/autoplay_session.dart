import 'expectimax_solver.dart';
import 'game_engine.dart';
import 'game_state.dart';
import 'game_types.dart';

enum AutoplayStrategy { heuristic, expectimax }

/// An isolated deterministic autoplay session used by the Solver Demo.
///
/// This type intentionally does not depend on app persistence, statistics,
/// achievements, or Flutter widgets. Resetting the session recreates the
/// seeded engine so the same seed produces the same starting board and move
/// sequence for a given deterministic strategy.
class AutoplaySession {
  AutoplaySession({
    this.seed = 2048,
    this.size = 4,
    this.strategy = AutoplayStrategy.heuristic,
  }) {
    _resetInternal();
  }

  final int seed;
  final int size;
  AutoplayStrategy strategy;

  late GameConfig config;
  late GameEngine engine;
  late GameState state;
  Direction? lastDirection;
  int lastDecisionNodes = 0;
  double? lastExpectedValue;

  bool get isComplete => state.status != GameStatus.playing;

  /// Performs one strategy-recommended move.
  ///
  /// Returns `true` only when the board changed. If the session has reached a
  /// terminal state or no legal recommendation remains, the engine refreshes
  /// terminal status and `false` is returned.
  bool step() {
    if (state.status != GameStatus.playing) return false;

    final direction = _recommend();
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

  /// Changes the sandbox strategy without touching the board or RNG state.
  void setStrategy(AutoplayStrategy value) {
    if (strategy == value) return;
    strategy = value;
    lastDirection = null;
    lastDecisionNodes = 0;
    lastExpectedValue = null;
  }

  /// Restarts from the original deterministic seed while keeping the selected
  /// strategy.
  void reset() {
    _resetInternal();
  }

  Direction? _recommend() {
    switch (strategy) {
      case AutoplayStrategy.heuristic:
        lastDecisionNodes = 0;
        lastExpectedValue = null;
        return engine.hint(state);
      case AutoplayStrategy.expectimax:
        final result = ExpectimaxSolver(size: size).recommend(state.board);
        lastDecisionNodes = result.exploredNodes;
        lastExpectedValue = result.expectedValue;
        return result.direction;
    }
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
    lastDecisionNodes = 0;
    lastExpectedValue = null;
  }
}
