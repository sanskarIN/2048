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
  test(
    'candidate gate rejects passed evidence without a timezone offset',
    () async {
      final root = await Directory.systemTemp.createTemp(
        'nova-release-evidence-time-',
      );
      addTearDown(() async {
        if (root.existsSync()) {
          await root.delete(recursive: true);
        }
      });

      Future<void> write(String relativePath, String contents) async {
        final file = File.fromUri(root.uri.resolve(relativePath));
        await file.parent.create(recursive: true);
        await file.writeAsString(contents);
      }

      for (final path in const <String>[
        'README.md',
        'SECURITY.md',
        'SUPPORT.md',
        'CONTRIBUTING.md',
        'what_changed.md',
        '.github/workflows/ci.yml',
        '.github/workflows/platform-builds.yml',
      ]) {
        await write(path, 'fixture\n');
      }
      await write('pubspec.yaml', 'name: fixture\nversion: 1.5.0+15\n');
      await write('CHANGELOG.md', '# Changelog\n\n## [Unreleased]\n');
      await write(
        'ROADMAP.md',
        '# Roadmap\n\nRemaining release qualification before `1.5.0`\n',
      );

      final checks = _requiredCheckIds
          .map(
            (id) => <String, Object?>{
              'id': id,
              'title': 'Qualification for $id',
              'status': id == 'android-device' ? 'passed' : 'pending',
              'evidence': id == 'android-device'
                  ? 'Physical device evidence'
                  : '',
              'updatedAt': id == 'android-device'
                  ? '2026-08-17T14:30:00'
                  : null,
            },
          )
          .toList(growable: false);
      await write(
        'docs/release_qualification.json',
        const JsonEncoder.withIndent('  ').convert(<String, Object?>{
          'schemaVersion': 1,
          'candidate': '1.5.0+15',
          'manualChecks': checks,
        }),
      );

      final scriptPath = File('tool/release_readiness.dart').absolute.path;
      final result = await Process.run('dart', <String>[
        scriptPath,
        '--root=${root.path}',
        '--json',
      ]);
      expect(result.stdout, isNotEmpty, reason: result.stderr.toString());
      final output =
          jsonDecode(result.stdout as String) as Map<String, dynamic>;

      expect(result.exitCode, 1);
      expect(output['candidateGatePassed'], isFalse);
      expect(
        (output['failures'] as List<dynamic>).join('\n'),
        contains('explicit UTC or numeric offset'),
      );
    },
  );
}
