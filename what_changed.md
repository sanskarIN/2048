# 2048 Nova — Development Log

> This file is the primary continuity/progress record for the repository. Objective test/build evidence is recorded here instead of relying on chat history.

## 2026-08-14 — 0.9.0 release-candidate implementation and verification

### Project

- **Project:** 2048 Nova
- **Version:** `0.9.0+1`
- **Repository:** https://github.com/sanskarIN/2048
- **Branch:** `main`
- **Creator / branding:** Sanskar / **Made by the Sanskar**
- **Commit email used by repository automation:** `sanskarin@outlook.in`
- **License:** MIT
- **Current phase:** Phase 10 — release-candidate verification complete; manual/device release validation remains before 1.0.0
- **Latest production-code commit used by native build verification:** `eacdb9dc04b4467271f98ce2104e60daf0124f6d` — `fix: use portable page transition builders`
- **Latest test-fix commit used by the final quality gate:** `f3e7aaec6404139951425144cb1fb4d2fda66e27` — `test: scroll lazy mode list before asserting offscreen entries`
- **Latest documentation commit before this log refresh:** `3d5988f1a7a29d38dbd72602e2c489d5975c7b5b` — `docs: update changelog for release candidate verification`

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
