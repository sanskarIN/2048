import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nova_2048/app/state/app_controller.dart';
import 'package:nova_2048/app/state/app_scope.dart';
import 'package:nova_2048/data/local_store.dart';
import 'package:nova_2048/domain/game_types.dart';
import 'package:nova_2048/features/statistics/statistics_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/localized_test_app.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Future<AppController> controllerWithClassicRecord() async {
    final controller = AppController(store: LocalStore());
    await controller.initialize();
    await controller.newGame(
      const GameConfig(mode: GameMode.classic, size: 4),
    );
    controller.game!.board
      ..[0] = [2, 2, 0, 0]
      ..[1] = [0, 0, 0, 0]
      ..[2] = [0, 0, 0, 0]
      ..[3] = [0, 0, 0, 0];
    await controller.move(Direction.left);
    return controller;
  }

  Future<void> useTallViewport(WidgetTester tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(800, 1800);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
  }

  testWidgets('statistics exposes ranked mode records and metadata',
      (tester) async {
    await useTallViewport(tester);
    final controller = await controllerWithClassicRecord();

    await tester.pumpWidget(
      localizedTestApp(
        home: AppScope(
          controller: controller,
          child: const StatisticsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Classic'), findsOneWidget);
    expect(find.text('4 × 4 board'), findsOneWidget);
    expect(find.text('Target tile: 2048'), findsOneWidget);

    await tester.tap(find.text('Classic'));
    await tester.pumpAndSettle();

    expect(find.text('Best score'), findsNWidgets(2));
    expect(find.text('Highest tile'), findsNWidgets(2));
    expect(find.text('4'), findsWidgets);
  });

  testWidgets('per-mode statistics reuse the Hindi localization layer',
      (tester) async {
    await useTallViewport(tester);
    final controller = await controllerWithClassicRecord();

    await tester.pumpWidget(
      localizedTestApp(
        locale: const Locale('hi'),
        home: AppScope(
          controller: controller,
          child: const StatisticsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('क्लासिक'), findsOneWidget);
    expect(find.text('4 × 4 बोर्ड'), findsOneWidget);
    expect(find.text('लक्ष्य टाइल: 2048'), findsOneWidget);

    await tester.tap(find.text('क्लासिक'));
    await tester.pumpAndSettle();

    expect(find.text('सर्वश्रेष्ठ स्कोर'), findsNWidgets(2));
    expect(find.text('सबसे बड़ी टाइल'), findsNWidgets(2));
  });
}
