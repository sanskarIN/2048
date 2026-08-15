import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nova_2048/app/nova_app.dart';
import 'package:nova_2048/app/state/app_controller.dart';
import 'package:nova_2048/core/localization/nova_localizations.dart';
import 'package:nova_2048/data/local_store.dart';
import 'package:nova_2048/domain/game_types.dart';
import 'package:nova_2048/features/game/game_board.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('language parser accepts supported values and rejects malformed input',
      () {
    expect(AppLanguageX.parse('system'), AppLanguage.system);
    expect(AppLanguageX.parse('english'), AppLanguage.english);
    expect(AppLanguageX.parse('hindi'), AppLanguage.hindi);
    expect(AppLanguageX.parse('unknown'), AppLanguage.system);
    expect(AppLanguageX.parse(42), AppLanguage.system);
  });

  test('Hindi catalog translates critical product surfaces', () {
    const l10n = NovaLocalizations(Locale('hi'));

    expect(l10n.text('New Game'), 'नया गेम');
    expect(l10n.text('Settings'), 'सेटिंग्स');
    expect(l10n.text('Challenge Codes'), 'चैलेंज कोड');
    expect(l10n.text('Game Backup'), 'गेम बैकअप');
    expect(l10n.text('Move Replay'), 'मूव रिप्ले');
    expect(l10n.text('How to Play'), 'कैसे खेलें');
    expect(l10n.text('Invalid challenge seed'), 'अमान्य चैलेंज सीड');
    expect(l10n.text('Game backup is empty.'), 'गेम बैकअप खाली है।');
  });

  test('Hindi catalog translates advanced solver controls', () {
    const l10n = NovaLocalizations(Locale('hi'));

    expect(
      l10n.text('Deterministic local solver demonstration'),
      'निर्धारक स्थानीय सॉल्वर प्रदर्शन',
    );
    expect(l10n.text('Strategy'), 'रणनीति');
    expect(l10n.text('Search nodes'), 'खोज नोड');
    expect(l10n.text('Heuristic'), 'ह्यूरिस्टिक');
    expect(l10n.text('Expectimax'), 'एक्सपेक्टिमैक्स');
  });

  test('English is identity and missing Hindi strings fall back safely', () {
    const english = NovaLocalizations(Locale('en'));
    const hindi = NovaLocalizations(Locale('hi'));

    expect(english.text('New Game'), 'New Game');
    expect(
        hindi.text('Untranslated future string'), 'Untranslated future string');
  });

  test('localized mode direction and achievement helpers use stable IDs', () {
    const l10n = NovaLocalizations(Locale('hi'));

    expect(l10n.modeName(GameMode.classic), 'क्लासिक');
    expect(l10n.modeName(GameMode.daily), 'डेली चैलेंज');
    expect(l10n.directionName(Direction.left), 'बाएँ');
    expect(l10n.achievementTitle('tile_2048', 'Nova Master'), 'नोवा मास्टर');
    expect(
      l10n.achievementDescription('daily_1', 'fallback'),
      'एक डेली चैलेंज जीतें।',
    );
  });

  test('language preference persists and malformed data falls back to system',
      () async {
    final controller = AppController(store: LocalStore());
    await controller.initialize();
    await controller.updateSettings(
      (settings) => settings.language = AppLanguage.hindi,
    );

    final restored = AppController(store: LocalStore());
    await restored.initialize();
    expect(restored.settings.language, AppLanguage.hindi);

    final malformed = AppSettings.fromJson({'language': 7});
    final unsupported = AppSettings.fromJson({'language': 'esperanto'});
    expect(malformed.language, AppLanguage.system);
    expect(unsupported.language, AppLanguage.system);
  });

  testWidgets('Hindi preference renders localized Home and Settings UI',
      (tester) async {
    final controller = AppController(store: LocalStore());
    await controller.initialize();
    await controller.updateSettings(
      (settings) => settings.language = AppLanguage.hindi,
    );

    await tester.pumpWidget(NovaApp(controller: controller));
    await tester.pumpAndSettle();

    expect(find.text('नया गेम'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('सेटिंग्स'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('सेटिंग्स'));
    await tester.pumpAndSettle();

    expect(find.text('सेटिंग्स'), findsWidgets);
    expect(find.text('भाषा'), findsOneWidget);
    expect(find.text('हिन्दी'), findsOneWidget);
  });

  testWidgets('Hindi board semantics include localized position and value',
      (tester) async {
    final semantics = tester.ensureSemantics();
    try {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('hi'),
          supportedLocales: NovaLocalizations.supportedLocales,
          localizationsDelegates: const [
            NovaLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: const Scaffold(
            body: Center(
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
        ),
      );

      expect(find.bySemanticsLabel('4 बाय 4 गेम बोर्ड'), findsOneWidget);
      expect(
        find.bySemanticsLabel('पंक्ति 1, कॉलम 1, टाइल 2'),
        findsOneWidget,
      );
      expect(find.bySemanticsLabel('पंक्ति 1, कॉलम 2, खाली'), findsOneWidget);
    } finally {
      semantics.dispose();
    }
  });
}
