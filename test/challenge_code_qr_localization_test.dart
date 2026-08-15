import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nova_2048/core/localization/nova_localizations.dart';

void main() {
  test('Hindi catalog covers Challenge Code QR trust and accessibility copy', () {
    const l10n = NovaLocalizations(Locale('hi'));

    expect(l10n.text('Scan to share'), 'स्कैन करके साझा करें');
    expect(
      l10n.text('QR code containing this challenge code'),
      'इस चैलेंज कोड वाला QR कोड',
    );
    expect(l10n.text('Unable to render QR code.'), 'QR कोड नहीं बनाया जा सका।');
    expect(
      l10n.text(
        'The QR code contains the same plain NOVA1 text shown above. It does not add identity, authentication, or cloud transfer.',
      ),
      contains('NOVA1'),
    );
    expect(
      l10n.text(
        'Core gameplay, Challenge Code text/QR generation, Game Backup validation, Move Replay, Full Replay Archive, Auto Play Demo, and language switching work without a project server. QR rendering is local and does not request camera access. No account, analytics, advertising tracker, remote AI service, cloud synchronization, or online translation service is required. Clipboard text is read or written only after you choose the corresponding Challenge Code, Game Backup, or Full Replay Archive action.',
      ),
      isNot(contains('Core gameplay')),
    );
  });
}
