# 2048 Nova Architecture Walkthrough

This guide explains **how the implemented project flows from startup to gameplay, persistence, replay, backup, solver, localization, and release tooling**. It complements [`ARCHITECTURE.md`](ARCHITECTURE.md) by following real user/developer flows through the current source tree.

Current source target: **2.0.12+2012**.

## 1. High-level layers

The source is intentionally organized into responsibilities:

```text
lib/main.dart
    ↓
lib/app/                 application shell and state orchestration
    ↓
lib/features/            screens and feature UI
    ↓
lib/domain/              deterministic game/protocol/solver logic
    ↓
lib/data/                local persistence/infrastructure

lib/core/                cross-cutting constants, localization, theme
lib/shared/              reusable shared UI/helpers
```

This is not an absolute “UI can never call anything else” rule. It is a design boundary that keeps game rules and portable codecs testable independently from screens.

## 2. Application startup

Entry point:

```text
lib/main.dart
```

Conceptual startup flow:

```text
Flutter runtime starts
        ↓
main() initializes required Flutter/application state
        ↓
local settings/save data are prepared
        ↓
AppController is created/initialized
        ↓
NovaApp becomes the root widget
        ↓
AppScope exposes controller/state to descendant UI
        ↓
initial splash/home/navigation UI appears
```

Primary files:

```text
lib/main.dart
lib/app/nova_app.dart
lib/app/state/app_controller.dart
lib/app/state/app_scope.dart
```

## 3. Why `AppController` exists

`AppController` is the central application/session coordinator.

It sits between UI actions and lower-level domain/storage responsibilities so screens do not independently invent rules for:

- starting games;
- moving tiles;
- undo;
- saving/resuming;
- updating statistics/records;
- challenge/daily/replay behavior;
- settings/theme/language;
- persistence and trust boundaries.

This reduces duplicated state logic across screens.

## 4. `AppScope`

`AppScope` makes the active controller/state accessible to descendant widgets.

Conceptually:

```text
NovaApp
  └─ AppScope
       ├─ Home
       ├─ Game
       ├─ Settings
       ├─ Statistics
       └─ other feature screens
```

The scope is a UI/state-access mechanism. It should not become another independent game engine.

## 5. Home and navigation

Feature area:

```text
lib/features/home/
```

The home experience exposes the major entry points such as:

- play/start/resume;
- mode selection;
- daily challenge;
- statistics/achievements;
- solver demonstration;
- settings;
- guide/about/support;
- backup/replay/challenge features.

Navigation changes which UI surface is shown; it should not bypass application state rules.

## 6. Starting a game

Conceptual flow:

```text
User selects mode/configuration
        ↓
mode UI validates selection
        ↓
AppController starts a game session
        ↓
domain state/engine/random source are initialized
        ↓
initial board/spawns are created deterministically for the session state
        ↓
state is exposed to Game UI
        ↓
save/persistence is updated according to policy
```

Relevant paths:

```text
lib/features/modes/
lib/features/game/
lib/app/state/app_controller.dart
lib/domain/game_state.dart
lib/domain/game_engine.dart
lib/domain/random_source.dart
lib/domain/game_types.dart
```

## 7. Game state

`lib/domain/game_state.dart` represents the state required to describe the current game.

A useful mental model includes concepts such as:

```text
board
score
move count
highest tile
mode/configuration
status/terminal state
random-source state
mode-specific counters/timing where applicable
```

The exact fields are source-controlled. Documentation should describe behavior rather than creating another conflicting state schema.

## 8. Directional move flow

Conceptually:

```text
Swipe / keyboard / UI command
        ↓
Game screen translates input to direction
        ↓
AppController requests move
        ↓
GameEngine applies deterministic shift/merge rules
        ↓
Was the move valid/state-changing?
        ├─ no → state remains appropriately unchanged
        └─ yes
             ↓
         score/board update
             ↓
         deterministic random source chooses spawn outcome
             ↓
         new tile is spawned
             ↓
         terminal/mode conditions evaluated
             ↓
         controller records trusted side effects
             ↓
         save/statistics/records/replay history updated
             ↓
         UI rebuilds from new state
```

Exact merge behavior is specified in [`GAME_ENGINE.md`](GAME_ENGINE.md).

## 9. Why random state belongs in deterministic domain logic

A normal “call random whenever needed” design makes exact session reproduction difficult.

The project uses a controlled random source so a known seed/state and event order can reproduce the same pseudo-random sequence.

That supports:

- deterministic tests;
- Challenge Codes;
- Daily Challenge;
- replays;
- debugging;
- solver benchmark fixtures.

File:

```text
lib/domain/random_source.dart
```

Gameplay determinism is not cryptographic security.

## 10. Merge and spawn separation

A move is conceptually two different operations:

1. transform the current board according to directional merge rules;
2. if appropriate, spawn a new tile using the deterministic random source.

Keeping those concepts explicit makes tests able to prove movement rules separately from random spawning.

## 11. Terminal-state evaluation

After a move, the engine/controller can evaluate whether the session has:

- reached a mode target;
- exhausted valid moves;
- exhausted time/move budget;
- reached another mode-specific completion boundary;
- remained playable.

The ten modes have different objectives/constraints, so do not hard-code one “game over” meaning into every screen.

See [`GAME_MODES.md`](GAME_MODES.md).

## 12. Mode configuration

Shared mode types/configuration live in:

```text
lib/domain/game_types.dart
```

UI for selecting/configuring modes lives in:

```text
lib/features/modes/
```

This division means the UI chooses a supported configuration while the domain/controller enforces what that configuration means.

## 13. Undo flow

Conceptually:

```text
Before trusted state-changing move
        ↓
controller retains bounded prior state
        ↓
move occurs
        ↓
user chooses Undo
        ↓
controller validates Undo availability/policy
        ↓
prior trusted state is restored
        ↓
persistent current game/UI are synchronized
```

The Undo history is bounded. It is not an unlimited full event-sourcing database.

## 14. Save flow

Persistence implementation:

```text
lib/data/local_store.dart
```

Conceptually:

```text
trusted controller state changes
        ↓
state is serialized into supported local schema
        ↓
LocalStore writes bounded local data
        ↓
application can resume later
```

The storage layer should not independently calculate gameplay outcomes.

## 15. Resume flow

Conceptually:

```text
application starts
        ↓
LocalStore reads persisted data
        ↓
schema/data is validated/migrated
        ↓
valid current game/settings/history are reconstructed
        ↓
controller exposes restored state
        ↓
UI offers/continues resume path
```

Malformed/incompatible data should follow documented recovery behavior rather than causing arbitrary trusted-state mutation.

See [`DATA_STORAGE.md`](DATA_STORAGE.md).

## 16. Preferences/settings flow

Conceptually:

```text
Settings screen changes a supported preference
        ↓
AppController validates/applies value
        ↓
preference is persisted
        ↓
NovaApp/feature widgets rebuild with new setting
```

Examples can include theme, language, accessibility, and gameplay presentation preferences.

Feature path:

```text
lib/features/settings/
```

## 17. Theme flow

Theme definitions:

```text
lib/core/theme/
```

Conceptually:

```text
saved/selected theme preference
        ↓
AppController/application state
        ↓
NovaApp chooses theme configuration
        ↓
all descendant Material widgets inherit/update theme
```

Contrast/accessibility should remain part of theme changes, not an afterthought.

## 18. Localization flow

Localization source:

```text
lib/core/localization/
```

Conceptually:

```text
saved language preference / fallback
        ↓
application locale/localizer selection
        ↓
feature widgets request translated strings
        ↓
English or Hindi text is presented
```

Avoid hard-coded user-facing strings inside low-level domain code where localization should be a UI concern.

See [`LOCALIZATION.md`](LOCALIZATION.md).

## 19. Statistics flow

Conceptually:

```text
trusted gameplay event/session completion
        ↓
AppController evaluates statistics update rules
        ↓
trusted local statistics/records change
        ↓
LocalStore persists them
        ↓
Statistics/Achievements UI reads current values
```

Relevant paths:

```text
lib/features/statistics/
lib/features/achievements/
lib/app/state/app_controller.dart
lib/data/local_store.dart
```

Portable imported data is not allowed to become an unrestricted record-writing path.

## 20. Per-mode records

Records are associated with defined game modes and trusted local gameplay.

The trust policy is important:

```text
trusted local play → eligible record path
portable/imported data → isolated/unranked unless explicitly permitted by policy
```

See [`MODE_RECORDS.md`](MODE_RECORDS.md).

## 21. Daily Challenge flow

Conceptually:

```text
date/day identity
        ↓
deterministic daily challenge configuration/seed
        ↓
controller starts daily session
        ↓
normal deterministic engine flow
        ↓
local daily record/history is updated
```

Source:

```text
lib/domain/daily_record.dart
lib/features/daily_challenge/
```

Portable timestamps are normalized according to [`PORTABLE_TIMESTAMPS.md`](PORTABLE_TIMESTAMPS.md).

## 22. Challenge Code export

Source codec:

```text
lib/domain/challenge_code.dart
```

Conceptually:

```text
supported challenge configuration/seed
        ↓
codec serializes compact fields
        ↓
checksum/integrity field is produced
        ↓
text code is displayed/copied or rendered as QR
```

The checksum detects corruption; it is not proof of who authored the code.

## 23. Challenge Code import

Conceptually:

```text
user supplies text/QR-decoded challenge payload
        ↓
codec parses structure
        ↓
format/value/checksum limits are validated
        ↓
invalid data is rejected
        ↓
valid challenge configuration creates an isolated supported challenge
```

External input is a trust boundary.

See [`CHALLENGE_CODES.md`](CHALLENGE_CODES.md).

## 24. QR flow

Feature path:

```text
lib/features/challenge_codes/
```

A QR image is only another representation of the Challenge Code payload.

Rendering a QR does not require a camera. Any future scanner would be a separate feature requiring camera/platform/privacy documentation.

## 25. Current-game backup export

Codec:

```text
lib/domain/game_backup.dart
```

Conceptually:

```text
current supported game state
        ↓
backup codec serializes bounded portable representation
        ↓
UI lets user copy/save/share through supported path
```

See [`BACKUP_AND_RESTORE.md`](BACKUP_AND_RESTORE.md).

## 26. Backup import

Conceptually:

```text
user-controlled portable input
        ↓
size/structure/schema/value validation
        ↓
codec reconstructs safe state
        ↓
controller applies imported-state trust policy
        ↓
imported session remains isolated from trusted ranked data where required
```

This prevents a backup file from becoming a way to directly write arbitrary achievements/records/statistics.

## 27. File backup transport

Feature path:

```text
lib/features/backup/
```

Native file picker/handler integration is infrastructure. It transports bytes/text; it should not bypass the domain backup validator.

Real file handlers require platform qualification because hosted unit tests cannot reproduce every OS picker/share/provider behavior.

See [`FILE_BACKUPS.md`](FILE_BACKUPS.md).

## 28. Move Replay

Source:

```text
lib/domain/replay_timeline.dart
```

Conceptually:

```text
trusted session records move progression
        ↓
replay timeline stores bounded reconstructable events/states
        ↓
replay UI can step forward/back/play through timeline
```

Replay viewing is not active ranked gameplay.

## 29. Full Replay Archive

Source:

```text
lib/domain/replay_archive.dart
lib/domain/replay_archive_contract.dart
```

Conceptually:

```text
session metadata + bounded replay events
        ↓
archive codec serializes portable representation
        ↓
export/share
        ↓
import validates schema/event/count/value limits
        ↓
replay UI reconstructs spectator timeline
```

See [`REPLAY_ARCHIVES.md`](REPLAY_ARCHIVES.md).

## 30. Hint flow

Source:

```text
lib/domain/hint_solver.dart
```

Conceptually:

```text
current board/state snapshot
        ↓
solver evaluates legal moves
        ↓
best recommendation returned
        ↓
UI displays recommendation
```

The Hint path is read-only. Merely requesting a hint does not mutate the trusted game board.

## 31. Heuristic solver

A heuristic evaluates board characteristics with a bounded computation cost.

It can consider properties such as board structure/mobility/tiles according to the implementation, producing comparative move scores rather than exhaustively solving the complete future game.

## 32. Expectimax solver

Source:

```text
lib/domain/expectimax_solver.dart
```

Conceptual search tree:

```text
current board
    ↓
player move choices (maximize expected value)
    ↓
possible random tile spawns (weighted expectation)
    ↓
next player choices
    ↓
... bounded depth/work budget ...
    ↓
evaluation score
```

The search is bounded so it cannot expand indefinitely and freeze the app.

## 33. Auto Play flow

Source:

```text
lib/domain/autoplay_session.dart
lib/features/solver_demo/
```

Conceptually:

```text
isolated autoplay state
        ↓
selected solver recommends a move
        ↓
autoplay session applies it
        ↓
normal deterministic engine/spawn behavior
        ↓
repeat until stop/terminal/budget
```

Auto Play is deliberately isolated from normal trusted ranked gameplay.

## 34. Solver benchmark flow

Reusable benchmark logic:

```text
lib/domain/solver_benchmark.dart
```

CLI:

```text
tool/solver_benchmark.dart
```

Run:

```bash
dart run tool/solver_benchmark.dart 8
```

The CLI provides deterministic smoke/performance regression evidence. It does not prove globally optimal play.

## 35. External links

Support/About/UI can launch external destinations through the platform URL-launching integration.

Conceptually:

```text
user taps clearly identified external action
        ↓
application validates/selects supported URI
        ↓
platform handler/browser is requested
        ↓
control leaves the app's local trust boundary
```

The external site/app and network are not part of the offline game engine.

## 36. Offline-first boundary

The core product does not require a project account, remote database, or continuous backend to play.

Network behavior can still occur outside the core app when the user explicitly opens external URLs or when the operating system/tooling performs its own network functions.

See [`PRIVACY.md`](PRIVACY.md).

## 37. Platform runner relationship

Shared source:

```text
lib/
```

Native/web shells:

```text
android/
ios/
web/
windows/
macos/
linux/
```

Conceptually:

```text
platform launches native/web runner
        ↓
runner initializes Flutter engine
        ↓
Flutter loads Dart application
        ↓
shared NovaApp UI/domain logic runs
        ↓
plugins bridge supported platform services
```

## 38. Flutter plugin relationship

A dependency can include:

- Dart API used by shared code;
- Android Kotlin/Java native implementation;
- iOS/macOS Swift/Objective-C implementation;
- Windows C++ implementation;
- Linux C++/GTK implementation;
- Web JavaScript/browser implementation.

This is why a seemingly small package upgrade can require rebuilding all platforms.

## 39. Web/PWA flow

Source shell:

```text
web/index.html
web/manifest.json
web/icons/
```

Build:

```bash
flutter build web --release
```

Generated site:

```text
build/web/
```

The Web build must be served/deployed as a complete directory. PWA install/offline lifecycle requires real browser qualification.

## 40. Android build flow

Conceptually:

```text
Flutter/Dart source + Android runner/plugins
        ↓
Flutter build command
        ↓
Gradle Wrapper 9.7.0
        ↓
AGP 9.1.0 + Kotlin 2.4.10 + JDK/JVM 17 target
        ↓
Android SDK/NDK tools
        ↓
APK or AAB
```

Private distribution signing is a separate authorized release step.

## 41. Windows build flow

```text
Flutter source + windows/ CMake/C++ runner/plugins
        ↓
Flutter build
        ↓
CMake + Visual Studio/MSVC/MSBuild + Windows SDK
        ↓
complete Windows runtime bundle
```

Do not distribute only the `.exe`.

## 42. Linux build flow

```text
Flutter source + linux/ CMake/C++ runner/plugins
        ↓
Flutter build
        ↓
CMake + Ninja + Clang + GTK/native libraries
        ↓
complete Linux runtime bundle
```

## 43. macOS/iOS build flow

```text
Flutter source + Apple runners/plugins
        ↓
Flutter build
        ↓
Xcode/Clang/Apple SDK + CocoaPods as needed
        ↓
macOS .app or iOS .app/archive
        ↓
signing/provisioning/export/notarization as applicable
```

## 44. Test architecture

Tests live under:

```text
test/
```

The suite covers categories such as:

- domain/game rules;
- controller/state behavior;
- persistence/migrations;
- challenge/backup/replay codecs;
- solvers/autoplay;
- localization/UI;
- release/current-version contracts;
- CI/workflow source contracts;
- repository/source-completion tools;
- documentation completeness.

Run everything:

```bash
flutter test
```

## 45. Repository tool architecture

Maintainer CLIs under `tool/` are Dart programs intentionally kept in source control.

They can inspect current repository state without requiring a Flutter UI.

Examples:

```text
release_readiness.dart
release_qualification_status.dart
record_release_qualification.dart
repository_audit.dart
source_completion_audit.dart
solver_benchmark.dart
```

## 46. Candidate release gate

```bash
dart run tool/release_readiness.dart --json
```

Checks candidate/source release conditions but does not fabricate pending manual evidence.

## 47. Stable release gate

```bash
dart run tool/release_readiness.dart --stable --json
```

This intentionally fails closed until the canonical real-world qualification evidence is complete.

Failing for genuinely pending evidence is correct behavior.

## 48. Repository audit

```bash
dart run tool/repository_audit.dart --json
```

Protects repository files/current release metadata/Web metadata/links/continuity and other integrity requirements.

It is a repository correctness tool, not a gameplay solver.

## 49. Source-completion audit

```bash
dart run tool/source_completion_audit.dart --json
```

Protects the feature-complete Version 2.0.12 source contract and maintained source markers/current documentation rules.

## 50. CI architecture

GitHub Actions workflows under `.github/workflows/` execute automation on hosted environments.

Permanent quality CI includes source checks and Web build.

Native platform workflow builds each native target on a compatible host runner.

A GitHub Actions result is evidence for that workflow/runner/commit—not a substitute for every physical device/store/accessibility environment.

## 51. Trust-boundary map

Important trust transitions:

```text
user text/QR/file import → validator/codec → isolated safe state
external URL action       → OS/browser outside application trust boundary
release signing secret    → private release environment, never public source
manual evidence           → guarded qualification manifest, only observed results
hosted CI artifact        → qualification artifact, not automatically production signed
```

## 52. Why imported progress is unranked/isolated

If an arbitrary portable file could directly set trusted best scores/achievements/statistics, anyone could edit/import a file and overwrite ranked history.

The design therefore treats portable imports as untrusted data requiring validation and isolation.

## 53. Why checksums are not authentication

A checksum can show that a payload changed unexpectedly.

If anyone can recompute the checksum after modifying the payload, it does not prove author identity.

Challenge Code/file checksums therefore provide integrity/error detection, not cryptographic authentication.

## 54. Why source completion and stable release are separate

Source completion means the declared feature scope and source-level contracts are implemented.

Stable release qualification also requires evidence from environments the source tree cannot simulate honestly, such as:

- real Android/iOS devices;
- assistive technology;
- physical/external handlers;
- installed PWA lifecycle;
- final signing/provisioning/store metadata.

The architecture deliberately encodes that difference into release tooling.

## 55. How to trace an unfamiliar feature

Use this sequence:

1. find its screen under `lib/features/`;
2. search the screen for controller calls;
3. inspect the corresponding `AppController` behavior;
4. follow calls into `lib/domain/` for rules/codecs/solver;
5. follow persistence calls into `lib/data/local_store.dart`;
6. find tests with the feature/domain name under `test/`;
7. read the canonical feature document under `docs/`;
8. run the focused test plus whole suite before changing behavior.

Useful search:

```bash
git grep -n "FeatureName" lib test docs
```

## 56. How to add a bug fix without breaking layers

For a reproducible defect:

1. identify the layer that owns the rule;
2. add a regression test at the narrowest useful layer;
3. fix the owning implementation;
4. update user/technical docs if observable behavior changes;
5. run formatter/analyzer/tests/audits;
6. rebuild affected native targets if a plugin/platform layer changed.

Do not patch the screen to hide a domain-engine bug when the engine itself is wrong.

## 57. How to change a portable format safely

For Challenge Code/backup/replay/storage schema changes:

- version the format where applicable;
- preserve required backward compatibility or provide explicit migration/rejection behavior;
- validate all external values and sizes;
- keep imports isolated from trusted records;
- add old/new/malformed regression fixtures;
- update the exact protocol/storage documentation.

## 58. How to change a dependency safely

A Dart dependency can affect native platforms.

Workflow:

```bash
flutter pub outdated
# make deliberate pubspec change
flutter pub get
git diff -- pubspec.yaml pubspec.lock
flutter analyze
flutter test
```

Then rebuild all affected supported platforms.

## 59. How to change a platform runner safely

Do not use `flutter create .` as an automatic overwrite of customized runners.

Instead:

1. identify the exact native requirement;
2. compare with a temporary current Flutter template if needed;
3. migrate the smallest required change;
4. preserve IDs, signing rules, branding, metadata, PWA config, version resources;
5. run source tests and that native build.

## 60. Related documentation

- [`ARCHITECTURE.md`](ARCHITECTURE.md) — architectural contracts.
- [`REPOSITORY_FILE_ATLAS.md`](REPOSITORY_FILE_ATLAS.md) — every source-tree area.
- [`FEATURE_REFERENCE.md`](FEATURE_REFERENCE.md) — feature-by-feature meaning.
- [`GAME_ENGINE.md`](GAME_ENGINE.md) — exact engine behavior.
- [`DATA_STORAGE.md`](DATA_STORAGE.md) — persistence.
- [`TESTING.md`](TESTING.md) — test/evidence strategy.
- [`DEVELOPMENT.md`](DEVELOPMENT.md) — contribution workflow.
- [`setup/README.md`](setup/README.md) — development environment setup.
