import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  const checkoutRevision = '3d3c42e5aac5ba805825da76410c181273ba90b1';

  group('workflow security', () {
    test('read-only workflows do not persist checkout credentials', () {
      for (final path in <String>[
        '.github/workflows/ci.yml',
        '.github/workflows/dependency-review.yml',
        '.github/workflows/platform-builds.yml',
      ]) {
        final source = File(path).readAsStringSync();
        final checkoutCount = RegExp(
          'actions/checkout@$checkoutRevision',
        ).allMatches(source).length;
        final disabledCredentialCount = RegExp(
          r'persist-credentials:\s*false',
        ).allMatches(source).length;

        expect(source, contains('permissions:\n  contents: read'));
        expect(
          checkoutCount,
          greaterThan(0),
          reason: '$path must keep an explicit checkout step',
        );
        expect(
          disabledCredentialCount,
          checkoutCount,
          reason:
              '$path must disable credential persistence for every checkout step',
        );
      }
    });

    test('Android hosted build pins the qualified JDK 17 runtime', () {
      final workflow = File(
        '.github/workflows/platform-builds.yml',
      ).readAsStringSync();

      expect(
        workflow,
        contains('actions/setup-java@b6effb05e454b25005698d916606bdc6ffcbf961'),
      );
      expect(workflow, contains('distribution: temurin'));
      expect(workflow, contains("java-version: '17'"));
      expect(workflow, isNot(contains("java-version: '21'")));
    });

    test(
      'permanent workflows reject high-risk trigger and permission patterns',
      () {
        final workflows = Directory('.github/workflows')
            .listSync()
            .whereType<File>()
            .where(
              (file) =>
                  file.path.endsWith('.yml') || file.path.endsWith('.yaml'),
            );

        for (final workflow in workflows) {
          final source = workflow.readAsStringSync();
          expect(
            source,
            isNot(contains('pull_request_target:')),
            reason:
                '${workflow.path} must not execute privileged PR-target code',
          );
          expect(
            source,
            isNot(contains('write-all')),
            reason:
                '${workflow.path} must not request blanket write permissions',
          );
        }
      },
    );

    test(
      'repository-writing workflows serialize safe non-force main pushes',
      () {
        for (final path in <String>[
          '.github/workflows/bootstrap-branding.yml',
          '.github/workflows/bootstrap-platforms.yml',
          '.github/workflows/format-code.yml',
          '.github/workflows/lock-dependencies.yml',
        ]) {
          final source = File(path).readAsStringSync();
          expect(source, contains('contents: write'));
          expect(source, contains('concurrency:'));
          expect(source, contains('cancel-in-progress: true'));
          expect(source, contains("github.actor != 'github-actions[bot]'"));
          expect(source, contains('timeout-minutes:'));
          expect(source, contains('git config user.name "Sanskar"'));
          expect(
            source,
            contains('git config user.email "sanskarin@outlook.in"'),
          );
          expect(source, contains('git push origin HEAD:main'));
          expect(source, isNot(contains('git push --force')));
          expect(source, isNot(contains('git push -f')));
        }
      },
    );
  });
}
