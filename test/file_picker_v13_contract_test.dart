import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('backup file transport uses file_picker 13 single-file API', () {
    final source = File(
      'lib/shared/game_backup_file_port.dart',
    ).readAsStringSync();

    expect(source, contains('FilePicker.pickFile('));
    expect(source, isNot(contains('FilePicker.pickFiles(')));
    expect(source, isNot(contains('allowMultiple:')));
    expect(source, isNot(contains('withData:')));
    expect(source, contains('file.lengthSync()'));
    expect(source, contains('await file.length()'));
    expect(source, contains('file.readAsByteStream()'));
    expect(source, contains('maxBytes - builder.length'));
  });

  test('macOS generated registrant matches the maintained picker plugin', () {
    final source = File(
      'macos/Flutter/GeneratedPluginRegistrant.swift',
    ).readAsStringSync();

    expect(source, contains('import file_picker_darwin'));
  });
}
