import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Android distribution signing', () {
    test('real signing inputs remain local and ignored', () {
      final gitignore = File('.gitignore').readAsStringSync();
      final template = File('android/key.properties.example').readAsStringSync();

      expect(gitignore, contains('android/key.properties'));
      expect(gitignore, contains('*.jks'));
      expect(gitignore, contains('*.keystore'));

      expect(template, contains('storePassword=REPLACE_WITH_STORE_PASSWORD'));
      expect(template, contains('keyPassword=REPLACE_WITH_KEY_PASSWORD'));
      expect(template, contains('keyAlias=upload'));
      expect(template, contains('storeFile=app/upload-keystore.jks'));
    });

    test('release build supports local distribution signing with CI fallback', () {
      final gradle = File('android/app/build.gradle.kts').readAsStringSync();

      expect(gradle, contains('rootProject.file("key.properties")'));
      expect(gradle, contains('val hasDistributionSigning'));
      expect(gradle, contains('if (hasDistributionSigning)'));
      expect(gradle, contains('create("release")'));
      expect(
        gradle,
        contains(
          'storeFile = keystoreProperties.getProperty("storeFile")?.let { '
          'rootProject.file(it) }',
        ),
      );
      expect(gradle, contains('signingConfigs.getByName("release")'));
      expect(gradle, contains('signingConfigs.getByName("debug")'));
    });

    test('tracked signing template never contains a private keystore', () {
      expect(File('android/key.properties').existsSync(), isFalse);
      expect(File('android/app/upload-keystore.jks').existsSync(), isFalse);
    });
  });
}
