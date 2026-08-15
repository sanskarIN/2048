import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nova_2048/app/nova_app.dart';
import 'package:nova_2048/app/state/app_controller.dart';
import 'package:nova_2048/core/localization/nova_localizations.dart';
import 'package:nova_2048/data/local_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Hindi solver demo exposes localized strategy controls', (
    tester,
  ) async {
    final controller = AppController(store: LocalStore());
    await controller.initialize();
    await controller.updateSettings(
      (settings) => settings.language = AppLanguage.hindi,
    );

    await tester.pumpWidget(NovaApp(controller: controller));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('ऑटो प्ले डेमो'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('ऑटो प्ले डेमो'));
    await tester.pumpAndSettle();

    expect(find.text('निर्धारक स्थानीय सॉल्वर प्रदर्शन'), findsOneWidget);
    expect(find.text('रणनीति: ह्यूरिस्टिक'), findsOneWidget);
    expect(find.text('खोज नोड: —'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('ह्यूरिस्टिक'),
      250,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.tap(find.text('ह्यूरिस्टिक'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('एक्सपेक्टिमैक्स').last);
    await tester.pumpAndSettle();

    expect(find.text('रणनीति: एक्सपेक्टिमैक्स'), findsOneWidget);
    expect(controller.stats.gamesPlayed, 0);
    expect(controller.game, isNull);
  });
}
