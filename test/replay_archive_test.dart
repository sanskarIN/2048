import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:nova_2048/domain/game_engine.dart';
import 'package:nova_2048/domain/game_state.dart';
import 'package:nova_2048/domain/game_types.dart';
import 'package:nova_2048/domain/replay_archive.dart';

void main() {
  const config = GameConfig(mode: GameMode.classic, size: 4, seed: 2048);

  test('full replay round trip reconstructs deterministic move sequence', () {
    final engine = GameEngine(config: config);
    final initial = engine.createGame();
    final current = initial.copy();
    final capture = ReplayCapture.start(initial);

    for (var index = 0; index < 5; index++) {
      final direction = engine.hint(current);
      expect(direction, isNotNull);
      final at = initial.startedAt.add(Duration(seconds: index + 1));
      final outcome = engine.move(current, direction!, now: at);
      expect(outcome.changed, isTrue);
      expect(capture.appendMove(direction, at), isTrue);
    }

    final encoded = ReplayArchive.encode(
      capture,
      exportedAt: DateTime.utc(2026, 8, 15),
    );
    final decoded = ReplayArchive.decode(encoded);
    final frames = ReplayArchivePlayer.build(decoded);

    expect(frames.length, 6);
    expect(ReplayArchivePlayer.equivalent(frames.last, current), isTrue);
    expect(
      decoded.events.map((event) => event.kind),
      everyElement(ReplayEventKind.move),
    );
  });

  test('replay undo returns reconstructed state to the earlier frame', () {
    final engine = GameEngine(config: config);
    final initial = engine.createGame();
    final current = initial.copy();
    final capture = ReplayCapture.start(initial);
    final direction = engine.hint(current)!;
    final moveAt = initial.startedAt.add(const Duration(seconds: 1));

    expect(engine.move(current, direction, now: moveAt).changed, isTrue);
    capture.appendMove(direction, moveAt);
    capture.appendUndo(initial.startedAt.add(const Duration(seconds: 2)));

    final frames = ReplayArchivePlayer.build(capture);
    expect(frames.length, 3);
    expect(ReplayArchivePlayer.equivalent(frames.last, initial), isTrue);
  });

  test('replay supports explicit continue-after-win spectator action', () {
    final startedAt = DateTime.utc(2026, 8, 15, 8);
    final won = GameState(
      board: [
        [4, 0, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
      ],
      config: const GameConfig(
        mode: GameMode.target,
        size: 4,
        target: 4,
        seed: 7,
      ),
      score: 4,
      bestScore: 4,
      moves: 1,
      totalMerges: 1,
      status: GameStatus.won,
      rngState: 9,
      startedAt: startedAt,
    );
    final capture = ReplayCapture.incomplete(won);
    capture.appendContinueAfterWin(startedAt.add(const Duration(seconds: 1)));

    final finalFrame = ReplayArchivePlayer.build(capture).last;
    expect(finalFrame.status, GameStatus.playing);
    expect(finalFrame.hasAcknowledgedWin, isTrue);
    expect(finalFrame.board, won.board);
  });

  test('timed status refresh uses recorded deterministic event time', () {
    final startedAt = DateTime.utc(2026, 8, 15, 8);
    final initial = GameState(
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
        timeLimitSeconds: 1,
        seed: 7,
      ),
      rngState: 3,
      startedAt: startedAt,
    );
    final capture = ReplayCapture.incomplete(initial);
    capture.appendStatusRefresh(startedAt.add(const Duration(seconds: 2)));

    final finalFrame = ReplayArchivePlayer.build(capture).last;
    expect(finalFrame.status, GameStatus.lost);
  });

  test('player rejects invalid recorded actions and event order', () {
    final blocked = GameState(
      board: [
        [2, 4, 2, 4],
        [4, 2, 4, 2],
        [2, 4, 2, 4],
        [4, 2, 4, 2],
      ],
      config: config,
      rngState: 1,
      startedAt: DateTime.utc(2026, 8, 15),
    );
    final invalidMove = ReplayCapture.incomplete(blocked)
      ..appendMove(
        Direction.left,
        blocked.startedAt.add(const Duration(seconds: 1)),
      );
    expect(
      () => ReplayArchivePlayer.build(invalidMove),
      throwsA(isA<FormatException>()),
    );

    final engine = GameEngine(config: config);
    final initial = engine.createGame();
    final json = ReplayCapture.start(initial).toJson();
    json['events'] = [
      {'kind': 'statusRefresh', 'elapsedMilliseconds': 1000},
      {'kind': 'statusRefresh', 'elapsedMilliseconds': 500},
    ];
    final outOfOrder = ReplayCapture.fromJson(json);
    expect(
      () => ReplayArchivePlayer.build(outOfOrder),
      throwsA(isA<FormatException>()),
    );
  });

  test('export rejects incomplete and overflowed replay captures', () {
    final initial = GameEngine(config: config).createGame();
    final incomplete = ReplayCapture.incomplete(initial);
    expect(() => ReplayArchive.encode(incomplete), throwsStateError);

    final overflowed = ReplayCapture.start(initial);
    final at = initial.startedAt.add(const Duration(seconds: 1));
    for (var index = 0; index < ReplayCapture.maxEvents; index++) {
      expect(overflowed.appendUndo(at), isTrue);
    }
    expect(overflowed.appendUndo(at), isFalse);
    expect(overflowed.overflowed, isTrue);
    expect(() => ReplayArchive.encode(overflowed), throwsStateError);
  });

  test('decode rejects unsupported, incomplete, and oversized archives', () {
    final initial = GameEngine(config: config).createGame();
    final validCapture = ReplayCapture.start(initial);

    final wrongFormat = jsonEncode({
      'format': 'other',
      'version': 1,
      'exportedAt': DateTime.utc(2026, 8, 15).toIso8601String(),
      'capture': validCapture.toJson(),
    });
    expect(
      () => ReplayArchive.decode(wrongFormat),
      throwsA(isA<FormatException>()),
    );

    final incomplete = jsonEncode({
      'format': ReplayArchive.format,
      'version': ReplayArchive.version,
      'exportedAt': DateTime.utc(2026, 8, 15).toIso8601String(),
      'capture': ReplayCapture.incomplete(initial).toJson(),
    });
    expect(
      () => ReplayArchive.decode(incomplete),
      throwsA(isA<FormatException>()),
    );

    final oversized = List.filled(
      ReplayArchive.maxEncodedLength + 1,
      'x',
    ).join();
    expect(
      () => ReplayArchive.decode(oversized),
      throwsA(isA<FormatException>()),
    );
  });

  test('capture parser validates event shape and maximum count', () {
    final initial = GameEngine(config: config).createGame();
    final malformed = ReplayCapture.start(initial).toJson();
    malformed['events'] = [
      {'kind': 'move', 'elapsedMilliseconds': 1},
    ];
    expect(
      () => ReplayCapture.fromJson(malformed),
      throwsA(isA<FormatException>()),
    );

    final tooMany = ReplayCapture.start(initial).toJson();
    tooMany['events'] = List.generate(
      ReplayCapture.maxEvents + 1,
      (_) => {'kind': 'undo', 'elapsedMilliseconds': 1},
    );
    expect(
      () => ReplayCapture.fromJson(tooMany),
      throwsA(isA<FormatException>()),
    );
  });
}
