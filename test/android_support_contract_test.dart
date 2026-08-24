import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Android manifest keeps production device/privacy guarantees', () {
    final manifest = File(
      'android/app/src/main/AndroidManifest.xml',
    ).readAsStringSync();

    expect(manifest, contains('android:supportsRtl="true"'));
    expect(manifest, contains('android:resizeableActivity="true"'));
    expect(manifest, contains('android:usesCleartextTraffic="false"'));
    expect(manifest, contains('android:allowBackup="false"'));
    expect(manifest, contains('android:hardwareAccelerated="true"'));
    expect(manifest, contains('android:required="false"'));
    expect(manifest, isNot(contains('android:screenOrientation=')));
  });

  test('Android release config keeps shrinking and Flutter SDK contracts', () {
    final gradle = File('android/app/build.gradle.kts').readAsStringSync();

    expect(gradle, contains('minSdk = flutter.minSdkVersion'));
    expect(gradle, contains('targetSdk = flutter.targetSdkVersion'));
    expect(gradle, contains('isMinifyEnabled = true'));
    expect(gradle, contains('isShrinkResources = true'));
    expect(gradle, contains('proguard-android-optimize.txt'));
    expect(gradle, contains('"proguard-rules.pro"'));
  });

  test('Android CI qualifies universal, split ABI, and AAB output', () {
    final workflow = File(
      '.github/workflows/platform-builds.yml',
    ).readAsStringSync();

    expect(workflow, contains('flutter build apk --release'));
    expect(workflow, contains('flutter build apk --release --split-per-abi'));
    expect(workflow, contains('flutter build appbundle --release'));
    expect(workflow, contains('app-armeabi-v7a-release.apk'));
    expect(workflow, contains('app-arm64-v8a-release.apk'));
    expect(workflow, contains('app-x86_64-release.apk'));
  });

  test('Android support audit passes the repository contract', () async {
    final result = await Process.run(
      Platform.resolvedExecutable,
      const ['run', 'tool/android_support_audit.dart', '--json'],
      workingDirectory: Directory.current.path,
    );

    expect(result.exitCode, 0, reason: '${result.stdout}\n${result.stderr}');
    expect(result.stdout, contains('"androidReady": true'));
  });
}
