from pathlib import Path
import subprocess


def commit_file(path: str, message: str) -> None:
    subprocess.run(["git", "add", path], check=True)
    result = subprocess.run(["git", "diff", "--cached", "--quiet"])
    if result.returncode != 0:
        subprocess.run(["git", "commit", "-m", message], check=True)


def append(path: str, marker: str, block: str, message: str) -> None:
    p = Path(path)
    text = p.read_text()
    if marker in text:
        return
    p.write_text(text.rstrip() + "\n\n" + block.strip() + "\n")
    commit_file(path, message)


def replace(path: str, old: str, new: str, message: str) -> None:
    p = Path(path)
    text = p.read_text()
    if old not in text:
        if new in text:
            return
        raise RuntimeError(f"anchor not found in {path}: {old[:100]!r}")
    p.write_text(text.replace(old, new, 1))
    commit_file(path, message)


phase20 = r'''# Phase 20 Verification - File-Based Game Backup

Date: **2026-08-15**

## Scope

Phase 20 extends the existing version-1 current-game Game Backup from clipboard-only transport to explicit user-selected file save/open while preserving the same project-owned JSON codec and persistent unranked-import trust boundary.

Implemented runtime surface:

- pinned `file_picker 11.0.2` behind the project-owned `GameBackupFilePort` interface;
- `.nova2048` / `.json` chooser filters as convenience only, never trust signals;
- UTC-stamped `.nova2048` suggested export filenames;
- explicit Save/Open interactions only, with normal cancellation behavior;
- Web save/download handoff that does not depend on a native filesystem path;
- one-file import with reported-size and actual-byte-size checks;
- `GameBackup.maxFileBytes = 524,288` before strict UTF-8 decode;
- existing 128 Ki-character Game Backup protocol bound after decode;
- shared `GameBackup.decode()` envelope/GameState validation for clipboard and file input;
- explicit restore preview followed by `AppController.importGameBackup()` only;
- persistent unranked imported-session policy unchanged;
- macOS `com.apple.security.files.user-selected.read-write` entitlement in Debug/Profile and Release;
- English/Hindi Game Backup file actions, errors, safety copy, and in-app Guide content;
- five file-flow widget regressions plus one Hindi catalog regression.

The transport layer does not parse player state, decide ranking, retain a file history, scan directories, upload data, or establish authenticity from a filename/path/document grant.

## First clean functional gate

After formatter and analyzer cleanup, the first complete Phase 20 behavioral gate passed before the final native/plugin correction work:

```text
Commit: 1cd1b4230f6200c9208709d0c76f12fd3a20fce2
CI run: 31874929593
CI job: 94989136815
Result: SUCCESS
Flutter: 3.47.0 stable
Dart: 3.13.0
DevTools: 2.60.0
Formatting: PASS - 91 files, 0 changed
Static analysis: PASS - No issues found
Tests: PASS - 189/189
Web release: PASS - build/web
Web WASM dry run: PASS
```

The existing non-fatal Cupertino icon-font availability warning remained visible while the Web build still produced `build/web` successfully.

## Initial current-source native matrix failure

The first final runtime source candidate was:

```text
Commit: aa450da630e298047253915f141005076e8db10f
CI run: 31875177577
CI job: 94989731971
CI result: SUCCESS
Platform Builds run: 31875177571
Platform result: FAILURE
```

CI itself passed formatting, analysis, 189/189 tests, Web release, and WASM dry run. Native results were:

```text
Android release APK: FAILURE - job 94989728523
Linux release: PASS - job 94989728554
Windows release: PASS - job 94989728560
macOS release: PASS - job 94989728540
unsigned iOS release: PASS - job 94989728540
```

Android failed in generated plugin registration because `com.mr.flutter.plugin.filepicker.FilePickerPlugin` was not compiled/visible to `GeneratedPluginRegistrant.java` under the project's AGP-9 configuration.

The repository was already using the Flutter 3.47/AGP-9 application layout. `android/gradle.properties` still had `android.builtInKotlin=false`; meanwhile `file_picker 11.0.2` skips applying its legacy Kotlin Android plugin when AGP 9+ is detected. The host project was corrected rather than downgrading AGP or patching dependency source.

Repair commit:

```text
188e81c607eca76516018be8c668eab41b777cc1
build: enable AGP 9 built-in Kotlin
```

The project now keeps `android.newDsl=false` for the current Flutter template compatibility and sets `android.builtInKotlin=true` so AGP-9-aware plugin Kotlin sources are compiled by the host build.

## Final current-source CI

The repaired final runtime tree passed the permanent CI workflow:

```text
Commit: 188e81c607eca76516018be8c668eab41b777cc1
CI run: 31875447398
CI job: 94990368739
Result: SUCCESS
Runner: Ubuntu 24.04
Flutter: 3.47.0 stable
Dart: 3.13.0
DevTools: 2.60.0
Dependency: file_picker 11.0.2
Formatting: PASS - 91 files, 0 changed
Static analysis: PASS - No issues found
Tests: PASS - 189/189
Web release: PASS - build/web
Web WASM dry run: PASS
```

The Web build again emitted the existing non-fatal Cupertino icon-font availability warning and still completed successfully.

## Final current-source native matrix

The fresh native matrix tied to the same repaired runtime source completed successfully:

```text
Commit: 188e81c607eca76516018be8c668eab41b777cc1
Platform Builds run: 31875447417
Result: SUCCESS
Android release APK: PASS - job 94990368847
Linux release: PASS - job 94990368919
Windows release: PASS - job 94990368886
macOS release: PASS - job 94990368933
unsigned iOS release: PASS - job 94990368933
```

This is the accepted Phase 20 plugin/native compilation evidence. It supersedes the failed Android matrix `31875177571`.

## Focused automated coverage

Phase 20 increases the full automated suite from 183 to **189 tests**. New focused coverage verifies:

- file export produces a decodable current-game Game Backup;
- suggested export names use `.nova2048`;
- cancelled file export does not mutate the game;
- valid file import uses the same explicit unranked confirmation path as clipboard import;
- cancelled file selection preserves an existing ranked game;
- oversized-file rejection occurs before restore confirmation;
- Hindi catalog coverage exists for file actions and validation/error feedback.

Existing Game Backup codec, clipboard, imported-session persistence/ranking, statistics, achievements, Daily history, replay, solver, localization, and engine tests remain part of the 189-test gate.

## Transparent intermediate failures

Phase 20 intentionally retains the following failures as engineering evidence rather than rewriting history:

1. Integration helper run `31874615155` failed at its final push because Flutter 3.47's `flutter pub get` migrated `analysis_options.yaml`, leaving an unstaged edit that blocked `git pull --rebase`. Its intended Hindi/lock commits did not reach `main`. The helper was removed and replaced by a repaired integration flow.
2. CI `31874742612` stopped at formatting before analyzer/tests. The permanent formatter normalized the new Dart files.
3. CI `31874841323`, job `94988934511`, reached analyzer and failed on one redundant `dart:typed_data` import. Commit `1cd1b4230f6200c9208709d0c76f12fd3a20fce2` removed only that import.
4. Platform Builds `31875177571` failed Android only at plugin registration. Linux, Windows, macOS, and unsigned iOS passed. Commit `188e81c607eca76516018be8c668eab41b777cc1` enabled AGP-9 built-in Kotlin, and the complete fresh matrix `31875447417` then passed all configured targets.

## Phase 19 repository-audit correction

At the beginning of Phase 20, a repository audit found that an earlier chat response had overstated the final Phase 19 cleanup/verification state. The Phase 19 final-recorder run `31873308985` had failed, final-source CI `31873227162` had been cancelled, and two temporary Phase 19 workflow files still existed on `main`.

They were removed transparently before Phase 20 implementation:

```text
607afd4672443c40503c15816af296761342c01f
chore: remove stale Phase 19 contributor helper

f7126fe9e32dd382efccd3b37e8cfcfe9692e5da
chore: remove failed Phase 19 verification helper
```

Phase 19 still has its earlier clean 183-test behavioral gate (`31871817119`, job `94981543084`, commit `4a16608c9f8e94de529ef79ca5d213a81b66baae`). The later Phase 20 native matrix compiles the accumulated runtime including Phase 19 code, but it is not retroactively relabeled as a Phase 19 focused acceptance run.

## Manual release boundaries

Hosted CI/native compilation does **not** complete stable-release qualification. Before `1.0.0`, representative real environments still need:

- Game Backup `.nova2048` Save/Open/cancel/overwrite and fresh-session round trip;
- browser download/file-input behavior;
- Android/iOS document-provider behavior, including user-selected cloud-backed documents where practical;
- macOS sandboxed user-selected read/write behavior;
- Windows/Linux native picker behavior;
- large-but-valid, oversized, non-UTF-8, malformed, unsupported-version, and invalid-state file behavior;
- persistent unranked status after file restore/restart and new Undo behavior after imported moves;
- Hindi, large-text, keyboard/focus, VoiceOver/TalkBack/Narrator/browser-screen-reader checks for the new file actions/errors/confirmation;
- all previously documented physical-device gameplay/lifecycle, Challenge Code, replay, external-handler, native-branding, signing/provisioning/notarization, and store/package review checks.

Stable `1.0.0` therefore remains intentionally unpromoted.
'''

Path("docs/PHASE_20_VERIFICATION.md").write_text(phase20)
commit_file("docs/PHASE_20_VERIFICATION.md", "docs: add Phase 20 verification record")

verification_block = r'''## Phase 20 - File-Based Game Backup and current-source plugin matrix

Date: **2026-08-15**

Final accepted runtime source:

```text
Commit: 188e81c607eca76516018be8c668eab41b777cc1
CI run: 31875447398
CI job: 94990368739
Result: SUCCESS
Flutter: 3.47.0 stable
Dart: 3.13.0
DevTools: 2.60.0
Formatting: PASS - 91 files, 0 changed
Static analysis: PASS - No issues found
Tests: PASS - 189/189
Web release: PASS - build/web
Web WASM dry run: PASS
```

Fresh hosted native matrix on the same source:

```text
Platform Builds run: 31875447417
Result: SUCCESS
Android release APK: PASS - job 94990368847
Linux release: PASS - job 94990368919
Windows release: PASS - job 94990368886
macOS release: PASS - job 94990368933
unsigned iOS release: PASS - job 94990368933
```

The first final-source matrix `31875177571` failed Android only because `file_picker 11.0.2` was not being compiled into generated plugin registration with the host's AGP-9 built-in-Kotlin flag disabled. Linux, Windows, macOS, and unsigned iOS passed that run. Commit `188e81c607eca76516018be8c668eab41b777cc1` enabled `android.builtInKotlin=true`; the complete fresh matrix above then passed all configured targets.

Phase 20 adds explicit user-selected `.nova2048` / `.json` Game Backup file transport with pre-decode byte bounds, strict UTF-8, the existing version-1 backup decoder, explicit confirmation, and the unchanged persistent unranked import policy. It adds six focused tests over the Phase 19 total of 183.

Focused details: [`PHASE_20_VERIFICATION.md`](PHASE_20_VERIFICATION.md).

## Phase 19 repository-audit correction

Phase 19's earlier clean behavioral gate remains valid:

```text
Commit: 4a16608c9f8e94de529ef79ca5d213a81b66baae
CI run: 31871817119
CI job: 94981543084
Result: SUCCESS
Flutter: 3.47.0 stable
Dart: 3.13.0
DevTools: 2.60.0
Formatting: PASS - 88 files, 0 changed
Static analysis: PASS - No issues found
Tests: PASS - 183/183
Web release: PASS
Web WASM dry run: PASS
```

A later Phase 19 final-recorder run `31873308985` failed, final-source CI `31873227162` was cancelled, and stale temporary Phase 19 helpers were found and removed at the start of Phase 20. Those later failed/cancelled runs are not represented as successful Phase 19 acceptance evidence. Phase 20's native matrix compiles the accumulated runtime including Phase 19 code but is not relabeled as a Phase 19 focused matrix.

'''

p = Path("docs/VERIFICATION.md")
text = p.read_text()
marker = "## Phase 20 - File-Based Game Backup and current-source plugin matrix"
if marker not in text:
    anchor = "## Phase 18 - Bounded Expectimax and solver benchmarks"
    if anchor not in text:
        anchor = "## Phase 18 — Bounded Expectimax and solver benchmarks"
    if anchor not in text:
        raise RuntimeError("Phase 18 verification anchor not found")
    p.write_text(text.replace(anchor, verification_block + anchor, 1))
    commit_file("docs/VERIFICATION.md", "docs: make Phase 20 canonical verification current")

append(
    "docs/TESTING.md",
    "## Phase 20 final current-source acceptance",
    r'''## Phase 20 final current-source acceptance

The final repaired Phase 20 runtime source is commit `188e81c607eca76516018be8c668eab41b777cc1`.

```text
CI run: 31875447398
CI job: 94990368739
Flutter: 3.47.0 stable
Dart: 3.13.0
DevTools: 2.60.0
Formatting: PASS - 91 files, 0 changed
Static analysis: PASS - No issues found
Tests: PASS - 189/189
Web release: PASS - build/web
Web WASM dry run: PASS
```

The native plugin matrix on the same source is `31875447417` and passed Android, Linux, Windows, macOS, and unsigned iOS. This supersedes the Android-failed matrix `31875177571`.
''',
    "docs: record final Phase 20 test gate",
)

append(
    "docs/PLATFORMS.md",
    "## Phase 20 final native matrix",
    r'''## Phase 20 final native matrix

`file_picker 11.0.2`, the macOS user-selected read/write entitlement, and the AGP-9 built-in-Kotlin host setting are compiled in the accepted runtime source `188e81c607eca76516018be8c668eab41b777cc1`.

```text
Platform Builds run: 31875447417
Android release APK: PASS - job 94990368847
Linux release: PASS - job 94990368919
Windows release: PASS - job 94990368886
macOS release: PASS - job 94990368933
unsigned iOS release: PASS - job 94990368933
```

The prior run `31875177571` failed Android plugin registration while all other configured native targets passed. Enabling `android.builtInKotlin=true` fixed the AGP-9 host/plugin integration, and the full fresh matrix above is the accepted evidence.

Interactive picker/document-provider/browser behavior remains a real-environment release check rather than a hosted-compilation claim.
''',
    "docs: record Phase 20 native plugin matrix",
)

append(
    "docs/CI_CD.md",
    "## Phase 20 final CI and Android plugin repair",
    r'''## Phase 20 final CI and Android plugin repair

Accepted current-source automation:

```text
CI: 31875447398 / job 94990368739 - SUCCESS
Platform Builds: 31875447417 - SUCCESS
Source: 188e81c607eca76516018be8c668eab41b777cc1
```

The first native run `31875177571` was intentionally not accepted because Android job `94989728523` failed generated plugin registration for `FilePickerPlugin`. The host was migrated to AGP-9 built-in Kotlin in `188e81c607eca76516018be8c668eab41b777cc1`, after which Android job `94990368847` passed together with Linux `94990368919`, Windows `94990368886`, and macOS/unsigned-iOS `94990368933`.

CI on the repaired source passed 91-file formatting, analyzer, 189 tests, Web release, and WASM dry run. Hosted automation still does not exercise an interactive system file chooser.
''',
    "docs: record Phase 20 CI and Android repair",
)

append(
    "CHANGELOG.md",
    "#### Phase 20 final verification",
    r'''#### Phase 20 final verification

- Final current-source CI `31875447398` on `188e81c607eca76516018be8c668eab41b777cc1` passed formatting (91 files, 0 changes), static analysis, 189/189 tests, Web release, and Web WASM dry run on Flutter 3.47.0 / Dart 3.13.0.
- Initial Platform Builds `31875177571` failed Android plugin registration only; Linux, Windows, macOS, and unsigned iOS passed.
- `188e81c607eca76516018be8c668eab41b777cc1` enables AGP-9 built-in Kotlin so `file_picker` Kotlin sources remain available to Flutter plugin registration.
- Fresh Platform Builds `31875447417` passed Android `94990368847`, Linux `94990368919`, Windows `94990368886`, macOS and unsigned iOS `94990368933`.
- Stable `1.0.0` remains unpromoted pending the documented real-device/file-picker/accessibility/signing/store checks.
''',
    "docs: record final Phase 20 verification in changelog",
)

roadmap_stale = "- Optional file-based backup import/export in addition to the implemented clipboard backup, with the same strict validation/unranked policy.\n"
p = Path("ROADMAP.md")
text = p.read_text()
if roadmap_stale in text:
    p.write_text(text.replace(roadmap_stale, "", 1))
    commit_file("ROADMAP.md", "docs: remove completed file backup roadmap item")

append(
    "docs/README.md",
    "Phase 20 verification: [`PHASE_20_VERIFICATION.md`]",
    r'''Phase 20 verification: [`PHASE_20_VERIFICATION.md`](PHASE_20_VERIFICATION.md) records file-backup implementation scope, transparent CI/native failures, the AGP-9 built-in-Kotlin repair, final 189-test CI, the fully green cross-platform native matrix, and remaining real-environment release boundaries.''',
    "docs: index Phase 20 verification record",
)

worklog = r'''# Phase 20 - File-Based Game Backup Import/Export

Date: **2026-08-15**

## Repository audit before Phase 20

Phase 20 began with a verification/workflow audit rather than assuming the prior chat status was correct. That audit found a mismatch left after Phase 19:

- Phase 19 final recorder run `31873308985` had failed;
- final-source Phase 19 CI `31873227162` had been cancelled;
- `.github/workflows/phase19-contributing-cleanup.yml` still existed;
- `.github/workflows/phase19-final-verification.yml` still existed.

The earlier clean Phase 19 behavioral gate remained valid (`4a16608c9f8e94de529ef79ca5d213a81b66baae`, CI `31871817119`, job `94981543084`, 183/183 tests, Web/WASM PASS), but the later failed/cancelled evidence was not treated as success.

Cleanup commits:

```text
607afd4672443c40503c15816af296761342c01f  chore: remove stale Phase 19 contributor helper
f7126fe9e32dd382efccd3b37e8cfcfe9692e5da  chore: remove failed Phase 19 verification helper
```

This corrects the repository record from the earlier overstatement instead of hiding it.

## Phase 20 scope decision

The next roadmap item chosen was file-based Game Backup import/export. The design deliberately reuses the existing version-1 `GameBackup` envelope and `AppController.importGameBackup()` path rather than introducing a second portable-progress schema or a new ranked import route.

Guardrails:

- explicit user-selected files only;
- `.nova2048` / `.json` are chooser hints, not trust/authentication;
- bounded bytes before text decode;
- strict UTF-8;
- existing Game Backup text/JSON/GameState validation remains authoritative;
- explicit restore confirmation remains mandatory;
- imported sessions remain persistently unranked;
- no file history, directory scanner, account, cloud SDK, upload, or background sync;
- platform transport is injectable/testable and separated from domain validation.

## Runtime and build commits

```text
3120f41acce6a4ed08522b8cdfd6b7325dfb0adb  build: add cross-platform file picker
a14f0ab631f05ebc01cec1c6c70016cda95f8c33  feat: add cross-platform backup file port
a9013d7fc6f5e1254a4f2ee34137f0e2c3121401  build: allow selected backup files in macOS debug
6804a25cb79c0fdbe9d7f391b14f7f3db4ae2399  build: allow selected backup files in macOS release
dab5b3264f9d6b3c8265bb91efcc1b4be8de037f  feat: bound file backup input before decode
29cdb6f7f333bbc912ee0880a1e01e7d9d32e1e4  feat: add file export and import to Game Backup
69f4fbc0944d44e4418893efebc95d5324497722  build: pin verified stable file picker
51059902639ffd1d435f3c58912412e9f6010359  feat: localize file-based Game Backup
3b623a86ede467049560c97af33f71ae48000b5a  build: lock verified file picker dependency
1ce1171a8b02c7615caa073f7c60d1715f4510a2  docs: explain file backups in in-app guide
dc2ead03a4e5c8fd69898ad42ddc1658231bb188  style: format Dart sources and tests
1cd1b4230f6200c9208709d0c76f12fd3a20fce2  fix: remove redundant backup file import
dff8f881dab30b24810b768a944c2b1a66fc4e91  docs: codify Game Backup file trust boundary
aa450da630e298047253915f141005076e8db10f  docs: keep file trust contract dependency-neutral
188e81c607eca76516018be8c668eab41b777cc1  build: enable AGP 9 built-in Kotlin
```

`file_picker` is pinned to `11.0.2` in both `pubspec.yaml` and `pubspec.lock` for this release-candidate line.

## File transport implementation

`lib/shared/game_backup_file_port.dart` defines:

- `BackupFileSaveOutcome.saved/cancelled`;
- `BackupFileDocument`;
- `GameBackupFilePort`;
- `SystemGameBackupFilePort`.

Production behavior:

- save UTF-8 encoded backup bytes through the platform/browser save flow;
- propose a UTC-stamped `.nova2048` filename;
- filter chooser extensions to `nova2048` and `json` where supported;
- treat native null save path as cancellation;
- treat Web explicit download handoff as saved even though a native filesystem path is intentionally unavailable;
- request one import file;
- check picker-reported byte size before full reading;
- check actual byte size after reading;
- decode strict UTF-8;
- return text to the feature layer without parsing/ranking it.

`GameBackup.maxFileBytes` is `524,288` bytes. The existing `GameBackup.maxEncodedLength` remains `128 * 1024` characters. This creates a bounded byte-level file boundary before the existing text/JSON/domain validation.

## macOS sandbox

Both `macos/Runner/DebugProfile.entitlements` and `macos/Runner/Release.entitlements` now include:

```text
com.apple.security.files.user-selected.read-write = true
```

This is scoped to explicit user-selected files and is not treated as broad filesystem permission.

## Game Backup UI/trust integration

`GameBackupScreen` now accepts both `TextClipboard` and `GameBackupFilePort` dependencies. UI actions are:

- Copy game backup;
- Save backup file;
- Import from clipboard;
- Import backup file.

Clipboard and file imports both converge on:

```text
portable text
  -> GameBackup.decode
  -> decoded preview / explicit confirmation
  -> AppController.importGameBackup
  -> persistent unranked current game
```

There is no file-specific ranked path. Cancelled selection/export and rejected data never replace the live game.

## Focused tests

```text
9c3a61fbd97ecf12ff737e0c7f3389aebd249258  test: cover file-based Game Backup flows
1a167c4cf3265f0f03ee1421b70b4a1320a968fb  test: cover Hindi file backup catalog
```

Five file-flow widget tests plus one Hindi catalog test increase the Phase 19 total from 183 to **189 tests**.

Coverage includes decodable file export, `.nova2048` naming, cancelled export, valid file restore through the unranked confirmation path, cancelled selection, oversized-file rejection before confirmation, and Hindi actions/errors. Existing clipboard and imported-ranking regressions remain active.

## Integration-helper failure and repair

Initial integration staging commit:

```text
cc19146a173b3bea4bf32bf6bca3172b83a68e7e
```

Workflow run `31874615155` failed only at its final push. Flutter 3.47 `flutter pub get` migrated `analysis_options.yaml`, which remained as an unstaged runner edit; `git pull --rebase` therefore refused to proceed. Intended Hindi/lock commits existed only inside that runner and never reached `main`.

The failed helper was removed:

```text
d5d68e7940ce66ce2741420cb6bab4e18ccc82e8  chore: remove failed Phase 20 integration helper
```

Repaired integration staging:

```text
27edeb9f351d25683862c890b0f2c1f8811e6951
workflow run: 31874709676
result: SUCCESS
```

The repaired helper explicitly discarded Flutter's unrelated `analysis_options.yaml` migration before rebase/push, committed the Hindi catalog and exact dependency lock, then removed itself (`2102c58a50f9eef51bacf5dcd61dd12c952698d1`).

## Formatting/analyzer acceptance path

CI `31874742612` stopped at formatting before analyzer/tests. It is not passing behavioral evidence.

The maintained formatter then normalized the complete new Dart source/test tree:

```text
dc2ead03a4e5c8fd69898ad42ddc1658231bb188
style: format Dart sources and tests
```

CI `31874841323`, job `94988934511`, passed formatting but failed analyzer because `game_backup_file_port.dart` imported `dart:typed_data` redundantly. No runtime behavior was changed to fix it; commit `1cd1b4230f6200c9208709d0c76f12fd3a20fce2` removed that import.

## First clean Phase 20 functional gate

```text
Commit: 1cd1b4230f6200c9208709d0c76f12fd3a20fce2
CI run: 31874929593
CI job: 94989136815
Result: SUCCESS
Flutter: 3.47.0 stable
Dart: 3.13.0
DevTools: 2.60.0
Formatting: PASS - 91 files, 0 changed
Static analysis: PASS - No issues found
Tests: PASS - 189/189
Web release: PASS
Web WASM dry run: PASS
```

## Documentation phase

Added dedicated `docs/FILE_BACKUPS.md` and synchronized README, ROADMAP, BACKUP_AND_RESTORE, ARCHITECTURE, DATA_STORAGE, PRIVACY, SECURITY, DEPENDENCIES, CONTRIBUTING, DEVELOPMENT, USER_GUIDE, FAQ, TROUBLESHOOTING, TESTING, PLATFORMS, CI_CD, RELEASE_CHECKLIST, documentation index, in-app Guide, and CHANGELOG.

The documentation batch ran as workflow `31875136106`, job `94989624419`, and created separate document commits before removing its helper in `28a6e0651b37c23d725f2fcc81e812f2979cf4b3`.

A later audit found the old optional file-backup roadmap line had survived the batch. It is removed in the final documentation consistency commits rather than being silently ignored.

## First final-source native failure

Candidate source `aa450da630e298047253915f141005076e8db10f` passed permanent CI:

```text
CI run: 31875177577
CI job: 94989731971
Result: SUCCESS
Formatting: PASS - 91 files, 0 changed
Static analysis: PASS
Tests: PASS - 189/189
Web release: PASS
Web WASM dry run: PASS
```

But Platform Builds `31875177571` was correctly rejected because Android job `94989728523` failed:

```text
GeneratedPluginRegistrant.java:
cannot find symbol
com.mr.flutter.plugin.filepicker.FilePickerPlugin
```

Other jobs in that failed matrix were green:

```text
Linux: PASS - 94989728554
Windows: PASS - 94989728560
macOS + unsigned iOS: PASS - 94989728540
```

The Android failure was not bypassed, and the other successful jobs were not used to call the whole matrix green.

## Android AGP-9 built-in-Kotlin repair

The Android host already used AGP `9.1.0`, Flutter 3.47's application layout, and JVM-17 Kotlin compiler options. `android/gradle.properties` still disabled built-in Kotlin. `file_picker 11.0.2` detects AGP 9 and skips applying its legacy Kotlin Gradle plugin, so the host needed built-in Kotlin enabled to compile plugin Kotlin source.

Repair:

```text
188e81c607eca76516018be8c668eab41b777cc1
build: enable AGP 9 built-in Kotlin
```

The project now sets:

```text
android.newDsl=false
android.builtInKotlin=true
```

No AGP downgrade and no vendored/modified third-party plugin source was used.

## Final accepted Phase 20 CI

```text
Commit: 188e81c607eca76516018be8c668eab41b777cc1
CI run: 31875447398
CI job: 94990368739
Result: SUCCESS
Runner: Ubuntu 24.04
Flutter: 3.47.0 stable
Dart: 3.13.0
DevTools: 2.60.0
file_picker: 11.0.2
Formatting: PASS - 91 files, 0 changed
Static analysis: PASS - No issues found
Tests: PASS - 189/189
Web release: PASS - build/web
Web WASM dry run: PASS
```

The known non-fatal Cupertino icon-font warning remains visible while the Web build completes successfully.

## Final accepted Phase 20 native matrix

```text
Commit: 188e81c607eca76516018be8c668eab41b777cc1
Platform Builds run: 31875447417
Result: SUCCESS
Android release APK: PASS - job 94990368847
Linux release: PASS - job 94990368919
Windows release: PASS - job 94990368886
macOS release: PASS - job 94990368933
unsigned iOS release: PASS - job 94990368933
```

This fresh matrix supersedes failed Android matrix `31875177571` and is the accepted cross-platform plugin compilation evidence.

## Release status

Phase 20 automated/runtime-source qualification is complete, but stable `1.0.0` remains intentionally unpromoted.

Still-manual Phase 20 release boundaries include real `.nova2048` Save/Open/cancel/overwrite/round-trip behavior; Web browser download/file-input; Android/iOS document providers and selected cloud-backed files where practical; macOS sandbox access; Windows/Linux native pickers; malformed/non-UTF-8/oversized/large-valid files; restored-session restart/Undo behavior; and Hindi/large-text/keyboard/focus/screen-reader checks.

Previously documented physical-device gameplay/lifecycle, Challenge Code, Replay/Full Replay, external browser/email handlers, native splash/icon review, signing/provisioning/notarization, and store metadata/review checks also remain required. Hosted builds are not physical-device or store qualification.
'''

append(
    "what_changed.md",
    "# Phase 20 - File-Based Game Backup Import/Export",
    worklog,
    "docs: record complete Phase 20 implementation log",
)

print("Phase 20 final evidence documents complete")
