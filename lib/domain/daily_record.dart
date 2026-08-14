import 'game_state.dart';
import 'game_types.dart';

class DailyRecord {
  const DailyRecord({
    required this.seed,
    required this.score,
    required this.moves,
    required this.highestTile,
    required this.completed,
    required this.won,
    required this.updatedAt,
  });

  final int seed;
  final int score;
  final int moves;
  final int highestTile;
  final bool completed;
  final bool won;
  final DateTime updatedAt;

  factory DailyRecord.fromState(GameState state, {DailyRecord? previous}) {
    if (state.config.mode != GameMode.daily || state.config.seed == null) {
      throw ArgumentError('DailyRecord requires a seeded daily game.');
    }
    final reachedTarget = state.highestTile >= state.config.target;
    final won = previous?.won == true || reachedTarget;
    final completed =
        previous?.completed == true || won || state.status == GameStatus.lost;
    final isBestScore = previous == null || state.score >= previous.score;
    return DailyRecord(
      seed: state.config.seed!,
      score: isBestScore ? state.score : previous.score,
      moves: isBestScore ? state.moves : previous.moves,
      highestTile: previous == null || state.highestTile > previous.highestTile
          ? state.highestTile
          : previous.highestTile,
      completed: completed,
      won: won,
      updatedAt: DateTime.now().toUtc(),
    );
  }

  Map<String, Object?> toJson() => {
        'seed': seed,
        'score': score,
        'moves': moves,
        'highestTile': highestTile,
        'completed': completed,
        'won': won,
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory DailyRecord.fromJson(Map<String, Object?> json) {
    final seed = _requiredNonNegativeInt(json['seed'], 'daily seed');
    if (!_isValidDailySeed(seed)) {
      throw const FormatException('Invalid daily seed');
    }
    final score = _optionalNonNegativeInt(json['score'], 'daily score');
    final moves = _optionalNonNegativeInt(json['moves'], 'daily moves');
    final highestTile =
        _optionalNonNegativeInt(json['highestTile'], 'daily highest tile');
    if (!_isValidTile(highestTile)) {
      throw const FormatException('Invalid daily highest tile');
    }

    final rawCompleted = json['completed'];
    if (rawCompleted != null && rawCompleted is! bool) {
      throw const FormatException('Invalid daily completion state');
    }
    final rawWon = json['won'];
    if (rawWon != null && rawWon is! bool) {
      throw const FormatException('Invalid daily win state');
    }
    final won = rawWon as bool? ?? false;
    final completed = (rawCompleted as bool? ?? false) || won;

    final rawUpdatedAt = json['updatedAt'];
    if (rawUpdatedAt != null && rawUpdatedAt is! String) {
      throw const FormatException('Invalid daily update time');
    }
    final updatedAt = rawUpdatedAt is String
        ? DateTime.tryParse(rawUpdatedAt)?.toUtc()
        : DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
    if (updatedAt == null) {
      throw const FormatException('Invalid daily update time');
    }

    return DailyRecord(
      seed: seed,
      score: score,
      moves: moves,
      highestTile: highestTile,
      completed: completed,
      won: won,
      updatedAt: updatedAt,
    );
  }

  static int _requiredNonNegativeInt(Object? value, String label) {
    if (value == null) throw FormatException('Missing $label');
    return _checkedNonNegativeInt(value, label);
  }

  static int _optionalNonNegativeInt(Object? value, String label) {
    if (value == null) return 0;
    return _checkedNonNegativeInt(value, label);
  }

  static int _checkedNonNegativeInt(Object value, String label) {
    if (value is! num ||
        !value.isFinite ||
        value.toInt() != value ||
        value < 0) {
      throw FormatException('Invalid $label');
    }
    return value.toInt();
  }

  static bool _isValidDailySeed(int seed) {
    final year = seed ~/ 10000;
    final month = (seed ~/ 100) % 100;
    final day = seed % 100;
    if (year < 1 || year > 9999 || month < 1 || month > 12 || day < 1) {
      return false;
    }
    try {
      final date = DateTime.utc(year, month, day);
      return date.year == year && date.month == month && date.day == day;
    } on ArgumentError {
      return false;
    }
  }

  static bool _isValidTile(int value) {
    if (value == 0) return true;
    if (value < 2 || value > 1 << 30) return false;
    return (value & (value - 1)) == 0;
  }
}
