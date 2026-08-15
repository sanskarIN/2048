import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nova_2048/core/localization/nova_localizations.dart';

void main() {
  test('Hindi catalog covers file-based Game Backup actions and errors', () {
    const l10n = NovaLocalizations(Locale('hi'));
    const strings = <String>[
      'Save backup file',
      'Import backup file',
      '• File size is bounded before UTF-8 and JSON decoding.',
      'Game backup file saved.',
      'Backup file export cancelled.',
      'Could not save backup file.',
      'Could not open backup file.',
      'Backup file is too large.',
      'Backup file is not valid UTF-8 text.',
    ];

    for (final english in strings) {
      expect(
        l10n.text(english),
        isNot(equals(english)),
        reason: 'Missing Hindi translation for: $english',
      );
    }
  });
}
