import 'dart:convert';
import 'dart:io';

const _canonicalPackageVersion = '2.0.12+2012';
const _canonicalMarketingVersion = '2.0.12';

const _requiredPaths = <String>[
  '.editorconfig',
  '.gitattributes',
  '.gitignore',
  'README.md',
  'CHANGELOG.md',
  'ROADMAP.md',
  'SECURITY.md',
  'SUPPORT.md',
  'CONTRIBUTING.md',
  'CODE_OF_CONDUCT.md',
  'LICENSE',
  'AUTHORS.md',
  'what_changed.md',
  'what_changed_archive_phase_00_30.md',
  'what_changed_archive_phase_31.md',
  'pubspec.yaml',
  'analysis_options.yaml',
  'android/key.properties.example',
  'windows/runner/Runner.rc',
  'docs/README.md',
  'docs/PWA.md',
  'docs/REPOSITORY_AUDIT.md',
  'docs/RELEASE_QUALIFICATION.md',
  'docs/QUALIFICATION_RECORDER.md',
  'docs/QUALIFICATION_STATUS.md',
  'docs/PHASE_31_VERIFICATION.md',
  'docs/PHASE_32_VERSION_2_0_12.md',
  'docs/RELEASE_CHECKLIST.md',
  'docs/BUILDING_EXECUTABLES.md',
  'docs/release_qualification.json',
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

const _forbiddenTemporaryPaths = <String>[
  '.github/workflows/phase30-continuity.yml',
  '.github/workflows/phase30-finalize.yml',
  '.github/workflows/phase31-finalize.yml',
  '.github/workflows/phase32-finalize.yml',
  'docs/PHASE_30_INDEX_TRIGGER.md',
  'docs/PHASE_31_TRIGGER.md',
  'docs/PHASE_31_STATUS_TRIGGER.md',
  'docs/PHASE_32_TRIGGER.md',
  'tool/phase31_finalize.py',
  'tool/phase32_finalize.py',
];

const _canonicalPubspecMetadata = <String, String>{
  'homepage': 'https://github.com/sanskarIN/2048',
  'repository': 'https://github.com/sanskarIN/2048',
  'issue_tracker': 'https://github.com/sanskarIN/2048/issues',
};

const _canonicalWebManifestMetadata = <String, Object>{
  'name': '2048 Nova',
  'short_name': '2048 Nova',
  'id': '.',
  'start_url': '.',
  'scope': '.',
  'display': 'standalone',
  'lang': 'en',
  'dir': 'ltr',
  'orientation': 'any',
  'prefer_related_applications': false,
};

const _canonicalWebIconSignatures = <String>{
  'icons/Icon-192.png|192x192|any',
  'icons/Icon-512.png|512x512|any',
  'icons/Icon-maskable-192.png|192x192|maskable',
  'icons/Icon-maskable-512.png|512x512|maskable',
};

void main(List<String> args) {
  final jsonMode = args.contains('--json');
  final helpMode = args.contains('--help') || args.contains('-h');
  final rootValues = args
      .where((arg) => arg.startsWith('--root='))
      .map((arg) => arg.substring('--root='.length))
      .toList(growable: false);
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
    stdout.writeln('2048 Nova repository integrity audit');
    stdout.writeln();
    stdout.writeln('Usage: dart run tool/repository_audit.dart [options]');
    stdout.writeln();
    stdout.writeln('  --json         Emit machine-readable JSON.');
    stdout.writeln(
      '  --root=<path>  Audit another repository root (used by regression fixtures).',
    );
    stdout.writeln('  --help         Show this help text.');
    return;
  }

  final failures = <String>[];
  final warnings = <String>[];

  if (unknownArgs.isNotEmpty) {
    failures.add('Unknown argument(s): ${unknownArgs.join(', ')}');
  }
  if (rootValues.length > 1) {
    failures.add('Only one --root=<path> argument may be provided.');
  }

  final configuredRoot = rootValues.isEmpty ? null : rootValues.single.trim();
  final root = Directory(
    configuredRoot == null || configuredRoot.isEmpty
        ? Directory.current.path
        : configuredRoot,
  ).absolute;

  if (!root.existsSync()) {
    failures.add('Repository root does not exist: ${root.path}');
  } else {
    _auditRequiredPaths(root, failures);
    _auditTemporaryPaths(root, failures);
    _auditReleaseState(root, failures);
    _auditWebMetadata(root, failures);
    _auditMarkdownLinks(root, failures, warnings);
  }

  final result = <String, Object?>{
    'root': root.path,
    'packageVersion': _canonicalPackageVersion,
    'marketingVersion': _canonicalMarketingVersion,
    'passed': failures.isEmpty,
    'failures': failures,
    'warnings': warnings,
  };

  if (jsonMode) {
    stdout.writeln(const JsonEncoder.withIndent('  ').convert(result));
  } else {
    stdout.writeln('2048 Nova repository audit');
    stdout.writeln('Root: ${root.path}');
    stdout.writeln('Package target: $_canonicalPackageVersion');
    stdout.writeln('Marketing target: $_canonicalMarketingVersion');
    stdout.writeln('Result: ${failures.isEmpty ? 'PASS' : 'FAIL'}');
    if (warnings.isNotEmpty) {
      stdout.writeln();
      stdout.writeln('Warnings:');
      for (final warning in warnings) {
        stdout.writeln('- $warning');
      }
    }
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

void _auditRequiredPaths(Directory root, List<String> failures) {
  for (final relativePath in _requiredPaths) {
    final entity = _entityAt(root, relativePath);
    final type = FileSystemEntity.typeSync(entity.path, followLinks: false);
    if (type == FileSystemEntityType.notFound) {
      failures.add('Required repository path is missing: $relativePath');
      continue;
    }
    if (entity is File && entity.lengthSync() == 0) {
      failures.add('Required repository file is empty: $relativePath');
    }
  }
}

void _auditTemporaryPaths(Directory root, List<String> failures) {
  for (final relativePath in _forbiddenTemporaryPaths) {
    if (_entityAt(root, relativePath).existsSync()) {
      failures.add('Temporary repository path must not remain: $relativePath');
    }
  }
}

void _auditReleaseState(Directory root, List<String> failures) {
  final pubspec = _readText(root, 'pubspec.yaml', failures);
  final projectInfo = _readText(
    root,
    'lib/core/constants/project_info.dart',
    failures,
  );
  final windowsResources = _readText(
    root,
    'windows/runner/Runner.rc',
    failures,
  );
  final manifestText = _readText(
    root,
    'docs/release_qualification.json',
    failures,
  );
  final continuity = _readText(root, 'what_changed.md', failures);

  if (pubspec == null ||
      projectInfo == null ||
      windowsResources == null ||
      manifestText == null ||
      continuity == null) {
    return;
  }

  final versionMatch = RegExp(
    r'^version:\s*(\S+)\s*$',
    multiLine: true,
  ).firstMatch(pubspec);
  if (versionMatch == null) {
    failures.add('pubspec.yaml does not contain a parseable version field.');
    return;
  }
  final packageVersion = versionMatch.group(1)!;
  final baseVersion = packageVersion.split('+').first;

  if (packageVersion != _canonicalPackageVersion) {
    failures.add(
      'pubspec version must be $_canonicalPackageVersion for Phase 32; found $packageVersion.',
    );
  }

  for (final metadata in _canonicalPubspecMetadata.entries) {
    final match = RegExp(
      '^${RegExp.escape(metadata.key)}:\\s*(\\S+)\\s*\$',
      multiLine: true,
    ).firstMatch(pubspec);
    final actual = match?.group(1);
    if (actual != metadata.value) {
      failures.add(
        'pubspec ${metadata.key} must be ${metadata.value}; found ${actual ?? 'missing'}.',
      );
    }
  }

  final projectVersionMatch = RegExp(
    r"static const version = '([^']+)';",
  ).firstMatch(projectInfo);
  if (projectVersionMatch == null) {
    failures.add('ProjectInfo.version could not be parsed.');
  } else if (projectVersionMatch.group(1) != baseVersion ||
      projectVersionMatch.group(1) != _canonicalMarketingVersion) {
    failures.add(
      'ProjectInfo.version (${projectVersionMatch.group(1)}) must match marketing version $_canonicalMarketingVersion.',
    );
  }

  if (!windowsResources.contains('#define VERSION_AS_NUMBER 2,0,12,2012')) {
    failures.add('Windows fallback VERSION_AS_NUMBER must be 2,0,12,2012.');
  }
  if (!windowsResources.contains('#define VERSION_AS_STRING "2.0.12"')) {
    failures.add('Windows fallback VERSION_AS_STRING must be "2.0.12".');
  }

  try {
    final decoded = jsonDecode(manifestText);
    if (decoded is! Map<String, dynamic>) {
      failures.add(
        'docs/release_qualification.json must contain a JSON object.',
      );
    } else {
      final candidate = decoded['candidate'];
      if (candidate != packageVersion) {
        failures.add(
          'Release qualification candidate ($candidate) must match pubspec version ($packageVersion).',
        );
      }
      final checks = decoded['manualChecks'];
      if (checks is! List || checks.length != 13) {
        failures.add(
          'Release qualification manifest must contain exactly 13 manual checks.',
        );
      }
    }
  } on FormatException catch (error) {
    failures.add(
      'docs/release_qualification.json is invalid JSON: ${error.message}',
    );
  }

  if (!continuity.contains('**Current phase:** Phase 32')) {
    failures.add(
      'what_changed.md must identify Phase 32 as the current phase.',
    );
  }
  if (!continuity.contains('`2.0.12+2012`')) {
    failures.add(
      'what_changed.md must identify the current 2.0.12+2012 package candidate.',
    );
  }
  if (!continuity.contains('stable qualification boundary remains 0/13')) {
    failures.add(
      'what_changed.md must preserve the current 0/13 manual qualification boundary.',
    );
  }
}

void _auditWebMetadata(Directory root, List<String> failures) {
  final manifestText = _readText(root, 'web/manifest.json', failures);
  final indexHtml = _readText(root, 'web/index.html', failures);
  if (manifestText == null || indexHtml == null) {
    return;
  }

  try {
    final decoded = jsonDecode(manifestText);
    if (decoded is! Map<String, dynamic>) {
      failures.add('web/manifest.json must contain a JSON object.');
    } else {
      for (final expected in _canonicalWebManifestMetadata.entries) {
        final actual = decoded[expected.key];
        if (actual != expected.value) {
          failures.add(
            'web/manifest.json ${expected.key} must be ${expected.value}; found ${actual ?? 'missing'}.',
          );
        }
      }

      final categories = decoded['categories'];
      if (categories is! List ||
          !categories.contains('games') ||
          !categories.contains('entertainment')) {
        failures.add(
          'web/manifest.json categories must include games and entertainment.',
        );
      }

      final icons = decoded['icons'];
      if (icons is! List) {
        failures.add('web/manifest.json icons must be an array.');
      } else {
        final signatures = <String>{};
        for (final icon in icons) {
          if (icon is! Map<String, dynamic>) {
            continue;
          }
          if (icon['type'] != 'image/png') {
            failures.add('Every web/manifest.json icon must use image/png.');
          }
          signatures.add('${icon['src']}|${icon['sizes']}|${icon['purpose']}');
        }
        if (icons.length != _canonicalWebIconSignatures.length ||
            !signatures.containsAll(_canonicalWebIconSignatures)) {
          failures.add(
            'web/manifest.json must contain the canonical regular/maskable 192/512 icon matrix.',
          );
        }
      }
    }
  } on FormatException catch (error) {
    failures.add('web/manifest.json is invalid JSON: ${error.message}');
  }

  const requiredIndexFragments = <String>[
    '<html lang="en">',
    '<base href="$FLUTTER_BASE_HREF">',
    '<meta name="theme-color" content="#6C4DFF">',
    '<meta name="color-scheme" content="light dark">',
    '<meta name="mobile-web-app-capable" content="yes">',
    '<meta name="apple-mobile-web-app-capable" content="yes">',
    '<meta name="apple-mobile-web-app-title" content="2048 Nova">',
    '<link rel="manifest" href="manifest.json">',
    '<link rel="apple-touch-icon" href="icons/Icon-192.png">',
    '<title>2048 Nova</title>',
    'flutter_bootstrap.js',
  ];
  for (final fragment in requiredIndexFragments) {
    if (!indexHtml.contains(fragment)) {
      failures.add('web/index.html is missing required metadata: $fragment');
    }
  }
}

void _auditMarkdownLinks(
  Directory root,
  List<String> failures,
  List<String> warnings,
) {
  final markdownFiles = <File>[];

  for (final entity in root.listSync(followLinks: false)) {
    if (entity is File && entity.path.toLowerCase().endsWith('.md')) {
      markdownFiles.add(entity);
    }
  }

  for (final directoryName in <String>['docs', '.github', 'tool']) {
    final directory = Directory.fromUri(root.uri.resolve('$directoryName/'));
    if (!directory.existsSync()) {
      continue;
    }
    for (final entity in directory.listSync(
      recursive: true,
      followLinks: false,
    )) {
      if (entity is File && entity.path.toLowerCase().endsWith('.md')) {
        markdownFiles.add(entity);
      }
    }
  }

  final seenFailures = <String>{};
  for (final file in markdownFiles) {
    final text = file.readAsStringSync();
    var inFence = false;
    final lines = const LineSplitter().convert(text);

    for (var index = 0; index < lines.length; index += 1) {
      final line = lines[index];
      final trimmed = line.trimLeft();
      if (trimmed.startsWith('```') || trimmed.startsWith('~~~')) {
        inFence = !inFence;
        continue;
      }
      if (inFence) {
        continue;
      }

      final destinations = <String>[];
      for (final match in RegExp(r'!?\[[^\]]*\]\(([^)]+)\)').allMatches(line)) {
        destinations.add(match.group(1)!);
      }
      final referenceMatch = RegExp(
        r'^\s*\[[^\]]+\]:\s*(\S+)',
      ).firstMatch(line);
      if (referenceMatch != null) {
        destinations.add(referenceMatch.group(1)!);
      }

      for (final rawDestination in destinations) {
        final destination = _normalizeMarkdownDestination(rawDestination);
        if (destination == null) {
          continue;
        }

        final target = FileSystemEntity.typeSync(
          File.fromUri(file.parent.uri.resolve(destination)).path,
          followLinks: false,
        );
        if (target == FileSystemEntityType.notFound) {
          final relativeFile = _relativePath(root, file);
          final failure =
              'Broken local Markdown link in $relativeFile:${index + 1}: $destination';
          if (seenFailures.add(failure)) {
            failures.add(failure);
          }
        }
      }
    }

    if (inFence) {
      warnings.add(
        '${_relativePath(root, file)} ends with an unclosed Markdown code fence.',
      );
    }
  }
}

String? _normalizeMarkdownDestination(String raw) {
  var destination = raw.trim();
  if (destination.startsWith('<') && destination.contains('>')) {
    destination = destination.substring(1, destination.indexOf('>'));
  } else {
    final whitespace = destination.indexOf(RegExp(r'\s'));
    if (whitespace >= 0) {
      destination = destination.substring(0, whitespace);
    }
  }

  if (destination.isEmpty || destination.startsWith('#')) {
    return null;
  }

  final lower = destination.toLowerCase();
  if (lower.startsWith('http://') ||
      lower.startsWith('https://') ||
      lower.startsWith('mailto:') ||
      lower.startsWith('tel:') ||
      lower.startsWith('data:')) {
    return null;
  }

  destination = destination.split('#').first.split('?').first;
  if (destination.isEmpty) {
    return null;
  }

  try {
    return Uri.decodeComponent(destination);
  } on FormatException {
    return destination;
  }
}

FileSystemEntity _entityAt(Directory root, String relativePath) {
  final type = FileSystemEntity.typeSync(
    File.fromUri(root.uri.resolve(relativePath)).path,
    followLinks: false,
  );
  return switch (type) {
    FileSystemEntityType.directory => Directory.fromUri(
      root.uri.resolve('$relativePath/'),
    ),
    _ => File.fromUri(root.uri.resolve(relativePath)),
  };
}

String? _readText(Directory root, String relativePath, List<String> failures) {
  final file = File.fromUri(root.uri.resolve(relativePath));
  if (!file.existsSync()) {
    failures.add('Required audit input is missing: $relativePath');
    return null;
  }
  try {
    return file.readAsStringSync();
  } on FileSystemException catch (error) {
    failures.add('Could not read $relativePath: ${error.message}');
    return null;
  }
}

String _relativePath(Directory root, File file) {
  final rootPath = root.path.endsWith(Platform.pathSeparator)
      ? root.path
      : '${root.path}${Platform.pathSeparator}';
  if (!file.path.startsWith(rootPath)) {
    return file.path;
  }
  return file.path.substring(rootPath.length).replaceAll('\\', '/');
}
