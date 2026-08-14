import 'game_types.dart';

class GameState {
  GameState({
    required this.board,
    required this.config,
    this.score = 0,
    this.bestScore = 0,
    this.moves = 0,
    this.totalMerges = 0,
    this.status = GameStatus.playing,
    this.hasAcknowledgedWin = false,
    this.rngState = 0,
    DateTime? startedAt,
  }) : startedAt = startedAt ?? DateTime.now();

  final List<List<int>> board;
  final GameConfig config;
  int score;
  int bestScore;
  int moves;
  int totalMerges;
  GameStatus status;
  bool hasAcknowledgedWin;
  int rngState;
  final DateTime startedAt;

  int get highestTile =>
      board.expand((row) => row).fold(0, (a, b) => a > b ? a : b);

  GameState copy() => GameState(
        board: [
          for (final row in board) [...row]
        ],
        config: config,
        score: score,
        bestScore: bestScore,
        moves: moves,
        totalMerges: totalMerges,
        status: status,
        hasAcknowledgedWin: hasAcknowledgedWin,
        rngState: rngState,
        startedAt: startedAt,
      );

  Map<String, Object?> toJson() => {
        'schema': 1,
        'board': board,
        'config': config.toJson(),
        'score': score,
        'bestScore': bestScore,
        'moves': moves,
        'totalMerges': totalMerges,
        'status': status.name,
        'hasAcknowledgedWin': hasAcknowledgedWin,
        'rngState': rngState,
        'startedAt': startedAt.toIso8601String(),
      };

  factory GameState.fromJson(Map<String, Object?> json) {
    final config = GameConfig.fromJson(
      Map<String, Object?>.from(json['config'] as Map? ?? {}),
    );
    final rawBoard = json['board'] as List?;
    if (rawBoard == null || rawBoard.length != config.size) {
      throw const FormatException('Invalid board data');
    }
    final board = rawBoard
        .map(
          (row) => (row as List).map((cell) => (cell as num).toInt()).toList(),
        )
        .toList();
    if (board.any((row) => row.length != config.size)) {
      throw const FormatException('Invalid board dimensions');
    }
    final statusName = json['status'] as String? ?? GameStatus.playing.name;
    final status = GameStatus.values.firstWhere(
      (value) => value.name == statusName,
      orElse: () => GameStatus.playing,
    );
    return GameState(
      board: board,
      config: config,
      score: (json['score'] as num?)?.toInt() ?? 0,
      bestScore: (json['bestScore'] as num?)?.toInt() ?? 0,
      moves: (json['moves'] as num?)?.toInt() ?? 0,
      totalMerges: (json['totalMerges'] as num?)?.toInt() ?? 0,
      status: status,
      hasAcknowledgedWin: json['hasAcknowledgedWin'] as bool? ?? false,
      rngState: (json['rngState'] as num?)?.toInt() ?? 0,
      startedAt: DateTime.tryParse(json['startedAt'] as String? ?? ''),
    );
  }
}
