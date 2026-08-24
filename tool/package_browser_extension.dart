import 'dart:convert';
import 'dart:io';

const _supportedBrowsers = <String>['chromium', 'firefox'];

void main(List<String> args) {
  final helpMode = args.contains('--help') || args.contains('-h');
  final jsonMode = args.contains('--json');
  final browserArg = _singleValue(args, '--browser=', defaultValue: 'all');
  final buildDirArg = _singleValue(
    args,
    '--build-dir=',
    defaultValue: 'build/web',
  );
  final outputDirArg = _singleValue(
    args,
    '--output-dir=',
    defaultValue: 'build/browser-extension',
  );

  final known = args.where(
    (arg) =>
        arg == '--help' ||
        arg == '-h' ||
        arg == '--json' ||
        arg.startsWith('--browser=') ||
        arg.startsWith('--build-dir=') ||
        arg.startsWith('--output-dir='),
  );
  final unknown = args.where((arg) => !known.contains(arg)).toList();

  if (helpMode) {
    stdout.writeln('2048 Nova browser-extension packager');
    stdout.writeln();
    stdout.writeln(
      'Usage: dart run tool/package_browser_extension.dart [options]',
    );
    stdout.writeln();
    stdout.writeln(
      '  --browser=all|chromium|firefox  Package one or both manifests.',
    );
    stdout.writeln(
      '  --build-dir=<path>              Flutter web release directory.',
    );
    stdout.writeln(
      '  --output-dir=<path>             Generated extension directory.',
    );
    stdout.writeln('  --json                          Emit JSON summary.');
    stdout.writeln('  --help                          Show this help text.');
    return;
  }

  if (unknown.isNotEmpty) {
    _fail('Unknown argument(s): ${unknown.join(', ')}');
  }

  final browsers = browserArg == 'all'
      ? _supportedBrowsers
      : <String>[browserArg];
  for (final browser in browsers) {
    if (!_supportedBrowsers.contains(browser)) {
      _fail('Unsupported browser: $browser');
    }
  }

  final root = Directory.current.absolute;
  final buildDir = Directory(buildDirArg).absolute;
  final outputRoot = Directory(outputDirArg).absolute;

  _validateFlutterWebBuild(buildDir);
  final version = _readMarketingVersion(root);

  if (outputRoot.existsSync()) {
    outputRoot.deleteSync(recursive: true);
  }
  outputRoot.createSync(recursive: true);

  final generated = <String>[];
  for (final browser in browsers) {
    final destination = Directory(_join(outputRoot.path, browser));
    _packageBrowser(
      root: root,
      webBuild: buildDir,
      destination: destination,
      browser: browser,
      version: version,
    );
    generated.add(destination.path);
  }

  final summary = <String, Object>{
    'version': version,
    'browsers': browsers,
    'outputDirectories': generated,
  };

  if (jsonMode) {
    stdout.writeln(const JsonEncoder.withIndent('  ').convert(summary));
  } else {
    stdout.writeln('2048 Nova browser-extension packages prepared.');
    stdout.writeln('Version: $version');
    for (final path in generated) {
      stdout.writeln('- $path');
    }
  }
}

String _singleValue(
  List<String> args,
  String prefix, {
  required String defaultValue,
}) {
  final matches = args.where((arg) => arg.startsWith(prefix)).toList();
  if (matches.length > 1) {
    _fail('Only one ${prefix.substring(0, prefix.length - 1)} value is allowed.');
  }
  if (matches.isEmpty) {
    return defaultValue;
  }
  final value = matches.single.substring(prefix.length).trim();
  if (value.isEmpty) {
    _fail('${prefix.substring(0, prefix.length - 1)} cannot be empty.');
  }
  return value;
}

void _validateFlutterWebBuild(Directory buildDir) {
  if (!buildDir.existsSync()) {
    _fail(
      'Flutter web build does not exist: ${buildDir.path}. '
      'Run `flutter build web --release --base-href /app/` first.',
    );
  }

  for (final relativePath in <String>[
    'index.html',
    'flutter_bootstrap.js',
    'manifest.json',
    'icons/Icon-192.png',
    'icons/Icon-512.png',
  ]) {
    final file = File(_join(buildDir.path, relativePath));
    if (!file.existsSync() || file.lengthSync() == 0) {
      _fail('Flutter web build is missing required file: $relativePath');
    }
  }

  final index = File(_join(buildDir.path, 'index.html')).readAsStringSync();
  if (!index.contains('<base href="/app/">')) {
    _fail(
      'Flutter web build must use `/app/` as its base href. '
      'Rebuild with `flutter build web --release --base-href /app/`.',
    );
  }
}

String _readMarketingVersion(Directory root) {
  final pubspec = File(_join(root.path, 'pubspec.yaml'));
  if (!pubspec.existsSync()) {
    _fail('pubspec.yaml is missing from ${root.path}.');
  }

  final match = RegExp(
    r'^version:\s*([0-9]+\.[0-9]+\.[0-9]+)(?:\+[0-9]+)?\s*$',
    multiLine: true,
  ).firstMatch(pubspec.readAsStringSync());
  if (match == null) {
    _fail('pubspec.yaml must contain a semantic marketing version.');
  }
  return match!.group(1)!;
}

void _packageBrowser({
  required Directory root,
  required Directory webBuild,
  required Directory destination,
  required String browser,
  required String version,
}) {
  destination.createSync(recursive: true);

  final appDestination = Directory(_join(destination.path, 'app'));
  _copyDirectory(webBuild, appDestination);

  for (final fileName in <String>['popup.html', 'popup.css']) {
    File(_join(root.path, 'extension/$fileName')).copySync(
      _join(destination.path, fileName),
    );
  }

  final template = File(
    _join(root.path, 'extension/manifest.$browser.template.json'),
  );
  if (!template.existsSync()) {
    _fail('Missing $browser extension manifest template: ${template.path}');
  }

  final rendered = template.readAsStringSync().replaceAll(
    '__VERSION__',
    version,
  );
  Object decoded;
  try {
    decoded = jsonDecode(rendered);
  } on FormatException catch (error) {
    _fail('Rendered $browser manifest is invalid JSON: ${error.message}');
  }

  File(_join(destination.path, 'manifest.json')).writeAsStringSync(
    '${const JsonEncoder.withIndent('  ').convert(decoded)}\n',
  );
}

void _copyDirectory(Directory source, Directory destination) {
  destination.createSync(recursive: true);
  for (final entity in source.listSync(followLinks: false)) {
    final segments = entity.uri.pathSegments.where((segment) => segment.isNotEmpty);
    final name = segments.isEmpty ? '' : segments.last;
    if (name.isEmpty) {
      _fail('Could not determine path name for ${entity.path}.');
    }
    final target = _join(destination.path, name);
    if (entity is File) {
      entity.copySync(target);
    } else if (entity is Directory) {
      _copyDirectory(entity, Directory(target));
    } else {
      _fail('Extension packaging does not follow links: ${entity.path}');
    }
  }
}

String _join(String parent, String child) {
  final normalizedChild = child.replaceAll('/', Platform.pathSeparator);
  return '$parent${Platform.pathSeparator}$normalizedChild';
}

Never _fail(String message) {
  stderr.writeln(message);
  exit(64);
}
