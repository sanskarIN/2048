import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nova_2048/app/state/app_controller.dart';
import 'package:nova_2048/app/state/app_scope.dart';
import 'package:nova_2048/data/local_store.dart';
import 'package:nova_2048/domain/game_state.dart';
import 'package:nova_2048/domain/game_types.dart';
import 'package:nova_2048/features/game/game_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Future<AppController> pumpGame(WidgetTester tester) async {
    final controller = AppController(store: LocalStore());
    await controller.initialize();
    await controller.newGame(
      const GameConfig(mode: GameMode.classic, size: 4),
    );
    await tester.pumpWidget(
      MaterialApp(
        home: AppScope(
          controller: controller,
          child: const GameScreen(),
        ),
      ),
    );
    await tester.pump();
    return controller;
  }

  testWidgets('P keyboard shortcut opens the pause dialog', (tester) async {
    await pumpGame(tester);

    await tester.sendKeyEvent(LogicalKeyboardKey.keyP);
    await tester.pumpAndSettle();

    expect(find.text('Paused'), findsOneWidget);
    expect(find.text('Resume'), findsOneWidget);
  });

  testWidgets('H keyboard shortcut presents a deterministic hint',
      (tester) async {
    await pumpGame(tester);

    await tester.sendKeyEvent(LogicalKeyboardKey.keyH);
    await tester.pump();

    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.textContaining('Try '), findsOneWidget);
  });

  testWidgets('game over dialog cannot be dismissed with route back',
      (tester) async {
    final controller = AppController(store: LocalStore());
    await controller.initialize();
    controller.game = GameState(
      board: const [
        [2, 4, 2, 4],
        [4, 2, 4, 2],
        [2, 4, 2, 4],
        [4, 2, 4, 2],
      ],
      config: const GameConfig(mode: GameMode.classic, size: 4),
      status: GameStatus.lost,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: AppScope(
          controller: controller,
          child: const GameScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Game over'), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(find.text('Game over'), findsOneWidget);
  });
}
