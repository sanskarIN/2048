import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nova_2048/features/game/game_board.dart';

void main() {
  testWidgets('board exposes size and positional tile semantics', (tester) async {
    final semantics = tester.ensureSemantics();
    addTearDown(semantics.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox.square(
              dimension: 320,
              child: GameBoard(
                reducedMotion: true,
                board: const [
                  [2, 0, 0, 0],
                  [0, 4, 0, 0],
                  [0, 0, 0, 0],
                  [0, 0, 0, 0],
                ],
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.bySemanticsLabel('4 by 4 game board'), findsOneWidget);
    expect(find.bySemanticsLabel('Row 1, column 1, tile 2'), findsOneWidget);
    expect(find.bySemanticsLabel('Row 1, column 2, empty'), findsOneWidget);
    expect(find.bySemanticsLabel('Row 2, column 2, tile 4'), findsOneWidget);
  });
}
