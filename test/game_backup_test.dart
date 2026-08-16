import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:nova_2048/domain/game_backup.dart';
import 'package:nova_2048/domain/game_state.dart';
import 'package:nova_2048/domain/game_types.dart';

void main() {
  final startedAt = DateTime.utc(2026, 8, 14, 9);
  final exportedAt = DateTime.utc(2026, 8, 14, 10);

  GameState state() => GameState(
    config: const GameConfig(
      mode: GameMode.classic,
      size: 4,
      target: 2048,
      seed: 42,
    ),
    board: [
      [2, 4, 8, 16],
      [32, 64, 0, 0],
      [0, 0, 0, 0],
      [0, 0, 0, 0],
    ],
    score: 120,
    bestScore: 256,
    moves: 12,
    totalMerges: 7,
    rngState: 123456,
    startedAt: startedAt,
  );

  test('backup round trip preserves the current game', () {
    final source = state();
    final encoded = GameBackup.encode(source, exportedAt: exportedAt);
    final restored = GameBackup.decode(encoded);

    expect(restored.toJson(), source.toJson());
  });

  test('backup envelope excludes unrelated lifetime and preference data', () {
    final encoded = GameBackup.encode(state(), exportedAt: exportedAt);
    final envelope = jsonDecode(encoded) as Map<String, dynamic>;

    expect(envelope['format'], GameBackup.format);
    expect(envelope['version'], GameBackup.version);
    expect(envelope['exportedAt'], exportedAt.toIso8601String());
    expect(envelope['game'], isA<Map<String, dynamic>>());
    expect(envelope, isNot(contains('stats')));
    expect(envelope, isNot(contains('settings')));
    expect(envelope, isNot(contains('achievements')));
    expect(envelope, isNot(contains('dailyHistory')));
    expect(envelope, isNot(contains('undo')));
  });

  test('empty and malformed text are rejected', () {
    expect(() => GameBackup.decode('   '), throwsFormatException);
    expect(() => GameBackup.decode('{not-json'), throwsFormatException);
    expect(() => GameBackup.decode('[]'), throwsFormatException);
  });

  test('unsupported format and version are rejected', () {
    final valid =
        jsonDecode(GameBackup.encode(state(), exportedAt: exportedAt))
            as Map<String, dynamic>;

    final wrongFormat = Map<String, dynamic>.from(valid)
      ..['format'] = 'another-game';
    final wrongVersion = Map<String, dynamic>.from(valid)..['version'] = 999;

    expect(
      () => GameBackup.decode(jsonEncode(wrongFormat)),
      throwsFormatException,
    );
    expect(
      () => GameBackup.decode(jsonEncode(wrongVersion)),
      throwsFormatException,
    );
  });

  test('invalid export timestamp and missing game are rejected', () {
    final valid =
        jsonDecode(GameBackup.encode(state(), exportedAt: exportedAt))
            as Map<String, dynamic>;
    final invalidTime = Map<String, dynamic>.from(valid)
      ..['exportedAt'] = 'not-a-time';
    final missingGame = Map<String, dynamic>.from(valid)..remove('game');

    expect(
      () => GameBackup.decode(jsonEncode(invalidTime)),
      throwsFormatException,
    );
    expect(
      () => GameBackup.decode(jsonEncode(missingGame)),
      throwsFormatException,
    );
  });

  test('strict game-state validation is applied to imported backups', () {
    final valid =
        jsonDecode(GameBackup.encode(state(), exportedAt: exportedAt))
            as Map<String, dynamic>;
    final game = Map<String, dynamic>.from(valid['game'] as Map)
      ..['board'] = [
        [3, 0, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
      ];
    final invalidGame = Map<String, dynamic>.from(valid)..['game'] = game;

    expect(
      () => GameBackup.decode(jsonEncode(invalidGame)),
      throwsFormatException,
    );
  });

  test('oversized backup text is rejected before JSON parsing', () {
    final oversized = List.filled(
      GameBackup.maxEncodedLength + 1,
      'x',
      growable: false,
    ).join();
    expect(() => GameBackup.decode(oversized), throwsFormatException);
  });
}
