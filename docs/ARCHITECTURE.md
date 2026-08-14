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
- `statistics/`
- `achievements/`
- `settings/`
- `guide/`
- `about/`
- `support/`

The Game feature renders controller/domain state, translates touch/keyboard gestures into directions/actions, and shows explicit terminal dialogs. It does not implement merge rules or choose spawned tiles.

## Shared UI/policies

`lib/shared` contains cross-feature behavior such as:

- common scaffold/navigation presentation;
- validated external-link handoff;
- recoverable-game replacement confirmation.

`lib/core` contains project constants and theme generation.

## Hint boundary

Hints deliberately remain in the domain layer. `HintSolver` simulates legal directions on copied board lists and never consumes the game RNG. `GameEngine.hint()` also refuses suggestions for terminal states. This guarantees requesting a hint cannot alter the next tile, undo history, score, or statistics.

## Persistence/session boundaries

A saved game carries its start timestamp, configuration, counters, RNG state, status, and acknowledgement state. Restored undo snapshots must match the current session identity/configuration and cannot represent future score/move/merge progress relative to the current board.

On startup, the controller refreshes terminal rules before presenting the session. This is especially important for timed challenges that may expire while the app is closed.

## Dependency policy

The project intentionally uses only `shared_preferences` and `url_launcher` beyond Flutter itself. This keeps the offline game lightweight and avoids coupling the deterministic engine to a state-management framework, database, analytics SDK, account system, or cloud service.

## Verification boundary

Automated unit/widget tests and GitHub Actions verify deterministic rules, persistence behavior, analyzer cleanliness, Web builds, and configured native compilation. Physical-device UX, real screen-reader behavior, platform handlers, signing/provisioning, and store submission remain explicit manual release boundaries.
