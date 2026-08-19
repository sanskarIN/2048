# Complete Feature Reference

This document is the consolidated map of the implemented **2048 Nova** product surface. It explains what each major feature means, how it behaves at a high level, where its source-of-truth lives, and which detailed document to read next.

Current source target: **2.0.12+2012**.

This is a feature-reference guide, not a replacement for exact game-engine/protocol/security specifications. When details matter, follow the linked canonical document/source.

## 1. Core 2048 gameplay

### What it is

The board contains numbered tiles. A directional move shifts tiles. Eligible equal tiles merge according to the engine's one-merge-per-move ordering rules, score changes are applied, and a new tile is spawned after a valid move according to the selected mode/random-source rules.

### Important properties

- deterministic engine behavior for a known state and random-source state;
- invalid/no-op moves do not silently behave like valid state-changing moves;
- score and highest-tile data are derived from controlled game transitions;
- terminal-state behavior is explicit;
- mode-specific constraints are separated from the basic move/merge engine where practical.

### Source/documentation

- `lib/domain/game_engine.dart`
- `lib/domain/game_state.dart`
- `lib/domain/game_types.dart`
- [`GAME_ENGINE.md`](GAME_ENGINE.md)

## 2. Deterministic random source

### What it means

A pseudo-random generator produces values from controlled state. When the same seed/state and same sequence of requests are reproduced, the game can reproduce the same spawn sequence.

### Why it matters

Determinism supports:

- repeatable tests;
- seeded Challenge Codes;
- Daily Challenge behavior;
- replay validation;
- solver benchmarks;
- debugging reproducibility.

### Source

- `lib/domain/random_source.dart`

Deterministic does not mean cryptographically unpredictable. The game RNG is a gameplay/reproducibility mechanism, not a security key generator.

## 3. Ten game modes

The project documents these modes:

1. Classic;
2. Quick;
3. Extended;
4. Challenge;
5. Endless;
6. Target;
7. Time Challenge;
8. Move Limit;
9. Daily;
10. Zen.

Each mode can change board/goal/time/move/termination/ranking expectations without redefining the fundamental tile-merge rules.

Use [`GAME_MODES.md`](GAME_MODES.md) for exact per-mode behavior.

## 4. Classic mode

The baseline 2048-style experience: directional movement, merging equal tiles, score accumulation, and progression under the normal target/terminal rules documented by the engine/mode specification.

## 5. Quick mode

A shorter/faster configuration intended to reach its mode objective with a reduced session scope compared with the baseline experience. Exact board/goal parameters belong to `GAME_MODES.md` and source enums/configuration rather than assumptions from the name.

## 6. Extended mode

A larger/extended progression configuration for longer sessions. Exact board/goal rules are source/documentation controlled.

## 7. Challenge mode

A constrained challenge configuration that can be seeded/shared through the project's challenge model. Imported/shared challenge configuration remains subject to validation/trust rules.

## 8. Endless mode

Allows continued play under its documented mode rules instead of treating the normal 2048 target as the sole completion boundary.

## 9. Target mode

A configurable/defined target-tile objective. Completion behavior is based on the mode configuration rather than guessed from a generic 2048 rule.

## 10. Time Challenge mode

A timed mode whose state includes time-sensitive behavior. Portable timestamps use explicit UTC/compatibility rules to reduce timezone ambiguity.

See [`PORTABLE_TIMESTAMPS.md`](PORTABLE_TIMESTAMPS.md).

## 11. Move Limit mode

A mode with a finite move budget. Move counts are part of game state/mode completion logic.

## 12. Daily Challenge

### What it is

A reproducible daily challenge configuration/history experience tied to date-based challenge behavior.

### Important boundaries

- date/timestamp handling must remain portable;
- deterministic challenge setup supports reproducibility;
- daily records are local trusted records unless a future network service is explicitly introduced;
- imported data does not silently rewrite trusted ranked records.

### Source

- `lib/domain/daily_record.dart`
- related Daily Challenge UI/controller/local-store paths.

## 13. Zen mode

A relaxed mode with its own documented progression/termination expectations. Do not infer ranking/time pressure from the word “Zen”; use `GAME_MODES.md` for exact behavior.

## 14. Swipe, keyboard, and button/input controls

The UI accepts platform-appropriate controls such as touch/swipe and keyboard where implemented/supported. Input is translated into the same domain move directions so separate control methods do not create separate game rules.

Accessibility and keyboard behavior are documented in [`ACCESSIBILITY.md`](ACCESSIBILITY.md) and player usage in [`USER_GUIDE.md`](USER_GUIDE.md).

## 15. Save and resume

### What it is

The current session can be serialized into local storage and restored after application restart according to schema/migration validation.

### Important boundaries

- corrupted/incompatible local data should fail safely/recover according to storage rules;
- save data is bounded;
- trusted local session data is distinguished from imported portable data;
- migrations must preserve defined compatibility.

### Source/documentation

- `lib/data/local_store.dart`
- `lib/app/state/app_controller.dart`
- [`DATA_STORAGE.md`](DATA_STORAGE.md)

## 16. Undo

Undo restores a bounded previous trusted local game state according to the controller/engine policy.

Undo history is intentionally bounded so persistent memory/storage cannot grow forever.

Imported/replay data must not bypass ranking/trust policy through Undo.

## 17. Statistics

Local statistics record defined gameplay totals/records. They are persisted locally and updated through trusted controller/game transitions.

Portable imports are isolated from trusted statistics according to project policy.

UI: `lib/features/statistics/`.

Storage/orchestration: `lib/data/local_store.dart`, `lib/app/state/app_controller.dart`.

## 18. Achievements

Achievements represent locally evaluated milestones based on trusted game/statistical state. Their presentation lives in `lib/features/achievements/`.

They do not imply a cloud account or remote achievement service.

## 19. Per-mode records

The app tracks defined records such as best score/highest tile per mode in trusted local storage.

Imported portable sessions are isolated from ranked records to avoid a shared file becoming an unrestricted record-writing path.

See [`MODE_RECORDS.md`](MODE_RECORDS.md).

## 20. Hint

### What it is

A read-only solver recommendation for the current board.

### Important safety/integrity property

Requesting a Hint does not itself mutate the trusted game board. The user chooses whether to perform a recommended move.

### Source/documentation

- `lib/domain/hint_solver.dart`
- [`HINT_SOLVER.md`](HINT_SOLVER.md)

## 21. Heuristic solver

A bounded evaluation strategy scores possible moves/board characteristics without exploring an unlimited game tree. It provides a computationally cheaper strategy for hint/autoplay behavior.

Solver output is advisory/isolated from trusted external claims.

## 22. Expectimax solver

### What it is

A bounded search algorithm that alternates between player choices and probabilistic tile-spawn outcomes to estimate useful moves.

### Why bounded

Unbounded search would grow rapidly and could freeze UI or consume excessive CPU/memory. The implementation uses controlled search limits/benchmarks.

### Source/documentation

- `lib/domain/expectimax_solver.dart`
- [`SOLVER_BENCHMARKS.md`](SOLVER_BENCHMARKS.md)

## 23. Auto Play

### What it is

An isolated solver-driven session that can select/execute moves automatically using supported strategies.

### Trust boundary

Auto Play is deliberately distinguished from normal trusted ranked play so automation cannot silently present itself as an ordinary user-earned record.

### Source

- `lib/domain/autoplay_session.dart`
- `lib/features/solver_demo/`

## 24. Deterministic solver benchmark

The repository includes reusable benchmark cases plus a CLI:

```bash
dart run tool/solver_benchmark.dart 8
```

The benchmark is a deterministic smoke/performance regression aid, not a claim that the solver is mathematically optimal for every board.

## 25. Move Replay

A lightweight replay timeline can step through recorded move/state progression for inspection/playback.

Source:

- `lib/domain/replay_timeline.dart`
- `lib/features/replay/`

## 26. Full Replay Archives

### What they are

Portable full-session replay archives capture validated bounded replay events/metadata for later spectator-style playback/import.

### Important boundaries

- archive size/event counts are bounded;
- imported content is validated;
- replay playback is spectator/history functionality;
- imported replay data does not become trusted ranked game state.

### Source/documentation

- `lib/domain/replay_archive.dart`
- `lib/domain/replay_archive_contract.dart`
- [`REPLAY_ARCHIVES.md`](REPLAY_ARCHIVES.md)

## 27. Current-game backup

A portable backup can encode the current game/session state for user-controlled export/import.

The backup codec validates format/schema/value bounds before data enters application state.

Source/documentation:

- `lib/domain/game_backup.dart`
- [`BACKUP_AND_RESTORE.md`](BACKUP_AND_RESTORE.md)

## 28. File backup/import/export

The app supports user-selected portable file transport on supported platforms. File picker/platform handlers remain external trust boundaries.

Important controls include:

- file type/extension expectations;
- byte-size limits;
- codec/schema validation;
- safe failure on malformed input;
- imported state remains unranked where policy requires it.

See [`FILE_BACKUPS.md`](FILE_BACKUPS.md).

## 29. Challenge Codes

### What they are

Compact portable representation of deterministic challenge configuration/seed.

### What the checksum means

The challenge checksum helps detect accidental corruption/invalid data. It is **not cryptographic authentication** and does not prove who created the code.

### Source/documentation

- `lib/domain/challenge_code.dart`
- `lib/features/challenge_codes/`
- [`CHALLENGE_CODES.md`](CHALLENGE_CODES.md)

## 30. Challenge QR code

A Challenge Code can be represented as a QR image for convenient user-controlled transfer.

The QR is another representation of challenge data; scanning/importing it still requires the same validation/trust rules as text input.

The current project does not need to claim camera permissions simply because it can render QR codes. Any future camera-scanning feature would require explicit permission/privacy/platform documentation.

## 31. English/Hindi localization

### What it is

The app supports English and Hindi UI localization with persisted selection/fallback behavior.

### Source

- `lib/core/localization/`

### Documentation

- [`LOCALIZATION.md`](LOCALIZATION.md)

Localization changes should preserve placeholders/meaning and be checked for layout/accessibility on target devices.

## 32. Themes

Theme definitions live under `lib/core/theme/`. User preferences are coordinated/persisted through application state/storage.

A theme is more than color decoration when accessibility is considered: text/background contrast and focus/semantic visibility must remain usable.

## 33. Accessibility controls

The application implements documented semantics, input, contrast, text/layout, and motion-related accommodations.

Automated widget tests can protect semantic properties but cannot replace manual TalkBack/VoiceOver/keyboard/real-device assessment.

See [`ACCESSIBILITY.md`](ACCESSIBILITY.md).

## 34. Reduced-motion behavior

Where the app exposes motion preferences, animations/transitions should honor the documented reduced-motion behavior so visual effects are not mandatory to understand gameplay state.

## 35. About screen

`lib/features/about/` presents project identity/version/open-source and related project information.

Release-facing version text must stay synchronized with the canonical Version 2.0.12 metadata.

## 36. Guide screen

`lib/features/guide/` provides in-app instructions. In-app help must not contradict `GAME_ENGINE.md`, `GAME_MODES.md`, or current controls.

## 37. Support screen

`lib/features/support/` presents support/contact/external links.

External navigation is a trust boundary: the app should make external destinations clear and use platform URL-launch behavior rather than embedding hidden network behavior.

## 38. External links

External URLs are launched through controlled application helpers/plugin behavior. They leave the application's local/offline trust boundary and can be subject to the user's default browser/app and network policies.

Tests protect important external-link metadata/behavior.

## 39. Offline-first behavior

Core gameplay does not require a project account, remote database, or continuous application backend.

Local/offline does not mean the operating system itself never communicates with network services, and user-triggered external links can open network destinations.

See [`PRIVACY.md`](PRIVACY.md).

## 40. Local storage

`shared_preferences` and project codecs/store orchestration are used for bounded local state/preferences as documented.

Local storage is not an encrypted secrets vault. The app should not place private signing credentials or unrelated sensitive secrets into ordinary gameplay preferences.

## 41. Data reset

The settings/data controls can reset supported local state according to the documented storage policy. A reset should not be described as secure forensic erasure of underlying storage media.

## 42. Privacy model

The current product scope is intentionally offline-first with no silent analytics/accounts/cloud game backend.

Portable data operations and external links are explicit boundaries documented in [`PRIVACY.md`](PRIVACY.md).

## 43. Platform support

Configured Flutter runners:

- Android;
- iOS;
- Web/PWA;
- Windows;
- macOS;
- Linux.

Cross-platform means shared Flutter source targets all of them; it does **not** mean iOS can be compiled on Windows or Windows native output can be built on a Mac through ordinary Flutter commands.

See [`PLATFORMS.md`](PLATFORMS.md).

## 44. Android APK support

The project can build debug/profile/release APKs. Production distribution requires correct signing identity and real-device/release qualification.

See [`BUILDING_EXECUTABLES.md`](BUILDING_EXECUTABLES.md).

## 45. Android AAB support

The project can build a release App Bundle with:

```bash
flutter build appbundle --release
```

AAB is store-oriented packaging; it is not normally directly installed by the end user.

## 46. Web/PWA support

The app contains Web shell/PWA manifest/icon metadata and can build a release Web bundle.

Installed/offline PWA lifecycle behavior must be qualified in real supported browsers; a successful compile alone is not that evidence.

See [`PWA.md`](PWA.md).

## 47. Windows desktop support

Native Windows output is a complete release directory containing the `.exe`, runtime libraries, and data. Do not distribute only the executable.

## 48. macOS support

Native macOS output is a `.app` bundle. Developer ID signing/notarization/store distribution are external release processes beyond simple compilation.

## 49. Linux support

Native Linux output is an executable plus required runtime bundle. Distribution-specific `.deb`/`.rpm`/AppImage/Snap/Flatpak packaging is not automatically implied by the base Flutter bundle.

## 50. iOS support

The repository can qualify unsigned iOS release compilation on macOS. A signed IPA/App Store release requires legitimate Apple signing/provisioning configuration outside public source.

## 51. Branding

Source branding is stored under `assets/branding/` with native platform assets/generated workflows documented in [`BRANDING.md`](BRANDING.md).

Branding changes should be synchronized across application UI, icons, splash/launch assets, Web/PWA assets, and platform runners.

## 52. “Made by the Sanskar” project identity

Creator/project identity is part of the public product metadata. It belongs in appropriate About/README/branding surfaces rather than in low-level game-engine logic.

## 53. Repository audit

The repository-owned audit validates required files, release metadata/PWA expectations, local Markdown links, and cleanup/integrity rules.

Run:

```bash
dart run tool/repository_audit.dart --json
```

## 54. Source-completion audit

Protects the Version 2.0.12 completed-source contract against stale current release metadata, missing completion assets, restored unresolved feature backlog, and unfinished maintained Dart markers covered by the tool.

Run:

```bash
dart run tool/source_completion_audit.dart --json
```

## 55. Release readiness

Candidate check:

```bash
dart run tool/release_readiness.dart --json
```

Strict stable check:

```bash
dart run tool/release_readiness.dart --stable --json
```

The strict gate intentionally remains closed until the canonical real-world evidence requirements are genuinely complete.

## 56. Qualification status and recorder

Read status:

```bash
dart run tool/release_qualification_status.dart --json --pending-only
```

A separate guarded recorder exists for maintainers to record genuinely observed qualification evidence.

Do not edit evidence merely to make stable readiness pass.

## 57. CI quality automation

Permanent CI covers dependency resolution/drift, formatting, analyzer, tests/coverage, release/repository/source audits, strict-gate behavior, solver benchmark, and Web release build.

Native platform workflow covers Android, Linux, Windows, macOS, and unsigned iOS builds on corresponding hosted runners.

See [`CI_CD.md`](CI_CD.md).

## 58. Dependency integrity

`pubspec.yaml` declares package constraints and `pubspec.lock` records concrete resolved versions. Dependency updates are reviewed as source changes.

See [`DEPENDENCIES.md`](DEPENDENCIES.md) and [`SUPPLY_CHAIN.md`](SUPPLY_CHAIN.md).

## 59. Toolchain support lifecycle

If Flutter/Dart/Android Studio/SDK/JDK/Gradle/AGP/Kotlin/Xcode/CocoaPods/Visual Studio/CMake/Ninja/etc. becomes unsupported, migrate through the compatibility-first process in [`setup/UPGRADING_AND_SUPPORT.md`](setup/UPGRADING_AND_SUPPORT.md).

Do not blindly upgrade every layer in one step.

## 60. Documentation itself is a protected feature

The repository contains current player/developer/build/release docs plus historical evidence. Current documentation must match current source; historical records must preserve what actually happened at their old commit/version.

The documentation-completeness regression test protects the new setup/reference set and the current Version 2.0.12 build handbook identity.

## 61. Where to go next

- New machine: [`setup/README.md`](setup/README.md)
- Commands: [`COMMAND_REFERENCE.md`](COMMAND_REFERENCE.md)
- Terms: [`GLOSSARY.md`](GLOSSARY.md)
- All files: [`REPOSITORY_FILE_ATLAS.md`](REPOSITORY_FILE_ATLAS.md)
- Player details: [`USER_GUIDE.md`](USER_GUIDE.md)
- Exact engine: [`GAME_ENGINE.md`](GAME_ENGINE.md)
- Exact modes: [`GAME_MODES.md`](GAME_MODES.md)
- Architecture: [`ARCHITECTURE.md`](ARCHITECTURE.md)
- Tests: [`TESTING.md`](TESTING.md)
- Builds: [`BUILDING_EXECUTABLES.md`](BUILDING_EXECUTABLES.md)
- Troubleshooting: [`TROUBLESHOOTING.md`](TROUBLESHOOTING.md)
- Release: [`RELEASE_QUALIFICATION.md`](RELEASE_QUALIFICATION.md)
