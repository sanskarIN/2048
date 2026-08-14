import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/game_state.dart';

class LocalStore {
  static const _gameKey = 'nova.current_game.v1';
  static const _settingsKey = 'nova.settings.v1';
  static const _statsKey = 'nova.stats.v1';
  static const _achievementsKey = 'nova.achievements.v1';

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
      if (json is! Map<String, dynamic>) return null;
      return GameState.fromJson(Map<String, Object?>.from(json));
    } on Object {
      await prefs.remove(_gameKey);
      return null;
    }
  }

  Future<void> clearGame() async => (await _prefs).remove(_gameKey);

  Future<Map<String, Object?>> loadSettings() => _loadMap(_settingsKey);
  Future<Map<String, Object?>> loadStats() => _loadMap(_statsKey);
  Future<Map<String, Object?>> loadAchievements() => _loadMap(_achievementsKey);

  Future<void> saveSettings(Map<String, Object?> value) => _saveMap(_settingsKey, value);
  Future<void> saveStats(Map<String, Object?> value) => _saveMap(_statsKey, value);
  Future<void> saveAchievements(Map<String, Object?> value) => _saveMap(_achievementsKey, value);

  Future<Map<String, Object?>> _loadMap(String key) async {
    final raw = (await _prefs).getString(key);
    if (raw == null) return {};
    try {
      final value = jsonDecode(raw);
      return value is Map<String, dynamic> ? Map<String, Object?>.from(value) : {};
    } on Object {
      return {};
    }
  }

  Future<void> _saveMap(String key, Map<String, Object?> value) async {
    await (await _prefs).setString(key, jsonEncode(value));
  }
}
