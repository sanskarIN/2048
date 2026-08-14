import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nova_2048/app/state/app_controller.dart';
import 'package:nova_2048/app/state/app_scope.dart';
import 'package:nova_2048/data/local_store.dart';
import 'package:nova_2048/domain/game_state.dart';
import 'package:nova_2048/domain/game_types.dart';
import 'package:nova_2048/shared/game_replacement_guard.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('active recoverable game asks before replacement', (tester) async {
    final controller = AppController(store: LocalStore());
    await controller.initialize();
    await controller.newGame(
      const GameConfig(mode: GameMode.classic, size: 4),
    );
    bool? result;

    await tester.pumpWidget(
      MaterialApp(
        home: AppScope(
          controller: controller,
          child: Builder(
            builder: (context) => Scaffold(
              body: FilledButton(
                onPressed: () async {
                  result = await confirmGameReplacement(context);
                },
                child: const Text('Replace'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Replace'));
    await tester.pumpAndSettle();
    expect(find.text('Replace current game?'), findsOneWidget);

    await tester.tap(find.text('Keep current game'));
    await tester.pumpAndSettle();
    expect(result, isFalse);
  });

  testWidgets('lost game may be replaced without a confirmation dialog',
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
    bool? result;

    await tester.pumpWidget(
      MaterialApp(
        home: AppScope(
          controller: controller,
          child: Builder(
            builder: (context) => Scaffold(
              body: FilledButton(
                onPressed: () async {
                  result = await confirmGameReplacement(context);
                },
                child: const Text('Replace'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Replace'));
    await tester.pump();

    expect(find.text('Replace current game?'), findsNothing);
    expect(result, isTrue);
  });
}
