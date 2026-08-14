import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nova_2048/app/nova_app.dart';
import 'package:nova_2048/app/state/app_controller.dart';
import 'package:nova_2048/data/local_store.dart';
import 'package:nova_2048/domain/game_backup.dart';
import 'package:nova_2048/domain/game_state.dart';
import 'package:nova_2048/domain/game_types.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  GameState backupState() => GameState(
        config: const GameConfig(
          mode: GameMode.classic,
          size: 4,
          seed: 2026,
        ),
        board: [
          [2, 2, 0, 0],
          [0, 0, 0, 0],
          [0, 0, 0, 0],
          [0, 0, 0, 0],
        ],
        score: 32,
        bestScore: 9999,
        moves: 6,
        totalMerges: 3,
        rngState: 88,
        startedAt: DateTime.utc(2026, 8, 14, 10),
      );

  testWidgets('export copies a decodable current-game-only backup',
      (tester) async {
    final controller = AppController(store: LocalStore());
    await controller.initialize();
    await controller.newGame(
      const GameConfig(mode: GameMode.classic, size: 4, seed: 41),
    );

    await tester.pumpWidget(NovaApp(controller: controller));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Game Backup'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Copy game backup'));
    await tester.pump();

    final clipboard = await Clipboard.getData(Clipboard.kTextPlain);
    expect(clipboard?.text, isNotNull);
    final restored = GameBackup.decode(clipboard!.text!);
    expect(restored.toJson(), controller.game!.toJson());
    expect(
      find.text('Current game backup copied to clipboard.'),
      findsOneWidget,
    );
  });

  testWidgets('valid import requires confirmation and becomes unranked',
      (tester) async {
    final controller = AppController(store: LocalStore());
    await controller.initialize();
    controller.stats.bestScore = 128;
    await Clipboard.setData(
      ClipboardData(
        text: GameBackup.encode(
          backupState(),
          exportedAt: DateTime.utc(2026, 8, 14, 11),
        ),
      ),
    );

    await tester.pumpWidget(NovaApp(controller: controller));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Game Backup'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Import from clipboard'));
    await tester.pumpAndSettle();

    expect(find.text('Restore unranked backup?'), findsOneWidget);
    expect(find.text('Restore unranked backup'), findsOneWidget);
    expect(controller.game, isNull);

    await tester.tap(find.text('Restore unranked backup'));
    await tester.pumpAndSettle();

    expect(controller.currentGameIsUnranked, isTrue);
    expect(controller.game!.score, 32);
    expect(controller.game!.moves, 6);
    expect(controller.game!.bestScore, 128);
    expect(controller.stats.bestScore, 128);
  });

  testWidgets('cancelled import leaves an existing ranked game untouched',
      (tester) async {
    final controller = AppController(store: LocalStore());
    await controller.initialize();
    await controller.newGame(
      const GameConfig(mode: GameMode.classic, size: 4, seed: 99),
    );
    final before = controller.game!.toJson();
    await Clipboard.setData(
      ClipboardData(
        text: GameBackup.encode(
          backupState(),
          exportedAt: DateTime.utc(2026, 8, 14, 11),
        ),
      ),
    );

    await tester.pumpWidget(NovaApp(controller: controller));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Game Backup'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Import from clipboard'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(controller.currentGameIsUnranked, isFalse);
    expect(controller.game!.toJson(), before);
  });

  testWidgets('invalid clipboard text is rejected without replacing the game',
      (tester) async {
    final controller = AppController(store: LocalStore());
    await controller.initialize();
    await Clipboard.setData(const ClipboardData(text: '{invalid'));

    await tester.pumpWidget(NovaApp(controller: controller));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Game Backup'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Import from clipboard'));
    await tester.pump();

    expect(controller.game, isNull);
    expect(find.textContaining('Backup rejected:'), findsOneWidget);
  });
}
