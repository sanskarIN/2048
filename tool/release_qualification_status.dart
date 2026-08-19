import 'dart:convert';
import 'dart:io';

const _manifestPath = 'docs/release_qualification.json';
const _allowedStatuses = <String>{'pending', 'passed', 'blocked'};

void main(List<String> args) {
  if (args.contains('--help') || args.contains('-h')) {
    _printHelp();
    return;
  }

  final errors = <String>[];
  final unknown = args.where((arg) {
    return arg != '--json' &&
        arg != '--pending-only' &&
        arg != '--fail-if-incomplete' &&
        arg != '--help' &&
        arg != '-h' &&
        !arg.startsWith('--root=');
  }).toList(growable: false);
  if (unknown.isNotEmpty) {
    errors.add('Unknown argument(s): ${unknown.join(', ')}');
  }

  final rootValue = _singleValue(args, '--root=', errors);
  final root = Directory(
    rootValue == null || rootValue.trim().isEmpty
        ? Directory.current.path
        : rootValue.trim(),
  ).absolute;
  final manifestFile = File.fromUri(root.uri.resolve(_manifestPath));

  if (!root.existsSync()) {
    errors.add('Repository root does not exist: ${root.path}');
  }
  if (!manifestFile.existsSync()) {
    errors.add('Qualification manifest is missing: ${manifestFile.path}');
  }

  Map<String, dynamic>? manifest;
  if (errors.isEmpty) {
    manifest = _readManifest(manifestFile, errors);
  }
  final report = manifest == null ? null : _buildReport(manifest, errors);

  if (errors.isNotEmpty || report == null) {
    _fail(errors);
    return;
  }

  final pendingOnly = args.contains('--pending-only');
  final outputReport = pendingOnly ? report.pendingOnly() : report;
  if (args.contains('--json')) {
    stdout.writeln(const JsonEncoder.withIndent('  ').convert(outputReport.toJson()));
  } else {
    _printHuman(outputReport, pendingOnly: pendingOnly);
  }

  if (args.contains('--fail-if-incomplete') && !report.complete) {
    exitCode = 3;
  }
}

String? _singleValue(List<String> args, String prefix, List<String> errors) {
  final matches = args.where((arg) => arg.startsWith(prefix)).toList();
  if (matches.length > 1) {
    errors.add(
      'Only one ${prefix.substring(0, prefix.length - 1)} value is allowed.',
    );
  }
  if (matches.isEmpty) return null;
  return matches.first.substring(prefix.length);
}

Map<String, dynamic>? _readManifest(File file, List<String> errors) {
  try {
    final decoded = jsonDecode(file.readAsStringSync());
    if (decoded is! Map<String, dynamic>) {
      errors.add('$_manifestPath must contain a JSON object.');
      return null;
    }
    return decoded;
  } on FormatException catch (error) {
    errors.add('$_manifestPath is not valid JSON: ${error.message}');
  } on FileSystemException catch (error) {
    errors.add('Could not read $_manifestPath: ${error.message}');
  }
  return null;
}

_QualificationReport? _buildReport(
  Map<String, dynamic> manifest,
  List<String> errors,
) {
  if (manifest['schemaVersion'] != 1) {
    errors.add('$_manifestPath schemaVersion must be 1.');
  }

  final candidate = manifest['candidate'];
  if (candidate is! String || candidate.trim().isEmpty) {
    errors.add('$_manifestPath candidate must be a non-empty string.');
  }

  final rawChecks = manifest['manualChecks'];
  if (rawChecks is! List) {
    errors.add('$_manifestPath manualChecks must be a JSON array.');
    return null;
  }

  final checks = <_QualificationCheck>[];
  final ids = <String>{};
  for (var index = 0; index < rawChecks.length; index += 1) {
    final raw = rawChecks[index];
    if (raw is! Map<String, dynamic>) {
      errors.add('manualChecks[$index] must be a JSON object.');
      continue;
    }

    final id = raw['id'];
    final title = raw['title'];
    final status = raw['status'];
    final evidence = raw['evidence'];
    final updatedAt = raw['updatedAt'];

    if (id is! String || id.trim().isEmpty) {
      errors.add('manualChecks[$index].id must be a non-empty string.');
      continue;
    }
    if (!ids.add(id)) {
      errors.add('Duplicate manual check id: $id');
      continue;
    }
    if (title is! String || title.trim().isEmpty) {
      errors.add('Manual check "$id" must have a non-empty title.');
      continue;
    }
    if (status is! String || !_allowedStatuses.contains(status)) {
      errors.add('Manual check "$id" has an invalid status.');
      continue;
    }
    if (evidence is! String) {
      errors.add('Manual check "$id" evidence must be a string.');
      continue;
    }
    if (updatedAt != null && updatedAt is! String) {
      errors.add('Manual check "$id" updatedAt must be null or a string.');
      continue;
    }

    if (status == 'pending') {
      if (evidence.isNotEmpty || updatedAt != null) {
        errors.add(
          'Pending manual check "$id" must not retain evidence or updatedAt.',
        );
        continue;
      }
    } else {
      if (evidence.trim().isEmpty) {
        errors.add('Manual check "$id" with status $status needs evidence.');
        continue;
      }
      if (updatedAt == null || !_validExplicitTimestamp(updatedAt)) {
        errors.add(
          'Manual check "$id" with status $status needs an ISO-8601 updatedAt with an explicit timezone.',
        );
        continue;
      }
    }

    checks.add(
      _QualificationCheck(
        id: id,
        title: title.trim(),
        status: status,
        evidence: evidence.trim(),
        updatedAt: updatedAt,
      ),
    );
  }

  if (checks.isEmpty) {
    errors.add('$_manifestPath must contain at least one valid manual check.');
  }
  if (errors.isNotEmpty) return null;

  return _QualificationReport(candidate: (candidate as String).trim(), checks: checks);
}

bool _validExplicitTimestamp(String value) {
  final hasOffset = RegExp(r'(?:Z|[+-]\d{2}:\d{2})$').hasMatch(value);
  return hasOffset && DateTime.tryParse(value) != null;
}

void _printHuman(_QualificationReport report, {required bool pendingOnly}) {
  stdout.writeln('2048 Nova release qualification status');
  stdout.writeln('Candidate: ${report.candidate}');
  stdout.writeln(
    'Progress: ${report.passed}/${report.total} passed, '
    '${report.pending} pending, ${report.blocked} blocked',
  );
  stdout.writeln('Complete: ${report.complete ? 'yes' : 'no'}');
  stdout.writeln();
  stdout.writeln(pendingOnly ? 'Incomplete checks:' : 'Checks:');
  if (report.checks.isEmpty) {
    stdout.writeln('- none');
    return;
  }
  for (final check in report.checks) {
    stdout.writeln('- ${check.id}: ${check.status} — ${check.title}');
  }
}

void _fail(List<String> errors) {
  if (errors.isEmpty) {
    stderr.writeln('error: Could not build qualification status report.');
  } else {
    for (final error in errors) {
      stderr.writeln('error: $error');
    }
  }
  exitCode = 64;
}

void _printHelp() {
  stdout.writeln('2048 Nova release qualification status reporter');
  stdout.writeln();
  stdout.writeln('Usage:');
  stdout.writeln('  dart run tool/release_qualification_status.dart [options]');
  stdout.writeln();
  stdout.writeln('Options:');
  stdout.writeln('  --json                Emit a machine-readable JSON report.');
  stdout.writeln('  --pending-only        Show only pending or blocked checks.');
  stdout.writeln(
    '  --fail-if-incomplete Exit with status 3 when any check is incomplete.',
  );
  stdout.writeln('  --root=<path>         Read another repository root.');
  stdout.writeln('  --help                Show this help text.');
  stdout.writeln();
  stdout.writeln(
    'This command is read-only. It reports recorded evidence and never marks a manual qualification check as passed.',
  );
}

class _QualificationReport {
  const _QualificationReport({required this.candidate, required this.checks});

  final String candidate;
  final List<_QualificationCheck> checks;

  int get total => checks.length;
  int get passed => checks.where((check) => check.status == 'passed').length;
  int get pending => checks.where((check) => check.status == 'pending').length;
  int get blocked => checks.where((check) => check.status == 'blocked').length;
  bool get complete => total > 0 && passed == total;

  _QualificationReport pendingOnly() => _QualificationReport(
    candidate: candidate,
    checks: checks.where((check) => check.status != 'passed').toList(growable: false),
  );

  Map<String, Object?> toJson() => <String, Object?>{
    'candidate': candidate,
    'total': total,
    'passed': passed,
    'pending': pending,
    'blocked': blocked,
    'complete': complete,
    'checks': checks.map((check) => check.toJson()).toList(growable: false),
  };
}

class _QualificationCheck {
  const _QualificationCheck({
    required this.id,
    required this.title,
    required this.status,
    required this.evidence,
    required this.updatedAt,
  });

  final String id;
  final String title;
  final String status;
  final String evidence;
  final String? updatedAt;

  Map<String, Object?> toJson() => <String, Object?>{
    'id': id,
    'title': title,
    'status': status,
    'evidence': evidence,
    'updatedAt': updatedAt,
  };
}
