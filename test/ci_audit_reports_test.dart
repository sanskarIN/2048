import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('CI retains machine-readable source audit reports', () {
    final workflow = File('.github/workflows/ci.yml').readAsStringSync();

    const reports = <String, String>{
      'dart run tool/release_readiness.dart --json': 'release-readiness.json',
      'dart run tool/release_qualification_status.dart --json --pending-only':
          'release-qualification-status.json',
      'dart run tool/repository_audit.dart --json': 'repository-audit.json',
      'dart run tool/platform_support_audit.dart --json':
          'platform-support-audit.json',
      'dart run tool/source_completion_audit.dart --json':
          'source-completion-audit.json',
    };

    for (final entry in reports.entries) {
      expect(
        workflow,
        contains('${entry.key} | tee ${entry.value}'),
        reason: '${entry.key} must retain ${entry.value}.',
      );
      expect(
        workflow,
        contains(entry.value),
        reason: '${entry.value} must be included in the CI evidence bundle.',
      );
    }

    expect(workflow, contains('nova-2048-source-audit-reports'));
    expect(workflow, contains('if-no-files-found: error'));
    expect(workflow, contains('retention-days: 14'));
    expect(
      workflow,
      contains(
        'actions/upload-artifact@043fb46d1a93c77aae656e7c1c64a875d1fc6a0a',
      ),
    );
  });
}
