# Hint Solver

2048 Nova keeps all solver behavior deterministic, local, offline, and independent of trusted player state.

## Normal Hint scope

`lib/domain/hint_solver.dart` evaluates every legal board-changing direction without spawning a tile or mutating the live board. The highest-scoring direction is returned to the game screen as a suggestion only.

Normal player hints never:

- move tiles automatically;
- change score, moves, undo history, RNG state, statistics, or achievements;
- run on won or lost games;
- require network access;
- invoke the more expensive expectimax search.

The normal Hint path remains intentionally lightweight even after the advanced Auto Play solver expansion.

## Heuristic evaluation signals

The current lightweight heuristic combines:

1. **Empty cells** — strongly rewards moves that preserve board mobility.
2. **Immediate merge value** — rewards useful legal merges.
3. **Highest-tile corner position** — encourages stable corner-oriented play.
4. **Monotonicity** — penalizes rows and columns that repeatedly reverse value direction.
5. **Smoothness** — penalizes large exponent jumps between neighboring non-empty tiles.
6. **Stable tie bias** — provides deterministic ordering when otherwise-equivalent moves score equally.

Tile magnitudes are compared by powers-of-two exponents rather than raw values where positional shape is more important than absolute magnitude.

## Heuristic determinism and safety

The heuristic simulates board compression and classic one-merge-per-source-tile rules on copied lists. It does not consume the game RNG, so requesting a hint cannot change the next spawned tile.

The implementation supports configured board dimensions used by the project, including 3×3, 4×4, 5×5, and 6×6 modes.

## Auto Play Demo strategies

`lib/domain/autoplay_session.dart` wraps a seeded `GameEngine` in an isolated sandbox for Auto Play Demo. It now supports two deterministic strategies:

- `AutoplayStrategy.heuristic` — the original fast recommendation path;
- `AutoplayStrategy.expectimax` — the bounded look-ahead path from `lib/domain/expectimax_solver.dart`.

Heuristic remains the default for backward compatibility.

Changing strategy does not reset the sandbox board, score, move count, or RNG state. Automatic playback pauses on a strategy change so the user can see that the decision policy changed before the next step.

Reset Seed recreates the original deterministic opening while retaining the currently selected strategy.

## Bounded expectimax

The expectimax solver models two kinds of nodes:

- **player nodes** choose the highest-value legal board-changing direction;
- **chance nodes** enumerate every empty cell and both supported spawn values using the real game probabilities: 90% for tile `2` and 10% for tile `4`.

The default search is bounded to depth 2 and at most 50,000 explored nodes. When the budget is exhausted, the solver falls back to deterministic leaf evaluation rather than continuing unbounded work.

The solver never mutates the supplied board and never consumes the sandbox or live-game RNG while exploring hypothetical spawns.

## Auto Play Demo UI

`lib/features/solver_demo/solver_demo_screen.dart` provides:

- Auto Play start/pause/resume;
- single-step execution;
- speed selection;
- Heuristic/Expectimax strategy selection;
- deterministic seed reset;
- demo-only score, move, highest-tile, and last-direction metrics;
- visible selected strategy;
- expectimax explored-node diagnostics;
- the same responsive/accessibility-aware board renderer used by normal gameplay.

The explanatory UI explicitly states that normal Hint remains heuristic and that both solver strategies run only in the sandbox.

## Player-data isolation

The demo deliberately does **not** use `AppController.newGame`, `AppController.move`, player persistence, lifetime statistics, achievements, or Daily Challenge history. Its state exists only inside the demo screen/session.

This separation prevents demonstration moves from being confused with legitimate player results. Expectimax receives only a copied sandbox board for decision making; it is not allowed to import trusted player progress or write ranking state.

## Benchmark suite

`lib/domain/solver_benchmark.dart` provides a reusable deterministic benchmark runner over fixed seeded sandbox sessions. `tool/solver_benchmark.dart` is the CLI entry point.

Default command:

```bash
dart run tool/solver_benchmark.dart
```

Custom per-seed move budget example:

```bash
dart run tool/solver_benchmark.dart 500
```

The benchmark reports per-seed score, moves, highest tile, explored nodes, and aggregate averages. It is intended for reproducible regression comparison, not as proof that a strategy is globally optimal.

See [`SOLVER_BENCHMARKS.md`](SOLVER_BENCHMARKS.md) for the detailed search, resource-limit, benchmark, and interpretation contract.

## Testing

Regression coverage verifies:

- no heuristic recommendation when no board-changing move exists;
- representative corner-preserving heuristic behavior;
- heuristic input-board immutability;
- heuristic support for larger configured boards;
- terminal game states do not expose normal hints through `GameEngine`;
- expectimax recommendations are deterministic and legal;
- expectimax input-board immutability;
- expectimax no-move behavior;
- expectimax node-budget enforcement;
- expectimax larger-board support and malformed-board rejection;
- switching strategies does not mutate sandbox board/RNG state;
- matching seeded expectimax sessions reproduce matching sequences and diagnostics;
- reset retains the selected strategy while restoring deterministic seed state;
- benchmark results are deterministic for fixed seeds;
- heuristic benchmarks report zero expectimax-node work;
- benchmark validation rejects invalid input;
- demo stepping, strategy selection, reset, autoplay, and pause remain isolated from player state.

Neither solver is described as machine learning or guaranteed optimal play.
