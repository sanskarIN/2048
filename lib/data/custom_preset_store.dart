import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/custom_game_preset.dart';

class CustomPresetStore {
  static const String storageKey = 'nova.custom_game_presets.v1';
  static const int maxPresets = 24;

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  Future<List<CustomGamePreset>> load() async {
    final prefs = await _prefs;
    final raw = prefs.getString(storageKey);
    if (raw == null) return const [];

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        await prefs.remove(storageKey);
        return const [];
      }

      final presets = <CustomGamePreset>[];
      final names = <String>{};
      var repaired = false;
      for (final item in decoded) {
        if (item is! Map<String, dynamic>) {
          repaired = true;
          continue;
        }
        try {
          final preset = CustomGamePreset.fromJson(
            Map<String, Object?>.from(item),
          );
          final normalizedName = preset.name.toLowerCase();
          if (!names.add(normalizedName)) {
            repaired = true;
            continue;
          }
          presets.add(preset);
        } on Object {
          repaired = true;
        }
      }

      final limited = presets.length <= maxPresets
          ? presets
          : presets.sublist(0, maxPresets);
      if (limited.length != presets.length) repaired = true;
      if (repaired) {
        await _write(prefs, limited);
      }
      return List.unmodifiable(limited);
    } on Object {
      await prefs.remove(storageKey);
      return const [];
    }
  }

  Future<void> save(List<CustomGamePreset> presets) async {
    final normalized = <CustomGamePreset>[];
    final names = <String>{};
    for (final preset in presets) {
      final normalizedName = preset.name.toLowerCase();
      if (!names.add(normalizedName)) continue;
      normalized.add(preset);
      if (normalized.length == maxPresets) break;
    }
    await _write(await _prefs, normalized);
  }

  Future<void> clear() async {
    await (await _prefs).remove(storageKey);
  }

  Future<void> _write(
    SharedPreferences prefs,
    List<CustomGamePreset> presets,
  ) async {
    await prefs.setString(
      storageKey,
      jsonEncode(presets.map((preset) => preset.toJson()).toList()),
    );
  }
}
