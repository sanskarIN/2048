import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  const auditScripts = <String, String>{
    'tool/repository_audit.dart': 'passed',
    'tool/platform_support_audit.dart': 'crossPlatformReady',
    'tool/source_completion_audit.dart': 'featureComplete',
  };

  for (final entry in auditScripts.entries) {
    test('${entry.key} rejects an explicitly empty root', () async {
      final script = File(entry.key).absolute;
      expect(script.existsSync(), isTrue);

      final process = await Process.run('dart', <String>[
        script.path,
        '--root=',
        '--json',
      ]);

      expect(process.exitCode, 1, reason: process.stderr.toString());
      final output =
          jsonDecode(process.stdout as String) as Map<String, dynamic>;
      expect(output[entry.value], isFalse);
      expect(
        (output['failures'] as List<dynamic>).join('\n'),
        contains('The --root=<path> argument requires a non-empty path.'),
      );
    });
  }
}
