import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nova_2048/app/state/app_controller.dart';
import 'package:nova_2048/app/state/app_scope.dart';
import 'package:nova_2048/data/custom_preset_store.dart';
import 'package:nova_2048/data/local_store.dart';
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
  }) async {
    final controller = AppController(store: LocalStore());
    await controller.initialize();
    await tester.pumpWidget(
      localizedTestApp(
        locale: locale,
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
    final scrollable = find.byType(Scrollable).first;
    await tester.scrollUntilVisible(finder, 220, scrollable: scrollable);
    await tester.pump();
    await tester.tap(finder);
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

  testWidgets('play now starts the validated default custom target game', (
    tester,
  ) async {
    final controller = await pumpBuilder(tester);

    await tapVisible(
      tester,
      find.widgetWithText(FilledButton, 'Play now'),
    );

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

    await tapVisible(
      tester,
      find.widgetWithText(FilledButton, 'Play now'),
    );

    expect(controller.game, isNull);
    expect(
      find.text('Seed must be a whole number from 0 to 2147483647.'),
      findsOneWidget,
    );
  });
}
