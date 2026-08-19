import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  const checkoutRevision = '3d3c42e5aac5ba805825da76410c181273ba90b1';
  const flutterActionRevision = '1a449444c387b1966244ae4d4f8c696479add0b2';
  const dependencyReviewRevision = 'a1d282b36b6f3519aa1f3fc636f609c47dddb294';
  const uploadArtifactRevision = '043fb46d1a93c77aae656e7c1c64a875d1fc6a0a';

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

    test('validated Android toolchain baseline remains pinned', () {
      final settings = File('android/settings.gradle.kts').readAsStringSync();
      final wrapper = File(
        'android/gradle/wrapper/gradle-wrapper.properties',
      ).readAsStringSync();

      expect(
        settings,
        contains('id("com.android.application") version "9.1.0" apply false'),
      );
      expect(
        settings,
        contains(
          'id("org.jetbrains.kotlin.android") version "2.4.10" apply false',
        ),
      );
      expect(wrapper, contains('gradle-9.7.0-all.zip'));
      expect(
        wrapper,
        contains(
          'distributionSha256Sum='
          'a9ecb5ac5c2ca40691e6527724d11d0b43b8c0a52825b77c09899f2a72d2d2bf',
        ),
      );
      expect(settings, isNot(contains('version "9.3.1"')));
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
        contains('actions/dependency-review-action@$dependencyReviewRevision'),
      );
      expect(dependencyReview, contains('fail-on-severity: high'));
    });

    test('dependency review uses maintained Node 24 action runtime', () {
      final workflow = File(
        '.github/workflows/dependency-review.yml',
      ).readAsStringSync();

      expect(workflow, contains('actions/checkout@$checkoutRevision'));
      expect(
        workflow,
        contains('actions/dependency-review-action@$dependencyReviewRevision'),
      );
      expect(workflow, contains('fail-on-severity: high'));
    });

    test(
      'remote workflow actions are pinned to immutable commit revisions',
      () {
        final workflowFiles = Directory('.github/workflows')
            .listSync()
            .whereType<File>()
            .where((file) => file.path.endsWith('.yml'))
            .toList();
        final immutableUse = RegExp(
          r'^\s*(?:-\s*)?uses:\s*[^@\s]+@[0-9a-f]{40}(?:\s+#\s+.+)?\s*$',
        );

        expect(workflowFiles, isNotEmpty);
        for (final workflow in workflowFiles) {
          for (final line in workflow.readAsLinesSync()) {
            if (!line.contains('uses:') || line.contains('uses: ./')) {
              continue;
            }
            expect(
              immutableUse.hasMatch(line),
              isTrue,
              reason: '${workflow.path} has a mutable action reference: $line',
            );
          }
        }
      },
    );

    test('critical workflow action revisions match the qualified baseline', () {
      final workflows = Directory('.github/workflows')
          .listSync()
          .whereType<File>()
          .where((file) => file.path.endsWith('.yml'))
          .map((file) => file.readAsStringSync())
          .join('\n');

      expect(workflows, contains('actions/checkout@$checkoutRevision'));
      expect(
        workflows,
        contains('subosito/flutter-action@$flutterActionRevision'),
      );
      expect(
        workflows,
        contains('actions/dependency-review-action@$dependencyReviewRevision'),
      );
      expect(
        workflows,
        contains('actions/upload-artifact@$uploadArtifactRevision'),
      );
    });

    test('Flutter workflows freeze SDK version and disable action caching', () {
      final workflowFiles = Directory('.github/workflows')
          .listSync()
          .whereType<File>()
          .where((file) => file.path.endsWith('.yml'));
      var flutterWorkflowCount = 0;

      for (final workflow in workflowFiles) {
        final source = workflow.readAsStringSync();
        if (!source.contains(
          'subosito/flutter-action@$flutterActionRevision',
        )) {
          continue;
        }
        flutterWorkflowCount += 1;
        expect(
          source,
          contains('flutter-version: 3.47.0'),
          reason: '${workflow.path} must freeze the qualified Flutter SDK',
        );
        expect(
          source,
          contains('cache: false'),
          reason: '${workflow.path} must not invoke the action cache path',
        );
        expect(
          source,
          isNot(contains('cache: true')),
          reason: '${workflow.path} must not enable transitive actions/cache',
        );
      }

      expect(flutterWorkflowCount, 5);
    });

    test('branding generator Python environment is fully version pinned', () {
      final requirements = File(
        'tool/branding-requirements.txt',
      ).readAsLinesSync();
      final workflow = File(
        '.github/workflows/bootstrap-branding.yml',
      ).readAsStringSync();
      final packagePin = RegExp(
        r'^[a-z0-9_-]+==[^=\s]+$',
        caseSensitive: false,
      );
      final packages = requirements
          .map((line) => line.trim())
          .where((line) => line.isNotEmpty && !line.startsWith('#'))
          .toList();

      expect(packages, isNotEmpty);
      for (final package in packages) {
        expect(
          packagePin.hasMatch(package),
          isTrue,
          reason: 'Branding dependency is not exactly version-pinned: $package',
        );
      }
      expect(packages, contains('cairosvg==2.9.0'));
      expect(packages, contains('pillow==12.3.0'));
      expect(
        workflow,
        contains('--requirement tool/branding-requirements.txt'),
      );
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

    test('community metadata exposes support and funding routes', () {
      final editorConfig = File('.editorconfig').readAsStringSync();
      final attributes = File('.gitattributes').readAsStringSync();
      final funding = File('.github/FUNDING.yml').readAsStringSync();
      final issueConfig = File(
        '.github/ISSUE_TEMPLATE/config.yml',
      ).readAsStringSync();

      expect(editorConfig, contains('root = true'));
      expect(editorConfig, contains('charset = utf-8'));
      expect(attributes, contains('*.png binary'));
      expect(attributes, contains('*.ico binary'));
      expect(funding, contains('https://buymeacoffee.com/sanskarIN'));
      expect(funding, contains('https://ramsandesh.gumroad.com'));
      expect(issueConfig, contains('blank_issues_enabled: false'));
      expect(issueConfig, contains('/blob/main/SUPPORT.md'));
      expect(issueConfig, contains('/blob/main/SECURITY.md'));
    });

    test('security policy tracks the current Version 2.0.12 line', () {
      final policy = File('SECURITY.md').readAsStringSync();

      expect(policy, contains('Version 2.0.12'));
      expect(policy, contains('2.0.12+2012'));
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

    test('pubspec exposes exact Phase 32 package/build version', () {
      final pubspec = File('pubspec.yaml').readAsStringSync();
      final windows = File('windows/runner/Runner.rc').readAsStringSync();

      expect(pubspec, contains('version: 2.0.12+2012'));
      expect(windows, contains('#define VERSION_AS_NUMBER 2,0,12,2012'));
      expect(windows, contains('#define VERSION_AS_STRING "2.0.12"'));
    });

    test('pubspec exposes canonical open source destinations', () {
      final pubspec = File('pubspec.yaml').readAsStringSync();

      expect(pubspec, contains('homepage: https://github.com/sanskarIN/2048'));
      expect(
        pubspec,
        contains('repository: https://github.com/sanskarIN/2048'),
      );
      expect(
        pubspec,
        contains('issue_tracker: https://github.com/sanskarIN/2048/issues'),
      );
    });

    test('desktop metadata reflects the MIT open source license', () {
      final license = File('LICENSE').readAsStringSync();
      final windows = File('windows/runner/Runner.rc').readAsStringSync();
      final macos = File(
        'macos/Runner/Configs/AppInfo.xcconfig',
      ).readAsStringSync();

      expect(license, startsWith('MIT License'));
      expect(windows, contains('Licensed under the MIT License.'));
      expect(macos, contains('Licensed under the MIT License.'));
      expect(windows, isNot(contains('All rights reserved.')));
      expect(macos, isNot(contains('All rights reserved.')));
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
        expect(source, isNot(contains('actions/checkout@v4')));
        expect(source, isNot(contains('actions/checkout@v5')));
        expect(source, isNot(contains('actions/checkout@v6')));
        expect(source, isNot(contains('actions/checkout@v7')));
      }
    });

    test('dependency lock workflow watches dependency metadata', () {
      final workflow = File(
        '.github/workflows/lock-dependencies.yml',
      ).readAsStringSync();

      expect(workflow, contains('- pubspec.yaml'));
      expect(workflow, contains('- pubspec.lock'));
      expect(workflow, contains('actions/checkout@$checkoutRevision'));
    });

    test('CI rejects Flutter metadata drift and missing Web icon fonts', () {
      final workflow = File('.github/workflows/ci.yml').readAsStringSync();

      expect(
        workflow,
        contains('git diff --exit-code -- pubspec.lock analysis_options.yaml'),
      );
      expect(workflow, contains('Expected to find fonts for'));
      expect(workflow, contains('actions/checkout@$checkoutRevision'));
    });

    test('CI supports explicit maintainer dispatch', () {
      final workflow = File('.github/workflows/ci.yml').readAsStringSync();

      expect(workflow, contains('workflow_dispatch:'));
    });

    test('native builds publish checksummed qualification artifacts', () {
      final workflow = File(
        '.github/workflows/platform-builds.yml',
      ).readAsStringSync();

      expect(
        workflow,
        contains('actions/upload-artifact@$uploadArtifactRevision'),
      );
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
