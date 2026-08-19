import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  const requiredDocumentation = <String>[
    'docs/setup/README.md',
    'docs/setup/PREREQUISITES.md',
    'docs/setup/WINDOWS.md',
    'docs/setup/MACOS.md',
    'docs/setup/LINUX.md',
    'docs/setup/LINUX_NATIVE_TOOLCHAIN.md',
    'docs/setup/ANDROID.md',
    'docs/setup/UPGRADING_AND_SUPPORT.md',
    'docs/setup/TOOL_SUPPORT_MATRIX.md',
    'docs/DOCUMENTATION_READING_GUIDE.md',
    'docs/COMMAND_REFERENCE.md',
    'docs/GLOSSARY.md',
    'docs/REPOSITORY_FILE_ATLAS.md',
    'docs/FILE_COVERAGE_CONTRACT.md',
    'docs/FEATURE_REFERENCE.md',
    'docs/ARCHITECTURE_WALKTHROUGH.md',
    'docs/NEW_CONTRIBUTOR_TUTORIAL.md',
    'docs/ERROR_REFERENCE.md',
    'docs/DOCUMENTATION_AUDIT_CHECKLIST.md',
    'docs/CUSTOM_GAME_BUILDER.md',
    'docs/VERSION_1_6_ROADMAP.md',
    'docs/FINAL_2_0_12_INTEGRATION_AUDIT.md',
    'docs/BUILDING_EXECUTABLES.md',
    'docs/USER_GUIDE.md',
    'docs/README.md',
    'what_changed.md',
    'what_changed_archive_phase_32.md',
    'what_changed_archive_phase_33.md',
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

  test('setup index links lifecycle, native Linux, and deep references', () {
    final setupIndex = File('docs/setup/README.md').readAsStringSync();

    for (final path in <String>[
      'LINUX_NATIVE_TOOLCHAIN.md',
      'UPGRADING_AND_SUPPORT.md',
      'TOOL_SUPPORT_MATRIX.md',
      '../DOCUMENTATION_READING_GUIDE.md',
      '../COMMAND_REFERENCE.md',
      '../GLOSSARY.md',
      '../REPOSITORY_FILE_ATLAS.md',
      '../FILE_COVERAGE_CONTRACT.md',
      '../NEW_CONTRIBUTOR_TUTORIAL.md',
      '../ERROR_REFERENCE.md',
    ]) {
      expect(
        setupIndex,
        contains(path),
        reason: 'Setup index does not expose $path',
      );
    }
  });

  test('canonical docs index exposes the complete final documentation set', () {
    final docsIndex = File('docs/README.md').readAsStringSync();

    for (final path in <String>[
      'setup/PREREQUISITES.md',
      'setup/WINDOWS.md',
      'setup/MACOS.md',
      'setup/LINUX.md',
      'setup/LINUX_NATIVE_TOOLCHAIN.md',
      'setup/ANDROID.md',
      'setup/UPGRADING_AND_SUPPORT.md',
      'setup/TOOL_SUPPORT_MATRIX.md',
      'DOCUMENTATION_READING_GUIDE.md',
      'COMMAND_REFERENCE.md',
      'GLOSSARY.md',
      'REPOSITORY_FILE_ATLAS.md',
      'FILE_COVERAGE_CONTRACT.md',
      'NEW_CONTRIBUTOR_TUTORIAL.md',
      'ARCHITECTURE_WALKTHROUGH.md',
      'ERROR_REFERENCE.md',
      'DOCUMENTATION_AUDIT_CHECKLIST.md',
      'CUSTOM_GAME_BUILDER.md',
      'FINAL_2_0_12_INTEGRATION_AUDIT.md',
      '../what_changed_archive_phase_33.md',
    ]) {
      expect(
        docsIndex,
        contains(path),
        reason: 'Canonical documentation index does not expose $path',
      );
    }
  });

  test('canonical source map exposes custom game implementation ownership', () {
    final docsIndex = File('docs/README.md').readAsStringSync();

    for (final path in <String>[
      '../lib/domain/custom_game_preset.dart',
      '../lib/data/custom_preset_store.dart',
      '../lib/features/modes/custom_game_builder_screen.dart',
    ]) {
      expect(
        docsIndex,
        contains(path),
        reason: 'Canonical source map does not expose $path',
      );
    }
  });

  test('feature reference covers the completed product surface', () {
    final featureReference = File('docs/FEATURE_REFERENCE.md').readAsStringSync();

    for (final feature in <String>[
      'Ten game modes',
      'Custom Game Builder',
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

    expect(featureReference, contains('cannot overwrite built-in per-mode'));
    expect(featureReference, contains('Duplicate preset'));
  });

  test('user guide exposes the complete custom preset workflow and policy', () {
    final userGuide = File('docs/USER_GUIDE.md').readAsStringSync();

    for (final requiredText in <String>[
      'Custom Game Builder',
      'Play without saving',
      'Save a preset',
      'Edit a saved preset',
      'Cancel an edit',
      'Duplicate a saved preset',
      'Delete a saved preset',
      'Custom-session records',
      'Sharing boundary',
      'built-in per-mode',
    ]) {
      expect(
        userGuide,
        contains(requiredText),
        reason: 'User guide is missing: $requiredText',
      );
    }

    expect(userGuide, isNot(contains('before stable 1.0.0')));
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

  test('custom game documentation is current and covers final workflows', () {
    final customBuilder = File('docs/CUSTOM_GAME_BUILDER.md').readAsStringSync();

    for (final requiredText in <String>[
      '2.0.12+2012',
      'Edit preset',
      'Duplicate preset',
      'Cancel edit',
      'Save changes',
      'case-insensitively unique',
      'built-in per-mode',
      'Challenge Code boundary',
      'narrow',
      'large-text',
    ]) {
      expect(
        customBuilder,
        contains(requiredText),
        reason: 'Custom Game Builder documentation is missing: $requiredText',
      );
    }

    expect(
      customBuilder,
      isNot(contains('Version 1.6 feature branch documentation')),
    );
    expect(
      customBuilder,
      isNot(contains('not part of the qualified Version 1.5 release candidate')),
    );
  });

  test('Version 1.6 roadmap is explicitly historical instead of current', () {
    final historicalRoadmap = File(
      'docs/VERSION_1_6_ROADMAP.md',
    ).readAsStringSync();

    expect(historicalRoadmap, contains('Historical record'));
    expect(historicalRoadmap, contains('2.0.12+2012'));
    expect(historicalRoadmap, contains('closed as an active roadmap'));
    expect(
      historicalRoadmap,
      isNot(contains('Version 1.5 remains the current release-candidate line')),
    );
  });

  test('final integration audit preserves same-commit evidence boundary', () {
    final audit = File(
      'docs/FINAL_2_0_12_INTEGRATION_AUDIT.md',
    ).readAsStringSync();

    for (final requiredText in <String>[
      '2.0.12+2012',
      'f81076e614b5802af4024588047dd0ba11ce4ce6',
      '1.5.0+15',
      'Edit preset',
      'Duplicate preset',
      'same-commit',
      '0/13',
      'Dependency Review',
      'Android APK + AAB',
      'unsigned iOS',
    ]) {
      expect(
        audit,
        contains(requiredText),
        reason: 'Final integration audit is missing: $requiredText',
      );
    }
  });

  test('architecture and contributor guides cover final trust boundaries', () {
    final architecture = File(
      'docs/ARCHITECTURE_WALKTHROUGH.md',
    ).readAsStringSync();
    final contributor = File(
      'docs/NEW_CONTRIBUTOR_TUTORIAL.md',
    ).readAsStringSync();

    for (final requiredText in <String>[
      'Custom Game Builder',
      'imported Game Backup progress is unranked',
      'custom sessions cannot overwrite built-in per-mode records',
      'Full Replay Archive',
      'Auto Play',
      'source-complete',
    ]) {
      expect(
        architecture,
        contains(requiredText),
        reason: 'Architecture walkthrough is missing: $requiredText',
      );
    }

    for (final requiredText in <String>[
      'Preserve trust boundaries',
      'Custom Game Builder',
      'same-commit',
      'Conventional Commits',
      'Do not split one inseparable code line',
    ]) {
      expect(
        contributor,
        contains(requiredText),
        reason: 'Contributor tutorial is missing: $requiredText',
      );
    }
  });

  test('error reference and Linux handbook expose actionable diagnostics', () {
    final errors = File('docs/ERROR_REFERENCE.md').readAsStringSync();
    final linux = File(
      'docs/setup/LINUX_NATIVE_TOOLCHAIN.md',
    ).readAsStringSync();

    for (final requiredText in <String>[
      'flutter doctor -v',
      'Custom presets disappear after corruption',
      'Custom game appears in built-in mode records',
      'APK builds but AAB fails',
      'Stable release gate fails at 0/13',
    ]) {
      expect(
        errors,
        contains(requiredText),
        reason: 'Error reference is missing: $requiredText',
      );
    }

    for (final requiredText in <String>[
      'cmake --version',
      'ninja --version',
      'pkg-config --modversion gtk+-3.0',
      'flutter build linux --release',
      'complete release bundle',
      'Platform Builds',
    ]) {
      expect(
        linux,
        contains(requiredText),
        reason: 'Linux native handbook is missing: $requiredText',
      );
    }
  });

  test('documentation audit checklist covers project release boundaries', () {
    final checklist = File(
      'docs/DOCUMENTATION_AUDIT_CHECKLIST.md',
    ).readAsStringSync();

    for (final requiredText in <String>[
      'Custom Game Builder',
      'Portable data and trust',
      'Accessibility',
      'Privacy/security',
      'Build artifacts',
      'Same-commit evidence rule',
      'Manual qualification boundary',
      'Open-source/community files',
      'what_changed.md',
    ]) {
      expect(
        checklist,
        contains(requiredText),
        reason: 'Documentation audit checklist is missing: $requiredText',
      );
    }
  });

  test('changelog records final integration without claiming green evidence', () {
    final changelog = File('CHANGELOG.md').readAsStringSync();

    for (final requiredText in <String>[
      'Custom Game Builder',
      'Duplicate',
      'selector state',
      '1.5.0+15',
      'same-commit',
      '0/13',
    ]) {
      expect(
        changelog,
        contains(requiredText),
        reason: 'Changelog is missing: $requiredText',
      );
    }

    expect(changelog, contains('No green formatter'));
  });

  test('active continuity preserves archives and records Phase 34', () {
    final continuity = File('what_changed.md').readAsStringSync();

    expect(continuity, contains('Phase 34'));
    expect(continuity, contains('what_changed_archive_phase_32.md'));
    expect(continuity, contains('what_changed_archive_phase_33.md'));
    expect(continuity, contains('stable qualification boundary remains 0/13'));
  });
}
