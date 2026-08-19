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
  'what_changed_archive_phase_00_30.md',
  'what_changed_archive_phase_31.md',
  'android/key.properties.example',
  'windows/runner/Runner.rc',
  'docs/PWA.md',
  'docs/REPOSITORY_AUDIT.md',
  'docs/RELEASE_QUALIFICATION.md',
  'docs/QUALIFICATION_RECORDER.md',
  'docs/QUALIFICATION_STATUS.md',
  'docs/PHASE_31_VERIFICATION.md',
  'docs/PHASE_32_VERSION_2_0_12.md',
  'docs/RELEASE_CHECKLIST.md',
  'docs/BUILDING_EXECUTABLES.md',
  'web/index.html',
  'web/manifest.json',
  'web/favicon.svg',
  'web/icons/Icon-192.png',
  'web/icons/Icon-512.png',
  'web/icons/Icon-maskable-192.png',
  'web/icons/Icon-maskable-512.png',
  'tool/README.md',
  'tool/release_readiness.dart',
  'tool/record_release_qualification.dart',
  'tool/release_qualification_status.dart',
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
    String packageVersion = '2.0.12+2012',
    String projectVersion = '2.0.12',
    String? candidate,
    String homepage = 'https://github.com/sanskarIN/2048',
    String repository = 'https://github.com/sanskarIN/2048',
    String issueTracker = 'https://github.com/sanskarIN/2048/issues',
    String webManifestId = '.',
    String webHtmlLang = 'en',
    String windowsVersionNumber = '2,0,12,2012',
    String windowsVersionString = '2.0.12',
    String readme = '# Fixture\n\n[Docs](docs/README.md)\n',
    bool temporaryWorkflow = false,
    bool temporaryPhase31Helper = false,
    bool temporaryPhase32Helper = false,
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
          '- **Current phase:** Phase 32 — final fixture\n'
          '- package candidate `2.0.12+2012`\n'
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
      'windows/runner/Runner.rc',
      '#define VERSION_AS_NUMBER $windowsVersionNumber\n'
          '#define VERSION_AS_STRING "$windowsVersionString"\n',
    );
    await write(
      'docs/release_qualification.json',
      '${const JsonEncoder.withIndent('  ').convert(<String, Object?>{
        'schemaVersion': 1,
        'candidate': candidate ?? packageVersion,
        'manualChecks': _manualCheckIds.map((id) => <String, Object?>{'id': id, 'title': 'Qualification for $id', 'status': 'pending', 'evidence': '', 'updatedAt': null}).toList(growable: false),
      })}\n',
    );
    await write(
      'web/manifest.json',
      '${const JsonEncoder.withIndent('  ').convert(<String, Object?>{
        'name': '2048 Nova',
        'short_name': '2048 Nova',
        'id': webManifestId,
        'start_url': '.',
        'scope': '.',
        'display': 'standalone',
        'background_color': '#111318',
        'theme_color': '#6C4DFF',
        'description': 'Fixture manifest',
        'lang': 'en',
        'dir': 'ltr',
        'orientation': 'any',
        'categories': <String>['games', 'entertainment'],
        'prefer_related_applications': false,
        'icons': <Map<String, String>>[
          <String, String>{'src': 'icons/Icon-192.png', 'sizes': '192x192', 'type': 'image/png', 'purpose': 'any'},
          <String, String>{'src': 'icons/Icon-512.png', 'sizes': '512x512', 'type': 'image/png', 'purpose': 'any'},
          <String, String>{'src': 'icons/Icon-maskable-192.png', 'sizes': '192x192', 'type': 'image/png', 'purpose': 'maskable'},
          <String, String>{'src': 'icons/Icon-maskable-512.png', 'sizes': '512x512', 'type': 'image/png', 'purpose': 'maskable'},
        ],
      })}\n',
    );
    await write(
      'web/index.html',
      '<!DOCTYPE html>\n'
          '<html lang="$webHtmlLang">\n'
          '<head>\n'
          '<base href="\$FLUTTER_BASE_HREF">\n'
          '<meta name="theme-color" content="#6C4DFF">\n'
          '<meta name="color-scheme" content="light dark">\n'
          '<meta name="mobile-web-app-capable" content="yes">\n'
          '<meta name="apple-mobile-web-app-capable" content="yes">\n'
          '<meta name="apple-mobile-web-app-title" content="2048 Nova">\n'
          '<link rel="manifest" href="manifest.json">\n'
          '<link rel="apple-touch-icon" href="icons/Icon-192.png">\n'
          '<title>2048 Nova</title>\n'
          '</head>\n'
          '<body><script src="flutter_bootstrap.js" async></script></body>\n'
          '</html>\n',
    );

    if (temporaryWorkflow) {
      await write(
        '.github/workflows/phase30-finalize.yml',
        'name: temporary\n',
      );
    }
    if (temporaryPhase31Helper) {
      await write(
        '.github/workflows/phase31-finalize.yml',
        'name: temporary\n',
      );
      await write('docs/PHASE_31_STATUS_TRIGGER.md', 'temporary\n');
      await write('tool/phase31_finalize.py', 'temporary\n');
    }
    if (temporaryPhase32Helper) {
      await write(
        '.github/workflows/phase32-finalize.yml',
        'name: temporary\n',
      );
      await write('docs/PHASE_32_TRIGGER.md', 'temporary\n');
      await write('tool/phase32_finalize.py', 'temporary\n');
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

  test('clean Phase 32 fixture passes the repository audit', () async {
    final root = await fixture();

    final result = await runAudit(root);

    expect(
      result.process.exitCode,
      0,
      reason: result.process.stderr.toString(),
    );
    expect(result.json['packageVersion'], '2.0.12+2012');
    expect(result.json['marketingVersion'], '2.0.12');
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

  test('exact package build-version drift is rejected', () async {
    final root = await fixture(packageVersion: '2.0.12+2013');

    final result = await runAudit(root);

    expect(result.process.exitCode, 1);
    expect(
      (result.json['failures'] as List<dynamic>).join('\n'),
      contains('pubspec version must be 2.0.12+2012 for Phase 32'),
    );
  });

  test('runtime marketing-version drift is rejected', () async {
    final root = await fixture(projectVersion: '2.0.11');

    final result = await runAudit(root);

    expect(result.process.exitCode, 1);
    expect(
      (result.json['failures'] as List<dynamic>).join('\n'),
      contains('must match marketing version 2.0.12'),
    );
  });

  test('Windows fallback version drift is rejected', () async {
    final root = await fixture(windowsVersionNumber: '2,0,12,2011');

    final result = await runAudit(root);

    expect(result.process.exitCode, 1);
    expect(
      (result.json['failures'] as List<dynamic>).join('\n'),
      contains('Windows fallback VERSION_AS_NUMBER must be 2,0,12,2012'),
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
    final root = await fixture(candidate: '2.0.12+9999');

    final result = await runAudit(root);

    expect(result.process.exitCode, 1);
    expect(
      (result.json['failures'] as List<dynamic>).join('\n'),
      contains('must match pubspec version'),
    );
  });

  test('Web PWA identity drift is rejected', () async {
    final root = await fixture(webManifestId: '/wrong-app/');

    final result = await runAudit(root);

    expect(result.process.exitCode, 1);
    expect(
      (result.json['failures'] as List<dynamic>).join('\n'),
      contains('web/manifest.json id must be .'),
    );
  });

  test('Web PWA HTML language drift is rejected', () async {
    final root = await fixture(webHtmlLang: 'hi');

    final result = await runAudit(root);

    expect(result.process.exitCode, 1);
    expect(
      (result.json['failures'] as List<dynamic>).join('\n'),
      contains('web/index.html is missing required metadata: <html lang="en">'),
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

  test('Phase 31 finalizer artifacts are rejected', () async {
    final root = await fixture(temporaryPhase31Helper: true);

    final result = await runAudit(root);

    expect(result.process.exitCode, 1);
    final failures = (result.json['failures'] as List<dynamic>).join('\n');
    expect(failures, contains('.github/workflows/phase31-finalize.yml'));
    expect(failures, contains('docs/PHASE_31_STATUS_TRIGGER.md'));
    expect(failures, contains('tool/phase31_finalize.py'));
  });

  test('Phase 32 finalizer artifacts are rejected', () async {
    final root = await fixture(temporaryPhase32Helper: true);

    final result = await runAudit(root);

    expect(result.process.exitCode, 1);
    final failures = (result.json['failures'] as List<dynamic>).join('\n');
    expect(failures, contains('.github/workflows/phase32-finalize.yml'));
    expect(failures, contains('docs/PHASE_32_TRIGGER.md'));
    expect(failures, contains('tool/phase32_finalize.py'));
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
