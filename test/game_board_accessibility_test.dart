import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nova_2048/features/game/game_board.dart';

import 'support/localized_test_app.dart';

void main() {
  testWidgets('board exposes size and positional tile semantics',
      (tester) async {
    final semantics = tester.ensureSemantics();
    try {
      await tester.pumpWidget(
        localizedTestApp(
          home: const Center(
            child: SizedBox.square(
              dimension: 320,
              child: GameBoard(
                reducedMotion: true,
                board: [
                  [2, 0, 0, 0],
                  [0, 4, 0, 0],
                  [0, 0, 0, 0],
                  [0, 0, 0, 0],
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.bySemanticsLabel('4 by 4 game board'), findsOneWidget);
      expect(find.bySemanticsLabel('Row 1, column 1, tile 2'), findsOneWidget);
      expect(find.bySemanticsLabel('Row 1, column 2, empty'), findsOneWidget);
      expect(find.bySemanticsLabel('Row 2, column 2, tile 4'), findsOneWidget);
    } finally {
      semantics.dispose();
    }
  });
}
