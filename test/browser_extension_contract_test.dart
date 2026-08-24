import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  Map<String, dynamic> readManifest(String path) {
    final rendered = File(
      path,
    ).readAsStringSync().replaceAll('__VERSION__', '9.9.9');
    return jsonDecode(rendered) as Map<String, dynamic>;
  }

  test('Chromium extension manifest stays permission-free Manifest V3', () {
    final manifest = readManifest(
      'extension/manifest.chromium.template.json',
    );

    expect(manifest['manifest_version'], 3);
    expect(manifest['version'], '9.9.9');
    expect(manifest.containsKey('permissions'), isFalse);
    expect(manifest.containsKey('host_permissions'), isFalse);
    expect(manifest.containsKey('browser_specific_settings'), isFalse);
    expect(
      (manifest['action'] as Map<String, dynamic>)['default_popup'],
      'popup.html',
    );
    expect(
      ((manifest['content_security_policy'] as Map<String, dynamic>)[
              'extension_pages'
          ] as String),
      contains("script-src 'self' 'wasm-unsafe-eval'"),
    );
  });

  test('Firefox manifest keeps stable Gecko privacy metadata', () {
    final manifest = readManifest(
      'extension/manifest.firefox.template.json',
    );
    final settings =
        manifest['browser_specific_settings'] as Map<String, dynamic>;
    final gecko = settings['gecko'] as Map<String, dynamic>;
    final collection =
        gecko['data_collection_permissions'] as Map<String, dynamic>;

    expect(manifest['manifest_version'], 3);
    expect(manifest.containsKey('permissions'), isFalse);
    expect(manifest.containsKey('host_permissions'), isFalse);
    expect(gecko['id'], 'nova-2048@sanskarin');
    expect(collection['required'], <String>['none']);
    expect(settings['gecko_android'], isA<Map<String, dynamic>>());
  });

  test('Extension popup hosts packaged Flutter output without scripts', () {
    final popup = File('extension/popup.html').readAsStringSync();

    expect(popup, contains('src="app/index.html"'));
    expect(popup, isNot(contains('<script')));
  });

  test('Extension packager retains shared Flutter app architecture', () {
    final packager = File(
      'tool/package_browser_extension.dart',
    ).readAsStringSync();

    expect(
      packager,
      contains("const _supportedBrowsers = <String>['chromium', 'firefox']"),
    );
    expect(packager, contains('<base href="/app/">'));
    expect(packager, contains("_join(destination.path, 'app')"));
    expect(packager, contains('pubspec.yaml'));
  });

  test('Browser extension readiness audit passes but stays pre-stable', () async {
    final result = await Process.run(
      Platform.resolvedExecutable,
      const ['run', 'tool/browser_extension_audit.dart', '--json'],
      workingDirectory: Directory.current.path,
    );

    expect(result.exitCode, 0, reason: '${result.stdout}\n${result.stderr}');
    expect(result.stdout, contains('"browserExtensionReady": true'));
    expect(result.stdout, contains('"stableSupportDeclared": false'));
  });
}
