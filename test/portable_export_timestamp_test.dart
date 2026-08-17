import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:nova_2048/domain/game_backup.dart';
import 'package:nova_2048/domain/game_engine.dart';
import 'package:nova_2048/domain/game_types.dart';
import 'package:nova_2048/domain/replay_archive.dart';

void main() {
  test('game backup normalizes explicit export time to UTC', () {
    final localExportedAt = DateTime(2026, 8, 17, 11, 15, 30);
    final game = GameEngine(
      config: const GameConfig(mode: GameMode.classic, size: 4, seed: 42),
    ).createGame();

    final encoded = GameBackup.encode(game, exportedAt: localExportedAt);
    final envelope = jsonDecode(encoded) as Map<String, dynamic>;
    final serialized = envelope['exportedAt'] as String;
    final restored = DateTime.parse(serialized);

    expect(localExportedAt.isUtc, isFalse);
    expect(serialized, endsWith('Z'));
    expect(restored.isUtc, isTrue);
    expect(restored.isAtSameMomentAs(localExportedAt), isTrue);
  });

  test('replay archive normalizes explicit export time to UTC', () {
    final localExportedAt = DateTime(2026, 8, 17, 11, 45, 15);
    final initial = GameEngine(
      config: const GameConfig(mode: GameMode.classic, size: 4, seed: 2048),
    ).createGame();

    final encoded = ReplayArchive.encode(
      ReplayCapture.start(initial),
      exportedAt: localExportedAt,
    );
    final envelope = jsonDecode(encoded) as Map<String, dynamic>;
    final serialized = envelope['exportedAt'] as String;
    final restored = DateTime.parse(serialized);

    expect(localExportedAt.isUtc, isFalse);
    expect(serialized, endsWith('Z'));
    expect(restored.isUtc, isTrue);
    expect(restored.isAtSameMomentAs(localExportedAt), isTrue);
  });
}
