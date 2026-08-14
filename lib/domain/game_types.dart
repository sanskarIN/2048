enum Direction { up, down, left, right }

enum GameStatus { playing, won, lost }

enum GameMode {
  classic,
  quick,
  extended,
  challenge,
  endless,
  target,
  timeChallenge,
  moveLimit,
  daily,
  zen,
}

class GameConfig {
  const GameConfig({
    required this.mode,
    required this.size,
    this.target = 2048,
    this.moveLimit,
    this.timeLimitSeconds,
    this.seed,
  });

  final GameMode mode;
  final int size;
  final int target;
  final int? moveLimit;
  final int? timeLimitSeconds;
  final int? seed;

  static GameConfig preset(GameMode mode, {int? target}) {
    return switch (mode) {
      GameMode.quick =>
        const GameConfig(mode: GameMode.quick, size: 3, target: 512),
      GameMode.extended => const GameConfig(mode: GameMode.extended, size: 5),
      GameMode.challenge =>
        const GameConfig(mode: GameMode.challenge, size: 6, target: 4096),
      GameMode.endless =>
        const GameConfig(mode: GameMode.endless, size: 4, target: 2048),
      GameMode.target =>
        GameConfig(mode: GameMode.target, size: 4, target: target ?? 4096),
      GameMode.timeChallenge => const GameConfig(
          mode: GameMode.timeChallenge, size: 4, timeLimitSeconds: 180),
      GameMode.moveLimit =>
        const GameConfig(mode: GameMode.moveLimit, size: 4, moveLimit: 250),
      GameMode.daily =>
        GameConfig(mode: GameMode.daily, size: 4, seed: _dailySeed()),
      GameMode.zen => const GameConfig(mode: GameMode.zen, size: 4),
      GameMode.classic => const GameConfig(mode: GameMode.classic, size: 4),
    };
  }

  static int _dailySeed() {
    final now = DateTime.now().toUtc();
    return now.year * 10000 + now.month * 100 + now.day;
  }

  Map<String, Object?> toJson() => {
        'mode': mode.name,
        'size': size,
        'target': target,
        'moveLimit': moveLimit,
        'timeLimitSeconds': timeLimitSeconds,
        'seed': seed,
      };

  factory GameConfig.fromJson(Map<String, Object?> json) {
    final rawMode = json['mode'];
    if (rawMode != null && rawMode is! String) {
      throw const FormatException('Invalid game mode');
    }
    final modeName = rawMode as String? ?? GameMode.classic.name;
    GameMode? mode;
    for (final value in GameMode.values) {
      if (value.name == modeName) {
        mode = value;
        break;
      }
    }
    if (mode == null) {
      throw const FormatException('Unsupported game mode');
    }

    final size = _requiredInt(json['size'], fallback: 4, label: 'board size');
    final target =
        _requiredInt(json['target'], fallback: 2048, label: 'target tile');
    final moveLimit = _optionalInt(json['moveLimit'], 'move limit');
    final timeLimitSeconds =
        _optionalInt(json['timeLimitSeconds'], 'time limit');
    final seed = _optionalInt(json['seed'], 'random seed');

    if (size < 3 || size > 8) {
      throw const FormatException('Unsupported board size');
    }
    if (!_isPowerOfTwo(target) || target < 4 || target > 1 << 30) {
      throw const FormatException('Invalid target tile');
    }
    if (moveLimit != null && (moveLimit < 1 || moveLimit > 1000000)) {
      throw const FormatException('Invalid move limit');
    }
    if (timeLimitSeconds != null &&
        (timeLimitSeconds < 1 || timeLimitSeconds > 86400)) {
      throw const FormatException('Invalid time limit');
    }
    if (seed != null && (seed < 0 || seed > 0x7fffffff)) {
      throw const FormatException('Invalid random seed');
    }

    return GameConfig(
      mode: mode,
      size: size,
      target: target,
      moveLimit: moveLimit,
      timeLimitSeconds: timeLimitSeconds,
      seed: seed,
    );
  }

  static int _requiredInt(
    Object? value, {
    required int fallback,
    required String label,
  }) {
    if (value == null) return fallback;
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

  static bool _isPowerOfTwo(int value) =>
      value > 0 && (value & (value - 1)) == 0;
}
