# Local Data and Storage Model

2048 Nova is offline-first. Player state is stored locally through `shared_preferences` and is validated before use. The storage layer intentionally owns only small structured JSON/string/bool values; it does not use a remote database, account service, analytics store, advertising identifier, or cloud-sync provider.

## Project-owned keys

`LocalStore` currently owns these keys:

| Key | Type | Purpose |
| --- | --- | --- |
| `nova.current_game.v1` | JSON string | Current `GameState`. |
| `nova.undo_history.v1` | JSON string | Bounded list of `GameState` snapshots. |
| `nova.settings.v1` | JSON string | Theme/gameplay settings map. |
| `nova.stats.v1` | JSON string | Lifetime player statistics map. |
| `nova.achievements.v1` | JSON string | Achievement unlock timestamps. |
| `nova.daily_history.v1` | JSON string | Bounded Daily Challenge records. |
| `nova.current_game_unranked.v1` | bool | Whether the current game came from portable import and must remain unranked. |

The `v1` suffix versions the storage key namespace separately from the inner game-state schema.

**Challenge Codes add no additional project-owned storage key.** Generated and decoded code text exists only in screen memory and, after explicit Copy/Paste actions, the platform clipboard. Starting a validated code creates an ordinary fresh game that then uses the normal current-game/Undo/statistics storage path.

## Current game

The current game is serialized with `GameState.toJson()` and deserialized with `GameState.fromJson()`.

The game-state payload contains the fields needed to resume deterministically, including:

- schema version;
- game configuration;
- board cells;
- score and game-local best display value;
- move count;
- merge count;
- game status;
- win acknowledgement state;
- deterministic RNG state;
- start timestamp.

### Validation

Deserialization rejects unsupported or structurally invalid data. Validation includes configuration type/range checks, board shape, tile values, non-negative counters, status values, RNG state, timestamps, and schema compatibility.

Legacy game schema `0` is migrated into the current supported state. Unsupported future schemas are rejected instead of being interpreted speculatively.

### Corruption recovery

If the current-game string is malformed or cannot pass strict deserialization:

- the current game key is removed;
- the associated Undo history is removed;
- the unranked-import marker is removed;
- startup continues without crashing on the corrupt save.

This prevents stale snapshots or ranking policy from being attached to a future unrelated game.

## Undo history

Undo history is serialized as a list of `GameState` snapshots and is capped at **50** entries.

Loading is self-healing:

- non-list storage is removed;
- malformed list items are skipped while valid neighbors are retained;
- overlong lists retain the newest 50 valid snapshots;
- repaired data is rewritten to storage.

The controller then applies a second session-integrity filter. A snapshot must match the current game's session timestamp and complete game configuration and cannot claim progress beyond the current game's moves, score, or merge count.

This two-level validation prevents old-session Undo data from being trusted solely because it is syntactically valid.

## Settings

Settings are stored as a JSON map and loaded through corruption-safe map parsing. Current settings include:

- brightness mode: light, dark, system;
- visual palette;
- high contrast;
- reduced motion;
- sound enabled;
- haptics enabled;
- restart confirmation.

Invalid or missing individual values use safe defaults in `AppSettings.fromJson()`.

## Statistics

Lifetime statistics include:

- games played;
- games won;
- best score;
- highest tile;
- total moves;
- total merges;
- current streak;
- best streak.

Derived UI values such as win rate and averages are computed from these counters rather than stored as independent sources of truth.

Persisted numeric values are sanitized to legal non-negative integers. Wins cannot exceed games played, highest-tile data must be zero or a legal tile power of two, and best streak is normalized so it cannot be lower than current streak.

Portable imported sessions are deliberately excluded from lifetime-statistics mutation. See [`BACKUP_AND_RESTORE.md`](BACKUP_AND_RESTORE.md).

A Challenge Code is configuration-only and starts a fresh game through `AppController.newGame`, so its resulting play follows the same normal non-Daily statistics policy as a matching mode started locally from the mode picker. See [`CHALLENGE_CODES.md`](CHALLENGE_CODES.md).

## Achievements

Achievement persistence is a map from achievement ID to an ISO-8601 unlock timestamp or null. Invalid timestamp text is treated as not unlocked rather than causing startup failure.

Achievement definitions and thresholds live in `AppController`; storage keeps only the unlock-state timestamps.

## Daily Challenge history

Daily history is a list of `DailyRecord` values, normalized by date-derived seed and capped at **60** records.

Loading is self-healing:

- malformed records are skipped;
- duplicate seeds are merged;
- records are sorted newest-first by seed;
- the list is capped at 60;
- repaired content is rewritten.

Duplicate merge policy preserves:

- the stronger score result and its associated move count;
- the maximum highest tile;
- sticky completion;
- sticky win;
- the newest update timestamp.

An imported unranked Daily-configured game cannot mutate this history.

Daily mode is also excluded from Challenge Codes. Therefore code text cannot choose an arbitrary seed and then enter the date-indexed Daily-history pipeline.

## Unranked current-game marker

Portable restore sets:

```text
nova.current_game_unranked.v1 = true
```

This marker is persisted separately from the portable game payload so external backup data cannot choose whether it is ranked. The local application is authoritative about ranking policy.

The marker is removed with current-game reset, corrupt-current-game recovery, or complete project data reset. Starting a new local game—including one created from a validated Challenge Code—persists the marker as false.

## Reset behavior

### Reset current game

`clearGame()` removes:

- current game;
- Undo history;
- current-game unranked marker.

It does not erase settings, lifetime stats, achievements, or Daily history.

### Reset statistics

Statistics reset keeps an active local ranked game as the current session so later statistics remain internally coherent. It also normalizes retained Undo `bestScore` values so an Undo cannot resurrect historical lifetime-best data after the reset.

If the active game is an imported unranked session, statistics reset leaves the session unranked and does not count it as a fresh ranked game.

### Reset achievements

Only achievement unlock timestamps are cleared.

### Clear all local data

`clearAll()` removes only the seven project-owned keys listed above. It does not call a blanket preferences wipe and therefore does not remove unrelated keys that another component might own.

Generated Challenge Code text is not one of those keys. Any clipboard copy is controlled by the operating system/platform clipboard and is outside `SharedPreferences` reset semantics.

## Deterministic state integrity

RNG state is part of `GameState`. This is important because a board-only save would not be a faithful deterministic resume: the next spawn could differ after restore. Saving the RNG state ensures normal save/resume and Undo continue from the expected pseudo-random sequence.

Challenge Codes use the same deterministic boundary at game creation: the decoded `GameConfig.seed` initializes `SeededRandomSource`, so the same supported configuration/seed yields the same opening board/RNG state and remains aligned while the same valid move sequence is played.

## Replay, Auto Play, and Challenge Code storage

- **Challenge Codes** add no persistence key. Code text is transient screen/clipboard data; a started code becomes a normal fresh game.
- **Move Replay** adds no persistence key. It builds defensive display frames from the current game and validated Undo history.
- **Auto Play Demo** adds no persistence key. Its `AutoplaySession` exists only in memory and is discarded when the demo screen is closed.

## Backup storage boundary

Portable Game Backup is clipboard text, not a new `SharedPreferences` collection. Import writes the restored game to the normal current-game key and writes the local unranked marker. It never imports the user's settings, lifetime statistics, achievements, Daily history, or old Undo list.

Challenge Codes deliberately stay separate from Backup: Challenge Codes encode only a fresh-game configuration/seed and therefore require no unranked marker; Backup encodes progress and therefore always enters the local unranked policy.

## Data migration guidance

When changing persisted data in a future version:

1. prefer an explicit schema/version change rather than silently changing semantics;
2. add migration tests for supported older data;
3. reject unsupported future versions;
4. keep corruption recovery fail-safe;
5. do not attach stale Undo or ranking metadata to a new session;
6. update this document, `CHANGELOG.md`, `docs/TESTING.md`, and `what_changed.md` in the same change.

Challenge Code format versioning is independent from `SharedPreferences` key versions because the code is a portable protocol rather than persisted app storage. See [`CHALLENGE_CODES.md`](CHALLENGE_CODES.md).

## Privacy

All persisted data in this document is local application state. The default app does not transmit it to an analytics, advertising, account, or cloud backend. Challenge Code and Game Backup clipboard access happens only after explicit user actions. External links are launched only after an explicit user action. See [`PRIVACY.md`](PRIVACY.md).

## Language preference

The existing settings object now includes `language` with one of three validated values: `system`, `english`, or `hindi`. It does not require a new top-level SharedPreferences key or a settings schema migration.

Missing, wrongly typed, or unsupported language values are interpreted as `system`. The setting contains only the user's local UI preference; no locale selection is uploaded by the project. Clearing all project data restores the default `system` preference.
