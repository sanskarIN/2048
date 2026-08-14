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

The domain layer does not depend on Flutter widgets, SharedPreferences, or external services. The engine owns authoritative gameplay rules; widgets do not directly mutate board rules.

## Data

`lib/data/local_store.dart` provides SharedPreferences-backed persistence for:

- current game;
- bounded undo history;
- settings;
- statistics;
- achievement timestamps;
- bounded Daily Challenge history.

Persistence is treated as untrusted input on read. Current-game state is validated before use. Invalid map values are removed. Undo/Daily collections salvage valid entries, discard malformed entries, apply size bounds, and rewrite repaired storage. Daily records are normalized to one record per date seed so duplicates cannot inflate local achievement counts.

Replay deliberately adds **no new persistence format or key**. It reads the already-validated bounded Undo history and the current saved game, then creates defensive display copies through `ReplayTimeline`.

## App state

`AppController` is the session/application coordinator. It owns:

- current game + matching `GameEngine`;
- serialized move requests;
- undo snapshots and stale-session filtering;
- save/resume orchestration;
- startup challenge-status reconciliation;
- settings;
- lifetime statistics and streak accounting;
- achievement progress/unlock persistence;
- Daily Challenge history updates;
- reset/clear behavior.

UI widgets observe the controller through `AppScope`, an `InheritedNotifier`. This keeps screen code small while avoiding an additional state-management dependency.

Statistics and achievements intentionally remain lifetime/application data rather than being rolled back by Undo. Board score and session state can be restored, but lifetime best score and already-earned progress are not downgraded by returning to an earlier board snapshot.

## Features

Each user-facing screen sits under `lib/features`:

- `splash/`
- `home/`
- `modes/`
- `game/`
- `daily_challenge/`
- `replay/`
- `solver_demo/`
- `statistics/`
- `achievements/`
- `settings/`
- `guide/`
- `about/`
- `support/`

The Game feature renders controller/domain state, translates touch/keyboard gestures into directions/actions, and shows explicit terminal dialogs. It does not implement merge rules or choose spawned tiles.

The Replay feature snapshots the current controller game, loads the existing persisted Undo history, delegates filtering/copying to `ReplayTimeline`, and renders a spectator-only timeline. It offers scrub, first/previous/next/latest, play/pause, and 1/2/4-frame-per-second controls. It never calls player move, Undo, save, statistics, achievement, or Daily-history mutation methods.

The Auto Play Demo feature owns only an in-memory `AutoplaySession`, a periodic UI timer, speed/pause controls, and demo presentation. It does not call player-game mutation methods on `AppController` and therefore cannot increment player statistics, unlock achievements, replace a save, or update Daily history.

## Shared UI/policies

`lib/shared` contains cross-feature behavior such as:

- common scaffold/navigation presentation;
- validated external-link handoff;
- recoverable-game replacement confirmation.

`lib/core` contains project constants and theme generation.

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

This means replay playback/scrubbing cannot mutate the live `AppController.game`, the stored Undo objects, RNG state, statistics, achievements, or Daily history.

Because Undo storage is intentionally bounded, replay is also bounded. Very long games may begin at the earliest still-retained Undo snapshot rather than move zero. The UI discloses this instead of implying a complete lifetime replay.

## Hint and Auto Play Demo boundary

Hints deliberately remain in the domain layer. `HintSolver` simulates legal directions on copied board lists and never consumes the game RNG. `GameEngine.hint()` also refuses suggestions for terminal states. This guarantees requesting a normal hint cannot alter the next tile, undo history, score, or statistics.

`AutoplaySession` is a separate domain sandbox that owns its own `GameEngine`, `GameState`, and deterministic seed. The Auto Play Demo may automatically execute its sandbox recommendation, but that automatic movement is never applied to the player's `AppController.game`. Reset recreates the seeded sandbox rather than touching persisted data.

This architecture satisfies the distinction between a normal Hint (suggestion only) and optional Auto Play / AI Demonstration (automatic moves inside an explicitly isolated demo).

## Persistence/session boundaries

A saved game carries its start timestamp, configuration, counters, RNG state, status, and acknowledgement state. Restored undo snapshots must match the current session identity/configuration and cannot represent future score/move/merge progress relative to the current board.

On startup, the controller refreshes terminal rules before presenting the session. This is especially important for timed challenges that may expire while the app is closed.

Move Replay reads saved game/Undo state but never writes it. Leaving the replay screen simply discards the in-memory defensive timeline.

The Auto Play Demo has no persistence key. Leaving or destroying the demo screen discards its sandbox state; reopening it starts from the documented deterministic seed.

## Dependency policy

The project intentionally uses only `shared_preferences` and `url_launcher` beyond Flutter itself. Replay and Auto Play Demo add no package, network service, model download, analytics dependency, or cloud requirement.

This keeps the offline game lightweight and avoids coupling the deterministic engine to a state-management framework, database, analytics SDK, account system, AI service, or cloud service.

## Verification boundary

Automated unit/widget tests and GitHub Actions verify deterministic rules, persistence behavior, analyzer cleanliness, Web builds, replay immutability/filtering, Auto Play isolation, and configured native compilation. Physical-device UX, real screen-reader behavior, platform handlers, signing/provisioning, and store submission remain explicit manual release boundaries.
