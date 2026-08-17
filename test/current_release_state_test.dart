import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('current release-candidate records', () {
    test('primary continuity header points at Phase 29 evidence', () {
      final log = File('what_changed.md').readAsStringSync();

      expect(log, contains('**Current phase:** Phase 29'));
      expect(log, contains('232/232 tests'));
      expect(log, contains('105 files formatter-clean'));
      expect(log, contains('32016750775'));
      expect(log, contains('32015893841'));
    });

    test('verification record keeps Phase 29 ahead of Phase 28', () {
      final verification = File('docs/VERIFICATION.md').readAsStringSync();
      final phase29 = verification.indexOf('## Phase 29 —');
      final phase28 = verification.indexOf('## Phase 28 —');

      expect(phase29, greaterThanOrEqualTo(0));
      expect(phase28, greaterThan(phase29));
      expect(verification, contains('Tests: PASS — 232/232'));
    });

    test('roadmap and changelog expose the current CI baseline', () {
      final roadmap = File('ROADMAP.md').readAsStringSync();
      final changelog = File('CHANGELOG.md').readAsStringSync();

      expect(
        roadmap,
        contains('Phase 29 current maintained CI is 232/232 tests'),
      );
      expect(roadmap, isNot(contains('maintained CI is now 208/208 tests')));
      expect(changelog, contains('Maintained CI now passes 232/232 tests'));
    });
  });
}
