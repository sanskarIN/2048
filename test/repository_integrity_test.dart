import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('repository integrity', () {
    test('Cupertino icon dependency is declared and locked compatibly', () {
      final pubspec = File('pubspec.yaml').readAsStringSync();
      final lockfile = File('pubspec.lock').readAsStringSync();

      expect(pubspec, contains('cupertino_icons: 1.0.9'));
      expect(lockfile, contains('name: cupertino_icons'));
      expect(lockfile, contains('version: "1.0.9"'));
    });

    test('declared SDK floor matches maintained dependencies', () {
      final pubspec = File('pubspec.yaml').readAsStringSync();

      expect(pubspec, contains('sdk: ">=3.9.0 <4.0.0"'));
      expect(pubspec, contains('flutter: ">=3.35.0"'));
      expect(pubspec, contains('shared_preferences: ^2.5.5'));
      expect(pubspec, contains('flutter_lints: ^6.0.0'));
    });

    test('supply-chain automation covers maintained dependency ecosystems', () {
      final dependabot = File('.github/dependabot.yml').readAsStringSync();
      final dependencyReview = File(
        '.github/workflows/dependency-review.yml',
      ).readAsStringSync();

      for (final ecosystem in <String>['pub', 'gradle', 'github-actions']) {
        expect(dependabot, contains('package-ecosystem: $ecosystem'));
      }
      expect(dependabot, isNot(contains('- dependencies')));
      expect(
        dependencyReview,
        anyOf(
          contains('actions/dependency-review-action@v4'),
          contains('actions/dependency-review-action@v5'),
        ),
      );
      expect(dependencyReview, contains('fail-on-severity: high'));
    });

    test('CODEOWNERS covers release and platform policy', () {
      final owners = File('.github/CODEOWNERS').readAsStringSync();

      expect(owners, contains('* @sanskarIN'));
      expect(owners, contains('/.github/ @sanskarIN'));
      expect(owners, contains('/pubspec.yaml @sanskarIN'));
      expect(owners, contains('/docs/RELEASE* @sanskarIN'));
      expect(owners, contains('/android/ @sanskarIN'));
      expect(owners, contains('/ios/ @sanskarIN'));
    });

    test('security policy tracks the current Version 1.5 line', () {
      final policy = File('SECURITY.md').readAsStringSync();

      expect(policy, contains('Version 1.5'));
      expect(policy, contains('supportramsandesh@gmail.com'));
      expect(policy, contains('dependency-review'));
    });

    test('runtime version matches pubspec marketing version', () {
      final pubspec = File('pubspec.yaml').readAsStringSync();
      final projectInfo = File(
        'lib/core/constants/project_info.dart',
      ).readAsStringSync();
      final match = RegExp(
        r'^version:\s*([^+\s]+)(?:\+\d+)?\s*$',
        multiLine: true,
      ).firstMatch(pubspec);

      expect(match, isNotNull);
      final marketingVersion = match!.group(1)!;
      expect(
        projectInfo,
        contains("static const version = '$marketingVersion';"),
      );
    });

    test(
      'CI stable boundary is qualification-driven, not version-prefix driven',
      () {
        final workflow = File('.github/workflows/ci.yml').readAsStringSync();

        expect(workflow, isNot(contains('version == 0.9.*')));
        expect(workflow, contains('pending|blocked'));
        expect(
          workflow,
          contains('Stable release gate correctly remains closed'),
        );
      },
    );

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
      expect(
        workflow,
        anyOf(
          contains('actions/checkout@v6'),
          contains('actions/checkout@v7'),
        ),
      );
    });

    test('CI rejects Flutter metadata drift and missing Web icon fonts', () {
      final workflow = File('.github/workflows/ci.yml').readAsStringSync();

      expect(
        workflow,
        contains('git diff --exit-code -- pubspec.lock analysis_options.yaml'),
      );
      expect(workflow, contains('Expected to find fonts for'));
      expect(
        workflow,
        anyOf(
          contains('actions/checkout@v6'),
          contains('actions/checkout@v7'),
        ),
      );
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
