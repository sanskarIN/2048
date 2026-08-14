import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nova_2048/app/nova_app.dart';
import 'package:nova_2048/app/state/app_controller.dart';
import 'package:nova_2048/data/local_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('solver demo steps and resets without touching player statistics',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final controller = AppController(store: LocalStore());
    await controller.initialize();

    await tester.pumpWidget(NovaApp(controller: controller));
    await tester.pumpAndSettle();

    final initialGames = controller.stats.gamesPlayed;
    final initialMoves = controller.stats.totalMoves;
    final initialBest = controller.stats.bestScore;

    await tester.tap(find.text('Solver Demo'));
    await tester.pumpAndSettle();

    expect(find.text('Deterministic heuristic autoplay'), findsOneWidget);
    expect(find.text('Moves: 0'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Step'),
      250,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.tap(find.text('Step'));
    await tester.pump();

    expect(find.text('Moves: 1'), findsOneWidget);
    expect(controller.stats.gamesPlayed, initialGames);
    expect(controller.stats.totalMoves, initialMoves);
    expect(controller.stats.bestScore, initialBest);
    expect(controller.game, isNull);

    await tester.tap(find.text('Reset seed'));
    await tester.pump();

    expect(find.text('Moves: 0'), findsOneWidget);
    expect(controller.stats.gamesPlayed, initialGames);
    expect(controller.stats.totalMoves, initialMoves);
    expect(controller.stats.bestScore, initialBest);
  });

  testWidgets('solver autoplay can be paused without continuing in background',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final controller = AppController(store: LocalStore());
    await controller.initialize();

    await tester.pumpWidget(NovaApp(controller: controller));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Solver Demo'));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Autoplay'),
      250,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.tap(find.text('Autoplay'));
    await tester.pump(const Duration(milliseconds: 1100));

    expect(find.text('Pause'), findsOneWidget);
    final movesAfterRun = _visibleMoveCount(tester);
    expect(movesAfterRun, greaterThan(0));

    await tester.tap(find.text('Pause'));
    await tester.pump();
    expect(find.text('Autoplay'), findsOneWidget);

    final pausedMoves = _visibleMoveCount(tester);
    await tester.pump(const Duration(seconds: 2));
    expect(_visibleMoveCount(tester), pausedMoves);
  });
}

int _visibleMoveCount(WidgetTester tester) {
  final value = tester
      .widgetList<Text>(find.byType(Text))
      .map((widget) => widget.data)
      .whereType<String>()
      .firstWhere((text) => text.startsWith('Moves: '));
  return int.parse(value.substring('Moves: '.length));
}
