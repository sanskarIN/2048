import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:nova_2048/data/custom_preset_store.dart';
import 'package:nova_2048/domain/custom_game_preset.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  CustomGamePreset preset(String name, {int size = 4}) {
    return CustomGamePreset.create(
      name: name,
      style: CustomGameStyle.target,
      size: size,
      target: 2048,
    );
  }

  test('round trips validated custom presets', () async {
    final store = CustomPresetStore();
    await store.save([
      preset('Classic Plus'),
      CustomGamePreset.create(
        name: 'Quick Timer',
        style: CustomGameStyle.timed,
        size: 3,
        target: 512,
        timeLimitSeconds: 60,
        seed: 99,
      ),
    ]);

    final restored = await store.load();

    expect(restored, hasLength(2));
    expect(restored.first.name, 'Classic Plus');
    expect(restored.last.style, CustomGameStyle.timed);
    expect(restored.last.timeLimitSeconds, 60);
    expect(restored.last.seed, 99);
  });

  test('repairs invalid and duplicate stored entries', () async {
    final first = preset('Duplicate').toJson();
    final second = preset('duplicate', size: 5).toJson();
    final invalid = <String, Object?>{
      'schemaVersion': 1,
      'name': 'Broken',
      'style': 'target',
      'size': 2,
      'target': 2048,
      'moveLimit': null,
      'timeLimitSeconds': null,
      'seed': null,
    };
    SharedPreferences.setMockInitialValues({
      CustomPresetStore.storageKey: jsonEncode([
        first,
        second,
        invalid,
        'not-a-map',
      ]),
    });

    final store = CustomPresetStore();
    final restored = await store.load();
    final prefs = await SharedPreferences.getInstance();
    final repaired = jsonDecode(
      prefs.getString(CustomPresetStore.storageKey)!,
    ) as List<dynamic>;

    expect(restored, hasLength(1));
    expect(restored.single.name, 'Duplicate');
    expect(repaired, hasLength(1));
  });

  test('bounds saved presets and preserves first unique names', () async {
    final store = CustomPresetStore();
    final values = <CustomGamePreset>[
      for (var index = 0; index < CustomPresetStore.maxPresets + 5; index += 1)
        preset('Preset $index'),
      preset('PRESET 0'),
    ];

    await store.save(values);
    final restored = await store.load();

    expect(restored, hasLength(CustomPresetStore.maxPresets));
    expect(restored.first.name, 'Preset 0');
    expect(restored.last.name, 'Preset 23');
  });

  test('removes malformed top-level storage safely', () async {
    SharedPreferences.setMockInitialValues({
      CustomPresetStore.storageKey: '{not-json',
    });
    final store = CustomPresetStore();

    expect(await store.load(), isEmpty);
    expect(
      (await SharedPreferences.getInstance()).containsKey(
        CustomPresetStore.storageKey,
      ),
      isFalse,
    );
  });

  test('clear removes only custom preset storage', () async {
    SharedPreferences.setMockInitialValues({
      CustomPresetStore.storageKey: jsonEncode([preset('Saved').toJson()]),
      'nova.settings.v1': '{"themeMode":"dark"}',
    });
    final store = CustomPresetStore();

    await store.clear();

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.containsKey(CustomPresetStore.storageKey), isFalse);
    expect(prefs.containsKey('nova.settings.v1'), isTrue);
  });
}
