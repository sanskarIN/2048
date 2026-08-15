# Development Guide

This document describes the repository workflow for developing 2048 Nova without bypassing its deterministic engine, persistence, portability, accessibility, or release safeguards.

## Requirements

Install a stable Flutter SDK and the native toolchain required by the platform you intend to run. GitHub Actions currently verifies with the stable Flutter channel; current release evidence is recorded in [`VERIFICATION.md`](VERIFICATION.md).

Check your environment:

```bash
flutter --version
flutter doctor -v
flutter devices
```

Clone and install dependencies:

```bash
git clone https://github.com/sanskarIN/2048.git
cd 2048
flutter pub get
```

## Repository layout

```text
2048/
├─ lib/
│  ├─ app/
│  │  ├─ nova_app.dart
│  │  └─ state/
│  ├─ core/
│  │  ├─ constants/
│  │  └─ theme/
│  ├─ data/
│  ├─ domain/
│  ├─ features/
│  │  ├─ about/
│  │  ├─ achievements/
│  │  ├─ backup/
│  │  ├─ challenge_codes/
│  │  ├─ daily_challenge/
│  │  ├─ game/
│  │  ├─ guide/
│  │  ├─ home/
│  │  ├─ modes/
│  │  ├─ replay/
│  │  ├─ settings/
│  │  ├─ solver_demo/
│  │  ├─ splash/
│  │  ├─ statistics/
│  │  └─ support/
│  ├─ shared/
│  └─ main.dart
├─ test/
├─ docs/
├─ assets/
├─ android/
├─ ios/
├─ web/
├─ windows/
├─ macos/
├─ linux/
└─ .github/
```

## Architectural rule of thumb

Use the narrowest layer that can own a behavior:

- pure game rules, portable codecs, and serializable structures belong in `domain/`;
- local persistence belongs in `data/`;
- player-session coordination belongs in `app/state/`;
- reusable UI/platform helpers belong in `shared/`;
- user-facing flows belong in `features/`;
- project constants and theming belong in `core/`.

Do not move deterministic game rules into widgets. Do not let feature screens manipulate `SharedPreferences` directly. Do not let the pure engine depend on Flutter UI classes.

## Running the app

Use the default device:

```bash
flutter run
```

Or choose a target:

```bash
flutter run -d chrome
flutter run -d windows
flutter run -d macos
flutter run -d linux
```

Android and iOS require the corresponding SDK plus an emulator/simulator or device.

## Quality gate before every pull request

Run:

```bash
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
flutter build web --release
```

If formatting fails, run:

```bash
dart format lib test
```

and inspect the changes before committing.

Native release commands are host-specific:

```bash
flutter build apk --release
flutter build windows --release
flutter build macos --release
flutter build linux --release
flutter build ios --release --no-codesign
```

The repository's `Platform Builds` workflow is the cross-runner source of automated native build evidence.

## Deterministic engine changes

When changing movement, spawning, win/loss logic, RNG, or hints:

1. implement the behavior in `lib/domain/` first;
2. keep board mutation deterministic for a fixed state and RNG state;
3. add focused unit tests before wiring UI changes;
4. test all four directions when movement semantics change;
5. include no-change move behavior;
6. verify no source tile can merge twice in one move;
7. verify save/Undo RNG continuity if spawning changes;
8. update `docs/GAME_ENGINE.md` and relevant mode documentation.

Do not use widget tests as the only proof for game-rule changes.

## Challenge Code changes

Challenge Codes are an untrusted portable **configuration** boundary. Changes must preserve:

- explicit format/versioning;
- maximum input length before payload parsing;
- exact prefix/segment validation;
- checksum verification before decoding JSON;
- Base64URL/UTF-8/JSON failure handling;
- strict `GameConfig.fromJson()` reuse;
- required deterministic seed and legal seed bounds;
- explicit supported-mode allowlist;
- Daily Challenge exclusion unless its dedicated history contract is deliberately redesigned;
- no imported board progress, score, statistics, achievements, settings, Daily history, or Undo data;
- normal recoverable-game replacement confirmation before a decoded code is started;
- no extra persistence key or silent network requirement;
- checksum documentation that does not overstate it as cryptographic authentication.

Codec changes belong in `lib/domain/challenge_code.dart`. UI changes belong in `lib/features/challenge_codes/`. Clipboard access should continue through `TextClipboard` so production uses Flutter Clipboard while tests can stay deterministic.

Add or update `test/challenge_code_test.dart` for pure validation/determinism and `test/challenge_code_screen_test.dart` for copy/paste/preview/replacement flows. See [`CHALLENGE_CODES.md`](CHALLENGE_CODES.md).

## Persistence changes

When adding or changing local state:

- define explicit ownership in `LocalStore`;
- validate all deserialized external/persisted values;
- preserve corruption-safe startup;
- bound collections that can grow;
- add migration logic when compatibility is required;
- reject unsupported future schemas instead of guessing;
- update scoped reset behavior;
- test malformed data and partial collection corruption;
- update [`DATA_STORAGE.md`](DATA_STORAGE.md).

Never use `SharedPreferences.clear()` for project reset because it can erase unrelated keys.

Challenge Codes currently require no persistence key; do not add one unless there is a concrete product requirement and corresponding migration/privacy/reset design.

## Portable backup changes

Backup import is an untrusted-input boundary. Changes must preserve:

- strict format/version checks;
- size limit before parsing;
- strict embedded `GameState` validation;
- explicit replacement confirmation;
- clearing unrelated Undo state;
- locally controlled unranked marker;
- no imported lifetime stats, achievements, settings, or Daily history;
- no ranked record mutation from imported play.

Do not merge Backup and Challenge Code trust semantics: Backup restores progress and remains unranked; Challenge Codes start a fresh config-only game. See [`BACKUP_AND_RESTORE.md`](BACKUP_AND_RESTORE.md).

## Replay changes

Replay is spectator-only. Its timeline must continue to use defensive copies and reject stale/future snapshots. Replay controls must never call player mutation methods such as `move()` or `undo()`.

Because Undo storage is bounded, do not advertise Replay as guaranteed complete from move zero.

## Auto Play Demo changes

The Auto Play Demo is intentionally isolated from the player controller. Automated movement belongs to its in-memory `AutoplaySession`; it must not write current game, statistics, achievements, or Daily records.

Do not describe the heuristic as machine learning or guaranteed optimal play.

## Accessibility requirements for UI changes

For new interactive UI:

- provide meaningful visible text or tooltip/semantic labels;
- keep touch and keyboard/focus behavior usable where applicable;
- avoid color-only communication;
- test with large text and narrow layouts;
- respect reduced-motion behavior for nonessential animations;
- ensure important controls remain reachable when content scrolls;
- add widget/semantics regression tests for critical flows.

For portable text screens such as Challenge Codes/Backup, also test long input/output, validation feedback, clipboard success/failure, focus order, and replacement confirmation.

Real screen-reader testing remains a release qualification step in addition to automated semantics tests.

## External links

Use the shared external-link helper rather than calling `url_launcher` directly from arbitrary feature code. The helper allows only supported secure external destinations and provides a copy fallback when launching fails.

Do not add insecure `http` destinations, JavaScript/file schemes, or hidden external navigation.

## Commit style

Use small meaningful Conventional Commits, for example:

```text
feat: add versioned seeded challenge code codec
fix: validate challenge code checksum before parsing
test: cover challenge code replacement cancellation
docs: document challenge code trust model
chore: remove completed temporary workflow
```

Do not create empty/no-op commits just to increase commit count.

Repository automation and recent project commits use:

```text
user.name  = Sanskar
user.email = sanskarin@outlook.in
```

Do not commit credentials, tokens, passwords, signing certificates, private keys, or provisioning profiles.

## Pull requests

A pull request should explain:

- the behavior being changed;
- why the change is needed;
- tests added or changed;
- accessibility impact;
- persistence/schema impact;
- portable-input/trust impact when relevant;
- platform impact;
- documentation changed;
- manual checks still required.

Use the repository pull-request template and keep unrelated changes in separate commits/PRs when practical.

## Documentation maintenance

Behavior changes should update the matching technical document in the same development sequence. The documentation index is [`docs/README.md`](README.md).

`what_changed.md` is the chronological implementation/verification record. Preserve older evidence as history and append a newer phase or correction rather than rewriting successful older evidence to look current.

## Release discipline

Automated green CI is necessary but does not prove universal production readiness. Before promoting the `0.9.0+1` release candidate to stable, follow [`RELEASE_CHECKLIST.md`](RELEASE_CHECKLIST.md), including physical-device, screen-reader, long-session, real Challenge Code/Game Backup clipboard, external-handler, signing, and store-review checks.

## Localization development

New player-facing fixed strings should be rendered through `context.l10n.text(...)` and supplied with a Hindi catalog entry. Dynamic grammar should use a typed `NovaLocalizations` helper instead of fragile translated-fragment concatenation.

When changing locale behavior, test AppLanguage parsing/persistence, English fallback, Hindi rendering, and relevant semantics. Do not translate protocol tokens, JSON field names, URLs, email addresses, deterministic seeds, or numeric tile values that must remain exact. See [`LOCALIZATION.md`](LOCALIZATION.md) for the full contributor procedure.


## Solver strategy and benchmark changes

Normal Hint and Auto Play strategy work have different performance/trust contracts. Keep normal Hint in `hint_solver.dart` fast, read-only, and suggestion-only. Advanced automatic strategies belong behind `AutoplaySession`, not in `AppController`.

For expectimax or future search changes:

- never consume live/sandbox RNG while evaluating hypothetical boards;
- simulate on defensive board copies;
- preserve deterministic ordering/tie behavior;
- keep explicit search-depth and node/work bounds;
- test legal/no-move behavior, input immutability, resource limits, and larger boards;
- keep Auto Play state in memory only;
- do not write statistics, achievements, Daily history, saves, or ranking records;
- update English/Hindi UI copy and accessibility checks when strategy controls change.

Run the deterministic benchmark comparison with:

```bash
dart run tool/solver_benchmark.dart
```

Or pass a positive per-seed move budget:

```bash
dart run tool/solver_benchmark.dart 500
```

The benchmark is a regression/performance-comparison aid, not proof of globally optimal 2048 play. See [`SOLVER_BENCHMARKS.md`](SOLVER_BENCHMARKS.md).

## Full Replay Archive development rules

Both replay systems are spectator-only. Move Replay continues to use defensive copies from bounded Undo history and must never call player mutation methods from its viewer controls.

Full Replay Archive is a separate portable protocol. Changes must preserve explicit format/versioning, encoded-size bounds, strict opening `GameState` validation, deterministic event ordering and action legality, replay-time injection for timed rules, the hard 4,096-event capture bound, complete versus incomplete capture semantics, corruption-safe persistence, and spectator-only imported archives that never replace `AppController.game`.

Portable replay text must never mutate trusted statistics, achievements, streaks, Daily history, or per-mode records. JSON validity must not be described as authorship or authentication. Protocol/player changes belong in `lib/domain/replay_archive.dart`; active capture orchestration belongs in `AppController` and `LocalStore`; viewer behavior belongs in `lib/features/replay/`. Clipboard access must continue through `TextClipboard`. See [`REPLAY_ARCHIVES.md`](REPLAY_ARCHIVES.md).

## File backup development

Phase 20 adds a platform-plugin boundary under `lib/shared/game_backup_file_port.dart`. Feature/UI code should depend on `GameBackupFilePort`; pure backup validation remains in `lib/domain/game_backup.dart` and trusted-state installation remains in `AppController`.

When changing this integration, run the normal formatter/analyzer/full test/Web gate and the configured native matrix. Plugin or entitlement changes especially require Android, Linux, Windows, macOS, and unsigned-iOS compilation plus real-platform picker checks before stable release.

## Challenge Code QR development notes

Phase 21 pins `qr_flutter 4.1.0`. Keep the QR wrapper presentation-only: do not move protocol logic into the package integration, do not add a network QR-generation endpoint, and do not add camera/scanner permissions unless a separately reviewed in-app scanning feature is intentionally designed.

When changing the QR surface, run the Challenge Code codec/screen tests plus `test/challenge_code_qr_test.dart` and `test/challenge_code_qr_localization_test.dart`, then run the full formatter/analyzer/test/Web gate and configured native builds. Preserve fixed black-on-white QR contrast and narrow-layout containment unless real scan/accessibility evidence supports a deliberate change.
