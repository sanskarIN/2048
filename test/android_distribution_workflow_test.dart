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
      expect(workflow, contains('name: Android release APK, split APKs, and AAB'));
    });

    test('checksums universal and split APKs plus Play Store AAB', () {
      expect(workflow, contains('sha256sum \\'));
      expect(workflow, contains('app-release.apk \\'));
      expect(workflow, contains('app-arm64-v8a-release.apk \\'));
      expect(workflow, contains('app-x86_64-release.apk > SHA256SUMS'));
      expect(
        workflow,
        contains('sha256sum app-release.aab > app-release.aab.sha256'),
      );
    });

    test('uploads universal/split APKs, AAB and checksum records', () {
      for (final path in <String>[
        'build/app/outputs/flutter-apk/app-release.apk',
        'build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk',
        'build/app/outputs/flutter-apk/app-arm64-v8a-release.apk',
        'build/app/outputs/flutter-apk/app-x86_64-release.apk',
        'build/app/outputs/flutter-apk/SHA256SUMS',
        'build/app/outputs/bundle/release/app-release.aab',
        'build/app/outputs/bundle/release/app-release.aab.sha256',
      ]) {
        expect(
          workflow,
          contains(path),
          reason: 'Missing artifact path: $path',
        );
      }
      expect(workflow, contains('name: nova-2048-android-release'));
      expect(workflow, contains('if-no-files-found: error'));
    });
  });
}
