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
