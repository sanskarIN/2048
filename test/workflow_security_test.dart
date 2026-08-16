import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('workflow security', () {
    test('read-only workflows do not persist checkout credentials', () {
      final expectedCheckoutCounts = <String, int>{
        '.github/workflows/ci.yml': 1,
        '.github/workflows/dependency-review.yml': 1,
        '.github/workflows/platform-builds.yml': 4,
      };

      for (final entry in expectedCheckoutCounts.entries) {
        final source = File(entry.key).readAsStringSync();
        expect(source, contains('permissions:\n  contents: read'));
        expect(
          'persist-credentials: false'.allMatches(source).length,
          entry.value,
          reason: '${entry.key} must disable checkout credential persistence',
        );
      }
    });

    test(
      'permanent workflows reject high-risk trigger and permission patterns',
      () {
        final workflows = Directory('.github/workflows')
            .listSync()
            .whereType<File>()
            .where((file) => file.path.endsWith('.yml'));

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
      'repository-writing workflows preserve identity and avoid force pushes',
      () {
        for (final path in <String>[
          '.github/workflows/bootstrap-branding.yml',
          '.github/workflows/bootstrap-platforms.yml',
          '.github/workflows/format-code.yml',
          '.github/workflows/lock-dependencies.yml',
        ]) {
          final source = File(path).readAsStringSync();
          expect(source, contains('contents: write'));
          expect(source, contains('git config user.name "Sanskar"'));
          expect(
            source,
            contains('git config user.email "sanskarin@outlook.in"'),
          );
          expect(source, isNot(contains('git push --force')));
          expect(source, isNot(contains('git push -f')));
        }
      },
    );
  });
}
