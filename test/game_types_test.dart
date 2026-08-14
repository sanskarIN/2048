import 'package:flutter_test/flutter_test.dart';
import 'package:nova_2048/domain/game_types.dart';

void main() {
  group('GameConfig persistence validation', () {
    test('round trips a valid configuration', () {
      const original = GameConfig(
        mode: GameMode.timeChallenge,
        size: 4,
        target: 4096,
        moveLimit: 300,
        timeLimitSeconds: 180,
        seed: 20260814,
      );

      final restored = GameConfig.fromJson(original.toJson());

      expect(restored.mode, GameMode.timeChallenge);
      expect(restored.size, 4);
      expect(restored.target, 4096);
      expect(restored.moveLimit, 300);
      expect(restored.timeLimitSeconds, 180);
      expect(restored.seed, 20260814);
    });

    test('rejects unknown or wrongly typed game modes', () {
      expect(
        () => GameConfig.fromJson({'mode': 'futureMode', 'size': 4}),
        throwsFormatException,
      );
      expect(
        () => GameConfig.fromJson({'mode': 7, 'size': 4}),
        throwsFormatException,
      );
    });

    test('rejects fractional and wrongly typed numeric fields', () {
      expect(
        () => GameConfig.fromJson({'mode': 'classic', 'size': 4.5}),
        throwsFormatException,
      );
      expect(
        () => GameConfig.fromJson({'mode': 'classic', 'size': '4'}),
        throwsFormatException,
      );
      expect(
        () => GameConfig.fromJson({
          'mode': 'classic',
          'size': 4,
          'moveLimit': '250',
        }),
        throwsFormatException,
      );
    });

    test('rejects out of range deterministic seeds', () {
      expect(
        () => GameConfig.fromJson({
          'mode': 'daily',
          'size': 4,
          'seed': 0x80000000,
        }),
        throwsFormatException,
      );
    });
  });
}
