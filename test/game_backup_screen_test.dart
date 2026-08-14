import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nova_2048/app/state/app_controller.dart';
import 'package:nova_2048/app/state/app_scope.dart';
import 'package:nova_2048/data/local_store.dart';
import 'package:nova_2048/domain/game_backup.dart';
import 'package:nova_2048/domain/game_state.dart';
import 'package:nova_2048/domain/game_types.dart';
import 'package:nova_2048/features/backup/game_backup_screen.dart';
import 'package:nova_2048/shared/text_clipboard.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _MemoryClipboard implements TextClipboard {
  String? text;

  @override
  Future<String?> readText() async => text;

  @override
  Future<void> writeText(String text) async {
    this.text = text;
  }
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Future<void> pumpUi(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
  }

  Future<void> tapPageAction(WidgetTester tester, Finder finder) async {
    final pageList = find.byType(ListView);
    await tester.drag(pageList, const Offset(0, -260));
    await tester.pump();
    await tester.tap(finder);
  }

  Future<void> pumpBackupScreen(
    WidgetTester tester,
    AppController controller,
    TextClipboard clipboard,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        routes: {
          '/game': (_) => const Scaffold(body: Text('Game destination')),
        },
        home: AppScope(
          controller: controller,
          child: GameBackupScreen(clipboard: clipboard),
        ),
      ),
    );
    await tester.pump();
  }

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
    final clipboard = _MemoryClipboard();
    await controller.initialize();
    await controller.newGame(
      const GameConfig(mode: GameMode.classic, size: 4, seed: 41),
    );

    await pumpBackupScreen(tester, controller, clipboard);
    await tapPageAction(tester, find.text('Copy game backup'));
    await pumpUi(tester);

    expect(clipboard.text, isNotNull);
    final restored = GameBackup.decode(clipboard.text!);
    expect(restored.toJson(), controller.game!.toJson());
    expect(
      find.text('Current game backup copied to clipboard.'),
      findsOneWidget,
    );
  });

  testWidgets('valid import requires confirmation and becomes unranked',
      (tester) async {
    final controller = AppController(store: LocalStore());
    final clipboard = _MemoryClipboard();
    await controller.initialize();
    controller.stats.bestScore = 128;
    clipboard.text = GameBackup.encode(
      backupState(),
      exportedAt: DateTime.utc(2026, 8, 14, 11),
    );

    await pumpBackupScreen(tester, controller, clipboard);
    await tapPageAction(tester, find.text('Import from clipboard'));
    await pumpUi(tester);

    expect(find.text('Restore unranked backup?'), findsOneWidget);
    expect(find.text('Restore unranked backup'), findsOneWidget);
    expect(controller.game, isNull);

    await tester.tap(find.text('Restore unranked backup'));
    await pumpUi(tester);

    expect(controller.currentGameIsUnranked, isTrue);
    expect(controller.game!.score, 32);
    expect(controller.game!.moves, 6);
    expect(controller.game!.bestScore, 128);
    expect(controller.stats.bestScore, 128);
    expect(find.text('Game destination'), findsOneWidget);
  });

  testWidgets('cancelled import leaves an existing ranked game untouched',
      (tester) async {
    final controller = AppController(store: LocalStore());
    final clipboard = _MemoryClipboard();
    await controller.initialize();
    await controller.newGame(
      const GameConfig(mode: GameMode.classic, size: 4, seed: 99),
    );
    final before = controller.game!.toJson();
    clipboard.text = GameBackup.encode(
      backupState(),
      exportedAt: DateTime.utc(2026, 8, 14, 11),
    );

    await pumpBackupScreen(tester, controller, clipboard);
    await tapPageAction(tester, find.text('Import from clipboard'));
    await pumpUi(tester);
    await tester.tap(find.text('Cancel'));
    await pumpUi(tester);

    expect(controller.currentGameIsUnranked, isFalse);
    expect(controller.game!.toJson(), before);
  });

  testWidgets('invalid clipboard text is rejected without replacing the game',
      (tester) async {
    final controller = AppController(store: LocalStore());
    final clipboard = _MemoryClipboard()..text = '{invalid';
    await controller.initialize();

    await pumpBackupScreen(tester, controller, clipboard);
    await tapPageAction(tester, find.text('Import from clipboard'));
    await pumpUi(tester);

    expect(controller.game, isNull);
    expect(find.textContaining('Backup rejected:'), findsOneWidget);
  });
}
