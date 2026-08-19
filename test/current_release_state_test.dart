import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('current release-candidate records', () {
    test('primary continuity header points at Phase 32 state', () {
      final log = File('what_changed.md').readAsStringSync();

      expect(log, contains('**Current phase:** Phase 32'));
      expect(log, contains('Version 2.0.12 migration'));
      expect(log, contains('`2.0.12+2012`'));
      expect(log, contains('`2.0.12`'));
      expect(log, contains('stable qualification boundary remains 0/13'));
      expect(log, contains('32018055661'));
      expect(log, contains('32015893841'));
      expect(
        log,
        contains(
          'historical baseline evidence until a complete maintained Version 2.0.12',
        ),
      );
    });

    test('historical continuity through Phase 31 remains preserved', () {
      final phase00To30 = File('what_changed_archive_phase_00_30.md');
      final phase31 = File('what_changed_archive_phase_31.md');

      expect(phase00To30.existsSync(), isTrue);
      expect(phase31.existsSync(), isTrue);

      final earlyHistory = phase00To30.readAsStringSync();
      final phase31History = phase31.readAsStringSync();
      expect(earlyHistory, contains('# 2048 Nova — Development Log'));
      expect(earlyHistory, contains('Phase 30'));
      expect(phase31History, contains('Current phase:** Phase 31'));
      expect(phase31History, contains('Semantic fail-closed PWA audit'));
      expect(
        phase31History,
        contains('stable qualification boundary remains 0/13'),
      );
    });

    test('Version 2.0.12 package and runtime metadata stay aligned', () {
      final pubspec = File('pubspec.yaml').readAsStringSync();
      final projectInfo = File(
        'lib/core/constants/project_info.dart',
      ).readAsStringSync();
      final manifest =
          jsonDecode(File('docs/release_qualification.json').readAsStringSync())
              as Map<String, dynamic>;
      final windows = File('windows/runner/Runner.rc').readAsStringSync();

      expect(pubspec, contains('version: 2.0.12+2012'));
      expect(projectInfo, contains("static const version = '2.0.12';"));
      expect(manifest['candidate'], '2.0.12+2012');
      expect(windows, contains('#define VERSION_AS_NUMBER 2,0,12,2012'));
      expect(windows, contains('#define VERSION_AS_STRING "2.0.12"'));
    });

    test('verification record keeps prior accepted evidence historical', () {
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

    test(
      'phase 31 qualification status reporter remains indexed and read-only',
      () {
        final ci = File('.github/workflows/ci.yml').readAsStringSync();
        final docsIndex = File('docs/README.md').readAsStringSync();
        final qualification = File(
          'docs/RELEASE_QUALIFICATION.md',
        ).readAsStringSync();
        final manifest = File(
          'docs/release_qualification.json',
        ).readAsStringSync();

        expect(
          File('tool/release_qualification_status.dart').existsSync(),
          isTrue,
        );
        expect(File('docs/QUALIFICATION_STATUS.md').existsSync(), isTrue);
        expect(File('docs/PHASE_31_VERIFICATION.md').existsSync(), isTrue);
        expect(docsIndex, contains('QUALIFICATION_STATUS.md'));
        expect(docsIndex, contains('PHASE_31_VERIFICATION.md'));
        expect(
          qualification,
          contains('release_qualification_status.dart --pending-only'),
        );
        expect(
          ci,
          contains(
            'dart run tool/release_qualification_status.dart --json --pending-only',
          ),
        );
        expect(manifest, isNot(contains('"status": "passed"')));
      },
    );

    test('Phase 32 version migration documentation is source-controlled', () {
      final phase32 = File('docs/PHASE_32_VERSION_2_0_12.md');
      final docsIndex = File('docs/README.md').readAsStringSync();
      final roadmap = File('ROADMAP.md').readAsStringSync();
      final qualification = File(
        'docs/RELEASE_QUALIFICATION.md',
      ).readAsStringSync();

      expect(phase32.existsSync(), isTrue);
      expect(phase32.readAsStringSync(), contains('2.0.12+2012'));
      expect(docsIndex, contains('PHASE_32_VERSION_2_0_12.md'));
      expect(roadmap, contains('## 2.0.12 — Current release hardening'));
      expect(
        roadmap,
        contains('Remaining release qualification before `2.0.12`'),
      );
      expect(qualification, contains('stable `2.0.12` release'));
      expect(qualification, contains('`2.0.12+2012`'));
    });

    test('Web PWA metadata hardening remains source-controlled', () {
      final manifest =
          jsonDecode(File('web/manifest.json').readAsStringSync())
              as Map<String, dynamic>;
      final index = File('web/index.html').readAsStringSync();
      final docsIndex = File('docs/README.md').readAsStringSync();

      expect(manifest['id'], '.');
      expect(manifest['start_url'], '.');
      expect(manifest['scope'], '.');
      expect(manifest['lang'], 'en');
      expect(manifest['dir'], 'ltr');
      expect((manifest['icons'] as List<dynamic>), hasLength(4));
      expect(index, contains('<html lang="en">'));
      expect(index, contains('mobile-web-app-capable'));
      expect(index, contains('apple-touch-icon'));
      expect(File('docs/PWA.md').existsSync(), isTrue);
      expect(docsIndex, contains('PWA.md'));
    });

    test('repository integrity audit remains wired into permanent CI', () {
      final ci = File('.github/workflows/ci.yml').readAsStringSync();
      final audit = File('tool/repository_audit.dart').readAsStringSync();

      expect(audit, contains('2048 Nova repository integrity audit'));
      expect(audit, contains('Broken local Markdown link'));
      expect(audit, contains('ProjectInfo.version'));
      expect(audit, contains('what_changed_archive_phase_00_30.md'));
      expect(audit, contains('what_changed_archive_phase_31.md'));
      expect(audit, contains('2.0.12+2012'));
      expect(audit, contains('windows/runner/Runner.rc'));
      expect(audit, contains('web/manifest.json'));
      expect(ci, contains('dart run tool/repository_audit.dart --json'));
    });

    test('temporary phase maintenance helpers do not remain', () {
      expect(
        File('.github/workflows/phase30-continuity.yml').existsSync(),
        isFalse,
      );
      expect(
        File('.github/workflows/phase30-finalize.yml').existsSync(),
        isFalse,
      );
      expect(File('docs/PHASE_30_INDEX_TRIGGER.md').existsSync(), isFalse);
      expect(
        File('.github/workflows/phase31-finalize.yml').existsSync(),
        isFalse,
      );
      expect(File('docs/PHASE_31_STATUS_TRIGGER.md').existsSync(), isFalse);
      expect(File('tool/phase31_finalize.py').existsSync(), isFalse);
      expect(
        File('.github/workflows/phase32-finalize.yml').existsSync(),
        isFalse,
      );
      expect(File('docs/PHASE_32_TRIGGER.md').existsSync(), isFalse);
      expect(File('tool/phase32_finalize.py').existsSync(), isFalse);
    });

    test('roadmap and About expose the current release line safely', () {
      final roadmap = File('ROADMAP.md').readAsStringSync();
      final changelog = File('CHANGELOG.md').readAsStringSync();
      final about = File(
        'lib/features/about/about_screen.dart',
      ).readAsStringSync();

      expect(roadmap, contains('Version 2.0.12 migration aligns'));
      expect(roadmap, contains('235/235 tests'));
      expect(changelog, contains('## [Unreleased]'));
      expect(
        about,
        contains('Version \${ProjectInfo.version} release candidate'),
      );
      expect(about, isNot(contains('Release candidate 0.9')));
    });
  });
}
