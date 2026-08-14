# Game Modes

2048 Nova exposes ten player modes through `GameConfig.preset`. All modes use the same deterministic engine and merge rules; they differ only in board configuration, target behavior, seed, timer, or move budget.

## Mode reference

| Mode | Board | Default target | Additional rule |
| --- | ---: | ---: | --- |
| Classic | 4×4 | 2048 | Standard target-based game. |
| Quick | 3×3 | 512 | Compact board intended for shorter games. |
| Extended | 5×5 | 2048 | Larger board with the standard target. |
| Challenge | 6×6 | 4096 | Larger board with a higher target. |
| Endless | 4×4 | 2048 nominal | Reaching 2048 does not stop play. |
| Target | 4×4 | Player-selected | Select 128, 256, 512, 1024, 2048, 4096, 8192, or 16384. |
| Time Challenge | 4×4 | 2048 | 180-second limit. |
| Move Limit | 4×4 | 2048 | 250 valid-move budget. |
| Daily Challenge | 4×4 | 2048 | UTC date-derived deterministic seed. |
| Zen | 4×4 | 2048 nominal | Low-pressure continuation beyond the nominal target. |

## Classic

Classic uses a 4×4 board and target 2048. A win is reached when the configured target is present. For non-continuing target modes, further movement is blocked until the win is acknowledged or another game is started.

## Quick

Quick reduces the board to 3×3 and uses a 512 target. It uses the same spawning, scoring, merge, save, Undo, hint, statistics, and terminal-state rules as Classic.

## Extended

Extended uses a 5×5 board and a 2048 target. Additional cells create more mobility but do not change the fundamental merge rules.

## Challenge

Challenge uses a 6×6 board with a 4096 target. It is the largest built-in preset.

## Endless

Endless uses a 4×4 board. The nominal target remains 2048 for configuration consistency, but the engine does not stop the session when that target is reached. Play ends only when no legal moves remain.

## Target

Target uses a 4×4 board and prompts the player to choose one of the supported milestones:

- 128
- 256
- 512
- 1024
- 2048
- 4096
- 8192
- 16384

The chosen value is stored in the game configuration and persists with save/resume and Undo snapshots.

## Time Challenge

Time Challenge uses a 4×4 board, the normal 2048 target, and a 180-second limit. The persisted `startedAt` timestamp is used to determine expiry, so closing and reopening the app does not reset the challenge clock.

The game screen refreshes timed status once per second while the timed mode is open. Controller initialization also reconciles restored challenge state, preventing an expired save from being resumed as though time remained.

## Move Limit

Move Limit uses a 4×4 board, the 2048 target, and a 250-valid-move budget. Invalid input that leaves the board unchanged does not count as a valid move and does not spawn a tile.

The UI displays remaining moves as the configured limit minus the persisted valid-move count, clamped to the legal range.

## Daily Challenge

Daily Challenge uses a 4×4 board and an integer seed calculated from the current UTC calendar date:

```text
YYYYMMDD
```

For example, 2026-08-14 maps to `20260814`.

This seed is stored in `GameConfig`, so the deterministic RNG produces the same initial seed sequence for that date. Daily Challenge is designed to work offline; no server is required to generate the daily board.

Local Daily history stores a bounded set of recent records. A record contains:

- date-derived seed;
- score and moves from the strongest retained score result;
- highest tile reached;
- completed flag;
- won flag;
- last update timestamp.

Daily history is normalized by seed, capped at 60 records, and repaired when partially malformed persisted entries are encountered. Completion and win state are sticky, and a weaker replay cannot overwrite a stronger saved score result.

Starting or replaying a Daily Challenge that would replace a recoverable current game requires explicit replacement confirmation.

## Zen

Zen uses a 4×4 board and deliberately continues beyond the nominal 2048 target. It shares the standard engine, scoring, save, Undo, and game-over rules but avoids target-win interruption.

## Shared behavior across modes

Unless a mode explicitly changes a rule above, all player modes share:

- one merge per source tile per move;
- deterministic persisted RNG state;
- 90% spawn probability for 2 and 10% for 4;
- spawn only after a board-changing move;
- score based on merged tile values;
- persistent current game and bounded Undo history;
- touch and keyboard movement;
- optional Hint, Undo, Pause, and Restart controls;
- statistics and achievement updates for ranked local sessions;
- corruption-safe save validation;
- accessibility-aware board rendering.

Imported portable backups are deliberately marked **unranked**, regardless of their embedded mode. They may be played normally, but their later movement cannot update lifetime statistics, achievements, streaks, or Daily Challenge history. See [`BACKUP_AND_RESTORE.md`](BACKUP_AND_RESTORE.md).

## Configuration validation

Deserialized `GameConfig` values are validated before use. Current accepted structural bounds are:

- board size: 3 through 8;
- target: power of two from 4 through `1 << 30`;
- move limit: 1 through 1,000,000 when present;
- time limit: 1 through 86,400 seconds when present;
- seed: 0 through `0x7fffffff` when present.

These broader validation bounds support safe deserialization and future compatible configurations; the built-in presets remain the ten modes documented above.
