import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

const _manualCheckIds = <String>[
  'android-device',
  'ios-device',
  'input-responsive',
  'assistive-tech',
  'long-session',
  'autoplay-real-target',
  'challenge-code-real-target',
  'move-replay-real-target',
  'full-replay-real-target',
  'backup-real-target',
  'external-handlers',
  'native-branding',
  'distribution-metadata',
];

const _requiredFixtureFiles = <String>[
  '.editorconfig',
  '.gitattributes',
  '.gitignore',
  'CHANGELOG.md',
  'ROADMAP.md',
  'SECURITY.md',
  'SUPPORT.md',
  'CONTRIBUTING.md',
  'CODE_OF_CONDUCT.md',
  'LICENSE',
  'AUTHORS.md',
  'analysis_options.yaml',
  'android/key.properties.example',
  'docs/REPOSITORY_AUDIT.md',
  'docs/RELEASE_QUALIFICATION.md',
  'docs/QUALIFICATION_RECORDER.md',
  'docs/RELEASE_CHECKLIST.md',
  'docs/BUILDING_EXECUTABLES.md',
  'tool/README.md',
  'tool/release_readiness.dart',
  'tool/record_release_qualification.dart',
  'tool/repository_audit.dart',
  '.github/CODEOWNERS',
  '.github/dependabot.yml',
  '.github/FUNDING.yml',
  '.github/ISSUE_TEMPLATE/config.yml',
  '.github/workflows/bootstrap-branding.yml',
  '.github/workflows/bootstrap-platforms.yml',
  '.github/workflows/ci.yml',
  '.github/workflows/dependency-review.yml',
  '.github/workflows/format-code.yml',
  '.github/workflows/lock-dependencies.yml',
  '.github/workflows/platform-builds.yml',
];

void main() {
  late String scriptPath;
  final temporaryRoots = <Directory>[];

  setUpAll(() {
    scriptPath = File('tool/repository_audit.dart').absolute.path;
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
    String packageVersion = '1.5.0+15',
    String projectVersion = '1.5.0',
    String? candidate,
    String homepage = 'https://github.com/sanskarIN/2048',
    String repository = 'https://github.com/sanskarIN/2048',
    String issueTracker = 'https://github.com/sanskarIN/2048/issues',
    String readme = '# Fixture\n\n[Docs](docs/README.md)\n',
    bool temporaryWorkflow = false,
    bool unclosedFence = false,
  }) async {
    final root = await Directory.systemTemp.createTemp('nova-repo-audit-');
    temporaryRoots.add(root);

    Future<void> write(String relativePath, String contents) async {
      final file = File.fromUri(root.uri.resolve(relativePath));
      await file.parent.create(recursive: true);
      await file.writeAsString(contents);
    }

    for (final path in _requiredFixtureFiles) {
      await write(path, 'fixture\n');
    }

    await write('README.md', readme);
    await write('docs/README.md', '# Documentation\n');
    await write(
      'what_changed.md',
      '# Log\n\n'
          '- **Current phase:** Phase 30 — final fixture\n'
          '- stable qualification boundary remains 0/13\n',
    );
    await write(
      'pubspec.yaml',
      'name: fixture\n'
          'version: $packageVersion\n'
          'homepage: $homepage\n'
          'repository: $repository\n'
          'issue_tracker: $issueTracker\n',
    );
    await write(
      'lib/core/constants/project_info.dart',
      "class ProjectInfo {\n  static const version = '$projectVersion';\n}\n",
    );
    await write(
      'docs/release_qualification.json',
      '${const JsonEncoder.withIndent('  ').convert(<String, Object?>{
        'schemaVersion': 1,
        'candidate': candidate ?? packageVersion,
        'manualChecks': _manualCheckIds.map((id) => <String, Object?>{'id': id, 'title': 'Qualification for $id', 'status': 'pending', 'evidence': '', 'updatedAt': null}).toList(growable: false),
      })}\n',
    );

    if (temporaryWorkflow) {
      await write(
        '.github/workflows/phase30-finalize.yml',
        'name: temporary\n',
      );
    }
    if (unclosedFence) {
      await write('docs/REPOSITORY_AUDIT.md', '# Audit\n\n```text\nopen\n');
    }

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

  test('clean fixture passes the repository audit', () async {
    final root = await fixture();

    final result = await runAudit(root);

    expect(
      result.process.exitCode,
      0,
      reason: result.process.stderr.toString(),
    );
    expect(result.json['passed'], isTrue);
    expect(result.json['failures'], isEmpty);
  });

  test('broken local Markdown link fails closed', () async {
    final root = await fixture(
      readme: '# Fixture\n\n[Missing](docs/DOES_NOT_EXIST.md)\n',
    );

    final result = await runAudit(root);

    expect(result.process.exitCode, 1);
    expect(result.json['passed'], isFalse);
    expect(
      (result.json['failures'] as List<dynamic>).join('\n'),
      contains('Broken local Markdown link'),
    );
  });

  test('runtime marketing-version drift is rejected', () async {
    final root = await fixture(projectVersion: '1.5.1');

    final result = await runAudit(root);

    expect(result.process.exitCode, 1);
    expect(
      (result.json['failures'] as List<dynamic>).join('\n'),
      contains('must match pubspec base version'),
    );
  });

  test('canonical repository metadata drift is rejected', () async {
    final root = await fixture(repository: 'https://example.invalid/2048');

    final result = await runAudit(root);

    expect(result.process.exitCode, 1);
    expect(
      (result.json['failures'] as List<dynamic>).join('\n'),
      contains('pubspec repository must be https://github.com/sanskarIN/2048'),
    );
  });

  test('qualification candidate drift is rejected', () async {
    final root = await fixture(candidate: '1.5.0+99');

    final result = await runAudit(root);

    expect(result.process.exitCode, 1);
    expect(
      (result.json['failures'] as List<dynamic>).join('\n'),
      contains('must match pubspec version'),
    );
  });

  test('temporary maintenance workflow is rejected', () async {
    final root = await fixture(temporaryWorkflow: true);

    final result = await runAudit(root);

    expect(result.process.exitCode, 1);
    expect(
      (result.json['failures'] as List<dynamic>).join('\n'),
      contains('Temporary repository path must not remain'),
    );
  });

  test('unclosed Markdown fence is reported as a warning', () async {
    final root = await fixture(unclosedFence: true);

    final result = await runAudit(root);

    expect(result.process.exitCode, 0);
    expect(result.json['passed'], isTrue);
    expect(
      (result.json['warnings'] as List<dynamic>).join('\n'),
      contains('unclosed Markdown code fence'),
    );
  });
}
