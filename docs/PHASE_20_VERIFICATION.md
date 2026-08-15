# Phase 20 Verification - File-Based Game Backup

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
