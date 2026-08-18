import 'dart:convert';
import 'dart:io';

const _manifestPath = 'docs/release_qualification.json';
const _allowedStatuses = <String>{'pending', 'passed', 'blocked'};
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

void main(List<String> args) {
  if (args.contains('--help') || args.contains('-h')) {
    _printHelp();
    return;
  }

  final errors = <String>[];
  final unknown = args.where((arg) {
    return arg != '--list' &&
        arg != '--dry-run' &&
        arg != '--help' &&
        arg != '-h' &&
        !arg.startsWith('--root=') &&
        !arg.startsWith('--id=') &&
        !arg.startsWith('--status=') &&
        !arg.startsWith('--evidence=') &&
        !arg.startsWith('--updated-at=');
  }).toList(growable: false);
  if (unknown.isNotEmpty) {
    errors.add('Unknown argument(s): ${unknown.join(', ')}');
  }

  final rootValue = _singleValue(args, '--root=', errors);
  final id = _singleValue(args, '--id=', errors);
  final status = _singleValue(args, '--status=', errors);
  final evidence = _singleValue(args, '--evidence=', errors);
  final updatedAt = _singleValue(args, '--updated-at=', errors);
  final listMode = args.contains('--list');
  final dryRun = args.contains('--dry-run');

  if (listMode &&
      (id != null || status != null || evidence != null || updatedAt != null)) {
    errors.add('--list cannot be combined with mutation arguments.');
  }
  if (listMode && dryRun) {
    errors.add('--list does not need --dry-run.');
  }

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
  final checks = manifest == null
      ? null
      : _validatedChecks(manifest, errors: errors);

  if (errors.isNotEmpty) {
    _fail(errors);
    return;
  }

  if (listMode) {
    _printChecks(checks!);
    return;
  }

  if (id == null || id.trim().isEmpty) {
    errors.add('A non-empty --id=<manual-check-id> is required.');
  }
  if (status == null || status.trim().isEmpty) {
    errors.add('A --status=pending|passed|blocked value is required.');
  } else if (!_allowedStatuses.contains(status.trim())) {
    errors.add('--status must be pending, passed, or blocked.');
  }

  final normalizedId = id?.trim();
  final normalizedStatus = status?.trim();
  if (normalizedId != null && !_requiredCheckIds.contains(normalizedId)) {
    errors.add('Unknown manual check id: $normalizedId');
  }

  if (normalizedStatus == 'passed' || normalizedStatus == 'blocked') {
    if (evidence == null || evidence.trim().isEmpty) {
      errors.add('$normalizedStatus status requires non-empty --evidence=...');
    }
  }

  DateTime? timestamp;
  if (updatedAt != null) {
    timestamp = _parseExplicitTimestamp(updatedAt.trim(), errors);
  } else if (normalizedStatus == 'passed' || normalizedStatus == 'blocked') {
    timestamp = DateTime.now().toUtc();
  }

  if (normalizedStatus == 'pending' &&
      (evidence != null || updatedAt != null)) {
    errors.add(
      'pending status clears evidence and updatedAt; omit --evidence and --updated-at.',
    );
  }

  if (errors.isNotEmpty) {
    _fail(errors);
    return;
  }

  final matching = checks!
      .where((check) => check['id'] == normalizedId)
      .toList(growable: false);
  if (matching.length != 1) {
    _fail(<String>[
      'Manifest must contain exactly one manual check with id $normalizedId.',
    ]);
    return;
  }

  final check = matching.single;
  check['status'] = normalizedStatus;
  if (normalizedStatus == 'pending') {
    check['evidence'] = '';
    check['updatedAt'] = null;
  } else {
    check['evidence'] = evidence!.trim();
    check['updatedAt'] = timestamp!.toIso8601String();
  }

  final output = '${const JsonEncoder.withIndent('  ').convert(manifest)}\n';
  if (dryRun) {
    stdout.write(output);
    return;
  }

  try {
    manifestFile.writeAsStringSync(output, flush: true);
  } on FileSystemException catch (error) {
    _fail(<String>['Could not write $_manifestPath: ${error.message}']);
    return;
  }

  stdout.writeln(
    'Updated $normalizedId to $normalizedStatus in $_manifestPath.',
  );
}

String? _singleValue(
  List<String> args,
  String prefix,
  List<String> errors,
) {
  final matches = args.where((arg) => arg.startsWith(prefix)).toList();
  if (matches.length > 1) {
    errors.add('Only one ${prefix.substring(0, prefix.length - 1)} value is allowed.');
  }
  if (matches.isEmpty) {
    return null;
  }
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

List<Map<String, dynamic>>? _validatedChecks(
  Map<String, dynamic> manifest, {
  required List<String> errors,
}) {
  if (manifest['schemaVersion'] != 1) {
    errors.add('$_manifestPath schemaVersion must be 1.');
  }

  final rawChecks = manifest['manualChecks'];
  if (rawChecks is! List) {
    errors.add('$_manifestPath manualChecks must be a JSON array.');
    return null;
  }

  final checks = <Map<String, dynamic>>[];
  final seen = <String>{};
  for (var index = 0; index < rawChecks.length; index += 1) {
    final raw = rawChecks[index];
    if (raw is! Map<String, dynamic>) {
      errors.add('manualChecks[$index] must be a JSON object.');
      continue;
    }
    final id = raw['id'];
    if (id is! String || id.trim().isEmpty) {
      errors.add('manualChecks[$index].id must be a non-empty string.');
      continue;
    }
    if (!seen.add(id)) {
      errors.add('Duplicate manual check id: $id');
      continue;
    }
    if (!_requiredCheckIds.contains(id)) {
      errors.add('Unknown manual check id in manifest: $id');
    }
    if (raw['title'] is! String || (raw['title'] as String).trim().isEmpty) {
      errors.add('Manual check "$id" must have a non-empty title.');
    }
    final currentStatus = raw['status'];
    if (currentStatus is! String || !_allowedStatuses.contains(currentStatus)) {
      errors.add('Manual check "$id" has an invalid status.');
    }
    if (raw['evidence'] is! String) {
      errors.add('Manual check "$id" evidence must be a string.');
    }
    final currentUpdatedAt = raw['updatedAt'];
    if (currentUpdatedAt != null && currentUpdatedAt is! String) {
      errors.add('Manual check "$id" updatedAt must be null or a string.');
    }
    checks.add(raw);
  }

  for (final requiredId in _requiredCheckIds) {
    if (!seen.contains(requiredId)) {
      errors.add('Missing required manual check id: $requiredId');
    }
  }
  if (checks.length != _requiredCheckIds.length) {
    errors.add(
      'Manifest must contain exactly ${_requiredCheckIds.length} manual checks.',
    );
  }

  return checks;
}

DateTime? _parseExplicitTimestamp(String value, List<String> errors) {
  if (value.isEmpty) {
    errors.add('--updated-at must not be empty.');
    return null;
  }
  final explicitOffset = RegExp(r'(?:Z|[+-]\d{2}:\d{2})$').hasMatch(value);
  final parsed = DateTime.tryParse(value);
  if (!explicitOffset || parsed == null) {
    errors.add(
      '--updated-at must be a valid ISO-8601 timestamp ending in Z or a numeric offset.',
    );
    return null;
  }
  return parsed.toUtc();
}

void _printChecks(List<Map<String, dynamic>> checks) {
  stdout.writeln('2048 Nova manual release qualification');
  for (final check in checks) {
    stdout.writeln(
      '- ${check['id']}: ${check['status']} — ${check['title']}',
    );
  }
}

void _fail(List<String> errors) {
  for (final error in errors) {
    stderr.writeln('error: $error');
  }
  exitCode = 64;
}

void _printHelp() {
  stdout.writeln('2048 Nova release qualification recorder');
  stdout.writeln();
  stdout.writeln('Usage:');
  stdout.writeln('  dart run tool/record_release_qualification.dart --list');
  stdout.writeln(
    '  dart run tool/record_release_qualification.dart --id=<id> --status=<status> [options]',
  );
  stdout.writeln();
  stdout.writeln('Options:');
  stdout.writeln('  --list                  Show all required checks and states.');
  stdout.writeln('  --id=<id>               Required manual-check identifier.');
  stdout.writeln('  --status=<status>       pending, passed, or blocked.');
  stdout.writeln(
    '  --evidence=<text>      Required when status is passed or blocked.',
  );
  stdout.writeln(
    '  --updated-at=<time>    Optional explicit ISO-8601 Z/offset timestamp.',
  );
  stdout.writeln('  --dry-run               Print the changed manifest without writing it.');
  stdout.writeln('  --root=<path>           Operate on another repository root.');
  stdout.writeln('  --help                  Show this help text.');
  stdout.writeln();
  stdout.writeln(
    'The recorder never infers a passed result. A maintainer must explicitly choose passed and provide evidence from a real qualification check.',
  );
}
