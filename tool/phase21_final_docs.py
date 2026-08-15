from pathlib import Path
import subprocess


def run(*args: str) -> None:
    subprocess.run(args, check=True)


def commit_file(path: str, message: str) -> None:
    run('git', 'add', path)
    run('git', 'commit', '-m', message)


def prepend_before(path: str, marker: str, block: str, message: str) -> None:
    p = Path(path)
    text = p.read_text()
    if block.strip().splitlines()[0] in text:
        return
    assert marker in text, f'marker missing in {path}: {marker!r}'
    text = text.replace(marker, block.rstrip() + '\n\n' + marker, 1)
    p.write_text(text)
    commit_file(path, message)


def append_block(path: str, heading: str, body: str, message: str) -> None:
    p = Path(path)
    text = p.read_text()
    if heading in text:
        return
    text = text.rstrip() + '\n\n' + heading + '\n\n' + body.strip() + '\n'
    p.write_text(text)
    commit_file(path, message)


run('git', 'config', 'user.name', 'Sanskar')
run('git', 'config', 'user.email', 'sanskarin@outlook.in')

# Canonical verification: Phase 21 becomes the first/current maintained evidence.
verification = """## Phase 21 — Offline Challenge Code QR rendering and current-source matrix

Date: **2026-08-15**

Final accepted runtime source:

```text
Commit: 2678e65824ca088c4ba93342bc8737fc18ec7708
CI run: 31877515001
CI job: 94995319221
Result: SUCCESS
Runner: Ubuntu 24.04
Flutter: 3.47.0 stable
Dart: 3.13.0
DevTools: 2.60.0
Formatting: PASS — 94 files, 0 changed
Static analysis: PASS — No issues found
Tests: PASS — 194/194
Web release: PASS — build/web
Web WASM dry run: PASS
```

Fresh hosted native matrix on the same source:

```text
Platform Builds run: 31877514960
Result: SUCCESS
Android release APK: PASS — job 94995348734
Linux release: PASS — job 94995348682
Windows release: PASS — job 94995348743
macOS release: PASS — job 94995348674
unsigned iOS release: PASS — job 94995348674
```

Phase 21 adds presentation-only, offline QR rendering for the exact existing `NOVA1` Challenge Code text. It does not add in-app scanning, camera permission, networking, cloud transfer, a second portable protocol, or any trusted-progress path. The project keeps selectable/copyable text next to the QR, uses fixed black-on-white scan contrast, caps normal QR size at 260 logical pixels, respects narrower parent constraints, and localizes QR semantics/trust copy in English/Hindi.

Phase 21 adds five net tests to the Phase 20 total of 189. The first source-freeze CI `31877417527` failed at formatting because Dart 3.13 identified 32 existing/new source-test files requiring canonical formatting. Maintained formatter run `31877417558`, job `94995089435`, created `03f26863462609b3b7ff33b0bce81640580fbe18`; the final meaningful source trigger `2678e658...` then passed all permanent gates.

The existing non-fatal Cupertino icon-font availability warning remained visible during Web compilation while `build/web` completed successfully. Hosted compilation does not replace optical QR scanning, physical-device/accessibility, signing/provisioning, or store qualification.

Focused details: [`PHASE_21_VERIFICATION.md`](PHASE_21_VERIFICATION.md).
"""
prepend_before(
    'docs/VERIFICATION.md',
    '## Phase 20 - File-Based Game Backup and current-source plugin matrix',
    verification,
    'docs: make Phase 21 canonical verification current',
)

append_block(
    'docs/TESTING.md',
    '## Phase 21 final maintained gate',
    """The final Phase 21 runtime candidate is `2678e65824ca088c4ba93342bc8737fc18ec7708`.

```text
CI run: 31877515001
CI job: 94995319221
Flutter: 3.47.0 stable
Dart: 3.13.0
DevTools: 2.60.0
Formatting: PASS — 94 files, 0 changed
Static analysis: PASS — No issues found
Tests: PASS — 194/194
Web release: PASS
Web WASM dry run: PASS
```

Five Phase 21 regressions were added over the Phase 20 total of 189: Hindi generated-QR screen behavior, exact QR payload handoff, the 260-logical-pixel maximum, narrow-layout containment, and Hindi QR trust/accessibility catalog coverage. Existing Challenge Code codec, replacement, clipboard/manual-entry, deterministic-seed, malformed-input, Daily-isolation, persistence, replay, backup, solver, accessibility, and localization tests remain part of the 194-test gate.

The earlier final-source CI `31877417527` is retained as a formatting failure, not a behavioral pass. It reported 32 files requiring Dart 3.13 canonical formatting. Maintained formatter run `31877417558` normalized that tree before the final accepted CI.

Automated widget tests verify payload/constraints/semantics but do not prove optical scan performance. Real screens and external camera/scanner apps remain a manual release requirement.""",
    'docs: record Phase 21 final testing gate',
)

append_block(
    'docs/PLATFORMS.md',
    '## Phase 21 current native matrix',
    """The final Phase 21 runtime source `2678e65824ca088c4ba93342bc8737fc18ec7708` passed the permanent Platform Builds workflow:

```text
Platform Builds run: 31877514960
Android release APK: PASS — job 94995348734
Linux release: PASS — job 94995348682
Windows release: PASS — job 94995348743
macOS release: PASS — job 94995348674
unsigned iOS release: PASS — job 94995348674
```

This verifies that the pinned local QR-rendering dependency compiles across all configured native target families. No camera permission or native QR-scanner integration is introduced. The QR remains a Flutter presentation layer over the existing Challenge Code text.

Native compilation is not optical scan qualification. Representative real displays still need device-to-device scan checks across density, brightness, glare, orientation, surrounding theme, large-text layouts, and screen-reader behavior.""",
    'docs: record Phase 21 native matrix',
)

append_block(
    'docs/CI_CD.md',
    '## Phase 21 accepted workflow evidence',
    """Phase 21 final source `2678e65824ca088c4ba93342bc8737fc18ec7708` is covered by both permanent acceptance workflows.

```text
CI run: 31877515001
CI job: 94995319221
Result: SUCCESS
Formatting: 94 files, 0 changed
Analyzer: No issues found
Tests: 194/194
Web release: PASS
WASM dry run: PASS

Platform Builds run: 31877514960
Android: PASS — 94995348734
Linux: PASS — 94995348682
Windows: PASS — 94995348743
macOS + unsigned iOS: PASS — 94995348674
```

The first final-source CI `31877417527` failed the formatter and is intentionally retained in the record. The maintained formatter workflow `31877417558` corrected the repository-wide Dart formatting drift before the final source trigger. Temporary Phase 21 implementation/product-copy/documentation helpers were removed after use and are not permanent CI infrastructure.""",
    'docs: record Phase 21 workflow evidence',
)

append_block(
    'docs/RELEASE_CHECKLIST.md',
    '## Phase 21 automated acceptance and remaining manual checks',
    """Automated Phase 21 acceptance is complete on source `2678e65824ca088c4ba93342bc8737fc18ec7708`: CI `31877515001` passed formatting, analysis, 194/194 tests, Web release, and WASM dry run; Platform Builds `31877514960` passed Android, Linux, Windows, macOS, and unsigned iOS.

Before stable `1.0.0`, manually verify the QR on representative physical/real displays using external camera/scanner applications. Confirm exact `NOVA1` text recovery, practical scan reliability across brightness/glare/density/orientation, fixed black-on-white QR presentation inside light/dark themes, large-text/narrow-layout behavior, screen-reader semantics, and the selectable/copyable/manual text fallback. Confirm 2048 Nova requests no camera permission for rendering and that scanned text still enters the ordinary Challenge Code validation/replacement flow.

All earlier physical-device lifecycle/gameplay, clipboard/platform handler, Game Backup file/document provider, replay, accessibility, native branding, signing/provisioning/notarization, and store/package review checks remain required. Automated completion does not authorize a stable-release promotion by itself.""",
    'docs: record Phase 21 release acceptance boundary',
)

# Add verification link to documentation index.
p = Path('docs/README.md')
text = p.read_text()
if 'PHASE_21_VERIFICATION.md' not in text:
    text = text.rstrip() + "\n\n## Phase 21 verification\n\n- [`PHASE_21_VERIFICATION.md`](PHASE_21_VERIFICATION.md) — focused implementation, helper-failure, formatter, 194-test CI, native-build, QR trust/privacy/accessibility, and manual optical-scan qualification evidence for offline Challenge Code QR rendering.\n"
    p.write_text(text)
    commit_file('docs/README.md', 'docs: index Phase 21 verification record')

append_block(
    'CHANGELOG.md',
    '## Phase 21 final verification evidence',
    """The completed offline Challenge Code QR feature is accepted on runtime source `2678e65824ca088c4ba93342bc8737fc18ec7708`.

```text
CI 31877515001 / job 94995319221: SUCCESS
94 files formatted, 0 changed
Analyzer: No issues found
Tests: 194/194
Web release + WASM dry run: PASS

Platform Builds 31877514960: SUCCESS
Android 94995348734: PASS
Linux 94995348682: PASS
Windows 94995348743: PASS
macOS + unsigned iOS 94995348674: PASS
```

The first final-source CI `31877417527` failed only the formatting gate because 32 files required current Dart formatting. Maintained formatter run `31877417558` produced commit `03f26863462609b3b7ff33b0bce81640580fbe18`; the final source trigger then passed all acceptance workflows. Real-device optical QR scanning and the existing manual release boundaries remain outstanding, so `1.0.0` is not promoted.""",
    'docs: record Phase 21 final verification in changelog',
)

# Full chronological work log requested by the project owner.
append_block(
    'what_changed.md',
    '# Phase 21 — Offline Challenge Code QR Rendering',
    r"""Date: **2026-08-15**

## Phase decision and guardrails

Phase 21 was selected from the optional roadmap work after Phase 20 because Challenge Codes already had a stable, deterministic, versioned `NOVA1` text protocol and could gain scan-friendly presentation without modifying the game engine, trusted player data, Daily Challenge rules, or portable-progress trust boundary.

The phase was deliberately limited to **QR rendering only**. The implemented design does not add in-app QR scanning, camera permission, microphone/location permission, a QR web service, analytics, cloud synchronization, an account, a new portable protocol, or a ranked/trusted import route. Another device may scan the displayed image using its own camera/scanner software, but resulting text must still pass the existing `ChallengeCode.decode()` path and normal recoverable-game replacement confirmation.

The QR encodes the exact same generated `NOVA1...` string shown as selectable/copyable text. The existing FNV-1a checksum remains accidental-corruption detection only. QR presentation does not make the code signed, encrypted, authenticated, identity-bound, anti-cheat protected, or proof that a sender played a particular game.

## Dependency and reusable renderer

Phase 21 added the pinned presentation dependency and reusable widget in separate commits:

```text
7443fc4124c4e2aacc722dabd0b0e6e8d0ff0307  build: add offline challenge QR renderer
c9753e76ef495dc006258d434b5a1311f56b2100  feat: add offline Challenge Code QR widget
```

`pubspec.yaml` pins:

```yaml
qr_flutter: 4.1.0
```

The resolved lockfile also contains the package's QR-encoding dependency. The application does not add a camera/scanner package for this phase.

`lib/features/challenge_codes/challenge_code_qr.dart` owns the presentation wrapper. Its responsibilities are intentionally narrow:

- receive an already-generated canonical Challenge Code string;
- pass that exact string into `QrImageView`;
- use automatic QR version selection;
- render black data and eye modules on a white QR background;
- keep the QR presentation independent from the surrounding app theme for intended scan contrast;
- expose a localized semantic label;
- expose a local error-state message if rendering fails;
- use a `RepaintBoundary` around the visual QR surface;
- have no `AppController`, persistence, clipboard, networking, camera, statistics, achievements, Daily history, or trusted-progress dependency.

## First temporary implementation helper failure

The initial staging commit was:

```text
be5664ecc210b37b18ce46501215a2f6c21bb2c5
chore: stage Phase 21 implementation commits
```

Workflow run:

```text
31876872179
```

The temporary workflow did not produce usable implementation jobs/source commits. It was not treated as successful implementation evidence. The failed helper was removed in:

```text
41bb6a3804627b438eaeb2795618bfb88c76f6b3
chore: remove failed Phase 21 implementation helper
```

The remaining implementation was redesigned around a simpler temporary Python updater and focused test gate.

## Second helper attempt — test API mismatch

Temporary implementation staging used:

```text
1f1196a4f4750b46950931dc3365dd59641f270a  script staging
e26676b4aaa73b1cb567c1c802c996b7bbef4edc  workflow staging
```

Workflow evidence:

```text
Run: 31876914197
Job: 94993915532
Result: FAILURE
```

The failure was test-only. The first regression tried to read `QrImageView.data` after construction. `qr_flutter 4.1.0` accepts `data` in the constructor but does not expose that value through a public `data` getter. Production QR behavior was not weakened or changed merely to satisfy the test.

The regression contract was corrected in:

```text
989b2d41b7506bc13a2c143043213c2d09122207
fix: assert QR payload through project widget
```

The exact portable payload is instead asserted through the project-owned `ChallengeCodeQr.code` field, while package-public QR presentation properties remain tested separately.

## Third helper attempt — implementation/tests green, synchronization failed

Retry staging:

```text
071694bc058ee5e28dddb01499caad1a84fcc8cf
```

Workflow:

```text
Run: 31876990559
Job: 94994098270
Focused Challenge Code tests: 15/15 PASS
Final workflow result: FAILURE during synchronization
```

The implementation itself passed the focused gate. The final `git pull --rebase` step failed because Flutter had rewritten `analysis_options.yaml` in the runner workspace, leaving an unstaged edit. The generated source commits therefore remained runner-local and were not represented as published `main` history.

A synchronization-specific fix followed:

```text
605a9c1c036b569d6fe2e35fec6ea4fb48095cfb
fix: reset Flutter migration before Phase 21 sync
```

## Fourth helper attempt — focused gate still green, generated workspace noise still blocked rebase

Workflow evidence:

```text
Run: 31877037878
Job: 94994207117
Focused Challenge Code tests: 15/15 PASS
Final workflow result: FAILURE during synchronization
```

The QR source/tests remained green, but other generated workspace edits still made the rebase-based synchronization fragile. The final helper was simplified so the already-tested commits could fast-forward directly from the current `main` checkout. Generated workspace noise would be discarded only after the source commits were safely published.

Final synchronization change:

```text
226a577e70e416b8dd09bc220eaa69d174bfefed
fix: fast-forward Phase 21 generated commits
```

## Successful implementation publication

The final temporary implementation helper completed successfully:

```text
Run: 31877104598
Job: 94994366934
Result: SUCCESS
Focused Challenge Code tests: 15/15 PASS
```

It published separate logical commits including:

```text
609d88698318f58a7b2bba0dffc6f9691398c56a  feat: show QR for generated Challenge Codes
58a2807f689c052ea6f6b93f379995f11129efba  feat: localize Challenge Code QR sharing
a3f2305df0621b768f605a706ee4b97518b30403  test: cover Challenge Code QR sharing
7476461b9ae2fcbe9c7ae3adcbe87967bd737b60  build: lock offline QR dependency
f7254cbb86d21b3766f7ff440c5824d18f6b0496  style: format Challenge Code QR sources
02030d5f250424c4aa39e02bc85dcba59fec72da  chore: remove Phase 21 implementation tools
```

The generated-code panel now presents:

- the original selectable `NOVA1` text;
- a localized **Scan to share** heading;
- the local QR carrying exactly that text;
- a localized screen-reader semantic label;
- a localized render-error fallback;
- explicit trust copy stating that the QR adds no identity, authentication, or cloud transfer;
- the original **Copy challenge code** flow.

Manual entry, paste, validation, decoded preview, replacement protection, and game start behavior remain unchanged.

## Responsive-layout correction discovered during component audit

After the initial screen integration was published, a component audit found a genuine layout edge case: the first reusable QR wrapper enforced a 180-logical-pixel minimum even when a parent constraint could be narrower than 180 pixels. That could force horizontal overflow in unusually constrained environments.

The production fix is:

```text
be553b2100a6171c4c149a6832b4c8d75ae90546
fix: keep Challenge QR within narrow layouts
```

The renderer now derives its size from the actual bounded parent width and caps it at 260 logical pixels:

```text
bounded width -> min(parent width, 260)
unbounded width -> 260
```

There is no artificial minimum larger than the parent.

Dedicated component coverage was added in:

```text
61177f11948f0c0a603891813fcc2f0a1eca9457
test: cover Challenge Code QR component
```

The component tests independently verify exact project-wrapper payload handoff, the fixed white QR background and semantic label, the 260-logical-pixel maximum, narrow-width containment, and absence of overflow exceptions.

## Product copy, localization, and trust guidance

The Guide and About surfaces were then synchronized with the actual Phase 21 behavior. Guide copy now explains that:

- the generated QR is local;
- it contains the exact same Challenge Code text;
- another device may use its own external camera/scanner;
- 2048 Nova itself does not request camera permission or upload QR contents;
- QR form does not authenticate a Challenge Code;
- selectable text remains available so visual scanning is never the only sharing path.

About release highlights now include local Challenge Code QR rendering.

The English/Hindi localization catalog covers the QR heading, semantic label, render failure, trust disclosure, Guide privacy/accessibility content, and About release-highlight text. The portable `NOVA1` payload itself remains language-neutral and is never translated.

Product-copy helper evidence:

```text
Run: 31877255494
Job: 94994722496
Result: SUCCESS
```

Known separate product-copy commits include:

```text
ca8cd980f1904660a250c1c20f17e9521d6ce15a  docs: explain Challenge Code QR in guide
142574937b682b6ab0a430728a21f32eaf368436  docs: add Challenge Code QR to release highlights
```

The helper also produced separate Hindi guidance and focused localization-test commits before removing its temporary tools.

## Phase 21 net test additions

Phase 20 ended at 189 tests. Phase 21 adds five net new regressions:

1. a generated Challenge Code QR is localized in Hindi;
2. the project QR wrapper receives the exact portable Challenge Code text;
3. wide layouts cap the QR renderer at 260 logical pixels;
4. narrow layouts never force the QR beyond the available width;
5. the Hindi catalog covers QR trust/accessibility guidance.

The final maintained suite therefore contains **194 tests**.

These new checks complement, rather than replace, existing Challenge Code tests for every supported mode, deterministic encoding, same-seed opening state, Daily exclusion, checksum tampering, malformed structure, oversized input, unsafe seed bounds, clipboard flows, invalid-code rejection, and recoverable-game replacement cancellation.

## Full documentation synchronization

A dedicated documentation helper updated the complete affected documentation surface with one logical commit per document.

Workflow evidence:

```text
Run: 31877375454
Job: 94994996845
Result: SUCCESS
Cleanup commit: 844ed15180402b8f609e20c9c3f816e71ebef96e
```

Updated documentation includes:

- `README.md`;
- `ROADMAP.md`;
- `CHANGELOG.md`;
- `docs/CHALLENGE_CODES.md`;
- `docs/DEPENDENCIES.md`;
- `docs/PRIVACY.md`;
- `docs/ACCESSIBILITY.md`;
- `SECURITY.md`;
- `docs/ARCHITECTURE.md`;
- `docs/DEVELOPMENT.md`;
- `docs/TESTING.md`;
- `docs/RELEASE_CHECKLIST.md`;
- `docs/PLATFORMS.md`;
- `docs/CI_CD.md`;
- `docs/USER_GUIDE.md`;
- `docs/FAQ.md`;
- `docs/TROUBLESHOOTING.md`;
- `CONTRIBUTING.md`;
- `docs/README.md`;
- `docs/LOCALIZATION.md` where present.

Representative documentation commits include:

```text
1c9e586f365dc963e4c1b29f39b729d18266af43  docs: document offline Challenge Code QR sharing
9808e0421987027d60adf9572e219094a271ce61  docs: mark Challenge Code QR rendering complete
700a60c1dfa5253cec05d7c90595ca185c828152  docs: extend Challenge Code specification for QR
028f55468c38d9bc929031b674200f08d8c95017  docs: codify Challenge Code QR trust boundary
650d1233823f439d91965c7866d76d52b9b73d48  docs: document Challenge Code QR privacy
8d1cd30e9cf22c0e64dcd4614e7342ef48b91403  docs: document Challenge Code QR accessibility
d6ab58fde14d3faff6564cc73833285978a50dad  docs: add Challenge Code QR development guidance
157cc45e84fb9d9afaa7988146324998c46f5ebc  docs: add Challenge Code QR release gate
92ca1cd45d12b295c55a9fc8dcafdd7dbf2c4dcc  docs: add Challenge Code QR contribution guardrails
1e91beadaea3dd0dcc569f3669b368335b3bae04  docs: add Challenge Code QR FAQ
598c739ccaef22d6b11b78fe53fc58c59ed23e8e  docs: add Challenge Code QR troubleshooting
1ce0e5417a20462cb31a6b005bf1b0fe95b10606  docs: index Challenge Code QR documentation
142d6e89bac6eac2b000337737540f04e170aaf5  docs: document Challenge Code QR localization
```

The documentation pass removed stale claims that Challenge Codes required no QR/runtime package. The repository now accurately distinguishes:

- the existing project-owned Challenge Code **codec/trust model**, which remains offline and unchanged; from
- the new pinned `qr_flutter` **presentation layer**, which locally renders the exact existing text.

The roadmap now marks QR rendering as implemented. Any future in-app scanner remains a separate optional feature because it would introduce camera permissions and materially different privacy/platform/accessibility costs.

## First final-source verification failure — canonical formatting drift

After production, tests, localization, and documentation were complete, a real `lib/**` source-contract commit was used to freeze and qualify the runtime:

```text
1ab945fa3d483090c5c8290e52331c237f86ca5c
docs: clarify Challenge QR trust boundary in source
```

Permanent CI:

```text
Run: 31877417527
Job: 94995089241
Result: FAILURE at formatting
Files checked: 94
Files requiring formatting: 32
```

The formatter identified broad Dart 3.13 canonical formatting drift across both existing and Phase 21 `lib/`/`test/` files. Analyzer, tests, and Web were not treated as acceptance evidence from this run because the maintained formatting gate correctly stopped first.

The dedicated formatter workflow was allowed to normalize the complete current tree rather than hand-editing or ignoring those files:

```text
Formatter run: 31877417558
Formatter job: 94995089435
Result: SUCCESS
Commit: 03f26863462609b3b7ff33b0bce81640580fbe18
Message: style: format Dart sources and tests
```

The formatter commit contains repository-wide canonical formatting only. Because the formatter's token-authenticated push did not fan out the normal CI/native workflows, a final meaningful source-contract clarification was added to the already-formatted QR wrapper:

```text
2678e65824ca088c4ba93342bc8737fc18ec7708
docs: codify Challenge QR scan contrast in source
```

That source contract explicitly records that the QR remains black-on-white regardless of surrounding app theme so application presentation styling cannot reduce the intended scan contrast.

## Final accepted Phase 21 CI

The final runtime source is:

```text
2678e65824ca088c4ba93342bc8737fc18ec7708
```

Permanent CI evidence:

```text
CI run: 31877515001
CI job: 94995319221
Result: SUCCESS
Runner: Ubuntu 24.04
Flutter: 3.47.0 stable
Dart: 3.13.0
DevTools: 2.60.0
Formatting: PASS — 94 files, 0 changed
Static analysis: PASS — No issues found
Tests: PASS — 194/194
Web release: PASS — build/web
Web WASM dry run: PASS
```

The final Web build continues to show the existing non-fatal Cupertino icon-font availability warning while successfully creating `build/web`. Phase 21 does not make a speculative Cupertino dependency change merely to silence a successful-build warning unrelated to QR rendering.

## Final accepted Phase 21 native matrix

The same final runtime commit passed the complete permanent native build matrix:

```text
Platform Builds run: 31877514960
Result: SUCCESS
Android release APK: PASS — job 94995348734
Linux release: PASS — job 94995348682
Windows release: PASS — job 94995348743
macOS release: PASS — job 94995348674
unsigned iOS release: PASS — job 94995348674
```

This verifies compilation of the completed QR-rendering dependency and runtime source across all configured native target families. It does not claim optical QR scan performance on real screens.

## Final Phase 21 verification records

Focused permanent evidence was added in:

```text
docs/PHASE_21_VERIFICATION.md
```

Canonical verification, testing, platform, CI/CD, release-checklist, changelog, and documentation-index records were then synchronized with the exact final run/job IDs. The final documentation commits do not alter the runtime source qualified by `2678e658...`.

## Remaining stable-release boundary

Phase 21 automated/source qualification is complete, but stable `1.0.0` remains intentionally unpromoted.

Phase 21 still requires manual real-environment checks for:

- device-to-device scanning of the displayed QR with external camera/scanner applications;
- exact recovery of the visible/selectable `NOVA1...` text;
- representative display density and optical focus behavior;
- practical brightness, glare, orientation, and viewing-distance conditions;
- light/dark surrounding themes while the QR itself remains fixed black-on-white;
- large text, narrow layouts, high contrast, keyboard/focus, and screen-reader semantics;
- selectable/copyable/manual Challenge Code text as a fully usable fallback;
- confirmation that QR rendering never requests camera permission;
- confirmation that externally scanned text still passes the ordinary Challenge Code decoder, validation feedback, decoded preview, and game-replacement guard.

All previous manual release requirements also remain outstanding: real Android/iOS gameplay and lifecycle/save-resume, long-session Daily/timed/move-limit/Undo/win-continue behavior, real clipboard/browser handlers, Game Backup file/document-provider behavior, Move Replay and Full Replay Archive interaction/accessibility/performance, external browser/email handlers, native splash/icon review, signing/provisioning/notarization, and final store/package metadata/review.

Hosted formatter/analyzer/tests/Web/native builds are strong automated evidence but are not a substitute for those physical-device, assistive-technology, optical, signing, and distribution checks.""",
    'docs: record complete Phase 21 implementation log',
)
