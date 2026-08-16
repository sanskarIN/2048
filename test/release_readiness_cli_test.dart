import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

const _requiredCheckIds = <String>[
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

void main() {
  late String scriptPath;
  final temporaryRoots = <Directory>[];

  setUpAll(() {
    scriptPath = File('tool/release_readiness.dart').absolute.path;
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
    String version = '1.5.0+15',
    String? candidate,
    bool stableMetadata = false,
    bool passedEvidence = false,
    List<Map<String, Object?>>? checks,
  }) async {
    final root = await Directory.systemTemp.createTemp(
      'nova-release-readiness-',
    );
    temporaryRoots.add(root);

    Future<void> write(String relativePath, String contents) async {
      final file = File.fromUri(root.uri.resolve(relativePath));
      await file.parent.create(recursive: true);
      await file.writeAsString(contents);
    }

    const requiredNonSpecialFiles = <String>[
      'README.md',
      'SECURITY.md',
      'SUPPORT.md',
      'CONTRIBUTING.md',
      'what_changed.md',
      '.github/workflows/ci.yml',
      '.github/workflows/platform-builds.yml',
    ];
    for (final path in requiredNonSpecialFiles) {
      await write(path, 'fixture\n');
    }

    await write('pubspec.yaml', 'name: fixture\nversion: $version\n');
    await write(
      'CHANGELOG.md',
      '# Changelog\n\n## [Unreleased]\n'
          '${stableMetadata ? '\n## [1.5.0]\n' : ''}',
    );
    await write(
      'ROADMAP.md',
      '# Roadmap\n\nRemaining release qualification before `1.5.0`\n',
    );

    final manifestChecks =
        checks ??
        _requiredCheckIds
            .map(
              (id) => <String, Object?>{
                'id': id,
                'title': 'Qualification for $id',
                'status': passedEvidence ? 'passed' : 'pending',
                'evidence': passedEvidence ? 'Verified fixture evidence' : '',
                'updatedAt': passedEvidence
                    ? '2026-08-16T12:30:00+05:30'
                    : null,
              },
            )
            .toList(growable: false);

    await write(
      'docs/release_qualification.json',
      const JsonEncoder.withIndent('  ').convert(<String, Object?>{
        'schemaVersion': 1,
        'candidate': candidate ?? version,
        'manualChecks': manifestChecks,
      }),
    );

    return root;
  }

  Future<({ProcessResult process, Map<String, dynamic> json})> runGate(
    Directory root, {
    bool stable = false,
  }) async {
    final arguments = <String>[
      scriptPath,
      '--root=${root.path}',
      '--json',
      if (stable) '--stable',
    ];
    final result = await Process.run('dart', arguments);
    expect(result.stdout, isNotEmpty, reason: result.stderr.toString());
    final decoded = jsonDecode(result.stdout as String);
    expect(decoded, isA<Map<String, dynamic>>());
    return (process: result, json: decoded as Map<String, dynamic>);
  }

  test(
    'candidate fixture passes while stable readiness remains false',
    () async {
      final root = await fixture();

      final result = await runGate(root);

      expect(result.process.exitCode, 0);
      expect(result.json['mode'], 'candidate');
      expect(result.json['version'], '1.5.0+15');
      expect(result.json['candidateGatePassed'], isTrue);
      expect(result.json['readyForStable'], isFalse);
      expect(result.json['manualChecksPassed'], 0);
      expect(result.json['manualChecksRequired'], 13);
      expect(result.json['failures'], isEmpty);
    },
  );

  test('stable fixture passes with complete metadata and evidence', () async {
    final root = await fixture(
      version: '1.5.0+15',
      stableMetadata: true,
      passedEvidence: true,
    );

    final result = await runGate(root, stable: true);

    expect(
      result.process.exitCode,
      0,
      reason: result.process.stderr.toString(),
    );
    expect(result.json['mode'], 'stable');
    expect(result.json['candidateGatePassed'], isTrue);
    expect(result.json['readyForStable'], isTrue);
    expect(result.json['manualChecksPassed'], 13);
    expect(result.json['failures'], isEmpty);
  });

  test('stable mode fails closed while manual evidence is pending', () async {
    final root = await fixture(version: '1.5.0', stableMetadata: true);

    final result = await runGate(root, stable: true);

    expect(result.process.exitCode, 1);
    expect(result.json['readyForStable'], isFalse);
    expect(
      (result.json['failures'] as List<dynamic>).join('\n'),
      contains('android-device'),
    );
  });

  test('legacy 0.9 candidate is rejected after the 1.5 migration', () async {
    final root = await fixture(version: '0.9.99+99');

    final result = await runGate(root);

    expect(result.process.exitCode, 1);
    expect(result.json['candidateGatePassed'], isFalse);
    expect(
      (result.json['failures'] as List<dynamic>).join('\n'),
      contains('1.5.x current release line'),
    );
  });

  test('candidate mismatch is rejected', () async {
    final root = await fixture(candidate: '1.5.99+99');

    final result = await runGate(root);

    expect(result.process.exitCode, 1);
    expect(result.json['candidateGatePassed'], isFalse);
    expect(
      (result.json['failures'] as List<dynamic>).join('\n'),
      contains('must match pubspec version'),
    );
  });

  test('passed check without evidence or timestamp is rejected', () async {
    final checks = _requiredCheckIds
        .map(
          (id) => <String, Object?>{
            'id': id,
            'title': 'Qualification for $id',
            'status': id == 'android-device' ? 'passed' : 'pending',
            'evidence': '',
            'updatedAt': null,
          },
        )
        .toList(growable: false);
    final root = await fixture(checks: checks);

    final result = await runGate(root);

    expect(result.process.exitCode, 1);
    expect(
      (result.json['failures'] as List<dynamic>).join('\n'),
      contains('must include non-empty evidence'),
    );
  });

  test('missing required manual check id is rejected', () async {
    final checks = _requiredCheckIds
        .take(_requiredCheckIds.length - 1)
        .map(
          (id) => <String, Object?>{
            'id': id,
            'title': 'Qualification for $id',
            'status': 'pending',
            'evidence': '',
            'updatedAt': null,
          },
        )
        .toList(growable: false);
    final root = await fixture(checks: checks);

    final result = await runGate(root);

    expect(result.process.exitCode, 1);
    expect(
      (result.json['failures'] as List<dynamic>).join('\n'),
      contains('Missing required manual check id: distribution-metadata'),
    );
  });
}
