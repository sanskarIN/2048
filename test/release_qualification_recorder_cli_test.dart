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
    scriptPath = File('tool/record_release_qualification.dart').absolute.path;
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

  Future<Directory> fixture({bool androidPassed = false}) async {
    final root = await Directory.systemTemp.createTemp(
      'nova-release-recorder-',
    );
    temporaryRoots.add(root);

    final manifestFile = File.fromUri(
      root.uri.resolve('docs/release_qualification.json'),
    );
    await manifestFile.parent.create(recursive: true);
    await manifestFile.writeAsString(
      '${const JsonEncoder.withIndent('  ').convert(<String, Object?>{
        'schemaVersion': 1,
        'candidate': '1.5.0+15',
        'manualChecks': _requiredCheckIds.map((id) => <String, Object?>{'id': id, 'title': 'Qualification for $id', 'status': androidPassed && id == 'android-device' ? 'passed' : 'pending', 'evidence': androidPassed && id == 'android-device' ? 'Old verified evidence' : '', 'updatedAt': androidPassed && id == 'android-device' ? '2026-08-16T07:00:00Z' : null}).toList(growable: false),
      })}\n',
    );
    return root;
  }

  Future<ProcessResult> runRecorder(Directory root, List<String> arguments) {
    return Process.run('dart', <String>[
      scriptPath,
      '--root=${root.path}',
      ...arguments,
    ]);
  }

  Map<String, dynamic> readManifest(Directory root) {
    final text = File.fromUri(
      root.uri.resolve('docs/release_qualification.json'),
    ).readAsStringSync();
    return jsonDecode(text) as Map<String, dynamic>;
  }

  Map<String, dynamic> checkById(Map<String, dynamic> manifest, String id) {
    final checks = manifest['manualChecks'] as List<dynamic>;
    return checks.cast<Map<String, dynamic>>().singleWhere(
      (check) => check['id'] == id,
    );
  }

  test(
    '--list reports all required checks without mutating manifest',
    () async {
      final root = await fixture();
      final before = File.fromUri(
        root.uri.resolve('docs/release_qualification.json'),
      ).readAsStringSync();

      final result = await runRecorder(root, const <String>['--list']);

      expect(result.exitCode, 0, reason: result.stderr.toString());
      expect(result.stdout, contains('android-device: pending'));
      expect(result.stdout, contains('distribution-metadata: pending'));
      final after = File.fromUri(
        root.uri.resolve('docs/release_qualification.json'),
      ).readAsStringSync();
      expect(after, before);
    },
  );

  test(
    'passed status records evidence and normalizes timestamp to UTC',
    () async {
      final root = await fixture();

      final result = await runRecorder(root, const <String>[
        '--id=android-device',
        '--status=passed',
        '--evidence=Pixel test passed lifecycle and save resume checks',
        '--updated-at=2026-08-18T15:30:00+05:30',
      ]);

      expect(result.exitCode, 0, reason: result.stderr.toString());
      final check = checkById(readManifest(root), 'android-device');
      expect(check['status'], 'passed');
      expect(
        check['evidence'],
        'Pixel test passed lifecycle and save resume checks',
      );
      expect(check['updatedAt'], '2026-08-18T10:00:00.000Z');
    },
  );

  test('passed status refuses empty evidence', () async {
    final root = await fixture();

    final result = await runRecorder(root, const <String>[
      '--id=android-device',
      '--status=passed',
    ]);

    expect(result.exitCode, isNot(0));
    expect(result.stderr, contains('requires non-empty --evidence'));
    expect(
      checkById(readManifest(root), 'android-device')['status'],
      'pending',
    );
  });

  test('timezone-less explicit timestamp is rejected', () async {
    final root = await fixture();

    final result = await runRecorder(root, const <String>[
      '--id=android-device',
      '--status=passed',
      '--evidence=Real device evidence',
      '--updated-at=2026-08-18T15:30:00',
    ]);

    expect(result.exitCode, isNot(0));
    expect(result.stderr, contains('ending in Z or a numeric offset'));
    expect(
      checkById(readManifest(root), 'android-device')['status'],
      'pending',
    );
  });

  test('unknown manual-check id is rejected', () async {
    final root = await fixture();

    final result = await runRecorder(root, const <String>[
      '--id=not-a-real-check',
      '--status=blocked',
      '--evidence=Fixture blocker',
    ]);

    expect(result.exitCode, isNot(0));
    expect(result.stderr, contains('Unknown manual check id'));
  });

  test('pending status clears previous evidence and timestamp', () async {
    final root = await fixture(androidPassed: true);

    final result = await runRecorder(root, const <String>[
      '--id=android-device',
      '--status=pending',
    ]);

    expect(result.exitCode, 0, reason: result.stderr.toString());
    final check = checkById(readManifest(root), 'android-device');
    expect(check['status'], 'pending');
    expect(check['evidence'], '');
    expect(check['updatedAt'], isNull);
  });

  test('--dry-run prints the changed manifest without writing it', () async {
    final root = await fixture();
    final before = File.fromUri(
      root.uri.resolve('docs/release_qualification.json'),
    ).readAsStringSync();

    final result = await runRecorder(root, const <String>[
      '--id=android-device',
      '--status=blocked',
      '--evidence=Waiting for physical device access',
      '--updated-at=2026-08-18T10:00:00Z',
      '--dry-run',
    ]);

    expect(result.exitCode, 0, reason: result.stderr.toString());
    final preview = jsonDecode(result.stdout as String) as Map<String, dynamic>;
    expect(checkById(preview, 'android-device')['status'], 'blocked');
    final after = File.fromUri(
      root.uri.resolve('docs/release_qualification.json'),
    ).readAsStringSync();
    expect(after, before);
  });
}
