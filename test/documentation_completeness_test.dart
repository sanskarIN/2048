import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  const requiredDocumentation = <String>[
    'docs/setup/README.md',
    'docs/setup/PREREQUISITES.md',
    'docs/setup/WINDOWS.md',
    'docs/setup/MACOS.md',
    'docs/setup/LINUX.md',
    'docs/setup/ANDROID.md',
    'docs/setup/UPGRADING_AND_SUPPORT.md',
    'docs/setup/TOOL_SUPPORT_MATRIX.md',
    'docs/DOCUMENTATION_READING_GUIDE.md',
    'docs/COMMAND_REFERENCE.md',
    'docs/GLOSSARY.md',
    'docs/REPOSITORY_FILE_ATLAS.md',
    'docs/FILE_COVERAGE_CONTRACT.md',
    'docs/FEATURE_REFERENCE.md',
    'docs/BUILDING_EXECUTABLES.md',
    'docs/README.md',
    'what_changed.md',
    'what_changed_archive_phase_32.md',
  ];

  test('complete setup and reference documentation is tracked in source tree', () {
    for (final path in requiredDocumentation) {
      expect(
        File(path).existsSync(),
        isTrue,
        reason: 'Required documentation is missing: $path',
      );
    }
  });

  test('current build handbook uses the Version 2.0.12 package identity', () {
    final handbook = File('docs/BUILDING_EXECUTABLES.md').readAsStringSync();

    expect(handbook, contains('2.0.12+2012'));
    expect(handbook, contains('Marketing version: 2.0.12'));
    expect(handbook, isNot(contains('version: 1.5.0+15')));
  });

  test('setup index links lifecycle, support, command, and file references', () {
    final setupIndex = File('docs/setup/README.md').readAsStringSync();

    expect(setupIndex, contains('UPGRADING_AND_SUPPORT.md'));
    expect(setupIndex, contains('TOOL_SUPPORT_MATRIX.md'));
    expect(setupIndex, contains('../DOCUMENTATION_READING_GUIDE.md'));
    expect(setupIndex, contains('../COMMAND_REFERENCE.md'));
    expect(setupIndex, contains('../GLOSSARY.md'));
    expect(setupIndex, contains('../REPOSITORY_FILE_ATLAS.md'));
    expect(setupIndex, contains('../FILE_COVERAGE_CONTRACT.md'));
  });

  test('canonical docs index exposes the deep setup documentation', () {
    final docsIndex = File('docs/README.md').readAsStringSync();

    for (final path in <String>[
      'setup/PREREQUISITES.md',
      'setup/WINDOWS.md',
      'setup/MACOS.md',
      'setup/LINUX.md',
      'setup/ANDROID.md',
      'setup/UPGRADING_AND_SUPPORT.md',
      'setup/TOOL_SUPPORT_MATRIX.md',
      'DOCUMENTATION_READING_GUIDE.md',
      'COMMAND_REFERENCE.md',
      'GLOSSARY.md',
      'REPOSITORY_FILE_ATLAS.md',
      'FILE_COVERAGE_CONTRACT.md',
    ]) {
      expect(
        docsIndex,
        contains(path),
        reason: 'Canonical documentation index does not expose $path',
      );
    }
  });

  test('feature reference covers the completed product surface', () {
    final featureReference = File('docs/FEATURE_REFERENCE.md').readAsStringSync();

    for (final feature in <String>[
      'Ten game modes',
      'Save and resume',
      'Undo',
      'Hint',
      'Expectimax solver',
      'Auto Play',
      'Full Replay Archives',
      'Challenge Codes',
      'English/Hindi localization',
      'Accessibility controls',
      'Platform support',
      'Release readiness',
    ]) {
      expect(
        featureReference,
        contains(feature),
        reason: 'Feature reference is missing: $feature',
      );
    }
  });

  test('tool lifecycle guide protects the compatibility-first workflow', () {
    final lifecycle = File(
      'docs/setup/UPGRADING_AND_SUPPORT.md',
    ).readAsStringSync();

    expect(lifecycle, contains('End of support / EOL'));
    expect(lifecycle, contains('Safe upgrade workflow'));
    expect(lifecycle, contains('Rollback strategy'));
    expect(lifecycle, contains('CI baseline updates'));
    expect(lifecycle, contains('flutter analyze'));
    expect(lifecycle, contains('flutter test --coverage'));
    expect(lifecycle, contains('repository_audit.dart --json'));
    expect(lifecycle, contains('source_completion_audit.dart --json'));
  });

  test(
    'tool support matrix keeps current project pins and upgrade checks visible',
    () {
      final matrix = File(
        'docs/setup/TOOL_SUPPORT_MATRIX.md',
      ).readAsStringSync();

      for (final requiredText in <String>[
        '2.0.12+2012',
        '>=3.9.0 <4.0.0',
        '>=3.35.0',
        '3.47.0',
        '9.1.0',
        '2.4.10',
        '9.7.0',
        'flutter doctor -v',
        'java -version',
        './gradlew --version',
        'xcodebuild -version',
        'pod --version',
        'cmake --version',
        'ninja --version',
        'flutter pub outdated',
        'Standard post-upgrade verification',
      ]) {
        expect(
          matrix,
          contains(requiredText),
          reason: 'Tool support matrix is missing: $requiredText',
        );
      }
    },
  );

  test(
    'documentation reading guide explains notation instead of blind copying',
    () {
      final readingGuide = File(
        'docs/DOCUMENTATION_READING_GUIDE.md',
      ).readAsStringSync();

      for (final requiredText in <String>[
        'Inline code',
        'Fenced code blocks',
        'Placeholders and angle brackets',
        'Relative path',
        'Absolute path',
        '`PATH`',
        'Pipes (`|`)',
        'Exit codes',
        'Version constraints',
        'Source of truth',
        'Read-only versus mutating commands',
        'Copying commands safely',
      ]) {
        expect(
          readingGuide,
          contains(requiredText),
          reason: 'Documentation reading guide is missing: $requiredText',
        );
      }
    },
  );

  test('file coverage contract preserves the no-skip tracked-file rule', () {
    final coverage = File(
      'docs/FILE_COVERAGE_CONTRACT.md',
    ).readAsStringSync();

    for (final requiredText in <String>[
      'git ls-files',
      'Exact-file coverage',
      'Explicit file-family coverage',
      'Generated/platform-template coverage',
      'Historical/archive coverage',
      'Top-level coverage boundaries',
      'New-file rule',
      'Rename and deletion rule',
      'documentation_completeness_test.dart',
    ]) {
      expect(
        coverage,
        contains(requiredText),
        reason: 'File coverage contract is missing: $requiredText',
      );
    }
  });

  test('active continuity points to the preserved Phase 32 archive', () {
    final continuity = File('what_changed.md').readAsStringSync();

    expect(continuity, contains('Phase 33'));
    expect(continuity, contains('what_changed_archive_phase_32.md'));
    expect(continuity, contains('stable qualification boundary remains 0/13'));
  });
}
