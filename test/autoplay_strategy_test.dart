import 'package:flutter_test/flutter_test.dart';
import 'package:nova_2048/domain/autoplay_session.dart';

void main() {
  test('autoplay keeps heuristic as the backward-compatible default', () {
    final session = AutoplaySession();

    expect(session.strategy, AutoplayStrategy.heuristic);
    expect(session.lastDecisionNodes, 0);
    expect(session.lastExpectedValue, isNull);
  });

  test('switching strategy does not mutate sandbox game state', () {
    final session = AutoplaySession(seed: 77);
    final boardBefore = [for (final row in session.state.board) [...row]];
    final rngBefore = session.state.rngState;
    final movesBefore = session.state.moves;
    final scoreBefore = session.state.score;

    session.setStrategy(AutoplayStrategy.expectimax);

    expect(session.strategy, AutoplayStrategy.expectimax);
    expect(session.state.board, boardBefore);
    expect(session.state.rngState, rngBefore);
    expect(session.state.moves, movesBefore);
    expect(session.state.score, scoreBefore);
  });

  test('matching seeded expectimax sessions produce matching sequences', () {
    final first = AutoplaySession(
      seed: 20260815,
      strategy: AutoplayStrategy.expectimax,
    );
    final second = AutoplaySession(
      seed: 20260815,
      strategy: AutoplayStrategy.expectimax,
    );

    for (var step = 0; step < 12; step++) {
      expect(first.step(), second.step());
      expect(first.lastDirection, second.lastDirection);
      expect(first.state.board, second.state.board);
      expect(first.state.score, second.state.score);
      expect(first.state.moves, second.state.moves);
      expect(first.state.rngState, second.state.rngState);
      expect(first.lastDecisionNodes, second.lastDecisionNodes);
      expect(first.lastExpectedValue, second.lastExpectedValue);
      if (first.isComplete) break;
    }
  });

  test('expectimax steps expose bounded decision diagnostics', () {
    final session = AutoplaySession(
      seed: 2048,
      strategy: AutoplayStrategy.expectimax,
    );

    final changed = session.step();

    expect(changed, isTrue);
    expect(session.lastDecisionNodes, greaterThan(0));
    expect(session.lastDecisionNodes, lessThanOrEqualTo(50000));
    expect(session.lastExpectedValue, isNotNull);
    expect(session.lastExpectedValue!.isFinite, isTrue);
  });

  test('reset retains strategy but clears decision diagnostics', () {
    final session = AutoplaySession(
      seed: 512,
      strategy: AutoplayStrategy.expectimax,
    );
    final initialBoard = [for (final row in session.state.board) [...row]];
    session.step();
    expect(session.lastDecisionNodes, greaterThan(0));

    session.reset();

    expect(session.strategy, AutoplayStrategy.expectimax);
    expect(session.state.board, initialBoard);
    expect(session.state.moves, 0);
    expect(session.lastDirection, isNull);
    expect(session.lastDecisionNodes, 0);
    expect(session.lastExpectedValue, isNull);
  });
}
