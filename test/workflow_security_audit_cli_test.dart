import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  const checkoutSha = '1111111111111111111111111111111111111111';
  late String scriptPath;
  final temporaryRoots = <Directory>[];

  setUpAll(() {
    scriptPath = File('tool/workflow_security_audit.dart').absolute.path;
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
    bool mutableCiAction = false,
    bool omitCiTimeout = false,
    bool persistReadOnlyCredentials = false,
    bool omitWriterConcurrency = false,
    bool addPrivilegedTrigger = false,
    bool omitCiWiring = false,
  }) async {
    final root = await Directory.systemTemp.createTemp('nova-workflow-audit-');
    temporaryRoots.add(root);

    Future<void> write(String path, String contents) async {
      final file = File.fromUri(root.uri.resolve(path));
      await file.parent.create(recursive: true);
      await file.writeAsString(contents);
    }

    String readOnlyCi() {
      final checkoutRef = mutableCiAction ? 'v7' : checkoutSha;
      return '''
name: CI

on:
  push:
${addPrivilegedTrigger ? '  pull_request_target:\n' : ''}
permissions:
  contents: read

jobs:
  quality:
    runs-on: ubuntu-latest
${omitCiTimeout ? '' : '    timeout-minutes: 10\n'}    steps:
      - uses: actions/checkout@$checkoutRef
        with:
          persist-credentials: ${persistReadOnlyCredentials ? 'true' : 'false'}
      - run: ${omitCiWiring ? 'echo secure' : 'dart run tool/workflow_security_audit.dart --json'}
''';
    }

    String writer(String name, {bool omitConcurrency = false}) {
      final concurrency = omitConcurrency
          ? ''
          : '''
concurrency:
  group: $name-\${{ github.ref }}
  cancel-in-progress: true
''';
      return '''
name: $name

on:
  push:
    branches: [main]
  workflow_dispatch:

permissions:
  contents: write
$concurrency
jobs:
  write:
    if: github.actor != 'github-actions[bot]'
    runs-on: ubuntu-latest
    timeout-minutes: 10
    steps:
      - uses: actions/checkout@$checkoutSha
      - run: git push origin HEAD:main
''';
    }

    await write('.github/workflows/ci.yml', readOnlyCi());
    await write(
      '.github/workflows/bootstrap-branding.yml',
      writer('bootstrap-branding', omitConcurrency: omitWriterConcurrency),
    );
    await write(
      '.github/workflows/bootstrap-platforms.yml',
      writer('bootstrap-platforms'),
    );
    await write('.github/workflows/format-code.yml', writer('format-code'));
    await write(
      '.github/workflows/lock-dependencies.yml',
      writer('lock-dependencies'),
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

  test('secure workflow fixture passes', () async {
    final result = await runAudit(await fixture());

    expect(
      result.process.exitCode,
      0,
      reason: result.process.stderr.toString(),
    );
    expect(result.json['secure'], isTrue);
    expect(result.json['workflowCount'], 5);
    expect(result.json['failures'], isEmpty);
  });

  test('remote actions must use immutable commit revisions', () async {
    final result = await runAudit(await fixture(mutableCiAction: true));

    expect(result.process.exitCode, 1);
    expect(result.json['secure'], isFalse);
    expect(
      (result.json['failures'] as List<dynamic>).join('\n'),
      contains('mutable or unpinned Action reference'),
    );
  });

  test('every workflow job must have a timeout', () async {
    final result = await runAudit(await fixture(omitCiTimeout: true));

    expect(result.process.exitCode, 1);
    expect(
      (result.json['failures'] as List<dynamic>).join('\n'),
      contains('job quality must declare timeout-minutes'),
    );
  });

  test('read-only checkout credentials must not persist', () async {
    final result = await runAudit(
      await fixture(persistReadOnlyCredentials: true),
    );

    expect(result.process.exitCode, 1);
    expect(
      (result.json['failures'] as List<dynamic>).join('\n'),
      contains('disables checkout credential persistence for 0 of 1'),
    );
  });

  test('repository writers must serialize overlapping pushes', () async {
    final result = await runAudit(await fixture(omitWriterConcurrency: true));

    expect(result.process.exitCode, 1);
    expect(
      (result.json['failures'] as List<dynamic>).join('\n'),
      contains('must serialize/cancel overlapping repository writes'),
    );
  });

  test('privileged pull_request_target triggers fail closed', () async {
    final result = await runAudit(await fixture(addPrivilegedTrigger: true));

    expect(result.process.exitCode, 1);
    expect(
      (result.json['failures'] as List<dynamic>).join('\n'),
      contains('must not use the privileged pull_request_target trigger'),
    );
  });

  test('permanent CI must retain audit wiring', () async {
    final result = await runAudit(await fixture(omitCiWiring: true));

    expect(result.process.exitCode, 1);
    expect(
      (result.json['failures'] as List<dynamic>).join('\n'),
      contains('Permanent CI must run the workflow security audit'),
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
