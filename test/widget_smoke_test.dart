import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nova_2048/app/nova_app.dart';
import 'package:nova_2048/app/state/app_controller.dart';
import 'package:nova_2048/data/local_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('splash transitions to home and renders navigation',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final controller = AppController(store: LocalStore());
    await controller.initialize();

    await tester.pumpWidget(NovaApp(controller: controller));
    await tester.pumpAndSettle();

    expect(find.text('2048 NOVA'), findsOneWidget);
    expect(find.text('New Game'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
  });

  testWidgets('supports dark theme selection', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final controller = AppController(store: LocalStore());
    await controller.initialize();
    await controller.updateSettings(
      (settings) => settings.themeMode = ThemeMode.dark,
    );

    await tester.pumpWidget(NovaApp(controller: controller));
    await tester.pumpAndSettle();

    expect(controller.settings.themeMode, ThemeMode.dark);
  });

  testWidgets('mode screen exposes the requested game modes', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final controller = AppController(store: LocalStore());
    await controller.initialize();
    await tester.pumpWidget(NovaApp(controller: controller));
    await tester.pumpAndSettle();

    await tester.tap(find.text('New Game'));
    await tester.pumpAndSettle();

    expect(find.text('Classic 4×4'), findsOneWidget);
    expect(find.text('Quick 3×3'), findsOneWidget);
    expect(find.text('Extended 5×5'), findsOneWidget);
    expect(find.text('Challenge 6×6'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Daily Challenge'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Daily Challenge'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Zen'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Zen'), findsOneWidget);
  });
}
