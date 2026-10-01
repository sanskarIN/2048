import 'dart:convert';
import 'dart:io';

const _workflowDirectory = '.github/workflows';
const _ciWorkflow = '.github/workflows/ci.yml';
const _auditCommand = 'dart run tool/workflow_security_audit.dart --json';
const _approvedWriterWorkflows = <String>{
  '.github/workflows/bootstrap-branding.yml',
  '.github/workflows/bootstrap-platforms.yml',
  '.github/workflows/format-code.yml',
  '.github/workflows/lock-dependencies.yml',
};

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
    stdout.writeln('2048 Nova GitHub Actions workflow security audit');
    stdout.writeln();
    stdout.writeln(
      'Usage: dart run tool/workflow_security_audit.dart [options]',
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

  final checkedWorkflows = <String>[];
  if (!root.existsSync()) {
    failures.add('Repository root does not exist: ${root.path}');
  } else {
    final workflows = _workflowFiles(root, failures);
    for (final workflow in workflows) {
      final relativePath = _relativePath(root, workflow);
      checkedWorkflows.add(relativePath);
      final source = _read(workflow, relativePath, failures);
      if (source == null) {
        continue;
      }

      _auditUnsafePatterns(relativePath, source, failures);
      _auditActionPins(relativePath, source, failures);
      final contentsPermission = _auditPermissions(
        relativePath,
        source,
        failures,
      );
      _auditJobTimeouts(relativePath, source, failures);
      _auditCheckoutCredentials(
        relativePath,
        source,
        contentsPermission,
        failures,
      );
      _auditWriterPolicy(relativePath, source, contentsPermission, failures);
    }

    for (final writer in _approvedWriterWorkflows) {
      if (!checkedWorkflows.contains(writer)) {
        failures.add(
          'Approved repository-writing workflow is missing: $writer',
        );
      }
    }
    _auditCiWiring(root, failures);
  }

  checkedWorkflows.sort();
  final result = <String, Object?>{
    'root': root.path,
    'workflowCount': checkedWorkflows.length,
    'checkedWorkflows': checkedWorkflows,
    'secure': failures.isEmpty,
    'failures': failures,
  };

  if (jsonMode) {
    stdout.writeln(const JsonEncoder.withIndent('  ').convert(result));
  } else {
    stdout.writeln('2048 Nova workflow security audit');
    stdout.writeln('Root: ${root.path}');
    stdout.writeln('Workflows checked: ${checkedWorkflows.length}');
    stdout.writeln('Result: ${failures.isEmpty ? 'PASS' : 'FAIL'}');
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

List<File> _workflowFiles(Directory root, List<String> failures) {
  final directory = Directory.fromUri(root.uri.resolve('$_workflowDirectory/'));
  if (!directory.existsSync()) {
    failures.add('Workflow directory is missing: $_workflowDirectory');
    return const <File>[];
  }

  final workflows = directory
      .listSync(followLinks: false)
      .whereType<File>()
      .where(
        (file) => file.path.endsWith('.yml') || file.path.endsWith('.yaml'),
      )
      .toList(growable: false);

  if (workflows.isEmpty) {
    failures.add(
      'No GitHub Actions workflows were found in $_workflowDirectory.',
    );
  }
  return workflows;
}

void _auditUnsafePatterns(String path, String source, List<String> failures) {
  if (source.contains('pull_request_target:')) {
    failures.add(
      '$path must not use the privileged pull_request_target trigger.',
    );
  }
  if (source.contains('write-all')) {
    failures.add('$path must not request blanket write-all permissions.');
  }
}

void _auditActionPins(String path, String source, List<String> failures) {
  final immutableUse = RegExp(
    r'^\s*(?:-\s*)?uses:\s*[^@\s]+@[0-9a-f]{40}(?:\s+#\s+.+)?\s*$',
  );
  for (final line in const LineSplitter().convert(source)) {
    if (!line.contains('uses:') || RegExp(r'uses:\s*\./').hasMatch(line)) {
      continue;
    }
    if (!immutableUse.hasMatch(line)) {
      failures.add(
        '$path has a mutable or unpinned Action reference: ${line.trim()}',
      );
    }
  }
}

String? _auditPermissions(String path, String source, List<String> failures) {
  if (!RegExp(r'^permissions:\s*$', multiLine: true).hasMatch(source)) {
    failures.add('$path must declare top-level permissions explicitly.');
    return null;
  }

  final contentsMatch = RegExp(
    r'^  contents:\s*(read|write)\s*$',
    multiLine: true,
  ).firstMatch(source);
  if (contentsMatch == null) {
    failures.add(
      '$path must declare top-level contents: read or contents: write.',
    );
    return null;
  }
  return contentsMatch.group(1);
}

void _auditJobTimeouts(String path, String source, List<String> failures) {
  final lines = const LineSplitter().convert(source);
  final jobsIndex = lines.indexWhere((line) => line.trimRight() == 'jobs:');
  if (jobsIndex < 0) {
    failures.add('$path does not declare a jobs section.');
    return;
  }

  final jobPattern = RegExp(r'^  ([A-Za-z0-9_-]+):\s*$');
  final timeoutPattern = RegExp(r'^    timeout-minutes:\s*[1-9][0-9]*\s*$');
  String? currentJob;
  var currentHasTimeout = false;
  var jobCount = 0;

  void finishCurrentJob() {
    if (currentJob != null && !currentHasTimeout) {
      failures.add('$path job $currentJob must declare timeout-minutes.');
    }
  }

  for (var index = jobsIndex + 1; index < lines.length; index += 1) {
    final line = lines[index];
    final trimmed = line.trim();
    if (trimmed.isEmpty || trimmed.startsWith('#')) {
      continue;
    }
    if (!line.startsWith(' ')) {
      break;
    }

    final jobMatch = jobPattern.firstMatch(line);
    if (jobMatch != null) {
      finishCurrentJob();
      currentJob = jobMatch.group(1);
      currentHasTimeout = false;
      jobCount += 1;
      continue;
    }

    if (currentJob != null && timeoutPattern.hasMatch(line)) {
      currentHasTimeout = true;
    }
  }
  finishCurrentJob();

  if (jobCount == 0) {
    failures.add('$path does not declare any parseable jobs.');
  }
}

void _auditCheckoutCredentials(
  String path,
  String source,
  String? contentsPermission,
  List<String> failures,
) {
  if (contentsPermission != 'read') {
    return;
  }

  final checkoutCount = RegExp(
    r'uses:\s*actions/checkout@[0-9a-f]{40}',
  ).allMatches(source).length;
  final disabledCredentialCount = RegExp(
    r'^\s*persist-credentials:\s*false\s*$',
    multiLine: true,
  ).allMatches(source).length;

  if (disabledCredentialCount != checkoutCount) {
    failures.add(
      '$path is read-only but disables checkout credential persistence for '
      '$disabledCredentialCount of $checkoutCount checkout step(s).',
    );
  }
}

void _auditWriterPolicy(
  String path,
  String source,
  String? contentsPermission,
  List<String> failures,
) {
  final approvedWriter = _approvedWriterWorkflows.contains(path);

  if (contentsPermission == 'write' && !approvedWriter) {
    failures.add(
      '$path requests contents: write but is not an approved writer.',
    );
    return;
  }
  if (!approvedWriter) {
    return;
  }

  if (contentsPermission != 'write') {
    failures.add('$path must retain explicit contents: write permission.');
  }
  if (RegExp(r'^\s*pull_request:\s*$', multiLine: true).hasMatch(source)) {
    failures.add(
      '$path must not run with write permission on pull_request events.',
    );
  }
  if (!RegExp(r'^concurrency:\s*$', multiLine: true).hasMatch(source) ||
      !RegExp(
        r'^  cancel-in-progress:\s*true\s*$',
        multiLine: true,
      ).hasMatch(source)) {
    failures.add('$path must serialize/cancel overlapping repository writes.');
  }
  if (!source.contains("github.actor != 'github-actions[bot]'")) {
    failures.add('$path must guard against github-actions bot push loops.');
  }
  if (!source.contains('git push origin HEAD:main')) {
    failures.add('$path must keep its normal non-force main push explicit.');
  }
  if (source.contains('git push --force') || source.contains('git push -f')) {
    failures.add('$path must never force-push repository-generated changes.');
  }
}

void _auditCiWiring(Directory root, List<String> failures) {
  final file = File.fromUri(root.uri.resolve(_ciWorkflow));
  final source = _read(file, _ciWorkflow, failures);
  if (source != null && !source.contains(_auditCommand)) {
    failures.add('Permanent CI must run the workflow security audit.');
  }
}

String? _read(File file, String path, List<String> failures) {
  if (!file.existsSync()) {
    failures.add('Required workflow security file is missing: $path');
    return null;
  }
  try {
    return file.readAsStringSync();
  } on FileSystemException catch (error) {
    failures.add('Could not read $path: ${error.message}');
    return null;
  }
}

String _relativePath(Directory root, File file) {
  final prefix = root.path.endsWith(Platform.pathSeparator)
      ? root.path
      : '${root.path}${Platform.pathSeparator}';
  return file.path
      .substring(prefix.length)
      .replaceAll(Platform.pathSeparator, '/');
}
