# Changelog

All notable changes to this project are documented here.

## [Unreleased]

### Added
- Pull-request dependency review for Pub, Android Gradle, and GitHub Actions dependency surfaces, failing on newly introduced high-severity vulnerable dependency changes.
- Repository CODEOWNERS coverage for default, release, dependency, automation, and platform-sensitive paths.
- Dedicated supply-chain maintenance documentation covering SDK floors, Dependabot, dependency review, lockfile policy, code ownership, and dependency acceptance checks.
- Version 1.5 package/runtime metadata (`1.5.0+15`) with regression coverage that keeps the runtime marketing version synchronized with `pubspec.yaml`.
- Version 1.5 release-gate regression coverage rejecting legacy 0.9 candidates while preserving fail-closed manual qualification.
- Eight repository-integrity regressions covering dependency/lock pairing, macOS FilePicker registration, Flutter analysis migration exclusions, checkout runtime policy, dependency-lock triggers, CI metadata/font guards, and native artifact publishing contracts.
- Checksummed 14-day native qualification artifacts for Android, Linux x64, Windows x64, macOS, and unsigned iOS, with hard failure when expected package files are absent.
- Process-level release-gate regression coverage with six temporary-repository fixtures spanning candidate success, stable success, pending-evidence refusal, candidate mismatch, incomplete passed evidence, and missing required IDs.
- Evidence-backed release qualification with `docs/release_qualification.json`, covering the exact 13 real-device/accessibility/handler/branding/distribution checks that must be completed before stable promotion.
- `tool/release_readiness.dart` candidate/stable CLI with JSON output, required-file/version/manifest validation, evidence/timestamp enforcement, and a fail-closed `--stable` mode.
- Dedicated `docs/RELEASE_QUALIFICATION.md` procedure for recording verifiable manual evidence and promoting the exact qualified commit.
- Offline high-contrast **Challenge Code QR rendering** using pinned `qr_flutter 4.1.0`; the QR contains the exact existing `NOVA1` text and adds no camera permission, scanner, account, cloud transfer, or authentication semantics.
- Responsive `ChallengeCodeQr` presentation with a 260-logical-pixel cap, narrow-layout containment, white background/black modules, semantic labeling, and local render-error fallback.
- Five focused Phase 21 QR regressions covering exact payload handoff, scan contrast/semantics, narrow/wide sizing, Hindi screen copy, and Hindi trust/accessibility guidance.
- Portable spectator-only **Full Replay Archives** using versioned `nova2048.fullReplay` JSON, deterministic action reconstruction, explicit clipboard/manual open, and a hard 4,096-event capture bound.
- Full-session replay action capture for newly started local games, including valid moves, Undo, continue-after-win, and timed status-only transitions with recorded elapsed time.
- Full Replay Archive viewer with scrub/step/play-pause/first/latest controls, 1/2/4-frame-per-second playback, imported spectator-state labeling, and English/Hindi controls/trust messaging.
- Replay-capture persistence and safe recovery under `nova.replay_capture.v1`, including complete/incomplete/overflowed state and Game Backup incomplete-capture policy.
- Twenty-two focused Phase 19 protocol, persistence, controller, widget, navigation, and localization tests.
- Bounded deterministic **Expectimax** strategy for the isolated Auto Play Demo, including real 90%/10% 2/4 chance-node modeling, explicit depth/node limits, deterministic tie behavior, and non-mutating search.
- Selectable Heuristic/Expectimax Auto Play strategy controls with visible expectimax search-node diagnostics; strategy switching pauses playback without resetting sandbox board/RNG state.
- Reusable deterministic solver benchmark library plus `dart run tool/solver_benchmark.dart` CLI for fixed-seed Heuristic/Expectimax regression comparisons.
- Advanced solver unit, benchmark, strategy-isolation, widget, and Hindi localization regression coverage.
- Trusted local **per-mode records** for best score and highest tile, with best-score board-size/target metadata, backward-compatible persistence, and localized expandable Statistics cards.
- Ten focused Phase 17 regression tests covering per-mode serialization/migration, ranked tracking/reset behavior, imported-backup isolation, and English/Hindi Statistics presentation.
- Offline English/Hindi localization framework with System default, English, and हिन्दी language selection, persisted settings, English fallback, localized critical error paths, and Hindi board accessibility semantics.
- Flutter SDK Material/Widgets/Cupertino localization delegates and a repository-owned Hindi translation catalog; no online translation service is required.
- Initial 2048 Nova Flutter codebase with Android, iOS, Web, Windows, macOS, and Linux runners.
- Deterministic core move engine with persisted RNG state and corruption-safe serialization.
- Classic, Quick, Extended, Challenge, Endless, Target, Time Challenge, Move Limit, Daily, and Zen configurations.
- Selectable Target milestones from 128 through 16384.
- Responsive game UI with touch swipe and Arrow/WASD keyboard controls.
- Desktop game shortcuts for Hint (`H`), Undo (`U`), Pause (`P`/Escape), and Restart (`R`).
- Challenge timers, move-limit enforcement, hint, pause, restart, win, and game-over flows.
- Persistent save/resume and bounded undo history, including deterministic RNG restoration.
- Offline shareable **Challenge Codes** for Classic, Quick, Extended, Challenge, Endless, Target, Time Challenge, Move Limit, and Zen using a versioned checksummed `NOVA1.<base64url-payload>.<8-hex-checksum>` representation.
- Challenge Code workspace with mode/Target selection, fresh seed generation, selectable/copyable code text, manual multiline entry, explicit Paste/Validate actions, decoded configuration preview, and normal recoverable-game replacement confirmation before starting.
- Challenge Code validation for maximum input size, prefix/segment shape, hexadecimal/checksum integrity, Base64URL/UTF-8/JSON payload, exact format/version, strict `GameConfig`, required deterministic seed, and supported-mode allowlist.
- Challenge Code domain/UI/navigation regression coverage: 10 codec/determinism tests, 4 screen/state-flow tests, and one Home-navigation smoke regression.
- Read-only **Move Replay** using the validated current game and bounded Undo history, with defensive timeline copies, first/previous/next/latest navigation, slider scrubbing, play/pause, 1/2/4-frame-per-second playback, and bounded-history disclosure.
- Deterministic local heuristic hint solver using board mobility, merges, corner placement, monotonicity, and smoothness.
- Optional clearly labeled **Auto Play Demo / AI Demonstration** using an isolated deterministic seeded sandbox, with Auto Play, pause/resume, single-step execution, speed selection, seed reset, demo-only metrics, and strict separation from player saves/statistics/achievements/Daily history.
- Portable **Game Backup** for copying one current game as versioned validated JSON to the clipboard and restoring it after explicit preview/confirmation.
- Persistent local imported-game **unranked** marker so portable/editable backup data remains isolated from trusted lifetime statistics, achievements, streaks, and Daily Challenge history across restarts.
- Local statistics, average moves/merges per game, achievement progress/unlock dates, and offline Daily Challenge history.
- Seven visual palettes plus light/dark/system brightness, high contrast, reduced motion, optional sound, and optional haptics.
- Positional board/tile semantics with row and column information for assistive technologies.
- Guide, About, Support, GitHub, LinkedIn, business/support email, license, release notes/credits, and optional Buy Me a Coffee integration.
- Direct in-app GitHub bug-report-template action.
- Recoverable-game replacement confirmation before starting a different mode, Daily Challenge, or validated Challenge Code.
- Original 2048 Nova SVG logo, platform launcher icons, PWA icons, native launch branding, and automated branding export workflow.
- Unit/widget tests for engine rules, persistence, Daily Challenge records, controller state, navigation, themes, mode availability, Challenge Code encoding/validation/deterministic start/UI flows, save migration, external URI policy, accessibility semantics, terminal dialogs, replacement guards, session integrity, hints, Auto Play determinism/isolation/controls, Replay filtering/immutability/playback, portable backup validation/UI/unranked policy, and persistence repair.
- Complete user/maintainer documentation index plus dedicated User Guide, FAQ, game-mode reference, Challenge Code specification, data-storage reference, Backup/Restore trust model, platform setup/build guide, development guide, CI/CD guide, troubleshooting guide, and expanded architecture/privacy/accessibility/security/contribution/support/release documentation.
- GitHub Actions for formatting, static analysis, tests, web release builds, native platform release builds, platform bootstrapping, asset generation, and dependency locking.
- Dependabot, expanded issue templates, and expanded pull-request engineering checklist.
- Legacy save-schema migration from schema 0 to the current schema 1 representation.
- Friendly copy fallback when an approved external destination cannot be opened by the platform.

### Changed
- GitHub Actions checkout runtime baseline moved to `actions/checkout@v7` across permanent workflows and was verified on Ubuntu, Windows, and macOS hosted runners.
- Pull-request dependency review moved to `actions/dependency-review-action@v5` and was verified on a real pull-request event using hosted runner `2.336.0`.
- Version 1.5 now declares Dart `>=3.9.0 <4.0.0` and Flutter `>=3.35.0`, matching the maintained dependency floor.
- Updated direct maintenance pins to `cupertino_icons 1.0.9`, `shared_preferences ^2.5.5`, and `flutter_lints ^6.0.0`; current stable `file_picker`, `qr_flutter`, and `url_launcher` pins remain unchanged.
- Dependabot now covers Pub, Android Gradle, and GitHub Actions without depending on a repository label that is not guaranteed to exist.
- The maintained package line is now Version 1.5 (`1.5.0+15` candidate metadata, `1.5.0` marketing version) with the qualification manifest and release policy aligned to the same target.
- Windows version-resource fallback metadata now matches Version 1.5 instead of the old template fallback.
- Repository-owned workflows now use `actions/checkout@v7`; platform artifacts use `actions/upload-artifact@v7`.
- Permanent CI now supports explicit maintainer `workflow_dispatch`, guarded by a repository-integrity regression for verification of bot-authored heads.
- Dependency-lock automation watches dependency metadata, while permanent CI fails when `flutter pub get` changes the committed lockfile or Flutter-managed analysis options.
- `analysis_options.yaml` explicitly carries Flutter 3.47 generated-platform exclusions instead of being silently migrated during CI.
- Maintained CI now passes 215/215 tests, 98-file formatting, metadata drift checks, release gates, solver smoke, and a warning-enforced Web build.
- `tool/release_readiness.dart` now accepts `--root=<path>` for isolated regression fixtures, while normal repository-root behavior and the real 13-item qualification boundary remain unchanged.
- Current maintained CI evidence now passes 200/200 tests and 97-file formatting on the fixture-tested release-gate source.
- Permanent CI formats `tool/`, validates Version 1.5 candidate metadata, proves the stable gate remains fail-closed while real-world qualification is incomplete, smoke-runs both deterministic solver strategies, and then produces the Web release build.
- Formatter automation now covers `lib/`, `test/`, and `tool/` so maintenance CLIs cannot drift outside canonical Dart formatting.
- Stable Version 1.5 promotion criteria are machine-enforced instead of depending only on prose checklists; pending real-world checks remain explicit rather than being fabricated from hosted automation.
- `GameEngine.move` accepts an optional event time so deterministic replay reconstruction can reproduce timed status rules without spectator wall-clock dependence.
- Move Replay now links to Full Replay Archive, including from its no-live-game state so received spectator archives can be opened without creating or replacing player progress.
- Game Backup imports receive incomplete replay capture because sender-side earlier actions are not present; they are never mislabeled as complete full-session histories.
- Normal player Hint deliberately remains the fast read-only heuristic; bounded Expectimax is available only inside the isolated Auto Play sandbox.
- In-app Guide/About and English/Hindi solver copy now distinguish Heuristic, Expectimax, sandbox isolation, and benchmark/resource-limit boundaries.
- Statistics reset now clears historical per-mode records while rebuilding only the observable baseline for a ranked active session; an imported unranked session rebuilds none.
- Ranked legacy current games can seed missing per-mode records during startup repair without inventing records for historical games that are no longer observable.
- Home, modes, gameplay controls/dialogs, Daily Challenge, statistics, achievements, Challenge Codes, Game Backup, Move Replay, Auto Play Demo, Guide, About, Support, splash semantics, and external-link fallbacks now use the shared localization layer.
- Serialized game-move processing to prevent rapid swipe/keyboard requests from racing state persistence.
- Scoped complete-data reset to project-owned preference keys only.
- Replaced non-restorable runtime randomness with a persisted deterministic random source.
- Standardized native application metadata and product naming as **2048 Nova**.
- Replaced platform-specific transition builder assumptions with portable Flutter transition builders.
- Locked resolved Flutter dependencies for reproducible application builds.
- Main-branch Dart changes are automatically formatted by a dedicated workflow before later quality verification.
- Completed or unavailable Daily Challenge runs require an explicit Replay or Restart confirmation instead of silently creating a fresh board.
- Daily replay history preserves the strongest score/move pairing, peak tile, completion, and win state instead of allowing a weaker replay to downgrade history.
- Daily Challenge remains intentionally separate from Challenge Codes: its UTC-date seed/history contract cannot be replaced by arbitrary portable seeded configuration text.
- A valid Challenge Code starts a fresh normal non-Daily game through `AppController.newGame` rather than using the unranked portable-progress restore path.
- The Challenge Code **codec/trust model** still adds no account/cloud service, network requirement, persistence key, or record/progress import surface. Phase 21 adds only pinned `qr_flutter 4.1.0` for local presentation of the exact existing text; it does not add in-app scanning or camera permission.
- Local persistence repairs valid portions of partially corrupt undo and Daily Challenge collections and rewrites repaired storage.
- Statistics reset keeps an active game represented as the current session so win-rate and streak accounting remain internally consistent.
- Challenge countdown refresh runs only for timed games rather than waking every Game screen once per second.
- The existing Hint heuristic is reused by Auto Play only through an isolated `AutoplaySession`; the player-facing Hint remains suggestion-only and read-only.
- Move Replay reuses the existing validated bounded Undo history instead of introducing a second persistence schema or tracking database.
- Portable backup restores clear unrelated prior Undo history and use the normal deterministic engine/save path while record/achievement/Daily mutation is suppressed for the imported session.
- Imported backup `bestScore` history is not trusted as a lifetime record; the local device lifetime best remains authoritative.
- Home explicitly labels a resumable imported session as **Continue Unranked Backup** and exposes the Challenge Codes workspace as a separate configuration-sharing feature.
- The in-app Guide and About release-candidate text now document Challenge Codes, Game Backup, Replay, Auto Play, offline/privacy boundaries, and unranked restore behavior.
- Repository documentation now distinguishes configured/compiled platform support from real-device, assistive-technology, clipboard-handler, signing/provisioning, and store-release qualification.

### Fixed
- Removed release automation assumptions that treated every non-0.9 version as already stable-qualified; candidate CI is now independent from real-device stable qualification while the strict stable gate remains fail-closed.
- Missing Cupertino icon-font asset in Web release builds by explicitly pinning `cupertino_icons 1.0.8`; CI now fails if the missing-font warning returns.
- Generated macOS `file_picker` registration so Game Backup file transport has the expected native plugin registration on macOS.
- Prevented directional engine write logic from falling through switch cases.
- Preserved RNG state across save/resume and undo snapshots.
- Preserved lifetime best score when undoing to an earlier board snapshot.
- Prevented Reset Statistics followed by Undo from resurrecting a pre-reset lifetime best score through retained undo snapshots.
- Blocked board mutation after reaching a non-Endless target until the win is explicitly acknowledged.
- Suppressed hints after terminal game states.
- Preserved a counted win streak if a player continues beyond the target and later loses that same run.
- Restored already-counted win state correctly across app restarts.
- Applied terminal streak accounting when a timed challenge expires without a move.
- Reconciled restored challenge status during startup so an expired timed game cannot briefly resume as active.
- Filtered stale persisted undo snapshots that belong to another game session.
- Hidden Home’s Continue action for completed/lost games.
- Protected win and game-over dialogs from accidental barrier/back dismissal so a terminal state always receives an explicit choice.
- Exposed board dimensions and every positional tile/empty-cell label as distinct semantic nodes while excluding duplicate visual-text semantics.
- Corrected Linux GApplication identifier to a valid reverse-domain value without underscores.
- Added the explicit `PlayerStats` constructor required by strict analysis.
- Corrected the widget smoke test to scroll lazy mode-list entries into view before asserting them.
- Corrected Replay widget tests to scroll controls into the constrained test viewport before tapping instead of assuming below-the-fold controls were initially visible.
- Corrected Game Backup widget tests to scroll the Home backup entry into the constrained test viewport before tapping it.
- Removed an unused backup test import exposed by strict static analysis.
- Corrected the oversized-backup test fixture to construct a large Dart string with `List.filled(...).join()` rather than invalid string multiplication syntax.
- Corrected the initial Challenge Code Base64URL-padding reconstruction to use valid Dart `List.filled(...).join()` rather than unsupported string multiplication.
- Restricted external actions to validated `https` and non-empty `mailto` URIs; unsupported, insecure, or malformed schemes are rejected.
- Added persisted configuration bounds and strict type validation for board size, target, move/time limits, game mode, and random seed.
- Added persisted board validation for dimensions, tile values, score invariants, counters, RNG state, status/acknowledgement consistency, and timed-game start timestamps.
- Future/unsupported save schemas fail safely instead of being interpreted as the current format.
- Malformed settings, statistics, achievement timestamps, and imported-game marker values recover to safe values instead of causing initialization failures.
- Corrupt current-game recovery removes associated Undo and imported-game unranked metadata so stale session policy cannot attach to a future game.
- Daily Challenge records validate date seeds, counters, tiles, flags, and update timestamps.
- Duplicate Daily Challenge records for the same date are merged into one strongest consistent record, preventing duplicate-history inflation.

### Verification
- Phase 19 first clean replay gate: CI `31871817119` on `4a16608c9f8e94de529ef79ca5d213a81b66baae` passed formatting (88 files, 0 changes), analysis, **183/183 tests**, Web release, and Web WASM dry run.

- Phase 18 final gate: CI `31869835223` on `b114255b6f510f0e7ba8d0516e9a30eebf4451b8` passed formatting (80 files / 0 changes), analysis, **161/161 tests**, Web release, and the Web WASM dry run under Flutter 3.47.0 / Dart 3.13.0.
- Phase 18 native matrix: Platform Builds `31869794809` on runtime `e324882fc861e9e4221020aabb00515c7366a6f7` passed Android APK, Linux, Windows, macOS, and unsigned iOS release builds.
- Phase 18 acceptance history remains visible: CI `31869526679` caught a duplicate Hindi key plus benchmark CLI lints; CI `31869794852` caught a missing `AppLanguage` test import. Both were corrected before the final green gate.
- Phase 17 current-source gate: CI `31867788776` on `d33d65840aff67c4e9bf69ad203f46b85146093c` passed formatting, analysis, **144/144 tests**, Web release, and the Web WASM dry run.
- Phase 17 current-source native matrix: Platform Builds `31867788753` passed Android APK, Linux, Windows, macOS, and unsigned iOS release builds on the corrected runtime tree.
- Phase 17 trusted per-mode records final gate: CI run `31867499047` on commit `c443f9fde0cc243269be57515772378c06284e86` used Flutter 3.47.0 / Dart 3.13.0; formatting passed with 74 files / 0 changes, analysis reported no issues, **144/144 tests passed**, the Web release build succeeded, and the WASM dry run passed.
- Phase 17 acceptance history remains visible: CI `31867316152` caught an unused test local during analysis, and CI `31867370893` reached 142 passed / 2 failed because localized combined metadata was incorrectly asserted as separate widgets; both test-quality defects were corrected before the final green gate.
- Phase 16 English/Hindi localization final gate: CI run `31806785165` on commit `9dea87e73803d83c3aa0614d35f7860773dbca04` used Flutter 3.47.0 / Dart 3.13.0; formatting passed with 70 files and 0 changes, analysis reported no issues, **134/134 tests passed**, the Web release build succeeded, and the WASM dry run passed.
- Phase 16 localization native matrix: Platform Builds run `31804713200` on production commit `5048486775b0c9702583f348bfc5be71219e83ae`; Android release APK, Linux, Windows, macOS, and unsigned iOS all succeeded.
- Transparent Phase 16 failures remained visible: analyzer run `31804557648` found an unused Auto Play import; lock helper run `31804740412` hit an unrelated Flutter-generated working-tree change; full-suite runs `31805260580` and `31806175302` exposed stale direct-widget harnesses missing localization delegates. Those issues were corrected and the final 134-test gate passed.
- Earlier release-candidate quality gate on commit `f3e7aaec6404139951425144cb1fb4d2fda66e27`: formatter clean, analyzer reported no issues, all 29 automated tests passed, and Web release build succeeded.
- A later post-hardening gate expanded this to 37 passing automated tests before the Phase 11 work above.
- Final Phase 11 quality gate: CI run `31777374553` on commit `1ecbf0881f723af1829fda523752562660a86a98` used Flutter 3.47.0 / Dart 3.13.0; formatting passed with 47 files and 0 changes, analysis reported no issues, **81/81 tests passed**, and the Web release build succeeded.
- Phase 12 Auto Play quality gate: CI run `31778558429` on commit `1d98042558ab7ffe40c9da4ad42dbbf8263dcaf6` used Flutter 3.47.0 / Dart 3.13.0; formatting passed with 51 files and 0 changes, analysis reported no issues, **86/86 tests passed**, and the Web release build succeeded.
- Phase 12 native matrix: Platform Builds run `31778424208` on commit `a1cc17836834750c542c69ffdf3c5e582d4e43ab`; Android release APK, Linux release, Windows release, macOS release, and unsigned iOS release all succeeded with the Auto Play production code included.
- Phase 13 Move Replay quality gate: CI run `31779838751` on commit `278ba039d0b7b59ce54c72c5ed0fcd0401ba537a` used Flutter 3.47.0 / Dart 3.13.0; formatting passed with 55 files and 0 changes, analysis reported no issues, **92/92 tests passed**, the Web release build succeeded, and the WASM dry run passed.
- Phase 13 Replay native matrix: Platform Builds run `31779566057` on production commit `4f3cc6f55ae6b2f50b4758db22569b7ec48ddafd`; Android release APK, Linux release, Windows release, macOS release, and unsigned iOS release all succeeded.
- Intermediate Replay CI run `31779369661` recorded 90 passing / 2 failing tests because below-the-fold controls were tapped without scrolling in the widget harness; commit `501b2a512c2f185461129f2e294504e43e883d59` fixed the harness and the final 92-test run passed.
- Phase 14 portable-backup coverage added 20 focused tests (7 codec, 5 imported-policy, 4 backup-screen, 4 unranked-marker) to the prior 92-test suite. Final Phase 14 CI run `31787639781` on commit `1371ef9eaa00f1da5a2ce0370a1f22eb1f2f4cd2` passed formatting, static analysis, **112/112 tests**, and the Web release build.
- Final Phase 14 clipboard-refactor native matrix: Platform Builds run `31787016748` on production commit `dd3c79bec40cf1aa1e4b00190d32393b249902e0`; Android release APK, Linux release, Windows release, macOS release, and unsigned iOS release all succeeded.
- Phase 14 intermediate CI run `31781326279` exposed an unused backup-test import under static analysis; the import was removed by commit `3446413574582c196a47877fe1bfbe63addbf71d`.
- Phase 15 Challenge Code coverage adds 15 focused tests to the 112-test Phase 14 suite: 10 codec/determinism/validation cases, 4 screen/state-flow cases, and one Home-navigation regression.
- Final Phase 15 quality gate: CI run `31796242355` on commit `643b38665738ce314eea81e3dcc8887c77fb2257` used Flutter 3.47.0 / Dart 3.13.0; formatting passed with **66 files / 0 changes**, analysis reported **No issues found**, **127/127 tests passed**, the Web release build succeeded, and the WASM dry run passed.
- Final Phase 15 native matrix: Platform Builds run `31795329370` on production/in-app-doc commit `7c83d7a14656d9309b54205de1f72e0af131f551`; Android release APK, Linux release, Windows release, macOS release, and unsigned iOS release all succeeded with Challenge Code runtime/in-app documentation included.
- Earlier Phase 15 CI run `31795076552` passed formatter, analyzer, and tests but its Web step was cancelled by concurrency after newer commits superseded it; it is not treated as a code failure and is superseded by complete successful run `31796242355`.
- Flutter platform-runner bootstrap and branded asset-generation workflows succeeded.
- The permanent workflow directory has been cleaned of temporary one-time patch/wiring workflows and contains only maintained bootstrap, CI, formatting, dependency-lock, and platform-build automation.
- Full chronological evidence, including real intermediate failures and superseded runs rather than hidden history, is maintained in `what_changed.md`.

### Security
- Portable/editable Game Backup progress is excluded from per-mode record updates across import, continued moves, restart restoration, and statistics reset.
- Persisted per-mode record values are sanitized/bounded before use, and unknown future mode keys are ignored.
- No embedded credentials, analytics SDK, advertising tracker, account system, payment SDK, or cloud synchronization service.
- External destinations are opened only through explicit user actions and an `https`/`mailto` scheme allowlist.
- Local structured data is validated; malformed current-game data fails safely; partially corrupt bounded histories are repaired from valid records when possible.
- Persisted save configuration, state relationships, and board values are type/range-checked before use.
- Challenge Code input is capped at 1024 characters before payload parsing and validates prefix/shape, hexadecimal FNV-1a checksum, Base64URL/UTF-8/JSON envelope, exact format/version, strict configuration/seed bounds, and supported non-Daily mode before any game can start.
- Challenge Code checksum is explicitly a corruption detector, not encryption, a digital signature, authentication, identity proof, or an anti-cheat mechanism.
- Challenge Codes cannot import board progress, score, lifetime statistics, achievements, streaks, settings, Daily history, or Undo snapshots and add no network/account/cloud dependency.
- Move Replay reads existing local game/Undo data through defensive copies and has no live-game/statistics/achievement/Daily mutation path.
- Auto Play adds no network service, model download, or player-data persistence path; its sandbox is discarded with the demo screen.
- Portable Game Backup is an explicit clipboard action and is limited to 128 KiB before JSON parsing; the envelope format/version/timestamp and embedded `GameState` are strictly validated.
- Portable backup JSON is plain, unsigned, user-editable data and therefore can never choose its own trusted ranking status; every confirmed import is locally marked unranked.
- Portable import cannot import or mutate lifetime statistics, achievements, streaks, Daily history, settings, or old Undo data, and cannot award a ranked terminal win.
- No signing credentials, platform private keys, provisioning profiles, or secrets are stored in the public repository.

### Phase 20 — File-based Game Backup

- Added explicit user-selected Game Backup file export/import using the existing version-1 backup envelope and `.nova2048` / `.json` chooser filters.
- Added `GameBackupFilePort` and pinned `file_picker 11.0.2` so platform transport stays isolated from domain validation and ranked-state policy.
- Added a 512 KiB pre-decode file byte limit plus strict UTF-8 before the existing 128 Ki-character JSON protocol bound.
- Added macOS user-selected read/write sandbox entitlement for Debug/Profile and Release.
- File restores use the same explicit preview and persistent unranked `AppController.importGameBackup()` path as clipboard restores.
- Added five file-flow widget regressions plus one Hindi catalog regression, bringing the first clean Phase 20 gate to 189/189 tests.
- First clean gate: CI `31874929593` on `1cd1b4230f6200c9208709d0c76f12fd3a20fce2` passed formatting (91 files, 0 changes), analyzer, 189 tests, Web release, and WASM dry run.

#### Phase 20 final verification

- Final current-source CI `31875447398` on `188e81c607eca76516018be8c668eab41b777cc1` passed formatting (91 files, 0 changes), static analysis, 189/189 tests, Web release, and Web WASM dry run on Flutter 3.47.0 / Dart 3.13.0.
- Initial Platform Builds `31875177571` failed Android plugin registration only; Linux, Windows, macOS, and unsigned iOS passed.
- `188e81c607eca76516018be8c668eab41b777cc1` enables AGP-9 built-in Kotlin so `file_picker` Kotlin sources remain available to Flutter plugin registration.
- Fresh Platform Builds `31875447417` passed Android `94990368847`, Linux `94990368919`, Windows `94990368886`, macOS and unsigned iOS `94990368933`.
- Stable `1.0.0` remains unpromoted pending the documented real-device/file-picker/accessibility/signing/store checks.

## Phase 21 final verification evidence

The completed offline Challenge Code QR feature is accepted on runtime source `2678e65824ca088c4ba93342bc8737fc18ec7708`.

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

The first final-source CI `31877417527` failed only the formatting gate because 32 files required current Dart formatting. Maintained formatter run `31877417558` produced commit `03f26863462609b3b7ff33b0bce81640580fbe18`; the final source trigger then passed all acceptance workflows. Real-device optical QR scanning and the existing manual release boundaries remain outstanding, so `1.0.0` is not promoted.
