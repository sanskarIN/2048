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
    final themeName = json['themeMode'] as String? ?? ThemeMode.system.name;
    final theme = ThemeMode.values.firstWhere(
      (value) => value.name == themeName,
      orElse: () => ThemeMode.system,
    );
    final paletteName = json['palette'] as String? ?? NovaPalette.classic.name;
    final palette = NovaPalette.values.firstWhere(
      (value) => value.name == paletteName,
      orElse: () => NovaPalette.classic,
    );
    return AppSettings(
      themeMode: theme,
      palette: palette,
      highContrast: json['highContrast'] as bool? ?? false,
      reducedMotion: json['reducedMotion'] as bool? ?? false,
      soundEnabled: json['soundEnabled'] as bool? ?? true,
      hapticsEnabled: json['hapticsEnabled'] as bool? ?? true,
      confirmRestart: json['confirmRestart'] as bool? ?? true,
    );
  }
}

class PlayerStats {
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
    stats.gamesPlayed = (json['gamesPlayed'] as num?)?.toInt() ?? 0;
    stats.gamesWon = (json['gamesWon'] as num?)?.toInt() ?? 0;
    stats.bestScore = (json['bestScore'] as num?)?.toInt() ?? 0;
    stats.highestTile = (json['highestTile'] as num?)?.toInt() ?? 0;
    stats.totalMoves = (json['totalMoves'] as num?)?.toInt() ?? 0;
    stats.totalMerges = (json['totalMerges'] as num?)?.toInt() ?? 0;
    stats.currentStreak = (json['currentStreak'] as num?)?.toInt() ?? 0;
    stats.bestStreak = (json['bestStreak'] as num?)?.toInt() ?? 0;
    return stats;
  }
}

class Achievement {
  Achievement(
    this.id,
    this.title,
    this.description,
    this.threshold, {
    this.unlockedAt,
  });

  final String id;
  final String title;
  final String description;
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

  final List<Achievement> achievements = [
    Achievement(
      'first_merge',
      'First Merge',
      'Merge your first pair of tiles.',
      1,
    ),
    Achievement('tile_128', 'Nova 128', 'Reach the 128 tile.', 128),
    Achievement('tile_512', 'Nova 512', 'Reach the 512 tile.', 512),
    Achievement('tile_2048', 'Nova Master', 'Reach the 2048 tile.', 2048),
    Achievement('tile_4096', 'Beyond Nova', 'Reach the 4096 tile.', 4096),
  ];

  bool get hasGame => game != null;
  bool get canUndo => _undo.isNotEmpty;

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
      _undo
        ..clear()
        ..addAll(await store.loadUndoHistory());
      _sessionCounted = true;
      _winCounted = game!.hasAcknowledgedWin;
    }
  }

  Future<void> newGame(GameConfig config) async {
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
    if (current == null || engine == null) return null;
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
    _unlockAchievements(current, outcome.merges);
    if (current.status == GameStatus.won && !_winCounted) {
      stats.gamesWon += 1;
      stats.currentStreak += 1;
      if (stats.currentStreak > stats.bestStreak) {
        stats.bestStreak = stats.currentStreak;
      }
      _winCounted = true;
    }
    if (current.status == GameStatus.lost && _sessionCounted) {
      stats.currentStreak = 0;
      _sessionCounted = false;
    }
    _updateDailyRecord(current);
    await _persist();
    notifyListeners();
    return outcome;
  }

  Future<void> undo() async {
    if (_undo.isEmpty || game == null) return;
    game = _undo.removeLast();
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

  Future<void> refreshChallengeStatus() async {
    final current = game;
    final engine = _engine;
    if (current == null || engine == null) return;
    final before = current.status;
    engine.refreshStatus(current);
    if (before != current.status) {
      _updateDailyRecord(current);
      await _persist();
      notifyListeners();
    }
  }

  Future<void> continueAfterWin() async {
    if (game == null) return;
    game!.hasAcknowledgedWin = true;
    game!.status = GameStatus.playing;
    _updateDailyRecord(game!);
    await _persist();
    notifyListeners();
  }

  Future<void> clearCurrentGame() async {
    game = null;
    _engine = null;
    _undo.clear();
    await store.clearGame();
    notifyListeners();
  }

  Future<void> clearAllData() async {
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

  void _unlockAchievements(GameState state, int merges) {
    for (final achievement in achievements) {
      if (achievement.unlocked) continue;
      final shouldUnlock = switch (achievement.id) {
        'first_merge' => merges > 0,
        _ => state.highestTile >= achievement.threshold,
      };
      if (shouldUnlock) achievement.unlockedAt = DateTime.now();
    }
  }

  void _restoreAchievements(Map<String, Object?> raw) {
    for (final achievement in achievements) {
      final value = raw[achievement.id] as String?;
      achievement.unlockedAt = value == null ? null : DateTime.tryParse(value);
    }
  }

  Future<void> _saveAchievements() {
    return store.saveAchievements({
      for (final item in achievements)
        item.id: item.unlockedAt?.toIso8601String(),
    });
  }
}
