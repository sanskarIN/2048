# 2048 Nova — Development Log

> This file is the primary continuity/progress record for the repository. Objective test/build evidence is recorded here instead of relying on chat history.

## Current repository state — Version 1.5

### Project

- **Project:** 2048 Nova
- **Version:** `1.5.0+15`
- **Repository:** https://github.com/sanskarIN/2048
- **Branch:** `main`
- **Creator / branding:** Sanskar / **Made by the Sanskar**
- **Commit email used by repository automation:** `sanskarin@outlook.in`
- **License:** MIT
- **Current phase:** Phase 29 — cross-platform timestamp and release-evidence integrity hardening complete and final Version 1.5 release-candidate source audit complete; permanent CI is green at 235 tests with 106 Dart files formatter-clean, analyzer-clean Flutter 3.47.0 / Dart 3.13.0, UTC-normalized persisted/portable timestamps, explicit-offset release evidence enforcement, current-state drift regressions, and a fail-closed 0/13 stable qualification boundary; AGP issue #10 and repository-protection issue #12 remain explicit
- **Latest accepted Version 1.5 native-matrix source:** `439a4441ebd2b36c4e1b6e0700d6f3d3359bd016` — `fix: normalize daily record timestamps to utc`
- **Permanent Version 1.5 CI evidence:** final audit source `657cfb986090a15429ebb38ddf8196b02095f9e4`, run `32018055661`, job `95351676619` — SUCCESS, 235/235 tests, 106 files formatter-clean, analyzer clean, Flutter 3.47.0 / Dart 3.13.0, candidate gate passed, strict stable gate correctly closed at 0/13 manual evidence, solver smoke passed, WASM dry run passed, Web release passed
- **Version 1.5 native build evidence:** Platform Builds run `32015893841` — Android job `95345268019`, Linux `95345268049`, Windows `95345268000`, and macOS + unsigned iOS `95345267946` all SUCCESS with checksummed qualification artifacts
- **Manual qualification boundary:** `0/13` real-world evidence items are passed; no physical-device, assistive-technology, external-handler, long-session, signing/provisioning, or store-distribution evidence has been synthesized

---

## Phase 0 — Repository audit and bootstrap

The preferred repository `sanskarIN/2048` was used rather than creating or renaming a second repository. The repository did not already contain the required complete Flutter game, so implementation was built directly from the actual repository state using many small Conventional Commits.

Repository-writing workflows explicitly configure:

```text
user.name  = Sanskar
user.email = sanskarin@outlook.in
```

No access token, signing key, password, API key, or other private credential is committed.

## Phase 1 — Foundation

Added and configured:

- Flutter application package and dependency manifest
- strict analysis configuration
- repository `.gitignore`
- app entry point
- Material 3 application shell
- named navigation routes
- lightweight `ChangeNotifier` + `InheritedNotifier` app-state architecture
- central project/contact constants
- reusable scaffold and external-link handling
- local persistence layer
- design/theme foundations

Architecture decision: deterministic 2048 rules and serializable game state remain independent of Flutter widgets. UI does not directly manipulate persistence internals.

Runtime packages beyond Flutter are intentionally limited to:

- `shared_preferences`
- `url_launcher`

The resolved application dependencies are committed in `pubspec.lock`.

## Phase 2 — Deterministic game engine

Implemented:

- board and tile-value state
- configurable board dimensions
- Up / Down / Left / Right movement
- zero-cell compression
- adjacent-equal merge logic
- correct one-merge-per-source-tile behavior
- score gain calculation
- merge count calculation
- valid/invalid move detection
- spawn only after a board-changing move
- 90% `2` / 10% `4` spawn rule
- win/target detection
- game-over detection
- Endless and Zen continuation rules
- move-limit challenge expiry
- time-challenge expiry
- deterministic seeded RNG abstraction
- persisted RNG state
- deterministic undo/save integrity
- lightweight valid-direction hint heuristic

Important defects prevented/fixed:

- directional write switch cases explicitly terminate
- invalid moves never create new tiles
- `[2, 2, 4]` cannot chain into `8` in one move
- persisted/undo state restores RNG sequence rather than only visual board state
- repeated touch/keyboard requests are serialized by the controller to prevent mutation/persistence races

## Phase 3 — Core UI and controls

Implemented:

- branded splash screen with no artificial launch delay
- responsive Home screen
- mode selection
- responsive Game screen
- square 3×3 through 6×6 board layouts
- score / best / moves / highest-tile metrics
- remaining move count for Move Limit
- remaining seconds for Time Challenge
- touch swipe input with a minimum velocity threshold
- Arrow Key controls
- W/A/S/D controls
- Hint
- Undo
- Pause
- Restart
- win/continue dialog
- game-over/restart flow
- pause menu with Resume / Settings / Home
- adaptive text size for high-value tiles
- spawn/merge value transitions
- reduced-motion and platform animation-preference handling
- optional system sound feedback
- optional haptic feedback where supported

## Phase 4 — Save/resume, undo, and local data integrity

Versioned local persistence now stores:

- current board
- score / best score
- move count / merge count
- mode and board size
- target/challenge configuration
- status/win acknowledgement
- game start time
- deterministic RNG state
- bounded undo history up to 50 snapshots
- appearance/gameplay settings
- statistics
- achievements
- Daily Challenge history up to 60 records

Malformed current-game JSON fails safely instead of crashing startup. When the current saved game is malformed, its associated undo history is also removed rather than being applied to an unrelated future session.

Confirmed destructive-data controls exist for:

- current game reset
- statistics reset
- achievements reset
- complete 2048 Nova local-data reset

The complete reset removes only project-owned keys instead of wiping unrelated platform/application preferences.

## Phase 5 — Themes, personalization, and accessibility

Implemented appearance options:

- Light
- Dark
- System
- Classic Nova
- Midnight
- Neon
- Ocean
- Forest
- Sunset
- Monochrome
- High Contrast
- Reduced Motion

Implemented accessibility foundations:

- semantic tile labels
- exact visible tile values, so color is never the only indicator
- keyboard gameplay
- tooltips/labels on important controls
- responsive constrained layouts
- Flutter/system text scaling
- fitted high-value labels
- respect for `MediaQuery.disableAnimations`
- independently disableable sound and haptics
- semantic BMC support label

Detailed manual accessibility QA remains documented in `docs/ACCESSIBILITY.md` because automated tests do not replace physical assistive-technology testing.

## Phase 6 — Modes, statistics, achievements, and Daily Challenge

Implemented game modes:

1. Classic 4×4
2. Quick 3×3
3. Extended 5×5
4. Challenge 6×6
5. Endless
6. Target
7. Time Challenge
8. Move Limit
9. Daily Challenge
10. Zen

Target mode supports:

- 128
- 256
- 512
- 1024
- 2048
- 4096
- 8192
- 16384

Statistics implemented:

- games played
- games won
- win rate
- best score
- highest tile
- total moves
- total merges
- current streak
- best streak

Achievements include:

- first merge
- 128 / 256 / 512 / 1024 / 2048 / 4096 / 8192 milestones
- 10,000 / 50,000 score milestones
- 1 / 5 total-win milestones
- 1 / 7 Daily Challenge win milestones
- visible progress
- persistent unlocked state
- unlock dates

Daily Challenge:

- works offline
- derives deterministic seed from UTC `YYYYMMDD`
- persists score, moves, highest tile, completion, and win state
- maintains recent local history

## Phase 7 — Guide, project information, support, BMC, and privacy

Added in-app:

- detailed How to Play guide
- controls and merging explanation
- strategy guidance
- mode explanations
- feature/accessibility explanations
- About screen
- Support screen
- third-party license UI
- GitHub repository link
- GitHub profile link
- LinkedIn link
- both business email actions
- support email action
- Buy Me a Coffee support controls
- **Made by the Sanskar** branding

Buy Me a Coffee destination:

`https://buymeacoffee.com/sanskarIN`

It is explicitly presented as optional and does not interrupt game moves or imitate a payment form.

Default privacy behavior remains offline-first with no analytics SDK, advertising tracker, account system, or cloud synchronization.

## Phase 8 — Branding and platform runners

Original editable branding source:

- `assets/branding/2048_nova_logo.svg`

Generated branding exports include:

- Android launcher icons
- iOS AppIcon assets
- iOS launch images
- macOS AppIcon assets
- Windows multi-resolution ICO
- PWA 192×192 / 512×512 icons
- maskable PWA icons
- web favicon PNG
- `assets/branding/2048_nova_icon_1024.png`

### Branding generation evidence

- Workflow: `Bootstrap Branding Assets`
- Run: `31770394131`
- Result: **SUCCESS**
- Generated commit: `f2ffe3588fabec1a6c383132da04954bc7de5d02`
- Commit message: `feat: export branded platform icons and splash assets`

### Flutter platform-runner generation evidence

The first generated-runner push encountered a normal non-fast-forward race because other atomic commits reached `main` during the workflow. The workflow was fixed to clean the workspace, rebase on current `main`, and push normally. No force push was used.

- Workflow: `Bootstrap Flutter Platforms`
- Corrected run: `31769867015`
- Result: **SUCCESS**
- Generated commit: `7a1d039b8552692234c6519cc81895be65726489`
- Commit message: `build: generate Flutter platform runners`

Configured runners now exist for Android, iOS, Linux, macOS, and Windows, while Web is configured directly in the repository.

Native product metadata is branded as **2048 Nova**. Android launch backgrounds use the branded launcher asset.

## Phase 9 — Tests, analyzer, formatter, and Web build

Automated test files:

- `test/game_engine_test.dart`
- `test/game_state_test.dart`
- `test/local_store_test.dart`
- `test/daily_record_test.dart`
- `test/app_controller_test.dart`
- `test/widget_smoke_test.dart`

Coverage includes:

- all movement directions
- compression
- single and multiple merges
- no double/chained merge
- score/merge accounting
- invalid-move spawn prevention
- deterministic spawning/RNG state
- game over
- target win
- Move Limit
- deterministic Time Challenge expiry
- game-state serialization
- invalid board rejection
- save/resume
- persistent undo history
- malformed-save recovery
- scoped complete-data reset
- Daily Challenge persistence/record integrity
- settings persistence
- rapid/concurrent move serialization
- app startup and navigation
- theme selection
- requested mode availability

### Final quality-gate evidence

- Workflow: `CI`
- Run: `31770835591`
- Tested commit: `f3e7aaec6404139951425144cb1fb4d2fda66e27`
- Flutter: **3.47.0 stable**
- Dart: **3.11.0**
- Formatter: **PASS** — 28 files checked, 0 changed
- Analyzer: **PASS** — `No issues found!`
- Automated tests: **PASS — 29/29 tests**
- Web release build: **PASS** — `build/web` produced successfully
- Overall job result: **SUCCESS**

A previous test run correctly exposed a widget-test assumption: lazy `ListView` entries such as Daily Challenge and Zen were not built while offscreen. The test was fixed to scroll the list into view before asserting those entries, then the full quality gate passed.

A previous analyzer run also exposed two release blockers which were fixed before the successful run:

- explicit `PlayerStats()` constructor added
- unavailable Cupertino transition builder replaced with portable Flutter transition builders

## Phase 10 — Native release-build verification

The native build workflow executed on production-code commit:

`eacdb9dc04b4467271f98ce2104e60daf0124f6d`

Workflow:

- `Platform Builds`
- Run: `31770715273`
- Overall native build result: **SUCCESS**

### Android

- Job: `Android release APK`
- Job ID: `94675905971`
- `flutter build apk --release`: **SUCCESS**
- Release APK produced: `build/app/outputs/flutter-apk/app-release.apk`
- Reported artifact size: **48.9 MB**

The hosted runner emitted a non-fatal file-watcher exception after the APK had been built; the build command and job still completed successfully. This is recorded rather than hidden.

### Linux

- Job: `Linux release`
- Job ID: `94675905885`
- `flutter build linux --release`: **SUCCESS**
- Job result: **SUCCESS**

An earlier native-build run exposed an invalid underscore in the Linux GApplication ID (`com.sanskarin.nova_2048`). It was fixed to `com.sanskarin.nova2048`, and the corrected Linux release build passed.

### Windows

- Job: `Windows release`
- Job ID: `94675905908`
- `flutter build windows --release`: **SUCCESS**
- Job result: **SUCCESS**

### macOS

- Job: `macOS and unsigned iOS release`
- Job ID: `94675905949`
- `flutter build macos --release`: **SUCCESS**
- Output: `build/macos/Build/Products/Release/2048 Nova.app`
- Reported application size: **42.1 MB**

The Xcode build emitted the standard informational warning that the Flutter Assemble run-script phase has no declared outputs and therefore runs every build. It did not fail the release build.

### iOS

- Same Apple job: `94675905949`
- `flutter build ios --release --no-codesign`: **SUCCESS**
- Bundle identifier: `com.sanskarin.nova2048`
- Output: `build/ios/iphoneos/Runner.app`
- Reported application size: **16.2 MB**

This is deliberately an **unsigned** iOS release build. Real App Store/device deployment still requires Apple signing/provisioning outside this CI verification.

### Native build conclusion

All configured native release-build jobs completed successfully in GitHub Actions:

- Android: **PASS**
- Linux: **PASS**
- Windows: **PASS**
- macOS: **PASS**
- iOS unsigned: **PASS**

This verifies compilation/build configuration on hosted CI runners. It does **not** replace physical-device usability, store-signing, distribution, screen-reader, or long-session testing.

## Open-source and release-engineering files

Added/maintained:

- `README.md`
- `LICENSE`
- `.gitignore`
- `CONTRIBUTING.md`
- `CODE_OF_CONDUCT.md`
- `SECURITY.md`
- `CHANGELOG.md`
- `what_changed.md`
- `ROADMAP.md`
- `SUPPORT.md`
- `AUTHORS.md`
- `docs/ARCHITECTURE.md`
- `docs/GAME_ENGINE.md`
- `docs/PRIVACY.md`
- `docs/ACCESSIBILITY.md`
- `docs/DEPENDENCIES.md`
- `docs/TESTING.md`
- `docs/BRANDING.md`
- `docs/RELEASE_CHECKLIST.md`
- bug-report issue template
- feature-request issue template
- documentation issue template
- pull-request template
- Dependabot configuration
- quality CI workflow
- native-platform build workflow
- safe platform-runner generation workflow
- reproducible branding export workflow
- reproducible Dart formatting workflow
- reproducible dependency-lock workflow

### Formatting / dependency workflow evidence

- `Format Dart` run `31770549129`: **SUCCESS**
- Formatting commit: `8b79b4a12aa6cdb74232bc469d4ebb950be2f572` — `style: format Dart sources and tests`
- `Lock Flutter Dependencies` run `31770562267`: **SUCCESS**
- Lockfile commit: `7c4e2102ebeec5e9719221d77eb4eb07d122ae1c` — `build: lock Flutter dependencies`

## Commit strategy

Work was split into many meaningful atomic Conventional Commits instead of one giant commit. Examples:

- `chore: initialize 2048 Nova repository`
- `chore: configure Flutter project and strict linting`
- `feat: implement deterministic 2048 domain engine`
- `feat: preserve deterministic RNG state across saves and undo`
- `feat: add responsive accessible game board`
- `feat: add game screen controls timers and challenge UI`
- `feat: persist undo history across app restarts`
- `feat: add seven visual theme palettes`
- `feat: track daily challenge progress and history`
- `feat: expand achievements with progress metrics`
- `fix: serialize game moves to prevent input race conditions`
- `build: generate Flutter platform runners`
- `feat: export branded platform icons and splash assets`
- `fix: use valid Linux application identifier`
- `fix: add explicit player statistics constructor`
- `fix: use portable page transition builders`
- `test: scroll lazy mode list before asserting offscreen entries`
- `docs: update changelog for release candidate verification`

Artificial no-op or one-line spam commits were not created merely to inflate history.

## Dependency state

Runtime dependencies beyond Flutter:

- `shared_preferences`
- `url_launcher`

Development dependencies:

- `flutter_test`
- `flutter_lints`

CI reported newer versions for some transitive/development packages that are outside the currently resolved compatibility constraints. This is informational; the committed lockfile and current Flutter 3.47.0 build/test matrix passed. Dependabot is configured for ongoing updates.

No analytics, advertising, account, payment, telemetry, or cloud-sync SDK is present.

---

## Release-candidate completion report

```text
Project: 2048 Nova
Version: 0.9.0+1
Current phase: Release-candidate verification complete
Repository: https://github.com/sanskarIN/2048
Branch: main
Production build commit: eacdb9dc04b4467271f98ce2104e60daf0124f6d
Final quality-test commit: f3e7aaec6404139951425144cb1fb4d2fda66e27

Implemented:
- Deterministic 2048 engine
- 10 game modes
- Responsive touch/keyboard UI
- Save/resume and persistent deterministic undo
- Hints, pause, challenge timers/limits
- 7 palettes plus brightness/high-contrast/reduced-motion settings
- Optional sound/haptics
- Statistics and progress-based achievements
- Offline Daily Challenge history
- Guide/About/Support/BMC/contact integration
- Original logo, icons and splash branding
- Android/iOS/Web/Windows/macOS/Linux Flutter configuration
- Open-source documentation, templates and CI

Tests:
- 29/29 automated tests passed

Formatter:
- PASS — 28 files checked, 0 changed

Analyzer:
- PASS — No issues found

Builds:
- Web release: PASS
- Android release APK: PASS
- Linux release: PASS
- Windows release: PASS
- macOS release: PASS
- iOS unsigned release: PASS
- Platform runner generation: PASS
- Branding generation: PASS

Accessibility:
- Semantic tile labels
- Visible exact numeric values
- Keyboard controls
- High contrast
- Reduced motion + system animation preference
- Responsive text/layout foundations
- Disableable sound/haptics

Known release limitations:
- Physical-device and screen-reader manual QA has not been performed by this coding session.
- iOS CI build is unsigned and still requires normal Apple signing/provisioning for deployment.
- Store packaging/submission has not been performed.
- Android CI logged a non-fatal runner file-watcher exception after successfully producing the release APK.
- macOS CI logged a non-fatal Xcode run-script dependency-analysis warning.

Release decision:
- Keep version at 0.9.0+1 release-candidate line.
- Do not claim absolute zero bugs or physical-device production readiness solely from CI.
- Advance to 1.0.0 only after the remaining manual/device/store-release checklist is completed.
```

## Next optional expansion after stable validation

The current core release-candidate scope is implemented and objectively build/test verified. Future non-blocking expansion is documented in `ROADMAP.md`, including:

- expectimax/advanced AI demonstration
- replay/export/import
- localization and Hindi support
- deeper golden/visual regression testing
- broader physical-device/accessibility matrices
- additional challenge/customization systems

These optional features should not be added at the expense of core correctness or stability.


---

## 2026-08-14 — Phase 11 continued hardening, regression expansion, and final automated verification

The original Phase 10 completion report above is preserved as historical evidence of the earlier 29-test release-candidate state. This Phase 11 entry supersedes its test/build counts for the current code state.

### Scope completed in Phase 11

This continuation stayed on the `0.9.0+1` release-candidate line and prioritized correctness, state integrity, recoverability, accessibility, and regression coverage before any optional post-stable expansion.

Completed changes include:

- blocked game mutation after reaching a non-Endless target until the win is explicitly acknowledged;
- preserved already-counted win/streak state when continuing beyond a target and after application restart;
- applied terminal statistics when timed challenges expire without requiring another move;
- reconciled restored timed/challenge status during controller initialization before a stale session can be resumed;
- strictly validated persisted configuration types, enum values, board dimensions, target/limit ranges, random seeds, counters, scores, status, win acknowledgement, timestamps, and save schemas;
- retained legacy save-schema `0` migration while rejecting unsupported future schemas;
- sanitized malformed settings, statistics, and achievement timestamps to safe defaults;
- filtered persisted Undo snapshots that belong to another game session;
- preserved the legitimate lifetime best score during ordinary Undo;
- normalized retained Undo snapshots when Reset Statistics is used, preventing a later Undo/future move from resurrecting the pre-reset lifetime best;
- self-healed partially corrupt bounded Undo and Daily Challenge collections by retaining valid neighboring records and rewriting repaired storage;
- deduplicated Daily Challenge history by date/seed while preserving the strongest score/move pairing, peak tile, completion/win state, and newest update timestamp;
- prevented weaker Daily Challenge replays from downgrading a stronger saved result;
- required confirmation before replacing a recoverable current game from mode selection or Daily Challenge entry points;
- removed misleading Continue behavior for terminal lost saves;
- protected terminal win/game-over dialogs from accidental outside-tap or route-back dismissal;
- upgraded the Hint feature from a simple valid-direction choice to a deterministic heuristic evaluation using empty-cell mobility, immediate merge value, highest-tile corner placement, monotonicity, smoothness, and deterministic tie-breaking;
- kept hint evaluation read-only and independent from the persisted game RNG;
- suppressed gameplay hints for terminal states;
- added desktop shortcuts for Hint (`H`), Undo (`U`), Pause (`P`/Escape), and Restart (`R`) in addition to Arrow/WASD movement;
- limited the one-second challenge status refresh loop to timed games only;
- added board-dimension semantics plus distinct row/column/value-or-empty semantic nodes for every board cell;
- excluded duplicate visual tile-text semantics so assistive technology receives the intended positional/value label once per cell;
- expanded lifetime statistics with average moves and average merges;
- clarified active-session-safe Reset Statistics behavior in Settings;
- added direct in-app GitHub bug-report-template access;
- added in-app release notes and credits;
- expanded architecture, testing, accessibility, roadmap, release-checklist, README, changelog, guide, and hint-solver documentation;
- removed failed/temporary one-time workflow files so the permanent workflow set remains limited to the normal branding/platform bootstrap, CI, formatting, dependency-lock, and native-build workflows.

### Expanded automated regression suite

The current automated suite contains 81 tests across the original and newly added/expanded files.

Coverage now includes:

- exact movement/compression/merge rules and no chained double merge;
- valid-move spawning and invalid-move spawn prevention;
- deterministic RNG restoration;
- target-win movement blocking before acknowledgement;
- game-over, move-limit, and deterministic time-limit behavior;
- strict `GameConfig` parsing and bounds;
- save-schema migration and rejection of invalid/future state;
- score/status/acknowledgement/timestamp invariants;
- settings/statistics/achievement corruption recovery;
- save/resume and bounded Undo persistence;
- stale Undo session filtering;
- lifetime best-score preservation through ordinary Undo;
- Reset Statistics → Undo isolation from historical best-score data;
- local collection self-repair;
- Daily Challenge record validation, deduplication, and replay-best preservation;
- restored timed-game expiry reconciliation;
- win/streak integrity across continue, loss, and relaunch;
- deterministic hint quality boundaries and board immutability;
- terminal hint suppression;
- external URI allowlist behavior;
- recoverable-game replacement confirmation;
- terminal Home state;
- keyboard shortcuts and terminal dialog route-back protection;
- board-size and positional tile accessibility semantics;
- app startup/navigation, theme selection, and game-mode availability.

New or expanded regression files include:

- `test/game_types_test.dart`
- `test/session_integrity_test.dart`
- `test/restored_challenge_status_test.dart`
- `test/hint_solver_test.dart`
- `test/hint_state_test.dart`
- `test/daily_replay_history_test.dart`
- `test/undo_best_score_test.dart`
- `test/statistics_reset_undo_test.dart`
- `test/home_screen_state_test.dart`
- `test/game_replacement_guard_test.dart`
- `test/game_screen_interaction_test.dart`
- `test/game_board_accessibility_test.dart`

### Real intermediate CI failures found and fixed

Failures were treated as defects/evidence rather than hidden behind later runs.

1. **CI run `31773193609` — analyzer failure**
   - Formatting passed.
   - Static analysis failed after a controller test referenced `ThemeMode` without the required Material import.
   - Commit `21c08cb6df5b89f9cbac3f9a65a6ac164404fef3` (`fix: import material theme mode in controller tests`) corrected the regression.

2. **CI run `31775439842` — 79 passed / 2 failed**
   - Formatting passed.
   - Static analysis passed.
   - Two focused tests exposed real/current hardening gaps:
     - board-size accessibility semantics were not discoverable as the expected distinct board node;
     - Reset Statistics followed by Undo could restore an old `bestScore` from an Undo snapshot (`expected 4`, actual `9999` in the focused regression).
   - The statistics/Undo defect was fixed by commit `41a13e1dcbea1ec78b710e1a356c4fb32d952f96` (`fix: keep statistics reset isolated from undo history`).
   - The board semantic hierarchy was then refined in focused accessibility commits.

3. **CI run `31777176056` — 80 passed / 1 failed**
   - Formatting passed across 47 files with 0 changes.
   - Analyzer reported no issues.
   - The statistics-reset/Undo regression passed.
   - The only remaining failure showed the exact positional tile label was still merged with visual text semantics.
   - This led to the explicit `excludeSemantics` correction.

4. **CI run `31777275966` — 80 passed / 1 failed**
   - Formatting passed across 47 files with 0 changes.
   - Analyzer reported no issues.
   - The accessibility label assertions themselves passed.
   - The remaining failure was a test-harness cleanup issue: the `SemanticsHandle` was disposed too late by teardown.
   - Commit `1ecbf0881f723af1829fda523752562660a86a98` changed the accessibility test to dispose the handle in `finally` before end-of-test verification.

### Final Phase 11 quality gate

Final current source/test verification:

```text
Workflow: CI
Run: 31777374553
Commit: 1ecbf0881f723af1829fda523752562660a86a98
Flutter: 3.47.0 stable
Dart: 3.13.0

Formatting:
PASS — 47 files checked, 0 changed

Static analysis:
PASS — No issues found

Automated tests:
PASS — 81/81 tests

Web release build:
PASS — build/web produced successfully

Overall CI job:
SUCCESS
```

The Web build also completed its WASM dry run successfully. It emitted the existing informational CupertinoIcons-font lookup warning while still producing the release build; the project does not directly reference `CupertinoIcons`.

### Final production-code native release-build verification

The last production-code change in this hardening sequence was:

`b95d0a630521f896016dff733c8c4f9dc1e082e3` — `fix: isolate tile semantics from visual text`

Native matrix:

```text
Workflow: Platform Builds
Run: 31777275982
Production-code commit: b95d0a630521f896016dff733c8c4f9dc1e082e3
```

Jobs:

- Android release APK: **SUCCESS**
- Linux release: **SUCCESS**
- Windows release: **SUCCESS**
- macOS release: **SUCCESS**
- iOS release without signing: **SUCCESS**

This confirms the accessibility production-code change did not break any configured native release build. The iOS build is intentionally unsigned; Apple signing/provisioning credentials are not committed.

### Phase 11 selected commit trail

Representative meaningful commits from this continuation include:

- `21c08cb6df5b89f9cbac3f9a65a6ac164404fef3` — `fix: import material theme mode in controller tests`
- restored timed challenge reconciliation and regression coverage;
- lifetime best-score Undo preservation and test coverage;
- Daily replay best-result preservation and test coverage;
- terminal dialog explicit-choice protection and tests;
- context-aware desktop keyboard shortcuts;
- timed-only challenge refresh loop;
- deterministic heuristic hint improvements, tests, and documentation;
- expanded lifetime statistics with averages;
- direct in-app GitHub bug-report-template action;
- Daily history deduplication and strongest-record regression coverage;
- `41a13e1dcbea1ec78b710e1a356c4fb32d952f96` — `fix: keep statistics reset isolated from undo history`
- `583f1bbfc9892fb45d0152a6fd35353bd83081f9` — `fix: expose board and tile semantics as distinct nodes`
- `b95d0a630521f896016dff733c8c4f9dc1e082e3` — `fix: isolate tile semantics from visual text`
- `1ecbf0881f723af1829fda523752562660a86a98` — `test: dispose accessibility semantics before verification ends`
- `120f18104ece4f3f88d18e3468d88d77710557e6` — `docs: document statistics reset undo regression coverage`
- `62f98d20ffc96666747e3c52422e7eb8e997a3db` — `docs: clarify distinct game board semantics nodes`
- `7460b4e839ca1fc7f7f8891c5b97c0a9627be2fb` — `docs: align roadmap with verified release candidate state`
- `d45ebc33f4ab7ab279224badfb795f600cdd571d` — `docs: record final phase eleven regression fixes`
- `28f33b772edc38bfe4fc8e3fdb3403ac992aea57` — `docs: separate automated and manual release gates`

The repository continues to favor small coherent Conventional Commits over artificial no-op commit spam.

### Current permanent workflow set

After cleanup, the normal permanent workflow directory contains:

- `.github/workflows/bootstrap-branding.yml`
- `.github/workflows/bootstrap-platforms.yml`
- `.github/workflows/ci.yml`
- `.github/workflows/format-code.yml`
- `.github/workflows/lock-dependencies.yml`
- `.github/workflows/platform-builds.yml`

Temporary/finalizer workflows used during development were removed and are not part of the final maintained automation surface.

### Dependency/update state

The verified Flutter 3.47.0 run reports newer versions available for some development/transitive packages, including `flutter_lints` 6.0.0 while the project remains on the resolved `flutter_lints` 5.x constraint.

Dependabot PR #1 proposes the `flutter_lints` major update but is currently stale/non-mergeable against the evolved `main` branch. It was not force-merged merely to use the newest version. Dependency updates remain deliberate and must preserve the verified analyzer/test/build state.

No TODO, FIXME, or `UnimplementedError` markers were found in the current indexed repository code during the final audit. No project API key was found by the corresponding repository code search.

### Updated release-candidate status

```text
Project: 2048 Nova
Version: 0.9.0+1
Repository: https://github.com/sanskarIN/2048
Branch: main

Current automated code quality:
- Formatter: PASS
- Analyzer: PASS
- Automated tests: 81/81 PASS
- Web release: PASS

Current configured native build matrix:
- Android release APK: PASS
- Linux release: PASS
- Windows release: PASS
- macOS release: PASS
- iOS unsigned release: PASS

Core/priority implementation:
- Deterministic 2048 engine: implemented
- Save/resume and deterministic Undo: implemented and hardened
- Touch + keyboard gameplay: implemented
- Responsive board: implemented
- Win/game-over/new-game flows: implemented and hardened
- Themes/accessibility/settings: implemented
- Statistics/achievements: implemented
- Daily Challenge: implemented and hardened
- Hint system: implemented as deterministic heuristic
- Guide/About/Support/BMC/contact: implemented
- Branding/platform runners/open-source docs/CI: implemented

Release decision:
- Remain at 0.9.0+1 until manual/device/distribution qualification is complete.
- Do not claim absolute zero bugs from automation alone.
```

### Remaining manual boundaries before 1.0.0

The code/build verification above is intentionally separated from manual release qualification. Remaining stable-release checks include:

- physical Android and iOS gameplay, lifecycle, background/foreground, termination, and save-resume testing;
- touch/gesture behavior on representative screen sizes and orientations;
- VoiceOver, TalkBack, and representative desktop/browser screen-reader verification;
- real keyboard focus/order/shortcut behavior on representative desktop/browser environments;
- large-text/high-contrast/reduced-motion checks on real platforms;
- long-session Undo, Daily, timed, move-limit, target-win/continue, and restart testing;
- real browser and email-handler verification for external actions;
- native splash/icon visual review;
- Android distribution signing;
- Apple signing/provisioning;
- final store/package artifacts, privacy/data-safety metadata, listing text, and screenshots where required.

Optional localization, replay/export/import, advanced AI demonstration, golden/visual-regression matrices, richer mode-specific records, and additional PWA/desktop convenience features remain post-stable enhancements. They are non-blocking by design and must not destabilize the verified core.


---

## 2026-08-14 — Phase 12 optional Auto Play / AI Demonstration

Phase 12 continues the source prompt's optional-expansion track without changing the release-candidate version from `0.9.0+1`. The implementation follows the specification's explicit Auto Play / AI Demonstration requirements: clear labeling, pause/resume, speed selection, separation from personal statistics/achievements, and algorithm documentation.

### Source requirement implemented

The project master prompt requires an optional demonstration mode that can play automatically using a heuristic or expectimax-style solver while:

- clearly labeling the feature as Auto Play or AI Demo;
- allowing pause/resume;
- allowing speed selection;
- keeping demonstration results separate from legitimate personal statistics/achievements;
- documenting the algorithm in the guide;
- keeping optional advanced work isolated so it does not destabilize the core project.

Phase 12 implements the heuristic form using the already-tested deterministic Hint solver. It does **not** present the feature as machine learning or guaranteed-optimal play.

### Architecture

Added `lib/domain/autoplay_session.dart`.

`AutoplaySession`:

- owns its own `GameConfig`, `GameEngine`, and `GameState`;
- defaults to deterministic seed `2048` and a 4×4 Endless sandbox;
- requests the existing deterministic `GameEngine.hint()` recommendation;
- applies the recommendation only to its own sandbox state;
- tracks its own last direction;
- recreates the seeded engine/state on Reset;
- does not import or depend on `AppController`, SharedPreferences, Flutter UI, analytics, network services, or cloud services.

This creates an explicit boundary between:

- **Hint** — suggestion-only behavior on the player's current game; and
- **Auto Play Demo** — automatic movement only inside an isolated in-memory demonstration session.

The demo has no local-storage key. Closing the screen discards its sandbox state.

### Auto Play user experience

Added `lib/features/solver_demo/solver_demo_screen.dart` and registered route `/solver-demo`.

Home now contains a clearly labeled **Auto Play Demo** entry.

The screen provides:

- title `Auto Play Demo`;
- heading `Deterministic heuristic AI demonstration`;
- explicit explanation that the feature is local heuristic automation rather than machine learning or guaranteed optimal play;
- explicit explanation that it never modifies the player's saved game, lifetime statistics, achievements, or Daily Challenge history;
- demo-only metrics: Demo score, Demo moves, Highest, Last move;
- `Auto Play` / `Pause` control;
- one-move `Step` control;
- `Reset seed` control;
- speed choices of 1, 2, or 4 moves per second;
- periodic autoplay timer that stops on Pause, terminal state, reset, or widget disposal;
- responsive reuse of the accessible `GameBoard` renderer;
- reduced-motion behavior inherited from application settings;
- semantic running/paused/completed state labels.

Changing speed while Auto Play is active safely cancels and recreates the periodic timer at the chosen interval.

### Player-data isolation

The demo intentionally never calls:

- `AppController.newGame()`;
- `AppController.move()`;
- `LocalStore.saveGame()`;
- lifetime-statistics mutation paths;
- achievement unlock paths;
- Daily Challenge history update paths.

The normal player controller may still be read for appearance/reduced-motion settings, but the demonstration game itself is not stored in or written through the player controller.

### Automated tests added

Added `test/autoplay_session_test.dart` covering:

- deterministic reset to the original starting board and RNG state;
- matching seeded sessions producing matching direction, board, score, move-count, and RNG sequences;
- alternate sandbox board size support;
- session behavior remaining outside application persistence/statistics orchestration.

Added `test/solver_demo_screen_test.dart` covering:

- Home navigation into Auto Play Demo;
- clear AI-demonstration labeling;
- single-step execution;
- seed reset;
- player `gamesPlayed`, `totalMoves`, and lifetime `bestScore` remaining unchanged;
- player `AppController.game` remaining null during demo-only operation;
- speed selection from 2 moves/sec to 4 moves/sec;
- Auto Play start;
- Pause availability;
- Pause preventing later timer ticks from advancing the sandbox.

The total automated suite increased from 81 to **86 tests**.

### Documentation updated

Updated:

- `README.md` — Auto Play feature, controls, architecture, privacy/isolation, and no external AI dependency;
- `lib/features/guide/guide_screen.dart` — Auto Play / AI Demo explanation and algorithm boundary;
- `docs/HINT_SOLVER.md` — `AutoplaySession` architecture, controls, determinism, isolation, and tests;
- `docs/ARCHITECTURE.md` — Auto Play domain/feature/persistence boundaries;
- `docs/TESTING.md` — Auto Play domain/widget regression coverage and current 86-test evidence;
- `CHANGELOG.md` — release-facing Auto Play feature and Phase 12 verification evidence;
- `docs/VERIFICATION.md` — current Phase 12 quality/native evidence;
- `docs/RELEASE_CHECKLIST.md` — automated Auto Play checks and remaining real-platform/manual qualification;
- `ROADMAP.md` — heuristic Auto Play marked complete while advanced expectimax/benchmark work remains optional.

### Meaningful Phase 12 commit trail

Key commits include:

- `5bda247947bd6c2582acc0e681be3ae3ef5849a4` — `feat: add isolated deterministic autoplay session`
- `ed57608b1d5f16caf9119e841fdf566891559674` — `test: cover deterministic autoplay session isolation`
- `aac49bd890e7ab0d0bb06120622c2eb0b49bfba4` — `feat: add isolated solver autoplay demo screen`
- `59da74daf76eada3f8021f128c5a50a35e6ad054` — `fix: keep solver demo board extent strongly typed`
- `a03edb96065c6e9b183a23a257482b46a76260a0` — `feat: register solver demo route`
- `ac794af068ef2529d949482f25be346a0254c2ec` — `feat: surface solver demo from home`
- `92feaf2ccbcefee1d35170c6f2d17508c2c0430c` — `test: cover solver demo controls and player data isolation`
- `2d16065c8a74963da491d3098bb72c82a96efc06` — `test: read solver metrics from rendered text widgets`
- `d28041eda59e02edb7fdb93a5d1ce0f76170336d` — `feat: label solver sandbox as auto play demo`
- `e2301c8a60f67548911c36d71edd70217a7ad9fd` — `feat: label sandbox entry as auto play demo`
- `b9905d49b7af6705c4aa00590bbe67f2a9a50022` — `test: align auto play demo labels with specification`
- `d91ea1d5daa8b3f1704df142e3302df2d5080758` — `test: verify auto play speed selection and pause behavior`
- `759cefc23bdc0a3a0ebb723a6992ee0a09a0394a` — `docs: explain solver demo inside the game guide`
- `a1cc17836834750c542c69ffdf3c5e582d4e43ab` — `docs: align guide with auto play demo naming`
- `9389a18a07fbbdecdafde0ebbc2335feb1ea7e39` — `docs: document solver autoplay architecture`
- `c8982c81035936c6e1c81a3c7fe28ad220a9eb64` — `docs: record solver demo isolation boundary`
- `73865d7ef881e9693c3e3a220a606b5ab74b40c7` — `docs: document isolated auto play demo`
- `1d98042558ab7ffe40c9da4ad42dbbf8263dcaf6` — `docs: mark heuristic auto play demo complete`
- `5120cb24c2071b86e44674351dcdf29296b41503` — `style: format Dart sources and tests`
- `5bd36e800d40725980b3a09ec6a94bfb055ee89a` — `docs: add auto play regression coverage`
- `7dd9b35fb5e7d0eff134bdb0fe15b21a6c576ff4` — `docs: record isolated auto play demonstration`
- `269a216aa35ab00ea2018053c63b97c2b0100a82` — `docs: advance verification manifest through auto play phase`
- `865c250ee1bb5fda9e518c6e17eae693e977372a` — `docs: add auto play release qualification checks`

### Transparent intermediate formatting failure

CI run `31778424231` failed at the formatting verification step after the Auto Play source/test files contained Dart-format differences. Static analysis, tests, and Web build were skipped by that run because formatting is intentionally the first gate.

The permanent `Format Dart` workflow run `31778424259` succeeded and produced commit:

`5120cb24c2071b86e44674351dcdf29296b41503` — `style: format Dart sources and tests`

No behavior was hidden or bypassed. The final quality run below verified the formatted state independently.

### Final Phase 12 quality verification

```text
Workflow: CI
Run: 31778558429
Verified commit: 1d98042558ab7ffe40c9da4ad42dbbf8263dcaf6
Flutter: 3.47.0 stable
Dart: 3.13.0
Formatting: PASS — 51 files checked, 0 changed
Static analysis: PASS — No issues found
Automated tests: PASS — 86/86
Web release build: PASS — build/web
WASM dry run: PASS
Overall CI job: SUCCESS
```

The Web build emitted the existing informational CupertinoIcons font lookup warning while still producing `build/web` successfully. The project does not directly reference `CupertinoIcons`.

### Final Phase 12 native build verification

```text
Workflow: Platform Builds
Run: 31778424208
Verified commit: a1cc17836834750c542c69ffdf3c5e582d4e43ab
```

Results:

- Linux release: **SUCCESS**
- Windows release: **SUCCESS**
- macOS release: **SUCCESS**
- iOS release without signing: **SUCCESS**
- Android release APK: **SUCCESS**

The native verified commit contains the Auto Play production code. Later Phase 12 commits changed tests, documentation, naming documentation, or Dart formatting without changing the underlying demo behavior.

The iOS build remains deliberately unsigned. Real Apple signing/provisioning is a manual distribution boundary.

### Phase 12 status

```text
Project: 2048 Nova
Version: 0.9.0+1
Phase: 12 — optional heuristic Auto Play / AI Demonstration implemented

Auto Play architecture: implemented
Auto Play clear labeling: implemented
Pause/resume: implemented
Single-step: implemented
Speed selection: implemented
Deterministic reset: implemented
Player-statistics separation: implemented and tested
Player-save separation: implemented and tested
Daily/achievement separation: architectural boundary documented
Guide/algorithm documentation: implemented
Formatter: PASS
Analyzer: PASS
Automated tests: 86/86 PASS
Web release: PASS
Configured native builds: PASS
```

### Remaining manual boundaries before stable 1.0.0

Phase 12 does not change the existing stable-release boundary. Manual qualification still includes:

- Auto Play navigation, timer start/pause/resume, speed changes, reset, navigation-away cleanup, responsive layout, and reduced-motion behavior on representative real platforms;
- Auto Play board/control/metric semantics with representative real screen readers;
- physical Android/iOS player gameplay and lifecycle/save-resume checks;
- representative touch/orientation/keyboard/focus/large-text/high-contrast/reduced-motion checks;
- long-session Undo, Daily, timed, move-limit, target-win/continue, and restart testing;
- real browser/email external handlers;
- native splash/icon review;
- Android distribution signing;
- Apple signing/provisioning;
- final package/store privacy/listing/screenshot review.

### Next safe optional expansion

The source prompt's remaining Phase 11+ options include replay/move history, export/import saves, shareable seeded challenges, localization readiness, advanced expectimax/benchmark work, and additional PWA/desktop improvements. Any such feature must continue to preserve the verified core, add focused tests, and remain truthful about manual release boundaries.


---

## 2026-08-14 — Phase 13 read-only Move Replay / move-history viewer

Phase 13 implements the source prompt's optional replay/move-history/spectator expansion while preserving the existing `0.9.0+1` release-candidate boundary. The design deliberately reuses the already-validated bounded Undo history instead of adding another persistence schema, and the replay viewer is read-only by construction.

### Replay domain architecture

Added `lib/domain/replay_timeline.dart`.

`ReplayTimeline.build()` receives the authoritative current game plus validated persisted Undo snapshots and creates a spectator timeline by:

1. requiring every retained snapshot to match the current session's start timestamp and complete configuration identity;
2. rejecting snapshots whose moves, merge count, or score represent progress beyond the current game;
3. collapsing duplicate move-number frames;
4. sorting retained frames by move count;
5. making a defensive copy of every retained `GameState`;
6. making the current game the authoritative final frame;
7. returning an unmodifiable list so viewer code cannot replace or append frames.

The timeline comparison includes mode, board size, target, move limit, time limit, seed, and session start time. This protects Replay from stale snapshots that belong to a previous game.

Replay introduces **no new persistence key or schema**. Its storage source remains the existing bounded Undo history plus current game. Because Undo history is intentionally bounded, a very long game's replay may begin at the earliest still-retained snapshot rather than move zero. The UI explicitly discloses this instead of implying a complete lifetime history.

### Replay user experience

Added `lib/features/replay/replay_screen.dart` and route `/replay`.

Home now shows **Move Replay** whenever a saved game exists, including a terminal/lost saved game. This does not change the existing Continue rule: Continue remains hidden for a lost game.

The Replay screen provides:

- title `Move Replay`;
- explicit `Read-only spectator replay` explanation;
- retained Frame, Move, Score, and Highest metrics;
- the same responsive/accessibility-aware `GameBoard` renderer used by gameplay;
- first retained frame navigation;
- previous frame navigation;
- next frame navigation;
- latest/current frame navigation;
- slider scrubbing across retained frames;
- `Play Replay` / `Pause Replay`;
- 1, 2, or 4 frames per second playback choices;
- frame status and merge count;
- safe empty state when the route is opened without a current game;
- safe load-error state with Retry;
- bounded-history explanation when the earliest retained move is later than move zero;
- timer cancellation on Pause, end-of-timeline, and widget disposal.

Playback/scrubbing operate only on defensive frame copies. The screen never calls `AppController.move`, `AppController.undo`, player save mutation, statistics mutation, achievement mutation, or Daily history mutation.

### Replay automated coverage

Added `test/replay_timeline_test.dart` covering:

- active-session filtering;
- stale-session rejection;
- future move/merge/score rejection;
- chronological ordering;
- duplicate move-number collapse;
- current frame authority;
- defensive copied boards/state;
- unmodifiable returned frame list.

Added `test/replay_screen_test.dart` covering:

- Home navigation into Move Replay;
- first/next/latest frame navigation;
- live game board remaining unchanged while replay frames are viewed;
- live game score remaining unchanged;
- live game move count remaining unchanged;
- live RNG state remaining unchanged;
- timed playback advancing frames;
- Pause stopping later timer ticks;
- safe empty route behavior when no current game exists.

The total automated suite increased from 86 to **92 tests**.

### Transparent intermediate Replay CI failure

CI run `31779369661` passed formatting and static analysis but completed the test step with:

```text
90 tests passed
2 tests failed
```

Both failures were in Replay widget tests. The tests attempted to tap `Next frame` and `Play Replay` while those controls were below Flutter's default 800×600 widget-test viewport. The production Replay body is intentionally scrollable, so the taps missed their targets rather than exposing a production Replay logic failure.

Commit:

`501b2a512c2f185461129f2e294504e43e883d59` — `test: scroll replay controls before widget taps`

changed the tests to scroll the controls into view before tapping them. The final 92-test gate then passed. This real intermediate failure remains documented instead of being hidden behind the later successful run.

### Phase 13 formatting work

The permanent Format Dart workflow produced formatting commits during the early Replay source/test sequence:

- `4f86cb5e363f76e936e7d2db5198d0fe40790772` — `style: format Dart sources and tests`
- `33e7f59c1ddc4326ec07545937a3412a2796e107` — `style: format Dart sources and tests`

The final quality gate independently confirmed that all 55 Dart source/test files were formatter-clean with 0 changes required.

### Final Phase 13 quality verification

```text
Workflow: CI
Run: 31779838751
Verified commit: 278ba039d0b7b59ce54c72c5ed0fcd0401ba537a
Flutter: 3.47.0 stable
Dart: 3.13.0
Formatting: PASS — 55 files checked, 0 changed
Static analysis: PASS — No issues found
Automated tests: PASS — 92/92
Web release build: PASS — build/web
WASM dry run: PASS
Overall CI job: SUCCESS
```

The Web build emitted the existing informational CupertinoIcons font lookup warning while still producing `build/web` successfully. The project does not directly reference `CupertinoIcons`.

The dependency resolver also continued to report newer versions outside the current constraints (`flutter_lints` 6.0.0, `lints` 6.1.0, `material_color_utilities` 0.13.1, and `test_api` 0.7.13). They were not blindly upgraded during Replay hardening because the verified release-candidate dependency state remains stable and Dependabot review is separate from feature implementation.

### Final Phase 13 native release-build verification

The final Replay production/UI state requiring native compilation was:

`4f3cc6f55ae6b2f50b4758db22569b7ec48ddafd` — `docs: explain read-only move replay in game guide`

Although that commit message is documentation-oriented, the guide lives under `lib/` and is compiled into the application; it also contains all preceding Replay production code.

Native matrix:

```text
Workflow: Platform Builds
Run: 31779566057
Verified production commit: 4f3cc6f55ae6b2f50b4758db22569b7ec48ddafd
```

Results:

- Linux release: **SUCCESS**
- Windows release: **SUCCESS**
- Android release APK: **SUCCESS**
- macOS release: **SUCCESS**
- iOS release without signing: **SUCCESS**

The Apple build remains intentionally unsigned. Real signing/provisioning credentials are not committed to the repository.

### Phase 13 documentation updated

Updated:

- `README.md` — Move Replay feature, read-only/bounded-history behavior, architecture, privacy, and accessibility wording;
- `lib/features/guide/guide_screen.dart` — Move Replay usage, controls, bounded-history disclosure, and immutability guarantee;
- `docs/ARCHITECTURE.md` — Replay domain, feature, persistence, and session boundaries;
- `docs/TESTING.md` — Replay domain/widget coverage, transparent intermediate failure, final 92-test evidence, and native matrix;
- `docs/ACCESSIBILITY.md` — Replay board/slider/control/manual screen-reader qualification;
- `docs/PRIVACY.md` — Replay defensive-copy/local-only behavior and Auto Play sandbox privacy boundary;
- `docs/RELEASE_CHECKLIST.md` — Replay automated/manual/accessibility qualification items;
- `docs/VERIFICATION.md` — current Phase 13 quality/native evidence and historical progression;
- `CHANGELOG.md` — release-facing Replay feature, fixes, and objective verification evidence;
- `ROADMAP.md` — bounded read-only Move Replay marked implemented; full-session export/import remains later optional work.

### Meaningful Phase 13 commit trail

Key commits include:

- `8499b1498d696240447fa06002414d75b1a0d22f` — `feat: add read-only replay timeline builder`
- `6285eb415516dcfc0c419e464e1863ef209b086b` — `test: cover replay timeline filtering and immutability`
- `4f86cb5e363f76e936e7d2db5198d0fe40790772` — `style: format Dart sources and tests`
- `fc83fe07c924710e3087e60da783565f89f1003e` — `feat: add read-only move history replay screen`
- `bfc9358b96790aa47caa422a152983642f5c63ea` — `feat: register move replay route`
- `7afeedfdbd5d9e4de2b11576b33bccc3cc8d1f77` — `feat: surface read-only replay for saved games`
- `33e7f59c1ddc4326ec07545937a3412a2796e107` — `style: format Dart sources and tests`
- `6f845c6deb222ff6f86dda4c42291204e84a425f` — `fix: keep replay frame index strongly typed`
- `26316479c1762086a6c3787302f282dc833e2ea7` — `test: cover read-only replay controls and game isolation`
- `0f761c0531cd47faaccb779c420e32aef33ead93` — `test: keep replay fixture shifts strongly typed`
- `7d4ffc376d6a10e4829a6b02c862f2ca533b0f98` — `test: navigate replay route through navigator state`
- `501b2a512c2f185461129f2e294504e43e883d59` — `test: scroll replay controls before widget taps`
- `4f3cc6f55ae6b2f50b4758db22569b7ec48ddafd` — `docs: explain read-only move replay in game guide`
- `385538c838fb1b60a247c600ceb6c2434cc8737b` — `docs: record read-only replay architecture boundary`
- `6d10635453da3d82671283acc434b07ca30fb417` — `docs: mark read-only move replay implemented`
- `05a9563fac3d84ca497c65995bbc711286647a18` — `docs: document read-only move replay feature`
- `1b9c3612bb1438971febaccc9a5d07f86d8d5b3d` — `docs: add replay accessibility qualification`
- `aac83f90d635e8056cc21ceca50189ad2daeb391` — `docs: add read-only replay regression strategy`
- `278ba039d0b7b59ce54c72c5ed0fcd0401ba537a` — `docs: add move replay release qualification checks`
- `ff3cde390b88f4d0a1bc2d2a7d0a7c6e56eecd97` — `docs: clarify replay and auto play local data boundaries`
- `9ff2be684df1c166156f58ac0a07ee70ff446d0e` — `docs: record final replay quality gate`
- `096368e2f6048fe3ec8df917ad59e5676804f26c` — `docs: advance verification manifest through move replay phase`
- `b1970f2e378a6edeaef0fbe4ce160d40af928b42` — `docs: record read-only move replay and verification`

The repository continues to use meaningful small Conventional Commits; no-op commit spam was not used merely to inflate commit count.

### Updated release-candidate state after Phase 13

```text
Project: 2048 Nova
Version: 0.9.0+1
Phase: 13 — read-only Move Replay implemented

Core engine: implemented and hardened
Save/resume + deterministic Undo: implemented and hardened
Daily Challenge: implemented and hardened
Statistics/achievements: implemented
Accessibility foundations: implemented and expanded
Heuristic Hint: implemented and deterministic
Auto Play Demo: implemented, isolated, and verified
Move Replay: implemented, read-only, bounded, and verified
Formatter: PASS
Analyzer: PASS
Automated tests: 92/92 PASS
Web release build: PASS
Configured native release builds: PASS
```

### Remaining manual boundaries before stable `1.0.0`

Phase 13 does not remove the existing manual stable-release qualification. Remaining work includes:

- physical Android/iOS gameplay, lifecycle, background/foreground, termination, and save-resume checks;
- real-platform Move Replay slider/first/previous/next/latest/play/pause/speed behavior;
- Replay navigation-away timer cleanup and comparison of saved state before/after real interaction;
- Replay bounded-history wording and layout on long retained timelines;
- Replay control/slider/board semantics with VoiceOver, TalkBack, and representative desktop/browser screen readers;
- real-platform Auto Play timer/start/pause/resume/speed/reset/navigation-away behavior;
- representative touch, orientation, keyboard, focus, large-text, high-contrast, and reduced-motion checks;
- long-session Undo, Daily, timed, move-limit, target-win/continue, and restart testing;
- real external browser/email handlers;
- native splash/icon visual review;
- Android distribution signing;
- Apple signing/provisioning;
- final package/store privacy/data-safety/listing/screenshot review.

### Next safe optional expansion

The remaining source-listed optional expansion areas include validated save export/import, shareable seeded challenge codes, localization readiness, advanced solver benchmarking behind the existing isolated Auto Play boundary, golden/visual-regression matrices, and additional PWA/desktop convenience work. Any next phase must remain isolated, tested, and truthful about manual/device boundaries.


## Phase 14 — Portable Current-Game Backup/Restore + Complete Documentation

Phase 14 completes the next optional data-portability feature and expands the repository into a complete user, maintainer, platform, testing, security, privacy, and release documentation set. The project remains `0.9.0+1` release candidate; this phase does not claim universal zero-bug or physical-device/store readiness.

### Trust model

Portable/editable JSON is not trusted proof of lifetime progress. The feature restores one current game only and deliberately excludes lifetime statistics, achievements, streaks, Daily history, settings, and old Undo history.

Every confirmed portable import becomes a locally controlled **unranked session**. The restored board remains playable, saveable, and can create new Undo snapshots, but imported progress cannot inflate trusted local records.

### Portable backup codec

Added `lib/domain/game_backup.dart` with envelope version 1:

```json
{
  "format": "2048-nova-game-backup",
  "version": 1,
  "exportedAt": "<ISO-8601 timestamp>",
  "game": { "...": "GameState JSON" }
}
```

Current policy:

```text
format: 2048-nova-game-backup
version: 1
maximum encoded input: 128 KiB
```

Import rejects empty/oversized text before parsing, malformed/non-map JSON, wrong format, unsupported version, invalid export timestamp, missing game data, and any embedded state rejected by strict `GameState.fromJson()` validation.

### Persistent unranked marker

`LocalStore` now owns `nova.current_game_unranked.v1`. The marker is intentionally outside portable `GameState`, so edited backup text cannot choose trusted ranking status.

It persists a confirmed import across restart and is removed/reset when the current game is cleared, corrupt-current-game recovery removes the save, all project data is cleared, or a normal new local game replaces the imported session. Malformed non-boolean marker data fails safely and is removed.

### AppController imported-session policy

Added `_currentGameUnranked` and `currentGameIsUnranked`.

`importGameBackup()` copies the validated state, reconstructs the engine, refreshes terminal status under current rules, installs the game, clears unrelated prior Undo, marks it unranked, persists it, and does not increment games played.

An imported historical `bestScore` is not trusted as a lifetime record. The restored game's display best is normalized against the imported current score and the device's existing lifetime best, while lifetime statistics remain authoritative.

While unranked, imported play cannot update games played/won, total moves/merges, lifetime best score/highest tile, streaks, achievements, or Daily history. A terminal imported game cannot award a ranked win. Reset Statistics does not convert the session into ranked progress.

### Game Backup UI

Added `lib/features/backup/game_backup_screen.dart`, route `/backup`, and a Home **Game Backup** card.

Export copies current-game-only JSON to the clipboard after explicit user action and does not mutate player state.

Import reads clipboard text only after explicit action, validates it, previews mode/board/score/moves/highest/source timestamp, explains unranked policy, requires non-dismissible confirmation, preserves the existing game on Cancel, and installs the unranked game on Restore.

Home identifies imported resume state as **Continue Unranked Backup**.

### Phase 14 automated tests

Added four focused files:

- `test/game_backup_test.dart` — 7 tests for codec round trip, excluded data, malformed/unsupported/timestamp/missing-game/invalid-state/oversized rejection.
- `test/imported_game_policy_test.dart` — 5 tests for lifetime-best isolation, stats/achievement/Daily isolation, restart persistence, normal-new-game exit, and terminal imported no-win policy.
- `test/game_backup_screen_test.dart` — 4 tests for clipboard export, explicit confirmed unranked import, Cancel preservation, and invalid-input preservation.
- `test/unranked_marker_test.dart` — 4 tests for marker round trip, malformed repair, clear-game cleanup, and corrupt-save cleanup.

Phase 14 adds **20 focused tests** to the Phase 13 total of 92, producing a 112-test suite target. Exact final permanent-CI evidence is recorded in `docs/VERIFICATION.md` after the completed repository state is verified.

### Transparent defects and tooling failures

Real intermediate problems remain documented rather than hidden.

CI run `31781326279` exposed an unused backup-test import under strict analysis. Fix:

```text
3446413574582c196a47877fe1bfbe63addbf71d
fix: remove unused backup test import
```

The oversized-backup fixture initially used unsupported Dart string multiplication. Fix:

```text
a4a2de5bfb9e32fb9f02cf13b5019f69141ff567
fix: build oversized backup fixture with valid Dart
```

The backup widget harness initially assumed the below-the-fold Home card was visible in Flutter's default 800×600 test viewport. Fix:

```text
24b2063f365b63a86009c9acbebf2c4bafe73bed
test: scroll game backup entry into widget viewport
```

Several temporary one-time patch/wiring workflows failed for development-tooling reasons such as source-anchor mismatch, an invalid handwritten patch, or a plain Ubuntu patch job lacking Dart. Runs included `31780514759`, `31780577741`, `31780703213`, `31780791461`, and `31781232021`. They are not release evidence. Actual source changes were committed normally and temporary helper files were removed.

The first two attempts to append this Phase 14 log (`31785071035` and `31785159285`) failed at workflow parsing because multiline helper content was not YAML-indented. They ran no job and changed no project source. A third helper run (`31785331045`) successfully decoded/appended the log in its temporary checkout and removed its helper file, but failed before commit because its staging command named an already-removed path. No repository content from that run was pushed. The final corrected helper uses the same single-line base64 payload, stages deletions with `git add -A`, commits the log, and self-removes.

### Final Phase 14 native production verification

Final production/in-app documentation state requiring native compilation:

```text
741dfd42e51386646aa64be116cf7e913e98d211
docs: refresh in-app release candidate highlights
```

Native matrix:

```text
Workflow: Platform Builds
Run: 31784286707
Verified production commit: 741dfd42e51386646aa64be116cf7e913e98d211
Overall: SUCCESS
```

Android release APK, Linux release, Windows release, macOS release, and iOS release with `--no-codesign` all succeeded. iOS remains deliberately unsigned; distribution signing/provisioning credentials are not stored in the repository.

### Complete documentation expansion

New dedicated documents include:

- `docs/README.md`
- `docs/USER_GUIDE.md`
- `docs/FAQ.md`
- `docs/GAME_MODES.md`
- `docs/DATA_STORAGE.md`
- `docs/BACKUP_AND_RESTORE.md`
- `docs/DEVELOPMENT.md`
- `docs/PLATFORMS.md`
- `docs/CI_CD.md`
- `docs/TROUBLESHOOTING.md`

Expanded existing documents include root `README.md`, `ARCHITECTURE`, `GAME_ENGINE`, `ACCESSIBILITY`, `PRIVACY`, `DEPENDENCIES`, `TESTING`, `VERIFICATION`, `RELEASE_CHECKLIST`, `CONTRIBUTING`, `CODE_OF_CONDUCT`, `SECURITY`, `SUPPORT`, `AUTHORS`, `ROADMAP`, `CHANGELOG`, issue/PR templates, and the in-app Guide/About text.

Documentation now clearly separates implemented behavior from roadmap ideas, configured platforms from store-ready qualification, automated evidence from real-device checks, ranked local progress from editable imported state, normal Hint from automatic demo behavior, and bounded read-only Replay from full exported replay history.

### Representative meaningful Phase 14 commits

```text
3446413574582c196a47877fe1bfbe63addbf71d  fix: remove unused backup test import
67d5453752c97afd5eb97946ad26f58bc1ba5838  feat: register game backup route
1b86e707476a6cd142e6b6c47ee52e7385c02337  feat: expose game backup from home
a4a2de5bfb9e32fb9f02cf13b5019f69141ff567  fix: build oversized backup fixture with valid Dart
2bfaedeb3819f4f3e6a6bf73c39d0f14800c78cf  fix: clarify unranked backup continuation
24b2063f365b63a86009c9acbebf2c4bafe73bed  test: scroll game backup entry into widget viewport
741dfd42e51386646aa64be116cf7e913e98d211  docs: refresh in-app release candidate highlights
```

Direct repository and automation commits use `Sanskar <sanskarin@outlook.in>`. No no-op commits were created merely to inflate commit count.

### Phase 14 release-candidate state

```text
Project: 2048 Nova
Version: 0.9.0+1
Phase: 14 — Portable Current-Game Backup/Restore + Complete Documentation

Core engine: implemented/hardened
Save + deterministic Undo: implemented/hardened
Daily Challenge: implemented/hardened
Statistics/achievements: implemented
Accessibility foundations: implemented/expanded
Heuristic Hint: implemented/deterministic
Auto Play Demo: implemented/isolated/verified
Move Replay: implemented/read-only/bounded/verified
Game Backup: implemented/validated/clipboard-based/persistent-unranked/native-build verified
Documentation: complete user/technical/development/platform/release set
Native configured release builds: PASS
```

### Remaining manual boundaries before stable 1.0.0

Still required: representative physical mobile gameplay/lifecycle/save-resume, real touch/orientation/responsive/keyboard/focus checks, TalkBack/VoiceOver/desktop-browser screen readers, long-session Undo/Daily/timed/move-limit/Replay/Auto Play checks, real Game Backup clipboard flows and imported marker persistence/Undo/multiple-mode checks, real browser/email handlers, native icon/splash visual review, Android distribution signing, Apple signing/provisioning, and final store/privacy/listing/package review.

Portable backups remain plain JSON and intentionally unranked. Replay remains bounded by retained Undo history. Auto Play remains a deterministic heuristic demonstration rather than guaranteed optimal play.


## Phase 14 Final Verification Addendum

After the initial Phase 14 development record was committed, the Backup widget boundary received one final testability/refinement pass and the permanent verification gates were completed.

### Clipboard boundary refinement

Production clipboard access is now isolated behind:

```text
lib/shared/text_clipboard.dart
```

`SystemTextClipboard` remains the default production implementation and delegates to Flutter's `Clipboard` APIs. `GameBackupScreen` accepts a `TextClipboard` dependency, which lets widget tests use a deterministic in-memory implementation without changing production behavior.

This refinement removed platform-channel timing from Backup widget tests while preserving the explicit real clipboard behavior that still requires manual platform qualification before stable release.

Final production clipboard-boundary native matrix:

```text
Workflow: Platform Builds
Run: 31787016748
Production commit: dd3c79bec40cf1aa1e4b00190d32393b249902e0
Commit: refactor: inject clipboard service into game backup screen
Overall: SUCCESS
```

Results:

- Android release APK: **PASS**
- Linux release: **PASS**
- Windows release: **PASS**
- macOS release: **PASS**
- iOS release with `--no-codesign`: **PASS**

### Final Backup widget-test defect

After the in-memory clipboard refinement, the full suite completed with **110 passed / 2 failed**. Focused diagnostic jobs showed the remaining failures were only the Backup **export** and **cancel** UI cases.

The issue was not Backup state logic. Those page-level actions were still below Flutter's default 800×600 widget-test viewport and behind the bottom-navigation area when tapped.

Final fix:

```text
137180a1c886852e1b2b4dfda4bbcb514c927eb2
test: scroll backup page beyond bottom navigation before taps
```

The Backup widget harness now scrolls the page before tapping page-level Copy/Import actions, while dialog actions remain direct taps.

Temporary diagnostic workflow files were removed after isolating the issue.

### Final Phase 14 maintained quality gate

```text
Workflow: CI
Run: 31787639781
Verified source/test commit: 137180a1c886852e1b2b4dfda4bbcb514c927eb2
Overall: SUCCESS
```

Maintained CI results:

- dependency resolution: **PASS**
- Dart formatting gate: **PASS**
- Flutter static analysis: **PASS**
- automated tests: **PASS — 112/112**
- Flutter Web release build: **PASS**

This supersedes the earlier Phase 14 intermediate 110/2 run and closes the automated source/test/Web verification loop for the implemented Backup feature.

### Permanent workflow cleanup

After diagnostics and development-log helpers were removed, the intended permanent workflow set is:

```text
bootstrap-branding.yml
bootstrap-platforms.yml
ci.yml
format-code.yml
lock-dependencies.yml
platform-builds.yml
```

Temporary patch, log, and diagnostic workflows are not part of the maintained project automation surface.

### Final Phase 14 release-candidate boundary

The project remains **0.9.0+1**, not stable 1.0.0. Automated source/test/Web and configured native compilation are green, but the manual release boundaries already listed above still apply, especially real platform clipboard behavior, physical-device lifecycle/touch testing, assistive-technology checks, external handlers, signing/provisioning, and store/package review.


## Phase 15 — Offline Shareable Seeded Challenge Codes

### Phase goal

Phase 15 implements the next release-candidate roadmap item: a completely offline way to share the deterministic **starting configuration** of a 2048 game without introducing accounts, cloud synchronization, a multiplayer backend, a new database, or a progress-import trust problem.

The feature deliberately shares only a supported `GameConfig` plus deterministic seed. It does **not** share a progressed board, score, move count, lifetime statistics, achievements, settings, Daily history, or Undo snapshots. This keeps Challenge Codes conceptually and technically separate from Phase 14 Game Backup.

The project remains **2048 Nova 0.9.0+1 release candidate**. Phase 15 does not promote the project to stable 1.0.0.

### Architecture and trust decision

Two portable-text features now exist, with intentionally different policies:

```text
Challenge Code
  -> fresh configuration + deterministic seed only
  -> normal local new-game path
  -> normal non-Daily statistics/achievement policy

Game Backup
  -> progressed current GameState
  -> explicit restore path
  -> always locally marked unranked
  -> cannot mutate trusted lifetime/Daily records
```

This distinction prevents a configuration-sharing convenience from becoming a second progress-import protocol and prevents user-editable progressed backup data from being treated as trusted records.

Daily Challenge is intentionally excluded from Challenge Codes. Daily already derives its shared deterministic seed from the UTC calendar date and owns a dedicated date-indexed local history contract. Arbitrary portable Daily seeds would blur that contract and could create confusing history semantics.

### Domain codec

Added:

```text
lib/domain/challenge_code.dart
```

Current portable format:

```text
NOVA1.<base64url-payload>.<8-hex-checksum>
```

Logical decoded payload:

```json
{
  "format": "2048-nova-challenge",
  "version": 1,
  "config": {
    "mode": "classic",
    "size": 4,
    "target": 2048,
    "moveLimit": null,
    "timeLimitSeconds": null,
    "seed": 123456789
  }
}
```

Current constants/policy:

```text
format: 2048-nova-challenge
version: 1
prefix: NOVA1
maximum input length: 1024 characters
checksum: 32-bit FNV-1a over the encoded payload
seed range: 0..0x7fffffff
```

Supported modes:

- Classic;
- Quick;
- Extended;
- Challenge;
- Endless;
- Target;
- Time Challenge;
- Move Limit;
- Zen.

Daily Challenge is rejected explicitly.

The codec reuses `GameConfig.fromJson()` as the authoritative type/range validator instead of duplicating configuration bounds in a portable parser.

Decode validation rejects:

- empty text;
- text over 1024 characters before payload parsing;
- unsupported prefix;
- wrong segment count;
- empty payload;
- malformed/non-hex/eight-character checksum;
- checksum mismatch;
- invalid Base64URL;
- invalid UTF-8;
- invalid JSON/non-map payload;
- wrong format identifier;
- unsupported version;
- missing/non-map configuration;
- invalid `GameConfig` fields/types/ranges;
- missing deterministic seed;
- unsupported portable mode, including Daily.

The checksum is deliberately documented as **accidental corruption/typo detection only**. It is not encryption, a digital signature, authentication, identity proof, or an anti-cheat system. A technically capable person can construct another valid configuration/code; under the current local-only feature this does not let them import progress or trusted records.

### Deterministic game-start behavior

`ChallengeCode.withSeed()` copies a normal preset configuration with an explicit validated seed. Starting a decoded code uses the same normal engine path as a locally chosen new game:

```text
ChallengeCode.decode(text)
  -> validated seeded GameConfig
  -> recoverable-game replacement guard
  -> AppController.newGame(config)
  -> GameEngine(config: config).createGame()
  -> normal local save/statistics policy
```

For the same supported configuration and seed, the engine produces the same opening board and post-opening RNG state. If two players subsequently make the same valid move sequence from identical state, the deterministic spawn sequence stays aligned. Different moves can change board occupancy and naturally cause the paths to diverge.

A Time Challenge Code shares the deterministic configuration/seed, but each newly started game gets its own local `startedAt`; the code does not synchronize a wall-clock competition start time.

### Player-facing Challenge Codes workspace

Added:

```text
lib/features/challenge_codes/challenge_code_screen.dart
```

Registered route:

```text
/challenge-codes
```

Home now exposes a **Challenge Codes** card.

Create flow:

1. choose a supported mode;
2. for Target mode, choose 128/256/512/1024/2048/4096/8192/16384;
3. generate a fresh deterministic seed;
4. encode the seeded configuration;
5. display selectable `NOVA1...` text;
6. copy only after explicit user action.

Open flow:

1. paste or manually type code text;
2. validate explicitly, with Paste also validating after reading clipboard;
3. display mode, board size, target, move/time limit when present, and seed;
4. choose **Start this challenge**;
5. if a recoverable game exists, use the normal **Replace current game?** guard;
6. after confirmation, create a fresh normal local game and navigate to Game.

Invalid text cannot create or replace a game.

### Clipboard boundary

Challenge Codes reuse:

```text
lib/shared/text_clipboard.dart
```

Production defaults to `SystemTextClipboard`, which delegates to Flutter's system clipboard. The screen accepts an injected `TextClipboard` so widget tests use an in-memory deterministic implementation rather than a real platform channel.

The application reads/writes Challenge Code clipboard text only after explicit Paste/Copy actions. Manual entry remains available when platform clipboard behavior is unavailable or restricted.

No third-party sharing, QR, networking, or clipboard package was added.

### Persistence boundary

Challenge Codes add **no new SharedPreferences key**.

Generated and decoded code text lives only in screen memory and, after explicit actions, the system clipboard. Once a validated code is started, the resulting fresh `GameState` uses the existing normal current-game/Undo/statistics persistence path.

Because a Challenge Code cannot carry progressed state or claimed historical records, a game started from a code is not automatically unranked. It follows normal local non-Daily statistics/achievement behavior.

This differs intentionally from portable Game Backup, whose progressed user-editable state remains unranked.

### Source files changed/added

Production/in-app source:

```text
lib/domain/challenge_code.dart
lib/features/challenge_codes/challenge_code_screen.dart
lib/app/nova_app.dart
lib/features/home/home_screen.dart
lib/features/guide/guide_screen.dart
lib/features/about/about_screen.dart
```

Existing shared boundary reused:

```text
lib/shared/text_clipboard.dart
lib/shared/game_replacement_guard.dart
```

Automated coverage:

```text
test/challenge_code_test.dart
test/challenge_code_screen_test.dart
test/widget_smoke_test.dart
```

### Automated test expansion

Phase 14 ended at **112 tests**.

Phase 15 adds exactly **15** cases:

```text
test/challenge_code_test.dart        10
test/challenge_code_screen_test.dart  4
test/widget_smoke_test.dart            1 new Challenge Codes navigation case
                            --
Total added                             15
Final suite                            127
```

Pure codec/determinism coverage verifies:

- every supported preset mode round-trips after adding a seed;
- encoding is stable for the same configuration;
- decoded configuration reproduces the same opening board/RNG state;
- unseeded configuration rejection;
- Daily rejection;
- empty/unsupported-prefix rejection;
- checksum-tampering rejection;
- malformed checksum/payload-shape rejection;
- pre-parse oversized input rejection;
- unsafe seed-bound rejection.

Widget/state-flow coverage verifies:

- deterministic generated code and Copy action;
- Paste/Validate of a valid code;
- decoded preview visibility;
- starting a code produces the exact decoded configuration and deterministic opening state;
- invalid input preserves the no-game state;
- cancelling recoverable-game replacement leaves the existing ranked game unchanged;
- Home navigation opens the Challenge Codes workspace.

### Transparent implementation defect and correction

The first `ChallengeCode` codec commit attempted to rebuild Base64URL padding with unsupported Dart string multiplication. The defect was corrected immediately before final verification.

Correcting commit:

```text
88c2954f9703a72626ddf47d93b4d6e9e8e8dfeb
fix: decode challenge code padding with valid Dart
```

The final implementation uses:

```text
List.filled(paddingCount, '=').join()
```

This intermediate coding defect is recorded rather than rewritten out of the project history.

### Final maintained quality gate

```text
Workflow: CI
Run: 31796242355
Verified commit: 643b38665738ce314eea81e3dcc8887c77fb2257
Commit: docs: explain challenge code deterministic engine relationship
Flutter: 3.47.0 stable
Dart: 3.13.0
Overall: SUCCESS
```

Results:

- dependency resolution: **PASS**;
- Dart formatting: **PASS — 66 files, 0 changed**;
- Flutter static analysis: **PASS — No issues found**;
- automated tests: **PASS — 127/127**;
- Flutter Web release build: **PASS — build/web**;
- WASM dry run: **PASS**.

The CI log retains the existing non-blocking package-update availability notices, CupertinoIcons lookup warning during the successful Web build, and hosted Actions Node runtime deprecation notice. None caused a failed quality gate.

Earlier Phase 15 CI run `31795076552` passed formatter, analyzer, and tests for an earlier source state but had its Web step cancelled when a newer commit superseded it through the repository concurrency policy. It is **not** treated as a code failure and is not promoted as final evidence. Complete run `31796242355` supersedes it.

### Final native production gate

```text
Workflow: Platform Builds
Run: 31795329370
Verified production/in-app-doc commit: 7c83d7a14656d9309b54205de1f72e0af131f551
Commit: docs: include challenge codes in app release highlights
Overall: SUCCESS
```

Jobs:

```text
Windows job:               94751062446 — PASS
Android release APK job:   94751062458 — PASS
macOS + unsigned iOS job:  94751062524 — PASS
Linux job:                 94751062579 — PASS
```

Configured targets:

- Android release APK — **PASS**;
- Linux release — **PASS**;
- Windows release — **PASS**;
- macOS release — **PASS**;
- iOS release with `--no-codesign` — **PASS**.

That commit contains all Phase 15 runtime source plus the compiled in-app Guide/About Challenge Code documentation. Later Phase 15 commits before final CI were tests and repository documentation only.

### Documentation completed in Phase 15

Added:

```text
docs/CHALLENGE_CODES.md
```

Updated Challenge Code behavior/trust/platform/release guidance across:

```text
README.md
docs/README.md
docs/USER_GUIDE.md
docs/FAQ.md
docs/ARCHITECTURE.md
docs/GAME_ENGINE.md
docs/GAME_MODES.md
docs/DATA_STORAGE.md
docs/BACKUP_AND_RESTORE.md
docs/PRIVACY.md
docs/ACCESSIBILITY.md
docs/DEPENDENCIES.md
docs/DEVELOPMENT.md
docs/TROUBLESHOOTING.md
docs/PLATFORMS.md
docs/CI_CD.md
docs/TESTING.md
docs/VERIFICATION.md
docs/RELEASE_CHECKLIST.md
CONTRIBUTING.md
SECURITY.md
SUPPORT.md
ROADMAP.md
CHANGELOG.md
what_changed.md
```

The documentation explicitly distinguishes:

- configuration-sharing Challenge Codes from progressed Game Backup;
- normal fresh-game record policy from unranked imported progress;
- checksum corruption detection from real cryptographic authentication;
- configured/native compilation from real clipboard/device/accessibility qualification;
- automated 127-test evidence from remaining manual release work.

### Key Phase 15 commits

```text
e5d63ef9a46423bd9aabcd4bf4eab70d3be38395  feat: add versioned seeded challenge code codec
88c2954f9703a72626ddf47d93b4d6e9e8e8dfeb  fix: decode challenge code padding with valid Dart
0daa054160dafb7140b8a0cfbf47237f40f82afd  test: cover seeded challenge code validation
5b416d1d1185d556794b2d6bc245d90c521cd5e3  feat: add shareable challenge code screen
2f00b8678ec085dae26d5cc25a62dcee11d4ba0b  feat: register challenge code route
fbd653cefd30cf039140cabab87d30533ebf7cf5  feat: expose challenge codes from home
531b11287dc38cb328702c1e3a22e6787f64db3d  test: cover challenge code UI flows
d6b293ecdc3f0fb519f365bfca51fef95902b457  test: cover challenge code navigation from home
8c034b69b79e4e7d0bba9a11c48cdea27e592f4a  docs: explain challenge codes in the in-app guide
7c83d7a14656d9309b54205de1f72e0af131f551  docs: include challenge codes in app release highlights
a77f8d607a387dab182f5a204347caccc92929d9  docs: add seeded challenge code specification
643b38665738ce314eea81e3dcc8887c77fb2257  docs: explain challenge code deterministic engine relationship
72fbfc2c81892dc75b347ea6b4e3fe119fc682d8  docs: record Phase 15 challenge code verification
60149f7acc8dbc031c1b2405e6f74fb3b513b6fc  docs: record Phase 15 challenge code test coverage
2e4100538259bf41b15673a92b2f48c94c5ab1ee  docs: record Phase 15 seeded challenge codes
```

Additional Phase 15 documentation commits remain in the normal repository history; no empty/no-op commits were added to inflate commit count.

Direct repository and automation commits use:

```text
Sanskar <sanskarin@outlook.in>
```

### Historical correction

A Phase 14 addendum contained a shortened/incorrect commit text `137180a1...` for the final Backup widget scroll fix. The correct commit is:

```text
1371ef9eaa00f1da5a2ce0370a1f22eb1f2f4cd2
test: scroll backup page beyond bottom navigation before taps
```

`docs/TESTING.md`, `docs/VERIFICATION.md`, and the current `CHANGELOG.md` use the corrected SHA. This correction does not change the Phase 14 verification result: CI run `31787639781` passed 112/112 tests and the Web release build.

### Development-log helper transparency

The first Phase 15 log helper run `31796719195` failed at workflow parsing because the multiline append payload was not encoded safely for YAML. It ran no project job and changed no source/log content.

A second attempt (`31797028878`) also failed at workflow parsing when the encoded payload was embedded as very long environment-value lines. It likewise ran no project job and changed no source/log content.

The final helper stages this Markdown payload as a temporary repository file, appends it with normal shell `cat`, commits `what_changed.md`, removes both temporary files in that same commit, rebases normally, and pushes without force.

### Permanent workflow state

Phase 15 required no feature diagnostic/patch workflow. The self-removing log helper and its temporary payload are deleted in the same commit that appends this section.

The intended permanent workflow set after this commit is:

```text
bootstrap-branding.yml
bootstrap-platforms.yml
ci.yml
format-code.yml
lock-dependencies.yml
platform-builds.yml
```

### Remaining manual boundaries before stable 1.0.0

Still required before a truthful stable release:

- representative physical Android/iOS gameplay/lifecycle/save-resume;
- touch/swipe thresholds and orientation/responsive behavior;
- real desktop/browser keyboard focus/shortcut behavior;
- TalkBack, VoiceOver, Narrator/browser screen-reader qualification;
- Challenge Code generation/copy/paste/manual entry/validation/error/preview/replacement behavior using real platform clipboard handlers;
- same-code deterministic opening and same-valid-move-sequence comparisons across independent devices/runs;
- Challenge Code Target/Time/Move Limit/board-size/Endless/Zen qualification;
- confirmation on real builds that arbitrary Daily Challenge Codes remain unavailable and normal UTC-date Daily history is unchanged;
- Game Backup real clipboard/import/unranked/restart/Undo/multiple-mode checks;
- Move Replay/Auto Play long-session, pause/navigation-away, and accessibility checks;
- real browser/email external handlers;
- native splash/icon visual review;
- Android production signing/store packaging;
- Apple signing/provisioning/notarization as applicable;
- final store privacy/data-safety/listing/package review.

Automated success does not prove universal absence of defects. The project remains:

```text
Project: 2048 Nova
Version: 0.9.0+1
Status: release candidate
Stable 1.0.0: NOT YET
```

## Phase 16 — Offline English/Hindi Localization

### Phase goal

Phase 16 completes the next release-candidate roadmap item by adding an offline localization foundation with first-class **English** and **Hindi (हिन्दी)** support. The goal is not merely to register two locale codes: the phase adds a persisted language setting, framework localization delegates, translated player-facing flows, translated validation/error paths, localized board accessibility semantics, corruption-safe settings recovery, contributor guidance, regression coverage, Web/native compilation evidence, and explicit manual-release boundaries.

The project remains **2048 Nova 0.9.0+1 release candidate**. Phase 16 does not claim stable 1.0.0, universal zero defects, complete real-device Hindi qualification, or store readiness.

### Supported language policy

The player can choose:

```text
System default
English
हिन्दी
```

The persisted values are:

```text
system
english
hindi
```

`System default` follows the device locale when it is one of the supported language codes. If the platform reports another locale, the app deliberately falls back to English instead of selecting an unsupported translation.

Explicit English or Hindi selection overrides the platform locale through `MaterialApp.locale`.

### Localization architecture

Added:

```text
lib/core/localization/nova_localizations.dart
lib/core/localization/hindi_translations.dart
```

The localization layer owns:

- `AppLanguage` with System/English/Hindi choices;
- validated persisted storage names;
- locale mapping;
- safe parsing of persisted settings;
- supported locale declarations;
- the project `LocalizationsDelegate`;
- `BuildContext.l10n` access;
- English source-string fallback;
- Hindi fixed-string catalog lookup;
- typed dynamic helpers for modes and directions;
- typed helpers for board size, target, time/move limits, score, moves, highest tile, and seed;
- stable achievement-ID based Hindi title/description translation.

English is the source/fallback language. If a future Hindi key is accidentally missing, the player sees the English source text instead of an empty string, exception, or failed startup. This fallback is defensive rather than permission to leave new Hindi UI unfinished.

### Flutter framework localization

`pubspec.yaml` now includes the official Flutter SDK localization package:

```yaml
flutter_localizations:
  sdk: flutter
```

`NovaApp` registers:

```text
NovaLocalizations.delegate
GlobalMaterialLocalizations.delegate
GlobalWidgetsLocalizations.delegate
GlobalCupertinoLocalizations.delegate
```

This gives standard framework controls locale-aware labels/formatting while keeping project-specific translations in repository source.

No remote translation SDK, account service, analytics package, language download service, or translation API was added.

The application dependency lock was refreshed and now resolves the SDK localization dependency, including Flutter's transitive `intl` package, through the committed `pubspec.lock`.

### Persisted language preference

`AppSettings` now includes:

```text
AppLanguage language
```

Default:

```text
AppLanguage.system
```

Serialization stores the enum's stable storage value. Deserialization uses `AppLanguageX.parse(Object?)` so:

- `system` restores System default;
- `english` restores English;
- `hindi` restores Hindi;
- unknown strings fall back to System default;
- wrong types fall back to System default;
- missing values remain backward-compatible and fall back to System default.

This extends the existing settings JSON rather than creating a separate top-level SharedPreferences key or a second persistence subsystem.

Clearing all 2048 Nova local data returns language to the default System setting together with the other application preferences.

### Settings user interface

The Settings Appearance section now includes a Language selector before brightness/theme controls.

Visible choices:

```text
System default
English
हिन्दी
```

Changing the setting persists through `AppController.updateSettings()` and immediately rebuilds `MaterialApp`, so player-facing routes use the selected locale without an account or project-server round trip.

### Localized player-facing surfaces

Phase 16 routes the primary player-facing application through the shared localization layer.

Localized surfaces include:

- Home navigation and hero supporting text;
- Continue/New Game/Daily/Replay actions;
- mode selection titles/descriptions and target selection;
- gameplay screen title, metrics, tooltips, keyboard-control help, hint feedback, pause, restart, win, and game-over dialogs;
- Daily Challenge status, run actions, history, and confirmation flows;
- Statistics labels and reset confirmation;
- Achievement titles/descriptions/status/reset flow;
- Challenge Code creation, validation, configuration preview, clipboard feedback, trust/privacy cards, and validation error messages;
- Game Backup overview, current-state facts, import safety, clipboard feedback, validation errors, preview/restore dialog, and ranking labels;
- recoverable-game replacement confirmation;
- Move Replay labels, controls, speed text, status, empty state, and failure state;
- isolated Auto Play Demo labels, controls, metrics, speed text, and status;
- full in-app How to Play guide;
- About release-candidate information and project-link labels;
- Support and optional Buy Me a Coffee labels;
- splash accessibility semantics;
- external-link safety/copy fallbacks;
- Settings controls/data confirmations;
- board container/tile accessibility semantics.

Machine-readable or externally meaningful tokens remain exact and untranslated where appropriate, including:

- `NOVA1` challenge prefix;
- JSON field names and portable format identifiers;
- deterministic numeric seeds;
- numeric tile values;
- repository URLs;
- email addresses;
- GitHub profile/business destinations;
- code identifiers.

Localization does not change deterministic game rules, RNG, ranking, Daily history, backup trust policy, Replay behavior, Auto Play isolation, or Challenge Code format.

### Hindi board accessibility semantics

`GameBoard` now generates locale-aware semantic labels.

Representative English labels:

```text
4 by 4 game board
Row 1, column 1, tile 2
Row 1, column 2, empty
```

Representative Hindi labels:

```text
4 बाय 4 गेम बोर्ड
पंक्ति 1, कॉलम 1, टाइल 2
पंक्ति 1, कॉलम 2, खाली
```

Tile numbers remain visible text and semantic values; color is not the only indicator.

Automated semantics coverage verifies representative Hindi board labels. It does not replace real TalkBack, VoiceOver, Narrator/browser-screen-reader pronunciation/focus testing.

### Privacy and trust boundary

Localization is fully offline project data plus a local preference.

The feature does **not**:

- send source text to an online translator;
- upload the selected language;
- add analytics or advertising tracking;
- add cloud synchronization;
- add an account requirement;
- modify clipboard contents automatically;
- modify or trust imported backup ranking data;
- alter Challenge Code integrity rules;
- alter Daily date-seed behavior;
- alter deterministic engine/RNG state.

External browser/email actions remain explicit player actions through the existing secure URI allowlist.

### Dependency-lock tooling correction

The first Phase 16 localization lock helper successfully ran `flutter pub get`, but Flutter 3.47 also rewrote `analysis_options.yaml` in the runner. That unrelated unstaged generated change prevented the helper from rebasing/pushing its intended lockfile commit.

Failed helper:

```text
Run: 31804740412
Job: 94780823968
Result: FAILURE
```

This was not a dependency-resolution failure and is not counted as release evidence.

Correction:

```text
f91ee2d423af2142d4d660b3a1d1402bf942f13f
fix: keep lock refresh scoped to dependency files
```

The corrected helper explicitly restores the unrelated `analysis_options.yaml` runner rewrite before staging the lockfile.

Corrected run:

```text
Run: 31804909137
Result: SUCCESS
```

Generated lock commit:

```text
abf4c95c411658abae27c44f76d39f2f6a9a8bdd
build: lock localization dependencies
```

The temporary helper self-removed after use.

### Initial static-analysis regression

The first broader Phase 16 source gate exposed one real analyzer issue: after Auto Play was localized, `solver_demo_screen.dart` retained an import that was no longer used.

Failing gate:

```text
CI run: 31804557648
Job: 94780222302
Formatting: PASS
Static analysis: FAILURE
Tests: not run
Web build: not run
```

Fix:

```text
5048486775b0c9702583f348bfc5be71219e83ae
fix: remove unused auto play localization import
```

That corrected commit became the runtime source used by the successful Phase 16 native matrix.

### New localization regression suite

Added:

```text
test/localization_test.dart
```

Phase 16 contributes **7 focused tests**:

1. supported/malformed `AppLanguage` parsing;
2. critical Hindi catalog translations;
3. English identity plus safe missing-Hindi-key fallback;
4. localized mode/direction/achievement helpers;
5. language preference persistence and malformed-data recovery;
6. Hindi Home and Settings rendering;
7. Hindi board positional semantics.

Phase 15 ended at **127** automated tests.

Final Phase 16 suite:

```text
127 + 7 = 134 tests
```

### Direct-widget localization harness regression

The localization implementation made an important test assumption visible: several older widget tests mounted individual localized feature widgets in a bare `MaterialApp` rather than using the production localization delegate configuration.

The first failure appeared in `game_screen_interaction_test.dart`.

Failing run:

```text
CI: 31805260580
```

A diagnostic run then established that:

```text
pub resolution: PASS
format: PASS
analyze: PASS
focused localization_test.dart: PASS
full suite: FAILURE
```

Diagnostic:

```text
31805881265
```

The localized Game screen correctly asserted because `NovaLocalizations` was not present in that legacy test tree. The production app already supplied it.

Fix:

```text
8990a904f6ecfb487c722b3705f7061237ca270f
test: add localization delegates to game screen harness
```

### Remaining eleven stale widget harnesses

After the Game-screen harness correction, the next full suite reached:

```text
123 passed
11 failed
```

Run:

```text
31806175302
Job: 94785602406
Formatting: PASS
Analyzer: PASS
Tests: FAILURE — 123 passed / 11 failed
Web: skipped after test failure
```

A temporary machine-readable test diagnostic identified every failure at once:

```text
Run: 31806445596
```

The eleven failures were:

Challenge Codes — 4:

- generates and copies a deterministic challenge code;
- pastes validates and starts the same seeded challenge;
- invalid pasted code is rejected without creating a game;
- replacement cancellation preserves the current game.

Game Backup — 4:

- export copies a decodable current-game-only backup;
- valid import requires confirmation and becomes unranked;
- cancelled import leaves an existing ranked game untouched;
- invalid clipboard text is rejected without replacing the game.

Other direct-widget harnesses — 3:

- active recoverable game asks before replacement;
- board exposes size and positional tile semantics;
- lost game does not expose Continue Game.

All eleven had the same root cause: an old direct-widget test harness lacked the localization delegates now required by the localized widget it was mounting.

### Shared production-like widget test harness

Added:

```text
test/support/localized_test_app.dart
```

The shared test wrapper mirrors production locale infrastructure:

```text
NovaLocalizations.delegate
GlobalMaterialLocalizations.delegate
GlobalWidgetsLocalizations.delegate
GlobalCupertinoLocalizations.delegate
NovaLocalizations.supportedLocales
```

It supports optional locale override and routes so focused feature tests stay isolated without inventing a second localization configuration.

Relevant focused correction commits include:

```text
9b2a0794f979caf04e443b14718c6d29745bee83  test: add production-like localized widget harness
9ba141325f2656f06f5c07f3bcb41461eb3e5b5e  test: use localized harness for board semantics
31fd02a24c25dfa2b817649633cca1adccc1b53b  fix: restore material widgets in board semantics test
ff9b3ef132ad391441685f8d181c0f9d97f0c61b  test: use localized harness for home state
f7addf720b995fb0fd29383d317d4612bb63bbff  test: use localized harness for replacement guard
418ee6b29fd1bdd0b98c4a6e7f1b4a958a780645  test: use localized harness for challenge codes
578f514a854202ec89f27236f31264e52d642c03  test: use localized harness for game backup
9dea87e73803d83c3aa0614d35f7860773dbca04  chore: remove Phase 16 failing-test report
```

Temporary diagnostic workflow/report files were deleted after the failures were identified. They are not part of the permanent project surface.

### Final maintained Phase 16 quality gate

The cleaned repository state after all localization source, test-harness, documentation, lockfile, and diagnostic cleanup changes was verified by the permanent CI workflow:

```text
Workflow: CI
Run: 31806785165
Job: 94787540103
Verified commit: 9dea87e73803d83c3aa0614d35f7860773dbca04
Overall: SUCCESS
```

Toolchain:

```text
Flutter 3.47.0 stable
Dart 3.13.0
DevTools 2.60.0
```

Results:

```text
Dependency resolution: PASS
Formatting: PASS — 70 files, 0 changed
Static analysis: PASS — No issues found
Automated tests: PASS — 134/134
Web release build: PASS — build/web
WASM dry run: PASS
```

The successful Web build retained the existing informational CupertinoIcons font lookup warning and package-update availability notices. The hosted runner also emitted the current Actions Node runtime deprecation notice. None of those warnings failed the build or test gate.

### Final Phase 16 native runtime gate

The finalized runtime localization source was verified by the permanent native matrix on:

```text
5048486775b0c9702583f348bfc5be71219e83ae
fix: remove unused auto play localization import
```

Workflow:

```text
Platform Builds
Run: 31804713200
Overall: SUCCESS
```

Jobs:

```text
Windows release:              94780817747 — PASS
Linux release:                94780817828 — PASS
Android release APK:          94780817929 — PASS
macOS + unsigned iOS release: 94780818361 — PASS
```

Configured targets:

- Android release APK: **PASS**;
- Linux release: **PASS**;
- Windows release: **PASS**;
- macOS release: **PASS**;
- iOS release with `--no-codesign`: **PASS**.

Later Phase 16 changes after this runtime commit were localization tests/test-harness corrections, dependency lockfile, repository documentation, and temporary diagnostic cleanup. The app runtime localization source itself is represented in this successful native matrix.

The iOS build remains deliberately unsigned. Real App Store/device distribution still requires Apple signing/provisioning outside public CI.

### Documentation completed in Phase 16

Added:

```text
docs/LOCALIZATION.md
```

Updated:

```text
README.md
docs/README.md
docs/USER_GUIDE.md
docs/FAQ.md
docs/ARCHITECTURE.md
docs/DATA_STORAGE.md
docs/ACCESSIBILITY.md
docs/PRIVACY.md
docs/DEPENDENCIES.md
docs/DEVELOPMENT.md
docs/PLATFORMS.md
docs/TROUBLESHOOTING.md
docs/TESTING.md
docs/VERIFICATION.md
docs/RELEASE_CHECKLIST.md
CONTRIBUTING.md
SUPPORT.md
SECURITY.md
ROADMAP.md
CHANGELOG.md
what_changed.md
```

Documentation now explicitly distinguishes automated localization coverage from real-device/manual language qualification.

### Representative Phase 16 commits

```text
cbc08ab2d6d39e316fce24a1ae64a9c335bc9efe  feat: add English and Hindi localization foundation
208b8634a4c71d43555fcfd48b303ecf28f7deda  build: enable Flutter localization delegates
c80d0c22106140736e0c8f0010bee3207e3cc532  feat: wire app locale and localization delegates
6c54ea69a5ec26330bb7bf144a59cac5a6389c48  feat: add persisted language selector to settings
b03da0cfa0b75f5e8a057ad319ace31060f5bdeb  feat: localize home screen in English and Hindi
44932bea9ae480ce96d1ac2268b00a336794ca7c  feat: localize mode selection experience
aa7d9c9eaf7590885aa69e8fbef4f258df5d1eec  feat: localize gameplay controls dialogs and metrics
7a24f98c378b37aff4b26d80dc24116c87feb87c  feat: localize game board accessibility semantics
92c54632e10f050c3738e84ca6157e67f855542b  feat: localize statistics screen
cb674272fc953ebcef1627815123394e4ef165c8  feat: localize achievements and progress status
30c132dd95710c584c03488f5bf94a6316754adb  feat: localize daily challenge flow and history
b663ecd0c7be6069d0ff3f39bc6cdb55e21553db  feat: localize challenge code create and open flows
4823506352a6abcae403d764b7817cdd21708bec  feat: localize portable backup workflow
702479d08e4c0e755bde720d4144ffe3741b0071  feat: localize recoverable game replacement guard
3367197b8a45ce1254e6232f8c68ba362c3da7fd  feat: localize move replay spectator controls
2fe119641f84a94214113bf87979ab28c2d702b3  feat: localize isolated auto play demonstration
5d03b8d3cf82b3586c5956667cfc5ee9c4b998d2  feat: route Hindi strings through complete translation catalog
5048486775b0c9702583f348bfc5be71219e83ae  fix: remove unused auto play localization import
abf4c95c411658abae27c44f76d39f2f6a9a8bdd  build: lock localization dependencies
9f09f72b398cf9b1161ca513043e1d5e4e2d4576  docs: add English and Hindi localization guide
38b3387c087f71f5db0b753861f162030244f23c  docs: index localization documentation
8990a904f6ecfb487c722b3705f7061237ca270f  test: add localization delegates to game screen harness
9b2a0794f979caf04e443b14718c6d29745bee83  test: add production-like localized widget harness
418ee6b29fd1bdd0b98c4a6e7f1b4a958a780645  test: use localized harness for challenge codes
578f514a854202ec89f27236f31264e52d642c03  test: use localized harness for game backup
```

Additional focused localization/documentation/test commits remain in normal repository history. Empty/no-op commits were not created merely to inflate commit count.

Direct repository and automation commits use:

```text
Sanskar <sanskarin@outlook.in>
```

### Permanent workflow state after Phase 16

Temporary language-settings, dependency-lock, documentation, diagnostic, and failure-report helpers were removed after use.

The permanent `.github/workflows/` set was verified as exactly:

```text
bootstrap-branding.yml
bootstrap-platforms.yml
ci.yml
format-code.yml
lock-dependencies.yml
platform-builds.yml
```

### Remaining manual boundaries before stable 1.0.0

Phase 16 automated verification does not replace the existing release checklist. Remaining manual qualification includes:

- representative physical Android/iOS gameplay, termination/relaunch, background/foreground, save/resume;
- swipe thresholds, orientation changes, and responsive layouts;
- keyboard/focus behavior on actual desktop and browser targets;
- System default locale switching on representative platforms;
- explicit English/Hindi switching on representative platforms;
- Hindi font rendering and glyph coverage;
- Hindi long-label wrapping and narrow-screen behavior;
- large-text Hindi layouts;
- Hindi TalkBack behavior on Android;
- Hindi VoiceOver behavior on iOS/macOS;
- representative Windows/browser screen-reader pronunciation/focus;
- language-setting persistence after real process termination/relaunch;
- Challenge Code generation/copy/paste/manual entry/validation/replacement while Hindi is selected;
- Game Backup copy/import/cancel/confirm/unranked flows while Hindi is selected;
- localized external browser/email fallback behavior;
- confirmation that `NOVA1`, backup JSON identifiers, URLs, emails, seeds, and numeric tile values remain exact across locales;
- long-session Undo, Daily, timed, move-limit, Replay, Auto Play, win/continue, and restart behavior;
- native splash/icon visual review;
- Android production signing/store packaging;
- Apple signing/provisioning/notarization where applicable;
- final store listing/privacy/data-safety/screenshots, including any language-specific metadata actually shipped.

Automated success proves only the tested/compiled boundaries. The project remains:

```text
Project: 2048 Nova
Version: 0.9.0+1
Status: release candidate
Stable 1.0.0: NOT YET
```


# Phase 17 — Trusted per-mode records

Date: **2026-08-15**

## Starting point

Phase 17 started from the completed Phase 16 English/Hindi localization release-candidate state:

```text
Version: 0.9.0+1
Previous final automated gate: 134/134 tests
Previous final CI: 31806785165
Previous native matrix: 31804713200
Stable 1.0.0: not yet promoted
```

The release roadmap still contained an optional mode-specific-record expansion. This phase implemented the portion that can be measured and migrated honestly from trusted local gameplay without introducing accounts, cloud synchronization, analytics, or a new trust system.

## Scope selected for Phase 17

Implemented trusted local records per `GameMode`:

- best score;
- highest tile;
- board size associated with the stored best score;
- target tile associated with the stored best score.

The feature deliberately does **not** invent historical records for completed games that are no longer observable. It also does not claim an exact historical fewest-winning-moves record because old persisted statistics do not contain enough information to reconstruct that fact safely.

## Persisted record model

`lib/app/state/app_controller.dart` now contains `ModeRecord` and a `PlayerStats.modeRecords` map keyed by `GameMode`.

The serialized statistics payload can now include:

```json
"modeRecords": {
  "classic": {
    "bestScore": 16384,
    "highestTile": 2048,
    "bestScoreBoardSize": 4,
    "bestScoreTarget": 2048
  }
}
```

Validation rules were kept consistent with the existing statistics/save parser:

- scores must be finite, integral, and non-negative;
- highest-tile and target values must be valid powers of two within application bounds;
- stored best-score board size must remain between 3 and 8;
- unknown/future mode keys are ignored;
- malformed record objects are skipped/sanitized;
- empty records are not serialized;
- statistics payloads written before Phase 17 remain valid because `modeRecords` is optional.

No new preference key, database, runtime dependency, account, network request, or cloud service was added.

## Trusted update boundary

`AppController` is the record-policy boundary.

A locally started ranked game can update its mode record:

- when a new game is created and its generated board establishes an observable highest-tile baseline;
- after a successful ranked move raises score or tile progress;
- when timed/challenge status is refreshed and trusted progress must be persisted;
- during startup repair when a valid ranked current game predates the new `modeRecords` statistics field;
- during Reset Statistics when an active ranked session must remain represented consistently.

Undo does not reduce a historical maximum. This follows the existing global-best behavior: reaching a best and then undoing does not erase the fact that the best was already reached.

## Imported Game Backup isolation

The existing persistent `_currentGameUnranked` boundary now also protects per-mode records.

A portable/editable Game Backup:

- does not seed a mode record at import time;
- cannot improve a mode record through continued moves;
- remains excluded after app restart because the unranked marker is restored before ranked repair logic runs;
- does not recreate a record when Statistics is reset while that imported board is active.

A locally started deterministic seeded game is still ranked. Challenge Codes continue to start fresh configuration-only local games and do not use the portable-progress import path.

## Statistics reset behavior

`resetStats()` now resets `PlayerStats`, including `modeRecords`.

If a ranked active game exists, the controller rebuilds only a minimal observable baseline for that active session:

- one current game counted;
- current score/global best baseline;
- current highest tile;
- current mode record derived from the active board/configuration;
- already-counted win state retained when applicable.

Historical records for other modes remain cleared.

If the active board is an imported unranked backup, no aggregate or per-mode progress is reconstructed from it.

## Localized Statistics UI

`lib/features/statistics/statistics_screen.dart` now appends expandable mode-record cards after the existing global statistics.

Each mode with trusted progress can show:

- localized mode name;
- localized board-size metadata when available;
- localized target metadata when available;
- best score;
- highest tile.

The UI intentionally reuses the Phase 16 localization layer rather than adding duplicate strings:

- `NovaLocalizations.modeName(...)`;
- `NovaLocalizations.boardSize(...)`;
- `NovaLocalizations.targetTile(...)`;
- existing `Best score` / `Highest tile` English/Hindi translations.

This preserves the offline localization and accessibility architecture.

## Focused regression tests added

Ten tests were added across four new files:

```text
test/mode_record_serialization_test.dart     3 tests
test/mode_record_tracking_test.dart          3 tests
test/mode_record_unranked_test.dart          2 tests
test/statistics_mode_records_test.dart       2 tests
```

Coverage includes:

1. per-mode record JSON round trip;
2. malformed/unknown record sanitization;
3. backward compatibility with legacy statistics payloads;
4. ranked move progress updating and persisting the correct mode record;
5. startup migration from an observable legacy ranked current game;
6. Reset Statistics preserving only an active ranked mode baseline;
7. imported-backup exclusion through import, continued move, and reset;
8. locally started seeded-game ranking behavior;
9. English expandable Statistics record presentation;
10. Hindi mode/configuration/record-label presentation through the production localization layer.

The permanent Format Dart workflow subsequently produced:

```text
15b735811fa32b51def5d5ee991aa1e89ed8ae6d
style: format Dart sources and tests
```

## Transparent intermediate automation issues

The first one-time source-commit helper run failed before committing production source:

```text
Workflow: Phase 17 source commits
Run: 31866878358
Result: FAILURE
Cause: dart: command not found
```

The lightweight helper used an Ubuntu runner that did not include Dart on `PATH`. Its Python source edit had only occurred in the ephemeral checkout; the job stopped before the source commit and therefore did not leave a half-written production commit.

The helper was corrected to leave formatting to the repository's maintained Flutter Format Dart/CI workflows instead of assuming an SDK on the lightweight helper runner.

Corrected helper:

```text
Run: 31866913732
Result: SUCCESS
```

A later changelog/work-log helper definition initially failed workflow parsing before any job ran:

```text
Workflow: Phase 17 changelog and work log
Run: 31867206065
Result: FAILURE
Cause: invalid workflow YAML caused by an unindented embedded multiline log payload
```

That helper failure made no changelog or work-log commit. The definition was corrected to carry the long log payload as Base64 and decode it inside the runner, avoiding YAML indentation ambiguity.

## Parser correction found during source audit

After the first model/tracking push, the committed file was explicitly re-opened instead of assuming the generated patch was complete. The audit showed that the intended `modeRecords` deserialization block was not present in the final `PlayerStats.fromJson` body even though serialization/tracking code was present.

That omission was corrected immediately in:

```text
341f2ad5d5b252f75e52e05ed7aede8a8aa38fbb
fix: restore per-mode record deserialization
```

A later final source audit confirmed that the parser now:

- reads only current `GameMode.values` keys;
- normalizes string-keyed maps defensively;
- validates records through `ModeRecord.fromJson`;
- retains only records with actual progress.

The intermediate mistake remains recorded here rather than being hidden.

## Phase 17 source/test commits

Representative production and regression commits:

```text
97880d90daafa5b45812c263e89d3e1f68106556  feat: add persisted per-mode record model
7e264da32c3154c18318d80e7ca5c2d41e4f6d82  feat: track trusted per-mode progress
752bf15074ff43dd614d5e6888f8ec16f29560d7  feat: show per-mode records in statistics
341f2ad5d5b252f75e52e05ed7aede8a8aa38fbb  fix: restore per-mode record deserialization
09124d22f584b92a57f747a2288c63c9551610cf  test: cover per-mode record serialization
dc92109ad1ea6f75859db26d5e87768e6936a739  test: cover trusted per-mode record tracking
f55e913a5dbd30f586a120716b586e430d589b95  test: keep imported backups out of mode records
c381dd1582845b26ab9dcd96c9d1874eb9e3d52f  test: cover localized per-mode statistics UI
15b735811fa32b51def5d5ee991aa1e89ed8ae6d  style: format Dart sources and tests
```

Temporary helper setup/correction/removal commits are also retained in normal Git history because they reflect real repository operations. No empty/no-op commit was created solely to inflate the count.

## Phase 17 documentation work

Added:

```text
docs/MODE_RECORDS.md
```

Updated or extended:

```text
README.md
ROADMAP.md
CHANGELOG.md
SECURITY.md
docs/README.md
docs/ARCHITECTURE.md
docs/BACKUP_AND_RESTORE.md
docs/DATA_STORAGE.md
docs/PRIVACY.md
docs/TESTING.md
docs/USER_GUIDE.md
what_changed.md
```

The documentation now states the exact migration, reset, privacy, trust, imported-backup isolation, and non-goal boundaries instead of describing per-mode records as a generic leaderboard feature.

## Phase 17 documentation commits

```text
d331fe1e6499d721152255cfd1404daad5424b87  docs: document per-mode record trust model
2dbf3935cf4cacd784ef0db6db746b4715128894  docs: index per-mode records documentation
9b60eae4c25859c699eefc6427f12eaa8f280e21  docs: advance roadmap with per-mode records
5931bbcf4c51ac1ce15a9ae343941ae953086585  docs: add per-mode records to project overview
5bd5d0d42e2407f8436b0d5d82f27f9a03ba9d80  docs: describe per-mode record persistence
9e2b129fa6a71c645aad9599ac5feebeff95f344  docs: define per-mode record architecture
593d218efab446e9d564ad66cfe5b809182b8f9f  docs: explain per-mode records to players
a6ba8e69934eb2e32a43ddba9936c0c0dd0659c7  docs: record per-mode statistics privacy
6cdfda38d21fcd268b3610c0e8559a87f032feeb  docs: extend backup trust boundary to mode records
bb5cf29df327391aeff1de8d2ebade13ed60b81c  docs: define per-mode record integrity boundary
58b63917cc6a4a26d0fbf7daffa97af651b302b8  docs: describe Phase 17 record regression coverage
```

## Verification state before the final Phase 17 gate

Several intermediate CI runs were superseded/cancelled by main-branch concurrency while the source, tests, formatter commit, and documentation commits were still arriving. For example, CI run `31867018829` for the localized Statistics test commit was cancelled after newer main commits superseded it. This is not treated as a passing gate or as a code failure.

The final Phase 17 passing test count and maintained CI run are intentionally recorded only after the repository stops moving and the permanent CI workflow completes against the final candidate source state.

## Manual boundaries remain unchanged

Phase 17 does not convert automated CI into physical-device release qualification. Stable `1.0.0` still requires the manual checks already listed in `ROADMAP.md` and `docs/RELEASE_CHECKLIST.md`, including representative real-device lifecycle, accessibility, clipboard/platform-handler, long-session, splash/icon, signing/provisioning, and store-metadata review.

## Final Phase 17 maintained acceptance gate

The first stabilized Phase 17 candidate was intentionally passed through the permanent `CI` workflow instead of being declared complete from source inspection alone.

### Acceptance attempt 1 — analyzer caught an unused test local

```text
Commit: f86e9499280310a431370a7f0fe9e275a3da0ec6
CI run: 31867316152
Formatting: PASS
Static analysis: FAIL
Tests: not run
Web build: not run
```

The analyzer identified an unused local variable in `test/mode_record_serialization_test.dart`. This was a test-code quality defect rather than a production failure. It was corrected in:

```text
f42a8ab18edd4661a066419de0daa84a2ce22f85
test: remove unused per-mode record local
```

### Acceptance attempt 2 — widget tests exposed a wrong expectation

CI was rerun on the analyzer-clean candidate:

```text
Commit: f42a8ab18edd4661a066419de0daa84a2ce22f85
CI run: 31867370893
Formatting: PASS — 74 files, 0 changed
Static analysis: PASS — No issues found
Tests: 142 passed, 2 failed
Web build: skipped after test failure
```

Both failures were in `test/statistics_mode_records_test.dart`.

The production Statistics card deliberately renders configuration metadata as one subtitle:

```text
4 × 4 board • Target tile: 2048
```

and in Hindi:

```text
4 × 4 बोर्ड • लक्ष्य टाइल: 2048
```

The tests had searched for board size and target as two separate `Text` widgets. The source UI and localization helper contract were re-opened and checked; production behavior was correct, so the tests—not the UI—were corrected in:

```text
c443f9fde0cc243269be57515772378c06284e86
test: match combined mode record metadata
```

### Acceptance attempt 3 — authoritative green gate

The permanent maintained CI workflow then completed successfully against that exact source/test commit:

```text
Commit: c443f9fde0cc243269be57515772378c06284e86
CI workflow run: 31867499047
CI job: 94970781061
Result: SUCCESS
Runner: ubuntu-24.04

Flutter 3.47.0 stable
Dart 3.13.0
DevTools 2.60.0

Dependency resolution: PASS
Formatting: PASS — 74 files, 0 changed
Static analysis: PASS — No issues found
Automated regression tests: PASS — 144/144
Flutter Web release build: PASS — build/web produced
Flutter Web WASM dry run: PASS
```

The final test total moved from 134 in Phase 16 to 144 in Phase 17, exactly matching the ten focused new per-mode-record tests.

The Web compiler emitted a non-fatal Cupertino icon-font availability warning while still completing the release build and producing `build/web`. It is recorded as a warning rather than misrepresented as a failed build.

### Phase 17 qualification status

Phase 17's trusted per-mode record implementation is now accepted by the maintained automated gate.

This does **not** promote the project to stable `1.0.0`. Remaining release blockers are still manual/real-environment qualification items already listed in `ROADMAP.md` and `docs/RELEASE_CHECKLIST.md`, including physical Android/iOS lifecycle/gameplay checks, representative accessibility checks, real clipboard/platform-handler behavior, long-session checks, native branding review, distribution signing/provisioning, and store metadata.

No fresh Phase 17 native build matrix was claimed. The previously recorded Phase 16 native matrix remains the latest Android/Linux/Windows/macOS/unsigned-iOS hosted native evidence until a newer native matrix is explicitly executed and recorded.

A focused permanent verification record is available at:

```text
docs/PHASE_17_VERIFICATION.md
```


## Phase 17 final current-source native matrix

A final audit found that Phase 17 already had successful hosted native-build evidence on commit `752bf15074ff43dd614d5e6888f8ec16f29560d7`, but that matrix predated the later parser correction in `341f2ad5d5b252f75e52e05ed7aede8a8aa38fbb`. Because the parser correction had been pushed by a one-time `GITHUB_TOKEN` helper, it did not trigger a new Platform Builds run.

The evidence gap was closed without an empty/no-op commit. `lib/features/statistics/statistics_screen.dart` received maintainer-facing source documentation clarifying that the Statistics screen is read-only with respect to ranking, that `AppController` owns the imported-backup trust policy, and that board/target metadata is intentionally presented as one record context.

```text
d33d65840aff67c4e9bf69ad203f46b85146093c
docs: clarify statistics record trust boundary in source
```

Because this is a real `lib/**` source change, the maintained push triggers verified the complete corrected runtime tree.

### Current-source CI

```text
Commit: d33d65840aff67c4e9bf69ad203f46b85146093c
CI workflow run: 31867788776
CI job: 94971490776
Result: SUCCESS
Runner: ubuntu-24.04
Flutter: 3.47.0 stable
Dart: 3.13.0
DevTools: 2.60.0
Dependency resolution: PASS
Formatting: PASS — 74 files, 0 changed
Static analysis: PASS — No issues found
Automated tests: PASS — 144/144
Flutter Web release build: PASS — build/web produced
Flutter Web WASM dry run: PASS
```

The Web compiler again emitted the existing non-fatal Cupertino icon-font availability warning but completed successfully and produced `build/web`. A source search did not find a direct `CupertinoIcons` usage, so no speculative dependency/source change was made solely to silence a successful-build warning.

### Current-source hosted native matrix

```text
Platform Builds workflow run: 31867788753
Commit: d33d65840aff67c4e9bf69ad203f46b85146093c
Result: SUCCESS

Android release APK
  Job: 94971490848
  flutter build apk --release: PASS

Linux release
  Job: 94971490809
  flutter build linux --release: PASS

Windows release
  Job: 94971490788
  flutter build windows --release: PASS

macOS and unsigned iOS release
  Job: 94971490875
  macOS release build: PASS
  unsigned iOS release build: PASS
```

This supersedes the Phase 16 native matrix as the latest hosted multi-platform compilation evidence and covers the final Phase 17 per-mode-record deserializer/tracking/UI runtime source. It still does not replace physical-device gameplay/lifecycle testing, assistive-technology testing, signing/provisioning, or store metadata/review. Stable `1.0.0` therefore remains intentionally unpromoted.


# Phase 18 — Bounded Expectimax and deterministic solver benchmarks

Date: **2026-08-15**

## Starting state

Phase 18 started after Phase 17 had a current-source 144/144 CI gate and a green Android/Linux/Windows/macOS/unsigned-iOS hosted native matrix. The roadmap still listed an optional advanced expectimax solver plus benchmark suite behind the already-isolated Auto Play boundary.

## Scope implemented

Phase 18 adds an advanced deterministic search strategy without changing trusted player gameplay:

- `lib/domain/expectimax_solver.dart` — bounded deterministic expectimax search;
- `AutoplayStrategy.heuristic` / `AutoplayStrategy.expectimax`;
- strategy-aware `AutoplaySession` diagnostics;
- Heuristic/Expectimax selector in Auto Play Demo;
- visible expectimax explored-node diagnostics;
- `lib/domain/solver_benchmark.dart` reusable seeded benchmark runner;
- `tool/solver_benchmark.dart` deterministic CLI harness;
- Hindi solver controls plus updated in-app Guide/About content;
- focused unit/widget/localization regression tests;
- complete solver/benchmark documentation.

Normal `GameEngine.hint()` remains the original fast `HintSolver` path. Expectimax is deliberately sandbox-only.

## Expectimax search model

The search alternates player and chance nodes. Player nodes select the highest-value legal move. Chance nodes enumerate every empty cell and both supported spawn values using the game probabilities: tile 2 at 90% and tile 4 at 10%. Search uses copied boards only and does not consume RNG while evaluating hypothetical outcomes.

Default resource bounds are:

```text
searchDepth = 2
maxNodes = 50000
```

When the node budget is exhausted, search falls back to deterministic board evaluation. This prevents an unbounded tree from becoming an invisible device-performance cost.

## Auto Play strategy behavior

Heuristic remains the default. Changing to/from Expectimax:

- pauses automatic playback;
- preserves sandbox board, score, moves, and RNG state;
- clears only prior decision diagnostics;
- never touches `AppController` trusted player state.

Reset Seed recreates the deterministic opening while retaining the selected strategy.

## Benchmark design

`SolverBenchmark.run()` accepts a strategy, deterministic seed list, and positive per-seed move budget. It returns immutable per-seed results plus aggregate score/move/peak-tile/search-node metrics. The CLI defaults to seeds `2048`, `4096`, `8192`, `20260815` and 200 moves per seed.

The harness is for reproducible regression comparison, not a claim that one strategy is globally optimal.

## Focused Phase 18 tests added before final acceptance

```text
test/expectimax_solver_test.dart        6 tests
test/autoplay_strategy_test.dart        5 tests
test/solver_benchmark_test.dart         3 tests
test/solver_demo_screen_test.dart       +1 strategy-selection test
test/localization_test.dart             +1 solver-catalog test
test/solver_demo_localization_test.dart 1 Hindi UI test
```

That is 17 focused additions over the Phase 17 total of 144, for an expected complete total of **161 tests** before final CI confirmation.

## Transparent first analyzer failure

The first full Phase 18 source gate reached formatting successfully but static analysis stopped the candidate before tests:

```text
CI run: 31869526679
Commit: 959f8a230484b0cbdf0e028eabbbe4847ef51d41
Formatting: PASS — 79 files, 0 changed
Static analysis: FAIL — 9 issues
Tests: skipped
Web build: skipped
```

The issues were:

1. a duplicate Hindi `Strategy` key introduced when the solver-specific translation block added a key already used by the How-to-Play strategy section;
2. eight `avoid_print` findings in the command-line benchmark harness.

Corrections:

- the benchmark CLI now uses `dart:io` `stdout.writeln` instead of `print`;
- the duplicate added `Strategy` entry was removed while keeping the existing Hindi `रणनीति` translation as the single source for both Guide and Solver UI.

These defects and the failing run are retained here rather than being hidden. No test/Web success is claimed from that run.

## Major Phase 18 commits

```text
9c0031de9b2185076a81cbe2b1a7f5f53bccc7de  feat: add bounded deterministic expectimax solver
f1bd44c59cf6c8ac3f2e5e4a327405664b5275ba  feat: add selectable autoplay solver strategies
36f467c5d0154b8d88a23d123c73eeb78504f821  test: cover bounded expectimax recommendations
c57dde0766fae40d9c6bd88c5b6c941f5cd7bcca  test: cover expectimax autoplay strategy isolation
bec975c05b1911e9570a5946b787e1dce52cb0b3  feat: add deterministic solver benchmark harness
d406b850b44a80f3be1c6f8e9c8acd6fd0e5fa3c  feat: expose expectimax strategy in solver demo
5f4c8d0d7f2a4242fec65721516f7f97e72d6766  test: cover solver demo strategy selection
3274373f129fd7694803fd6fd90035a180557837  feat: add reusable deterministic solver benchmark suite
decf3cdb32d5c4842f27a4c2255780ed1ab0b6a6  refactor: use reusable solver benchmark suite
1e8e198fa499e7ef0a29982319c8433b4dcc6ed2  test: cover deterministic solver benchmark suite
8cee4e0cc1bb91b40b114709bf5dd5ae007ba396  fix: use stdout for solver benchmark output
98b26714e1354f7a76d57230bee2805352ef5cd0  docs: explain solver strategies in in-app guide
2e693af2fa3e80e54390a3756d2f8b90a2821e34  docs: add expectimax to in-app release highlights
aa23cbb1419d0dbaebabf8243ecda6d7e9c6eb0a  test: cover Hindi advanced solver translations
9cb2f3734ca89b238eafabaf98da2c5fee66da45  test: cover Hindi expectimax solver demo UI
11112fe91fed0d85bc9d90289965e8bd6ea479a0  docs: document expectimax solver and benchmark suite
959f8a230484b0cbdf0e028eabbbe4847ef51d41  docs: document heuristic and expectimax solver boundary
```

Additional small localization-helper/fix commits remain in Git history because they reflect real repository operations. Empty commits were not created solely to increase the count.

## Acceptance status at this point

Phase 18 is not marked accepted by this entry alone. The final permanent CI and current-source native matrix are recorded only after all source/tests/documentation stop moving and the maintained workflows complete against the final candidate. Stable `1.0.0` remains separately blocked on the documented physical-device/accessibility/signing/store qualification.


## Final Phase 18 maintained acceptance and native matrix

Phase 18 was not declared complete from source inspection. The completed source/test candidate was passed through the permanent CI gate and the full hosted native matrix.

### Acceptance attempt 1 — duplicate translation key and CLI lint findings

```text
Commit: 959f8a230484b0cbdf0e028eabbbe4847ef51d41
CI run: 31869526679
Formatting: PASS — 79 files, 0 changed
Static analysis: FAIL — 9 issues
Tests: skipped
Web build: skipped
```

The analyzer found one duplicate constant-map key for Hindi `Strategy` plus eight `avoid_print` lints in `tool/solver_benchmark.dart`. The benchmark CLI was changed to `dart:io` `stdout.writeln`, and the duplicate newly-added solver `Strategy` key was removed so the already-existing `Strategy` → `रणनीति` entry remains the shared source.

### Acceptance attempt 2 — missing localization import in Hindi solver test

A final runtime-source documentation commit was used to trigger the maintained CI/native workflows on the complete Phase 18 runtime tree:

```text
e324882fc861e9e4221020aabb00515c7366a6f7
docs: clarify autoplay strategy isolation in source
```

Its CI gate stopped at one test-code analyzer error:

```text
CI run: 31869794852
CI job: 94976548162
Formatting: PASS — 80 files, 0 changed
Static analysis: FAIL — 1 issue
Cause: Undefined name 'AppLanguage' in test/solver_demo_localization_test.dart
Tests: skipped
Web build: skipped
```

Production solver/runtime code was not implicated. The new Hindi widget test was missing the localization module import. It was corrected in:

```text
b114255b6f510f0e7ba8d0516e9a30eebf4451b8
fix: import solver demo language enum
```

### Authoritative Phase 18 CI gate

The permanent CI workflow then completed successfully:

```text
Commit: b114255b6f510f0e7ba8d0516e9a30eebf4451b8
CI workflow run: 31869835223
CI job: 94976646621
Result: SUCCESS
Runner: ubuntu-24.04
Flutter: 3.47.0 stable
Dart: 3.13.0
DevTools: 2.60.0
Dependency resolution: PASS
Formatting: PASS — 80 files, 0 changed
Static analysis: PASS — No issues found
Automated regression tests: PASS — 161/161
Flutter Web release build: PASS — build/web produced
Flutter Web WASM dry run: PASS
```

The complete test total moved from 144 in Phase 17 to 161 in Phase 18, exactly matching the 17 focused expectimax/strategy/benchmark/localization additions. The Web compiler emitted the existing non-fatal Cupertino icon-font availability warning but still produced `build/web`.

### Current runtime native matrix

The full permanent Platform Builds workflow completed against runtime commit `e324882fc861e9e4221020aabb00515c7366a6f7`. The later `b114...` fix changes only a test import, so runtime application source is identical.

```text
Platform Builds workflow run: 31869794809
Result: SUCCESS

Linux release
  Job: 94976574317
  flutter build linux --release: PASS

Android release APK
  Job: 94976574376
  flutter build apk --release: PASS

Windows release
  Job: 94976574323
  flutter build windows --release: PASS

macOS and unsigned iOS release
  Job: 94976574495
  flutter build macos --release: PASS
  flutter build ios --release --no-codesign: PASS
```

This supersedes the Phase 17 native matrix as the latest hosted multi-platform compilation evidence.

### Phase 18 qualification status

The bounded deterministic Expectimax strategy, selectable Auto Play strategy layer, benchmark library/CLI, English/Hindi solver UI, and all existing project behavior are accepted by the maintained automated gates. No failing analyzer/test/native build is being hidden or counted as passing evidence.

Stable `1.0.0` remains intentionally unpromoted because hosted CI cannot replace physical Android/iOS lifecycle/gameplay checks, real TalkBack/VoiceOver/desktop screen-reader checks, expectimax responsiveness on representative slower devices, real clipboard/platform-handler behavior, long-session checks, native splash/icon review, signing/provisioning/notarization, and store metadata/review.

Focused permanent evidence is recorded in:

```text
docs/PHASE_18_VERIFICATION.md
```

# Phase 19 — Portable Full-Session Replay Archives

Date: **2026-08-15**

## Scope and trust model

Phase 19 implements the roadmap's full-session replay export/import expansion without replacing the existing bounded Move Replay.

Move Replay remains the lightweight read-only view based on the current game plus retained Undo snapshots. Full Replay Archive is a separate portable deterministic action protocol for sessions captured from their actual beginning.

Imported Full Replay Archives are spectator-only. They never replace `AppController.game`, never call the playable Game Backup import path, and cannot update lifetime statistics, achievements, streaks, Daily Challenge history, settings, or trusted per-mode records.

Portable replay JSON is user-editable. Validation establishes deterministic self-consistency, not player identity, cryptographic authenticity, anti-cheat proof, or trusted leaderboard provenance.

## Runtime implementation

### Deterministic event clock

Commit:

```text
7596b2297e701e7ec80aece5e4f779933d4aef78
feat: add deterministic replay event clock
```

`GameEngine.move` accepts optional `DateTime? now` and forwards it into status reconciliation. Existing callers remain compatible.

Replay events store elapsed milliseconds from the captured session start. `ReplayArchivePlayer` reconstructs event time as:

```text
initialState.startedAt + event.elapsedMilliseconds
```

and supplies that recorded event time to the engine. This prevents Time Challenge replay from depending on the spectator device's present wall clock.

### Versioned full-session archive protocol

Commit:

```text
b18d64e5e5c1e8a8f64c2c614dfcd4942a9fbdfd
feat: add full-session replay archive protocol
```

New `lib/domain/replay_archive.dart` contains:

- `ReplayEventKind.move`;
- `ReplayEventKind.undo`;
- `ReplayEventKind.continueAfterWin`;
- `ReplayEventKind.statusRefresh`;
- strict event type, direction, integer, and elapsed-time parsing;
- `ReplayCapture.start(...)` for complete freshly started sessions;
- `ReplayCapture.incomplete(...)` for legacy/restored/imported progress whose earlier actions are unavailable;
- hard `ReplayCapture.maxEvents = 4096`;
- overflow state that stops further full-history recording without stopping normal gameplay;
- portable `ReplayArchive` envelope `nova2048.fullReplay`, version 1;
- maximum encoded archive length of 1,000,000 characters;
- strict envelope, export-time, capture, completeness, and event validation;
- `ReplayArchivePlayer` deterministic reconstruction using defensive unmodifiable frames;
- action legality checks for moves, Undo, win-continuation, status refresh, and event chronology;
- state-equivalence checks for current-session verification.

Complete portable export requires `startsAtSessionStart == true` and `overflowed == false`. The encoder reconstructs the sequence before emitting archive text. Incomplete and overflowed captures fail closed instead of being mislabeled as full-session history.

### Local persistence

Commit:

```text
fb4382cb0bf716805f4bbce6aeafcdb3390b4c5c
feat: persist bounded full-session replay capture
```

LocalStore owns:

```text
nova.replay_capture.v1
```

with save/load/clear behavior. Malformed capture persistence is removed safely. Corrupt current-game recovery clears associated replay metadata, and clearing the current game or all project data clears replay capture.

### AppController capture

`AppController` now:

- creates `ReplayCapture.start(game)` for a fresh `newGame`;
- records successful moves with direction and time;
- records valid Undo;
- records explicit continue-after-win;
- records status-only timed transitions;
- persists capture with the session;
- restores only same-session capture that reconstructs consistently;
- preserves an otherwise valid current game and falls back to incomplete capture if replay metadata is missing, malformed, or mismatched;
- assigns an incomplete capture to Game Backup imports because the sender's earlier actions are unavailable;
- clears replay capture with the current game or all-data reset.

An overflowed capture is a bounded valid prefix, not a complete session. It remains non-exportable while the game continues normally.

### Full Replay Archive UI

Commit:

```text
cb07ac75ca9b47af6ecbdcdffd7faad173272ab9
feat: add full-session replay archive workspace
```

New `lib/features/replay/replay_archive_screen.dart` includes:

- complete/incomplete/overflow/no-capture status;
- **Copy full replay** only for complete non-overflowed capture;
- explicit **Open from clipboard**;
- manual replay-text entry;
- strict validation/rejection feedback;
- imported spectator frames kept only in memory;
- first/previous/next/latest navigation;
- slider scrubbing;
- play/pause;
- 1/2/4 frames per second;
- frame, move, score, and highest-tile metrics;
- imported-spectator label;
- return from imported replay to current replay;
- recorded-event count versus 4,096 disclosure;
- reduced-motion board behavior.

Move Replay links to Full Replay Archive in both normal and no-live-game states. Archive import never calls a player-state import path.

## English/Hindi localization

Hindi runtime strings were added for archive title/navigation, complete/incomplete/overflow status, copy/clipboard/manual-open actions, spectator labels, validation errors, Guide content, trust/privacy copy, and About release highlights.

## Focused regression coverage

Phase 19 adds 22 tests over the Phase 18 total of 161:

```text
test/replay_archive_test.dart                8
test/replay_capture_store_test.dart          3
test/replay_capture_controller_test.dart     4
test/replay_archive_screen_test.dart         4
test/replay_archive_navigation_test.dart     1
test/replay_archive_localization_test.dart   2
```

Representative test commits:

```text
386f1857a611b8f40363c5160b4f440f69607aca test: cover full-session replay archive protocol
95b12fe0f00e187c727f7ae5dc14569e1a644431 test: cover persisted replay capture storage
01408cfa715e6fb21b7cb8c08a518bb9deea8d8 test: cover controller full-session replay capture
bbd3516858132db86b1cb8bae0298fa81f8d8469 test: cover full replay archive spectator UI
7954caac38a4d52ba89f7835e0e9abb129e0d350 test: cover move replay archive navigation
3f9a917ab2a17dc65849c186222bc7923827087b test: cover full replay archive Hindi localization
```

Formatter normalization:

```text
a6825a449a8596d110139cf298f8b00fb8aeeaa7
style: format Dart sources and tests
```

## First clean maintained Phase 19 gate

After formatter normalization, permanent CI completed against the Phase 19 runtime/test tree:

```text
Commit: 4a16608c9f8e94de529ef79ca5d213a81b66baae
CI run: 31871817119
CI job: 94981543084
Result: SUCCESS
Runner: ubuntu-24.04
Flutter: 3.47.0 stable
Dart: 3.13.0
DevTools: 2.60.0
Formatting: PASS — 88 files, 0 changed
Static analysis: PASS — No issues found
Tests: PASS — 183/183
Flutter Web release: PASS — build/web produced
Flutter Web WASM dry run: PASS
```

The existing non-fatal Cupertino icon-font availability warning appeared while `build/web` still completed successfully.

## Transparent automation failures

The following failures are intentionally retained because they affected repository operations but did **not** produce the runtime/live documentation result they were attempting:

1. Core helper staging commit `cf3ebff74c42f497947064c0da8c0334ab9d9263`, run `31871152886`, job `94979863756`: generated Python patch had a syntax error. No runtime source commit was produced.
2. Repaired core helper staging commit `ee3ec3202bc1efa85a9d7cd0a00e5d0c6a85aa836`, run `31871211446`, job `94980011690`: multiline source anchor did not match. No runtime source commit was produced.
3. Early broad Phase 19 CI, including `731871494115` / job `94980745538`, stopped at formatting before analyzer/tests. These are formatter failures, not behavioral test failures and not passing evidence.
# Phase 19 - Portable Full-Session Replay Archives

Date: **2026-08-15**

## Scope and trust model

Phase 19 implements the roadmap's full-session replay export/import expansion without replacing the existing bounded Move Replay. Move Replay remains the lightweight read-only view built from the current game plus retained Undo snapshots. Full Replay Archive is a separate portable deterministic action protocol for sessions captured from their actual beginning.

Imported Full Replay Archives are spectator-only. They never replace `AppController.game`, never call the playable Game Backup import path, and cannot update lifetime statistics, achievements, streaks, Daily Challenge history, settings, or trusted per-mode records.

Portable replay JSON is user-editable. Validation establishes deterministic self-consistency only. It is not a digital signature, player identity proof, anti-cheat mechanism, or trusted leaderboard provenance.

## Deterministic replay event clock

```text
7596b2297e7017e6c80aece5e4f779933d4aef78
feat: add deterministic replay event clock
```

`GameEngine.move` now accepts optional `DateTime? now` and forwards it into status reconciliation. Replay events store elapsed milliseconds from the captured session start. `ReplayArchivePlayer` reconstructs event time as `initialState.startedAt + event.elapsedMilliseconds` and supplies that recorded time to the engine. Timed replay reconstruction therefore does not depend on the spectator device's present wall clock.

## Versioned full replay protocol

```text
b18d64e5e5c1e8a8f64c2c614dfcd4942a9fbdfd
feat: add full-session replay archive protocol
```

Added `lib/domain/replay_archive.dart` with `move`, `undo`, `continueAfterWin`, and `statusRefresh` events; strict event type/direction/integer-time/chronology validation; complete and incomplete capture constructors; hard `ReplayCapture.maxEvents = 4096`; overflow handling that never stops gameplay; portable envelope `nova2048.fullReplay` version 1; 1,000,000-character encoded-size bound; deterministic defensive replay reconstruction; action-legality checks; and current-session state-equivalence validation.

Portable export requires `startsAtSessionStart == true` and `overflowed == false`. The encoder reconstructs the event sequence before producing archive text. Incomplete or overflowed history fails closed instead of being mislabeled as a complete session.

## Bounded local persistence and controller capture

```text
fb4382cb0bf716805f4bbce6aeafcdb3390b4c5c
feat: persist bounded full-session replay capture
```

`LocalStore` now owns `nova.replay_capture.v1` with save/load/clear and corruption-safe recovery. Corrupt current-game recovery removes associated replay metadata, and current-game/Clear All reset removes the capture.

`AppController` starts complete capture for each fresh `newGame`, records successful moves with direction/time, records valid Undo, explicit continue-after-win, and status-only timed transitions, persists capture with the session, restores only same-session deterministically consistent capture, preserves a valid game while falling back to incomplete capture when replay metadata is missing/malformed/mismatched, assigns incomplete capture to Game Backup imports, and clears replay capture with the current game/all-data reset.

An overflowed capture is a valid bounded prefix but remains non-exportable while gameplay continues normally.

## Full Replay Archive workspace

```text
cb07ac75ca9b47af6ecbdcdffd7faad173272ab9
feat: add full-session replay archive workspace
```

Added `lib/features/replay/replay_archive_screen.dart` with complete/incomplete/overflow/no-capture status; Copy full replay only for complete non-overflowed capture; explicit Open from clipboard; manual replay-text entry; strict validation feedback; imported spectator frames retained only in memory; first/previous/next/latest navigation; slider scrubbing; play/pause; 1/2/4 frames per second; frame/move/score/highest-tile metrics; imported spectator labeling; return to current replay; event-count versus 4096 disclosure; and reduced-motion board behavior.

Move Replay links to Full Replay Archive in both normal and no-live-game states, so a received replay can be opened without first creating player progress. Imported spectator replay never calls a player-state import path and never becomes trusted progress.

## English/Hindi localization

Hindi runtime strings cover archive navigation, complete/incomplete/overflow state, copy/clipboard/manual-open actions, spectator labels, validation errors, Guide content, trust/privacy copy, and About release highlights. Focused localization tests cover the real archive UI and catalog strings.

## Focused Phase 19 tests

Phase 19 adds 22 tests over the Phase 18 total of 161:

```text
test/replay_archive_test.dart                8
test/replay_capture_store_test.dart          3
test/replay_capture_controller_test.dart     4
test/replay_archive_screen_test.dart         4
test/replay_archive_navigation_test.dart     1
test/replay_archive_localization_test.dart   2
------------------------------------------------
Total Phase 19 additions                    22
```

Representative commits:

```text
386f1857a611b8f40363c5160b4f440f69607aca  test: cover full-session replay archive protocol
95b12fe0f00e187c727f7ae5dc14569e1a644431  test: cover persisted replay capture storage
01408cfa715e6fb21b7cb8c08a518dbb9deea8d8  test: cover controller full-session replay capture
bbd3516858132db86b1cb8bae0298fa81f8d8469  test: cover full replay archive spectator UI
7954caac38a4d52ba89f7835e0e9abb129e0d350  test: cover move replay archive navigation
3f9a917ab2a17dc65849c186222bc7923827087b  test: cover full replay archive Hindi localization
a6825a449a8596d110139cf298f8b00fb8aeeaa7  style: format Dart sources and tests
```

Coverage includes deterministic multi-move round trip, replay Undo, win continuation, recorded-time timed status transition, invalid action/order rejection, incomplete/overflow export rules, malformed/unsupported/oversized input, event-count/shape validation, persistence repair/reset, controller fresh capture/restart/Undo behavior, Game Backup incomplete-capture policy, clipboard export, spectator-only import isolation, invalid-input preservation, Hindi controls/catalog, and Move Replay navigation.

## First clean maintained Phase 19 gate

```text
Commit: 4a16608c9f8e94de529ef79ca5d213a81b66baae
CI run: 31871817119
CI job: 94981543084
Result: SUCCESS
Runner: ubuntu-24.04
Flutter: 3.47.0 stable
Dart: 3.13.0
DevTools: 2.60.0
Formatting: PASS - 88 files, 0 changed
Static analysis: PASS - No issues found
Tests: PASS - 183/183
Flutter Web release: PASS - build/web produced
Flutter Web WASM dry run: PASS
```

The existing non-fatal Cupertino icon-font availability warning appeared while `build/web` still completed successfully. This is the first clean behavioral gate, not the final current-runtime native qualification record.

## Transparent automation failures

The following failures are retained and are not counted as passing analyzer/test evidence:

1. Core helper staging `cf3ebff74c42f497947064c0da8c0334ab9d9263`, run `31871152886`, job `94979863756`: generated Python patch script had a syntax error. No runtime source commit was produced.
2. Repaired core helper staging `ee3ec3202bc1efa85a9d7cd0a00e5d0c6a85a836`, run `31871211446`, job `94980011690`: multiline source anchor did not match. No runtime source commit was produced.
3. Early broad Phase 19 CI, including run `31871494115` / job `94980745538`, stopped at formatting before analyzer/tests. These were formatter failures, not behavioral test failures.
4. Permanent Format Dart normalized the source/test tree in `a6825a449a8596d110139cf298f8b00fb8aeeaa7`.
5. Oversized documentation helper staging `56927ca2f5100e0b9fcd6acf692aa7a1142c9824`, run `31872000586`, failed workflow parsing before a job. No target document edit occurred.
6. Encoded core-doc helper run `31872236343`, job `94982576071`, failed before target document commits because the decoded executable Python payload was invalid/non-UTF-8.
7. Initial raw-here-document safe documentation helpers produced YAML parse-only failures, including run `31872407775`; no target document commit occurred from those parse failures.
8. First combined TESTING/CHANGELOG/work-log helper run `31872834366`, job `94983983247`, completed TESTING and CHANGELOG steps only in its ephemeral checkout but failed at work-log payload before push. None of those target edits reached main from that failed run; the batch was split afterward.

Corrected documentation helpers use smaller Markdown payloads and commit each target separately, then remove themselves. These failures remain visible instead of being hidden.

## Documentation synchronized

Phase 19 added or updated protocol, roadmap, documentation index, project overview, architecture, storage, privacy, user guide, development rules, FAQ, troubleshooting, security, release checklist, platform behavior, CI scope, Game Backup interaction, testing strategy, changelog, and this chronological work log.

Key permanent documentation:

```text
docs/REPLAY_ARCHIVES.md
```

Key documentation commits already in history include:

```text
bc92fb6000cf9d566537263a1a37123abc4250fa  docs: document full-session replay archive protocol
20033fd2d6febd829572504e22514ae783354648  docs: advance roadmap with full replay archives
4a16608c9f8e94de529ef79ca5d213a81b66baae  docs: index full replay archive documentation
```

Additional per-document commits remain in normal Git history with descriptive messages. No empty/no-op commits were created merely to inflate commit count.

## Stable-release boundary

Phase 19 does not promote the project to stable `1.0.0`. Manual qualification still includes physical Android/iOS lifecycle/gameplay, representative accessibility, real clipboard/platform-handler behavior, long-session checks, native branding, signing/provisioning/notarization, and store metadata/review. Phase 19 additionally requires real-platform checks for large replay copy/open/manual entry, long replay scrub/play/pause/timer cleanup, 4,096-event overflow behavior, incomplete-capture messaging, imported spectator isolation, English/Hindi large-text and screen-reader behavior, and slower-device responsiveness.

Final current-source CI and native matrix evidence will be appended after the final runtime source-documentation trigger completes.

# Phase 20 - File-Based Game Backup Import/Export

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

# Phase 21 — Offline Challenge Code QR Rendering

Date: **2026-08-15**

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

Hosted formatter/analyzer/tests/Web/native builds are strong automated evidence but are not a substitute for those physical-device, assistive-technology, optical, signing, and distribution checks.


---

## 2026-08-16 — Phase 22: Evidence-backed release qualification and fail-closed stable promotion

Phase 22 continued from the Phase 21 release-candidate state without pretending that hosted automation can perform physical-device, assistive-technology, external-handler, signing, or store qualification. The repository already had a mature gameplay/runtime feature set, so this phase hardened the transition from `0.9.x` to a future stable `1.0.0`.

### Implemented release evidence model

Added `docs/release_qualification.json` with schema version 1 and exactly 13 required real-world qualification IDs: `android-device`, `ios-device`, `input-responsive`, `assistive-tech`, `long-session`, `autoplay-real-target`, `challenge-code-real-target`, `move-replay-real-target`, `full-replay-real-target`, `backup-real-target`, `external-handlers`, `native-branding`, and `distribution-metadata`. Every item begins `pending` with no invented evidence. Passed items require non-empty evidence and a valid ISO-8601 timestamp.

### Implemented release readiness CLI

`tool/release_readiness.dart` now validates required release/support/security/CI/continuity files, package/candidate version consistency, manifest JSON/schema, the exact manual-check ID set, allowed statuses, passed-evidence/timestamp completeness, the `[Unreleased]` changelog boundary, and the explicit ROADMAP pre-1.0 boundary. Candidate mode remains usable while qualification is pending; strict `--stable` requires real `1.0.0` metadata and complete passed evidence.

### Permanent CI hardening

The permanent CI gate now formats `lib test tool`, runs analyzer and all tests, validates candidate readiness, asserts that the current RC cannot pass strict stable mode, smoke-runs both deterministic solver strategies, and builds Web. Formatter automation now also owns `tool/**` and correctly produced the canonical-format commit `aa8d3d639d681f7e3972fba020b797d04bab15dc` for the new CLI.

### Phase 22 implementation commits before final documentation

```text
372c4c2377d55eddd6023aeab7d14acfdeb5882c  chore: add release qualification evidence manifest
fff686994ae708ca6022948b21cae95311165fd4  feat: add release readiness gate
8e531d358fd7d6ea8b1cee778ef19ecfa2310b46  ci: enforce release readiness and tool quality
3431724cf66a583b51a89f3e035ab1cd7df3bcef  docs: add evidence-backed release qualification guide
dc905663a0e7ebf1505b0595d70b8a1265b7b1f9  ci: include tool sources in formatter automation
aa8d3d639d681f7e3972fba020b797d04bab15dc  style: format Dart sources tests and tools
593f037c6dfcce2dc2bc2b2eabd2cb95c1189ed5  docs: add machine-enforced stable release boundary
86aaddeb6cfcbfef45c86889060ec5313fdbab31  ci: verify release promotion boundary fails closed
```

### Accepted automated verification

Permanent CI run `31932018261`, job `95128223530`, verified source `86aaddeb6cfcbfef45c86889060ec5313fdbab31` on Ubuntu 24.04 with Flutter 3.47.0, Dart 3.13.0, and DevTools 2.60.0.

```text
Formatting: PASS — 96 files, 0 changed
Static analysis: PASS — No issues found
Automated tests: PASS — 194/194
Candidate release gate: PASS — candidateGatePassed=true; readyForStable=false; 0/13 evidence items passed
Stable boundary assertion: PASS — strict --stable correctly rejected 0.9.0+1, missing [1.0.0] changelog metadata, and all 13 pending evidence items
Solver benchmark smoke: PASS — Heuristic + Expectimax; seeds 2048, 4096, 8192, 20260815; move budget 8 each
Web release: PASS — build/web
Web WASM dry run: PASS
```

The existing non-fatal Cupertino icon-font warning remained visible during Web compilation; the Web build completed successfully. No Flutter gameplay/runtime source changed in Phase 22, so the latest accepted native runtime matrix remains Phase 21 rather than being falsely relabeled.

### Transparent helper failure

Temporary documentation workflow run `31932187504` failed at workflow-definition validation before creating any job or modifying any project file. The cause was the first helper YAML embedding unindented multiline Python string contents inside a YAML block. It was replaced by a small valid workflow plus this repository-local temporary Python helper. This failure did not invalidate permanent CI run `31932018261` and is retained here rather than hidden.

### Documentation synchronized

README, documentation index, CI/CD guide, release checklist, changelog, roadmap, verification record, dedicated release qualification guide, and this continuity log now describe one consistent path from release candidate to stable release.

### Remaining stable-release boundary

The project is intentionally **not** marked `1.0.0`. All 13 real-world evidence items remain pending until actually performed. The stable gate prevents missing manual checks from being silently converted into a stable-release claim by a version edit alone.

---

## 2026-08-16 — Phase 22 regression expansion: fixture-tested stable-release gate

After the initial fail-closed gate was accepted at 194 tests, the gate itself was hardened with real process/filesystem regression fixtures instead of relying only on the live release-candidate invocation.

### Code and test commits

```text
9fe63472a59d4af77c92ef3da6232c96960c3134  feat: make release readiness gate fixture-testable
8b8ba77a8afbf90d93f8d05170435dce4140f309  test: cover release readiness promotion boundaries
28a48c0e7c7d99c4407d6e86b8ac8ed122188fc8  style: format Dart sources tests and tools
57c6312ee26eed0cea8597ebf6417d442cf988cc  docs: document release gate regression fixtures
```

`tool/release_readiness.dart` gained `--root=<path>` so automated tests can point the actual CLI at temporary repository fixtures. Normal invocation still validates the real checkout. JSON output now also reports the resolved root, and duplicate/nonexistent fixture-root errors fail closed.

`test/release_readiness_cli_test.dart` adds six end-to-end scenarios:

1. valid 0.9.0+1 candidate succeeds while stable readiness remains false;
2. complete 1.0.0+1 fixture with all 13 passed evidence records succeeds in strict stable mode;
3. stable metadata with pending evidence is refused;
4. manifest/package candidate mismatch is refused;
5. `passed` status without evidence/timestamp is refused;
6. a missing required manual-check ID is refused.

The stable-success fixture is intentionally synthetic. It proves the gate is capable of opening when every declared condition is satisfied; it does not claim those real checks were performed.

### Accepted current-source automated verification

Permanent CI run `31932367464`, job `95129044532`, verified source `57c6312ee26eed0cea8597ebf6417d442cf988cc`.

```text
Runner: Ubuntu 24.04.4 LTS
Flutter: 3.47.0 stable
Dart: 3.13.0
DevTools: 2.60.0
Formatting: PASS — 97 files, 0 changed
Static analysis: PASS — No issues found
Tests: PASS — 200/200
Release-gate fixture scenarios: PASS — 6/6
Candidate gate: PASS — candidateGatePassed=true; readyForStable=false; 0/13 manual evidence complete
Stable boundary: PASS — strict --stable correctly rejected the live 0.9.0+1 candidate
Solver benchmark: PASS — Heuristic + Expectimax, seeds 2048/4096/8192/20260815, 8 moves each
WASM dry run: PASS
Web release: PASS — build/web
```

The Web build retained the existing non-fatal Cupertino icon-font warning but completed successfully. No Flutter gameplay/runtime source changed in this expansion, so Phase 21 remains the latest native runtime build evidence.

### Release status after regression expansion

The codeable release-engineering boundary is now tested in both directions. The real manifest remains **0/13**, and strict stable mode therefore remains intentionally closed. Physical Android/iOS, representative input/responsive behavior, real assistive technology, long sessions, Auto Play/Challenge Code/replay/backup on real targets, external handlers, native branding, signing/provisioning, privacy/store metadata, and distribution qualification must still be performed before changing the project to stable `1.0.0`.

---

## 2026-08-16 — Phase 23: reproducible release engineering and retained qualification artifacts

Phase 23 continued from the fixture-tested Phase 22 release gate and focused on codeable release/build defects already visible in objective CI logs. It does not claim completion of any physical-device or assistive-technology check.

### Problems found and corrected

1. **Web Cupertino icon font warning.** Phase 22 Web builds succeeded but emitted `Expected to find fonts for ... CupertinoIcons`. `pubspec.yaml` did not declare the font package even though Flutter/Cupertino icon data referenced it. Exact `cupertino_icons 1.0.8` was added and locked to preserve the repository's declared Dart SDK range. Permanent CI now fails if the warning returns. The accepted Phase 23 Web log shows `CupertinoIcons.ttf` being tree-shaken and no missing-font warning.
2. **Deprecated checkout runtime warning.** All repository-owned workflows used `actions/checkout@v4`, which current GitHub-hosted runners were forcing away from its deprecated Node 20 runtime. All six permanent workflows now use `actions/checkout@v6`.
3. **Dependency-lock drift risk.** `lock-dependencies.yml` previously did not automatically follow ordinary `pubspec.yaml` edits. It now watches dependency metadata, while CI independently rejects an unstaged `pubspec.lock` rewrite after `flutter pub get`.
4. **Silent Flutter analysis-options migration.** Flutter 3.47 was rewriting `analysis_options.yaml` in hosted jobs because generated platform trees were not all excluded. The repository now carries the current generated-platform exclusion set explicitly, and CI rejects future drift.
5. **Missing generated macOS FilePicker registration.** Re-running the platform generator produced one meaningful native difference: `macos/Flutter/GeneratedPluginRegistrant.swift` was missing `FilePickerPlugin`. The generated registration was committed, and native jobs now fail if generated dependency/plugin files drift after dependency resolution.
6. **Ephemeral native build evidence.** Successful native builds were discarded when jobs ended. The permanent matrix now creates payload SHA-256 sidecars, packages desktop/Apple bundles safely, hard-fails on missing outputs, and uploads five 14-day qualification artifacts.

### Phase 23 implementation commits

```text
83a8b02443aed3e3e99ea15a5fadebf462094d80  ci: keep dependency lockfile synchronized
3c54a6c33472d6e4cdce732a071e69685a7ad233  ci: move formatter checkout to Node 24 action
5419e3cfbfcc75764dec33c143b43cea6009acbc  ci: modernize branding workflow checkout
91e12965fc2a90cd589b99325f0bf525af5310bf  ci: modernize platform bootstrap checkout
5dd6c0e060295d8f57f5fe9e5340932e9778b77b  ci: move platform builds to checkout v6
ffa40ffc7eca91bf8c4c58eb8174919f92f4d836  ci: fail web builds on missing font assets
1cbf482d1b3eded98f1e1e079bcb02ecab9d4735  build: include Cupertino icon font asset
1d445c7b8291260e974a1d0132c9417f1132b48e  build: generate Flutter platform runners
c82b77f71b650fb0fb9c7e7e3fb75f64ded175ec  build: lock Flutter dependencies
36cf29014a610092f8577cf467dee66b7ce96d8e  ci: reject stale dependency lockfiles
21065f20797f3aa9cad71153f4faf22f90b9dd8e  ci: verify native dependency generation stays clean
c63811d35529c2a7d0b27e441fb5a7466a6dc8e4  test: guard release engineering repository integrity
1024a543e9fc114ee977d69ee6d708413026e000  build: apply current Flutter analysis migration
77d9bb931decdb0840e65131b3b32ebbca5eacd4  ci: reject Flutter project metadata drift
7b21997474a9d68d15151a01ed5b51a563d115f1  test: guard Flutter project metadata migration
5b22795d5aba661bd587e7bcbf2ae6442c8b4b3a  ci: retain checksummed native qualification artifacts
a93542ecae7713214f7f3e4e11a03c647e880129  test: guard qualification artifact publishing
a0581eb13722b28e9f98cf3e2920832b80fa48af  docs: define native qualification artifact handling
8997945b11e0db749ad24dbb434d3f3ef8c3dc5e  ci: allow explicit quality gate dispatch
1f48ebc947596915be3104aa5da56eb6ad291fff  test: guard manual CI dispatch support
```

The platform-bootstrap commit is retained because it repaired the missing macOS FilePicker registration. The dependency lock commit was created by the corrected lockfile automation. Formatting automation found the final repository-integrity test source already canonical and produced no extra formatter commit.

### Accepted Phase 23 quality gate

Final permanent CI run **31934616568**, job **95134494782**, verified source `1f48ebc947596915be3104aa5da56eb6ad291fff`:

```text
Runner: Ubuntu 24.04.4 LTS
Flutter: 3.47.0 stable
Dart: 3.13.0
DevTools: 2.60.0
Checkout v6: PASS
Flutter metadata drift: PASS
Formatting: PASS — 98 files, 0 changed
Static analysis: PASS — No issues found
Tests: PASS — 208/208
Repository-integrity regressions: PASS — 8/8
Candidate gate: PASS — candidateGatePassed=true; readyForStable=false; 0/13 manual evidence complete
Strict stable boundary: PASS — current 0.9.0+1 correctly refused
Solver benchmark: PASS — Heuristic + Expectimax; seeds 2048/4096/8192/20260815; 8 moves each
WASM dry run: PASS
Missing icon-font warning guard: PASS
Web release: PASS — build/web
```

The accepted Web log now reports a tree-shaken `CupertinoIcons.ttf` asset and no `Expected to find fonts for` warning, directly closing the warning that remained documented in Phase 22.

### Accepted native matrix and retained artifacts

Platform Builds run **31934181987** verified source `5b22795d5aba661bd587e7bcbf2ae6442c8b4b3a`:

```text
Linux job 95133491351: PASS — build + package + checksum + upload
Android job 95133491378: PASS — APK + checksum + upload
Windows job 95133491405: PASS — build + ZIP + checksum + upload
Apple job 95133491379: PASS — macOS + unsigned iOS builds + ZIPs + checksums + uploads
```

GitHub retained exactly five artifacts:

```text
9260209072  nova-2048-android-release      25,409,651 bytes  sha256:d88a691dd33bcb3e12544f5fb9b35f623cd5890fe96e74dcefe8af4ada75df5d
9260177318  nova-2048-linux-x64-release     10,396,367 bytes  sha256:8556a5d31017faa4ff7f8c128e097aafc5664cf36e219075ea24499bc58dfcef
9260197932  nova-2048-windows-x64-release   12,655,196 bytes  sha256:9ac4fcc2ce969139e9412466f7d568c361a84b666d0812184b1c671a0966e463
9260232848  nova-2048-macos-release         18,739,502 bytes  sha256:20f52591cb0c3cbd5da330b129a98c03831388d2f8dceadf90d760cf7c7193dc
9260233269  nova-2048-ios-unsigned-release   8,709,732 bytes  sha256:44a0adb2482ef422637eb241659a54fc0b7ed59c343ee7d8e104920783e03721
```

The configured artifact retention expires these run artifacts on **2026-08-30**. Every uploaded artifact also contains the payload-level `.sha256` sidecar generated before upload.

### Manual stable-release boundary remains intact

None of the 13 entries in `docs/release_qualification.json` were changed from `pending`. Hosted artifact availability makes real-target testing more reproducible, but it cannot substitute for physical Android/iOS interaction, real screen readers, external handlers, long sessions, native branding review, signing/provisioning, or store/privacy metadata qualification. The project therefore remains correctly on `0.9.0+1`; strict stable mode remains intentionally closed.


### Final Phase 23 dispatch verification improvement

The documentation helper completed successfully and removed itself, but its cleanup push was authenticated by GitHub Actions. GitHub intentionally suppresses recursive workflow execution for ordinary workflow-token pushes, which meant the permanent CI workflow had no supported explicit trigger for verifying that exact bot-authored documentation head.

Commit `8997945b11e0db749ad24dbb434d3f3ef8c3dc5e` adds `workflow_dispatch` to permanent CI. Commit `1f48ebc947596915be3104aa5da56eb6ad291fff` adds the eighth repository-integrity regression so that manual dispatch support cannot silently disappear. The normal push-triggered CI on `1f48ebc947596915be3104aa5da56eb6ad291fff` then passed 208/208 tests, metadata drift, formatting, analysis, both release-gate directions, solver smoke, WASM dry run, and the warning-enforced Web release build.

This changes no manual release evidence. The real qualification manifest remains 0/13 passed, and stable `1.0.0` remains intentionally unavailable.

## Phase 24 — Version 1.5 current-line migration and release-contract hardening (2026-08-16)

- Promoted current package metadata from 0.9.0+1 to 1.5.0+15 and runtime marketing metadata to 1.5.0.
- Fixed permanent CI so automated candidate health is not incorrectly coupled to already-complete stable manual qualification.
- Migrated the fail-closed release gate, process-level fixtures, qualification manifest, roadmap, release policy, release checklist, and README to Version 1.5.
- Added integrity regressions for package/runtime version synchronization and qualification-driven CI behavior.
- Corrected Windows resource fallback version metadata and consolidated duplicate CHANGELOG Fixed headings.
- Preserved all 13 real-device/accessibility/handler/signing qualification items as pending; no synthetic evidence was invented.
- Migration validation passed dependency resolution, formatting, analysis, the complete Flutter test suite, candidate gate, expected-closed stable gate, and Web release build before push.

### Migration commits

- `a001d52` — chore: set package version to 1.5.0+15
- `e99f126` — chore: set runtime version to 1.5.0
- `0c976b5` — chore: align qualification candidate with Version 1.5
- `8741b4d` — fix: migrate release gate to Version 1.5
- `60ebac0` — test: cover Version 1.5 release gate
- `e2bca6b` — test: guard Version 1.5 metadata integrity
- `899a4f0` — fix: align Windows fallback version metadata
- `1101297` — docs: mark Version 1.5 as current
- `db3ef32` — docs: migrate roadmap to Version 1.5
- `e6ec820` — docs: align qualification policy with Version 1.5
- `a730b2d` — docs: align release gate fixtures with Version 1.5
- `9f36700` — docs: align release checklist with Version 1.5
- `75a3c78` — docs: record Version 1.5 migration and fixes


---

## Phase 24 final verification — Version 1.5 hosted quality and native matrix

Date: **2026-08-16**

- Current package metadata: `1.5.0+15`; runtime marketing version: `1.5.0`.
- Permanent CI source `4d4fe634624b069834786a2aaad356e356281c44`, run `31940994228`, job `95150049412`: SUCCESS.
- CI evidence: Flutter 3.47.0 stable / Dart 3.13.0, formatter 98 files with 0 changes, analyzer `No issues found`, **211/211 tests passed**, Version 1.5 candidate gate passed, strict stable gate remained fail-closed, deterministic solver smoke passed, and Web release build completed without the missing Cupertino icon-font warning.
- Native Platform Builds run `31940994252`: Android job `95150049652`, Linux job `95150049660`, Windows job `95150049634`, and Apple job `95150049606` all SUCCESS.
- Five checksummed qualification artifacts were uploaded for Android, Linux x64, Windows x64, macOS, and unsigned iOS. Their GitHub artifact archive digests are recorded in `docs/RELEASE_ARTIFACTS.md`.
- Hosted compilation/package success is **not** physical-device or store-distribution qualification. `docs/release_qualification.json` remains intentionally at **0/13** passed real-world checks.
- Temporary Version 1.5 migration automation was removed after successful use; the repository retains only permanent release/CI tooling.
- Repository-writing automation for this phase explicitly uses `Sanskar <sanskarin@outlook.in>`.

---

## Phase 25 — Dependency and supply-chain maintenance hardening (2026-08-16)

- Corrected Dependabot maintenance to cover Pub, Android Gradle, and GitHub Actions without requiring the missing custom dependencies label.
- Added pull-request dependency review that fails on newly introduced high-severity vulnerable dependency changes.
- Added CODEOWNERS coverage for default, release, dependency, automation, and platform-sensitive paths.
- Raised the maintained Version 1.5 toolchain floor to Dart >=3.9 and Flutter >=3.35 so pubspec no longer advertises SDKs that cannot resolve the maintained direct dependency set.
- Updated cupertino_icons to 1.0.9, shared_preferences to ^2.5.5, and flutter_lints to ^6.0.0 while keeping file_picker 11.0.2, qr_flutter 4.1.0, and url_launcher ^6.3.2.
- Migrated repository Dart formatting to the canonical Dart 3.9+ formatter style and kept formatting-only changes isolated in per-file commits.
- Fixed three unnecessary-underscore findings exposed by flutter_lints 6 in Achievements, Modes, and Statistics separator callbacks.
- Added four repository-integrity regressions for SDK/dependency floors, supply-chain automation, CODEOWNERS, and the Version 1.5 security policy.
- Added docs/SUPPLY_CHAIN.md and synchronized README, DEVELOPMENT, DEPENDENCIES, SECURITY, documentation index, and CHANGELOG.
- Validation passed dependency resolution, canonical formatting, static analysis under flutter_lints 6, the complete Flutter test suite, Version 1.5 candidate gate, expected-closed stable gate, deterministic solver smoke, and warning-enforced Web release build before push.
- Real-device/accessibility/handler/signing qualification remains 0/13; no hosted automation evidence was substituted for those checks.


---

## Phase 25 final hosted verification — maintained toolchain and native matrix

Date: **2026-08-16**

- Final requalification source: `a719321725ab818edb9f443a8cebdc86ad4fae47`.
- Permanent CI run `31943081231`, job `95154949822`: SUCCESS with dependency/generated metadata synchronization, canonical formatting, zero analyzer issues under `flutter_lints 6`, **215/215 tests**, Version 1.5 candidate gate, expected-closed stable gate, deterministic solver smoke, and warning-enforced Web release build all passing.
- Platform Builds run `31943081259`: Android job `95154950015`, Linux job `95154950051`, Windows job `95154950020`, and macOS + unsigned iOS job `95154950021` all SUCCESS.
- Five fresh checksummed hosted artifacts were retained for Android, Linux x64, Windows x64, macOS, and unsigned iOS; archive IDs and GitHub artifact digests are recorded in `docs/RELEASE_ARTIFACTS.md` and `docs/PHASE_25_VERIFICATION.md`.
- This evidence verifies the maintained Dart/Flutter dependency floor and supply-chain hardening across hosted targets. It does **not** satisfy physical-device, assistive-technology, external-handler, long-session, native-branding, signing/provisioning, or store-distribution checks.
- `docs/release_qualification.json` therefore remains intentionally at **0/13** real-world checks passed.


---

## Phase 26 — GitHub Actions runtime hardening (2026-08-16)

- Migrated every maintained repository checkout step from `actions/checkout@v6` to `actions/checkout@v7` in granular workflow commits.
- Migrated pull-request dependency review from `actions/dependency-review-action@v4` to `@v5`.
- Added a strict repository-integrity regression rejecting checkout v4/v5/v6 and requiring the v7/v5 maintained baseline; the current suite is **216 tests**.
- The initial guarded migration run `31943480975` successfully passed formatting, analysis, 216 tests, release gates, solver smoke, and Web release before its final push was rejected solely because the workflow token lacked permission to modify another workflow file.
- Recovered by applying the already-validated workflow changes directly through GitHub, keeping a temporary compatibility assertion during the staged migration and restoring the strict assertion after all permanent workflows had moved to v7.
- Permanent CI run `31943741993`, job `95156594200`, then passed on the strict migrated repository state using runner `2.336.0`, Flutter `3.47.0`, Dart `3.13.0`, checkout v7, **216/216 tests**, release gates, solver smoke, and Web release.
- Platform Builds run `31943702153` proved checkout v7 and successful release build/package/checksum/upload behavior on Android, Linux, Windows, macOS, and unsigned iOS.
- Disposable PR #8 exercised the real pull-request path; Dependency Review run `31943963173`, job `95157100528`, passed with `actions/checkout@v7` and `actions/dependency-review-action@v5`, then the PR was closed without merge.
- Phase 26 hosted artifact IDs/digests and detailed evidence are recorded in `docs/PHASE_26_VERIFICATION.md` and `docs/RELEASE_ARTIFACTS.md`.
- Real-device/accessibility/handler/signing qualification remains **0/13**; no CI or hosted-build result was substituted for manual evidence.


---

## Phase 27 — Android toolchain compatibility qualification (2026-08-16)

- Evaluated Android build-tool updates as coordinated compatibility sets instead of blindly merging independent Dependabot PRs.
- PR #9 tested AGP 9.3.1 + Kotlin 2.4.10 + Gradle 9.7.0. Normal Flutter CI, Dependency Review, and non-Android hosted targets passed, but Android release lint failed on the normal JDK 17 baseline in `:url_launcher_android:lintVitalAnalyzeRelease` with a `java.util.List.removeLast()` `NoSuchMethodError`.
- A branch-only Temurin JDK 21 diagnostic then passed the exact AGP 9.3.1 stack, including Android release lint/APK/checksum/artifact upload. The project did not promote that workaround because AGP 9.3 still documents JDK 17 compatibility; release lint was never disabled.
- Opened issue #10 as the explicit AGP 9.3 follow-up and closed PR #9 plus the standalone Dependabot AGP PR #3 without merge.
- Kept stable `file_picker 11.0.2`; the relevant built-in-Kotlin cleanup remains on its 12.0.0 prerelease line, so Version 1.5 does not replace a stable runtime dependency with a beta merely to suppress a forward-looking build warning.
- PR #11 isolated the safe subset: AGP remained 9.1.0, Kotlin moved to 2.4.10, and Gradle moved to 9.7.0. Dependency Review v5, complete CI, Android JDK-17 release APK, Linux, Windows, macOS, unsigned iOS, checksum creation, and artifact uploads all passed before merge.
- Merged PR #11 as `b5ddc657880826bb8a0a5621ff03a99050350342`; standalone Dependabot Kotlin/Gradle PRs #6 and #7 were closed as superseded.
- Post-merge Platform Builds run `31944999081` passed Android job `95159531941`, Linux `95159531882`, Windows `95159531908`, and macOS + unsigned iOS `95159531916`.
- Added repository-integrity coverage at `4f17442920026fdfef2c342707883c0454558195` that pins AGP 9.1.0, Kotlin 2.4.10, and Gradle 9.7.0 and explicitly rejects AGP 9.3.1 while issue #10 remains unresolved.
- Permanent CI run `31945071057`, job `95159704902`, passed formatter, analyzer, **217/217 tests**, Version 1.5 candidate gate, expected-closed stable gate, deterministic solver smoke, WASM dry run, and Web release build.
- Added `docs/ANDROID_TOOLCHAIN.md` and `docs/PHASE_27_VERIFICATION.md` with upgrade policy, failure/diagnostic evidence, accepted artifact digests, and revisit criteria.
- Real-device/accessibility/handler/signing qualification remains **0/13**; no hosted toolchain result was substituted for manual evidence.


---

## Phase 28 — Workflow and supply-chain reproducibility hardening (2026-08-16)

- Audited maintained workflows, tracked secrets/signing configuration, TODO/FIXME-style debt, repository protection state, and available GitHub security surfaces.
- Replaced moving remote Action tags with reviewed full 40-character commit revisions for checkout, Flutter setup, Dependency Review, upload-artifact, and Android Java setup.
- Frozen every Flutter-executing workflow to Flutter 3.47.0 and set the composite action cache input to false. GitHub still prepares nested `actions/cache@v5` metadata from the composite action definition, but both cache execution steps are skipped; no cache action step executes.
- Added `persist-credentials: false` to read-only CI, Dependency Review, and native checkout operations. Repository-writing workflows retain only the credentials needed for their explicit push purpose.
- Replaced floating branding Python installs with exact versions in `tool/branding-requirements.txt`; Bootstrap Branding Assets run `31947463847`, job `95165649555`, succeeded with no generated drift.
- Added the official Gradle 9.7.0 complete-distribution SHA-256 to the Android wrapper configuration and regression coverage for the version/checksum pair.
- Made the hosted Android Java baseline explicit with immutable `actions/setup-java` and Temurin JDK 17 rather than relying on runner-image defaults. JDK 21 remains only a diagnostic from issue #10.
- Added repository-integrity and workflow-security regressions for immutable Action references, exact qualified revisions, frozen Flutter/cache policy, pinned branding packages, Gradle checksum, checkout credential persistence, JDK 17, rejection of `pull_request_target`/`write-all`, repository-writing identity, and no force pushes.
- Exercised immutable Dependency Review on disposable PR #13. Run `31947619961`, job `95166040339`, succeeded with no high-or-higher vulnerable dependency changes; the PR was closed without merge.
- Permanent CI run `31948413257`, job `95167995837`, passed **225/225 tests**, 99-file formatting, analyzer, candidate gate, expected-closed stable gate, solver smoke, WASM dry run, and Web release.
- Definitive native run `31948335974` passed Android `95167849002`, Linux `95167849014`, Windows `95167848969`, and macOS + unsigned iOS `95167849007`, including package checksums and artifact uploads.
- Added `docs/WORKFLOW_SECURITY.md` and `docs/PHASE_28_VERIFICATION.md` for executable trust/reproducibility policy and objective evidence.
- GitHub reported `main` as unprotected with required status enforcement off. The connected integration cannot write branch rulesets, so issue #12 tracks this repository-setting requirement rather than pretending CODEOWNERS/YAML enforces it.
- Dependabot/code-scanning/secret-scanning alert APIs were permission-restricted to the connected integration; no claim of empty hidden alert sets is made.
- AGP 9.3.1 remains deferred under issue #10. Dependabot already records the ignored exact release, while future newer AGP releases remain discoverable.
- Real-device/accessibility/handler/signing qualification remains **0/13**; no automation evidence was substituted for physical or distribution evidence.

## Phase 29 — cross-platform timestamp and release-evidence integrity hardening

Date: 2026-08-17

Phase 29 continued the Version 1.5 hardening line after the executable-build documentation work. The phase performed a targeted portability, persistence, and release-gate audit rather than changing deterministic 2048 gameplay behavior.

### Runtime defects fixed

- `GameState.startedAt` is now serialized as an absolute UTC ISO-8601 instant. Newly persisted games, Undo snapshots, Game Backup payloads, and Full Replay initial states therefore do not reinterpret a Time Challenge start merely because portable data is restored under another device timezone.
- Legacy timezone-less game-state values remain readable for backward compatibility and are normalized to UTC on subsequent serialization; no fictitious historical offset is invented for old data that never recorded one.
- `GameBackup.encode()` now normalizes `exportedAt` to UTC.
- `ReplayArchive.encode()` now normalizes `exportedAt` to UTC.
- `DailyRecord.toJson()` now enforces UTC even for directly constructed records; normal `DailyRecord.fromState()` creation was already UTC.
- No game/backup/replay/Daily schema bump was required because JSON field names/types did not change and existing parsers already accept explicit UTC timestamps.

### Release-gate integrity fixed

- `tool/release_readiness.dart` no longer accepts timezone-less manual qualification evidence timestamps as valid passed evidence.
- Future `updatedAt` evidence must identify an absolute instant with `Z` or an explicit numeric offset, for example `2026-08-17T09:00:00Z` or `2026-08-17T14:30:00+05:30`.
- The live qualification manifest was still 0/13 passed when this requirement was tightened, so no accepted real-world evidence was invalidated.
- The gate remains fail-closed for stable `1.5.0` promotion until all 13 genuine manual checks are completed.

### Focused regression coverage

Seven focused cases were added across six test files:

- `test/portable_timestamp_test.dart`
- `test/portable_export_timestamp_test.dart` (two cases: Backup and Full Replay export metadata)
- `test/legacy_timestamp_compatibility_test.dart`
- `test/timed_restore_timestamp_test.dart`
- `test/daily_record_utc_test.dart`
- `test/release_evidence_timestamp_test.dart`

The existing release-readiness stable fixture continues to use explicit `+05:30` evidence timestamps, so the process-level suite covers both rejection of ambiguous local text and acceptance of an explicit numeric offset.

Phase 28's accepted automated baseline was 225 tests. Phase 29 adds seven focused cases; the hosted workflow API confirms the complete `flutter test --coverage` step passed on the accepted source. The continuity record does not manufacture a runner count that was not exposed by that workflow API response.

### Permanent CI acceptance

Accepted integrated source:

`32d50735065cb4ec084990ccfe178d16ba5f0c79`

Permanent CI run `32016750775`, job `95347802636`: **SUCCESS**.

Confirmed successful steps:

- Flutter 3.47.0 setup;
- dependency installation and managed-metadata synchronization;
- canonical Dart formatting;
- static analysis;
- full test suite with coverage;
- Version 1.5 release-candidate readiness metadata gate;
- strict stable-gate fail-closed verification;
- deterministic solver benchmark smoke test;
- Web release build without the guarded missing-font warning.

The repository formatter workflow also produced commit `947306c35de94b1192464bad18c273d0b947f249` (`style: format Dart sources tests and tools`) using `Sanskar <sanskarin@outlook.in>`. The accepted permanent CI formatter check passed after that normalization.

### Native build acceptance

Runtime timestamp-hardening source:

`439a4441ebd2b36c4e1b6e0700d6f3d3359bd016`

Platform Builds run `32015893841`: **SUCCESS** across all configured native jobs.

- Android release APK — job `95345268019`: build, SHA-256, artifact upload successful under Temurin JDK 17 and Flutter 3.47.0.
- Linux release — job `95345268049`: release bundle, archive/checksum, artifact upload successful.
- Windows release — job `95345268000`: release bundle, ZIP/checksum, artifact upload successful.
- macOS + unsigned iOS — job `95345267946`: both release builds, both packages/checksums, and artifact uploads successful.

### Documentation added/updated

- Added `docs/PORTABLE_TIMESTAMPS.md`.
- Added `docs/PHASE_29_VERIFICATION.md`.
- Updated `docs/README.md` to index the timestamp integrity and Phase 29 verification records.
- Updated `docs/RELEASE_QUALIFICATION.md` to require explicit absolute evidence timestamps.
- Updated `docs/RELEASE_GATE_TESTING.md` with the new negative evidence-time fixture and explicit-offset acceptance boundary.

### Audit scope and deliberate non-changes

- Achievement unlock dates remain local-only presentation metadata. They do not determine Time Challenge expiration, Backup trust/ranking, Full Replay reconstruction, Daily seeding, trusted score calculation, or manual release-evidence validity, so Phase 29 did not expand into a broad unrelated `AppController` rewrite.
- Deterministic move/spawn RNG semantics, Challenge Codes, Backup unranked policy, replay spectator-only policy, solver behavior, localization architecture, and accessibility UI were not changed by this phase.
- Intermediate CI runs cancelled by concurrency were superseded by newer commits; they were not treated as test failures. The accepted source has a fully successful permanent CI run.

### Remaining explicit external/manual boundaries

- `docs/release_qualification.json` remains 0/13 real-world checks passed. Physical Android/iOS, assistive technology, real clipboard/file/browser/email handlers, long sessions, native branding, signing/provisioning, and distribution/store metadata still require truthful manual evidence.
- GitHub issue #10 remains open: AGP 9.3.x is deferred because the Android release-lint path failed on the maintained JDK 17 baseline. The accepted baseline remains AGP 9.1.0, Kotlin 2.4.10, Gradle 9.7.0, JDK 17.
- GitHub issue #12 remains open: `main` branch protection/ruleset enforcement requires GitHub repository settings. It cannot be truthfully implemented by repository files alone through the currently available repository actions.

Phase 29 is complete for automated/source-controlled scope and does not claim that the pending real-world stable-release qualification has been completed.

## Phase 30 — Guarded release qualification recorder

Implemented a dedicated maintainer CLI for safely editing the real-world qualification manifest without weakening the existing fail-closed stable-release gate.

Added:

- `tool/record_release_qualification.dart`
- `test/release_qualification_recorder_cli_test.dart`
- `docs/QUALIFICATION_RECORDER.md`
- `docs/PHASE_30_VERIFICATION.md`

Recorder behavior:

- lists all 13 required qualification IDs without mutating the manifest;
- requires an explicit supported ID and one of `pending`, `passed`, or `blocked` for mutations;
- never infers `passed` from hosted CI, compilation, widget tests, or synthetic fixtures;
- requires non-empty evidence for `passed` and `blocked`;
- automatically timestamps passed/blocked updates in UTC unless an explicit ISO-8601 `Z`/numeric-offset timestamp is supplied;
- normalizes explicit timestamps to UTC;
- resets stale evidence/timestamp when a check returns to `pending`;
- supports `--dry-run` for non-mutating previews and `--root=<path>` for isolated regression fixtures;
- rejects malformed manifests, duplicate/missing/unknown qualification IDs, invalid statuses, ambiguous timestamps, and unsafe option combinations.

Process-level regression coverage exercises listing, genuine-evidence recording mechanics, timezone normalization, missing-evidence rejection, timezone-less timestamp rejection, unknown-ID rejection, pending reset behavior, and dry-run non-mutation.

The manual release boundary remains unchanged: `docs/release_qualification.json` still contains no synthesized real-device evidence, and the recorder is only a guarded editing tool. Physical-device, assistive-technology, external-handler, long-session, signing/provisioning, branding presentation, and store-metadata checks must still be performed in representative real environments before stable release promotion.
