# Changelog

All notable changes to this project are documented here.

## [Unreleased]

### Added
- Initial 2048 Nova Flutter codebase with Android, iOS, Web, Windows, macOS, and Linux runners.
- Deterministic core move engine with persisted RNG state and corruption-safe serialization.
- Classic, Quick, Extended, Challenge, Endless, Target, Time Challenge, Move Limit, Daily, and Zen configurations.
- Selectable Target milestones from 128 through 16384.
- Responsive game UI with touch swipe and Arrow/WASD keyboard controls.
- Desktop game shortcuts for Hint (`H`), Undo (`U`), Pause (`P`/Escape), and Restart (`R`).
- Challenge timers, move-limit enforcement, hint, pause, restart, win, and game-over flows.
- Persistent save/resume and bounded undo history, including deterministic RNG restoration.
- Deterministic local heuristic hint solver using board mobility, merges, corner placement, monotonicity, and smoothness.
- Local statistics, average moves/merges per game, achievement progress/unlock dates, and offline Daily Challenge history.
- Seven visual palettes plus light/dark/system brightness, high contrast, reduced motion, optional sound, and optional haptics.
- Positional board/tile semantics with row and column information for assistive technologies.
- Guide, About, Support, GitHub, LinkedIn, business/support email, license, release notes/credits, and optional Buy Me a Coffee integration.
- Direct in-app GitHub bug-report-template action.
- Recoverable-game replacement confirmation before starting a different mode or Daily Challenge.
- Original 2048 Nova SVG logo, platform launcher icons, PWA icons, native launch branding, and automated branding export workflow.
- Unit/widget tests for engine rules, persistence, Daily Challenge records, controller state, navigation, themes, mode availability, save migration, external URI policy, accessibility semantics, terminal dialogs, replacement guards, session integrity, hints, and persistence repair.
- Open-source governance, contribution, security, privacy, architecture, testing, dependency, accessibility, branding, hint-solver, and release documentation.
- GitHub Actions for formatting, static analysis, tests, web release builds, native platform release builds, platform bootstrapping, asset generation, and dependency locking.
- Dependabot, issue templates, and pull-request template.
- Legacy save-schema migration from schema 0 to the current schema 1 representation.
- Friendly copy fallback when an approved external destination cannot be opened by the platform.

### Changed
- Serialized game-move processing to prevent rapid swipe/keyboard requests from racing state persistence.
- Scoped complete-data reset to project-owned preference keys only.
- Replaced non-restorable runtime randomness with a persisted deterministic random source.
- Standardized native application metadata and product naming as **2048 Nova**.
- Replaced platform-specific transition builder assumptions with portable Flutter transition builders.
- Locked resolved Flutter dependencies for reproducible application builds.
- Main-branch Dart changes are automatically formatted by a dedicated workflow before later quality verification.
- Completed or unavailable Daily Challenge runs require an explicit Replay or Restart confirmation instead of silently creating a fresh board.
- Daily replay history preserves the strongest score/move pairing, peak tile, completion, and win state instead of allowing a weaker replay to downgrade history.
- Local persistence repairs valid portions of partially corrupt undo and Daily Challenge collections and rewrites repaired storage.
- Statistics reset keeps an active game represented as the current session so win-rate and streak accounting remain internally consistent.
- Challenge countdown refresh runs only for timed games rather than waking every Game screen once per second.

### Fixed
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
- Restricted external actions to validated `https` and non-empty `mailto` URIs; unsupported, insecure, or malformed schemes are rejected.
- Added persisted configuration bounds and strict type validation for board size, target, move/time limits, game mode, and random seed.
- Added persisted board validation for dimensions, tile values, score invariants, counters, RNG state, status/acknowledgement consistency, and timed-game start timestamps.
- Future/unsupported save schemas fail safely instead of being interpreted as the current format.
- Malformed settings, statistics, and achievement timestamps recover to safe values instead of causing initialization failures.
- Daily Challenge records validate date seeds, counters, tiles, flags, and update timestamps.
- Duplicate Daily Challenge records for the same date are merged into one strongest consistent record, preventing duplicate-history inflation.

### Verification
- Earlier release-candidate quality gate on commit `f3e7aaec6404139951425144cb1fb4d2fda66e27`: formatter clean, analyzer reported no issues, all 29 automated tests passed, and Web release build succeeded.
- A later post-hardening gate expanded this to 37 passing automated tests before the Phase 11 work above.
- Final Phase 11 quality gate: CI run `31777374553` on commit `1ecbf0881f723af1829fda523752562660a86a98` used Flutter 3.47.0 / Dart 3.13.0; formatting passed with 47 files and 0 changes, analysis reported no issues, **81/81 tests passed**, and the Web release build succeeded.
- Final production-code native matrix: Platform Builds run `31777275982` on commit `b95d0a630521f896016dff733c8c4f9dc1e082e3`; Android release APK, Linux release, Windows release, macOS release, and unsigned iOS release all succeeded.
- Flutter platform-runner bootstrap and branded asset-generation workflows succeeded.
- Full chronological evidence, including real intermediate failures that were fixed rather than hidden, is maintained in `what_changed.md`.

### Security
- No embedded credentials, analytics SDK, advertising tracker, account system, payment SDK, or cloud synchronization service.
- External destinations are opened only through explicit user actions and an `https`/`mailto` scheme allowlist.
- Local structured data is validated; malformed current-game data fails safely; partially corrupt bounded histories are repaired from valid records when possible.
- Persisted save configuration, state relationships, and board values are type/range-checked before use.
