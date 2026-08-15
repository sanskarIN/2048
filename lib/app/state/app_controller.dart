import 'package:flutter/material.dart';

import '../../core/localization/nova_localizations.dart';
import '../../core/theme/nova_theme.dart';
import '../../data/local_store.dart';
import '../../domain/daily_record.dart';
import '../../domain/game_engine.dart';
import '../../domain/game_state.dart';
import '../../domain/game_types.dart';

class AppSettings {
  AppSettings({
    this.themeMode = ThemeMode.system,
    this.language = AppLanguage.system,
    this.palette = NovaPalette.classic,
    this.highContrast = false,
    this.reducedMotion = false,
    this.soundEnabled = true,
    this.hapticsEnabled = true,
    this.confirmRestart = true,
  });

  ThemeMode themeMode;
  AppLanguage language;
  NovaPalette palette;
  bool highContrast;
  bool reducedMotion;
  bool soundEnabled;
  bool hapticsEnabled;
  bool confirmRestart;

  Map<String, Object?> toJson() => {
        'themeMode': themeMode.name,
        'language': language.storageValue,
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
      language: AppLanguageX.parse(json['language']),
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

class ModeRecord {
  ModeRecord({
    this.bestScore = 0,
    this.highestTile = 0,
    this.bestScoreBoardSize,
    this.bestScoreTarget,
  });

  int bestScore;
  int highestTile;
  int? bestScoreBoardSize;
  int? bestScoreTarget;

  bool get hasProgress => bestScore > 0 || highestTile > 0;

  Map<String, Object?> toJson() => {
        'bestScore': bestScore,
        'highestTile': highestTile,
        'bestScoreBoardSize': bestScoreBoardSize,
        'bestScoreTarget': bestScoreTarget,
      };

  factory ModeRecord.fromJson(Map<String, Object?> json) {
    final bestScore = PlayerStats._nonNegativeInt(json['bestScore']);
    final highestTile = PlayerStats._validTileOrZero(json['highestTile']);
    final boardSize = _validBoardSizeOrNull(json['bestScoreBoardSize']);
    final target = _validTargetOrNull(json['bestScoreTarget']);
    return ModeRecord(
      bestScore: bestScore,
      highestTile: highestTile,
      bestScoreBoardSize: bestScore > 0 ? boardSize : null,
      bestScoreTarget: bestScore > 0 ? target : null,
    );
  }

  static int? _validBoardSizeOrNull(Object? value) {
    final size = PlayerStats._nonNegativeInt(value);
    return size >= 3 && size <= 8 ? size : null;
  }

  static int? _validTargetOrNull(Object? value) {
    final target = PlayerStats._validTileOrZero(value);
    return target >= 4 ? target : null;
  }
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
  final Map<GameMode, ModeRecord> modeRecords = {};

  double get winRate => gamesPlayed == 0 ? 0 : gamesWon / gamesPlayed;

  ModeRecord recordFor(GameMode mode) =>
      modeRecords.putIfAbsent(mode, ModeRecord.new);

  ModeRecord? existingRecordFor(GameMode mode) => modeRecords[mode];

  Map<String, Object?> toJson() => {
        'gamesPlayed': gamesPlayed,
        'gamesWon': gamesWon,
        'bestScore': bestScore,
        'highestTile': highestTile,
        'totalMoves': totalMoves,
        'totalMerges': totalMerges,
        'currentStreak': currentStreak,
        'bestStreak': bestStreak,
        'modeRecords': {
          for (final entry in modeRecords.entries)
            if (entry.value.hasProgress) entry.key.name: entry.value.toJson(),
        },
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
    final rawModeRecords = json['modeRecords'];
    if (rawModeRecords is Map) {
      for (final mode in GameMode.values) {
        final rawRecord = rawModeRecords[mode.name];
        if (rawRecord is! Map) continue;
        final normalized = <String, Object?>{};
        for (final entry in rawRecord.entries) {
          final key = entry.key;
          if (key is String) normalized[key] = entry.value;
        }
        final record = ModeRecord.fromJson(normalized);
        if (record.hasProgress) stats.modeRecords[mode] = record;
      }
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
  bool _currentGameUnranked = false;

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
  bool get currentGameIsUnranked => game != null && _currentGameUnranked;

  Future<void> initialize() async {
    settings = AppSettings.fromJson(await store.loadSettings());
    stats = PlayerStats.fromJson(await store.loadStats());
    _restoreAchievements(await store.loadAchievements());
    dailyHistory
      ..clear()
      ..addAll(await store.loadDailyHistory());
    game = await store.loadGame();
    _currentGameUnranked =
        game != null && await store.loadCurrentGameUnranked();
    var repairedSession = false;
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
      _sessionCounted = !_currentGameUnranked;
      _winCounted = _currentGameUnranked ||
          current.hasAcknowledgedWin ||
          current.status == GameStatus.won;
      final previousStatus = current.status;
      final previousStreak = stats.currentStreak;
      _engine!.refreshStatus(current);
      if (!_currentGameUnranked) {
        if (_updateModeRecord(current)) repairedSession = true;
        _applyTerminalStats(current);
      }
      if (current.status != previousStatus) {
        if (!_currentGameUnranked) {
          _updateDailyRecord(current);
        }
        repairedSession = true;
      }
      if (!_currentGameUnranked && stats.currentStreak != previousStreak) {
        repairedSession = true;
      }
    }
    _unlockAchievements();
    if (repairedSession) await _persist();
  }

  Future<void> newGame(GameConfig config) async {
    if (_moveInProgress) return;
    _engine = GameEngine(config: config);
    game = _engine!.createGame(bestScore: stats.bestScore);
    _undo.clear();
    _currentGameUnranked = false;
    _sessionCounted = true;
    _winCounted = false;
    stats.gamesPlayed += 1;
    _updateModeRecord(game!);
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
      if (!_currentGameUnranked) {
        stats.totalMoves += 1;
        stats.totalMerges += outcome.merges;
        stats.bestScore = current.bestScore > stats.bestScore
            ? current.bestScore
            : stats.bestScore;
        stats.highestTile = current.highestTile > stats.highestTile
            ? current.highestTile
            : stats.highestTile;
        _updateModeRecord(current);
        _applyTerminalStats(current);
        _updateDailyRecord(current);
        _unlockAchievements();
      }
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
    if (!_currentGameUnranked) _updateDailyRecord(game!);
    await store.saveGame(game!);
    await store.saveUndoHistory(_undo);
    if (!_currentGameUnranked) {
      await store.saveDailyHistory(dailyHistory);
    }
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
      if (!_currentGameUnranked) {
        _updateModeRecord(current);
        _applyTerminalStats(current);
        _updateDailyRecord(current);
        _unlockAchievements();
      }
      await _persist();
      notifyListeners();
    }
  }

  Future<void> continueAfterWin() async {
    if (game == null || _moveInProgress) return;
    game!.hasAcknowledgedWin = true;
    game!.status = GameStatus.playing;
    _winCounted = true;
    if (!_currentGameUnranked) {
      _updateDailyRecord(game!);
      _unlockAchievements();
    }
    await _persist();
    notifyListeners();
  }

  Future<void> importGameBackup(GameState imported) async {
    if (_moveInProgress) return;
    final restored = imported.copy();
    restored.bestScore =
        restored.score > stats.bestScore ? restored.score : stats.bestScore;
    _engine = GameEngine(config: restored.config);
    _engine!.refreshStatus(restored);
    game = restored;
    _undo.clear();
    _currentGameUnranked = true;
    _sessionCounted = false;
    _winCounted = true;
    await store.saveGame(restored);
    await store.saveUndoHistory(_undo);
    await store.saveCurrentGameUnranked(true);
    notifyListeners();
  }

  Future<void> clearCurrentGame() async {
    if (_moveInProgress) return;
    game = null;
    _engine = null;
    _undo.clear();
    _currentGameUnranked = false;
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
    _currentGameUnranked = false;
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
    if (current != null && _currentGameUnranked) {
      current.bestScore = current.score;
      for (final snapshot in _undo) {
        snapshot.bestScore =
            snapshot.score > current.score ? snapshot.score : current.score;
      }
      _sessionCounted = false;
      _winCounted = true;
      await store.saveGame(current);
      await store.saveUndoHistory(_undo);
      await store.saveStats(stats.toJson());
      notifyListeners();
      return;
    }
    if (current != null) {
      current.bestScore = current.score;
      for (final snapshot in _undo) {
        snapshot.bestScore =
            snapshot.score > current.score ? snapshot.score : current.score;
      }
      stats.gamesPlayed = 1;
      stats.bestScore = current.score;
      stats.highestTile = current.highestTile;
      _updateModeRecord(current);
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
      await store.saveUndoHistory(_undo);
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
    if (game != null) {
      await store.saveGame(game!);
      await store.saveCurrentGameUnranked(_currentGameUnranked);
    }
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

  bool _updateModeRecord(GameState state) {
    final mode = state.config.mode;
    final existing = stats.existingRecordFor(mode);
    final record = existing ?? ModeRecord();
    var changed = false;

    if (state.score > record.bestScore) {
      record.bestScore = state.score;
      record.bestScoreBoardSize = state.config.size;
      record.bestScoreTarget = state.config.target;
      changed = true;
    } else if (state.score > 0 && state.score == record.bestScore) {
      if (record.bestScoreBoardSize == null) {
        record.bestScoreBoardSize = state.config.size;
        changed = true;
      }
      if (record.bestScoreTarget == null) {
        record.bestScoreTarget = state.config.target;
        changed = true;
      }
    }

    if (state.highestTile > record.highestTile) {
      record.highestTile = state.highestTile;
      changed = true;
    }

    if (existing == null && record.hasProgress) {
      stats.modeRecords[mode] = record;
      changed = true;
    }
    return changed;
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
