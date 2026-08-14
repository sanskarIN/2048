# Hint Solver

2048 Nova keeps the hint system deterministic, local, and independent of UI code.

## Scope

`lib/domain/hint_solver.dart` evaluates every legal board-changing direction without spawning a tile or mutating the live board. The highest-scoring direction is returned to the game screen as a suggestion only.

Normal player hints never:

- move tiles automatically;
- change score, moves, undo history, RNG state, statistics, or achievements;
- run on won or lost games;
- require network access.

## Evaluation signals

The current lightweight heuristic combines:

1. **Empty cells** — strongly rewards moves that preserve board mobility.
2. **Immediate merge value** — rewards useful legal merges.
3. **Highest-tile corner position** — encourages stable corner-oriented play.
4. **Monotonicity** — penalizes rows and columns that repeatedly reverse value direction.
5. **Smoothness** — penalizes large exponent jumps between neighboring non-empty tiles.
6. **Stable tie bias** — provides deterministic ordering when otherwise-equivalent moves score equally.

Tile magnitudes are compared by powers-of-two exponents rather than raw values where positional shape is more important than absolute magnitude.

## Determinism and safety

The solver simulates board compression and classic one-merge-per-source-tile rules on copied lists. It does not consume the game RNG, so requesting a hint cannot change the next spawned tile.

The implementation supports every configured board dimension, including 3×3, 4×4, 5×5, and 6×6 modes.

## Solver Demo / Auto Play

`lib/domain/autoplay_session.dart` wraps the existing deterministic `GameEngine` and hint solver in an isolated sandbox for the optional Solver Demo. The demo uses a fixed seeded Endless 4×4 session by default and repeatedly applies the recommended legal direction.

`lib/features/solver_demo/solver_demo_screen.dart` provides:

- Auto Play start/pause/resume;
- single-step execution;
- speed selection;
- deterministic seed reset;
- demo-only score, move, highest-tile, and last-direction metrics;
- the same responsive/accessibility-aware board renderer used by normal gameplay.

The demo deliberately does **not** use `AppController.newGame`, `AppController.move`, player persistence, lifetime statistics, achievements, or Daily Challenge history. Its state exists only inside the demo screen/session. This separation prevents demonstration moves from being confused with legitimate player results.

Reset recreates the engine from the original seed, so the same deterministic solver and seed reproduce the same starting board and recommendation sequence unless the solver itself is intentionally changed in a future version.

The Solver Demo is a heuristic demonstration, not a claim of optimal AI play, machine learning, or guaranteed 2048 completion.

## Testing

Regression coverage verifies:

- no recommendation when no board-changing move exists;
- preference for preserving a high tile in a corner in a representative merge position;
- input-board immutability;
- support for larger configured boards;
- terminal game states do not expose hints through `GameEngine`;
- resetting an autoplay session reproduces its starting board/RNG state;
- equal seeds produce equal autoplay direction/board/score/RNG sequences;
- demo stepping remains isolated from player game/statistics state;
- demo UI can step, reset, autoplay, and pause without continuing in the background.

The current solver remains intentionally lightweight. A future expectimax or other advanced solver can be added behind the same isolated demonstration boundary only if it preserves deterministic tests, performance, accessibility, and player-data separation.
