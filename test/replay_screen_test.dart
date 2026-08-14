import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nova_2048/app/nova_app.dart';
import 'package:nova_2048/app/state/app_controller.dart';
import 'package:nova_2048/data/local_store.dart';
import 'package:nova_2048/domain/game_state.dart';
import 'package:nova_2048/domain/game_types.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  const config = GameConfig(mode: GameMode.classic, size: 4);
  final startedAt = DateTime.utc(2026, 8, 14, 8);

  GameState frame({
    required int moves,
    required int score,
    required int rng,
    required List<int> firstRow,
    int merges = 0,
  }) {
    return GameState(
      config: config,
      board: [
        firstRow,
        [0, 0, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
      ],
      moves: moves,
      score: score,
      bestScore: 8,
      totalMerges: merges,
      rngState: rng,
      startedAt: startedAt,
    );
  }

  Future<AppController> controllerWithReplay() async {
    SharedPreferences.setMockInitialValues({});
    final store = LocalStore();
    await store.saveGame(
      frame(
        moves: 2,
        score: 8,
        rng: 3,
        merges: 1,
        firstRow: [4, 4, 2, 0],
      ),
    );
    await store.saveUndoHistory([
      frame(moves: 0, score: 0, rng: 1, firstRow: [2, 2, 0, 0]),
      frame(
        moves: 1,
        score: 4,
        rng: 2,
        merges: 1,
        firstRow: [4, 2, 0, 0],
      ),
    ]);
    final controller = AppController(store: store);
    await controller.initialize();
    return controller;
  }

  testWidgets('replay scrubbing never mutates the live game', (tester) async {
    final controller = await controllerWithReplay();
    final liveBoard = controller.game!.board
        .map((row) => List<int>.from(row))
        .toList(growable: false);
    final liveScore = controller.game!.score;
    final liveMoves = controller.game!.moves;
    final liveRng = controller.game!.rngState;

    await tester.pumpWidget(NovaApp(controller: controller));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Move Replay'));
    await tester.pumpAndSettle();

    expect(find.text('Read-only spectator replay'), findsOneWidget);
    expect(find.text('Frame: 1 / 3'), findsOneWidget);
    expect(find.text('Move: 0'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.byTooltip('Next frame'),
      250,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.tap(find.byTooltip('Next frame'));
    await tester.pump();
    expect(find.text('Move: 1'), findsOneWidget);

    await tester.tap(find.byTooltip('Latest frame'));
    await tester.pump();
    expect(find.text('Move: 2'), findsOneWidget);

    expect(controller.game!.board, liveBoard);
    expect(controller.game!.score, liveScore);
    expect(controller.game!.moves, liveMoves);
    expect(controller.game!.rngState, liveRng);
  });

  testWidgets('replay playback pauses without advancing in background',
      (tester) async {
    final controller = await controllerWithReplay();
    await tester.pumpWidget(NovaApp(controller: controller));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Move Replay'));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Play Replay'),
      250,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.tap(find.text('Play Replay'));
    await tester.pump(const Duration(milliseconds: 550));
    expect(find.text('Move: 1'), findsOneWidget);
    expect(find.text('Pause Replay'), findsOneWidget);

    await tester.tap(find.text('Pause Replay'));
    await tester.pump();
    final pausedMove = _visibleMove(tester);
    await tester.pump(const Duration(seconds: 2));
    expect(_visibleMove(tester), pausedMove);
  });

  testWidgets('replay route handles missing game with an empty state',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final controller = AppController(store: LocalStore());
    await controller.initialize();

    await tester.pumpWidget(NovaApp(controller: controller));
    await tester.pumpAndSettle();
    tester.state<NavigatorState>(find.byType(Navigator)).pushNamed('/replay');
    await tester.pumpAndSettle();

    expect(find.text('No game replay is available yet.'), findsOneWidget);
    expect(find.text('Start a game'), findsOneWidget);
  });
}

int _visibleMove(WidgetTester tester) {
  final value = tester
      .widgetList<Text>(find.byType(Text))
      .map((widget) => widget.data)
      .whereType<String>()
      .firstWhere((text) => text.startsWith('Move: '));
  return int.parse(value.substring('Move: '.length));
}
