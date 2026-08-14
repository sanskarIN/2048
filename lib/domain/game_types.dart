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
      GameMode.quick => const GameConfig(mode: GameMode.quick, size: 3, target: 512),
      GameMode.extended => const GameConfig(mode: GameMode.extended, size: 5),
      GameMode.challenge => const GameConfig(mode: GameMode.challenge, size: 6, target: 4096),
      GameMode.endless => const GameConfig(mode: GameMode.endless, size: 4, target: 2048),
      GameMode.target => GameConfig(mode: GameMode.target, size: 4, target: target ?? 4096),
      GameMode.timeChallenge => const GameConfig(mode: GameMode.timeChallenge, size: 4, timeLimitSeconds: 180),
      GameMode.moveLimit => const GameConfig(mode: GameMode.moveLimit, size: 4, moveLimit: 250),
      GameMode.daily => GameConfig(mode: GameMode.daily, size: 4, seed: _dailySeed()),
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
    final modeName = json['mode'] as String? ?? GameMode.classic.name;
    final mode = GameMode.values.firstWhere(
      (value) => value.name == modeName,
      orElse: () => GameMode.classic,
    );
    return GameConfig(
      mode: mode,
      size: (json['size'] as num?)?.toInt() ?? 4,
      target: (json['target'] as num?)?.toInt() ?? 2048,
      moveLimit: (json['moveLimit'] as num?)?.toInt(),
      timeLimitSeconds: (json['timeLimitSeconds'] as num?)?.toInt(),
      seed: (json['seed'] as num?)?.toInt(),
    );
  }
}
