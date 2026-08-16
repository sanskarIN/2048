import 'dart:convert';
import 'dart:io';

const _manifestPath = 'docs/release_qualification.json';

const _requiredFiles = <String>[
  'README.md',
  'CHANGELOG.md',
  'ROADMAP.md',
  'SECURITY.md',
  'SUPPORT.md',
  'CONTRIBUTING.md',
  'what_changed.md',
  'pubspec.yaml',
  _manifestPath,
  '.github/workflows/ci.yml',
  '.github/workflows/platform-builds.yml',
];

const _requiredManualCheckIds = <String>[
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

const _allowedStatuses = <String>{'pending', 'passed', 'blocked'};

void main(List<String> args) {
  final stableMode = args.contains('--stable');
  final jsonMode = args.contains('--json');
  final helpMode = args.contains('--help') || args.contains('-h');
  final unknownArgs = args
      .where(
        (arg) =>
            arg != '--stable' &&
            arg != '--json' &&
            arg != '--help' &&
            arg != '-h',
      )
      .toList(growable: false);

  if (helpMode) {
    stdout.writeln('2048 Nova release readiness gate');
    stdout.writeln();
    stdout.writeln('Usage: dart run tool/release_readiness.dart [options]');
    stdout.writeln();
    stdout.writeln('  --json    Emit machine-readable JSON.');
    stdout.writeln(
      '  --stable  Require every stable-release condition and manual evidence item.',
    );
    stdout.writeln('  --help    Show this help text.');
    return;
  }

  final failures = <String>[];
  final warnings = <String>[];

  if (unknownArgs.isNotEmpty) {
    failures.add('Unknown argument(s): ${unknownArgs.join(', ')}');
  }

  for (final path in _requiredFiles) {
    final file = File(path);
    if (!file.existsSync()) {
      failures.add('Required release file is missing: $path');
      continue;
    }
    if (file.lengthSync() == 0) {
      failures.add('Required release file is empty: $path');
    }
  }

  final pubspec = _readFile('pubspec.yaml', failures);
  final changelog = _readFile('CHANGELOG.md', failures);
  final roadmap = _readFile('ROADMAP.md', failures);
  final manifestText = _readFile(_manifestPath, failures);

  final version = _readVersion(pubspec, failures);
  final manifest = _readManifest(manifestText, failures);

  final checks = _validateManifest(
    manifest: manifest,
    version: version,
    failures: failures,
    warnings: warnings,
  );

  if (changelog != null && !changelog.contains('## [Unreleased]')) {
    failures.add('CHANGELOG.md must keep an [Unreleased] section.');
  }

  if (roadmap != null &&
      !roadmap.contains('Remaining release qualification before `1.0.0`')) {
    failures.add(
      'ROADMAP.md must preserve the explicit pre-1.0 release qualification boundary.',
    );
  }

  if (version != null) {
    final acceptableCandidate = RegExp(
      r'^(?:0\.9\.\d+|1\.0\.0)(?:\+\d+)?$',
    ).hasMatch(version);
    if (!acceptableCandidate) {
      failures.add(
        'pubspec version must remain in the 0.9.x release-candidate line or be 1.0.0 while using this gate; found $version.',
      );
    }
  }

  final passedChecks = checks.where((check) => check.status == 'passed').length;
  final allManualChecksPassed =
      checks.length == _requiredManualCheckIds.length &&
      checks.every((check) => check.isStableEvidenceComplete);

  var stableMetadataReady = false;
  if (version != null && changelog != null) {
    stableMetadataReady = RegExp(
          r'^1\.0\.0(?:\+\d+)?$',
        ).hasMatch(version) &&
        changelog.contains('## [1.0.0]');
  }

  final readyForStable =
      failures.isEmpty && allManualChecksPassed && stableMetadataReady;

  if (stableMode) {
    if (version == null ||
        !RegExp(r'^1\.0\.0(?:\+\d+)?$').hasMatch(version)) {
      failures.add(
        'Stable mode requires pubspec.yaml version 1.0.0 (optionally with a build number).',
      );
    }
    if (changelog == null || !changelog.contains('## [1.0.0]')) {
      failures.add('Stable mode requires a CHANGELOG.md [1.0.0] release section.');
    }
    for (final check in checks) {
      if (!check.isStableEvidenceComplete) {
        failures.add(
          'Stable mode requires passed evidence for manual check "${check.id}".',
        );
      }
    }
  } else if (!allManualChecksPassed) {
    warnings.add(
      'Manual release qualification is incomplete: $passedChecks/${_requiredManualCheckIds.length} checks have passed evidence.',
    );
  }

  final result = <String, Object?>{
    'mode': stableMode ? 'stable' : 'candidate',
    'version': version,
    'candidateGatePassed': failures.isEmpty,
    'readyForStable': readyForStable,
    'manualChecksPassed': passedChecks,
    'manualChecksRequired': _requiredManualCheckIds.length,
    'failures': failures,
    'warnings': warnings,
  };

  if (jsonMode) {
    stdout.writeln(const JsonEncoder.withIndent('  ').convert(result));
  } else {
    stdout.writeln('2048 Nova release readiness');
    stdout.writeln('Mode: ${stableMode ? 'stable' : 'candidate'}');
    stdout.writeln('Version: ${version ?? 'unknown'}');
    stdout.writeln(
      'Manual evidence: $passedChecks/${_requiredManualCheckIds.length} passed',
    );
    stdout.writeln('Ready for stable: ${readyForStable ? 'yes' : 'no'}');

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

String? _readFile(String path, List<String> failures) {
  final file = File(path);
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

String? _readVersion(String? pubspec, List<String> failures) {
  if (pubspec == null) {
    return null;
  }
  final match = RegExp(r'^version:\s*(\S+)\s*$', multiLine: true).firstMatch(
    pubspec,
  );
  if (match == null) {
    failures.add('pubspec.yaml does not contain a parseable version field.');
    return null;
  }
  return match.group(1);
}

Map<String, dynamic>? _readManifest(
  String? text,
  List<String> failures,
) {
  if (text == null) {
    return null;
  }
  try {
    final decoded = jsonDecode(text);
    if (decoded is! Map<String, dynamic>) {
      failures.add('$_manifestPath must contain a JSON object.');
      return null;
    }
    return decoded;
  } on FormatException catch (error) {
    failures.add('$_manifestPath is not valid JSON: ${error.message}');
    return null;
  }
}

List<_ManualCheck> _validateManifest({
  required Map<String, dynamic>? manifest,
  required String? version,
  required List<String> failures,
  required List<String> warnings,
}) {
  if (manifest == null) {
    return const [];
  }

  if (manifest['schemaVersion'] != 1) {
    failures.add('$_manifestPath schemaVersion must be 1.');
  }

  final candidate = manifest['candidate'];
  if (candidate is! String || candidate.trim().isEmpty) {
    failures.add('$_manifestPath candidate must be a non-empty string.');
  } else if (version != null && candidate != version) {
    failures.add(
      '$_manifestPath candidate ($candidate) must match pubspec version ($version).',
    );
  }

  final rawChecks = manifest['manualChecks'];
  if (rawChecks is! List) {
    failures.add('$_manifestPath manualChecks must be a JSON array.');
    return const [];
  }

  final checks = <_ManualCheck>[];
  final seenIds = <String>{};

  for (var index = 0; index < rawChecks.length; index += 1) {
    final raw = rawChecks[index];
    if (raw is! Map<String, dynamic>) {
      failures.add('manualChecks[$index] must be a JSON object.');
      continue;
    }

    final id = raw['id'];
    final title = raw['title'];
    final status = raw['status'];
    final evidence = raw['evidence'];
    final updatedAt = raw['updatedAt'];

    if (id is! String || id.trim().isEmpty) {
      failures.add('manualChecks[$index].id must be a non-empty string.');
      continue;
    }
    if (!seenIds.add(id)) {
      failures.add('Duplicate manual check id: $id');
      continue;
    }
    if (!_requiredManualCheckIds.contains(id)) {
      failures.add('Unknown manual check id: $id');
    }
    if (title is! String || title.trim().isEmpty) {
      failures.add('Manual check "$id" must have a non-empty title.');
    }
    if (status is! String || !_allowedStatuses.contains(status)) {
      failures.add(
        'Manual check "$id" status must be pending, passed, or blocked.',
      );
      continue;
    }
    if (evidence is! String) {
      failures.add('Manual check "$id" evidence must be a string.');
      continue;
    }
    if (updatedAt != null && updatedAt is! String) {
      failures.add('Manual check "$id" updatedAt must be null or a string.');
      continue;
    }

    DateTime? parsedUpdatedAt;
    if (updatedAt is String && updatedAt.trim().isNotEmpty) {
      parsedUpdatedAt = DateTime.tryParse(updatedAt);
      if (parsedUpdatedAt == null) {
        failures.add(
          'Manual check "$id" updatedAt must be an ISO-8601 timestamp.',
        );
      }
    }

    final check = _ManualCheck(
      id: id,
      status: status,
      evidence: evidence,
      updatedAt: parsedUpdatedAt,
    );
    checks.add(check);

    if (status == 'passed' && !check.isStableEvidenceComplete) {
      failures.add(
        'Passed manual check "$id" must include non-empty evidence and a valid updatedAt timestamp.',
      );
    }
    if (status == 'blocked' && evidence.trim().isEmpty) {
      warnings.add('Blocked manual check "$id" should explain the blocker.');
    }
  }

  final missingIds = _requiredManualCheckIds.where((id) => !seenIds.contains(id));
  for (final id in missingIds) {
    failures.add('Missing required manual check id: $id');
  }

  return checks;
}

class _ManualCheck {
  const _ManualCheck({
    required this.id,
    required this.status,
    required this.evidence,
    required this.updatedAt,
  });

  final String id;
  final String status;
  final String evidence;
  final DateTime? updatedAt;

  bool get isStableEvidenceComplete =>
      status == 'passed' && evidence.trim().isNotEmpty && updatedAt != null;
}
