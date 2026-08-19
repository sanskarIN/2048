# Custom Game Builder

> Version 1.6 feature branch documentation. This feature is not part of the qualified Version 1.5 release candidate until its own review and verification are complete.

## Purpose

Custom Game Builder lets a player create reusable local 2048 configurations without changing the deterministic engine or inventing a parallel rules implementation.

The builder reuses the existing `GameConfig` and `GameEngine` boundaries. A custom preset selects only already-supported deterministic parameters:

- board size from **3×3 through 8×8**;
- target tile from the supported power-of-two target set exposed by the UI;
- one style: **Target**, **Endless**, **Timed**, or **Move Limit**;
- a style-specific time or move limit where applicable;
- an optional deterministic random seed.

## Domain model

`lib/domain/custom_game_preset.dart` owns the versioned `CustomGamePreset` model.

Current schema:

```text
schemaVersion = 1
name
style
size
target
moveLimit
timeLimitSeconds
seed
```

Validation is fail-closed:

- name must contain 1–40 non-whitespace characters after trimming;
- board size must be 3–8;
- target must be a supported power of two within the engine's safe numeric range;
- seed, when present, must be an integer from 0 through `0x7fffffff`;
- Target and Endless do not accept a time/move limit;
- Timed requires exactly a valid time limit;
- Move Limit requires exactly a valid move limit.

Malformed persisted data is rejected with `FormatException` rather than partially accepted.

## Engine mapping

Custom styles intentionally map to existing tested engine modes:

| Custom style | Engine mode |
| --- | --- |
| Target | `GameMode.target` |
| Endless | `GameMode.endless` |
| Timed | `GameMode.timeChallenge` |
| Move Limit | `GameMode.moveLimit` |

There is deliberately no new `GameMode.custom` enum member. This avoids unnecessary migrations across saved games, replay archives, localization switches, statistics serialization, Challenge Codes, and other exhaustive mode logic.

## Local preset persistence

`lib/data/custom_preset_store.dart` stores presets under:

```text
nova.custom_game_presets.v1
```

The store:

- validates every record on load;
- drops malformed records while preserving valid neighbors;
- deduplicates names case-insensitively;
- keeps at most **24** presets;
- rewrites repaired data after recovery;
- removes malformed top-level storage instead of crashing;
- exposes an explicit clear operation.

`LocalStore.clearAll()` also removes this key, so **Clear all local data** retains its promise to remove every project-owned user-data category.

## Custom-session identity and statistics

A custom game is trusted local gameplay, but its configuration may not be comparable to a built-in preset. For example, an 8×8 Target game must not overwrite the best record displayed for the built-in 4×4 Target mode.

To preserve that boundary, the controller persists a separate session marker:

```text
nova.current_game_custom.v1
```

The marker is deliberately separate from `GameState` serialization so existing save, Challenge Code, replay, and backup formats do not need a migration solely for UI-origin metadata.

Policy:

- custom games are **not** imported/unranked backups;
- they may contribute to normal lifetime gameplay totals and achievements;
- they **do not update built-in per-mode best-score/highest-tile records**;
- the custom identity survives save/resume and app restart;
- starting a normal built-in game clears the custom identity;
- importing a portable backup clears the custom identity and keeps the existing unranked-import policy;
- clearing the active game or all app data removes the marker.

## User interface

`lib/features/modes/custom_game_builder_screen.dart` provides:

- English and Hindi labels from the first implementation;
- preset name input;
- game-style selector;
- board-size selector;
- target selector;
- conditional time/move-limit selector;
- optional deterministic seed input;
- **Play now**;
- **Save preset**;
- saved-preset list with play/delete actions.

Mode Selection exposes the builder without replacing the current game. The existing replacement guard is invoked only when a player actually starts a custom game.

Invalid form input is rejected before the current game can be replaced.

## Privacy and offline behavior

Custom presets are local-only. Creating, saving, deleting, or playing a preset does not require:

- an account;
- analytics;
- advertising;
- a backend;
- cloud synchronization;
- remote AI;
- network access.

An optional future sharing action may reuse the existing Challenge Code format only if the current validator can represent the chosen configuration without weakening its strict validation or Daily Challenge isolation.

## Tests

The feature branch includes focused coverage for:

- domain validation and JSON round trips;
- style-to-engine mapping;
- invalid schema/style/number rejection;
- local preset persistence, deduplication, corruption repair, and bounds;
- full-data reset behavior;
- bilingual builder rendering and user flows;
- invalid seed rejection before replacement;
- custom-session persistence across restart;
- built-in per-mode-record isolation;
- restoration of normal record behavior after starting a built-in game.

## Release boundary

This feature must remain outside the Version 1.5 stable claim until its feature branch is formatter-clean, analyzer-clean, regression-tested, documented, and reviewed through the maintained CI process. Real-device/responsive/accessibility qualification should then be added to the next release's evidence plan rather than silently reusing Version 1.5 evidence.
