import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  late String scriptPath;
  final temporaryRoots = <Directory>[];

  setUpAll(() {
    scriptPath = File('tool/platform_support_audit.dart').absolute.path;
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
    String? missingRunner,
    String? missingBuildCommand,
    bool omitWebPackaging = false,
    bool omitCiWiring = false,
  }) async {
    final root = await Directory.systemTemp.createTemp('nova-platform-audit-');
    temporaryRoots.add(root);

    Future<void> write(String path, [String contents = 'configured\n']) async {
      if (path == missingRunner) {
        return;
      }
      final file = File.fromUri(root.uri.resolve(path));
      await file.parent.create(recursive: true);
      await file.writeAsString(contents);
    }

    for (final path in <String>[
      'android/app/build.gradle.kts',
      'android/app/src/main/AndroidManifest.xml',
      'ios/Runner/Info.plist',
      'ios/Runner.xcodeproj/project.pbxproj',
      'web/index.html',
      'web/manifest.json',
      'windows/CMakeLists.txt',
      'windows/runner/main.cpp',
      'macos/Runner/Info.plist',
      'macos/Runner.xcodeproj/project.pbxproj',
      'linux/CMakeLists.txt',
      'linux/runner/main.cc',
    ]) {
      await write(path);
    }

    final buildCommands = <String>[
      'flutter build apk --release',
      'flutter build appbundle --release',
      'flutter build ios --release --no-codesign',
      'flutter build web --release',
      'flutter build windows --release',
      'flutter build macos --release',
      'flutter build linux --release',
    ]..remove(missingBuildCommand);

    final workflow = StringBuffer()
      ..writeln('name: Platform Builds')
      ..writeln('paths:')
      ..writeln('  - android/**')
      ..writeln('  - ios/**')
      ..writeln('  - web/**')
      ..writeln('  - windows/**')
      ..writeln('  - macos/**')
      ..writeln('  - linux/**');
    for (final command in buildCommands) {
      workflow.writeln('run: $command');
    }
    if (!omitWebPackaging) {
      workflow
        ..writeln('test -f build/web/index.html')
        ..writeln('test -f build/web/manifest.json')
        ..writeln('test -f build/web/flutter_service_worker.js')
        ..writeln('nova-2048-web-pwa.tar.gz')
        ..writeln('nova-2048-web-pwa.tar.gz.sha256')
        ..writeln('nova-2048-web-pwa-release');
    }
    await write('.github/workflows/platform-builds.yml', workflow.toString());
    await write(
      '.github/workflows/ci.yml',
      omitCiWiring
          ? 'name: CI\n'
          : 'run: dart run tool/platform_support_audit.dart --json\n',
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

  test('complete six-target fixture passes', () async {
    final result = await runAudit(await fixture());

    expect(result.process.exitCode, 0, reason: result.process.stderr.toString());
    expect(result.json['crossPlatformReady'], isTrue);
    expect(
      result.json['supportedTargets'],
      <String>['Android', 'iOS', 'Web/PWA', 'Windows', 'macOS', 'Linux'],
    );
    expect(result.json['failures'], isEmpty);
  });

  test('missing runner file fails closed', () async {
    final result = await runAudit(
      await fixture(missingRunner: 'windows/runner/main.cpp'),
    );

    expect(result.process.exitCode, 1);
    expect(result.json['crossPlatformReady'], isFalse);
    expect(
      (result.json['failures'] as List<dynamic>).join('\n'),
      contains('Windows runner file is missing: windows/runner/main.cpp'),
    );
  });

  test('missing platform build command fails closed', () async {
    const command = 'flutter build linux --release';
    final result = await runAudit(await fixture(missingBuildCommand: command));

    expect(result.process.exitCode, 1);
    expect(
      (result.json['failures'] as List<dynamic>).join('\n'),
      contains('Linux release command: $command'),
    );
  });

  test('Web PWA must be packaged as a qualification artifact', () async {
    final result = await runAudit(await fixture(omitWebPackaging: true));

    expect(result.process.exitCode, 1);
    final failures = (result.json['failures'] as List<dynamic>).join('\n');
    expect(failures, contains('Web/PWA qualification packaging is missing'));
    expect(failures, contains('nova-2048-web-pwa-release'));
  });

  test('permanent CI must retain platform audit wiring', () async {
    final result = await runAudit(await fixture(omitCiWiring: true));

    expect(result.process.exitCode, 1);
    expect(
      (result.json['failures'] as List<dynamic>).join('\n'),
      contains('Permanent CI must run the cross-platform support audit'),
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
