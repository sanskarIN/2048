import 'dart:convert';
import 'dart:io';

const _requiredFiles = <String>[
  'android/app/build.gradle.kts',
  'android/app/proguard-rules.pro',
  'android/app/src/main/AndroidManifest.xml',
  '.github/workflows/platform-builds.yml',
  'docs/ANDROID_SUPPORT.md',
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
    stdout.writeln('2048 Nova Android support audit');
    stdout.writeln();
    stdout.writeln('Usage: dart run tool/android_support_audit.dart [options]');
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
    _auditFiles(root, failures);
    _auditManifest(root, failures);
    _auditGradle(root, failures);
    _auditWorkflow(root, failures);
    _auditDocumentation(root, failures);
  }

  final result = <String, Object?>{
    'root': root.path,
    'androidReady': failures.isEmpty,
    'failures': failures,
  };

  if (jsonMode) {
    stdout.writeln(const JsonEncoder.withIndent('  ').convert(result));
  } else {
    stdout.writeln('2048 Nova Android support audit');
    stdout.writeln('Root: ${root.path}');
    stdout.writeln('Android source readiness: ${failures.isEmpty ? 'yes' : 'no'}');
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

void _auditFiles(Directory root, List<String> failures) {
  for (final path in _requiredFiles) {
    final file = File.fromUri(root.uri.resolve(path));
    if (!file.existsSync()) {
      failures.add('Required Android support file is missing: $path');
      continue;
    }
    if (file.lengthSync() == 0) {
      failures.add('Required Android support file is empty: $path');
    }
  }
}

void _auditManifest(Directory root, List<String> failures) {
  final manifest = _read(
    root,
    'android/app/src/main/AndroidManifest.xml',
    failures,
  );
  if (manifest == null) {
    return;
  }

  const required = <String, String>{
    'RTL support': 'android:supportsRtl="true"',
    'resizable activity': 'android:resizeableActivity="true"',
    'hardware acceleration': 'android:hardwareAccelerated="true"',
    'cleartext traffic disabled': 'android:usesCleartextTraffic="false"',
    'platform backup disabled': 'android:allowBackup="false"',
    'optional touchscreen hardware': 'android:required="false"',
    'Flutter embedding v2': 'android:name="flutterEmbedding"',
  };

  for (final entry in required.entries) {
    if (!manifest.contains(entry.value)) {
      failures.add('Android manifest is missing ${entry.key}: ${entry.value}');
    }
  }

  if (manifest.contains('android:screenOrientation=')) {
    failures.add('Android activity must not hard-lock orientation.');
  }
}

void _auditGradle(Directory root, List<String> failures) {
  final gradle = _read(root, 'android/app/build.gradle.kts', failures);
  if (gradle == null) {
    return;
  }

  const required = <String, String>{
    'stable application ID': 'applicationId = "com.sanskarin.nova_2048"',
    'Flutter minSdk contract': 'minSdk = flutter.minSdkVersion',
    'Flutter targetSdk contract': 'targetSdk = flutter.targetSdkVersion',
    'Java 17 source target': 'sourceCompatibility = JavaVersion.VERSION_17',
    'Java 17 bytecode target': 'targetCompatibility = JavaVersion.VERSION_17',
    'Kotlin JVM 17 target': 'JvmTarget.JVM_17',
    'R8 minification': 'isMinifyEnabled = true',
    'resource shrinking': 'isShrinkResources = true',
    'optimized ProGuard baseline': 'proguard-android-optimize.txt',
    'project R8 rules': '"proguard-rules.pro"',
    'release signing fallback': 'signingConfigs.getByName("debug")',
  };

  for (final entry in required.entries) {
    if (!gradle.contains(entry.value)) {
      failures.add('Android Gradle config is missing ${entry.key}: ${entry.value}');
    }
  }
}

void _auditWorkflow(Directory root, List<String> failures) {
  final workflow = _read(root, '.github/workflows/platform-builds.yml', failures);
  if (workflow == null) {
    return;
  }

  const required = <String, String>{
    'universal APK build': 'flutter build apk --release',
    'split ABI APK build': 'flutter build apk --release --split-per-abi',
    'AAB build': 'flutter build appbundle --release',
    'armeabi-v7a artifact': 'app-armeabi-v7a-release.apk',
    'arm64-v8a artifact': 'app-arm64-v8a-release.apk',
    'x86_64 artifact': 'app-x86_64-release.apk',
    'Android AAB artifact': 'app-release.aab',
  };

  for (final entry in required.entries) {
    if (!workflow.contains(entry.value)) {
      failures.add('Android CI is missing ${entry.key}: ${entry.value}');
    }
  }
}

void _auditDocumentation(Directory root, List<String> failures) {
  final docs = _read(root, 'docs/ANDROID_SUPPORT.md', failures);
  if (docs == null) {
    return;
  }

  for (final fragment in <String>[
    'flutter build apk --release',
    'flutter build apk --release --split-per-abi',
    'flutter build appbundle --release',
    'physical',
    'signing',
  ]) {
    if (!docs.toLowerCase().contains(fragment.toLowerCase())) {
      failures.add('Android support documentation is missing: $fragment');
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
