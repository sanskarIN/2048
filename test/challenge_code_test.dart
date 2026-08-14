import 'package:flutter_test/flutter_test.dart';
import 'package:nova_2048/domain/challenge_code.dart';
import 'package:nova_2048/domain/game_engine.dart';
import 'package:nova_2048/domain/game_types.dart';

void main() {
  group('ChallengeCode', () {
    test('round trips every supported preset mode', () {
      for (final mode in ChallengeCode.supportedModes) {
        final preset = GameConfig.preset(
          mode,
          target: mode == GameMode.target ? 8192 : null,
        );
        final seeded = ChallengeCode.withSeed(preset, 20260814);

        final decoded = ChallengeCode.decode(ChallengeCode.encode(seeded));

        expect(decoded.toJson(), seeded.toJson(), reason: mode.name);
      }
    });

    test('encoding is stable for the same configuration', () {
      final config = ChallengeCode.withSeed(
        GameConfig.preset(GameMode.classic),
        42,
      );

      expect(ChallengeCode.encode(config), ChallengeCode.encode(config));
    });

    test('decoded seed creates the same deterministic opening board', () {
      final source = ChallengeCode.withSeed(
        GameConfig.preset(GameMode.extended),
        13579,
      );
      final decoded = ChallengeCode.decode(ChallengeCode.encode(source));

      final first = GameEngine(config: source).createGame();
      final second = GameEngine(config: decoded).createGame();

      expect(second.board, first.board);
      expect(second.rngState, first.rngState);
    });

    test('rejects unseeded configurations', () {
      expect(
        () => ChallengeCode.encode(GameConfig.preset(GameMode.classic)),
        throwsFormatException,
      );
    });

    test('rejects Daily Challenge codes', () {
      final daily = ChallengeCode.withSeed(
        const GameConfig(mode: GameMode.daily, size: 4),
        20260814,
      );

      expect(() => ChallengeCode.encode(daily), throwsFormatException);
    });

    test('rejects empty and unsupported prefixes', () {
      expect(() => ChallengeCode.decode(''), throwsFormatException);
      expect(
        () => ChallengeCode.decode('OTHER.payload.00000000'),
        throwsFormatException,
      );
    });

    test('rejects checksum tampering', () {
      final code = ChallengeCode.encode(
        ChallengeCode.withSeed(
          GameConfig.preset(GameMode.quick),
          77,
        ),
      );
      final parts = code.split('.');
      final replacement = parts.last == '00000000' ? '00000001' : '00000000';
      final tampered = '${parts[0]}.${parts[1]}.$replacement';

      expect(() => ChallengeCode.decode(tampered), throwsFormatException);
    });

    test('rejects malformed checksum and payload structure', () {
      expect(
        () => ChallengeCode.decode('NOVA1.payload.not-hex!!'),
        throwsFormatException,
      );
      expect(
        () => ChallengeCode.decode('NOVA1.only-two-parts'),
        throwsFormatException,
      );
    });

    test('rejects oversized input before payload parsing', () {
      final oversized = List.filled(ChallengeCode.maxCodeLength + 1, 'A').join();
      expect(() => ChallengeCode.decode(oversized), throwsFormatException);
    });

    test('withSeed rejects unsafe seed bounds', () {
      final preset = GameConfig.preset(GameMode.classic);
      expect(() => ChallengeCode.withSeed(preset, -1), throwsFormatException);
      expect(
        () => ChallengeCode.withSeed(preset, 0x80000000),
        throwsFormatException,
      );
    });
  });
}
