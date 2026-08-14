# Game Engine Rules

For every move, each row or column is read in movement order, zeros are removed, adjacent equal values merge once, and zeros are padded back to board size. A tile created by a merge cannot merge again during the same move.

A random tile is spawned only when the board signature actually changes. The spawn value is 2 with 90% probability and 4 otherwise.

`RandomSource` makes spawning deterministic. The current RNG state is stored in `GameState`, so save/resume and undo can continue from the correct deterministic random sequence.

The engine reports whether a move changed the board, score gain, and merge count. It then refreshes win/loss state, move-limit rules, and time-challenge expiry. Endless and Zen modes do not stop at the nominal target.

The hint system deliberately remains lightweight: it checks preferred directions and returns the first direction that changes the board. It is not presented as an optimal solver.
