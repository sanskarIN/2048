import 'dart:convert';
import 'dart:io';

const _targets = <String, List<String>>{
  'Android': <String>[
    'android/app/build.gradle.kts',
    'android/app/src/main/AndroidManifest.xml',
  ],
  'iOS': <String>[
    'ios/Runner/Info.plist',
    'ios/Runner.xcodeproj/project.pbxproj',
  ],
  'Web/PWA': <String>[
    'web/index.html',
    'web/manifest.json',
  ],
  'Windows': <String>[
    'windows/CMakeLists.txt',
    'windows/runner/main.cpp',
  ],
  'macOS': <String>[
    'macos/Runner/Info.plist',
    'macos/Runner.xcodeproj/project.pbxproj',
  ],
  'Linux': <String>[
    'linux/CMakeLists.txt',
    'linux/runner/main.cc',
  ],
};

const _requiredBuildFragments = <String, String>{
  'Android APK': 'flutter build apk --release',
  'Android AAB': 'flutter build appbundle --release',
  'iOS': 'flutter build ios --release --no-codesign',
  'Web/PWA': 'flutter build web --release',
  'Windows': 'flutter build windows --release',
  'macOS': 'flutter build macos --release',
  'Linux': 'flutter build linux --release',
};

const _platformWorkflow = '.github/workflows/platform-builds.yml';
const _ciWorkflow = '.github/workflows/ci.yml';
const _auditCommand = 'dart run tool/platform_support_audit.dart --json';

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
    stdout.writeln('2048 Nova cross-platform support audit');
    stdout.writeln();
    stdout.writeln(
      'Usage: dart run tool/platform_support_audit.dart [options]',
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

  final targetStatus = <String, bool>{};
  if (!root.existsSync()) {
    failures.add('Repository root does not exist: ${root.path}');
  } else {
    _auditTargetRunners(root, targetStatus, failures);
    _auditBuildMatrix(root, failures);
    _auditWebPwaPackaging(root, failures);
    _auditCiWiring(root, failures);
  }

  final result = <String, Object?>{
    'root': root.path,
    'supportedTargets': _targets.keys.toList(growable: false),
    'targetStatus': targetStatus,
    'crossPlatformReady': failures.isEmpty,
    'failures': failures,
  };

  if (jsonMode) {
    stdout.writeln(const JsonEncoder.withIndent('  ').convert(result));
  } else {
    stdout.writeln('2048 Nova cross-platform support audit');
    stdout.writeln('Root: ${root.path}');
    for (final entry in targetStatus.entries) {
      stdout.writeln('${entry.key}: ${entry.value ? 'configured' : 'incomplete'}');
    }
    stdout.writeln(
      'Cross-platform source readiness: ${failures.isEmpty ? 'yes' : 'no'}',
    );
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

void _auditTargetRunners(
  Directory root,
  Map<String, bool> targetStatus,
  List<String> failures,
) {
  for (final entry in _targets.entries) {
    var configured = true;
    for (final path in entry.value) {
      final file = File.fromUri(root.uri.resolve(path));
      if (!file.existsSync()) {
        configured = false;
        failures.add('${entry.key} runner file is missing: $path');
        continue;
      }
      if (file.lengthSync() == 0) {
        configured = false;
        failures.add('${entry.key} runner file is empty: $path');
      }
    }
    targetStatus[entry.key] = configured;
  }
}

void _auditBuildMatrix(Directory root, List<String> failures) {
  final workflow = _read(root, _platformWorkflow, failures);
  if (workflow == null) {
    return;
  }

  for (final entry in _requiredBuildFragments.entries) {
    if (!workflow.contains(entry.value)) {
      failures.add(
        'Platform Builds workflow is missing ${entry.key} release command: ${entry.value}',
      );
    }
  }

  for (final platformPath in <String>[
    'android/**',
    'ios/**',
    'web/**',
    'windows/**',
    'macos/**',
    'linux/**',
  ]) {
    if (!workflow.contains(platformPath)) {
      failures.add(
        'Platform Builds workflow does not react to $platformPath changes.',
      );
    }
  }
}

void _auditWebPwaPackaging(Directory root, List<String> failures) {
  final workflow = _read(root, _platformWorkflow, failures);
  if (workflow == null) {
    return;
  }

  const requiredFragments = <String>[
    'build/web/index.html',
    'build/web/manifest.json',
    'flutter_service_worker.js',
    'nova-2048-web-pwa.tar.gz',
    'nova-2048-web-pwa.tar.gz.sha256',
    'nova-2048-web-pwa-release',
  ];

  for (final fragment in requiredFragments) {
    if (!workflow.contains(fragment)) {
      failures.add('Web/PWA qualification packaging is missing: $fragment');
    }
  }
}

void _auditCiWiring(Directory root, List<String> failures) {
  final ci = _read(root, _ciWorkflow, failures);
  if (ci != null && !ci.contains(_auditCommand)) {
    failures.add('Permanent CI must run the cross-platform support audit.');
  }
}

String? _read(Directory root, String path, List<String> failures) {
  final file = File.fromUri(root.uri.resolve(path));
  if (!file.existsSync()) {
    failures.add('Required cross-platform file is missing: $path');
    return null;
  }
  try {
    return file.readAsStringSync();
  } on FileSystemException catch (error) {
    failures.add('Could not read $path: ${error.message}');
    return null;
  }
}
