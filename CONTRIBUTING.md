# Contributing to 2048 Nova

Thank you for helping improve 2048 Nova. Contributions should preserve the project's deterministic game rules, offline-first behavior, accessibility requirements, local-data integrity, and truthful release verification.

## Before you start

Read the documentation relevant to your change:

- [`README.md`](README.md) — project overview and setup.
- [`docs/README.md`](docs/README.md) — documentation index.
- [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) — layer boundaries.
- [`docs/GAME_ENGINE.md`](docs/GAME_ENGINE.md) — game-rule invariants.
- [`docs/DATA_STORAGE.md`](docs/DATA_STORAGE.md) — persistence rules.
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

- Keep deterministic game rules in `lib/domain/` and independent from Flutter widgets.
- Keep `SharedPreferences` access inside the data layer rather than feature screens.
- Use `AppController` for ranked player-session/statistics/achievement/Daily orchestration.
- Keep reusable route/link/replacement helpers under shared application utilities.
- Do not make Replay mutate the live player session.
- Do not make Auto Play Demo write player saves or lifetime records.
- Keep portable imported games unranked unless the entire trust model is deliberately redesigned and reviewed.

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

See [`docs/BACKUP_AND_RESTORE.md`](docs/BACKUP_AND_RESTORE.md).

## UI and accessibility changes

For user-facing changes:

- keep visible labels understandable without color alone;
- add semantic labels/tooltips where needed;
- keep controls reachable with scrolling on small viewports;
- preserve keyboard/focus behavior on desktop/Web;
- respect high contrast and reduced motion;
- test large text/narrow layouts when relevant;
- add widget or semantics regression tests for critical flows.

A passing semantics unit test is not a substitute for final real screen-reader qualification.

## External links and privacy

Use the shared external-link helper for browser/email destinations. Do not introduce insecure or hidden schemes.

Do not add analytics, advertising, account, tracking, cloud-sync, or remote-AI dependencies without an explicit project decision, privacy review, documentation update, and user-visible behavior review.

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
