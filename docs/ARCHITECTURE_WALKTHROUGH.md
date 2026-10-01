# 2048 Nova Architecture Walkthrough

Current source target: **2.0.12+2012**.

This guide follows the implemented application from startup through gameplay, persistence, portable data, solver features, localization, platform runners, and release tooling. It complements [`ARCHITECTURE.md`](ARCHITECTURE.md), which defines the architectural boundaries in more formal terms.

## 1. Layer map

```text
lib/main.dart
    ↓
lib/app/                 application shell and state orchestration
    ↓
lib/features/            player-facing screens and feature UI
    ↓
lib/domain/              deterministic game/protocol/solver models
    ↓
lib/data/                validated local persistence

lib/core/                constants, localization, theme
lib/shared/              reusable UI/helpers and guards
```

The goal is not to forbid every cross-directory import. The goal is to prevent screens from becoming independent game engines or persistence codecs.

## 2. Application startup

```text
Flutter runtime
    ↓
lib/main.dart
    ↓
AppController initialization
    ↓
validated local settings/game/statistics/replay state
    ↓
NovaApp
    ↓
AppScope exposes the controller
    ↓
Home/navigation UI
```

Primary files:

- `lib/main.dart`
- `lib/app/nova_app.dart`
- `lib/app/state/app_controller.dart`
- `lib/app/state/app_scope.dart`
- `lib/data/local_store.dart`

`AppController` is the central coordinator. Screens ask it to start games, apply moves, undo, import state, change settings, and update trusted progress instead of duplicating those rules.

## 3. Starting built-in gameplay

```text
Mode Selection
    ↓
validated GameConfig
    ↓
current-game replacement guard when needed
    ↓
AppController.newGame(...)
    ↓
GameEngine creates deterministic initial state
    ↓
current game + replay capture + trusted session state persist
    ↓
GameScreen renders state
```

Important source:

- `lib/features/modes/`
- `lib/domain/game_types.dart`
- `lib/domain/game_engine.dart`
- `lib/domain/game_state.dart`
- `lib/domain/random_source.dart`

## 4. Directional move flow

```text
Swipe / keyboard command
    ↓
Direction
    ↓
AppController serializes move request
    ↓
GameEngine shifts and merges
    ↓
Did board change?
   ├─ no → no spawn, no trusted move side effect
   └─ yes
        ↓
      score/board update
        ↓
      deterministic tile spawn
        ↓
      mode/terminal status refresh
        ↓
      statistics/records/replay/Undo policy
        ↓
      validated persistence
        ↓
      UI rebuild
```

The exact merge/spawn invariants are specified in [`GAME_ENGINE.md`](GAME_ENGINE.md).

## 5. Deterministic random state

`lib/domain/random_source.dart` makes pseudo-random tile spawning reproducible from controlled state. That supports:

- deterministic engine tests;
- save/resume continuity;
- Daily Challenge;
- Challenge Codes;
- replay reconstruction;
- solver benchmarks.

Determinism is a reproducibility property, not cryptographic authentication.

## 6. Save and resume

`lib/data/local_store.dart` owns the supported local persistence contracts.

```text
trusted controller state
    ↓
versioned/validated serialization
    ↓
SharedPreferences-backed local store
    ↓
application restart
    ↓
load + validate + repair/migrate where defined
    ↓
AppController reconstructs active state
```

Malformed data must fail safely instead of being partially promoted to trusted state. Growing collections are bounded.

See [`DATA_STORAGE.md`](DATA_STORAGE.md).

## 7. Undo

Before a trusted state-changing move, the controller retains bounded prior state. Undo restores a compatible prior game snapshot, including deterministic RNG state, without pretending that application-level lifetime records are an event-sourced history.

Undo history is capped and validated when restored.

## 8. Custom Game Builder

Custom Game Builder intentionally reuses `GameConfig` and `GameEngine` rather than adding a second engine.

```text
CustomGamePreset form
    ↓
strict domain validation
    ↓
optional bounded local preset save
    ↓
Play action
    ↓
current-game replacement guard
    ↓
AppController.newGame(config, custom: true)
    ↓
normal deterministic engine
```

Source:

- `lib/domain/custom_game_preset.dart`
- `lib/data/custom_preset_store.dart`
- `lib/features/modes/custom_game_builder_screen.dart`

Custom-session identity is stored separately from `GameState` so the existing save/replay/backup protocols do not need an origin-only schema migration.

A custom session is trusted local play but does **not** write built-in per-mode records because custom board/target/limit combinations may not be comparable to those presets.

See [`CUSTOM_GAME_BUILDER.md`](CUSTOM_GAME_BUILDER.md).

## 9. Statistics and record trust

```text
trusted local gameplay
    ↓
AppController evaluates record/statistics policy
    ↓
PlayerStats / achievements / Daily history
    ↓
LocalStore
```

Two isolation rules matter:

- imported Game Backup progress is unranked;
- custom sessions cannot overwrite built-in per-mode records.

This prevents editable/portable or incomparable configuration paths from silently becoming ordinary ranked records.

## 10. Daily Challenge

Daily Challenge derives deterministic challenge identity from the date and maintains dedicated local history.

Source includes:

- `lib/domain/daily_record.dart`
- `lib/features/daily_challenge/`

Portable timestamps use explicit UTC rules described in [`PORTABLE_TIMESTAMPS.md`](PORTABLE_TIMESTAMPS.md).

## 11. Challenge Codes

`lib/domain/challenge_code.dart` serializes a supported seeded configuration into the versioned `NOVA1` text format.

```text
GameConfig + deterministic seed
    ↓
strict encode
    ↓
payload + corruption-detection checksum
    ↓
text / local QR representation
```

Import reverses that process only after format, value, size, mode, and checksum validation.

The checksum detects corruption; it does not authenticate authorship.

Custom preset origin is not currently encoded, which is why Custom Game Builder does not expose a sharing path that could weaken the custom-record boundary.

See [`CHALLENGE_CODES.md`](CHALLENGE_CODES.md).

## 12. Game Backup

`lib/domain/game_backup.dart` owns the portable current-game envelope.

```text
current supported game
    ↓
strict backup codec
    ↓
clipboard or user-selected file
    ↓
strict input-size/schema/state validation
    ↓
explicit replacement confirmation
    ↓
AppController restores as unranked
```

The imported game can continue to be played and saved, but it cannot inflate trusted statistics, achievements, streaks, Daily history, or per-mode records.

See [`BACKUP_AND_RESTORE.md`](BACKUP_AND_RESTORE.md) and [`FILE_BACKUPS.md`](FILE_BACKUPS.md).

## 13. Move Replay

`lib/domain/replay_timeline.dart` turns retained session progression into a read-only timeline.

Replay UI may scrub, step, and play frames, but it has no route for mutating the live board or trusted progress.

## 14. Full Replay Archives

Full Replay Archive uses a separate versioned portable protocol for complete spectator reconstruction.

Source:

- `lib/domain/replay_archive.dart`
- `lib/domain/replay_archive_contract.dart`

Archive input is bounded and validated. Imported archives remain spectator-only and are not a trusted gameplay-import channel.

See [`REPLAY_ARCHIVES.md`](REPLAY_ARCHIVES.md).

## 15. Hint and Auto Play

Hint is read-only. It evaluates the current board and returns a recommendation without applying a move.

Auto Play is a separate deterministic sandbox. It can run Heuristic or bounded Expectimax decisions, but its game state is isolated from player saves and records.

Source:

- `lib/domain/hint_solver.dart`
- `lib/domain/expectimax_solver.dart`
- `lib/domain/autoplay_session.dart`
- `lib/features/solver_demo/`

## 16. Solver benchmark

The reusable benchmark domain code and CLI provide deterministic regression evidence:

```bash
dart run tool/solver_benchmark.dart 8
```

The benchmark is bounded smoke/performance evidence, not a proof of globally optimal 2048 play.

## 17. Localization

Player-facing localization lives under `lib/core/localization/`.

```text
persisted language preference
    ↓
System / English / हिन्दी selection
    ↓
NovaLocalizations
    ↓
feature widgets request localized strings
```

Machine-readable protocol fields, URLs, seeds, and numeric tile values are not translated.

## 18. Theme and accessibility

Theme definitions live under `lib/core/theme/`. Application settings coordinate theme mode, palette, contrast, reduced motion, language, feedback, and gameplay preferences.

Accessibility is cross-cutting rather than a separate mode. Board semantics, keyboard navigation, standard controls, text scaling, contrast, and reduced-motion behavior are protected by source/tests where possible, while real assistive-technology qualification remains manual evidence.

See [`ACCESSIBILITY.md`](ACCESSIBILITY.md).

## 19. External links

External destinations are user-triggered and pass through the shared secure-link policy before platform launch.

```text
user action
    ↓
allowed URI validation
    ↓
url_launcher platform bridge
    ↓
external browser/mail/app
```

The external handler leaves the offline application's trust boundary.

## 20. Platform runners

Shared Dart source is hosted by platform runners:

```text
android/
ios/
web/
windows/
macos/
linux/
```

A plugin may contain a Dart API plus different native implementations for each platform. That is why dependency/toolchain changes require cross-platform build verification even when application Dart code barely changes.

## 21. Web/PWA

`web/index.html`, `web/manifest.json`, icons, and generated Flutter Web output form the Web/PWA surface.

CI verifies source metadata and release compilation. Real installed-PWA lifecycle/storage behavior remains a browser qualification task.

## 22. Native builds

The maintained hosted matrix covers:

- Android release APK;
- Android release AAB;
- Linux release;
- Windows release;
- macOS release;
- unsigned iOS release compilation.

Production signing, provisioning, notarization, store policy, and real-device behavior are external release responsibilities.

See [`BUILDING_EXECUTABLES.md`](BUILDING_EXECUTABLES.md).

## 23. Repository quality pipeline

Permanent CI runs the maintained equivalent of:

```bash
flutter pub get
dart format --output=none --set-exit-if-changed lib test tool
flutter analyze
flutter test --coverage
dart run tool/release_readiness.dart --json
dart run tool/release_qualification_status.dart --json --pending-only
dart run tool/repository_audit.dart --json
dart run tool/source_completion_audit.dart --json
dart run tool/solver_benchmark.dart 8
flutter build web --release
```

Pull-request dependency review and the native build matrix add supply-chain and cross-platform evidence.

## 24. Source completion versus stable release

`2.0.12+2012` can be source-complete while stable distribution remains blocked. The repository deliberately distinguishes:

- implemented source scope;
- automated same-commit verification;
- real-world manual qualification;
- production signing/store distribution.

The 13 manual checks remain fail-closed until genuine evidence is recorded. Automation must not fabricate them.

## 25. Maintenance rule

When changing the architecture:

1. preserve deterministic engine independence;
2. validate external and persisted input before trust;
3. bound growing collections;
4. preserve import/custom/replay/Auto Play trust isolation;
5. update tests with behavior changes;
6. update the matching user/technical/release documentation;
7. run the maintained gates on the exact change;
8. treat a new product feature as a deliberately scoped future release rather than hiding it inside a completed release.

See [`MAINTENANCE_POLICY.md`](MAINTENANCE_POLICY.md).