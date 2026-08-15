import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';

enum BackupFileSaveOutcome { saved, cancelled }

class BackupFileDocument {
  const BackupFileDocument({
    required this.name,
    required this.text,
  });

  final String name;
  final String text;
}

abstract interface class GameBackupFilePort {
  Future<BackupFileSaveOutcome> saveText({
    required String suggestedName,
    required String text,
  });

  Future<BackupFileDocument?> openText({required int maxBytes});
}

class SystemGameBackupFilePort implements GameBackupFilePort {
  const SystemGameBackupFilePort();

  static const _extensions = <String>['nova2048', 'json'];

  @override
  Future<BackupFileSaveOutcome> saveText({
    required String suggestedName,
    required String text,
  }) async {
    final bytes = Uint8List.fromList(utf8.encode(text));
    final path = await FilePicker.saveFile(
      dialogTitle: 'Save 2048 Nova game backup',
      fileName: suggestedName,
      type: FileType.custom,
      allowedExtensions: _extensions,
      bytes: bytes,
    );

    // Browsers hand the bytes to the download UI and intentionally return no
    // filesystem path. On native platforms a null path represents cancellation.
    if (kIsWeb) return BackupFileSaveOutcome.saved;
    return path == null
        ? BackupFileSaveOutcome.cancelled
        : BackupFileSaveOutcome.saved;
  }

  @override
  Future<BackupFileDocument?> openText({required int maxBytes}) async {
    if (maxBytes <= 0) {
      throw ArgumentError.value(maxBytes, 'maxBytes', 'Must be positive');
    }

    final result = await FilePicker.pickFiles(
      dialogTitle: 'Open 2048 Nova game backup',
      type: FileType.custom,
      allowedExtensions: _extensions,
      allowMultiple: false,
      // Web needs in-memory bytes for a reliable XFile fallback in file_picker
      // 11.x. Native platforms can defer the read until after the size check.
      withData: kIsWeb,
    );
    if (result == null || result.files.isEmpty) return null;

    final file = result.files.single;
    if (file.size > maxBytes) {
      throw const FormatException('Backup file is too large.');
    }

    final bytes = file.bytes ?? await file.xFile.readAsBytes();
    if (bytes.length > maxBytes) {
      throw const FormatException('Backup file is too large.');
    }

    final String text;
    try {
      text = utf8.decode(bytes);
    } on FormatException {
      throw const FormatException('Backup file is not valid UTF-8 text.');
    }

    return BackupFileDocument(name: file.name, text: text);
  }
}
