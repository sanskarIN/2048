import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  late String scriptPath;
  final temporaryRoots = <Directory>[];

  setUpAll(() {
    scriptPath = File('tool/source_completion_audit.dart').absolute.path;
    expect(File(scriptPath).existsSync(), isTrue);
  });

  tearDown(() async {
    for (final directory in temporaryRoots) {
      if (directory.existsSync()) {
        await directory.delete(recursive: true);
      }
    }
    temporaryRoots.clear();
  });

  Future<Directory> fixture({
    String packageVersion = '2.0.12+2012',
    String candidate = '2.0.12+2012',
    bool restoreOptionalBacklog = false,
    bool indexFinalDocs = true,
    bool unresolvedProductTodo = false,
    bool unresolvedToolTodo = false,
    bool staleCurrentVersion = false,
    bool missingCiWiring = false,
  }) async {
    final root = await Directory.systemTemp.createTemp(
      'nova-source-completion-',
    );
    temporaryRoots.add(root);

    Future<void> write(String path, String contents) async {
      final file = File.fromUri(root.uri.resolve(path));
      await file.parent.create(recursive: true);
      await file.writeAsString(contents);
    }

    await write(
      'README.md',
      staleCurrentVersion
          ? '# Fixture\n\nCurrent release is Version 1.5 (`1.5.0+15`).\n'
          : '# Fixture\n\nVersion 2.0.12 source is feature-complete.\n',
    );
    await write(
      'ROADMAP.md',
      '# Completion Roadmap\n\n'
          '## 2.0.12 — Feature-complete source target\n\n'
          'Remaining release qualification before `2.0.12`\n\n'
          '## No active post-2.0.12 feature backlog\n\n'
          'A proposal for any non-goal starts a **new release scope**.\n'
          '${restoreOptionalBacklog ? '\n## Later — Optional expansion\n\n- Add something.\n' : ''}',
    );
    await write('CHANGELOG.md', '# Changelog\n\n## [Unreleased]\n');
    await write('CHANGELOG_ARCHIVE_PRE_2_0_12.md', '# Historical changelog\n');
    await write(
      'SECURITY.md',
      '# Security\n\nThe repository is maintained on Version 2.0.12.\n',
    );
    await write(
      'what_changed.md',
      '# Continuity\n\nVersion 2.0.12 source completion.\n',
    );
    await write('pubspec.yaml', 'name: fixture\nversion: $packageVersion\n');
    await write(
      'docs/README.md',
      '# Documentation\n\n'
          '${indexFinalDocs ? '- FINAL_2_0_12_SOURCE_AUDIT.md\n- MAINTENANCE_POLICY.md\n- SOURCE_COMPLETION_AUDIT.md\n' : ''}',
    );
    await write(
      'docs/DEPENDENCIES.md',
      '# Dependencies\n\nVersion 2.0.12 compatibility-first freeze.\n',
    );
    await write(
      'docs/FINAL_2_0_12_SOURCE_AUDIT.md',
      '# Final audit\n\n'
          '2048 Nova 2.0.12 is feature-complete within its declared offline-first puzzle-game scope.\n',
    );
    await write(
      'docs/MAINTENANCE_POLICY.md',
      '# Maintenance\n\n## No active feature backlog\n',
    );
    await write(
      'docs/PHASE_32_VERSION_2_0_12.md',
      '# Phase 32\n\n2.0.12+2012\n',
    );
    await write(
      'docs/RELEASE_CHECKLIST.md',
      '# Release checklist\n\nVersion 2.0.12\n',
    );
    await write(
      'docs/RELEASE_QUALIFICATION.md',
      '# Qualification\n\nStable Version 2.0.12 requires real evidence.\n',
    );
    await write(
      'docs/SOURCE_COMPLETION_AUDIT.md',
      '# Source completion audit\n\n'
          '`test/source_completion_audit_cli_test.dart` protects this contract.\n',
    );
    await write(
      'docs/release_qualification.json',
      '${const JsonEncoder.withIndent('  ').convert(<String, Object?>{
        'schemaVersion': 1,
        'candidate': candidate,
        'manualChecks': <Map<String, Object?>>[
          for (var index = 0; index < 13; index += 1) <String, Object?>{'id': 'check-$index', 'title': 'Check $index', 'status': 'pending', 'evidence': '', 'updatedAt': null},
        ],
      })}\n',
    );
    await write(
      'lib/main.dart',
      unresolvedProductTodo
          ? '// TODO: finish product work\nvoid main() {}\n'
          : 'void main() {}\n',
    );
    await write(
      'test/source_completion_audit_cli_test.dart',
      'void main() {}\n',
    );
    await write(
      'tool/README.md',
      '# Tools\n\n`source_completion_audit.dart`\n',
    );
    await write('tool/source_completion_audit.dart', 'void main() {}\n');
    if (unresolvedToolTodo) {
      await write(
        'tool/unresolved_helper.dart',
        '// FIXME: finish maintenance helper\nvoid helper() {}\n',
      );
    }
    await write(
      '.github/workflows/ci.yml',
      missingCiWiring
          ? 'name: CI\n'
          : 'name: CI\nrun: dart run tool/source_completion_audit.dart --json\n',
    );

    return root;
  }

  Future<({ProcessResult process, Map<String, dynamic> json})> runAudit(
    Directory root,
  ) async {
    final process = await Process.run('dart', <String>[
      scriptPath,
      '--root=${root.path}',
      '--json',
    ]);
    expect(process.stdout, isNotEmpty, reason: process.stderr.toString());
    final decoded = jsonDecode(process.stdout as String);
    expect(decoded, isA<Map<String, dynamic>>());
    return (process: process, json: decoded as Map<String, dynamic>);
  }

  test('clean final fixture reports feature complete', () async {
    final root = await fixture();

    final result = await runAudit(root);

    expect(
      result.process.exitCode,
      0,
      reason: result.process.stderr.toString(),
    );
    expect(result.json['packageVersion'], '2.0.12+2012');
    expect(result.json['marketingVersion'], '2.0.12');
    expect(result.json['featureComplete'], isTrue);
    expect(result.json['failures'], isEmpty);
  });

  test('package drift fails closed', () async {
    final root = await fixture(packageVersion: '2.0.12+2013');

    final result = await runAudit(root);

    expect(result.process.exitCode, 1);
    expect(result.json['featureComplete'], isFalse);
    expect(
      (result.json['failures'] as List<dynamic>).join('\n'),
      contains('pubspec.yaml must target 2.0.12+2012'),
    );
  });

  test('restored optional feature backlog fails closed', () async {
    final root = await fixture(restoreOptionalBacklog: true);

    final result = await runAudit(root);

    expect(result.process.exitCode, 1);
    expect(
      (result.json['failures'] as List<dynamic>).join('\n'),
      contains('must not restore an active optional-feature backlog'),
    );
  });

  test('final docs must remain indexed', () async {
    final root = await fixture(indexFinalDocs: false);

    final result = await runAudit(root);

    expect(result.process.exitCode, 1);
    final failures = (result.json['failures'] as List<dynamic>).join('\n');
    expect(failures, contains('FINAL_2_0_12_SOURCE_AUDIT.md'));
    expect(failures, contains('MAINTENANCE_POLICY.md'));
    expect(failures, contains('SOURCE_COMPLETION_AUDIT.md'));
  });

  test('unresolved product TODO comment fails closed', () async {
    final root = await fixture(unresolvedProductTodo: true);

    final result = await runAudit(root);

    expect(result.process.exitCode, 1);
    expect(
      (result.json['failures'] as List<dynamic>).join('\n'),
      contains('Maintained Dart source contains unresolved TODO/FIXME comment'),
    );
  });

  test('unresolved tool FIXME comment fails closed', () async {
    final root = await fixture(unresolvedToolTodo: true);

    final result = await runAudit(root);

    expect(result.process.exitCode, 1);
    final failures = (result.json['failures'] as List<dynamic>).join('\n');
    expect(failures, contains('tool/unresolved_helper.dart'));
    expect(
      failures,
      contains('Maintained Dart source contains unresolved TODO/FIXME comment'),
    );
  });

  test('permanent CI must retain source completion audit wiring', () async {
    final root = await fixture(missingCiWiring: true);

    final result = await runAudit(root);

    expect(result.process.exitCode, 1);
    expect(
      (result.json['failures'] as List<dynamic>).join('\n'),
      contains('Permanent CI must run the source-completion audit'),
    );
  });

  test('stale current Version 1.5 metadata fails closed', () async {
    final root = await fixture(staleCurrentVersion: true);

    final result = await runAudit(root);

    expect(result.process.exitCode, 1);
    final failures = (result.json['failures'] as List<dynamic>).join('\n');
    expect(failures, contains('obsolete 1.5.0+15 current-release metadata'));
  });

  test('candidate mismatch fails closed', () async {
    final root = await fixture(candidate: '2.0.12+9999');

    final result = await runAudit(root);

    expect(result.process.exitCode, 1);
    expect(
      (result.json['failures'] as List<dynamic>).join('\n'),
      contains('Release qualification candidate must remain 2.0.12+2012'),
    );
  });

  test('unknown argument fails closed', () async {
    final root = await fixture();
    final process = await Process.run('dart', <String>[
      scriptPath,
      '--root=${root.path}',
      '--json',
      '--surprise',
    ]);

    expect(process.exitCode, 1);
    final output = jsonDecode(process.stdout as String) as Map<String, dynamic>;
    expect(
      (output['failures'] as List<dynamic>).join('\n'),
      contains('Unknown argument(s): --surprise'),
    );
  });
}
