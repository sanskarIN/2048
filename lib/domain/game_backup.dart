import 'dart:convert';

import 'game_state.dart';

/// Portable text backup for one current game only.
///
/// Lifetime statistics, achievements, settings, Daily history, and Undo history
/// are intentionally excluded. Import callers must still decide how restored
/// games interact with local ranking/statistics policy.
class GameBackup {
  const GameBackup._();

  static const format = '2048-nova-game-backup';
  static const version = 1;
  static const maxEncodedLength = 128 * 1024;

  /// Conservative byte bound used before decoding file-based imports.
  ///
  /// The validated text protocol itself is capped by [maxEncodedLength]
  /// characters. UTF-8 can use up to four bytes per Unicode scalar value, so
  /// file input is bounded before allocation and then checked again by
  /// [decode]. Normal backups are much smaller than this ceiling.
  static const maxFileBytes = maxEncodedLength * 4;

  static String encode(GameState state, {DateTime? exportedAt}) {
    return jsonEncode({
      'format': format,
      'version': version,
      'exportedAt': (exportedAt ?? DateTime.now()).toUtc().toIso8601String(),
      'game': state.toJson(),
    });
  }

  static GameState decode(String raw) {
    final value = raw.trim();
    if (value.isEmpty) {
      throw const FormatException('Game backup is empty.');
    }
    if (value.length > maxEncodedLength) {
      throw const FormatException('Game backup is too large.');
    }

    final Object? decoded;
    try {
      decoded = jsonDecode(value);
    } on FormatException {
      throw const FormatException('Game backup is not valid JSON.');
    }

    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Game backup must be a JSON object.');
    }

    final envelope = Map<String, Object?>.from(decoded);
    if (envelope['format'] != format) {
      throw const FormatException('Unsupported game backup format.');
    }
    if (envelope['version'] != version) {
      throw const FormatException('Unsupported game backup version.');
    }

    final exportedAt = envelope['exportedAt'];
    if (exportedAt is! String || DateTime.tryParse(exportedAt) == null) {
      throw const FormatException('Game backup timestamp is invalid.');
    }

    final game = envelope['game'];
    if (game is! Map<String, dynamic>) {
      throw const FormatException('Game backup does not contain a valid game.');
    }

    return GameState.fromJson(Map<String, Object?>.from(game));
  }
}
