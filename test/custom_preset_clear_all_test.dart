import 'package:flutter_test/flutter_test.dart';
import 'package:nova_2048/data/custom_preset_store.dart';
import 'package:nova_2048/data/local_store.dart';
import 'package:nova_2048/domain/custom_game_preset.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('LocalStore clearAll removes custom presets with other app data', () async {
    final presets = CustomPresetStore();
    await presets.save([
      CustomGamePreset.create(
        name: 'Saved custom mode',
        style: CustomGameStyle.target,
        size: 5,
        target: 4096,
      ),
    ]);
    await LocalStore().saveSettings({'themeMode': 'dark'});

    await LocalStore().clearAll();

    expect(await presets.load(), isEmpty);
    expect(await LocalStore().loadSettings(), isEmpty);
  });
}
