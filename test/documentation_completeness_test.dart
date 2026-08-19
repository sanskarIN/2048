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
    'docs/COMMAND_REFERENCE.md',
    'docs/GLOSSARY.md',
    'docs/REPOSITORY_FILE_ATLAS.md',
    'docs/BUILDING_EXECUTABLES.md',
    'docs/README.md',
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

  test('setup index links the support lifecycle and command references', () {
    final setupIndex = File('docs/setup/README.md').readAsStringSync();

    expect(setupIndex, contains('UPGRADING_AND_SUPPORT.md'));
    expect(setupIndex, contains('../COMMAND_REFERENCE.md'));
    expect(setupIndex, contains('../GLOSSARY.md'));
    expect(setupIndex, contains('../REPOSITORY_FILE_ATLAS.md'));
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
      'COMMAND_REFERENCE.md',
      'GLOSSARY.md',
      'REPOSITORY_FILE_ATLAS.md',
    ]) {
      expect(
        docsIndex,
        contains(path),
        reason: 'Canonical documentation index does not expose $path',
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
}
