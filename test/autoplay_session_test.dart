import 'package:flutter_test/flutter_test.dart';
import 'package:nova_2048/domain/autoplay_session.dart';

void main() {
  test('reset restores the same deterministic starting state', () {
    final session = AutoplaySession(seed: 4242);
    final startingBoard = session.state.board
        .map((row) => List<int>.from(row))
        .toList(growable: false);
    final startingRng = session.state.rngState;

    expect(session.step(), isTrue);
    expect(session.state.moves, 1);

    session.reset();

    expect(session.state.board, startingBoard);
    expect(session.state.rngState, startingRng);
    expect(session.state.moves, 0);
    expect(session.state.score, 0);
    expect(session.lastDirection, isNull);
  });

  test('matching seeded sessions produce matching autoplay sequences', () {
    final first = AutoplaySession(seed: 9001);
    final second = AutoplaySession(seed: 9001);

    for (var step = 0; step < 40; step++) {
      final firstChanged = first.step();
      final secondChanged = second.step();

      expect(secondChanged, firstChanged);
      expect(second.lastDirection, first.lastDirection);
      expect(second.state.board, first.state.board);
      expect(second.state.score, first.state.score);
      expect(second.state.moves, first.state.moves);
      expect(second.state.rngState, first.state.rngState);

      if (!firstChanged) break;
    }
  });

  test('autoplay step does not expose persistence or player statistics', () {
    final session = AutoplaySession(seed: 17, size: 5);

    expect(session.config.size, 5);
    expect(session.step(), isTrue);
    expect(session.state.moves, 1);
    expect(session.state.bestScore, session.state.score);
  });
}
