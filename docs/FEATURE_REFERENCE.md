# Complete Feature Reference

This document is the consolidated map of the implemented **2048 Nova** product surface. It explains what each major feature means, its high-level trust/behavior boundary, the source-of-truth area, and the detailed document to read next.

Current source target: **2.0.12+2012**.

This is a feature-reference guide, not a replacement for exact engine/protocol/security specifications. When details matter, follow the linked canonical source/document.

## 1. Core deterministic 2048 gameplay

Directional moves shift tiles, eligible equal values merge once per source tile per move, score changes are applied, and a new tile spawns only after a valid board-changing move.

Important properties:

- deterministic behavior for known game/random state;
- invalid/no-op moves do not silently behave like valid moves;
- score/highest tile derive from controlled transitions;
- terminal state and mode-specific constraints are explicit.

Source/documentation:

- `lib/domain/game_engine.dart`
- `lib/domain/game_state.dart`
- `lib/domain/game_types.dart`
- `lib/domain/random_source.dart`
- [`GAME_ENGINE.md`](GAME_ENGINE.md)

Deterministic gameplay supports repeatable tests, seeded challenges, Daily Challenge, replay validation, custom deterministic seeds, and solver benchmarks. It does not mean the gameplay RNG is a cryptographic random generator.

## 2. Ten game modes

The built-in modes are:

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

Each changes board/goal/time/move/termination expectations without redefining the fundamental merge engine. Use [`GAME_MODES.md`](GAME_MODES.md) for exact parameters.

Timed/portable state follows the UTC rules in [`PORTABLE_TIMESTAMPS.md`](PORTABLE_TIMESTAMPS.md).

## 3. Custom Game Builder

Custom Game Builder is an additional configuration surface, not an eleventh built-in `GameMode`. It reuses existing deterministic engine modes through a validated `CustomGamePreset`.

Supported configuration includes:

- 3×3 through 8×8 board sizes;
- supported target tiles from 128 through 16384;
- Target, Endless, Timed, and Move Limit styles;
- style-specific time/move limits;
- optional deterministic seed.

Saved custom presets are local, validated, corruption-repaired, case-insensitively deduplicated, and bounded to 24.

Player workflows include:

- Play now without saving;
- Save preset;
- Edit preset and safe rename;
- collision rejection instead of overwriting a different preset;
- Duplicate preset into an unsaved uniquely named copy;
- Cancel edit;
- confirmed Delete preset.

Trust boundary:

- custom play is trusted local gameplay;
- custom identity survives save/resume/application restart and in-game restart;
- incomparable custom configurations cannot overwrite built-in per-mode best-score/highest-tile records;
- imported Game Backup remains a separate unranked trust class;
- custom origin is not encoded in the current `NOVA1` Challenge Code, so the UI does not expose sharing that would lose the custom-record boundary.

Source/documentation:

- `lib/domain/custom_game_preset.dart`
- `lib/data/custom_preset_store.dart`
- `lib/features/modes/custom_game_builder_screen.dart`
- [`CUSTOM_GAME_BUILDER.md`](CUSTOM_GAME_BUILDER.md)
- [`USER_GUIDE.md`](USER_GUIDE.md)

## 4. Swipe, keyboard, and button input

Touch/swipe, keyboard, and visible controls translate into the same domain actions rather than separate rule implementations.

See [`ACCESSIBILITY.md`](ACCESSIBILITY.md) and [`USER_GUIDE.md`](USER_GUIDE.md).

## 5. Save and resume

The current session is serialized into validated local storage and restored after restart according to supported schema/migration rules.

Important boundaries:

- malformed/incompatible data fails safely or is repaired where explicitly supported;
- growing histories are bounded;
- trusted local state is distinguished from imported portable state;
- migrations preserve defined compatibility.

Source/documentation:

- `lib/data/local_store.dart`
- `lib/app/state/app_controller.dart`
- [`DATA_STORAGE.md`](DATA_STORAGE.md)

## 6. Undo

Undo restores a bounded prior game snapshot, including deterministic RNG state where required. The retained history is capped so memory/storage cannot grow indefinitely.

Undo is a board/session feature; it does not turn imported or otherwise isolated data into trusted records.

## 7. Statistics, achievements, and per-mode records

Statistics and achievements are local and updated through the controller's trusted gameplay policy.

Per-mode records store comparable built-in-mode best score/highest tile data. Two important isolation rules apply:

- imported Game Backup sessions remain unranked;
- custom configurations cannot overwrite built-in per-mode records.

See [`MODE_RECORDS.md`](MODE_RECORDS.md), [`DATA_STORAGE.md`](DATA_STORAGE.md), and `lib/app/state/app_controller.dart`.

## 8. Hint

Hint is a read-only local solver recommendation. Requesting it does not itself mutate the trusted game board, score, RNG, Undo history, or records.

Source/documentation:

- `lib/domain/hint_solver.dart`
- [`HINT_SOLVER.md`](HINT_SOLVER.md)

## 9. Heuristic and Expectimax solver

The heuristic provides a bounded evaluation strategy. The Expectimax solver performs bounded search over player choices and probabilistic spawns.

Bounded search prevents uncontrolled computation from freezing the UI or consuming unbounded CPU/memory.

Source/documentation:

- `lib/domain/hint_solver.dart`
- `lib/domain/expectimax_solver.dart`
- [`SOLVER_BENCHMARKS.md`](SOLVER_BENCHMARKS.md)

## 10. Auto Play

Auto Play is an isolated deterministic solver-driven sandbox. It can execute supported strategies automatically, but it cannot present automated progress as ordinary player-earned ranked records.

Source:

- `lib/domain/autoplay_session.dart`
- `lib/features/solver_demo/`

## 11. Deterministic solver benchmark

The repository provides a reusable bounded CLI benchmark:

```bash
dart run tool/solver_benchmark.dart 8
```

It is regression/performance smoke evidence, not a claim of globally optimal 2048 play.

## 12. Daily Challenge

Daily Challenge uses reproducible date-based local challenge behavior and dedicated local history.

Important boundaries:

- portable date/timestamp handling is explicit;
- a weaker replay does not erase stronger stored history where the record policy says otherwise;
- arbitrary Challenge Code input cannot silently inject itself into Daily history;
- no remote Daily server/account is required.

See `lib/domain/daily_record.dart`, Daily Challenge UI/controller code, [`GAME_MODES.md`](GAME_MODES.md), and [`PORTABLE_TIMESTAMPS.md`](PORTABLE_TIMESTAMPS.md).

## 13. Challenge Codes

Challenge Codes are compact validated seeded configurations using the versioned `NOVA1` text format.

They support local QR representation for convenient transfer. The checksum detects accidental corruption; it is **not cryptographic authentication** and does not prove authorship.

Daily Challenge is excluded from arbitrary code injection. Custom Game Builder origin is also not currently encoded, so a custom-preset sharing button is deliberately absent until origin/trust semantics are intentionally versioned and tested.

Source/documentation:

- `lib/domain/challenge_code.dart`
- `lib/features/challenge_codes/`
- [`CHALLENGE_CODES.md`](CHALLENGE_CODES.md)

## 14. Current-game backup

Game Backup encodes the supported current game as validated portable data.

Import requires strict format/schema/state validation and explicit replacement confirmation. Imported progress remains unranked, including after restart, so user-editable portable data cannot inflate trusted statistics/achievements/streaks/Daily/per-mode records.

Source/documentation:

- `lib/domain/game_backup.dart`
- [`BACKUP_AND_RESTORE.md`](BACKUP_AND_RESTORE.md)

## 15. File backup/import/export

The same backup envelope can use user-selected file transport on supported platforms.

Controls include:

- extension/type expectations;
- byte-size limits;
- UTF-8/codec/schema validation;
- cancel-without-mutation behavior;
- safe failure on malformed input;
- unranked import policy.

Platform file pickers/handlers remain external qualification boundaries.

See [`FILE_BACKUPS.md`](FILE_BACKUPS.md).

## 16. Move Replay

Move Replay provides a read-only timeline of the current session/retained progression. Playback/scrubbing cannot mutate the live game, trusted records, achievements, or RNG.

Source:

- `lib/domain/replay_timeline.dart`
- `lib/features/replay/`

## 17. Full Replay Archives

Full Replay Archives provide bounded portable spectator reconstruction for complete captured sessions.

Important boundaries:

- archive/input/event size is bounded;
- imported content is strictly validated;
- imported archives remain spectator-only;
- replay input cannot become trusted ranked game state;
- editable replay JSON is not authenticated proof of who played.

Source/documentation:

- `lib/domain/replay_archive.dart`
- `lib/domain/replay_archive_contract.dart`
- [`REPLAY_ARCHIVES.md`](REPLAY_ARCHIVES.md)

## 18. English/Hindi localization

The player UI supports English and Hindi plus a persisted System-default choice/fallback behavior.

Machine-readable protocol fields, URLs, seeds, and numeric tile values remain protocol/numeric data rather than translated values.

Source/documentation:

- `lib/core/localization/`
- [`LOCALIZATION.md`](LOCALIZATION.md)

Custom Game Builder create/edit/duplicate/delete/error flows are also bilingual.

## 19. Themes, accessibility controls, and reduced motion

Theme definitions live under `lib/core/theme/`; persisted presentation preferences are coordinated through application state/storage.

Accessibility includes documented semantics, keyboard/focus behavior, contrast, responsive layout/text scaling, and reduced-motion handling.

Automated tests protect source regressions but do not replace representative TalkBack/VoiceOver/Narrator/browser-screen-reader qualification.

See [`ACCESSIBILITY.md`](ACCESSIBILITY.md).

## 20. About, Guide, Support, and external links

The About/Guide/Support surfaces provide project identity, player instructions, and explicit user-triggered external destinations.

External URLs pass through controlled URI-launch behavior and leave the offline application's trust boundary. The app does not hide remote network behavior behind ordinary gameplay.

Relevant source:

- `lib/features/about/`
- `lib/features/guide/`
- `lib/features/support/`
- shared external-link helpers.

## 21. Offline-first privacy model and local storage

Core gameplay requires no project account, analytics, advertising, cloud game backend, or remote AI service.

Local storage holds supported settings/game/statistics/history/preset state. It is not an encrypted signing-secret vault.

Clipboard/file/external-link actions happen only after explicit user actions and cross the documented trust boundary.

See [`PRIVACY.md`](PRIVACY.md), [`SECURITY.md`](../SECURITY.md), and [`DATA_STORAGE.md`](DATA_STORAGE.md).

## 22. Data reset

Settings can reset current game, statistics, achievements, or all project-owned local data according to documented policy.

Full project reset includes Custom Game Builder preset/session keys. Reset is an application-data operation, not a claim of forensic storage erasure.

## 23. Platform support

Configured Flutter runners:

- Android;
- iOS;
- Web/PWA;
- Windows;
- macOS;
- Linux.

Cross-platform means shared Flutter source targets all of them. It does not mean every target can be compiled from every host; for example, ordinary iOS builds require macOS/Xcode and native Windows builds require Windows/Visual Studio C++.

See [`PLATFORMS.md`](PLATFORMS.md).

## 24. Build artifacts

Maintained build coverage includes:

- Android APK;
- Android AAB;
- Web/PWA bundle;
- Windows desktop bundle;
- macOS `.app` bundle;
- Linux release bundle;
- unsigned iOS release compilation.

Production signing, provisioning, notarization, store policy, and representative device behavior are separate release responsibilities.

See [`BUILDING_EXECUTABLES.md`](BUILDING_EXECUTABLES.md), [`RELEASE_ARTIFACTS.md`](RELEASE_ARTIFACTS.md), and [`setup/LINUX_NATIVE_TOOLCHAIN.md`](setup/LINUX_NATIVE_TOOLCHAIN.md).

## 25. Branding and project identity

Branding source lives under `assets/branding/` and platform-specific assets/runners. **Made by the Sanskar** is project identity and belongs on appropriate product/About/README/branding surfaces rather than low-level engine logic.

See [`BRANDING.md`](BRANDING.md).

## 26. Repository audit

The repository-owned audit checks required files, release metadata/PWA expectations, cleanup/integrity rules, and local Markdown links.

```bash
dart run tool/repository_audit.dart --json
```

See [`REPOSITORY_AUDIT.md`](REPOSITORY_AUDIT.md).

## 27. Source-completion audit

The source-completion audit protects the completed Version 2.0.12 contract against stale current-release metadata, missing completion assets/automation, reopened optional backlog, and unresolved maintained Dart markers covered by the tool.

```bash
dart run tool/source_completion_audit.dart --json
```

See [`SOURCE_COMPLETION_AUDIT.md`](SOURCE_COMPLETION_AUDIT.md).

## 28. Release readiness

Candidate check:

```bash
dart run tool/release_readiness.dart --json
```

Strict stable check:

```bash
dart run tool/release_readiness.dart --stable --json
```

The strict gate remains fail-closed while the genuine 13-check real-world qualification manifest is incomplete.

See [`RELEASE_QUALIFICATION.md`](RELEASE_QUALIFICATION.md).

## 29. Qualification status and recorder

Read status:

```bash
dart run tool/release_qualification_status.dart --json --pending-only
```

A separate guarded recorder exists for maintainers to record genuinely observed evidence. Evidence must never be edited only to make stable readiness pass.

## 30. CI quality automation

Permanent CI covers dependency resolution/drift, formatting, analyzer, tests/coverage, release/repository/source audits, strict-gate behavior, solver smoke, and Web release build.

Native platform automation covers Android APK/AAB, Linux, Windows, macOS, and unsigned iOS on corresponding hosted runners. Pull-request Dependency Review provides an additional supply-chain check.

See [`CI_CD.md`](CI_CD.md).

## 31. Dependency and toolchain integrity

`pubspec.yaml` declares package constraints and `pubspec.lock` records concrete resolution. Dependency/toolchain updates are source changes requiring compatibility, privacy/security, licensing, and platform review.

See:

- [`DEPENDENCIES.md`](DEPENDENCIES.md)
- [`SUPPLY_CHAIN.md`](SUPPLY_CHAIN.md)
- [`setup/TOOL_SUPPORT_MATRIX.md`](setup/TOOL_SUPPORT_MATRIX.md)
- [`setup/UPGRADING_AND_SUPPORT.md`](setup/UPGRADING_AND_SUPPORT.md)

Do not blindly upgrade every layer only because newer releases exist.

## 32. Documentation is a protected project feature

Current player/developer/build/release documentation must match current source; historical evidence must preserve what actually happened on older versions/commits.

Regression tests/audits protect the documentation set, including the current Version 2.0.12 identity, Custom Game Builder integration, no-skip file-coverage contract, setup/toolchain references, and final integration evidence boundary.

See [`DOCUMENTATION_AUDIT_CHECKLIST.md`](DOCUMENTATION_AUDIT_CHECKLIST.md), [`FINAL_2_0_12_INTEGRATION_AUDIT.md`](FINAL_2_0_12_INTEGRATION_AUDIT.md), and [`README.md`](README.md).

## 33. Where to go next

- New machine: [`setup/README.md`](setup/README.md)
- New contributor: [`NEW_CONTRIBUTOR_TUTORIAL.md`](NEW_CONTRIBUTOR_TUTORIAL.md)
- Commands: [`COMMAND_REFERENCE.md`](COMMAND_REFERENCE.md)
- Terms: [`GLOSSARY.md`](GLOSSARY.md)
- All files: [`REPOSITORY_FILE_ATLAS.md`](REPOSITORY_FILE_ATLAS.md)
- Player details: [`USER_GUIDE.md`](USER_GUIDE.md)
- Custom games: [`CUSTOM_GAME_BUILDER.md`](CUSTOM_GAME_BUILDER.md)
- Exact engine: [`GAME_ENGINE.md`](GAME_ENGINE.md)
- Exact modes: [`GAME_MODES.md`](GAME_MODES.md)
- Architecture: [`ARCHITECTURE_WALKTHROUGH.md`](ARCHITECTURE_WALKTHROUGH.md)
- Tests: [`TESTING.md`](TESTING.md)
- Builds: [`BUILDING_EXECUTABLES.md`](BUILDING_EXECUTABLES.md)
- Diagnosis: [`ERROR_REFERENCE.md`](ERROR_REFERENCE.md)
- Release: [`RELEASE_QUALIFICATION.md`](RELEASE_QUALIFICATION.md)
