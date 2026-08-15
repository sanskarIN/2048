from pathlib import Path
import subprocess


def run(*args: str) -> None:
    subprocess.run(args, check=True)


def commit(path: str, message: str) -> None:
    run('git', 'add', path)
    run('git', 'commit', '-m', message)


run('git', 'config', 'user.name', 'Sanskar')
run('git', 'config', 'user.email', 'sanskarin@outlook.in')

# 1. Wire the reusable QR renderer into generated Challenge Codes.
p = Path('lib/features/challenge_codes/challenge_code_screen.dart')
s = p.read_text()
import_needle = "import '../../shared/text_clipboard.dart';\n"
assert import_needle in s
s = s.replace(import_needle, import_needle + "\nimport 'challenge_code_qr.dart';\n", 1)
button_needle = """                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: _copyGeneratedCode,"""
assert button_needle in s
qr_block = """                    const SizedBox(height: 12),
                    Text(
                      l10n.text('Scan to share'),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    ChallengeCodeQr(
                      code: _generatedCode!,
                      semanticsLabel: l10n.text(
                        'QR code containing this challenge code',
                      ),
                      errorLabel: l10n.text('Unable to render QR code.'),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.text(
                        'The QR code contains the same plain NOVA1 text shown above. It does not add identity, authentication, or cloud transfer.',
                      ),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: _copyGeneratedCode,"""
s = s.replace(button_needle, qr_block, 1)
p.write_text(s)
commit(str(p), 'feat: show QR for generated Challenge Codes')

# 2. Hindi localization for the new QR surface.
p = Path('lib/core/localization/hindi_translations.dart')
s = p.read_text()
needle = "  'Copy challenge code': 'चैलेंज कोड कॉपी करें',\n"
assert needle in s
addition = """  'Scan to share': 'स्कैन करके साझा करें',
  'QR code containing this challenge code':
      'इस चैलेंज कोड वाला QR कोड',
  'Unable to render QR code.': 'QR कोड नहीं बनाया जा सका।',
  'The QR code contains the same plain NOVA1 text shown above. It does not add identity, authentication, or cloud transfer.':
      'QR कोड में ऊपर दिखाया गया वही साधारण NOVA1 टेक्स्ट है। यह पहचान, प्रमाणीकरण या क्लाउड ट्रांसफर नहीं जोड़ता।',
"""
s = s.replace(needle, needle + addition, 1)
p.write_text(s)
commit(str(p), 'feat: localize Challenge Code QR sharing')

# 3. Screen-level QR and Hindi behavior regression coverage.
p = Path('test/challenge_code_screen_test.dart')
s = p.read_text()
import_needle = "import 'package:nova_2048/shared/text_clipboard.dart';\n"
assert import_needle in s
s = s.replace(import_needle, import_needle + "import 'package:qr_flutter/qr_flutter.dart';\n", 1)
pump_needle = """    int Function()? seedFactory,
  }) async {"""
assert pump_needle in s
s = s.replace(pump_needle, """    int Function()? seedFactory,
    Locale? locale,
  }) async {""", 1)
app_needle = """      localizedTestApp(
        routes:"""
assert app_needle in s
s = s.replace(app_needle, """      localizedTestApp(
        locale: locale,
        routes:""", 1)
test_needle = """    await tapVisible(tester, find.text('Generate new seeded code'));
    await tapVisible(tester, find.text('Copy challenge code'));

    expect(clipboard.text, isNotNull);
    final config = ChallengeCode.decode(clipboard.text!);"""
assert test_needle in s
replacement = """    await tapVisible(tester, find.text('Generate new seeded code'));

    final expectedCode = ChallengeCode.encode(
      ChallengeCode.withSeed(GameConfig.preset(GameMode.classic), 24680),
    );
    expect(find.byType(QrImageView), findsOneWidget);
    final qr = tester.widget<QrImageView>(find.byType(QrImageView));
    expect(qr.data, expectedCode);
    expect(qr.backgroundColor, Colors.white);
    expect(qr.semanticsLabel, 'QR code containing this challenge code');

    await tapVisible(tester, find.text('Copy challenge code'));
    expect(clipboard.text, expectedCode);
    final config = ChallengeCode.decode(clipboard.text!);"""
s = s.replace(test_needle, replacement, 1)
marker = """  testWidgets('pastes validates and starts the same seeded challenge',
"""
assert marker in s
hindi_test = """  testWidgets('generated Challenge Code QR is localized in Hindi',
      (tester) async {
    final controller = AppController(store: LocalStore());
    final clipboard = _MemoryClipboard();
    await controller.initialize();

    await pumpScreen(
      tester,
      controller,
      clipboard,
      seedFactory: () => 13579,
      locale: const Locale('hi'),
    );
    await tapVisible(tester, find.text('नया सीडेड कोड बनाएँ'));

    expect(find.text('स्कैन करके साझा करें'), findsOneWidget);
    final qr = tester.widget<QrImageView>(find.byType(QrImageView));
    expect(qr.semanticsLabel, 'इस चैलेंज कोड वाला QR कोड');
    expect(controller.game, isNull);
  });

"""
s = s.replace(marker, hindi_test + marker, 1)
p.write_text(s)
commit(str(p), 'test: cover Challenge Code QR sharing')

# 4. Resolve and lock the pure-Dart/Flutter QR dependency.
run('flutter', 'pub', 'get')
run('git', 'checkout', '--', 'analysis_options.yaml')
commit('pubspec.lock', 'build: lock offline QR dependency')

# 5. Keep repository formatting canonical.
run('dart', 'format', 'lib', 'test')
status = subprocess.run(
    ['git', 'diff', '--quiet', '--', 'lib', 'test'],
    check=False,
).returncode
if status != 0:
    run('git', 'add', 'lib', 'test')
    run('git', 'commit', '-m', 'style: format Challenge Code QR sources')

# 6. Focused gate before pushing the generated commits.
run(
    'flutter',
    'test',
    'test/challenge_code_test.dart',
    'test/challenge_code_screen_test.dart',
)
