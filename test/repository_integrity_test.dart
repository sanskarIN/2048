import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('repository integrity', () {
    test('Cupertino icon dependency is declared and locked compatibly', () {
      final pubspec = File('pubspec.yaml').readAsStringSync();
      final lockfile = File('pubspec.lock').readAsStringSync();

      expect(pubspec, contains('cupertino_icons: 1.0.8'));
      expect(lockfile, contains('name: cupertino_icons'));
      expect(lockfile, contains('version: "1.0.8"'));
    });

    test('macOS generated registrant includes file picker', () {
      final registrant = File(
        'macos/Flutter/GeneratedPluginRegistrant.swift',
      ).readAsStringSync();

      expect(registrant, contains('import file_picker'));
      expect(
        registrant,
        contains(
          'FilePickerPlugin.register(with: registry.registrar(forPlugin: '
          '"FilePickerPlugin"))',
        ),
      );
    });

    test('Flutter analysis excludes generated platform trees', () {
      final options = File('analysis_options.yaml').readAsStringSync();

      for (final exclude in <String>[
        'build/**',
        'android/**',
        'ios/**',
        'web/**',
        'windows/**',
        'macos/**',
        'linux/**',
      ]) {
        expect(options, contains('- $exclude'));
      }
    });

    test('repository workflows no longer use deprecated checkout runtimes', () {
      final workflowFiles = Directory('.github/workflows')
          .listSync()
          .whereType<File>()
          .where((file) => file.path.endsWith('.yml'))
          .toList();

      expect(workflowFiles, isNotEmpty);
      for (final workflow in workflowFiles) {
        final source = workflow.readAsStringSync();
        expect(
          source,
          isNot(contains('actions/checkout@v4')),
          reason: '${workflow.path} still uses checkout v4',
        );
        expect(
          source,
          isNot(contains('actions/checkout@v5')),
          reason: '${workflow.path} still uses checkout v5',
        );
      }
    });

    test('dependency lock workflow watches dependency metadata', () {
      final workflow = File(
        '.github/workflows/lock-dependencies.yml',
      ).readAsStringSync();

      expect(workflow, contains('- pubspec.yaml'));
      expect(workflow, contains('- pubspec.lock'));
      expect(workflow, contains('actions/checkout@v6'));
    });

    test('CI rejects Flutter metadata drift and missing Web icon fonts', () {
      final workflow = File('.github/workflows/ci.yml').readAsStringSync();

      expect(
        workflow,
        contains('git diff --exit-code -- pubspec.lock analysis_options.yaml'),
      );
      expect(workflow, contains('Expected to find fonts for'));
      expect(workflow, contains('actions/checkout@v6'));
    });

    test('CI supports explicit maintainer dispatch', () {
      final workflow = File('.github/workflows/ci.yml').readAsStringSync();

      expect(workflow, contains('workflow_dispatch:'));
    });

    test('native builds publish checksummed qualification artifacts', () {
      final workflow = File(
        '.github/workflows/platform-builds.yml',
      ).readAsStringSync();

      expect(workflow, contains('actions/upload-artifact@v7'));
      expect(workflow, contains('if-no-files-found: error'));
      expect(workflow, contains('retention-days: 14'));
      for (final artifact in <String>[
        'nova-2048-android-release',
        'nova-2048-linux-x64-release',
        'nova-2048-windows-x64-release',
        'nova-2048-macos-release',
        'nova-2048-ios-unsigned-release',
      ]) {
        expect(workflow, contains('name: $artifact'));
      }
      expect(workflow, contains('sha256sum'));
      expect(workflow, contains('Get-FileHash'));
      expect(workflow, contains('shasum -a 256'));
    });
  });
}
