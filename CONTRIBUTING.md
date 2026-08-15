# Contributing to 2048 Nova

Thank you for helping improve 2048 Nova. Contributions should preserve the project's deterministic game rules, offline-first behavior, accessibility requirements, portable-input trust boundaries, local-data integrity, and truthful release verification.

## Before you start

Read the documentation relevant to your change:

- [`README.md`](README.md) — project overview and setup.
- [`docs/README.md`](docs/README.md) — documentation index.
- [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) — layer boundaries.
- [`docs/GAME_ENGINE.md`](docs/GAME_ENGINE.md) — game-rule invariants.
- [`docs/CHALLENGE_CODES.md`](docs/CHALLENGE_CODES.md) — shareable seeded-code format and trust model.
- [`docs/DATA_STORAGE.md`](docs/DATA_STORAGE.md) — persistence rules.
- [`docs/BACKUP_AND_RESTORE.md`](docs/BACKUP_AND_RESTORE.md) — portable progress trust boundary.
- [`docs/ACCESSIBILITY.md`](docs/ACCESSIBILITY.md) — accessibility requirements.
- [`docs/DEVELOPMENT.md`](docs/DEVELOPMENT.md) — detailed development workflow.

For a bug fix, first look for an existing issue. For a security-sensitive problem, follow [`SECURITY.md`](SECURITY.md) instead of posting exploit details publicly.

## Development setup

1. Install stable Flutter and Git.
2. Fork or clone the repository.
3. From the repository root run:

```bash
flutter doctor -v
flutter pub get
```

4. Run the app on an available target:

```bash
flutter run
```

Platform-specific native development requires the normal Flutter platform toolchain.

## Required quality checks

Before opening a pull request, run:

```bash
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
flutter build web --release
```

If formatting differs, apply:

```bash
dart format lib test
```

and review the formatted result before committing.

Native changes should also be exercised on the relevant host/platform where practical. GitHub Actions runs the configured Android, Linux, Windows, macOS, and unsigned-iOS release matrix for relevant source/native changes.

## Architecture rules

- Keep deterministic game rules and portable codecs in `lib/domain/` and independent from Flutter widgets.
- Keep `SharedPreferences` access inside the data layer rather than feature screens.
- Use `AppController` for ranked player-session/statistics/achievement/Daily orchestration.
- Keep reusable route/link/replacement/clipboard helpers under shared application utilities.
- Do not make Replay mutate the live player session.
- Do not make Auto Play Demo write player saves or lifetime records.
- Keep portable imported progress unranked unless the entire trust model is deliberately redesigned and reviewed.
- Keep Challenge Codes configuration-only unless a separately versioned protocol and trust policy are deliberately introduced.

## Game-engine changes

Changes to movement, merging, spawning, target handling, move/time limits, RNG, or hints need focused unit tests.

At minimum consider:

- all four directions;
- invalid/no-change moves;
- one-merge-per-source-tile behavior;
- score and merge accounting;
- deterministic RNG continuation;
- save/Undo behavior;
- terminal state behavior;
- interaction with challenge modes.

Do not change a rule only in the UI while leaving the domain engine inconsistent.

## Challenge Code changes

Challenge Code text is untrusted input and the format is a public compatibility surface. Preserve or deliberately version:

- `NOVA1` prefix/format identity;
- envelope version;
- maximum input length before decode/parse;
- checksum verification before payload parsing;
- Base64URL/UTF-8/JSON validation;
- strict `GameConfig.fromJson()` validation;
- deterministic seed requirement and bounds;
- supported-mode allowlist;
- Daily Challenge exclusion unless Daily history semantics are intentionally redesigned;
- explicit decoded preview and normal recoverable-game replacement confirmation;
- no board progress, score, lifetime record, achievement, setting, Daily history, or Undo import;
- no hidden networking/account/cloud behavior;
- documentation that describes the checksum only as corruption detection, not cryptographic authentication.

Add focused pure-domain tests in `test/challenge_code_test.dart` and UI-flow tests in `test/challenge_code_screen_test.dart`. Changes to clipboard behavior should retain the `TextClipboard` abstraction so tests need not depend on a real platform channel.

## Persistence and migration changes

Persisted input is untrusted. New or changed persistence must:

- validate types and ranges;
- remain corruption-safe;
- define a bounded policy for growing collections;
- update reset behavior;
- preserve or explicitly migrate supported old schema data;
- reject unsupported future schema values;
- add malformed-data regression tests;
- update [`docs/DATA_STORAGE.md`](docs/DATA_STORAGE.md).

Do not use blanket preference clearing for project reset.

Challenge Codes currently add no persistence key. Adding a code-history store would require an explicit retention, reset, privacy, and migration design.

## Backup/import changes

Portable Game Backup is an explicit trust boundary. Preserve:

- envelope format/version validation;
- maximum input size before parsing;
- strict embedded `GameState` validation;
- explicit replacement confirmation;
- Undo isolation;
- local unranked marker persistence;
- exclusion of lifetime statistics, achievements, settings, and Daily history;
- no lifetime-record mutation by imported play.

Do not reuse the Challenge Code ranked/fresh-game policy for Backup. Challenge Codes contain no progress; Backup does. See [`docs/BACKUP_AND_RESTORE.md`](docs/BACKUP_AND_RESTORE.md).

## UI and accessibility changes

For user-facing changes:

- keep visible labels understandable without color alone;
- add semantic labels/tooltips where needed;
- keep controls reachable with scrolling on small viewports;
- preserve keyboard/focus behavior on desktop/Web;
- respect high contrast and reduced motion;
- test large text/narrow layouts when relevant;
- add widget or semantics regression tests for critical flows.

Portable text UIs also need readable validation messages, long-text handling, explicit Copy/Paste actions, and safe replacement confirmation.

A passing semantics unit test is not a substitute for final real screen-reader qualification.

## External links and privacy

Use the shared external-link helper for browser/email destinations. Do not introduce insecure or hidden schemes.

Do not add analytics, advertising, account, tracking, cloud-sync, or remote-AI dependencies without an explicit project decision, privacy review, documentation update, and user-visible behavior review.

Challenge Codes must remain local/offline by default unless a separate networked feature is explicitly designed and documented.

## Dependencies

Keep dependencies minimal. Before adding one, explain why Flutter/Dart/platform APIs are insufficient and consider:

- maintenance status;
- supported platforms;
- binary/app-size impact;
- license;
- privacy/network behavior;
- transitive dependency cost;
- Web and native build compatibility.

Update [`docs/DEPENDENCIES.md`](docs/DEPENDENCIES.md) when dependency policy changes.

## Commit style

Prefer small, coherent Conventional Commits:

```text
feat: add ...
fix: prevent ...
test: cover ...
docs: document ...
refactor: isolate ...
perf: reduce ...
build: update ...
ci: verify ...
chore: maintain ...
```

Do not create empty/no-op commits merely to inflate history.

## Pull-request checklist

A good pull request explains:

- what changed and why;
- behavior before and after;
- tests added/updated;
- commands run and results;
- persistence/schema impact;
- portable-input/trust impact;
- accessibility impact;
- privacy/security impact;
- platform/build impact;
- documentation updated;
- screenshots for meaningful UI changes;
- remaining manual checks or known limitations.

Use `.github/pull_request_template.md` and link relevant issues.

## Documentation requirement

Behavior changes should update the matching documentation in the same contribution. `docs/README.md` maps topics to files, and `what_changed.md` is the chronological implementation/verification record maintained for major phases.

Do not rewrite historical verification to make an older run appear current. Add newer evidence and clearly state what it supersedes.

## License and assets

By contributing, you agree that your contribution can be distributed under the repository's MIT License. Only add assets/code you have the right to contribute. Do not commit proprietary game art, copied paid assets, credentials, signing material, or private information.

## Community conduct

Participation is subject to [`CODE_OF_CONDUCT.md`](CODE_OF_CONDUCT.md). Keep technical review focused on the work, provide reproducible evidence where possible, and treat regressions as issues to diagnose rather than hide.

## Localization contributions

Player-facing behavior changes must keep English/Hindi localization coherent. Route fixed UI strings through the project localization layer, add Hindi catalog entries, preserve English fallback, and add focused tests for critical flows. Dynamic messages should use typed helpers where grammar or values vary.

Do not translate protocol identifiers, JSON keys, URLs, email addresses, seeds, or code. A registered locale is not considered release-qualified until representative layout and assistive-technology checks are also documented. See [`docs/LOCALIZATION.md`](docs/LOCALIZATION.md).

## File-based Game Backup changes

Changes to file backup transport must preserve these additional rules:

- keep `GameBackupFilePort` as the testable platform boundary;
- keep `.nova2048` / `.json` extensions as chooser hints only, never trust signals;
- enforce a bounded byte length before UTF-8/JSON processing;
- route accepted text through `GameBackup.decode()` rather than duplicating a parser;
- route state replacement through `AppController.importGameBackup()` so file restores remain persistently unranked;
- preserve explicit user selection and avoid background directory scanning/path retention;
- update macOS sandbox entitlements deliberately if file-access requirements change;
- add widget/domain tests and run the native build matrix for plugin/configuration changes.

See [`docs/FILE_BACKUPS.md`](docs/FILE_BACKUPS.md).
