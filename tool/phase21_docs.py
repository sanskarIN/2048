from pathlib import Path
import subprocess


def run(*args: str) -> None:
    subprocess.run(args, check=True)


def write_commit(path: str, text: str, message: str) -> None:
    p = Path(path)
    p.write_text(text)
    run('git', 'add', path)
    run('git', 'commit', '-m', message)


def append_section(path: str, heading: str, body: str, message: str) -> None:
    p = Path(path)
    text = p.read_text()
    if heading in text:
        return
    text = text.rstrip() + '\n\n' + heading + '\n\n' + body.strip() + '\n'
    write_commit(path, text, message)


run('git', 'config', 'user.name', 'Sanskar')
run('git', 'config', 'user.email', 'sanskarin@outlook.in')

# README
p = Path('README.md')
s = p.read_text()
s = s.replace(
    'offline shareable seeded Challenge Codes, portable current-game backup/restore,',
    'offline shareable seeded Challenge Codes with local QR rendering, portable current-game backup/restore,',
    1,
)
s = s.replace(
    '- Offline **Challenge Codes** that share a supported deterministic game configuration/seed as checksummed `NOVA1...` text without accounts or cloud synchronization.',
    '- Offline **Challenge Codes** that share a supported deterministic game configuration/seed as checksummed `NOVA1...` text plus a local black-on-white QR containing the exact same text, without accounts, camera permission, or cloud synchronization.',
    1,
)
needle = 'The checksum detects accidental corruption; it is not encryption, authentication, identity proof, or an anti-cheat mechanism.\n'
assert needle in s
qr_para = '\nGenerated codes are also rendered locally as a high-contrast QR containing the exact same `NOVA1` text. 2048 Nova does not scan QR codes, request camera permission, or upload QR contents; another device may scan the displayed code using its own camera/scanner application, and the selectable/copyable text remains the fallback.\n'
s = s.replace(needle, needle + qr_para, 1)
s = s.replace(
    '- `file_picker` — explicit user-selected Game Backup file save/open transport across configured Flutter targets.\n- `shared_preferences`',
    '- `file_picker` — explicit user-selected Game Backup file save/open transport across configured Flutter targets.\n- `qr_flutter` — offline presentation-only QR rendering for the exact existing Challenge Code text; no camera/scanner or network service.\n- `shared_preferences`',
    1,
)
s = s.replace(
    'Challenge Codes use Dart JSON/Base64URL and the existing Flutter clipboard abstraction.',
    'Challenge Code encoding/validation uses Dart JSON/Base64URL and the existing Flutter clipboard abstraction; generated-code presentation additionally uses pinned `qr_flutter 4.1.0` for local rendering only.',
    1,
)
write_commit('README.md', s, 'docs: document offline Challenge Code QR sharing')

# Roadmap
p = Path('ROADMAP.md')
s = p.read_text()
s = s.replace(
    '- Offline shareable seeded **Challenge Codes** with a versioned `NOVA1` format, deterministic config/seed round trip, corruption checksum, strict input validation, manual/clipboard entry, decoded preview, replacement protection, and no account/cloud requirement.',
    '- Offline shareable seeded **Challenge Codes** with a versioned `NOVA1` format, deterministic config/seed round trip, corruption checksum, strict input validation, manual/clipboard entry, decoded preview, replacement protection, local high-contrast QR rendering of the exact code text, and no account/cloud/camera requirement.',
    1,
)
s = s.replace(
    '- Real-platform Challenge Code generate/copy/paste/manual-entry/validation/replacement/determinism/accessibility checks using actual clipboard/browser handlers.',
    '- Real-platform Challenge Code generate/QR-display/device-to-device scan/copy/paste/manual-entry/validation/replacement/determinism/accessibility checks using actual screens, external camera/scanner apps, and clipboard/browser handlers.',
    1,
)
s = s.replace(
    '- Optional QR rendering/scanning or OS share-sheet convenience for the already-implemented Challenge Code text format, only if cross-platform/privacy/accessibility costs are justified.',
    '- Optional **in-app QR scanning** or OS share-sheet convenience for the already-implemented Challenge Code text/QR format, only if camera permissions, cross-platform maintenance, privacy, and accessibility costs are justified. Local QR rendering itself is already implemented.',
    1,
)
write_commit('ROADMAP.md', s, 'docs: mark Challenge Code QR rendering complete')

# Changelog
p = Path('CHANGELOG.md')
s = p.read_text()
marker = '### Added\n'
assert marker in s
added = """- Offline high-contrast **Challenge Code QR rendering** using pinned `qr_flutter 4.1.0`; the QR contains the exact existing `NOVA1` text and adds no camera permission, scanner, account, cloud transfer, or authentication semantics.
- Responsive `ChallengeCodeQr` presentation with a 260-logical-pixel cap, narrow-layout containment, white background/black modules, semantic labeling, and local render-error fallback.
- Five focused Phase 21 QR regressions covering exact payload handoff, scan contrast/semantics, narrow/wide sizing, Hindi screen copy, and Hindi trust/accessibility guidance.
"""
s = s.replace(marker, marker + added, 1)
s = s.replace(
    '- Challenge Codes add no runtime dependency, account/cloud service, network requirement, persistence key, or record/progress import surface.',
    '- The Challenge Code **codec/trust model** still adds no account/cloud service, network requirement, persistence key, or record/progress import surface. Phase 21 adds only pinned `qr_flutter 4.1.0` for local presentation of the exact existing text; it does not add in-app scanning or camera permission.',
    1,
)
write_commit('CHANGELOG.md', s, 'docs: record Phase 21 QR feature in changelog')

# Challenge Code specification
p = Path('docs/CHALLENGE_CODES.md')
s = p.read_text()
s = s.replace(
    '4. Review the selectable generated code.\n5. Press **Copy challenge code** to write it to the clipboard.\n6. Share that text through a channel you choose.',
    '4. Review the selectable generated code and the local black-on-white QR that contains the exact same text.\n5. Another device may scan the displayed QR with its own camera/scanner app, or press **Copy challenge code** to write the text to the clipboard.\n6. Share only through a channel you choose; 2048 Nova itself does not request camera access, scan codes, upload the QR, or contact a sharing server.',
    1,
)
s = s.replace(
    '- `lib/features/challenge_codes/challenge_code_screen.dart`\n',
    '- `lib/features/challenge_codes/challenge_code_screen.dart`\n- `lib/features/challenge_codes/challenge_code_qr.dart`\n',
    1,
)
append = """The QR is a **presentation of the existing portable text**, not a second protocol. `ChallengeCodeQr` passes the exact generated string into `QrImageView` with automatic QR version selection, black data/eye modules, a white background, and a maximum 260 logical-pixel render size while respecting narrower constraints.

The app implements rendering only. It does not include a camera/scanning package or request camera permission. Scanning, when desired, is performed by another device/application and yields ordinary `NOVA1...` text that must still pass the same decoder/validation path before a challenge can start.

A QR image does not make a Challenge Code trusted. The FNV-1a checksum remains accidental-corruption detection only; neither the text nor QR proves authorship, identity, fairness, or authenticity.

Accessibility keeps the selectable text alongside the QR, provides a localized semantic label for the QR, and never makes visual scanning the only sharing route. Real-device qualification must still cover glare/brightness, screen density, large text, dark theme surrounding layout, screen readers, and device-to-device scanning with representative external camera/scanner apps.

Phase 21 focused automated coverage lives in `test/challenge_code_qr_test.dart`, `test/challenge_code_screen_test.dart`, and `test/challenge_code_qr_localization_test.dart`."""
if '## Offline QR rendering' not in s:
    s = s.rstrip() + '\n\n## Offline QR rendering\n\n' + append + '\n'
write_commit('docs/CHALLENGE_CODES.md', s, 'docs: extend Challenge Code specification for QR')

# Dependencies
p = Path('docs/DEPENDENCIES.md')
s = p.read_text()
insert_marker = '## Features that add no additional runtime package\n'
assert insert_marker in s
qr_section = """## qr_flutter

Pinned at **4.1.0** for Phase 21. It is used only to render the already-generated Challenge Code string as a local QR image. The project passes the exact `NOVA1...` text into the renderer; `qr_flutter` does not own Challenge Code encoding, checksum validation, game configuration parsing, trust policy, persistence, or networking.

The resolved lockfile also records the package's QR-encoding dependency. 2048 Nova does **not** add a QR scanner/camera package in Phase 21.

Why it is used:

- Flutter core does not include a QR encoder/renderer;
- local rendering avoids a network QR-generation service;
- the wrapper can enforce fixed scan contrast, responsive bounds, semantics, and a render-error fallback;
- rendering remains presentation-only and leaves the domain protocol unchanged.

It does not request camera permission, create an account, upload code contents, add analytics, or establish authenticity.

"""
s = s.replace(insert_marker, qr_section + insert_marker, 1)
old_block = """### Challenge Codes

Offline shareable seeded Challenge Codes use:

- `dart:convert` for JSON, UTF-8, and Base64URL;
- project-owned FNV-1a checksum logic;
- Flutter clipboard APIs through the existing `TextClipboard` abstraction;
- the existing `GameConfig` strict parser and deterministic game engine.

No QR package, networking package, account SDK, cloud service, cryptography package, database, file picker, or sharing SDK is required. The checksum is intentionally a corruption detector, not a cryptographic signature.
"""
new_block = """### Challenge Code codec

Offline shareable seeded Challenge Code **encoding and validation** use:

- `dart:convert` for JSON, UTF-8, and Base64URL;
- project-owned FNV-1a checksum logic;
- Flutter clipboard APIs through the existing `TextClipboard` abstraction;
- the existing `GameConfig` strict parser and deterministic game engine.

Phase 21 adds `qr_flutter` only in the feature presentation layer described above. No networking package, account SDK, cloud service, cryptography package, database, file picker, sharing SDK, or in-app QR scanner is required for Challenge Codes. The checksum remains a corruption detector, not a cryptographic signature.
"""
assert old_block in s
s = s.replace(old_block, new_block, 1)
write_commit('docs/DEPENDENCIES.md', s, 'docs: document QR rendering dependency boundary')

# Privacy
p = Path('docs/PRIVACY.md')
s = p.read_text()
needle = 'Challenge Code text is plain and not encrypted. Its checksum is only for accidental corruption detection. Share a code only through channels you choose and remember that the operating system/platform controls clipboard history and cross-device clipboard behavior.\n'
assert needle in s
qr_privacy = '\nThe generated code may also be rendered locally as a QR image containing the exact same plain text. Rendering does not upload the code, contact a QR service, read the camera, request camera permission, or create an additional Challenge Code history. If another device scans the screen, that external camera/scanner environment controls its own handling of the captured text.\n'
s = s.replace(needle, needle + qr_privacy, 1)
s = s.replace(
    '- `file_picker` for explicit user-selected Game Backup file save/open transport;\n- `shared_preferences`',
    '- `file_picker` for explicit user-selected Game Backup file save/open transport;\n- `qr_flutter` for local presentation-only Challenge Code QR rendering;\n- `shared_preferences`',
    1,
)
s = s.replace(
    "Challenge Codes use Dart JSON/Base64URL and Flutter's clipboard APIs through the local `TextClipboard` abstraction, so they add no third-party runtime package or network dependency.",
    "Challenge Code encoding/validation uses Dart JSON/Base64URL and Flutter's clipboard APIs through the local `TextClipboard` abstraction. Phase 21 additionally uses pinned `qr_flutter 4.1.0` for local rendering only; it adds no network dependency, camera permission, scanner, account, telemetry, or cloud transfer.",
    1,
)
write_commit('docs/PRIVACY.md', s, 'docs: document Challenge Code QR privacy')

# Accessibility
p = Path('docs/ACCESSIBILITY.md')
s = p.read_text()
s = s.replace(
    '- Challenge Codes use standard labeled form controls, selectable generated code text, explicit validation feedback, a decoded configuration preview, and the same recoverable-game replacement confirmation used by normal new-game flows.',
    '- Challenge Codes use standard labeled form controls, selectable generated code text, a localized semantic label for the high-contrast QR, explicit validation feedback, a decoded configuration preview, and the same recoverable-game replacement confirmation used by normal new-game flows.',
    1,
)
s = s.replace(
    '- copying a generated code;\n',
    '- a semantic black-on-white QR containing the same generated text;\n- copying a generated code;\n',
    1,
)
extra = """The QR is never the only sharing path: the exact text remains selectable/copyable. The renderer stays black-on-white regardless of surrounding theme for scan contrast, carries a localized semantic label, caps its normal size, and shrinks inside narrower constraints instead of forcing horizontal overflow.

The application does not provide in-app scanning, so no camera control or permission is introduced. Manual qualification must verify the QR and adjacent text with large text, high contrast, dark/light surrounding themes, keyboard traversal, TalkBack/VoiceOver/Narrator/browser screen readers, and real device-to-device scanning without making the visual QR the only understandable control."""
if '### Challenge Code QR accessibility' not in s:
    s = s.rstrip() + '\n\n### Challenge Code QR accessibility\n\n' + extra + '\n'
write_commit('docs/ACCESSIBILITY.md', s, 'docs: document Challenge Code QR accessibility')

# Security
append_section(
    'SECURITY.md',
    '## Challenge Code QR trust boundary',
    "A displayed Challenge Code QR is only another representation of the existing plain `NOVA1...` text. It does not provide authentication, identity, signing, encryption, anti-cheat protection, or proof that the sender played a particular game. The existing checksum remains accidental-corruption detection only.\n\n2048 Nova renders the QR locally and does not add camera permission or an in-app scanner. Text obtained by any external scanner must still pass the same strict Challenge Code decoder before a challenge can start. Security reports should treat QR parsing/rendering, decoder validation, and replacement protection as separate boundaries rather than assuming the image itself establishes trust.",
    'docs: codify Challenge Code QR trust boundary',
)

# Architecture
append_section(
    'docs/ARCHITECTURE.md',
    '## Phase 21 - Challenge Code QR presentation',
    "Phase 21 keeps QR rendering in `features/challenge_codes/` rather than moving it into the deterministic domain layer. `ChallengeCode.encode()` still produces the canonical portable string and `ChallengeCode.decode()` remains the only protocol-validation path. `ChallengeCodeQr` receives that already-generated string and renders it through `qr_flutter`; it has no `AppController`, persistence, clipboard, networking, or camera dependency.\n\nThis preserves a one-way boundary: domain configuration -> canonical `NOVA1` text -> optional visual QR. A scanned string re-enters through the existing manual/clipboard decoder path; the QR widget itself never creates trusted progress or bypasses replacement confirmation.",
    'docs: document QR presentation architecture',
)

# Development
append_section(
    'docs/DEVELOPMENT.md',
    '## Challenge Code QR development notes',
    "Phase 21 pins `qr_flutter 4.1.0`. Keep the QR wrapper presentation-only: do not move protocol logic into the package integration, do not add a network QR-generation endpoint, and do not add camera/scanner permissions unless a separately reviewed in-app scanning feature is intentionally designed.\n\nWhen changing the QR surface, run the Challenge Code codec/screen tests plus `test/challenge_code_qr_test.dart` and `test/challenge_code_qr_localization_test.dart`, then run the full formatter/analyzer/test/Web gate and configured native builds. Preserve fixed black-on-white QR contrast and narrow-layout containment unless real scan/accessibility evidence supports a deliberate change.",
    'docs: add Challenge Code QR development guidance',
)

# Testing
append_section(
    'docs/TESTING.md',
    '## Phase 21 Challenge Code QR coverage',
    "Phase 21 adds five focused tests over the Phase 20 total of 189, bringing the source suite definition to **194 tests** before the final maintained gate. Coverage includes exact canonical text handed to the project QR wrapper, white-background rendering/semantic labeling, a 260-logical-pixel maximum, narrow-layout containment, Hindi generated-QR UI, and Hindi QR trust/accessibility catalog copy.\n\nAutomated rendering/widget checks do not prove optical scan reliability. Stable qualification still requires representative real screens and external camera/scanner apps across brightness, glare, density, theme, orientation, and text-scale conditions.",
    'docs: document Phase 21 QR regression coverage',
)

# Release checklist
append_section(
    'docs/RELEASE_CHECKLIST.md',
    '## Phase 21 Challenge Code QR manual gate',
    "Before stable `1.0.0`, verify generated Challenge Code QR behavior on representative Android, iOS, Web, Windows, macOS, and Linux displays where practical. Check that the displayed QR decodes to the exact visible `NOVA1` text using external camera/scanner apps, remains readable under light/dark surrounding themes and practical brightness/glare conditions, does not overflow narrow layouts or clip adjacent large text, exposes understandable screen-reader semantics, and never requests camera permission.\n\nAlso confirm that QR-scanned text still goes through ordinary Challenge Code validation/replacement protection and that users can always fall back to selectable/copyable/manual text. Do not mark QR display as authentication or as an in-app scanning capability.",
    'docs: add Challenge Code QR release gate',
)

# Platforms
append_section(
    'docs/PLATFORMS.md',
    '## Phase 21 QR platform behavior',
    "Challenge Code QR rendering is a Flutter presentation feature and requires no target-specific camera permission or scanner integration. The same canonical text is rendered on every configured target, with a fixed black-on-white QR surface inside the surrounding themed UI.\n\nHosted compilation can verify that the dependency and widget compile across configured targets, but it cannot verify physical screen optical scan quality. Real-device/browser qualification remains required for device-to-device scanning, density/brightness/glare, accessibility, and narrow-layout behavior.",
    'docs: document QR behavior across platforms',
)

# CI/CD
append_section(
    'docs/CI_CD.md',
    '## Phase 21 QR verification path',
    "The normal CI gate covers QR Dart formatting, analyzer checks, the complete widget/unit suite, and the Web release/WASM dry run. Platform Builds must also compile the final runtime tree on Android, Linux, Windows, macOS, and unsigned iOS so the pinned QR package does not silently break a configured target.\n\nOptical scan testing remains manual and is not inferred from a successful build. Final Phase 21 run/job identifiers are recorded in `PHASE_21_VERIFICATION.md` and the canonical verification record after source freeze.",
    'docs: document Phase 21 QR CI path',
)

# User guide
append_section(
    'docs/USER_GUIDE.md',
    '## Sharing a Challenge Code by QR',
    "After choosing a supported mode and generating a seeded Challenge Code, 2048 Nova shows both the selectable `NOVA1...` text and a black-on-white QR containing exactly that text. Another device can scan the displayed QR with its own camera/scanner app, or you can use **Copy challenge code** and share the text normally.\n\n2048 Nova does not scan QR codes itself and does not need camera permission for this feature. Receiving/scanning a QR does not make a code trusted: validate/start it through the normal Challenge Codes screen, and remember that the checksum only detects accidental corruption.",
    'docs: add QR sharing to user guide',
)

# FAQ
append_section(
    'docs/FAQ.md',
    '## Does Challenge Code QR sharing need internet or camera permission?',
    "No. 2048 Nova generates the QR locally from the same `NOVA1...` text already shown on screen. The app does not request camera permission and does not include an in-app QR scanner in Phase 21. Another device may scan the displayed QR using its own camera/scanner app, or users can continue sharing the selectable/copyable text. QR form does not authenticate the sender or code.",
    'docs: add Challenge Code QR FAQ',
)

# Troubleshooting
append_section(
    'docs/TROUBLESHOOTING.md',
    '## A Challenge Code QR will not scan',
    "First use the selectable/copyable `NOVA1...` text as the reliable fallback. For optical scanning, keep the full white QR area visible, avoid covering/cropping it, increase practical screen brightness if needed, reduce glare, and give the external camera/scanner enough distance to focus. The surrounding app theme may be dark, but the QR itself intentionally remains black on white.\n\n2048 Nova does not contain an in-app scanner, so camera/scanner compatibility belongs to the receiving device/application. If scanned text is produced but 2048 Nova rejects it, use the normal validation message: the text must still satisfy prefix, checksum, payload, version, configuration, seed, and supported-mode checks.",
    'docs: add Challenge Code QR troubleshooting',
)

# Contributing
append_section(
    'CONTRIBUTING.md',
    '## Challenge Code QR changes',
    "Changes to QR rendering should keep the canonical Challenge Code protocol in project domain code, preserve selectable text as a non-visual fallback, avoid introducing camera/network permissions without explicit design review, and include focused widget/localization regressions. Dependency or rendering changes must pass the full CI gate and configured native build matrix before they are described as release-candidate ready.",
    'docs: add Challenge Code QR contribution guardrails',
)

# Documentation index: update Challenge Code description and dependency scope if the phrase exists, otherwise append a concise note.
p = Path('docs/README.md')
s = p.read_text()
if 'Challenge Code QR rendering' not in s:
    s = s.rstrip() + "\n\n## Phase 21 documentation note\n\nChallenge Code documentation now includes offline QR rendering of the exact `NOVA1` text, presentation/trust/privacy/accessibility boundaries, focused tests, and real-device scan qualification. See [`CHALLENGE_CODES.md`](CHALLENGE_CODES.md), [`ACCESSIBILITY.md`](ACCESSIBILITY.md), [`PRIVACY.md`](PRIVACY.md), [`DEPENDENCIES.md`](DEPENDENCIES.md), and the Phase 21 verification record once finalized.\n"
write_commit('docs/README.md', s, 'docs: index Challenge Code QR documentation')

# Optional localization doc if present.
if Path('docs/LOCALIZATION.md').exists():
    append_section(
        'docs/LOCALIZATION.md',
        '## Phase 21 QR localization',
        "English/Hindi localization covers the QR sharing heading, semantic label, render-error fallback, trust disclosure, Guide accessibility/privacy copy, and About release-highlight text. The QR payload itself is the canonical language-neutral `NOVA1...` code and must not be translated or modified by the localization layer.",
        'docs: document Challenge Code QR localization',
    )
