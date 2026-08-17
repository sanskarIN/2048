import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('current release-candidate records', () {
    test('primary continuity header points at Phase 29 evidence', () {
      final log = File('what_changed.md').readAsStringSync();

      expect(log, contains('**Current phase:** Phase 29'));
      expect(log, contains('235/235 tests'));
      expect(log, contains('106 files formatter-clean'));
      expect(log, contains('32018055661'));
      expect(log, contains('32015893841'));
    });

    test('verification record keeps Phase 29 ahead of Phase 28', () {
      final verification = File('docs/VERIFICATION.md').readAsStringSync();
      final phase29 = verification.indexOf('## Phase 29 —');
      final phase28 = verification.indexOf('## Phase 28 —');

      expect(phase29, greaterThanOrEqualTo(0));
      expect(phase28, greaterThan(phase29));
      expect(verification, contains('Tests: PASS — 235/235'));
    });

    test('roadmap, changelog, and About expose the current release line', () {
      final roadmap = File('ROADMAP.md').readAsStringSync();
      final changelog = File('CHANGELOG.md').readAsStringSync();
      final about = File(
        'lib/features/about/about_screen.dart',
      ).readAsStringSync();

      expect(
        roadmap,
        contains('Final Version 1.5 candidate CI is 235/235 tests'),
      );
      expect(roadmap, isNot(contains('maintained CI is now 208/208 tests')));
      expect(
        changelog,
        contains('Final Version 1.5 candidate CI passes 235/235 tests'),
      );
      expect(
        about,
        contains('Version \${ProjectInfo.version} release candidate'),
      );
      expect(about, isNot(contains('Release candidate 0.9')));
    });
  });
}
