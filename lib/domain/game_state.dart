import 'game_types.dart';

class GameState {
  GameState({
    required this.board,
    required this.config,
    this.score = 0,
    int bestScore = 0,
    this.moves = 0,
    this.totalMerges = 0,
    this.status = GameStatus.playing,
    this.hasAcknowledgedWin = false,
    this.rngState = 0,
    DateTime? startedAt,
  })  : bestScore = bestScore < score ? score : bestScore,
        startedAt = startedAt ?? DateTime.now();

  static const schemaVersion = 1;

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
          for (final row in board) [...row],
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
        'schema': schemaVersion,
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
    final schema = _optionalInt(json['schema'], 'save schema') ?? 0;
    if (schema < 0 || schema > schemaVersion) {
      throw const FormatException('Unsupported save schema');
    }

    final normalized = schema == 0 ? _migrateLegacyV0(json) : json;
    final rawConfig = normalized['config'];
    if (rawConfig is! Map) {
      throw const FormatException('Invalid game configuration');
    }
    final config = GameConfig.fromJson(Map<String, Object?>.from(rawConfig));

    final rawBoard = normalized['board'];
    if (rawBoard is! List || rawBoard.length != config.size) {
      throw const FormatException('Invalid board data');
    }

    final board = <List<int>>[];
    for (final rawRow in rawBoard) {
      if (rawRow is! List || rawRow.length != config.size) {
        throw const FormatException('Invalid board dimensions');
      }
      final row = <int>[];
      for (final rawCell in rawRow) {
        if (rawCell is! num ||
            !rawCell.isFinite ||
            rawCell.toInt() != rawCell) {
          throw const FormatException('Invalid tile value');
        }
        final cell = rawCell.toInt();
        if (!_isValidTile(cell)) {
          throw const FormatException('Invalid tile value');
        }
        row.add(cell);
      }
      board.add(row);
    }

    final score = _nonNegativeInt(normalized['score'], 'score');
    final bestScore = _nonNegativeInt(normalized['bestScore'], 'best score');
    if (bestScore < score) {
      throw const FormatException('Best score cannot be below current score');
    }
    final moves = _nonNegativeInt(normalized['moves'], 'moves');
    final totalMerges = _nonNegativeInt(
      normalized['totalMerges'],
      'total merges',
    );
    final rngState = _nonNegativeInt(normalized['rngState'], 'RNG state');
    if (rngState > 0x7fffffff) {
      throw const FormatException('Invalid RNG state');
    }

    final rawStatus = normalized['status'];
    if (rawStatus != null && rawStatus is! String) {
      throw const FormatException('Invalid game status');
    }
    final statusName = rawStatus as String? ?? GameStatus.playing.name;
    GameStatus? status;
    for (final value in GameStatus.values) {
      if (value.name == statusName) {
        status = value;
        break;
      }
    }
    if (status == null) {
      throw const FormatException('Unsupported game status');
    }

    final rawAcknowledged = normalized['hasAcknowledgedWin'];
    if (rawAcknowledged != null && rawAcknowledged is! bool) {
      throw const FormatException('Invalid win acknowledgement');
    }
    final hasAcknowledgedWin = rawAcknowledged as bool? ?? false;

    final startedAtRaw = normalized['startedAt'];
    if (startedAtRaw != null && startedAtRaw is! String) {
      throw const FormatException('Invalid game start time');
    }
    final startedAt =
        startedAtRaw is String ? DateTime.tryParse(startedAtRaw) : null;
    if (startedAtRaw != null && startedAt == null) {
      throw const FormatException('Invalid game start time');
    }
    if (config.timeLimitSeconds != null && startedAt == null) {
      throw const FormatException('Timed game is missing a valid start time');
    }

    final highestTile = board
        .expand((row) => row)
        .fold(0, (highest, value) => value > highest ? value : highest);
    final reachedTarget = highestTile >= config.target;
    final endless =
        config.mode == GameMode.endless || config.mode == GameMode.zen;
    if (status == GameStatus.won && (endless || !reachedTarget)) {
      throw const FormatException('Inconsistent won game state');
    }
    if (hasAcknowledgedWin && !reachedTarget) {
      throw const FormatException('Invalid win acknowledgement');
    }
    if (status == GameStatus.won && hasAcknowledgedWin) {
      throw const FormatException('Acknowledged win must be playing or lost');
    }
    if (!endless &&
        reachedTarget &&
        !hasAcknowledgedWin &&
        status == GameStatus.playing) {
      throw const FormatException('Unacknowledged target must be won');
    }

    return GameState(
      board: board,
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
  }

  static Map<String, Object?> _migrateLegacyV0(Map<String, Object?> legacy) {
    final rawBoard = legacy['board'];
    final inferredSize = rawBoard is List ? rawBoard.length : 4;
    final legacyConfig = legacy['config'];
    final config = legacyConfig is Map
        ? Map<String, Object?>.from(legacyConfig)
        : <String, Object?>{
            'mode': legacy['mode'] ?? GameMode.classic.name,
            'size': legacy['size'] ?? inferredSize,
            'target': legacy['target'] ?? 2048,
            'moveLimit': legacy['moveLimit'],
            'timeLimitSeconds': legacy['timeLimitSeconds'],
            'seed': legacy['seed'],
          };
    final score = legacy['score'] ?? 0;

    return <String, Object?>{
      'schema': schemaVersion,
      'board': rawBoard,
      'config': config,
      'score': score,
      'bestScore': legacy['bestScore'] ?? score,
      'moves': legacy['moves'] ?? 0,
      'totalMerges': legacy['totalMerges'] ?? 0,
      'status': legacy['status'] ?? GameStatus.playing.name,
      'hasAcknowledgedWin': legacy['hasAcknowledgedWin'] ?? false,
      'rngState': legacy['rngState'] ?? 0,
      'startedAt': legacy['startedAt'],
    };
  }

  static int? _optionalInt(Object? value, String label) {
    if (value == null) return null;
    if (value is! num || !value.isFinite || value.toInt() != value) {
      throw FormatException('Invalid $label');
    }
    return value.toInt();
  }

  static int _nonNegativeInt(Object? value, String label) {
    if (value == null) return 0;
    final parsed = _optionalInt(value, label)!;
    if (parsed < 0) {
      throw FormatException('Invalid $label');
    }
    return parsed;
  }

  static bool _isValidTile(int value) {
    if (value == 0) return true;
    if (value < 2 || value > 1 << 30) return false;
    return (value & (value - 1)) == 0;
  }
}
