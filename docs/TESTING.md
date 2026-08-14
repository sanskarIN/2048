# Testing Strategy

2048 Nova uses automated tests for deterministic rules, persistence integrity, controller behavior, accessibility semantics, terminal-state safety, Auto Play isolation, read-only replay integrity, and important UI flows. GitHub Actions is the objective source of truth for repository-wide formatter, analyzer, test, and build status.

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

`test/daily_record_test.dart` covers Daily Challenge progress, completion, retained wins, serialization, date validation, counter/tile validation, completion flags, and timestamps.

`test/daily_replay_history_test.dart` verifies weaker replays cannot downgrade a previous Daily best result and stronger replays update score-associated metrics while preserving the peak tile.

`test/local_store_test.dart` covers save/resume, undo history, Daily Challenge persistence, duplicate-date normalization, bounded/self-healing history repair, invalid map recovery, scoped data clearing, and malformed-save recovery.

`test/app_controller_test.dart` covers persisted appearance/accessibility settings, malformed preference recovery, malformed statistics, malformed achievement timestamps, stale undo filtering, serialized move requests, timed terminal statistics, continued-win streak behavior, and complete local reset behavior.

`test/session_integrity_test.dart` covers counted-win restoration across restart and statistics reset behavior while a game is active.

`test/restored_challenge_status_test.dart` verifies expired timed games are reconciled during startup before the UI can resume them.

`test/undo_best_score_test.dart` verifies undo restores a board snapshot without lowering the lifetime best score.

`test/statistics_reset_undo_test.dart` verifies that resetting statistics also normalizes retained current-session undo snapshots, so a later Undo and future move cannot resurrect a pre-reset lifetime best score.

`test/external_link_test.dart` covers the approved external URI policy.

## Widget and interaction coverage

`test/widget_smoke_test.dart` validates app startup/navigation, theme selection, and availability of the primary game modes.

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

## Current Phase 13 quality evidence

The final Replay quality gate is:

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

The Phase 13 native matrix is:

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
- Auto Play start/pause/resume, single-step, speed changes, reset, navigation-away timer cleanup, and readability on representative real platforms;
- Move Replay first/previous/next/latest navigation, slider scrubbing, play/pause, all speed choices, bounded-history disclosure, navigation-away timer cleanup, and readability on representative real platforms;
- confirmation that replay does not mutate the actual saved game while it is being viewed;
- real browser/email external-link handlers;
- native splash/icon presentation;
- haptic/sound capability behavior;
- signing, provisioning, packaging, and store metadata.

These manual/device/store checks are release boundaries, not hidden automated claims.
