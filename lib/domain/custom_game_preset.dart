import 'game_types.dart';

enum CustomGameStyle { target, endless, timed, moveLimit }

class CustomGamePreset {
  const CustomGamePreset._({
    required this.name,
    required this.style,
    required this.size,
    required this.target,
    required this.moveLimit,
    required this.timeLimitSeconds,
    required this.seed,
  });

  static const int schemaVersion = 1;
  static const int maxNameLength = 40;

  final String name;
  final CustomGameStyle style;
  final int size;
  final int target;
  final int? moveLimit;
  final int? timeLimitSeconds;
  final int? seed;

  factory CustomGamePreset.create({
    required String name,
    required CustomGameStyle style,
    required int size,
    int target = 2048,
    int? moveLimit,
    int? timeLimitSeconds,
    int? seed,
  }) {
    final normalizedName = name.trim();
    _validate(
      name: normalizedName,
      style: style,
      size: size,
      target: target,
      moveLimit: moveLimit,
      timeLimitSeconds: timeLimitSeconds,
      seed: seed,
    );
    return CustomGamePreset._(
      name: normalizedName,
      style: style,
      size: size,
      target: target,
      moveLimit: moveLimit,
      timeLimitSeconds: timeLimitSeconds,
      seed: seed,
    );
  }

  GameConfig toGameConfig() {
    return switch (style) {
      CustomGameStyle.target => GameConfig(
        mode: GameMode.target,
        size: size,
        target: target,
        seed: seed,
      ),
      CustomGameStyle.endless => GameConfig(
        mode: GameMode.endless,
        size: size,
        target: target,
        seed: seed,
      ),
      CustomGameStyle.timed => GameConfig(
        mode: GameMode.timeChallenge,
        size: size,
        target: target,
        timeLimitSeconds: timeLimitSeconds,
        seed: seed,
      ),
      CustomGameStyle.moveLimit => GameConfig(
        mode: GameMode.moveLimit,
        size: size,
        target: target,
        moveLimit: moveLimit,
        seed: seed,
      ),
    };
  }

  Map<String, Object?> toJson() => {
    'schemaVersion': schemaVersion,
    'name': name,
    'style': style.name,
    'size': size,
    'target': target,
    'moveLimit': moveLimit,
    'timeLimitSeconds': timeLimitSeconds,
    'seed': seed,
  };

  factory CustomGamePreset.fromJson(Map<String, Object?> json) {
    final rawSchemaVersion = json['schemaVersion'];
    if (rawSchemaVersion is! num ||
        !rawSchemaVersion.isFinite ||
        rawSchemaVersion.toInt() != rawSchemaVersion ||
        rawSchemaVersion.toInt() != schemaVersion) {
      throw const FormatException('Unsupported custom preset schema');
    }

    final rawName = json['name'];
    if (rawName is! String) {
      throw const FormatException('Invalid custom preset name');
    }

    final rawStyle = json['style'];
    if (rawStyle is! String) {
      throw const FormatException('Invalid custom game style');
    }
    CustomGameStyle? style;
    for (final candidate in CustomGameStyle.values) {
      if (candidate.name == rawStyle) {
        style = candidate;
        break;
      }
    }
    if (style == null) {
      throw const FormatException('Unsupported custom game style');
    }

    return CustomGamePreset.create(
      name: rawName,
      style: style,
      size: _requiredInt(json['size'], 'board size'),
      target: _requiredInt(json['target'], 'target tile'),
      moveLimit: _optionalInt(json['moveLimit'], 'move limit'),
      timeLimitSeconds: _optionalInt(
        json['timeLimitSeconds'],
        'time limit',
      ),
      seed: _optionalInt(json['seed'], 'random seed'),
    );
  }

  static int _requiredInt(Object? value, String label) {
    if (value == null) {
      throw FormatException('Missing $label');
    }
    return _checkedInt(value, label);
  }

  static int? _optionalInt(Object? value, String label) {
    if (value == null) return null;
    return _checkedInt(value, label);
  }

  static int _checkedInt(Object value, String label) {
    if (value is! num || !value.isFinite || value.toInt() != value) {
      throw FormatException('Invalid $label');
    }
    return value.toInt();
  }

  static void _validate({
    required String name,
    required CustomGameStyle style,
    required int size,
    required int target,
    required int? moveLimit,
    required int? timeLimitSeconds,
    required int? seed,
  }) {
    if (name.isEmpty || name.length > maxNameLength) {
      throw const FormatException('Invalid custom preset name');
    }
    if (size < 3 || size > 8) {
      throw const FormatException('Unsupported board size');
    }
    if (!_isPowerOfTwo(target) || target < 4 || target > 1 << 30) {
      throw const FormatException('Invalid target tile');
    }
    if (seed != null && (seed < 0 || seed > 0x7fffffff)) {
      throw const FormatException('Invalid random seed');
    }

    switch (style) {
      case CustomGameStyle.target:
      case CustomGameStyle.endless:
        if (moveLimit != null || timeLimitSeconds != null) {
          throw const FormatException('Unexpected custom game limit');
        }
        break;
      case CustomGameStyle.timed:
        if (moveLimit != null ||
            timeLimitSeconds == null ||
            timeLimitSeconds < 1 ||
            timeLimitSeconds > 86400) {
          throw const FormatException('Invalid custom time limit');
        }
        break;
      case CustomGameStyle.moveLimit:
        if (timeLimitSeconds != null ||
            moveLimit == null ||
            moveLimit < 1 ||
            moveLimit > 1000000) {
          throw const FormatException('Invalid custom move limit');
        }
        break;
    }
  }

  static bool _isPowerOfTwo(int value) =>
      value > 0 && (value & (value - 1)) == 0;
}
