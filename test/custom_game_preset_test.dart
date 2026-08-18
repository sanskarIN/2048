import 'package:flutter_test/flutter_test.dart';
import 'package:nova_2048/domain/custom_game_preset.dart';
import 'package:nova_2048/domain/game_types.dart';

void main() {
  group('CustomGamePreset', () {
    test('normalizes name and maps target preset to GameConfig', () {
      final preset = CustomGamePreset.create(
        name: '  Big Target  ',
        style: CustomGameStyle.target,
        size: 6,
        target: 8192,
        seed: 42,
      );

      final config = preset.toGameConfig();

      expect(preset.name, 'Big Target');
      expect(config.mode, GameMode.target);
      expect(config.size, 6);
      expect(config.target, 8192);
      expect(config.seed, 42);
      expect(config.moveLimit, isNull);
      expect(config.timeLimitSeconds, isNull);
    });

    test('maps every supported custom style to the existing engine modes', () {
      final endless = CustomGamePreset.create(
        name: 'Endless 5x5',
        style: CustomGameStyle.endless,
        size: 5,
      ).toGameConfig();
      final timed = CustomGamePreset.create(
        name: 'Fast 3x3',
        style: CustomGameStyle.timed,
        size: 3,
        target: 1024,
        timeLimitSeconds: 90,
      ).toGameConfig();
      final moveLimit = CustomGamePreset.create(
        name: 'Forty Moves',
        style: CustomGameStyle.moveLimit,
        size: 4,
        target: 512,
        moveLimit: 40,
      ).toGameConfig();

      expect(endless.mode, GameMode.endless);
      expect(endless.size, 5);
      expect(timed.mode, GameMode.timeChallenge);
      expect(timed.timeLimitSeconds, 90);
      expect(moveLimit.mode, GameMode.moveLimit);
      expect(moveLimit.moveLimit, 40);
    });

    test('round trips versioned preset JSON', () {
      final original = CustomGamePreset.create(
        name: 'Seeded Sprint',
        style: CustomGameStyle.timed,
        size: 4,
        target: 4096,
        timeLimitSeconds: 180,
        seed: 20260818,
      );

      final restored = CustomGamePreset.fromJson(original.toJson());

      expect(restored.name, original.name);
      expect(restored.style, original.style);
      expect(restored.size, original.size);
      expect(restored.target, original.target);
      expect(restored.timeLimitSeconds, original.timeLimitSeconds);
      expect(restored.seed, original.seed);
      expect(restored.toJson(), original.toJson());
    });

    test('rejects invalid names, board sizes, targets, and seeds', () {
      expect(
        () => CustomGamePreset.create(
          name: '   ',
          style: CustomGameStyle.target,
          size: 4,
        ),
        throwsFormatException,
      );
      expect(
        () => CustomGamePreset.create(
          name: 'Too Small',
          style: CustomGameStyle.target,
          size: 2,
        ),
        throwsFormatException,
      );
      expect(
        () => CustomGamePreset.create(
          name: 'Bad Target',
          style: CustomGameStyle.target,
          size: 4,
          target: 3000,
        ),
        throwsFormatException,
      );
      expect(
        () => CustomGamePreset.create(
          name: 'Bad Seed',
          style: CustomGameStyle.target,
          size: 4,
          seed: 0x80000000,
        ),
        throwsFormatException,
      );
    });

    test('enforces style-specific limit contracts', () {
      expect(
        () => CustomGamePreset.create(
          name: 'Missing Timer',
          style: CustomGameStyle.timed,
          size: 4,
        ),
        throwsFormatException,
      );
      expect(
        () => CustomGamePreset.create(
          name: 'Missing Moves',
          style: CustomGameStyle.moveLimit,
          size: 4,
        ),
        throwsFormatException,
      );
      expect(
        () => CustomGamePreset.create(
          name: 'Unexpected Limit',
          style: CustomGameStyle.endless,
          size: 4,
          moveLimit: 50,
        ),
        throwsFormatException,
      );
      expect(
        () => CustomGamePreset.create(
          name: 'Mixed Limits',
          style: CustomGameStyle.timed,
          size: 4,
          timeLimitSeconds: 60,
          moveLimit: 20,
        ),
        throwsFormatException,
      );
    });

    test('rejects unknown schemas, styles, and malformed numbers', () {
      final valid = CustomGamePreset.create(
        name: 'Valid',
        style: CustomGameStyle.target,
        size: 4,
      ).toJson();

      expect(
        () => CustomGamePreset.fromJson({...valid, 'schemaVersion': 2}),
        throwsFormatException,
      );
      expect(
        () => CustomGamePreset.fromJson({...valid, 'style': 'futureStyle'}),
        throwsFormatException,
      );
      expect(
        () => CustomGamePreset.fromJson({...valid, 'size': 4.5}),
        throwsFormatException,
      );
      expect(
        () => CustomGamePreset.fromJson({...valid, 'target': '2048'}),
        throwsFormatException,
      );
    });
  });
}
