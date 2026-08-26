import 'dart:convert';
import 'dart:io';

const _packageVersion = '2.0.12+2012';
const _marketingVersion = '2.0.12';

const _requiredFiles = <String>[
  'README.md',
  'ROADMAP.md',
  'CHANGELOG.md',
  'CHANGELOG_ARCHIVE_PRE_2_0_12.md',
  'SECURITY.md',
  'what_changed.md',
  'pubspec.yaml',
  'docs/README.md',
  'docs/FINAL_2_0_12_SOURCE_AUDIT.md',
  'docs/MAINTENANCE_POLICY.md',
  'docs/PHASE_32_VERSION_2_0_12.md',
  'docs/RELEASE_CHECKLIST.md',
  'docs/RELEASE_QUALIFICATION.md',
  'docs/SOURCE_COMPLETION_AUDIT.md',
  'docs/release_qualification.json',
  'test/source_completion_audit_cli_test.dart',
  'tool/README.md',
  'tool/source_completion_audit.dart',
  '.github/workflows/ci.yml',
];

const _currentDocumentationFiles = <String>[
  'README.md',
  'ROADMAP.md',
  'SECURITY.md',
  'docs/README.md',
  'docs/DEPENDENCIES.md',
  'docs/RELEASE_CHECKLIST.md',
  'docs/RELEASE_QUALIFICATION.md',
  'docs/FINAL_2_0_12_SOURCE_AUDIT.md',
  'docs/MAINTENANCE_POLICY.md',
];

const _maintainedDartDirectories = <String>['lib', 'test', 'tool'];

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
    stdout.writeln('2048 Nova source-completion audit');
    stdout.writeln();
    stdout.writeln(
      'Usage: dart run tool/source_completion_audit.dart [options]',
    );
    stdout.writeln();
    stdout.writeln('  --json         Emit machine-readable JSON.');
    stdout.writeln(
      '  --root=<path>  Audit another repository root (used by regression fixtures).',
    );
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
    _auditReleaseIdentity(root, failures);
    _auditCompletionDocuments(root, failures);
    _auditCurrentDocumentation(root, failures);
    _auditCompletionWiring(root, failures);
    _auditMaintainedDartMarkers(root, failures);
  }

  final result = <String, Object?>{
    'root': root.path,
    'packageVersion': _packageVersion,
    'marketingVersion': _marketingVersion,
    'featureComplete': failures.isEmpty,
    'failures': failures,
  };

  if (jsonMode) {
    stdout.writeln(const JsonEncoder.withIndent('  ').convert(result));
  } else {
    stdout.writeln('2048 Nova source-completion audit');
    stdout.writeln('Root: ${root.path}');
    stdout.writeln('Package target: $_packageVersion');
    stdout.writeln('Marketing target: $_marketingVersion');
    stdout.writeln('Feature complete: ${failures.isEmpty ? 'yes' : 'no'}');
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
      failures.add('Required source-completion file is missing: $path');
      continue;
    }
    if (file.lengthSync() == 0) {
      failures.add('Required source-completion file is empty: $path');
    }
  }
}

void _auditReleaseIdentity(Directory root, List<String> failures) {
  final pubspec = _read(root, 'pubspec.yaml', failures);
  final qualification = _read(
    root,
    'docs/release_qualification.json',
    failures,
  );
  if (pubspec == null || qualification == null) {
    return;
  }

  if (!RegExp(
    '^version:\\s*${RegExp.escape(_packageVersion)}\\s*\$',
    multiLine: true,
  ).hasMatch(pubspec)) {
    failures.add('pubspec.yaml must target $_packageVersion.');
  }

  try {
    final decoded = jsonDecode(qualification);
    if (decoded is! Map<String, dynamic>) {
      failures.add(
        'docs/release_qualification.json must contain a JSON object.',
      );
      return;
    }
    if (decoded['candidate'] != _packageVersion) {
      failures.add(
        'Release qualification candidate must remain $_packageVersion.',
      );
    }
    final checks = decoded['manualChecks'];
    if (checks is! List || checks.length != 13) {
      failures.add(
        'Release qualification must retain exactly 13 manual checks.',
      );
    }
  } on FormatException catch (error) {
    failures.add('Invalid release qualification JSON: ${error.message}');
  }
}

void _auditCompletionDocuments(Directory root, List<String> failures) {
  final roadmap = _read(root, 'ROADMAP.md', failures);
  final finalAudit = _read(root, 'docs/FINAL_2_0_12_SOURCE_AUDIT.md', failures);
  final maintenance = _read(root, 'docs/MAINTENANCE_POLICY.md', failures);
  final docsIndex = _read(root, 'docs/README.md', failures);

  if (roadmap != null) {
    const requiredRoadmapFragments = <String>[
      '## 2.0.12 — Feature-complete source target',
      'Remaining release qualification before `2.0.12`',
      '## No active post-2.0.12 feature backlog',
      'A proposal for any non-goal starts a **new release scope**.',
    ];
    for (final fragment in requiredRoadmapFragments) {
      if (!roadmap.contains(fragment)) {
        failures.add('ROADMAP.md is missing completion contract: $fragment');
      }
    }
    if (roadmap.contains('## Later — Optional expansion')) {
      failures.add(
        'ROADMAP.md must not restore an active optional-feature backlog for Version 2.0.12.',
      );
    }
  }

  if (finalAudit != null &&
      !finalAudit.contains(
        '2048 Nova 2.0.12 is feature-complete within its declared offline-first',
      )) {
    failures.add(
      'Final Version 2.0.12 source audit must retain the explicit feature-complete verdict.',
    );
  }

  if (maintenance != null &&
      !maintenance.contains('## No active feature backlog')) {
    failures.add(
      'Maintenance policy must retain the no-active-feature-backlog boundary.',
    );
  }

  if (docsIndex != null) {
    for (final path in <String>[
      'FINAL_2_0_12_SOURCE_AUDIT.md',
      'MAINTENANCE_POLICY.md',
      'SOURCE_COMPLETION_AUDIT.md',
    ]) {
      if (!docsIndex.contains(path)) {
        failures.add('docs/README.md must index $path.');
      }
    }
  }
}

void _auditCurrentDocumentation(Directory root, List<String> failures) {
  for (final path in _currentDocumentationFiles) {
    final text = _read(root, path, failures);
    if (text == null) {
      continue;
    }

    if (text.contains('1.5.0+15')) {
      failures.add(
        '$path contains obsolete 1.5.0+15 current-release metadata.',
      );
    }

    final staleCurrentLine = RegExp(
      r'(?:currently maintained on the[^\n]{0,80}Version 1\.5|current release(?: line)?\s*(?:is|:)[^\n]{0,80}Version 1\.5|maintained package line\s*(?:is|:)[^\n]{0,80}Version 1\.5)',
      caseSensitive: false,
    );
    if (staleCurrentLine.hasMatch(text)) {
      failures.add('$path describes Version 1.5 as the current release line.');
    }
  }
}

void _auditCompletionWiring(Directory root, List<String> failures) {
  final ci = _read(root, '.github/workflows/ci.yml', failures);
  final toolReadme = _read(root, 'tool/README.md', failures);
  final docs = _read(root, 'docs/SOURCE_COMPLETION_AUDIT.md', failures);

  const command = 'dart run tool/source_completion_audit.dart --json';
  if (ci != null && !ci.contains(command)) {
    failures.add('Permanent CI must run the source-completion audit.');
  }
  if (toolReadme != null &&
      !toolReadme.contains('source_completion_audit.dart')) {
    failures.add('tool/README.md must index the source-completion audit.');
  }
  if (docs != null &&
      !docs.contains('test/source_completion_audit_cli_test.dart')) {
    failures.add(
      'Source-completion documentation must identify its process-level regression suite.',
    );
  }
}

void _auditMaintainedDartMarkers(Directory root, List<String> failures) {
  final unresolvedComment = RegExp(
    r'^\s*//\s*(?:TODO|FIXME)\b',
    multiLine: true,
    caseSensitive: false,
  );

  for (final directoryName in _maintainedDartDirectories) {
    final directory = Directory.fromUri(root.uri.resolve('$directoryName/'));
    if (!directory.existsSync()) {
      failures.add('Maintained Dart directory is missing: $directoryName/');
      continue;
    }

    for (final entity in directory.listSync(
      recursive: true,
      followLinks: false,
    )) {
      if (entity is! File || !entity.path.endsWith('.dart')) {
        continue;
      }
      final text = entity.readAsStringSync();
      if (unresolvedComment.hasMatch(text)) {
        failures.add(
          'Maintained Dart source contains unresolved TODO/FIXME comment: ${_relative(root, entity)}',
        );
      }
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

String _relative(Directory root, File file) {
  final rootPath = root.path.endsWith(Platform.pathSeparator)
      ? root.path
      : '${root.path}${Platform.pathSeparator}';
  if (!file.path.startsWith(rootPath)) {
    return file.path;
  }
  return file.path.substring(rootPath.length).replaceAll('\\', '/');
}
