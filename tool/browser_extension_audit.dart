import 'dart:convert';
import 'dart:io';

const _requiredFiles = <String>[
  'extension/manifest.chromium.template.json',
  'extension/manifest.firefox.template.json',
  'extension/popup.html',
  'extension/popup.css',
  'extension/README.md',
  'tool/package_browser_extension.dart',
  '.github/workflows/browser-extension.yml',
  'docs/BROWSER_EXTENSION.md',
  'test/browser_extension_contract_test.dart',
];

void main(List<String> args) {
  final jsonMode = args.contains('--json');
  final helpMode = args.contains('--help') || args.contains('-h');
  final rootArgs = args.where((arg) => arg.startsWith('--root=')).toList();
  final unknownArgs = args
      .where(
        (arg) =>
            arg != '--json' &&
            arg != '--help' &&
            arg != '-h' &&
            !arg.startsWith('--root='),
      )
      .toList(growable: false);

  if (helpMode) {
    stdout.writeln('2048 Nova browser-extension readiness audit');
    stdout.writeln();
    stdout.writeln(
      'Usage: dart run tool/browser_extension_audit.dart [options]',
    );
    stdout.writeln();
    stdout.writeln('  --json         Emit machine-readable JSON.');
    stdout.writeln('  --root=<path>  Audit another repository root.');
    stdout.writeln('  --help         Show this help text.');
    return;
  }

  final failures = <String>[];
  if (unknownArgs.isNotEmpty) {
    failures.add('Unknown argument(s): ${unknownArgs.join(', ')}');
  }
  if (rootArgs.length > 1) {
    failures.add('Only one --root=<path> argument may be provided.');
  }

  final configuredRoot = rootArgs.isEmpty
      ? Directory.current.path
      : rootArgs.first.substring('--root='.length).trim();
  final root = Directory(
    configuredRoot.isEmpty ? Directory.current.path : configuredRoot,
  ).absolute;

  if (!root.existsSync()) {
    failures.add('Repository root does not exist: ${root.path}');
  } else {
    _auditRequiredFiles(root, failures);
    _auditManifests(root, failures);
    _auditPopup(root, failures);
    _auditPackager(root, failures);
    _auditWorkflow(root, failures);
    _auditDocumentation(root, failures);
  }

  final result = <String, Object?>{
    'root': root.path,
    'status': failures.isEmpty ? 'prepared' : 'incomplete',
    'stableSupportDeclared': false,
    'browserExtensionReady': failures.isEmpty,
    'failures': failures,
  };

  if (jsonMode) {
    stdout.writeln(const JsonEncoder.withIndent('  ').convert(result));
  } else {
    stdout.writeln('2048 Nova browser-extension readiness audit');
    stdout.writeln('Root: ${root.path}');
    stdout.writeln(
      'Extension preparation readiness: ${failures.isEmpty ? 'yes' : 'no'}',
    );
    stdout.writeln('Stable support declared: no');
    if (failures.isNotEmpty) {
      stdout.writeln();
      stdout.writeln('Failures:');
      for (final failure in failures) {
        stdout.writeln('- $failure');
      }
    }
  }

  if (failures.isNotEmpty) {
    exitCode = 1;
  }
}

void _auditRequiredFiles(Directory root, List<String> failures) {
  for (final path in _requiredFiles) {
    final file = File.fromUri(root.uri.resolve(path));
    if (!file.existsSync()) {
      failures.add('Required extension preparation file is missing: $path');
      continue;
    }
    if (file.lengthSync() == 0) {
      failures.add('Required extension preparation file is empty: $path');
    }
  }
}

void _auditManifests(Directory root, List<String> failures) {
  final chromium = _readManifest(
    root,
    'extension/manifest.chromium.template.json',
    failures,
  );
  final firefox = _readManifest(
    root,
    'extension/manifest.firefox.template.json',
    failures,
  );

  if (chromium != null) {
    _auditCommonManifest('Chromium', chromium, failures);
    if (chromium.containsKey('browser_specific_settings')) {
      failures.add(
        'Chromium manifest must not contain Firefox browser_specific_settings.',
      );
    }
  }

  if (firefox != null) {
    _auditCommonManifest('Firefox', firefox, failures);
    final settings = firefox['browser_specific_settings'];
    if (settings is! Map<String, dynamic>) {
      failures.add('Firefox manifest is missing browser_specific_settings.');
      return;
    }
    final gecko = settings['gecko'];
    if (gecko is! Map<String, dynamic>) {
      failures.add('Firefox manifest is missing Gecko settings.');
      return;
    }
    if (gecko['id'] != 'nova-2048@sanskarin') {
      failures.add('Firefox manifest must keep the stable Gecko extension ID.');
    }
    final collection = gecko['data_collection_permissions'];
    if (collection is! Map<String, dynamic> ||
        !_listEquals(collection['required'], const <String>['none'])) {
      failures.add(
        'Firefox manifest must explicitly declare required data collection as none.',
      );
    }
    if (settings['gecko_android'] is! Map<String, dynamic>) {
      failures.add('Firefox manifest must retain Gecko Android preparation.');
    }
  }
}

void _auditCommonManifest(
  String browser,
  Map<String, dynamic> manifest,
  List<String> failures,
) {
  if (manifest['manifest_version'] != 3) {
    failures.add('$browser extension manifest must use Manifest V3.');
  }
  if (manifest['version'] != '9.9.9') {
    failures.add('$browser extension manifest must derive version from template.');
  }
  if (manifest.containsKey('permissions')) {
    failures.add('$browser extension must remain permission-free.');
  }
  if (manifest.containsKey('host_permissions')) {
    failures.add('$browser extension must not request host permissions.');
  }

  final action = manifest['action'];
  if (action is! Map<String, dynamic> ||
      action['default_popup'] != 'popup.html') {
    failures.add('$browser extension must open popup.html from its action.');
  }

  final csp = manifest['content_security_policy'];
  final extensionPages = csp is Map<String, dynamic>
      ? csp['extension_pages']
      : null;
  if (extensionPages is! String ||
      !extensionPages.contains("script-src 'self' 'wasm-unsafe-eval'") ||
      !extensionPages.contains("object-src 'self'")) {
    failures.add(
      '$browser extension CSP must allow only packaged scripts plus WebAssembly.',
    );
  }
}

Map<String, dynamic>? _readManifest(
  Directory root,
  String path,
  List<String> failures,
) {
  final file = File.fromUri(root.uri.resolve(path));
  if (!file.existsSync()) {
    return null;
  }
  try {
    final rendered = file.readAsStringSync().replaceAll('__VERSION__', '9.9.9');
    final decoded = jsonDecode(rendered);
    if (decoded is! Map<String, dynamic>) {
      failures.add('Extension manifest is not a JSON object: $path');
      return null;
    }
    return decoded;
  } on FormatException catch (error) {
    failures.add('Invalid JSON in $path: ${error.message}');
    return null;
  }
}

void _auditPopup(Directory root, List<String> failures) {
  final popup = _read(root, 'extension/popup.html', failures);
  final css = _read(root, 'extension/popup.css', failures);
  if (popup != null) {
    if (!popup.contains('src="app/index.html"')) {
      failures.add('Extension popup must host the packaged Flutter app.');
    }
    if (popup.contains('<script')) {
      failures.add('Extension popup shell must not contain inline/local scripts.');
    }
  }
  if (css != null &&
      (!css.contains('width: 420px') || !css.contains('height: 600px'))) {
    failures.add('Extension popup must keep the qualified desktop popup size.');
  }
}

void _auditPackager(Directory root, List<String> failures) {
  final packager = _read(root, 'tool/package_browser_extension.dart', failures);
  if (packager == null) {
    return;
  }

  for (final fragment in <String>[
    "const _supportedBrowsers = <String>['chromium', 'firefox']",
    '<base href="/app/">',
    'extension/manifest.\$browser.template.json',
    "_join(destination.path, 'app')",
    'pubspec.yaml',
  ]) {
    if (!packager.contains(fragment)) {
      failures.add('Browser-extension packager is missing contract: $fragment');
    }
  }
}

void _auditWorkflow(Directory root, List<String> failures) {
  final workflow = _read(
    root,
    '.github/workflows/browser-extension.yml',
    failures,
  );
  if (workflow == null) {
    return;
  }

  for (final fragment in <String>[
    'flutter build web --release --base-href /app/',
    'dart run tool/browser_extension_audit.dart --json',
    'dart run tool/package_browser_extension.dart --browser=all --json',
    'nova-2048-extension-chromium.zip',
    'nova-2048-extension-firefox.zip',
    'sha256sum',
  ]) {
    if (!workflow.contains(fragment)) {
      failures.add('Browser-extension CI is missing: $fragment');
    }
  }
}

void _auditDocumentation(Directory root, List<String> failures) {
  final docs = _read(root, 'docs/BROWSER_EXTENSION.md', failures);
  if (docs == null) {
    return;
  }

  for (final fragment in <String>[
    'Manifest V3',
    'Chrome',
    'Edge',
    'Firefox',
    '--base-href /app/',
    'Prepared, automated, not yet declared stable',
  ]) {
    if (!docs.contains(fragment)) {
      failures.add('Browser-extension documentation is missing: $fragment');
    }
  }
}

String? _read(Directory root, String path, List<String> failures) {
  final file = File.fromUri(root.uri.resolve(path));
  if (!file.existsSync()) {
    return null;
  }
  try {
    return file.readAsStringSync();
  } on FileSystemException catch (error) {
    failures.add('Could not read $path: ${error.message}');
    return null;
  }
}

bool _listEquals(Object? value, List<String> expected) {
  if (value is! List || value.length != expected.length) {
    return false;
  }
  for (var index = 0; index < expected.length; index += 1) {
    if (value[index] != expected[index]) {
      return false;
    }
  }
  return true;
}
