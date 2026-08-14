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
    return DailyRecord(
      seed: state.config.seed!,
      score: state.score,
      moves: state.moves,
      highestTile: state.highestTile,
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
    final seed = (json['seed'] as num?)?.toInt();
    if (seed == null) throw const FormatException('Missing daily seed');
    return DailyRecord(
      seed: seed,
      score: (json['score'] as num?)?.toInt() ?? 0,
      moves: (json['moves'] as num?)?.toInt() ?? 0,
      highestTile: (json['highestTile'] as num?)?.toInt() ?? 0,
      completed: json['completed'] as bool? ?? false,
      won: json['won'] as bool? ?? false,
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
    );
  }
}
