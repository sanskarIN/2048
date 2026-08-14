# Game Engine Rules and Invariants

2048 Nova keeps gameplay rules in `lib/domain/` so they can be tested independently from Flutter widgets and local persistence. The primary implementation is `GameEngine`, with serializable state in `GameState`, configuration in `GameConfig`, deterministic random behavior in `RandomSource`, and move recommendations in `HintSolver`.

## Board representation

A board is a square `List<List<int>>` whose dimensions match `GameConfig.size`.

Cell values are:

- `0` for an empty cell;
- powers of two (`2`, `4`, `8`, `16`, ...) for tiles.

Persisted state validation rejects malformed dimensions, negative values, non-power-of-two tile values, and values outside supported bounds.

## New game creation

`GameEngine.createGame()`:

1. creates an empty square board using the configured size;
2. initializes `GameState` with the supplied lifetime/display best score;
3. stores the engine's current deterministic RNG state in the game state;
4. spawns one tile;
5. spawns a second tile;
6. returns the initialized state.

When `GameConfig.seed` is present, the default random source is initialized from that seed. Without a configured seed, a fresh engine uses the current microsecond timestamp as its initial seed.

## Move algorithm

For a requested direction, each affected row or column is read in **movement order**. For example, a right move reads a row in reverse so the same collapse algorithm can be reused.

Each line then follows this sequence:

1. remove zero cells;
2. scan from the movement edge inward;
3. when two adjacent values are equal, replace them with one tile of double value;
4. skip the second source tile after a merge;
5. add the merged tile value to score gain;
6. increment merge count;
7. append remaining unmerged values;
8. pad the output with zeros to the configured board size;
9. write the line back in the requested board direction.

### One merge per source tile

A tile created by a merge cannot merge again during the same move because both source entries are consumed and the scan advances past them.

Example moving left:

```text
[2, 2, 4, 0] -> [4, 4, 0, 0]
```

It does **not** become `[8, 0, 0, 0]` in that same move.

Similarly:

```text
[2, 2, 2, 2] -> [4, 4, 0, 0]
```

not `[8, 0, 0, 0]`.

## Valid and invalid moves

Before transformation, the engine records a board signature. After all lines are written, it compares the new signature.

If the board did not change:

- `changed` is false;
- score gain is zero;
- merge count is zero;
- move count does not increase;
- no new tile is spawned;
- RNG state is not consumed for a spawn;
- terminal status is still refreshed.

If the board changed:

- calculated score gain is added to score;
- game-local best score is raised if necessary;
- valid move count increments by one;
- total merge count increases;
- exactly one new tile is spawned if an empty cell is available;
- terminal status is refreshed;
- a `MoveOutcome` reports `changed`, `scoreGain`, and `merges`.

## Tile spawning

`spawnTile()` collects every empty coordinate in row-major order. It restores the random source from `GameState.rngState`, chooses one empty coordinate, then chooses a tile value:

```text
2: 90%
4: 10%
```

After both random choices, the updated random-source state is written back to `GameState.rngState`.

This state handoff is what makes save/resume and Undo deterministic rather than restoring only the visible board.

## Deterministic RNG invariant

The current pseudo-random state is part of every normal game snapshot. Therefore a restored snapshot can continue the same deterministic spawn sequence as it would have before restoration.

Features that inspect possible moves, such as Hint and Replay, must not consume the player's RNG state.

## Move availability and game over

`canMove()` returns true if either:

- any empty cell exists; or
- any horizontally adjacent pair is equal; or
- any vertically adjacent pair is equal.

If none of those conditions is true, the game is lost.

## Target wins

`refreshStatus()` compares `highestTile` with the configured target.

For normal target-based modes, reaching or exceeding the target sets status to `won` until the win has been explicitly acknowledged.

The engine blocks further `move()` calls while status is not `playing`. This prevents a player from mutating the board behind an unresolved win/game-over flow.

After the player chooses Continue, `hasAcknowledgedWin` is persisted and the session can continue without counting the same win repeatedly.

## Endless and Zen

Endless and Zen treat the configured target as nominal. Reaching it does not interrupt play. These modes continue until there is no legal move.

## Move Limit

When `moveLimit` is present, the state becomes lost when:

```text
moves >= moveLimit
```

and the target has not been reached.

Only valid board-changing moves increment `moves`, so rejected/no-change input does not consume the move budget.

The built-in Move Limit preset uses 250 valid moves.

## Time Challenge

When `timeLimitSeconds` is present, elapsed time is calculated as:

```text
(now or DateTime.now()) - state.startedAt
```

If elapsed whole seconds reach the configured limit before the target is reached, status becomes lost.

`refreshStatus()` accepts an optional `now` parameter so time-limit behavior can be tested deterministically. The built-in Time Challenge preset uses 180 seconds.

Because `startedAt` is persisted, closing/reopening the app does not reset the timer. Controller initialization reconciles a restored challenge before the stale state is offered for continuation.

## Terminal-state precedence

Current status refresh order is:

1. unacknowledged target win for non-Endless/non-Zen mode;
2. move-limit loss when target has not been reached;
3. time-limit loss when target has not been reached;
4. no-legal-move loss;
5. otherwise playing.

This means reaching the configured target wins before an over-limit check can mark the same state lost.

## Hint behavior

`GameEngine.hint()` returns null for non-playing states. For a live state, it delegates to `HintSolver`.

The current solver is a deterministic **heuristic**, not the old first-legal-direction implementation and not a machine-learning model. It simulates legal directions on copied board data and scores them using mobility/empty cells, merge opportunity/value, highest-tile corner placement, monotonicity, smoothness, and deterministic tie-breaking.

A normal hint is read-only:

- it does not mutate the board;
- it does not change score or move count;
- it does not add Undo history;
- it does not alter statistics or achievements;
- it does not consume RNG state.

See [`HINT_SOLVER.md`](HINT_SOLVER.md) for the algorithm boundary and the isolated Auto Play Demo that reuses the same recommendation logic in its own sandbox.

## Controller responsibilities outside the pure engine

`GameEngine` intentionally does not own:

- `SharedPreferences` persistence;
- lifetime statistics;
- achievement unlocks;
- Daily history;
- route/dialog UI;
- imported-game ranking policy;
- replacement confirmation;
- external links.

Those responsibilities live in higher layers. This keeps engine tests focused and prevents UI concerns from changing rule semantics.

## Portable backup relationship

A portable backup embeds a strictly validated `GameState`. Import creates a normal engine for that configuration and calls `refreshStatus()` so a stale embedded status cannot bypass current engine rules.

However, imported sessions are marked **unranked** by `AppController`. The engine still moves the board normally, while the controller prevents imported progress from updating trusted lifetime records. See [`BACKUP_AND_RESTORE.md`](BACKUP_AND_RESTORE.md).

## Replay relationship

Move Replay never asks the engine to reproduce historical moves. It renders defensive snapshots from the current game and validated retained Undo history. This avoids guessing missing spawn events and keeps replay read-only.

## Core regression expectations

Any engine-related change should keep tests for at least:

- all four directions;
- compression with zeros;
- one merge per source tile;
- multiple independent merges;
- score gain and merge count;
- invalid move no-spawn/no-move-count behavior;
- deterministic spawn/RNG restoration;
- target win and movement blocking;
- game over;
- move-limit expiry;
- deterministic time-limit expiry;
- Endless/Zen target continuation;
- hint immutability and terminal suppression;
- serialization/deserialization invariants when state shape changes.

The broader suite and current automated evidence are documented in [`TESTING.md`](TESTING.md) and [`VERIFICATION.md`](VERIFICATION.md).
