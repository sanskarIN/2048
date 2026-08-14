import 'dart:convert';

import 'game_types.dart';

class ChallengeCode {
  const ChallengeCode._();

  static const String format = '2048-nova-challenge';
  static const int version = 1;
  static const int maxCodeLength = 1024;
  static const String _prefix = 'NOVA1';

  static const Set<GameMode> supportedModes = {
    GameMode.classic,
    GameMode.quick,
    GameMode.extended,
    GameMode.challenge,
    GameMode.endless,
    GameMode.target,
    GameMode.timeChallenge,
    GameMode.moveLimit,
    GameMode.zen,
  };

  static GameConfig withSeed(GameConfig config, int seed) {
    if (seed < 0 || seed > 0x7fffffff) {
      throw const FormatException('Invalid challenge seed');
    }
    return GameConfig(
      mode: config.mode,
      size: config.size,
      target: config.target,
      moveLimit: config.moveLimit,
      timeLimitSeconds: config.timeLimitSeconds,
      seed: seed,
    );
  }

  static String encode(GameConfig config) {
    _validateSharable(config);
    final envelope = <String, Object?>{
      'format': format,
      'version': version,
      'config': config.toJson(),
    };
    final payload = _encodePayload(jsonEncode(envelope));
    final checksum = _checksum(payload);
    return '$_prefix.$payload.$checksum';
  }

  static GameConfig decode(String text) {
    final code = text.trim();
    if (code.isEmpty) {
      throw const FormatException('Challenge code is empty');
    }
    if (code.length > maxCodeLength) {
      throw const FormatException('Challenge code is too large');
    }

    final parts = code.split('.');
    if (parts.length != 3 || parts.first != _prefix) {
      throw const FormatException('Unsupported challenge code format');
    }
    final payload = parts[1];
    final checksum = parts[2].toLowerCase();
    if (payload.isEmpty || checksum.length != 8 || !_isHex(checksum)) {
      throw const FormatException('Malformed challenge code');
    }
    if (_checksum(payload) != checksum) {
      throw const FormatException('Challenge code checksum does not match');
    }

    Object? decoded;
    try {
      decoded = jsonDecode(_decodePayload(payload));
    } on FormatException {
      rethrow;
    } catch (_) {
      throw const FormatException('Challenge code payload is invalid');
    }
    if (decoded is! Map<String, Object?>) {
      throw const FormatException('Challenge code payload is invalid');
    }
    if (decoded['format'] != format) {
      throw const FormatException('Unsupported challenge code format');
    }
    if (decoded['version'] != version) {
      throw const FormatException('Unsupported challenge code version');
    }

    final rawConfig = decoded['config'];
    if (rawConfig is! Map<String, Object?>) {
      throw const FormatException('Challenge code configuration is missing');
    }
    final config = GameConfig.fromJson(rawConfig);
    _validateSharable(config);
    return config;
  }

  static void _validateSharable(GameConfig config) {
    if (!supportedModes.contains(config.mode)) {
      throw const FormatException('This game mode cannot use challenge codes');
    }
    if (config.seed == null) {
      throw const FormatException('Challenge code requires a deterministic seed');
    }
    // Reuse the strict persisted configuration parser as the single source of
    // truth for all bounds and type-independent invariants.
    GameConfig.fromJson(config.toJson());
  }

  static String _encodePayload(String json) =>
      base64Url.encode(utf8.encode(json)).replaceAll('=', '');

  static String _decodePayload(String payload) {
    final padding = (4 - payload.length % 4) % 4;
    try {
      return utf8.decode(base64Url.decode('$payload${'=' * padding}'));
    } catch (_) {
      throw const FormatException('Challenge code payload is invalid');
    }
  }

  static String _checksum(String payload) {
    var hash = 0x811c9dc5;
    for (final byte in utf8.encode(payload)) {
      hash ^= byte;
      hash = (hash * 0x01000193) & 0xffffffff;
    }
    return hash.toRadixString(16).padLeft(8, '0');
  }

  static bool _isHex(String value) {
    for (final unit in value.codeUnits) {
      final digit = unit >= 48 && unit <= 57;
      final lower = unit >= 97 && unit <= 102;
      if (!digit && !lower) return false;
    }
    return true;
  }
}
