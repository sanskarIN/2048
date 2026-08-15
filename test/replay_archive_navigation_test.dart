import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nova_2048/app/state/app_controller.dart';
import 'package:nova_2048/app/state/app_scope.dart';
import 'package:nova_2048/core/localization/nova_localizations.dart';
import 'package:nova_2048/data/local_store.dart';
import 'package:nova_2048/features/replay/replay_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Move Replay exposes Full Replay Archive even without a game', (
    tester,
  ) async {
    final controller = AppController(store: LocalStore());
    await controller.initialize();

    await tester.pumpWidget(
      AppScope(
        controller: controller,
        child: const MaterialApp(
          supportedLocales: NovaLocalizations.supportedLocales,
          localizationsDelegates: [
            NovaLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: ReplayScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Open Full Replay Archive'), findsOneWidget);
    await tester.tap(find.text('Open Full Replay Archive'));
    await tester.pumpAndSettle();

    expect(find.text('Full Replay Archive'), findsOneWidget);
    expect(find.text('Open from clipboard'), findsOneWidget);
  });
}
