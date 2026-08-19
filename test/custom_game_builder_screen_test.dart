import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nova_2048/app/state/app_controller.dart';
import 'package:nova_2048/app/state/app_scope.dart';
import 'package:nova_2048/data/custom_preset_store.dart';
import 'package:nova_2048/data/local_store.dart';
import 'package:nova_2048/domain/custom_game_preset.dart';
import 'package:nova_2048/domain/game_types.dart';
import 'package:nova_2048/features/modes/custom_game_builder_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/localized_test_app.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Future<AppController> pumpBuilder(
    WidgetTester tester, {
    Locale? locale,
    TextScaler? textScaler,
  }) async {
    final controller = AppController(store: LocalStore());
    await controller.initialize();
    await tester.pumpWidget(
      localizedTestApp(
        locale: locale,
        textScaler: textScaler,
        routes: {'/game': (_) => const Scaffold(body: Text('Custom game'))},
        home: AppScope(
          controller: controller,
          child: const CustomGameBuilderScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return controller;
  }

  Future<void> tapVisible(WidgetTester tester, Finder finder) async {
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  Future<void> choosePresetAction(
    WidgetTester tester,
    String actionLabel,
  ) async {
    await tapVisible(tester, find.byTooltip('Preset actions').first);
    await tester.tap(find.text(actionLabel).last);
    await tester.pumpAndSettle();
  }

  testWidgets('renders builder controls in English and Hindi', (tester) async {
    await pumpBuilder(tester);

    expect(find.text('Custom Game Builder'), findsOneWidget);
    expect(find.text('Preset name'), findsOneWidget);
    expect(find.text('Play now'), findsOneWidget);
    expect(find.text('Saved presets'), findsOneWidget);

    await pumpBuilder(tester, locale: const Locale('hi'));

    expect(find.text('कस्टम गेम बिल्डर'), findsOneWidget);
    expect(find.text('प्रीसेट नाम'), findsOneWidget);
    expect(find.text('अभी खेलें'), findsOneWidget);
    expect(find.text('सेव किए गए प्रीसेट'), findsOneWidget);
  });

  testWidgets('saves a local preset without starting a game', (tester) async {
    final controller = await pumpBuilder(tester);
    final nameField = find.byType(TextField).first;
    await tester.enterText(nameField, 'My Saved Mode');

    await tapVisible(
      tester,
      find.widgetWithText(OutlinedButton, 'Save preset'),
    );

    expect(controller.game, isNull);
    expect(
      find.descendant(
        of: find.byType(ListTile),
        matching: find.text('My Saved Mode'),
      ),
      findsOneWidget,
    );
    expect(find.text('Preset saved.'), findsOneWidget);
    final restored = await CustomPresetStore().load();
    expect(restored, hasLength(1));
    expect(restored.single.name, 'My Saved Mode');
  });

  testWidgets('edits and renames a preset without leaving the old entry', (
    tester,
  ) async {
    final store = CustomPresetStore();
    await store.save([
      CustomGamePreset.create(
        name: 'Edit Me',
        style: CustomGameStyle.timed,
        size: 5,
        target: 4096,
        timeLimitSeconds: 90,
        seed: 42,
      ),
    ]);
    await pumpBuilder(tester);

    await choosePresetAction(tester, 'Edit preset');

    final nameField = tester.widget<TextField>(find.byType(TextField).first);
    final seedField = tester.widget<TextField>(find.byType(TextField).at(1));
    expect(nameField.controller!.text, 'Edit Me');
    expect(seedField.controller!.text, '42');
    expect(find.text('Save changes'), findsOneWidget);
    expect(find.text('Cancel edit'), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, 'Edited Mode');
    await tester.enterText(find.byType(TextField).at(1), '43');
    await tapVisible(
      tester,
      find.widgetWithText(OutlinedButton, 'Save changes'),
    );

    final restored = await store.load();
    expect(restored, hasLength(1));
    expect(restored.single.name, 'Edited Mode');
    expect(restored.single.style, CustomGameStyle.timed);
    expect(restored.single.size, 5);
    expect(restored.single.target, 4096);
    expect(restored.single.timeLimitSeconds, 90);
    expect(restored.single.seed, 43);
    expect(find.text('Edit Me'), findsNothing);
    expect(find.text('Preset updated.'), findsOneWidget);
  });

  testWidgets('editing refuses to overwrite a different saved preset name', (
    tester,
  ) async {
    final store = CustomPresetStore();
    await store.save([
      CustomGamePreset.create(
        name: 'First',
        style: CustomGameStyle.target,
        size: 4,
      ),
      CustomGamePreset.create(
        name: 'Second',
        style: CustomGameStyle.endless,
        size: 5,
      ),
    ]);
    await pumpBuilder(tester);

    await choosePresetAction(tester, 'Edit preset');
    await tester.enterText(find.byType(TextField).first, 'Second');
    await tapVisible(
      tester,
      find.widgetWithText(OutlinedButton, 'Save changes'),
    );

    expect(find.text('A preset with this name already exists.'), findsOneWidget);
    final restored = await store.load();
    expect(restored, hasLength(2));
    expect(restored.map((preset) => preset.name), containsAll(['First', 'Second']));
  });

  testWidgets('duplicates a preset into a unique unsaved copy before saving', (
    tester,
  ) async {
    final store = CustomPresetStore();
    await store.save([
      CustomGamePreset.create(
        name: 'Copy Me',
        style: CustomGameStyle.moveLimit,
        size: 6,
        target: 8192,
        moveLimit: 500,
        seed: 88,
      ),
    ]);
    await pumpBuilder(tester);

    await choosePresetAction(tester, 'Duplicate preset');

    final nameField = tester.widget<TextField>(find.byType(TextField).first);
    final seedField = tester.widget<TextField>(find.byType(TextField).at(1));
    expect(nameField.controller!.text, 'Copy Me copy');
    expect(seedField.controller!.text, '88');
    expect(find.text('Save preset'), findsOneWidget);
    expect(await store.load(), hasLength(1));

    await tapVisible(
      tester,
      find.widgetWithText(OutlinedButton, 'Save preset'),
    );

    final restored = await store.load();
    expect(restored, hasLength(2));
    expect(
      restored.map((preset) => preset.name),
      containsAll(['Copy Me', 'Copy Me copy']),
    );
    final copy = restored.firstWhere((preset) => preset.name == 'Copy Me copy');
    expect(copy.style, CustomGameStyle.moveLimit);
    expect(copy.size, 6);
    expect(copy.target, 8192);
    expect(copy.moveLimit, 500);
    expect(copy.seed, 88);
  });

  testWidgets('cancel edit restores the default creation form', (tester) async {
    final store = CustomPresetStore();
    await store.save([
      CustomGamePreset.create(
        name: 'Cancel Me',
        style: CustomGameStyle.endless,
        size: 7,
        target: 4096,
        seed: 7,
      ),
    ]);
    await pumpBuilder(tester);

    await choosePresetAction(tester, 'Edit preset');
    await tapVisible(tester, find.widgetWithText(TextButton, 'Cancel edit'));

    final nameField = tester.widget<TextField>(find.byType(TextField).first);
    final seedField = tester.widget<TextField>(find.byType(TextField).at(1));
    expect(nameField.controller!.text, 'My Custom Game');
    expect(seedField.controller!.text, isEmpty);
    expect(find.text('Save changes'), findsNothing);
    expect(find.text('Save preset'), findsOneWidget);
    expect(find.text('Edit cancelled.'), findsOneWidget);
    expect(await store.load(), hasLength(1));
  });

  testWidgets('delete confirmation cancels or removes only after approval', (
    tester,
  ) async {
    final store = CustomPresetStore();
    await store.save([
      CustomGamePreset.create(
        name: 'Delete Me',
        style: CustomGameStyle.target,
        size: 4,
        target: 2048,
      ),
    ]);
    await pumpBuilder(tester);

    await choosePresetAction(tester, 'Delete preset');

    expect(find.text('Delete preset?'), findsOneWidget);
    expect(
      find.text('Delete "Delete Me"? This cannot be undone.'),
      findsOneWidget,
    );
    await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
    await tester.pumpAndSettle();

    expect(find.text('Delete Me'), findsOneWidget);
    expect(await store.load(), hasLength(1));

    await choosePresetAction(tester, 'Delete preset');
    await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
    await tester.pumpAndSettle();

    expect(find.text('Delete Me'), findsNothing);
    expect(find.text('Preset deleted.'), findsOneWidget);
    expect(await store.load(), isEmpty);
  });

  testWidgets('preset actions remain usable on narrow large-text layouts', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await CustomPresetStore().save([
      CustomGamePreset.create(
        name: 'Responsive Mode',
        style: CustomGameStyle.target,
        size: 4,
        target: 2048,
      ),
    ]);
    await pumpBuilder(tester, textScaler: TextScaler.linear(2));

    await tester.ensureVisible(find.text('Responsive Mode'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Preset actions'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tapVisible(tester, find.byTooltip('Preset actions'));
    expect(find.text('Edit preset'), findsOneWidget);
    expect(find.text('Duplicate preset'), findsOneWidget);
    expect(find.text('Delete preset'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('preset action labels localize in Hindi', (tester) async {
    await CustomPresetStore().save([
      CustomGamePreset.create(
        name: 'हिंदी मोड',
        style: CustomGameStyle.target,
        size: 4,
      ),
    ]);
    await pumpBuilder(tester, locale: const Locale('hi'));

    await tapVisible(tester, find.byTooltip('प्रीसेट क्रियाएँ'));

    expect(find.text('प्रीसेट संपादित करें'), findsOneWidget);
    expect(find.text('प्रीसेट कॉपी करें'), findsOneWidget);
    expect(find.text('प्रीसेट हटाएँ'), findsOneWidget);
  });

  testWidgets('play now starts the validated default custom target game', (
    tester,
  ) async {
    final controller = await pumpBuilder(tester);

    await tapVisible(tester, find.widgetWithText(FilledButton, 'Play now'));

    expect(find.text('Custom game'), findsOneWidget);
    expect(controller.game, isNotNull);
    expect(controller.game!.config.mode, GameMode.target);
    expect(controller.game!.config.size, 4);
    expect(controller.game!.config.target, 2048);
    expect(controller.game!.config.seed, isNull);
  });

  testWidgets('invalid seed is rejected before replacing the game', (
    tester,
  ) async {
    final controller = await pumpBuilder(tester);
    final seedField = find.byType(TextField).at(1);
    await tester.enterText(seedField, 'not-a-number');

    await tapVisible(tester, find.widgetWithText(FilledButton, 'Play now'));

    expect(controller.game, isNull);
    expect(
      find.text('Seed must be a whole number from 0 to 2147483647.'),
      findsOneWidget,
    );
  });
}
