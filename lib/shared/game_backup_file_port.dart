import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';

enum BackupFileSaveOutcome { saved, cancelled }

class BackupFileDocument {
  const BackupFileDocument({required this.name, required this.text});

  final String name;
  final String text;
}

/// Explicit user-selected transport for portable current-game backup text.
///
/// Selecting a path or receiving a platform document grant does not make the
/// file contents trusted. Callers must still pass imported text through the
/// project-owned Game Backup codec before any state mutation and must preserve
/// the controller's persistent unranked-import policy.
abstract interface class GameBackupFilePort {
  Future<BackupFileSaveOutcome> saveText({
    required String suggestedName,
    required String text,
  });

  Future<BackupFileDocument?> openText({required int maxBytes});
}

/// Production file-picker adapter.
///
/// This class owns only platform/browser file transport and pre-decode byte
/// bounds. It does not parse game state, decide ranking, retain file history,
/// scan directories, or upload backup data.
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

    // file_picker 13.x exposes a dedicated single-document API. A grant to
    // open a user-selected file does not make its contents trusted.
    final file = await FilePicker.pickFile(
      dialogTitle: 'Open 2048 Nova game backup',
      type: FileType.custom,
      allowedExtensions: _extensions,
    );
    if (file == null) return null;

    // Reject reported oversized inputs before reading. For platforms that
    // cannot report a length, cap the streamed byte total as it arrives.
    final knownLength = file.lengthSync() ?? await file.length();
    if (knownLength != null && knownLength > maxBytes) {
      throw const FormatException('Backup file is too large.');
    }

    final builder = BytesBuilder(copy: false);
    await for (final chunk in file.readAsByteStream()) {
      if (chunk.length > maxBytes - builder.length) {
        throw const FormatException('Backup file is too large.');
      }
      builder.add(chunk);
    }
    final bytes = builder.takeBytes();

    final String text;
    try {
      text = utf8.decode(bytes);
    } on FormatException {
      throw const FormatException('Backup file is not valid UTF-8 text.');
    }

    return BackupFileDocument(name: file.name, text: text);
  }
}
