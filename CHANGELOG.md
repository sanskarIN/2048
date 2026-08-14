# Changelog

All notable changes to this project are documented here.

## [Unreleased]

### Added
- Initial 2048 Nova Flutter codebase with Android, iOS, Web, Windows, macOS, and Linux runners.
- Deterministic core move engine with persisted RNG state and corruption-safe serialization.
- Classic, Quick, Extended, Challenge, Endless, Target, Time Challenge, Move Limit, Daily, and Zen configurations.
- Selectable Target milestones from 128 through 16384.
- Responsive game UI with touch swipe and Arrow/WASD keyboard controls.
- Challenge timers, move-limit enforcement, hint, pause, restart, win, and game-over flows.
- Persistent save/resume and bounded undo history, including deterministic RNG restoration.
- Local statistics, achievement progress/unlock dates, and offline Daily Challenge history.
- Seven visual palettes plus light/dark/system brightness, high contrast, reduced motion, optional sound, and optional haptics.
- Semantic tile labels, visible numeric values, keyboard access, responsive text/layout behavior, and system animation-preference support.
- Guide, About, Support, GitHub, LinkedIn, business/support email, license, and optional Buy Me a Coffee integration.
- Original 2048 Nova SVG logo, platform launcher icons, PWA icons, native launch branding, and automated branding export workflow.
- Unit/widget tests for engine rules, persistence, Daily Challenge records, controller state, navigation, themes, mode availability, save migration, and external URI policy.
- Open-source governance, contribution, security, privacy, architecture, testing, dependency, accessibility, branding, and release documentation.
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
- Main-branch Dart changes are now automatically formatted by a dedicated workflow before later quality verification.
- Completed or unavailable Daily Challenge runs now require an explicit Replay or Restart confirmation instead of silently creating a fresh board.

### Fixed
- Prevented directional engine write logic from falling through switch cases.
- Preserved RNG state across save/resume and undo snapshots.
- Corrected Linux GApplication identifier to a valid reverse-domain value without underscores.
- Added the explicit `PlayerStats` constructor required by strict analysis.
- Corrected the widget smoke test to scroll lazy mode-list entries into view before asserting them.
- Restricted external actions to validated `https` and non-empty `mailto` URIs; unsupported, insecure, or malformed schemes are rejected.
- Added persisted configuration bounds for board size, target, move/time limits, and random seed.
- Added persisted board validation for dimensions, tile values, counters, RNG state, and timed-game start timestamps.
- Future/unsupported save schemas now fail safely instead of being interpreted as the current format.

### Verification
- Earlier release-candidate quality gate on commit `f3e7aaec6404139951425144cb1fb4d2fda66e27`: formatter clean, analyzer reported no issues, all 29 automated tests passed, and Web release build succeeded.
- Flutter platform-runner bootstrap and branded asset-generation workflows succeeded.
- Native Android, Linux, Windows, macOS, and unsigned iOS release builds previously passed; exact evidence is tracked in `what_changed.md`.
- Final post-hardening quality and native build evidence is recorded in `what_changed.md` after the latest save-validation, URI-policy, Daily Challenge replay, and formatting changes complete verification.

### Security
- No embedded credentials, analytics SDK, advertising tracker, account system, payment SDK, or cloud synchronization service.
- External destinations are opened only through explicit user actions and an `https`/`mailto` scheme allowlist.
- Local structured data is validated and malformed current-game data fails safely.
- Persisted save configuration and board values are range-checked before use.
