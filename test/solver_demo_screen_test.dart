import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nova_2048/app/nova_app.dart';
import 'package:nova_2048/app/state/app_controller.dart';
import 'package:nova_2048/data/local_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets(
      'auto play demo steps and resets without touching player statistics',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final controller = AppController(store: LocalStore());
    await controller.initialize();

    await tester.pumpWidget(NovaApp(controller: controller));
    await tester.pumpAndSettle();

    final initialGames = controller.stats.gamesPlayed;
    final initialMoves = controller.stats.totalMoves;
    final initialBest = controller.stats.bestScore;

    await tester.tap(find.text('Auto Play Demo'));
    await tester.pumpAndSettle();

    expect(
        find.text('Deterministic local solver demonstration'), findsOneWidget);
    expect(find.text('Strategy: Heuristic'), findsOneWidget);
    expect(find.text('Demo moves: 0'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Step'),
      250,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.tap(find.text('Step'));
    await tester.pump();

    expect(find.text('Demo moves: 1'), findsOneWidget);
    expect(controller.stats.gamesPlayed, initialGames);
    expect(controller.stats.totalMoves, initialMoves);
    expect(controller.stats.bestScore, initialBest);
    expect(controller.game, isNull);

    await tester.tap(find.text('Reset seed'));
    await tester.pump();

    expect(find.text('Demo moves: 0'), findsOneWidget);
    expect(controller.stats.gamesPlayed, initialGames);
    expect(controller.stats.totalMoves, initialMoves);
    expect(controller.stats.bestScore, initialBest);
  });

  testWidgets('auto play speed can change and pause stops background moves',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final controller = AppController(store: LocalStore());
    await controller.initialize();

    await tester.pumpWidget(NovaApp(controller: controller));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Auto Play Demo'));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Auto Play'),
      250,
      scrollable: find.byType(Scrollable).last,
    );

    expect(find.text('2 moves / sec'), findsOneWidget);
    await tester.tap(find.text('2 moves / sec'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('4 moves / sec').last);
    await tester.pumpAndSettle();
    expect(find.text('4 moves / sec'), findsOneWidget);

    await tester.tap(find.text('Auto Play'));
    await tester.pump(const Duration(milliseconds: 550));

    expect(find.text('Pause'), findsOneWidget);
    final movesAfterRun = _visibleMoveCount(tester);
    expect(movesAfterRun, greaterThan(0));

    await tester.tap(find.text('Pause'));
    await tester.pump();
    expect(find.text('Auto Play'), findsOneWidget);

    final pausedMoves = _visibleMoveCount(tester);
    await tester.pump(const Duration(seconds: 2));
    expect(_visibleMoveCount(tester), pausedMoves);
  });

  testWidgets('expectimax can be selected without touching trusted app state',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final controller = AppController(store: LocalStore());
    await controller.initialize();

    await tester.pumpWidget(NovaApp(controller: controller));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Auto Play Demo'));
    await tester.pumpAndSettle();

    final initialGames = controller.stats.gamesPlayed;
    final initialMoves = controller.stats.totalMoves;

    await tester.scrollUntilVisible(
      find.text('Heuristic'),
      250,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.tap(find.text('Heuristic'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Expectimax').last);
    await tester.pumpAndSettle();

    expect(find.text('Strategy: Expectimax'), findsOneWidget);
    expect(find.text('Search nodes: —'), findsOneWidget);

    await tester.tap(find.text('Step'));
    await tester.pumpAndSettle();

    expect(find.text('Demo moves: 1'), findsOneWidget);
    expect(_visibleSearchNodeCount(tester), greaterThan(0));
    expect(controller.stats.gamesPlayed, initialGames);
    expect(controller.stats.totalMoves, initialMoves);
    expect(controller.game, isNull);
  });
}

int _visibleMoveCount(WidgetTester tester) {
  final value = tester
      .widgetList<Text>(find.byType(Text))
      .map((widget) => widget.data)
      .whereType<String>()
      .firstWhere((text) => text.startsWith('Demo moves: '));
  return int.parse(value.substring('Demo moves: '.length));
}

int _visibleSearchNodeCount(WidgetTester tester) {
  final value = tester
      .widgetList<Text>(find.byType(Text))
      .map((widget) => widget.data)
      .whereType<String>()
      .firstWhere(
        (text) => text.startsWith('Search nodes: ') && !text.endsWith('—'),
      );
  return int.parse(value.substring('Search nodes: '.length));
}
