import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Android distribution workflow', () {
    late String workflow;

    setUpAll(() {
      workflow = File(
        '.github/workflows/platform-builds.yml',
      ).readAsStringSync();
    });

    test('builds both release APK and Play Store AAB', () {
      expect(workflow, contains('flutter build apk --release'));
      expect(workflow, contains('flutter build appbundle --release'));
      expect(workflow, contains('name: Android release APK and AAB'));
    });

    test('checksums both Android distribution payloads', () {
      expect(
        workflow,
        contains(
          'sha256sum build/app/outputs/flutter-apk/app-release.apk > '
          'build/app/outputs/flutter-apk/app-release.apk.sha256',
        ),
      );
      expect(
        workflow,
        contains(
          'sha256sum build/app/outputs/bundle/release/app-release.aab > '
          'build/app/outputs/bundle/release/app-release.aab.sha256',
        ),
      );
    });

    test('uploads APK AAB and both checksum sidecars', () {
      for (final path in <String>[
        'build/app/outputs/flutter-apk/app-release.apk',
        'build/app/outputs/flutter-apk/app-release.apk.sha256',
        'build/app/outputs/bundle/release/app-release.aab',
        'build/app/outputs/bundle/release/app-release.aab.sha256',
      ]) {
        expect(workflow, contains(path), reason: 'Missing artifact path: $path');
      }
      expect(workflow, contains('name: nova-2048-android-release'));
      expect(workflow, contains('if-no-files-found: error'));
    });
  });
}
