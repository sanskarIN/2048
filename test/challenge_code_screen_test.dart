import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nova_2048/app/state/app_controller.dart';
import 'package:nova_2048/app/state/app_scope.dart';
import 'package:nova_2048/data/local_store.dart';
import 'package:nova_2048/domain/challenge_code.dart';
import 'package:nova_2048/domain/game_engine.dart';
import 'package:nova_2048/domain/game_types.dart';
import 'package:nova_2048/features/challenge_codes/challenge_code_screen.dart';
import 'package:nova_2048/features/challenge_codes/challenge_code_qr.dart';
import 'package:nova_2048/shared/text_clipboard.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/localized_test_app.dart';

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

  Future<void> pumpScreen(
    WidgetTester tester,
    AppController controller,
    _MemoryClipboard clipboard, {
    int Function()? seedFactory,
    Locale? locale,
  }) async {
    await tester.pumpWidget(
      localizedTestApp(
        locale: locale,
        routes: {'/game': (_) => const Scaffold(body: Text('Challenge game'))},
        home: AppScope(
          controller: controller,
          child: ChallengeCodeScreen(
            clipboard: clipboard,
            seedFactory: seedFactory,
          ),
        ),
      ),
    );
    await tester.pump();
  }

  Future<void> tapVisible(WidgetTester tester, Finder finder) async {
    final scrollable = find.byType(Scrollable).first;
    await tester.scrollUntilVisible(finder, 220, scrollable: scrollable);
    await tester.pump();
    await tester.tap(finder);
    await tester.pump();
  }

  testWidgets('generates and copies a deterministic challenge code', (
    tester,
  ) async {
    final controller = AppController(store: LocalStore());
    final clipboard = _MemoryClipboard();
    await controller.initialize();

    await pumpScreen(tester, controller, clipboard, seedFactory: () => 24680);
    await tapVisible(tester, find.text('Generate new seeded code'));

    final expectedCode = ChallengeCode.encode(
      ChallengeCode.withSeed(GameConfig.preset(GameMode.classic), 24680),
    );
    expect(find.byType(ChallengeCodeQr), findsOneWidget);
    final qrCard = tester.widget<ChallengeCodeQr>(find.byType(ChallengeCodeQr));
    expect(qrCard.code, expectedCode);
    final qrImage = tester.widget<QrImageView>(find.byType(QrImageView));
    expect(qrImage.backgroundColor, Colors.white);
    expect(qrImage.semanticsLabel, 'QR code containing this challenge code');

    await tapVisible(tester, find.text('Copy challenge code'));
    expect(clipboard.text, expectedCode);
    final config = ChallengeCode.decode(clipboard.text!);
    expect(config.mode, GameMode.classic);
    expect(config.size, 4);
    expect(config.seed, 24680);
  });

  testWidgets('generated Challenge Code QR is localized in Hindi', (
    tester,
  ) async {
    final controller = AppController(store: LocalStore());
    final clipboard = _MemoryClipboard();
    await controller.initialize();

    await pumpScreen(
      tester,
      controller,
      clipboard,
      seedFactory: () => 13579,
      locale: const Locale('hi'),
    );
    await tapVisible(tester, find.text('नया सीडेड कोड बनाएँ'));

    expect(find.text('स्कैन करके साझा करें'), findsOneWidget);
    final qr = tester.widget<QrImageView>(find.byType(QrImageView));
    expect(qr.semanticsLabel, 'इस चैलेंज कोड वाला QR कोड');
    expect(controller.game, isNull);
  });

  testWidgets('pastes validates and starts the same seeded challenge', (
    tester,
  ) async {
    final controller = AppController(store: LocalStore());
    final clipboard = _MemoryClipboard();
    await controller.initialize();
    final shared = ChallengeCode.withSeed(
      GameConfig.preset(GameMode.quick),
      424242,
    );
    clipboard.text = ChallengeCode.encode(shared);

    await pumpScreen(tester, controller, clipboard);
    await tapVisible(tester, find.text('Paste code'));

    expect(find.text('Valid challenge code.'), findsOneWidget);
    expect(find.text('Quick 3×3'), findsOneWidget);
    await tapVisible(tester, find.text('Start this challenge'));
    await tester.pumpAndSettle();

    expect(controller.game, isNotNull);
    expect(controller.game!.config.toJson(), shared.toJson());
    final expected = GameEngine(config: shared).createGame();
    expect(controller.game!.board, expected.board);
    expect(controller.game!.rngState, expected.rngState);
    expect(find.text('Challenge game'), findsOneWidget);
  });

  testWidgets('invalid pasted code is rejected without creating a game', (
    tester,
  ) async {
    final controller = AppController(store: LocalStore());
    final clipboard = _MemoryClipboard()..text = 'not-a-challenge-code';
    await controller.initialize();

    await pumpScreen(tester, controller, clipboard);
    await tapVisible(tester, find.text('Paste code'));

    expect(controller.game, isNull);
    expect(find.text('Unsupported challenge code format'), findsOneWidget);
    expect(find.text('Start this challenge'), findsNothing);
  });

  testWidgets('replacement cancellation preserves the current game', (
    tester,
  ) async {
    final controller = AppController(store: LocalStore());
    final clipboard = _MemoryClipboard();
    await controller.initialize();
    await controller.newGame(
      const GameConfig(mode: GameMode.classic, size: 4, seed: 99),
    );
    final before = controller.game!.toJson();
    clipboard.text = ChallengeCode.encode(
      ChallengeCode.withSeed(GameConfig.preset(GameMode.extended), 1234),
    );

    await pumpScreen(tester, controller, clipboard);
    await tapVisible(tester, find.text('Paste code'));
    await tapVisible(tester, find.text('Start this challenge'));

    expect(find.text('Replace current game?'), findsOneWidget);
    await tester.tap(find.text('Keep current game'));
    await tester.pumpAndSettle();

    expect(controller.game!.toJson(), before);
    expect(find.text('Challenge Codes'), findsOneWidget);
  });
}
