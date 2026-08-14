# Hint Solver

2048 Nova keeps the hint system deterministic, local, and independent of UI code.

## Scope

`lib/domain/hint_solver.dart` evaluates every legal board-changing direction without spawning a tile or mutating the live board. The highest-scoring direction is returned to the game screen as a suggestion only.

Hints never:

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

## Testing

Regression coverage verifies:

- no recommendation when no board-changing move exists;
- preference for preserving a high tile in a corner in a representative merge position;
- input-board immutability;
- support for larger configured boards;
- terminal game states do not expose hints through `GameEngine`.

This solver is intentionally a lightweight heuristic, not an expectimax AI or guarantee of optimal play. A future AI demonstration mode should remain separate from player statistics and achievements.
