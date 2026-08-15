# Testing Strategy

2048 Nova uses automated tests for deterministic rules, persistence integrity, controller behavior, accessibility semantics, terminal-state safety, seeded Challenge Code portability, Auto Play isolation, read-only replay integrity, portable backup trust boundaries, and important UI flows. GitHub Actions is the objective source of truth for repository-wide formatter, analyzer, test, and build status.

## Unit and controller coverage

`test/game_engine_test.dart` covers:
- Starting tile creation.
- Compression and valid-move spawning.
- Single-merge semantics and chained-merge prevention.
- Score and merge accounting.
- Invalid-move spawn prevention.
- Vertical movement.
- Game-over and target-win detection.
- Move-limit and time-limit rules.
- Deterministic persisted RNG behavior.
- Blocking movement before a target win is acknowledged.

`test/game_types_test.dart` covers strict persisted `GameConfig` type/range parsing, unsupported modes, fractional numeric fields, and seed bounds.

`test/game_state_test.dart` covers serialization, schema migration, structure/type/range validation, status and acknowledgement invariants, best-score invariants, timed-state timestamps, and highest-tile derivation.

`test/challenge_code_test.dart` covers the portable seeded configuration codec:
- all supported built-in non-Daily presets round-trip exactly after an explicit seed is added;
- encoding is stable for the same configuration;
- a decoded configuration creates the same deterministic opening board and RNG state as the source configuration;
- unseeded configurations are rejected;
- Daily Challenge is rejected from arbitrary code transport;
- empty input and unsupported prefixes are rejected;
- checksum tampering is rejected;
- malformed checksum and payload structure are rejected;
- oversized text is rejected before payload parsing;
- unsafe seed bounds are rejected.

`test/hint_solver_test.dart` covers heuristic hint availability, representative corner/merge preference, board immutability, and larger board sizes.

`test/hint_state_test.dart` verifies terminal games do not expose gameplay hints.

`test/autoplay_session_test.dart` covers the isolated Auto Play domain session:
- deterministic reset to the original seeded starting board and RNG state;
- matching seeded sessions producing matching recommendation/board/score/move/RNG sequences;
- stepping on an alternate board size;
- independence from application persistence and player-statistics orchestration.

`test/replay_timeline_test.dart` covers the read-only replay domain boundary:
- filtering out stale-session snapshots;
- rejecting snapshots that represent future move/merge/score progress;
- ordering retained frames by move count;
- collapsing duplicate move-number frames;
- making the current game the authoritative final frame;
- defensive copies of board/state data;
- an unmodifiable returned timeline.

`test/game_backup_test.dart` covers the portable current-game backup codec:
- exact encode/decode round trip;
- exclusion of settings, lifetime statistics, achievements, Daily history, and Undo data;
- empty/malformed JSON rejection;
- unsupported format/version rejection;
- invalid export timestamp and missing-game rejection;
- strict embedded `GameState` validation;
- 128 KiB pre-parse input-size rejection.

`test/imported_game_policy_test.dart` covers the imported-game trust boundary:
- restoring the current board while refusing to trust an imported historical lifetime best;
- imported moves remaining unranked and unable to mutate lifetime statistics, achievements, streaks, or Daily history;
- the unranked policy surviving app/controller restart;
- a normal new local game exiting the imported unranked policy;
- terminal imported games never awarding a local ranked win.

`test/unranked_marker_test.dart` covers the local ranking marker:
- boolean round trip;
- malformed marker removal with safe ranked fallback;
- marker removal when the current game is cleared;
- marker removal when corrupt current-game recovery removes the associated save.

`test/daily_record_test.dart` covers Daily Challenge progress, completion, retained wins, serialization, date validation, counter/tile validation, completion flags, and timestamps.

`test/daily_replay_history_test.dart` verifies weaker replays cannot downgrade a previous Daily best result and stronger replays update score-associated metrics while preserving the peak tile.

`test/local_store_test.dart` covers save/resume, undo history, Daily Challenge persistence, duplicate-date normalization, bounded/self-healing history repair, invalid map recovery, scoped data clearing, malformed-save recovery, and project-owned persistence behavior.

`test/app_controller_test.dart` covers persisted appearance/accessibility settings, malformed preference recovery, malformed statistics, malformed achievement timestamps, stale undo filtering, serialized move requests, timed terminal statistics, continued-win streak behavior, and complete local reset behavior.

`test/session_integrity_test.dart` covers counted-win restoration across restart and statistics reset behavior while a game is active.

`test/restored_challenge_status_test.dart` verifies expired timed games are reconciled during startup before the UI can resume them.

`test/undo_best_score_test.dart` verifies undo restores a board snapshot without lowering the lifetime best score.

`test/statistics_reset_undo_test.dart` verifies that resetting statistics also normalizes retained current-session undo snapshots, so a later Undo and future move cannot resurrect a pre-reset lifetime best score.

`test/external_link_test.dart` covers the approved external URI policy.

## Widget and interaction coverage

`test/widget_smoke_test.dart` validates app startup/navigation, theme selection, availability of the primary game modes, and navigation from Home into the Challenge Codes workspace.

`test/challenge_code_screen_test.dart` verifies the seeded Challenge Code UI/state boundary using an injected in-memory `TextClipboard` while production defaults to `SystemTextClipboard`:
- deterministic code generation and clipboard copy;
- copied text decodes to the selected seeded configuration;
- Paste validates a supported code and exposes its decoded preview;
- starting the valid code creates the same deterministic configuration, opening board, and RNG state;
- invalid pasted text is rejected without creating/replacing a game;
- cancelling the normal recoverable-game replacement dialog preserves the existing ranked game unchanged.

`test/game_board_accessibility_test.dart` validates board-size semantics plus positional row/column tile labels as distinct semantic nodes, including empty-cell state.

`test/home_screen_state_test.dart` verifies completed lost games do not expose a misleading Continue action.

`test/game_replacement_guard_test.dart` verifies recoverable games require confirmation before replacement while terminal lost games can be replaced directly.

`test/game_screen_interaction_test.dart` covers keyboard shortcuts and protection against accidentally dismissing terminal dialogs with route-back behavior.

`test/solver_demo_screen_test.dart` verifies the optional Auto Play / AI Demonstration boundary:
- navigation from Home into the clearly labeled Auto Play Demo;
- single-step execution and deterministic seed reset;
- demo moves never create or replace `AppController.game`;
- player games-played, total-moves, and lifetime-best statistics remain unchanged;
- speed selection can be changed;
- Auto Play starts and exposes Pause;
- pausing stops later timer ticks from advancing the sandbox in the background.

`test/replay_screen_test.dart` verifies the spectator Replay boundary:
- Home navigation to Move Replay when a saved game exists;
- first/next/latest frame navigation;
- live board, score, move count, and RNG staying unchanged while replay frames are viewed;
- timed playback advancing retained frames;
- Pause preventing later timer ticks from advancing the replay in the background;
- a safe empty state when the replay route is opened without a current game;
- controls are explicitly scrolled into the constrained widget-test viewport before taps, matching the production screen's scrollable layout instead of assuming every control is initially visible.

`test/game_backup_screen_test.dart` verifies the portable backup UI flow with an injected in-memory `TextClipboard`, while production defaults to `SystemTextClipboard`:
- export producing a decodable current-game-only backup;
- a valid import showing the required unranked preview/confirmation before replacing state;
- confirmed restore producing an unranked current game while preserving the device lifetime best policy;
- Cancel preserving an existing ranked game unchanged;
- malformed clipboard text being rejected without replacing the current game;
- page actions are deliberately scrolled above the bottom navigation/test viewport before taps, matching the production screen's scrollable layout.

## Phase 15 Challenge Code evidence

Phase 14 completed at **112 tests**. Phase 15 adds exactly **15** focused automated cases:

- `test/challenge_code_test.dart` — 10;
- `test/challenge_code_screen_test.dart` — 4;
- `test/widget_smoke_test.dart` — 1 new Home-to-Challenge-Codes navigation regression.

The complete suite is therefore **127 tests**.

Final maintained quality gate:

```text
Workflow: CI
Run: 31796242355
Verified commit: 643b38665738ce314eea81e3dcc8887c77fb2257
Commit: docs: explain challenge code deterministic engine relationship
Flutter: 3.47.0 stable
Dart: 3.13.0
Formatting: PASS — 66 files, 0 changed
Static analysis: PASS — No issues found
Tests: PASS — 127/127
Web release build: PASS — build/web
WASM dry run: PASS
Overall: SUCCESS
```

Final native production/in-app-documentation state:

```text
Workflow: Platform Builds
Run: 31795329370
Production/in-app-doc commit: 7c83d7a14656d9309b54205de1f72e0af131f551
Commit: docs: include challenge codes in app release highlights
Overall: SUCCESS
```

Results:

- Android release APK: **PASS**
- Linux release: **PASS**
- Windows release: **PASS**
- macOS release: **PASS**
- iOS release with `--no-codesign`: **PASS**

This native state contains all Phase 15 runtime changes: `ChallengeCode`, Challenge Codes screen, named route, Home entry, shared clipboard use, in-app Guide content, and About release highlights. Later Phase 15 changes before the 127-test CI gate are tests/repository documentation and do not alter native runtime behavior.

### Challenge Code trust-boundary assertions covered by the suite

The automated/source evidence verifies that:

- a code is configuration/seed only rather than portable player progress;
- identical supported seeded configurations round-trip without field loss;
- the same configuration/seed creates the same deterministic opening board and post-opening RNG state;
- malformed, unsupported, tampered, or oversized text is rejected before it can create a game;
- the checksum is validated before decoding/parsing the configuration payload;
- strict existing `GameConfig` validation remains authoritative;
- Daily Challenge cannot be transported through arbitrary Challenge Code seed input;
- a valid decoded challenge still goes through normal recoverable-game replacement protection;
- a Challenge Code cannot import score, board progress, lifetime statistics, achievements, settings, Daily history, or Undo snapshots;
- starting a valid code uses the normal fresh non-Daily game path rather than the unranked Game Backup restore path.

### Transparent Phase 15 development history

The first codec commit used unsupported Dart string multiplication while reconstructing Base64URL padding. Commit `88c2954f9703a72626ddf47d93b4d6e9e8e8dfeb` (`fix: decode challenge code padding with valid Dart`) replaced it with `List.filled(paddingCount, '=').join()` before final verification.

Earlier CI run `31795076552` had already passed formatter, static analysis, and tests for an earlier Phase 15 source state, but its Web release step was cancelled by the repository concurrency policy when a newer commit superseded it. It is not a code failure and is not promoted as final evidence. Complete run `31796242355` supersedes it with all quality steps green.

No temporary diagnostic/patch workflow was required for Phase 15.

## Historical Phase 14 portable-backup evidence

Phase 14 added **20 focused automated tests** to the Phase 13 total of 92:

- 7 backup-codec tests;
- 5 imported-game policy tests;
- 4 backup-screen tests;
- 4 unranked-marker tests.

The complete Phase 14 suite was therefore **112 tests**.

Final maintained quality gate:

```text
Workflow: CI
Run: 31787639781
Verified source/test commit: 1371ef9eaa00f1da5a2ce0370a1f22eb1f2f4cd2
Formatting: PASS
Static analysis: PASS
Tests: PASS — 112/112
Web release build: PASS
Overall: SUCCESS
```

Final production/native state after isolating system clipboard access behind a testable boundary:

```text
Workflow: Platform Builds
Run: 31787016748
Production-code commit: dd3c79bec40cf1aa1e4b00190d32393b249902e0
Overall: SUCCESS
```

Results:

- Android release APK: **PASS**
- Linux release: **PASS**
- Windows release: **PASS**
- macOS release: **PASS**
- iOS release with `--no-codesign`: **PASS**

`TextClipboard` is a narrow boundary: `SystemTextClipboard` uses Flutter's platform clipboard in production, while widget tests use an in-memory implementation. This keeps tests deterministic without changing the user-facing clipboard behavior.

### Transparent Phase 14 defects and tooling failures

Phase 14 deliberately records real intermediate issues rather than rewriting history as if the feature was correct on the first attempt.

- CI run `31781326279` failed after backup screen tests were introduced because static analysis found an unused test import. Commit `3446413574582c196a47877fe1bfbe63addbf71d` (`fix: remove unused backup test import`) removed it.
- The oversized-backup fixture initially used non-Dart string multiplication. Commit `a4a2de5bfb9e32fb9f02cf13b5019f69141ff567` (`fix: build oversized backup fixture with valid Dart`) replaced it with `List.filled(...).join()`.
- The initial Backup widget harness used platform clipboard calls and unbounded settle behavior. The production clipboard access was isolated behind `TextClipboard`; tests now use an in-memory implementation and bounded frame pumping.
- A later full suite completed with **110 passed / 2 failed**. Focused diagnostics showed only Backup export and Cancel failed because their page actions remained below the bottom navigation in Flutter's default 800×600 widget-test viewport. Commit `1371ef9eaa00f1da5a2ce0370a1f22eb1f2f4cd2` scrolls the Backup page before those actions are tapped. The next maintained CI passed **112/112**.
- Several temporary one-time patch/wiring/diagnostic workflows failed for development-tooling reasons such as source-anchor mismatch, an invalid handwritten patch, missing Dart in a plain Ubuntu patch job, YAML helper parsing, or diagnostic-only test failures. The actual source changes were applied through normal repository commits, and temporary helper/diagnostic workflow files were removed after use.

These failures are not presented as successful release evidence. The final source is judged by the maintained CI/native gates above.

## Phase 16 — English/Hindi localization evidence

Phase 16 adds **7 focused localization tests** to the Phase 15 total of 127, producing a final suite of **134 tests**:

- supported/malformed `AppLanguage` parsing;
- critical Hindi catalog translations;
- English identity plus safe unknown-key fallback;
- localized mode/direction/achievement helpers;
- persisted language preference plus malformed-value recovery;
- Hindi Home and Settings rendering;
- Hindi board-size/row/column/tile/empty-cell semantics.

A reusable `test/support/localized_test_app.dart` harness now mirrors production localization delegates for widget tests that mount localized feature widgets directly.

Final maintained gate:

```text
Workflow: CI
Run: 31806785165
Verified commit: 9dea87e73803d83c3aa0614d35f7860773dbca04
Flutter: 3.47.0 stable
Dart: 3.13.0
Formatting: PASS — 70 files, 0 changed
Analysis: PASS — No issues found
Tests: PASS — 134/134
Web release build: PASS — build/web
WASM dry run: PASS
Overall: SUCCESS
```

Final runtime localization native evidence:

```text
Workflow: Platform Builds
Run: 31804713200
Verified production commit: 5048486775b0c9702583f348bfc5be71219e83ae
Overall: SUCCESS
```

Jobs:

- Windows release `94780817747` — **PASS**;
- Linux release `94780817828` — **PASS**;
- Android release APK `94780817929` — **PASS**;
- macOS + unsigned iOS `94780818361` — **PASS**.

### Transparent Phase 16 regressions/tooling failures

- CI run `31804557648` stopped at static analysis because `solver_demo_screen.dart` retained one unused import after localization refactoring. Commit `5048486775b0c9702583f348bfc5be71219e83ae` removed it.
- Localization lock helper run `31804740412` resolved dependencies but failed before rebase because Flutter 3.47 rewrote `analysis_options.yaml` in the runner and left an unrelated unstaged change. Commit `f91ee2d423af2142d4d660b3a1d1402bf942f13f` scoped the helper to the lockfile; corrected run `31804909137` succeeded and produced lock commit `abf4c95c411658abae27c44f76d39f2f6a9a8bdd`.
- CI run `31805260580` exposed a stale bare `MaterialApp` harness in `game_screen_interaction_test.dart`; localized `GameScreen` correctly required `NovaLocalizations`. Diagnostic run `31805881265` confirmed formatting, analysis, and focused localization tests were clean while the full suite failed. Commit `8990a904f6ecfb487c722b3705f7061237ca270f` added production localization delegates to that harness.
- CI run `31806175302` then reached **123 passed / 11 failed**. Machine-readable diagnostic run `31806445596` showed all eleven failures were old direct-widget harnesses without localization delegates: Challenge Codes (4), Game Backup (4), replacement guard (1), board semantics (1), and Home lost-game state (1). A shared localized test app plus focused harness commits corrected all eleven; the final CI passed 134/134.
- Temporary Phase 16 diagnostics and generated failure reports were removed after use and are not part of the permanent workflow/file surface.

Manual English/Hindi qualification still includes representative real-device font rendering, large-text/narrow-layout wrapping, System-default locale behavior, language persistence after real process termination, keyboard/focus, clipboard flows, and TalkBack/VoiceOver/desktop-browser screen-reader behavior. Automated success does not replace those checks.

## Historical Phase 13 quality evidence

The final Replay quality gate was:

```text
Workflow: CI
Run: 31779838751
Verified commit: 278ba039d0b7b59ce54c72c5ed0fcd0401ba537a
Flutter: 3.47.0 stable
Dart: 3.13.0
Formatting: PASS — 55 files, 0 changed
Analysis: PASS — No issues found
Tests: PASS — 92/92
Web release build: PASS — build/web
WASM dry run: PASS
Overall CI job: SUCCESS
```

The Web build emitted the existing informational CupertinoIcons font lookup warning while still producing the release Web output. The project does not directly reference `CupertinoIcons`.

The Phase 13 native matrix was:

```text
Workflow: Platform Builds
Run: 31779566057
Production-code commit: 4f3cc6f55ae6b2f50b4758db22569b7ec48ddafd
```

Results: Android release APK **PASS**, Linux **PASS**, Windows **PASS**, macOS **PASS**, and unsigned iOS **PASS**.

## Transparent Phase 13 intermediate test failure

CI run `31779369661` passed formatting and static analysis but finished the test step with **90 passed / 2 failed**. The failing Replay widget tests attempted to tap Next/Play controls that were below Flutter's default 800×600 widget-test viewport. The production Replay screen itself is intentionally scrollable.

Commit `501b2a512c2f185461129f2e294504e43e883d59` (`test: scroll replay controls before widget taps`) corrected the test harness by scrolling the controls into view before tapping them. The final 92-test gate above then passed. The failure is kept as evidence rather than being hidden as a superseded run.

## Historical Phase 12 quality evidence

The completed Auto Play quality gate was:

```text
Workflow: CI
Run: 31778558429
Commit: 1d98042558ab7ffe40c9da4ad42dbbf8263dcaf6
Flutter: 3.47.0 stable
Dart: 3.13.0
Formatting: PASS — 51 files, 0 changed
Analysis: PASS — No issues found
Tests: PASS — 86/86
Web release build: PASS
```

The Web build also completed Flutter's WASM dry run successfully.

## CI quality gate

The main CI workflow executes:

```bash
flutter pub get
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test --coverage
flutter build web --release
```

A separate format workflow automatically formats changed Dart source/test files on `main`; the CI gate still verifies formatting independently. Separate platform-build jobs compile configured native targets where the GitHub runner supports the required toolchain.

Because multiple atomic commits can be pushed rapidly, workflow concurrency may cancel an older in-progress run in favor of a newer commit. A canceled superseded run is not considered a code failure. Release evidence is taken from the latest completed run for the final technical state.

## Regression rule

When a defect is found:

1. Reproduce it from the repository state or CI evidence.
2. Add or update a focused regression test when practical.
3. Fix the underlying cause rather than masking the symptom.
4. Run/observe focused verification when available.
5. Run the broader formatter/analyzer/test/Web quality gate.
6. Run relevant native release builds when production code changed.
7. Record the defect, fix, and objective verification in `what_changed.md`.

Real failures are recorded even when immediately fixed. Superseded/canceled workflows are distinguished from actual failures.

## Manual QA

Automated tests do not replace manual interaction checks. Stable releases should additionally verify:

- touch/swipe behavior on representative physical mobile devices;
- responsive layouts and orientation changes;
- keyboard focus and shortcuts on representative desktop/browser environments;
- screen-reader behavior on real supported platforms;
- long-session save/resume, Daily, and challenge timing behavior;
- Challenge Code generation, Copy/Paste/manual entry, checksum errors, preview, replacement cancellation, and deterministic opening behavior with real Android/iOS/desktop/browser clipboard handlers;
- same-code/same-valid-move-sequence comparison across independent runs/devices and expected divergence after different moves;
- Target, Time Challenge, Move Limit, board-size, Endless, and Zen Challenge Codes on representative real platforms;
- confirmation that arbitrary Daily Challenge Codes remain unavailable and normal UTC date-derived Daily behavior is unchanged;
- Challenge Code keyboard focus, large-text layout, validation feedback, and screen-reader behavior;
- Auto Play start/pause/resume, single-step, speed changes, reset, navigation-away timer cleanup, and readability on representative real platforms;
- Move Replay first/previous/next/latest navigation, slider scrubbing, play/pause, all speed choices, bounded-history disclosure, navigation-away timer cleanup, and readability on representative real platforms;
- confirmation that Replay does not mutate the actual saved game while it is being viewed;
- Game Backup copy/import/cancel/confirm flows with real Android, iOS, desktop, and browser clipboard handlers;
- imported-game unranked labeling and persistence after real app termination/relaunch;
- imported Undo behavior and multiple imported modes, including Daily, Target, Time Challenge, and Move Limit;
- backup validation/error/confirmation behavior with representative screen readers and large text;
- real browser/email external-link handlers;
- native splash/icon presentation;
- haptic/sound capability behavior;
- signing, provisioning, packaging, and store metadata.

These manual/device/store checks are release boundaries, not hidden automated claims.


## Phase 17 per-mode record regression coverage

Phase 17 adds 10 focused tests across four files before the final maintained CI gate is recorded:

- `mode_record_serialization_test.dart`: record round-trip, malformed/unknown-record handling, and legacy statistics compatibility.
- `mode_record_tracking_test.dart`: ranked record persistence, migration from an observable legacy current game, and Reset Statistics active-mode baseline behavior.
- `mode_record_unranked_test.dart`: imported-backup exclusion across import/move/reset plus ranked handling for locally started seeded configurations.
- `statistics_mode_records_test.dart`: expandable per-mode Statistics presentation and reuse of English/Hindi localization for mode/configuration/record labels.

The feature intentionally relies on the existing imported-game, controller, persistence, and localization suites as additional cross-coverage. The current passing total must be taken from the newest CI/verification entry rather than inferred from this section.


## Phase 17 final maintained gate

The permanent `CI` workflow run `31867499047` on commit `c443f9fde0cc243269be57515772378c06284e86` is the authoritative Phase 17 automated acceptance result. Flutter 3.47.0 / Dart 3.13.0 formatted 74 files with 0 changes, reported no analyzer issues, passed **144/144 tests**, built the Flutter Web release successfully, and passed the Web WASM dry run.

The two prior acceptance attempts remain documented rather than hidden: run `31867316152` caught an unused test local during analysis; run `31867370893` reached 142 passing / 2 failing tests because the localized Statistics widget harness incorrectly expected combined mode-record metadata to be split into separate `Text` widgets. Commits `f42a8ab18edd4661a066419de0daa84a2ce22f85` and `c443f9fde0cc243269be57515772378c06284e86` corrected those test-quality issues before the final green gate.

See [`PHASE_17_VERIFICATION.md`](PHASE_17_VERIFICATION.md) for the focused acceptance record.


## Phase 17 current-source regression rerun

Permanent CI run `31867788776` reran the complete suite on current runtime commit `d33d65840aff67c4e9bf69ad203f46b85146093c` after the final per-mode-record parser correction and source trust-boundary documentation. Result: formatting clean, analyzer clean, **144/144 tests passed**, Web release build passed, and the Web WASM dry run passed.

The test count is unchanged from feature acceptance because this final source commit adds maintainer documentation only; the purpose of the rerun is to prove that the current corrected runtime tree—not an earlier Phase 17 snapshot—remains green.


## Phase 18 advanced solver regression coverage

Phase 18 adds focused coverage for bounded Expectimax and the reusable benchmark layer on top of the Phase 17 total of 144 tests. New coverage includes deterministic/legal recommendations, terminal no-move handling, input-board immutability, explicit node-budget enforcement, larger-board support, malformed-board rejection, strategy-switch state preservation, seeded expectimax sequence reproducibility, decision diagnostics, reset behavior, deterministic benchmark summaries, heuristic zero-search-node accounting, benchmark validation, strategy-selection UI isolation, Hindi solver catalog strings, and Hindi strategy-control presentation.

The final Phase 18 test total and authoritative CI/native run IDs are recorded only after the candidate source/docs stop moving and the permanent workflows complete. Intermediate analyzer/test failures remain documented in `what_changed.md` rather than being treated as passing evidence.


## Phase 18 final maintained gate

Permanent CI run `31869835223` on final test commit `b114255b6f510f0e7ba8d0516e9a30eebf4451b8` is the authoritative Phase 18 automated acceptance result. Flutter 3.47.0 / Dart 3.13.0 formatted 80 files with 0 changes, reported no analyzer issues, passed **161/161 tests**, built the Flutter Web release successfully, and passed the Web WASM dry run.

Phase 18 adds exactly 17 tests over the Phase 17 total of 144. They cover bounded expectimax, deterministic strategy isolation, seeded benchmark behavior, Auto Play strategy selection, Hindi solver catalog entries, and Hindi solver UI.

Two failed analyzer gates remain intentionally visible. CI `31869526679` caught a duplicate Hindi `Strategy` map key plus eight CLI `avoid_print` lints; CI `31869794852` caught a missing `AppLanguage` import in the new Hindi solver widget test. Neither failed run is counted as passing evidence. The corrections precede the final 161-test gate.

The current runtime tree is additionally covered by Platform Builds `31869794809`, which passed Android, Linux, Windows, macOS, and unsigned iOS release compilation. See [`PHASE_18_VERIFICATION.md`](PHASE_18_VERIFICATION.md).

## Phase 19 — Full Replay Archive regression coverage

Phase 19 adds **22 focused automated tests** to the Phase 18 total of 161, producing **183 tests** in the first formatter/analyzer/test/Web-clean Phase 19 gate.

Focused additions:

```text
test/replay_archive_test.dart                8
test/replay_capture_store_test.dart          3
test/replay_capture_controller_test.dart     4
test/replay_archive_screen_test.dart         4
test/replay_archive_navigation_test.dart     1
test/replay_archive_localization_test.dart   2
------------------------------------------------
Phase 19 additions                          22
```

Coverage verifies deterministic full-session multi-move round trip, replay Undo, explicit continue-after-win, recorded-time timed status transition, invalid actions and event ordering, incomplete/overflowed export rejection, malformed/unsupported/oversized input, event-count/shape validation, persistence and corruption repair, current-game/reset cleanup, controller fresh capture/restart/Undo behavior, Game Backup incomplete-capture policy, valid clipboard export, imported spectator-only UI, live game/statistics isolation, invalid-input preservation, Hindi controls/trust copy, and navigation from Move Replay.

First clean maintained Phase 19 gate after formatter normalization:

```text
Commit: 4a16608c9f8e94de529ef79ca5d213a81b66baae
CI run: 31871817119
CI job: 94981543084
Flutter: 3.47.0 stable
Dart: 3.13.0
DevTools: 2.60.0
Formatting: PASS — 88 files, 0 changed
Static analysis: PASS — No issues found
Tests: PASS — 183/183
Web release: PASS — build/web
Web WASM dry run: PASS
```

This is behavioral evidence before the final current-runtime native qualification pass. The final Phase 19 CI/native matrix is recorded in `VERIFICATION.md` and `PHASE_19_VERIFICATION.md` after the final source-documentation trigger completes.

Early Phase 19 helper and formatting failures remain recorded in `what_changed.md`; none is treated as passing analyzer/test evidence.

## Phase 20 file backup coverage

Phase 20 adds **6 focused automated tests** over the Phase 19 total of 183, producing **189 tests** in the first clean Phase 20 functional gate.

New/expanded coverage verifies file export round trip and extension, cancelled file export, valid file import through the existing unranked confirmation path, cancelled file selection, pre-confirmation oversized-file rejection, and Hindi file-backup catalog coverage. Existing clipboard backup, codec, imported-session ranking, persistence, and localization tests remain active.

First clean functional gate after the analyzer fix:

```text
Commit: 1cd1b4230f6200c9208709d0c76f12fd3a20fce2
CI run: 31874929593
CI job: 94989136815
Flutter: 3.47.0 stable
Dart: 3.13.0
DevTools: 2.60.0
Formatting: PASS — 91 files, 0 changed
Static analysis: PASS — No issues found
Tests: PASS — 189/189
Web release: PASS — build/web
Web WASM dry run: PASS
```

The final current-source Phase 20 CI/native matrix is recorded separately after all source/documentation synchronization is complete. Hosted tests cannot replace real platform Save/Open dialog and document-provider behavior.

## Phase 20 final current-source acceptance

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

## Phase 21 Challenge Code QR coverage

Phase 21 adds five focused tests over the Phase 20 total of 189, bringing the source suite definition to **194 tests** before the final maintained gate. Coverage includes exact canonical text handed to the project QR wrapper, white-background rendering/semantic labeling, a 260-logical-pixel maximum, narrow-layout containment, Hindi generated-QR UI, and Hindi QR trust/accessibility catalog copy.

Automated rendering/widget checks do not prove optical scan reliability. Stable qualification still requires representative real screens and external camera/scanner apps across brightness, glare, density, theme, orientation, and text-scale conditions.
