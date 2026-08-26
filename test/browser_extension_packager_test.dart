import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('packager creates Chromium and Firefox packages from web output', () async {
    final temp = await Directory.systemTemp.createTemp(
      'nova_2048_extension_packager_',
    );
    addTearDown(() async {
      if (await temp.exists()) {
        await temp.delete(recursive: true);
      }
    });

    final webBuild = Directory('${temp.path}${Platform.pathSeparator}web');
    await Directory(
      '${webBuild.path}${Platform.pathSeparator}icons',
    ).create(recursive: true);
    await File(
      '${webBuild.path}${Platform.pathSeparator}index.html',
    ).writeAsString(
      '<!doctype html><html><head><base href="/app/"></head><body></body></html>',
    );
    await File(
      '${webBuild.path}${Platform.pathSeparator}flutter_bootstrap.js',
    ).writeAsString('/* fixture */');
    await File(
      '${webBuild.path}${Platform.pathSeparator}manifest.json',
    ).writeAsString('{}');
    await File(
      '${webBuild.path}${Platform.pathSeparator}icons${Platform.pathSeparator}Icon-192.png',
    ).writeAsBytes(<int>[1]);
    await File(
      '${webBuild.path}${Platform.pathSeparator}icons${Platform.pathSeparator}Icon-512.png',
    ).writeAsBytes(<int>[1]);

    final output = Directory(
      '${temp.path}${Platform.pathSeparator}browser-extension',
    );
    final result = await Process.run(Platform.resolvedExecutable, <String>[
      'run',
      'tool/package_browser_extension.dart',
      '--browser=all',
      '--build-dir=${webBuild.path}',
      '--output-dir=${output.path}',
      '--json',
    ], workingDirectory: Directory.current.path);

    expect(result.exitCode, 0, reason: '${result.stdout}\n${result.stderr}');

    final summary = jsonDecode(result.stdout as String) as Map<String, dynamic>;
    expect(summary['browsers'], <String>['chromium', 'firefox']);

    final pubspec = File('pubspec.yaml').readAsStringSync();
    final versionMatch = RegExp(
      r'^version:\s*([0-9]+\.[0-9]+\.[0-9]+)(?:\+[0-9]+)?\s*$',
      multiLine: true,
    ).firstMatch(pubspec);
    expect(versionMatch, isNotNull);
    final expectedVersion = versionMatch!.group(1)!;

    for (final browser in <String>['chromium', 'firefox']) {
      final root = Directory('${output.path}${Platform.pathSeparator}$browser');
      expect(await root.exists(), isTrue);
      expect(
        await File('${root.path}${Platform.pathSeparator}popup.html').exists(),
        isTrue,
      );
      expect(
        await File(
          '${root.path}${Platform.pathSeparator}app${Platform.pathSeparator}index.html',
        ).exists(),
        isTrue,
      );

      final manifest =
          jsonDecode(
                await File(
                  '${root.path}${Platform.pathSeparator}manifest.json',
                ).readAsString(),
              )
              as Map<String, dynamic>;
      expect(manifest['manifest_version'], 3);
      expect(manifest['version'], expectedVersion);
      expect(manifest.containsKey('permissions'), isFalse);
      expect(manifest.containsKey('host_permissions'), isFalse);
    }

    final chromium =
        jsonDecode(
              await File(
                '${output.path}${Platform.pathSeparator}chromium${Platform.pathSeparator}manifest.json',
              ).readAsString(),
            )
            as Map<String, dynamic>;
    final firefox =
        jsonDecode(
              await File(
                '${output.path}${Platform.pathSeparator}firefox${Platform.pathSeparator}manifest.json',
              ).readAsString(),
            )
            as Map<String, dynamic>;

    expect(chromium.containsKey('browser_specific_settings'), isFalse);
    expect(
      ((firefox['browser_specific_settings'] as Map<String, dynamic>)['gecko']
          as Map<String, dynamic>)['id'],
      'nova-2048@sanskarin',
    );
  });
}
