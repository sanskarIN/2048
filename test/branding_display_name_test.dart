import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('public branding consistently displays 2048', () {
    final project = File(
      'lib/core/constants/project_info.dart',
    ).readAsStringSync();
    expect(project, contains("static const name = '2048';"));

    for (final path in <String>[
      'lib/app/nova_app.dart',
      'lib/features/home/home_screen.dart',
      'lib/features/about/about_screen.dart',
      'lib/features/support/support_screen.dart',
      'web/index.html',
      'android/app/src/main/AndroidManifest.xml',
      'ios/Runner/Info.plist',
      'macos/Runner/Configs/AppInfo.xcconfig',
      'linux/runner/my_application.cc',
      'windows/runner/main.cpp',
      'windows/runner/Runner.rc',
      'extension/manifest.chromium.template.json',
      'extension/manifest.firefox.template.json',
    ]) {
      final source = File(path).readAsStringSync();
      expect(
        source,
        isNot(contains('2048 Nova')),
        reason: 'Retired display name found in $path',
      );
    }

    final webManifest =
        jsonDecode(File('web/manifest.json').readAsStringSync())
            as Map<String, dynamic>;
    expect(webManifest['name'], '2048');
    expect(webManifest['short_name'], '2048');

    final html = File('web/index.html').readAsStringSync();
    expect(html, contains('<title>2048</title>'));
    expect(
      File('android/app/src/main/AndroidManifest.xml').readAsStringSync(),
      contains('android:label="2048"'),
    );
    expect(
      File('windows/runner/main.cpp').readAsStringSync(),
      contains('window.Create(L"2048"'),
    );
  });

  test('existing package and portable data identifiers remain stable', () {
    expect(
      File('pubspec.yaml').readAsStringSync(),
      contains('name: nova_2048'),
    );
    expect(
      File('android/app/build.gradle.kts').readAsStringSync(),
      contains('applicationId = "com.sanskarin.nova_2048"'),
    );
    expect(
      File('macos/Runner/Configs/AppInfo.xcconfig').readAsStringSync(),
      contains('PRODUCT_BUNDLE_IDENTIFIER = com.sanskarin.nova2048'),
    );
    expect(
      File('lib/domain/challenge_code.dart').readAsStringSync(),
      contains('NOVA1'),
    );
  });
}
