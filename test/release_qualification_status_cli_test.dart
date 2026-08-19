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
    scriptPath = File('tool/release_qualification_status.dart').absolute.path;
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
    Set<String> passed = const <String>{},
    Set<String> blocked = const <String>{},
    List<String> ids = _requiredCheckIds,
  }) async {
    final root = await Directory.systemTemp.createTemp('nova-release-status-');
    temporaryRoots.add(root);
    final manifestFile = File.fromUri(
      root.uri.resolve('docs/release_qualification.json'),
    );
    await manifestFile.parent.create(recursive: true);
    final checks = <Map<String, Object?>>[
      for (final id in ids)
        <String, Object?>{
          'id': id,
          'title': 'Qualification for $id',
          'status': passed.contains(id)
              ? 'passed'
              : blocked.contains(id)
              ? 'blocked'
              : 'pending',
          'evidence': passed.contains(id)
              ? 'Verified evidence for $id'
              : blocked.contains(id)
              ? 'Blocked evidence for $id'
              : '',
          'updatedAt': passed.contains(id) || blocked.contains(id)
              ? '2026-08-19T01:30:00Z'
              : null,
        },
    ];
    await manifestFile.writeAsString(
      '${const JsonEncoder.withIndent('  ').convert(<String, Object?>{'schemaVersion': 1, 'candidate': '1.5.0+15', 'manualChecks': checks})}\n',
    );
    return root;
  }

  Future<ProcessResult> runStatus(Directory root, List<String> arguments) {
    return Process.run('dart', <String>[
      scriptPath,
      '--root=${root.path}',
      ...arguments,
    ]);
  }

  test('human report summarizes the canonical pending checklist', () async {
    final root = await fixture();

    final result = await runStatus(root, const <String>[]);

    expect(result.exitCode, 0, reason: result.stderr.toString());
    expect(result.stdout, contains('Candidate: 1.5.0+15'));
    expect(
      result.stdout,
      contains('Progress: 0/13 passed, 13 pending, 0 blocked'),
    );
    expect(result.stdout, contains('Complete: no'));
    expect(result.stdout, contains('android-device: pending'));
    expect(result.stdout, contains('distribution-metadata: pending'));
  });

  test('--json returns stable aggregate counts and all checks', () async {
    final root = await fixture(
      passed: const <String>{'android-device'},
      blocked: const <String>{'ios-device'},
    );

    final result = await runStatus(root, const <String>['--json']);

    expect(result.exitCode, 0, reason: result.stderr.toString());
    final report = jsonDecode(result.stdout as String) as Map<String, dynamic>;
    expect(report['candidate'], '1.5.0+15');
    expect(report['total'], 13);
    expect(report['passed'], 1);
    expect(report['pending'], 11);
    expect(report['blocked'], 1);
    expect(report['complete'], isFalse);
    expect((report['checks'] as List<dynamic>), hasLength(13));
  });

  test(
    '--pending-only filters details without changing summary counts',
    () async {
      final root = await fixture(
        passed: const <String>{'android-device'},
        blocked: const <String>{'ios-device'},
      );

      final result = await runStatus(root, const <String>[
        '--json',
        '--pending-only',
      ]);

      expect(result.exitCode, 0, reason: result.stderr.toString());
      final report =
          jsonDecode(result.stdout as String) as Map<String, dynamic>;
      expect(report['total'], 13);
      expect(report['passed'], 1);
      expect(report['pending'], 11);
      expect(report['blocked'], 1);
      final checks = (report['checks'] as List<dynamic>)
          .cast<Map<String, dynamic>>();
      expect(checks, hasLength(12));
      expect(checks.any((check) => check['id'] == 'android-device'), isFalse);
      expect(checks.any((check) => check['id'] == 'ios-device'), isTrue);
    },
  );

  test('--fail-if-incomplete uses a distinct non-zero exit code', () async {
    final root = await fixture();

    final result = await runStatus(root, const <String>[
      '--fail-if-incomplete',
    ]);

    expect(result.exitCode, 3);
    expect(result.stdout, contains('Complete: no'));
  });

  test(
    'fully passed evidence reports complete and passes strict status',
    () async {
      final root = await fixture(passed: _requiredCheckIds.toSet());

      final result = await runStatus(root, const <String>[
        '--json',
        '--fail-if-incomplete',
      ]);

      expect(result.exitCode, 0, reason: result.stderr.toString());
      final report =
          jsonDecode(result.stdout as String) as Map<String, dynamic>;
      expect(report['passed'], 13);
      expect(report['pending'], 0);
      expect(report['blocked'], 0);
      expect(report['complete'], isTrue);
    },
  );

  test('missing canonical check is rejected as malformed evidence', () async {
    final root = await fixture(ids: _requiredCheckIds.sublist(1));

    final result = await runStatus(root, const <String>[]);

    expect(result.exitCode, 64);
    expect(
      result.stderr,
      contains('Missing required manual check id: android-device'),
    );
    expect(result.stderr, contains('exactly 13 manual checks'));
  });

  test('passed check without evidence is rejected', () async {
    final root = await fixture(passed: const <String>{'android-device'});
    final manifestFile = File.fromUri(
      root.uri.resolve('docs/release_qualification.json'),
    );
    final manifest =
        jsonDecode(manifestFile.readAsStringSync()) as Map<String, dynamic>;
    final checks = (manifest['manualChecks'] as List<dynamic>)
        .cast<Map<String, dynamic>>();
    checks.firstWhere((check) => check['id'] == 'android-device')['evidence'] =
        '';
    manifestFile.writeAsStringSync(jsonEncode(manifest));

    final result = await runStatus(root, const <String>[]);

    expect(result.exitCode, 64);
    expect(result.stderr, contains('with status passed needs evidence'));
  });
}
