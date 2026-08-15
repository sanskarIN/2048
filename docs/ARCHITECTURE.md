# Architecture

2048 Nova uses a deliberately small layered architecture so deterministic game rules, persistence, application orchestration, and UI behavior can be tested independently.

## Domain

`lib/domain` contains:

- `game_types.dart` — game modes, directions, status, presets, and strict persisted configuration validation.
- `game_state.dart` — schema-versioned serializable board/session state and structural invariants.
- `game_engine.dart` — deterministic movement, merge, spawn, terminal-state, and hint delegation rules.
- `random_source.dart` — restorable deterministic random-source abstraction.
- `daily_record.dart` — validated Daily Challenge history records and best-result retention.
- `hint_solver.dart` — deterministic, non-mutating heuristic move evaluation.
- `autoplay_session.dart` — isolated seeded Auto Play Demo session that repeatedly applies heuristic recommendations without app persistence or lifetime-player state.
- `replay_timeline.dart` — read-only timeline builder that filters current-session Undo snapshots, removes impossible/future frames, orders retained moves, and returns defensive unmodifiable copies plus the authoritative current frame.
- `challenge_code.dart` — versioned/checksummed deterministic game-configuration codec for offline shareable seeded challenges.
- `game_backup.dart` — versioned portable current-game JSON codec with size, envelope, timestamp, and strict embedded-state validation.

The domain layer does not depend on Flutter widgets, SharedPreferences, analytics, network services, or cloud services. The engine owns authoritative gameplay rules; widgets do not directly implement merge/spawn logic.

## Data

`lib/data/local_store.dart` provides SharedPreferences-backed persistence for:

- current game;
- bounded Undo history;
- settings;
- statistics;
- achievement timestamps;
- bounded Daily Challenge history;
- current-game unranked marker.

Persistence is treated as untrusted input on read. Current-game state is validated before use. Invalid map structures are removed. Undo/Daily collections salvage valid entries, discard malformed entries, apply size bounds, and rewrite repaired storage. Daily records are normalized to one record per date seed so duplicate records cannot inflate local Daily achievement counts.

If the current game is corrupt, the store also removes its associated Undo history and unranked marker so metadata from a broken session cannot attach to a later unrelated game.

Challenge Codes deliberately add **no persistence key**. Generated/decoded codes exist in screen memory and clipboard text only. After the player starts a valid code, the resulting fresh game uses the normal current-game/Undo/statistics persistence path.

Replay deliberately adds **no new persistence format or key**. It reads already-validated bounded Undo history and the current saved game, then creates defensive display copies through `ReplayTimeline`.

Auto Play Demo deliberately adds **no persistence key**. Its sandbox state is in memory only.

Portable Game Backup itself is clipboard text, not a new local database. After a confirmed import, the restored game uses the normal current-game key and the application writes its own local unranked marker.

## App state

`AppController` is the player-session/application coordinator. It owns:

- current game + matching `GameEngine`;
- serialized move requests;
- Undo snapshots and stale-session filtering;
- save/resume orchestration;
- startup challenge-status reconciliation;
- settings;
- lifetime statistics and streak accounting;
- achievement progress/unlock persistence;
- Daily Challenge history updates;
- reset/clear behavior;
- imported-current-game unranked policy.

UI widgets observe the controller through `AppScope`, an `InheritedNotifier`. This keeps screen code small while avoiding an additional state-management dependency.

Statistics and achievements intentionally remain lifetime/application data rather than being rolled back by Undo. Board score and session state can be restored, but lifetime best score and already-earned progress are not downgraded by returning to an earlier board snapshot.

Imported sessions are a special trust boundary: the controller allows their board/session state to progress and persist while suppressing lifetime statistics, achievement, streak, and Daily-history mutation.

A valid Challenge Code is different from an imported backup: it contains no progress or historical record. After decoding/confirmation, the screen calls the normal `AppController.newGame(config)` path so it behaves like a fresh locally chosen non-Daily game.

## Features

Each user-facing screen sits under `lib/features`:

- `splash/`
- `home/`
- `modes/`
- `game/`
- `daily_challenge/`
- `challenge_codes/`
- `backup/`
- `replay/`
- `solver_demo/`
- `statistics/`
- `achievements/`
- `settings/`
- `guide/`
- `about/`
- `support/`

The Game feature renders controller/domain state, translates touch/keyboard gestures into directions/actions, and shows explicit terminal dialogs. It does not implement merge rules or choose spawned tiles.

The Challenge Codes feature generates fresh seeded preset configurations, encodes them through `ChallengeCode`, copies code text through the shared clipboard abstraction, decodes pasted/manual text through the domain validator, previews valid configuration fields, requires normal recoverable-game replacement confirmation, and then starts the decoded configuration through `AppController.newGame`. It does not persist code text, import progress, or write SharedPreferences directly.

The Backup feature performs explicit clipboard export/import. It delegates validation to `GameBackup`, previews a valid candidate, requires explicit restore confirmation, and delegates unranked-session installation to `AppController`. It does not write `SharedPreferences` directly.

The Replay feature snapshots the current controller game, loads existing persisted Undo history, delegates filtering/copying to `ReplayTimeline`, and renders a spectator-only timeline. It offers scrub, first/previous/next/latest, play/pause, and 1/2/4-frame-per-second controls. It never calls player move, Undo, statistics, achievement, or Daily-history mutation methods.

The Auto Play Demo feature owns only an in-memory `AutoplaySession`, a periodic UI timer, speed/pause controls, and demo presentation. It does not call player-game mutation methods on `AppController` and therefore cannot increment player statistics, unlock achievements, replace a save, or update Daily history.

## Shared UI and policy helpers

`lib/shared` contains cross-feature behavior such as:

- common scaffold/navigation presentation;
- validated external-link handoff;
- recoverable-game replacement confirmation;
- `TextClipboard` abstraction with the production `SystemTextClipboard` implementation used by portable text features and deterministic in-memory test implementations.

`lib/core` contains project constants and theme generation.

## Player game state flow

A normal ranked/local player move follows this high-level flow:

```text
GameScreen input
  -> AppController.move(direction)
  -> GameEngine.move(GameState, direction)
  -> deterministic board/score/RNG/status update
  -> AppController lifetime/Daily/achievement policy
  -> LocalStore persistence
  -> controller notification
  -> UI rebuild
```

Move requests are serialized in the controller so rapid touch/keyboard input cannot overlap board mutation and persistence operations.

An invalid/no-change engine move never creates an Undo snapshot, increments a move counter, or spawns a tile.

## Challenge Code boundary

Challenge Codes are portable **configuration**, not portable progress:

```text
Selected preset + generated seed
  -> ChallengeCode.encode()
  -> NOVA1 Base64URL payload + FNV-1a checksum
  -> explicit Copy action

Manual/clipboard code text
  -> ChallengeCode.decode()
  -> size/prefix/checksum/Base64URL/JSON validation
  -> strict GameConfig validation + supported-mode allowlist
  -> decoded preview
  -> normal recoverable-game replacement confirmation
  -> AppController.newGame(config)
  -> normal fresh-game persistence/statistics policy
```

`ChallengeCode` requires a deterministic seed and rejects Daily mode. Daily Challenge already uses the UTC date as a shared seed and has dedicated date-history semantics.

The checksum detects accidental corruption but is not a cryptographic signature. The code is intentionally plain text and user-editable. This is acceptable under the current local-only trust model because code payloads cannot import board progress, score, lifetime statistics, achievements, streaks, settings, Daily history, or Undo snapshots.

See [`CHALLENGE_CODES.md`](CHALLENGE_CODES.md).

## Backup trust boundary

Portable backup flow is intentionally different from a normal ranked game:

```text
Clipboard text
  -> GameBackup.decode()
  -> strict envelope + GameState validation
  -> explicit user preview/confirmation
  -> AppController.importGameBackup()
  -> current game installed
  -> old Undo cleared
  -> local unranked marker = true
  -> current game persisted
```

The outer backup JSON does not contain a `ranked` authority field. Ranking policy is local and controlled by `AppController`/`LocalStore`.

Imported play still calls the deterministic engine and is saved normally, but the controller bypasses player-record mutation paths. This permits useful portable resume without treating user-editable JSON as trusted leaderboard/achievement proof.

The external backup's embedded historical `bestScore` is not trusted. The restored game's best display value is normalized against the imported current score and the existing local lifetime best, while lifetime statistics themselves remain unchanged.

See [`BACKUP_AND_RESTORE.md`](BACKUP_AND_RESTORE.md).

## Replay boundary

Replay reuses Undo history as a bounded spectator timeline rather than creating a second competing game-history system.

`ReplayTimeline.build()` accepts:

- a defensive copy of the authoritative current `GameState`; and
- validated persisted Undo snapshots.

It then:

1. keeps only snapshots whose start time and full game configuration match the current session;
2. rejects frames whose moves, merge count, or score are beyond the current game;
3. collapses duplicate move-number snapshots;
4. sorts retained frames by move count;
5. appends/replaces the final frame with an authoritative copy of the current game;
6. returns an unmodifiable list of copied `GameState` objects.

This means replay playback/scrubbing cannot mutate the live `AppController.game`, stored Undo objects, RNG state, statistics, achievements, or Daily history.

Because Undo storage is intentionally bounded, replay is also bounded. Very long games may begin at the earliest still-retained Undo snapshot rather than move zero. The UI discloses this instead of implying a complete lifetime replay.

## Hint and Auto Play Demo boundary

Hints deliberately remain in the domain layer. `HintSolver` simulates legal directions on copied board lists and never consumes the game RNG. `GameEngine.hint()` also refuses suggestions for terminal states. Requesting a normal hint therefore cannot alter the next tile, Undo history, score, or statistics.

`AutoplaySession` is a separate domain sandbox that owns its own `GameEngine`, `GameState`, and deterministic seed. The Auto Play Demo may automatically execute its sandbox recommendation, but that automatic movement is never applied to the player's `AppController.game`. Reset recreates the seeded sandbox rather than touching persisted data.

This architecture preserves the distinction between normal Hint (suggestion only) and optional Auto Play / AI Demonstration (automatic moves inside an explicitly isolated demo).

## Persistence and session boundaries

A saved game carries its start timestamp, configuration, counters, RNG state, status, and acknowledgement state. Restored Undo snapshots must match the current session identity/configuration and cannot represent future score/move/merge progress relative to the current board.

On startup, the controller refreshes terminal rules before presenting the session. This is especially important for timed challenges that may expire while the app is closed.

The imported-game unranked flag is stored outside `GameState`. This is intentional: a portable/edited game payload cannot claim that it is trusted ranked data.

Challenge Code text is not persisted as a separate app record. Once started, only the resulting normal `GameState`/Undo/statistics state is persisted.

Move Replay reads saved game/Undo state but never writes it. Leaving the replay screen discards the in-memory defensive timeline.

The Auto Play Demo has no persistence key. Leaving or destroying the demo screen discards its sandbox state; reopening it starts from the documented deterministic seed.

## Reset boundaries

- Current-game reset removes game, Undo, and current-game unranked marker.
- Statistics reset preserves active-session consistency and prevents old Undo `bestScore` data from resurrecting reset historical records.
- Achievement reset removes unlock dates only.
- Clear All removes only project-owned keys rather than every SharedPreferences value.

See [`DATA_STORAGE.md`](DATA_STORAGE.md).

## External-link boundary

Explicit browser/email actions are routed through the shared external-link helper. It accepts secure hosted `https` URLs and non-empty `mailto` links and rejects unsupported/insecure schemes. Failed launches offer a copy fallback.

Normal gameplay, Challenge Code codec, backup codec, Replay, Hint, Auto Play, statistics, achievements, and Daily generation do not require an external service.

## Dependency policy

The project intentionally uses only `shared_preferences` and `url_launcher` beyond Flutter itself. Challenge Codes use Dart JSON/Base64URL plus the existing Flutter clipboard API abstraction; Backup uses Flutter clipboard and Dart JSON APIs; Replay and Auto Play add no package, network service, model download, analytics dependency, or cloud requirement.

This keeps the offline game lightweight and avoids coupling the deterministic engine to a state-management framework, database, analytics SDK, account system, AI service, or cloud service.

## Verification boundary

Automated unit/widget tests and GitHub Actions verify deterministic rules, Challenge Code round-trip/validation/deterministic opening behavior/UI replacement safety, persistence behavior, backup validation/isolation, analyzer cleanliness, Web builds, Replay immutability/filtering, Auto Play isolation, and configured native compilation.

Physical-device UX, real screen-reader behavior, real platform clipboard behavior for Challenge Codes and Game Backup, platform browser/email handlers, signing/provisioning, long-session qualification, and store submission remain explicit manual release boundaries.

For more detail:

- [`GAME_ENGINE.md`](GAME_ENGINE.md)
- [`GAME_MODES.md`](GAME_MODES.md)
- [`CHALLENGE_CODES.md`](CHALLENGE_CODES.md)
- [`DATA_STORAGE.md`](DATA_STORAGE.md)
- [`BACKUP_AND_RESTORE.md`](BACKUP_AND_RESTORE.md)
- [`HINT_SOLVER.md`](HINT_SOLVER.md)
- [`TESTING.md`](TESTING.md)
- [`VERIFICATION.md`](VERIFICATION.md)

## Localization architecture

Localization is kept under `lib/core/localization/` rather than inside game rules or persistence code. `NovaLocalizations` declares supported locales, exposes `BuildContext.l10n`, owns typed dynamic helpers, and uses English source text as the defensive fallback. `hindi_translations.dart` contains the main Hindi fixed-string catalog.

`NovaApp` registers the project delegate plus Flutter's Material, Widgets, and Cupertino localization delegates. `AppSettings.language` stores `system`, `english`, or `hindi`; malformed persisted values fall back to System default. Switching language does not recreate or reinterpret `GameState`, RNG, Undo, ranking policy, Daily history, Challenge Codes, Replay, Auto Play, or portable backup data.

The architecture deliberately has no remote translation service. See [`LOCALIZATION.md`](LOCALIZATION.md).


## Phase 17 per-mode record boundary

Per-mode records remain part of controller-owned player statistics rather than the deterministic engine. `ModeRecord` and `PlayerStats.modeRecords` live in `lib/app/state/app_controller.dart`; the engine still knows nothing about lifetime records, trust, imported backups, or UI presentation.

`AppController` is the policy boundary. It updates a mode record only while `_currentGameUnranked` is false, seeds a missing record from a ranked restored session, preserves maxima across Undo, rebuilds only an active ranked baseline after Reset Statistics, and deliberately bypasses record mutation for imported portable progress. `StatisticsScreen` only reads the sanitized records and presents localized mode/configuration metadata.

This keeps three separate concerns explicit: deterministic game state, trusted local aggregate/record policy, and presentation. Future online/cloud/portable ranking work must not bypass this separation.
