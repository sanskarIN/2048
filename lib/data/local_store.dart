import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/daily_record.dart';
import '../domain/game_state.dart';
import '../domain/replay_archive.dart';

class LocalStore {
  static const _gameKey = 'nova.current_game.v1';
  static const _undoKey = 'nova.undo_history.v1';
  static const _settingsKey = 'nova.settings.v1';
  static const _statsKey = 'nova.stats.v1';
  static const _achievementsKey = 'nova.achievements.v1';
  static const _dailyHistoryKey = 'nova.daily_history.v1';
  static const _gameUnrankedKey = 'nova.current_game_unranked.v1';
  static const _replayCaptureKey = 'nova.replay_capture.v1';

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  Future<void> saveGame(GameState state) async {
    final prefs = await _prefs;
    await prefs.setString(_gameKey, jsonEncode(state.toJson()));
  }

  Future<GameState?> loadGame() async {
    final prefs = await _prefs;
    final raw = prefs.getString(_gameKey);
    if (raw == null) return null;
    try {
      final json = jsonDecode(raw);
      if (json is! Map<String, dynamic>) {
        await prefs.remove(_gameKey);
        await prefs.remove(_undoKey);
        await prefs.remove(_gameUnrankedKey);
        await prefs.remove(_replayCaptureKey);
        return null;
      }
      return GameState.fromJson(Map<String, Object?>.from(json));
    } on Object {
      await prefs.remove(_gameKey);
      await prefs.remove(_undoKey);
      await prefs.remove(_gameUnrankedKey);
      await prefs.remove(_replayCaptureKey);
      return null;
    }
  }

  Future<void> saveReplayCapture(ReplayCapture capture) async {
    await (await _prefs).setString(
      _replayCaptureKey,
      jsonEncode(capture.toJson()),
    );
  }

  Future<ReplayCapture?> loadReplayCapture() async {
    final prefs = await _prefs;
    final raw = prefs.getString(_replayCaptureKey);
    if (raw == null) return null;
    try {
      final json = jsonDecode(raw);
      if (json is! Map<String, dynamic>) {
        await prefs.remove(_replayCaptureKey);
        return null;
      }
      return ReplayCapture.fromJson(Map<String, Object?>.from(json));
    } on Object {
      await prefs.remove(_replayCaptureKey);
      return null;
    }
  }

  Future<void> clearReplayCapture() async {
    await (await _prefs).remove(_replayCaptureKey);
  }

  Future<void> saveCurrentGameUnranked(bool value) async {
    await (await _prefs).setBool(_gameUnrankedKey, value);
  }

  Future<bool> loadCurrentGameUnranked() async {
    final prefs = await _prefs;
    final value = prefs.get(_gameUnrankedKey);
    if (value is bool) return value;
    if (value != null) await prefs.remove(_gameUnrankedKey);
    return false;
  }

  Future<void> saveUndoHistory(List<GameState> history) async {
    final prefs = await _prefs;
    await prefs.setString(
      _undoKey,
      jsonEncode(history.map((state) => state.toJson()).toList()),
    );
  }

  Future<List<GameState>> loadUndoHistory() async {
    final prefs = await _prefs;
    final raw = prefs.getString(_undoKey);
    if (raw == null) return [];
    try {
      final json = jsonDecode(raw);
      if (json is! List) {
        await prefs.remove(_undoKey);
        return [];
      }
      final states = <GameState>[];
      var repaired = false;
      for (final item in json) {
        if (item is! Map<String, dynamic>) {
          repaired = true;
          continue;
        }
        try {
          states.add(GameState.fromJson(Map<String, Object?>.from(item)));
        } on Object {
          repaired = true;
        }
      }
      final limited =
          states.length <= 50 ? states : states.sublist(states.length - 50);
      if (limited.length != states.length) repaired = true;
      if (repaired) {
        await prefs.setString(
          _undoKey,
          jsonEncode(limited.map((state) => state.toJson()).toList()),
        );
      }
      return limited;
    } on Object {
      await prefs.remove(_undoKey);
      return [];
    }
  }

  Future<List<DailyRecord>> loadDailyHistory() async {
    final prefs = await _prefs;
    final raw = prefs.getString(_dailyHistoryKey);
    if (raw == null) return [];
    try {
      final json = jsonDecode(raw);
      if (json is! List) {
        await prefs.remove(_dailyHistoryKey);
        return [];
      }
      final records = <DailyRecord>[];
      var repaired = false;
      for (final item in json) {
        if (item is! Map<String, dynamic>) {
          repaired = true;
          continue;
        }
        try {
          records.add(
            DailyRecord.fromJson(Map<String, Object?>.from(item)),
          );
        } on Object {
          repaired = true;
        }
      }
      final normalized = _normalizeDailyHistory(records);
      if (normalized.length != records.length) repaired = true;
      final limited =
          normalized.length <= 60 ? normalized : normalized.sublist(0, 60);
      if (limited.length != normalized.length) repaired = true;
      if (repaired) {
        await prefs.setString(
          _dailyHistoryKey,
          jsonEncode(limited.map((record) => record.toJson()).toList()),
        );
      }
      return limited;
    } on Object {
      await prefs.remove(_dailyHistoryKey);
      return [];
    }
  }

  Future<void> saveDailyHistory(List<DailyRecord> records) async {
    final normalized = _normalizeDailyHistory(records);
    final limited =
        normalized.length <= 60 ? normalized : normalized.sublist(0, 60);
    await (await _prefs).setString(
      _dailyHistoryKey,
      jsonEncode(limited.map((record) => record.toJson()).toList()),
    );
  }

  List<DailyRecord> _normalizeDailyHistory(List<DailyRecord> records) {
    final bySeed = <int, DailyRecord>{};
    for (final record in records) {
      final previous = bySeed[record.seed];
      bySeed[record.seed] =
          previous == null ? record : _mergeDailyRecords(previous, record);
    }
    final normalized = bySeed.values.toList()
      ..sort((a, b) => b.seed.compareTo(a.seed));
    return normalized;
  }

  DailyRecord _mergeDailyRecords(DailyRecord a, DailyRecord b) {
    final scoreSource = b.score > a.score ||
            (b.score == a.score && b.updatedAt.isAfter(a.updatedAt))
        ? b
        : a;
    final updatedAt =
        a.updatedAt.isAfter(b.updatedAt) ? a.updatedAt : b.updatedAt;
    return DailyRecord(
      seed: a.seed,
      score: scoreSource.score,
      moves: scoreSource.moves,
      highestTile:
          a.highestTile > b.highestTile ? a.highestTile : b.highestTile,
      completed: a.completed || b.completed,
      won: a.won || b.won,
      updatedAt: updatedAt,
    );
  }

  Future<void> clearGame() async {
    final prefs = await _prefs;
    await prefs.remove(_gameKey);
    await prefs.remove(_undoKey);
    await prefs.remove(_gameUnrankedKey);
    await prefs.remove(_replayCaptureKey);
  }

  Future<void> clearAll() async {
    final prefs = await _prefs;
    for (final key in [
      _gameKey,
      _undoKey,
      _settingsKey,
      _statsKey,
      _achievementsKey,
      _dailyHistoryKey,
      _gameUnrankedKey,
      _replayCaptureKey,
    ]) {
      await prefs.remove(key);
    }
  }

  Future<Map<String, Object?>> loadSettings() => _loadMap(_settingsKey);
  Future<Map<String, Object?>> loadStats() => _loadMap(_statsKey);
  Future<Map<String, Object?>> loadAchievements() => _loadMap(_achievementsKey);

  Future<void> saveSettings(Map<String, Object?> value) =>
      _saveMap(_settingsKey, value);
  Future<void> saveStats(Map<String, Object?> value) =>
      _saveMap(_statsKey, value);
  Future<void> saveAchievements(Map<String, Object?> value) =>
      _saveMap(_achievementsKey, value);

  Future<Map<String, Object?>> _loadMap(String key) async {
    final prefs = await _prefs;
    final raw = prefs.getString(key);
    if (raw == null) return {};
    try {
      final value = jsonDecode(raw);
      if (value is Map<String, dynamic>) {
        return Map<String, Object?>.from(value);
      }
      await prefs.remove(key);
      return {};
    } on Object {
      await prefs.remove(key);
      return {};
    }
  }

  Future<void> _saveMap(String key, Map<String, Object?> value) async {
    await (await _prefs).setString(key, jsonEncode(value));
  }
}
