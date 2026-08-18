import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('current release-candidate records', () {
    test('primary continuity header points at Phase 30 state', () {
      final log = File('what_changed.md').readAsStringSync();

      expect(log, contains('**Current phase:** Phase 30'));
      expect(log, contains('guarded release-qualification evidence recorder'));
      expect(
        log,
        contains('latest previously accepted full CI/native evidence'),
      );
      expect(log, contains('stable qualification boundary remains 0/13'));
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

    test('phase 30 qualification recorder remains indexed and fail-closed', () {
      final readme = File('README.md').readAsStringSync();
      final docsIndex = File('docs/README.md').readAsStringSync();
      final qualification = File(
        'docs/RELEASE_QUALIFICATION.md',
      ).readAsStringSync();
      final manifest = File(
        'docs/release_qualification.json',
      ).readAsStringSync();

      expect(
        File('tool/record_release_qualification.dart').existsSync(),
        isTrue,
      );
      expect(File('docs/QUALIFICATION_RECORDER.md').existsSync(), isTrue);
      expect(File('docs/PHASE_30_VERIFICATION.md').existsSync(), isTrue);
      expect(readme, contains('docs/QUALIFICATION_RECORDER.md'));
      expect(docsIndex, contains('QUALIFICATION_RECORDER.md'));
      expect(docsIndex, contains('PHASE_30_VERIFICATION.md'));
      expect(
        qualification,
        contains('record_release_qualification.dart --list'),
      );
      expect(manifest, isNot(contains('"status": "passed"')));
    });

    test('repository integrity audit remains wired into permanent CI', () {
      final ci = File('.github/workflows/ci.yml').readAsStringSync();
      final audit = File('tool/repository_audit.dart').readAsStringSync();

      expect(audit, contains('2048 Nova repository integrity audit'));
      expect(audit, contains('Broken local Markdown link'));
      expect(audit, contains('ProjectInfo.version'));
      expect(ci, contains('dart run tool/repository_audit.dart --json'));
    });

    test('temporary phase 30 finalizer files do not remain', () {
      expect(
        File('.github/workflows/phase30-continuity.yml').existsSync(),
        isFalse,
      );
      expect(
        File('.github/workflows/phase30-finalize.yml').existsSync(),
        isFalse,
      );
      expect(File('docs/PHASE_30_INDEX_TRIGGER.md').existsSync(), isFalse);
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
