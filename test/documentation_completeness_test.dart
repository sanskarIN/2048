import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void expectContainsAll(String content, Iterable<String> required, String label) {
  for (final text in required) {
    expect(content, contains(text), reason: '$label is missing: $text');
  }
}

void main() {
  const requiredDocumentation = <String>[
    'README.md',
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

  test('complete final documentation set is tracked in source tree', () {
    for (final path in requiredDocumentation) {
      expect(
        File(path).existsSync(),
        isTrue,
        reason: 'Required documentation is missing: $path',
      );
    }
  });

  test('build handbook uses the current Version 2.0.12 identity', () {
    final content = File('docs/BUILDING_EXECUTABLES.md').readAsStringSync();
    expectContainsAll(
      content,
      const ['2.0.12+2012', 'Marketing version: 2.0.12'],
      'Build handbook',
    );
    expect(content, isNot(contains('version: 1.5.0+15')));
  });

  test('public README exposes the current custom and quality surface', () {
    final content = File('README.md').readAsStringSync();
    expectContainsAll(
      content,
      const [
        '2.0.12+2012',
        'Custom Game Builder',
        'Edit',
        'Duplicate-as-unsaved-copy',
        'cannot overwrite built-in per-mode',
        'docs/CUSTOM_GAME_BUILDER.md',
        'docs/FINAL_2_0_12_INTEGRATION_AUDIT.md',
        'docs/BUILDING_EXECUTABLES.md',
        'flutter build appbundle --release',
        'source_completion_audit.dart --json',
        'what_changed_archive_phase_33.md',
      ],
      'Public README',
    );
  });

  test('setup index exposes lifecycle, Linux native, and deep references', () {
    final content = File('docs/setup/README.md').readAsStringSync();
    expectContainsAll(
      content,
      const [
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
      ],
      'Setup index',
    );
  });

  test('canonical docs index exposes final guides and custom source owners', () {
    final content = File('docs/README.md').readAsStringSync();
    expectContainsAll(
      content,
      const [
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
        '../lib/domain/custom_game_preset.dart',
        '../lib/data/custom_preset_store.dart',
        '../lib/features/modes/custom_game_builder_screen.dart',
      ],
      'Canonical docs index',
    );
  });

  test('feature reference covers the completed product surface', () {
    final content = File('docs/FEATURE_REFERENCE.md').readAsStringSync();
    expectContainsAll(
      content,
      const [
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
        'accessibility controls',
        'Platform support',
        'Release readiness',
        'cannot overwrite built-in per-mode',
        'Duplicate preset',
      ],
      'Feature reference',
    );
  });

  test('user guide exposes the complete custom preset player workflow', () {
    final content = File('docs/USER_GUIDE.md').readAsStringSync();
    expectContainsAll(
      content,
      const [
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
      ],
      'User guide',
    );
    expect(content, isNot(contains('before stable 1.0.0')));
  });

  test('tool lifecycle and support matrix preserve compatibility workflow', () {
    final lifecycle = File(
      'docs/setup/UPGRADING_AND_SUPPORT.md',
    ).readAsStringSync();
    expectContainsAll(
      lifecycle,
      const [
        'End of support / EOL',
        'Safe upgrade workflow',
        'Rollback strategy',
        'CI baseline updates',
        'flutter analyze',
        'flutter test --coverage',
        'repository_audit.dart --json',
        'source_completion_audit.dart --json',
      ],
      'Lifecycle guide',
    );

    final matrix = File('docs/setup/TOOL_SUPPORT_MATRIX.md').readAsStringSync();
    expectContainsAll(
      matrix,
      const [
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
      ],
      'Tool support matrix',
    );
  });

  test('reading guide and no-skip contract preserve documentation safety', () {
    final readingGuide = File(
      'docs/DOCUMENTATION_READING_GUIDE.md',
    ).readAsStringSync();
    expectContainsAll(
      readingGuide,
      const [
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
      ],
      'Documentation reading guide',
    );

    final coverage = File('docs/FILE_COVERAGE_CONTRACT.md').readAsStringSync();
    expectContainsAll(
      coverage,
      const [
        'git ls-files',
        'Exact-file coverage',
        'Explicit file-family coverage',
        'Generated/platform-template coverage',
        'Historical/archive coverage',
        'Top-level coverage boundaries',
        'New-file rule',
        'Rename and deletion rule',
        'documentation_completeness_test.dart',
      ],
      'File coverage contract',
    );
  });

  test('custom game documentation is current and covers final workflows', () {
    final content = File('docs/CUSTOM_GAME_BUILDER.md').readAsStringSync();
    expectContainsAll(
      content,
      const [
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
      ],
      'Custom Game Builder documentation',
    );
    expect(content, isNot(contains('Version 1.6 feature branch documentation')));
    expect(
      content,
      isNot(contains('not part of the qualified Version 1.5 release candidate')),
    );
  });

  test('historical Version 1.6 roadmap cannot present itself as current', () {
    final content = File('docs/VERSION_1_6_ROADMAP.md').readAsStringSync();
    expectContainsAll(
      content,
      const ['Historical record', '2.0.12+2012', 'closed as an active roadmap'],
      'Historical Version 1.6 roadmap',
    );
    expect(
      content,
      isNot(contains('Version 1.5 remains the current release-candidate line')),
    );
  });

  test('final integration audit preserves the exact evidence boundary', () {
    final content = File(
      'docs/FINAL_2_0_12_INTEGRATION_AUDIT.md',
    ).readAsStringSync();
    expectContainsAll(
      content,
      const [
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
      ],
      'Final integration audit',
    );
  });

  test('architecture and contributor docs protect trust and review rules', () {
    final architecture = File(
      'docs/ARCHITECTURE_WALKTHROUGH.md',
    ).readAsStringSync();
    expectContainsAll(
      architecture,
      const [
        'Custom Game Builder',
        'imported Game Backup progress is unranked',
        'custom sessions cannot overwrite built-in per-mode records',
        'Full Replay Archive',
        'Auto Play',
        'source-complete',
      ],
      'Architecture walkthrough',
    );

    final contributor = File(
      'docs/NEW_CONTRIBUTOR_TUTORIAL.md',
    ).readAsStringSync();
    expectContainsAll(
      contributor,
      const [
        'Preserve trust boundaries',
        'Custom Game Builder',
        'Same-commit',
        'Conventional Commits',
        'Do not split one inseparable code line',
      ],
      'Contributor tutorial',
    );
  });

  test('error reference and Linux handbook expose actionable diagnostics', () {
    final errors = File('docs/ERROR_REFERENCE.md').readAsStringSync();
    expectContainsAll(
      errors,
      const [
        'flutter doctor -v',
        'Custom presets disappear after corruption',
        'Custom game appears in built-in mode records',
        'APK builds but AAB fails',
        'Stable release gate fails at 0/13',
      ],
      'Error reference',
    );

    final linux = File(
      'docs/setup/LINUX_NATIVE_TOOLCHAIN.md',
    ).readAsStringSync();
    expectContainsAll(
      linux,
      const [
        'cmake --version',
        'ninja --version',
        'pkg-config --modversion gtk+-3.0',
        'flutter build linux --release',
        'complete release bundle',
        'Platform Builds',
      ],
      'Linux native handbook',
    );
  });

  test('documentation audit, changelog, and continuity protect final state', () {
    final checklist = File(
      'docs/DOCUMENTATION_AUDIT_CHECKLIST.md',
    ).readAsStringSync();
    expectContainsAll(
      checklist,
      const [
        'Custom Game Builder',
        'Portable data and trust',
        'Accessibility',
        'Privacy/security',
        'Build artifacts',
        'Same-commit evidence rule',
        'Manual qualification boundary',
        'Open-source/community files',
        'what_changed.md',
      ],
      'Documentation audit checklist',
    );

    final changelog = File('CHANGELOG.md').readAsStringSync();
    expectContainsAll(
      changelog,
      const [
        'Custom Game Builder',
        'Duplicate',
        'selector state',
        '1.5.0+15',
        'same-commit',
        '0/13',
        'No green formatter',
      ],
      'Changelog',
    );

    final continuity = File('what_changed.md').readAsStringSync();
    expectContainsAll(
      continuity,
      const [
        'Phase 34',
        'what_changed_archive_phase_32.md',
        'what_changed_archive_phase_33.md',
        'stable qualification boundary remains 0/13',
        'DropdownButtonFormField.initialValue',
        'bf444910',
      ],
      'Active continuity',
    );
  });
}
