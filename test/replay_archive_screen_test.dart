import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nova_2048/app/state/app_controller.dart';
import 'package:nova_2048/app/state/app_scope.dart';
import 'package:nova_2048/core/localization/nova_localizations.dart';
import 'package:nova_2048/data/local_store.dart';
import 'package:nova_2048/domain/game_engine.dart';
import 'package:nova_2048/domain/game_types.dart';
import 'package:nova_2048/domain/replay_archive.dart';
import 'package:nova_2048/features/replay/replay_archive_screen.dart';
import 'package:nova_2048/shared/text_clipboard.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeClipboard implements TextClipboard {
  _FakeClipboard([this.text]);

  String? text;

  @override
  Future<String?> readText() async => text;

  @override
  Future<void> writeText(String text) async {
    this.text = text;
  }
}

void main() {
  const config = GameConfig(mode: GameMode.classic, size: 4, seed: 8080);

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('complete current capture can be copied as valid archive', (
    tester,
  ) async {
    final controller = AppController(store: LocalStore());
    await controller.initialize();
    await controller.newGame(config);
    final clipboard = _FakeClipboard();

    await _pumpScreen(tester, controller, clipboard);

    expect(
      find.text('Complete full-session capture available'),
      findsOneWidget,
    );
    await tester.tap(find.text('Copy full replay'));
    await tester.pumpAndSettle();

    expect(clipboard.text, isNotNull);
    final decoded = ReplayArchive.decode(clipboard.text!);
    expect(decoded.startsAtSessionStart, isTrue);
    expect(
      ReplayArchivePlayer.equivalent(
        ReplayArchivePlayer.build(decoded).last,
        controller.game!,
      ),
      isTrue,
    );
  });

  testWidgets(
    'imported replay stays spectator-only and leaves live state intact',
    (tester) async {
      final controller = AppController(store: LocalStore());
      await controller.initialize();
      await controller.newGame(config);
      final before = controller.game!.copy();
      final statsBefore = controller.stats.toJson();

      const importedConfig = GameConfig(
        mode: GameMode.classic,
        size: 4,
        seed: 9090,
      );
      final engine = GameEngine(config: importedConfig);
      final importedInitial = engine.createGame();
      final importedCurrent = importedInitial.copy();
      final capture = ReplayCapture.start(importedInitial);
      final direction = engine.hint(importedCurrent)!;
      final at = importedInitial.startedAt.add(const Duration(seconds: 1));
      expect(engine.move(importedCurrent, direction, now: at).changed, isTrue);
      capture.appendMove(direction, at);
      final clipboard = _FakeClipboard(
        ReplayArchive.encode(capture, exportedAt: DateTime.utc(2026, 8, 15)),
      );

      await _pumpScreen(tester, controller, clipboard);
      await tester.tap(find.text('Open from clipboard'));
      await tester.pumpAndSettle();

      expect(
        find.text(
          'Imported spectator replay — live player state is untouched.',
        ),
        findsOneWidget,
      );
      expect(ReplayArchivePlayer.equivalent(controller.game!, before), isTrue);
      expect(controller.stats.toJson(), statsBefore);
      expect(find.text('Return to current replay'), findsOneWidget);
    },
  );

  testWidgets('invalid clipboard archive is rejected without changing game', (
    tester,
  ) async {
    final controller = AppController(store: LocalStore());
    await controller.initialize();
    await controller.newGame(config);
    final before = controller.game!.copy();
    final clipboard = _FakeClipboard('{invalid-json');

    await _pumpScreen(tester, controller, clipboard);
    await tester.tap(find.text('Open from clipboard'));
    await tester.pump();

    expect(find.textContaining('Replay rejected:'), findsOneWidget);
    expect(ReplayArchivePlayer.equivalent(controller.game!, before), isTrue);
  });

  testWidgets('Hindi mode localizes full replay archive controls', (
    tester,
  ) async {
    final controller = AppController(store: LocalStore());
    await controller.initialize();
    await controller.updateSettings(
      (settings) => settings.language = AppLanguage.hindi,
    );
    await controller.newGame(config);

    await _pumpScreen(tester, controller, _FakeClipboard());

    expect(find.text('पूर्ण रिप्ले आर्काइव'), findsOneWidget);
    expect(find.text('पूर्ण-सेशन कैप्चर उपलब्ध है'), findsOneWidget);
    expect(find.text('पूर्ण रिप्ले कॉपी करें'), findsOneWidget);
    expect(find.text('क्लिपबोर्ड से खोलें'), findsOneWidget);
  });
}

Future<void> _pumpScreen(
  WidgetTester tester,
  AppController controller,
  TextClipboard clipboard,
) async {
  await tester.pumpWidget(
    AppScope(
      controller: controller,
      child: MaterialApp(
        locale: controller.settings.language.locale,
        supportedLocales: NovaLocalizations.supportedLocales,
        localizationsDelegates: const [
          NovaLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: ReplayArchiveScreen(clipboard: clipboard),
      ),
    ),
  );
  await tester.pumpAndSettle();
}
