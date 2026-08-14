import 'package:flutter/material.dart';

import '../../core/theme/nova_theme.dart';
import '../../data/local_store.dart';
import '../../domain/daily_record.dart';
import '../../domain/game_engine.dart';
import '../../domain/game_state.dart';
import '../../domain/game_types.dart';

class AppSettings {
  AppSettings({
    this.themeMode = ThemeMode.system,
    this.palette = NovaPalette.classic,
    this.highContrast = false,
    this.reducedMotion = false,
    this.soundEnabled = true,
    this.hapticsEnabled = true,
    this.confirmRestart = true,
  });

  ThemeMode themeMode;
  NovaPalette palette;
  bool highContrast;
  bool reducedMotion;
  bool soundEnabled;
  bool hapticsEnabled;
  bool confirmRestart;

  Map<String, Object?> toJson() => {
        'themeMode': themeMode.name,
        'palette': palette.name,
        'highContrast': highContrast,
        'reducedMotion': reducedMotion,
        'soundEnabled': soundEnabled,
        'hapticsEnabled': hapticsEnabled,
        'confirmRestart': confirmRestart,
      };

  factory AppSettings.fromJson(Map<String, Object?> json) {
    final themeName = json['themeMode'];
    final theme = ThemeMode.values.firstWhere(
      (value) => themeName is String && value.name == themeName,
      orElse: () => ThemeMode.system,
    );
    final paletteName = json['palette'];
    final palette = NovaPalette.values.firstWhere(
      (value) => paletteName is String && value.name == paletteName,
      orElse: () => NovaPalette.classic,
    );
    return AppSettings(
      themeMode: theme,
      palette: palette,
      highContrast: _boolValue(json['highContrast'], false),
      reducedMotion: _boolValue(json['reducedMotion'], false),
      soundEnabled: _boolValue(json['soundEnabled'], true),
      hapticsEnabled: _boolValue(json['hapticsEnabled'], true),
      confirmRestart: _boolValue(json['confirmRestart'], true),
    );
  }

  static bool _boolValue(Object? value, bool fallback) =>
      value is bool ? value : fallback;
}

class PlayerStats {
  PlayerStats();

  int gamesPlayed = 0;
  int gamesWon = 0;
  int bestScore = 0;
  int highestTile = 0;
  int totalMoves = 0;
  int totalMerges = 0;
  int currentStreak = 0;
  int bestStreak = 0;

  double get winRate => gamesPlayed == 0 ? 0 : gamesWon / gamesPlayed;

  Map<String, Object?> toJson() => {
        'gamesPlayed': gamesPlayed,
        'gamesWon': gamesWon,
        'bestScore': bestScore,
        'highestTile': highestTile,
        'totalMoves': totalMoves,
        'totalMerges': totalMerges,
        'currentStreak': currentStreak,
        'bestStreak': bestStreak,
      };

  factory PlayerStats.fromJson(Map<String, Object?> json) {
    final stats = PlayerStats();
    stats.gamesPlayed = _nonNegativeInt(json['gamesPlayed']);
    final parsedWins = _nonNegativeInt(json['gamesWon']);
    stats.gamesWon =
        parsedWins > stats.gamesPlayed ? stats.gamesPlayed : parsedWins;
    stats.bestScore = _nonNegativeInt(json['bestScore']);
    stats.highestTile = _validTileOrZero(json['highestTile']);
    stats.totalMoves = _nonNegativeInt(json['totalMoves']);
    stats.totalMerges = _nonNegativeInt(json['totalMerges']);
    stats.currentStreak = _nonNegativeInt(json['currentStreak']);
    stats.bestStreak = _nonNegativeInt(json['bestStreak']);
    if (stats.bestStreak < stats.currentStreak) {
      stats.bestStreak = stats.currentStreak;
    }
    return stats;
  }

  static int _nonNegativeInt(Object? value) {
    if (value is! num ||
        !value.isFinite ||
        value < 0 ||
        value.toInt() != value) {
      return 0;
    }
    return value.toInt();
  }

  static int _validTileOrZero(Object? value) {
    final tile = _nonNegativeInt(value);
    if (tile == 0) return 0;
    if (tile < 2 || tile > 1 << 30 || (tile & (tile - 1)) != 0) {
      return 0;
    }
    return tile;
  }
}

enum AchievementMetric { merges, highestTile, score, wins, dailyWins }

class Achievement {
  Achievement(
    this.id,
    this.title,
    this.description,
    this.metric,
    this.threshold, {
    this.unlockedAt,
  });

  final String id;
  final String title;
  final String description;
  final AchievementMetric metric;
  final int threshold;
  DateTime? unlockedAt;

  bool get unlocked => unlockedAt != null;
}

class AppController extends ChangeNotifier {
  AppController({required this.store});

  final LocalStore store;
  late AppSettings settings;
  late PlayerStats stats;
  GameState? game;
  GameEngine? _engine;
  final List<GameState> _undo = [];
  final List<DailyRecord> dailyHistory = [];
  bool _sessionCounted = false;
  bool _winCounted = false;
  bool _moveInProgress = false;

  final List<Achievement> achievements = [
    Achievement(
      'first_merge',
      'First Merge',
      'Merge your first pair of tiles.',
      AchievementMetric.merges,
      1,
    ),
    Achievement(
      'tile_128',
      'Nova 128',
      'Reach the 128 tile.',
      AchievementMetric.highestTile,
      128,
    ),
    Achievement(
      'tile_256',
      'Nova 256',
      'Reach the 256 tile.',
      AchievementMetric.highestTile,
      256,
    ),
    Achievement(
      'tile_512',
      'Nova 512',
      'Reach the 512 tile.',
      AchievementMetric.highestTile,
      512,
    ),
    Achievement(
      'tile_1024',
      'Nova 1024',
      'Reach the 1024 tile.',
      AchievementMetric.highestTile,
      1024,
    ),
    Achievement(
      'tile_2048',
      'Nova Master',
      'Reach the 2048 tile.',
      AchievementMetric.highestTile,
      2048,
    ),
    Achievement(
      'tile_4096',
      'Beyond Nova',
      'Reach the 4096 tile.',
      AchievementMetric.highestTile,
      4096,
    ),
    Achievement(
      'tile_8192',
      'Deep Space',
      'Reach the 8192 tile.',
      AchievementMetric.highestTile,
      8192,
    ),
    Achievement(
      'score_10000',
      'Five Digits',
      'Score at least 10,000 points in one game.',
      AchievementMetric.score,
      10000,
    ),
    Achievement(
      'score_50000',
      'Score Supernova',
      'Score at least 50,000 points in one game.',
      AchievementMetric.score,
      50000,
    ),
    Achievement(
      'win_1',
      'First Victory',
      'Reach a game target for the first time.',
      AchievementMetric.wins,
      1,
    ),
    Achievement(
      'win_5',
      'Nova Streaker',
      'Win five games.',
      AchievementMetric.wins,
      5,
    ),
    Achievement(
      'daily_1',
      'Daily Explorer',
      'Win a Daily Challenge.',
      AchievementMetric.dailyWins,
      1,
    ),
    Achievement(
      'daily_7',
      'Daily Voyager',
      'Win seven Daily Challenges.',
      AchievementMetric.dailyWins,
      7,
    ),
  ];

  bool get hasGame => game != null;
  bool get canUndo => !_moveInProgress && _undo.isNotEmpty;

  Future<void> initialize() async {
    settings = AppSettings.fromJson(await store.loadSettings());
    stats = PlayerStats.fromJson(await store.loadStats());
    _restoreAchievements(await store.loadAchievements());
    dailyHistory
      ..clear()
      ..addAll(await store.loadDailyHistory());
    game = await store.loadGame();
    if (game != null) {
      _engine = GameEngine(config: game!.config);
      final restoredUndo = await store.loadUndoHistory();
      final current = game!;
      _undo
        ..clear()
        ..addAll(
          restoredUndo.where(
            (snapshot) => _belongsToCurrentSession(snapshot, current),
          ),
        );
      if (_undo.length != restoredUndo.length) {
        await store.saveUndoHistory(_undo);
      }
      _sessionCounted = true;
      _winCounted = game!.hasAcknowledgedWin || game!.status == GameStatus.won;
    }
    _unlockAchievements();
  }

  Future<void> newGame(GameConfig config) async {
    if (_moveInProgress) return;
    _engine = GameEngine(config: config);
    game = _engine!.createGame(bestScore: stats.bestScore);
    _undo.clear();
    _sessionCounted = true;
    _winCounted = false;
    stats.gamesPlayed += 1;
    _updateDailyRecord(game!);
    await _persist();
    notifyListeners();
  }

  Future<MoveOutcome?> move(Direction direction) async {
    final current = game;
    final engine = _engine;
    if (current == null || engine == null || _moveInProgress) return null;
    _moveInProgress = true;
    try {
      final snapshot = current.copy();
      final outcome = engine.move(current, direction);
      if (!outcome.changed) {
        notifyListeners();
        return outcome;
      }
      _undo.add(snapshot);
      if (_undo.length > 50) _undo.removeAt(0);
      stats.totalMoves += 1;
      stats.totalMerges += outcome.merges;
      stats.bestScore = current.bestScore > stats.bestScore
          ? current.bestScore
          : stats.bestScore;
      stats.highestTile = current.highestTile > stats.highestTile
          ? current.highestTile
          : stats.highestTile;
      _applyTerminalStats(current);
      _updateDailyRecord(current);
      _unlockAchievements();
      await _persist();
      notifyListeners();
      return outcome;
    } finally {
      _moveInProgress = false;
    }
  }

  Future<void> undo() async {
    if (_moveInProgress || _undo.isEmpty || game == null) return;
    final restored = _undo.removeLast();
    if (restored.bestScore < stats.bestScore) {
      restored.bestScore = stats.bestScore;
    }
    game = restored;
    _engine = GameEngine(config: game!.config);
    _updateDailyRecord(game!);
    await store.saveGame(game!);
    await store.saveUndoHistory(_undo);
    await store.saveDailyHistory(dailyHistory);
    notifyListeners();
  }

  Direction? hint() =>
      game == null || _engine == null ? null : _engine!.hint(game!);

  DailyRecord? dailyRecordFor(int seed) {
    for (final record in dailyHistory) {
      if (record.seed == seed) return record;
    }
    return null;
  }

  int achievementProgress(Achievement achievement) {
    return switch (achievement.metric) {
      AchievementMetric.merges => stats.totalMerges,
      AchievementMetric.highestTile => stats.highestTile,
      AchievementMetric.score => stats.bestScore,
      AchievementMetric.wins => stats.gamesWon,
      AchievementMetric.dailyWins =>
        dailyHistory.where((record) => record.won).length,
    };
  }

  Future<void> refreshChallengeStatus() async {
    final current = game;
    final engine = _engine;
    if (current == null || engine == null || _moveInProgress) return;
    final before = current.status;
    engine.refreshStatus(current);
    if (before != current.status) {
      _applyTerminalStats(current);
      _updateDailyRecord(current);
      _unlockAchievements();
      await _persist();
      notifyListeners();
    }
  }

  Future<void> continueAfterWin() async {
    if (game == null || _moveInProgress) return;
    game!.hasAcknowledgedWin = true;
    game!.status = GameStatus.playing;
    _winCounted = true;
    _updateDailyRecord(game!);
    _unlockAchievements();
    await _persist();
    notifyListeners();
  }

  Future<void> clearCurrentGame() async {
    if (_moveInProgress) return;
    game = null;
    _engine = null;
    _undo.clear();
    await store.clearGame();
    notifyListeners();
  }

  Future<void> clearAllData() async {
    if (_moveInProgress) return;
    game = null;
    _engine = null;
    _undo.clear();
    dailyHistory.clear();
    settings = AppSettings();
    stats = PlayerStats();
    _sessionCounted = false;
    _winCounted = false;
    for (final achievement in achievements) {
      achievement.unlockedAt = null;
    }
    await store.clearAll();
    notifyListeners();
  }

  Future<void> updateSettings(void Function(AppSettings value) update) async {
    update(settings);
    await store.saveSettings(settings.toJson());
    notifyListeners();
  }

  Future<void> resetStats() async {
    stats = PlayerStats();
    final current = game;
    if (current != null) {
      current.bestScore = current.score;
      stats.gamesPlayed = 1;
      stats.bestScore = current.score;
      stats.highestTile = current.highestTile;
      final alreadyWon = _winCounted ||
          current.status == GameStatus.won ||
          current.hasAcknowledgedWin;
      if (alreadyWon) {
        stats.gamesWon = 1;
        stats.currentStreak = 1;
        stats.bestStreak = 1;
        _winCounted = true;
      } else {
        _winCounted = false;
      }
      _sessionCounted = current.status != GameStatus.lost;
      await store.saveGame(current);
    } else {
      _sessionCounted = false;
      _winCounted = false;
    }
    await store.saveStats(stats.toJson());
    notifyListeners();
  }

  Future<void> resetAchievements() async {
    for (final achievement in achievements) {
      achievement.unlockedAt = null;
    }
    await _saveAchievements();
    notifyListeners();
  }

  Future<void> _persist() async {
    if (game != null) await store.saveGame(game!);
    await store.saveUndoHistory(_undo);
    await store.saveStats(stats.toJson());
    await store.saveDailyHistory(dailyHistory);
    await _saveAchievements();
  }

  bool _belongsToCurrentSession(GameState snapshot, GameState current) {
    final candidate = snapshot.config;
    final active = current.config;
    return snapshot.startedAt.isAtSameMomentAs(current.startedAt) &&
        candidate.mode == active.mode &&
        candidate.size == active.size &&
        candidate.target == active.target &&
        candidate.moveLimit == active.moveLimit &&
        candidate.timeLimitSeconds == active.timeLimitSeconds &&
        candidate.seed == active.seed &&
        snapshot.moves <= current.moves &&
        snapshot.score <= current.score &&
        snapshot.totalMerges <= current.totalMerges;
  }

  void _applyTerminalStats(GameState state) {
    if (state.status == GameStatus.won && !_winCounted) {
      stats.gamesWon += 1;
      stats.currentStreak += 1;
      if (stats.currentStreak > stats.bestStreak) {
        stats.bestStreak = stats.currentStreak;
      }
      _winCounted = true;
    }
    if (state.status == GameStatus.lost && _sessionCounted && !_winCounted) {
      stats.currentStreak = 0;
      _sessionCounted = false;
    }
  }

  void _updateDailyRecord(GameState state) {
    if (state.config.mode != GameMode.daily || state.config.seed == null) {
      return;
    }
    final seed = state.config.seed!;
    final index = dailyHistory.indexWhere((record) => record.seed == seed);
    final previous = index >= 0 ? dailyHistory[index] : null;
    final updated = DailyRecord.fromState(state, previous: previous);
    if (index >= 0) {
      dailyHistory[index] = updated;
    } else {
      dailyHistory.add(updated);
    }
    dailyHistory.sort((a, b) => b.seed.compareTo(a.seed));
    if (dailyHistory.length > 60) {
      dailyHistory.removeRange(60, dailyHistory.length);
    }
  }

  void _unlockAchievements() {
    final now = DateTime.now();
    for (final achievement in achievements) {
      if (achievement.unlocked) continue;
      if (achievementProgress(achievement) >= achievement.threshold) {
        achievement.unlockedAt = now;
      }
    }
  }

  void _restoreAchievements(Map<String, Object?> raw) {
    for (final achievement in achievements) {
      final value = raw[achievement.id];
      achievement.unlockedAt =
          value is String ? DateTime.tryParse(value) : null;
    }
  }

  Future<void> _saveAchievements() {
    return store.saveAchievements({
      for (final item in achievements)
        item.id: item.unlockedAt?.toIso8601String(),
    });
  }
}
