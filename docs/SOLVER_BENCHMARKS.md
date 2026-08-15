# Solver Strategies and Benchmarks

2048 Nova keeps automated solving strictly inside the isolated **Auto Play Demo**. Normal player Hint remains the existing fast deterministic heuristic.

## Strategies

### Heuristic

The heuristic strategy is the original Auto Play behavior. It evaluates each legal board-changing direction using local board-shape signals such as empty cells, merge value, monotonicity, smoothness, and highest-tile corner placement.

Properties:

- deterministic;
- very fast;
- no look-ahead spawn tree;
- no live-game RNG consumption;
- also used by normal read-only Hint.

### Expectimax

`lib/domain/expectimax_solver.dart` adds a bounded expectimax strategy for the Auto Play sandbox.

At player nodes the solver chooses the highest-valued legal move. At chance nodes it enumerates every currently empty cell and evaluates both supported spawn outcomes:

- tile `2` with probability `0.9`;
- tile `4` with probability `0.1`.

The expected value of those chance outcomes is fed into the next player level. Leaf boards reuse shape-oriented evaluation signals so search still rewards mobility, smooth structure, monotonicity, and stable high-tile placement.

## Search bounds

The default solver uses:

```text
searchDepth = 2
maxNodes = 50000
```

Both limits are intentional product safeguards. Expectimax branching grows rapidly as empty-cell count and search depth increase. The node budget provides deterministic early fallback to board evaluation rather than allowing the demo to monopolize a slow device indefinitely.

The node counter is exposed in the Auto Play Demo after an expectimax decision so performance cost is visible instead of hidden.

## Determinism

Expectimax does not call the game RNG while evaluating candidate moves. It copies the supplied board, inserts hypothetical `2`/`4` tiles at chance nodes, and scores those copies only.

For a fixed board, solver configuration, and code version:

- the selected direction is deterministic;
- the expected value is deterministic;
- the explored-node count is deterministic;
- the supplied board is unchanged.

When the selected move is finally applied by `AutoplaySession`, only the sandbox `GameEngine` consumes its own seeded RNG to create the real next tile.

## Player-data boundary

The advanced strategy does not use `AppController.newGame`, `AppController.move`, LocalStore player saves, statistics, achievements, Daily Challenge history, or imported-backup state.

Changing strategy in the Auto Play Demo:

- pauses automatic stepping;
- keeps the current sandbox board;
- keeps the current sandbox score/move count;
- keeps the sandbox RNG state;
- clears only previous decision diagnostics;
- cannot change trusted player records.

Reset Seed recreates the same deterministic sandbox opening while retaining the selected strategy.

## Benchmark library

`lib/domain/solver_benchmark.dart` provides a reusable seeded benchmark runner.

A benchmark accepts:

- one `AutoplayStrategy`;
- a non-empty list of deterministic seeds;
- a positive per-seed move budget.

It returns per-seed results plus summary metrics:

- score;
- moves completed;
- highest tile;
- total expectimax nodes explored;
- average score;
- average moves;
- peak tile;
- average decision-node count.

The benchmark library uses only `AutoplaySession`, so it has the same isolation guarantees as Auto Play Demo.

## Command-line harness

Run the default comparison with:

```bash
dart run tool/solver_benchmark.dart
```

The default suite uses these fixed seeds:

```text
2048
4096
8192
20260815
```

and a 200-move budget for each seed and each strategy.

To use a different positive move budget:

```bash
dart run tool/solver_benchmark.dart 500
```

The tool prints each seeded result and aggregate metrics for Heuristic and Expectimax.

## Benchmark interpretation

The harness is designed for **repeatability and regression comparison**, not for claiming that one strategy is universally optimal.

A higher score in a small fixed-seed sample does not prove optimal 2048 play. Search quality and runtime depend on board state, depth, node budget, evaluation weights, and the selected seed set. Benchmark changes should therefore be reviewed together with deterministic tests and runtime cost.

## Regression coverage

Phase 18 tests verify that:

- expectimax recommendations are deterministic;
- recommended moves are legal;
- terminal/no-move boards return no direction;
- solver evaluation never mutates its input board;
- node exploration never exceeds the configured budget;
- larger board sizes are supported;
- malformed board dimensions are rejected;
- strategy switching leaves sandbox board/RNG state untouched;
- equal seeded expectimax sessions reproduce equal move/board/score/RNG/diagnostic sequences;
- expectimax exposes finite bounded decision diagnostics;
- reset retains strategy while restoring deterministic seed state;
- benchmark summaries are deterministic;
- heuristic benchmark runs report zero expectimax-node work;
- benchmark input validation rejects empty seed sets and invalid move budgets;
- UI strategy selection remains isolated from trusted app game/statistics state.

## Non-goals

This feature is not:

- machine learning;
- an online AI service;
- a guarantee of reaching 2048;
- a replacement for normal Hint;
- a competitive leaderboard or anti-cheat system;
- allowed to write player statistics or achievements.

Future solver work should remain behind this sandbox boundary and must preserve deterministic tests, explicit resource limits, accessibility, localization, and offline behavior.
