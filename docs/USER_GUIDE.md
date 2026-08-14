# 2048 Nova User Guide

This guide explains how to play and use the player-facing features of 2048 Nova. For developer internals, start with [`README.md`](README.md) in this docs directory and [`ARCHITECTURE.md`](ARCHITECTURE.md).

## Goal of 2048

Move all tiles on the board in one direction at a time. When two adjacent tiles with the same value collide in the movement direction, they merge into one tile worth double the value.

Examples:

```text
2 + 2 = 4
4 + 4 = 8
8 + 8 = 16
```

Each merged tile value is added to the game score.

A source tile can merge only once in a move. For example:

```text
2 2 4 0  ->  4 4 0 0
```

not `8 0 0 0` in one move.

After a valid move that changes the board, one new tile appears. A new tile is normally 2 and occasionally 4.

## Starting a game

From Home:

- choose **New Game** to select a mode;
- choose **Daily Challenge** for the current date-derived challenge;
- choose **Continue Game** when a recoverable local game exists;
- choose **Continue Unranked Backup** when the current recoverable game came from portable restore.

Starting a new game while a recoverable game exists requires confirmation so the saved board is not replaced silently.

## Controls

### Touch

Swipe up, down, left, or right across the game area.

Very small/slow gestures are ignored so accidental touches are less likely to trigger movement.

### Keyboard

| Key | Action |
| --- | --- |
| Arrow Up / W | Move up |
| Arrow Down / S | Move down |
| Arrow Left / A | Move left |
| Arrow Right / D | Move right |
| H | Hint |
| U | Undo |
| P / Escape | Pause menu |
| R | Restart |

Buttons for Hint, Undo, Pause, and Restart are also available in the game screen.

## Score and metrics

The game screen shows:

- **Score** — total score earned in the current game;
- **Best** — current local best display value associated with the session/lifetime record policy;
- **Moves** — valid board-changing moves made;
- **Highest** — largest current tile.

Challenge modes can also show:

- **Moves left** for Move Limit;
- **Seconds left** for Time Challenge.

## Winning and continuing

For normal target-based modes, reaching the target shows a win flow and movement pauses until you explicitly choose what to do. If you continue beyond the target, the win is acknowledged so the same target is not counted repeatedly.

Endless and Zen do not interrupt at the nominal target.

A game is over when no legal move remains, or when a challenge limit expires before its target is reached.

## Undo

Undo restores the most recent retained game snapshot, including deterministic RNG state. This means the restored state is more than a visual board copy.

Undo is bounded to the most recent 50 snapshots. Very old moves eventually fall outside the retained history.

Lifetime records/achievements are not generally rolled back by Undo. The app treats those as application progress, while Undo is a board/session tool.

Imported unranked sessions can create/use Undo after restore, but remain unranked.

## Hint

Hint suggests a legal direction using a deterministic local heuristic. It looks at factors such as:

- board mobility/empty spaces;
- immediate merge value;
- keeping the highest tile in a corner;
- monotonic tile ordering;
- smoothness between neighboring values.

A normal Hint does not move tiles, use up an Undo, change score, alter statistics, or consume the game's RNG.

The heuristic is useful guidance, not a promise of an optimal move.

## Pause menu

Pause opens explicit actions such as Resume, Settings, or Home. Timed challenge rules are based on persisted elapsed time, so leaving the screen/application does not grant extra challenge time.

## Restart

Restart begins the current mode again. When **Confirm restart** is enabled in Settings, the application asks before replacing the current game.

## Game modes

2048 Nova includes ten built-in modes:

- Classic 4×4;
- Quick 3×3;
- Extended 5×5;
- Challenge 6×6;
- Endless;
- Target;
- Time Challenge;
- Move Limit;
- Daily Challenge;
- Zen.

See [`GAME_MODES.md`](GAME_MODES.md) for exact targets/limits.

## Target mode

Target mode lets you choose:

- 128
- 256
- 512
- 1024
- 2048
- 4096
- 8192
- 16384

Higher targets generally require more careful board organization and longer sessions.

## Daily Challenge

Daily Challenge is generated locally from the UTC date. It works without a game server.

Recent local Daily history keeps score/move information, highest tile, completion, and win status. A weaker replay does not erase a stronger saved result, and completion/win flags are sticky.

## Move Replay

When a current game exists, Home can show **Move Replay**.

Replay is a read-only spectator view of the current game plus still-retained Undo snapshots. You can:

- go to the first retained frame;
- move backward/forward;
- jump to latest;
- scrub with the frame slider;
- play/pause automatically;
- choose 1, 2, or 4 frames per second.

Replay cannot change your live game, statistics, achievements, RNG, or Daily record.

Because Undo history is capped, a long game's replay may begin later than move zero.

## Auto Play Demo

**Auto Play Demo** is a separate deterministic sandbox used to demonstrate the heuristic automatically.

It offers:

- one-step execution;
- Auto Play;
- Pause;
- 1/2/4 moves per second;
- deterministic seed reset;
- demo-only score/move/highest metrics.

It is not your saved game. It cannot update lifetime records, achievements, Daily history, or replace your current save.

It is a local heuristic demonstration, not machine learning and not guaranteed optimal play.

## Game Backup

Home includes **Game Backup**.

### Export

Choose **Copy game backup** to copy the current game as validated JSON to the clipboard.

Only the current game is included. Settings, lifetime statistics, achievements, Daily history, and Undo history are not exported.

### Import

Choose **Import from clipboard**. The app validates the text and shows a preview/confirmation before replacing the current game.

Every imported game becomes **unranked**. You can play/save/Undo it, but it cannot increase trusted lifetime statistics, achievements, streaks, or Daily history.

See [`BACKUP_AND_RESTORE.md`](BACKUP_AND_RESTORE.md).

## Statistics

The Statistics screen tracks local ranked-player information such as:

- games played;
- games won;
- win rate;
- best score;
- highest tile;
- total moves;
- total merges;
- average moves/merges;
- current streak;
- best streak.

Imported backup play and Auto Play Demo do not inflate these records.

## Achievements

Achievements track local milestones such as first merge, high tiles, score thresholds, wins, and Daily wins. The screen shows progress and stored unlock dates.

Reset Achievements clears local unlock timestamps. Imported unranked play cannot unlock achievements.

## Settings

### Appearance

Choose:

- Light / Dark / System brightness;
- Classic Nova;
- Midnight;
- Neon;
- Ocean;
- Forest;
- Sunset;
- Monochrome.

### Accessibility/presentation

- High contrast;
- Reduced motion.

Reduced motion also respects the platform's disabled-animation preference where implemented.

### Feedback

- Sound on/off;
- Haptics on/off.

These controls depend on platform support.

### Gameplay

- Confirm restart on/off.

### Data controls

Settings provides explicit controls to:

- reset current game;
- reset statistics;
- reset achievements;
- clear all 2048 Nova local data.

Complete reset removes project-owned data only.

## Accessibility

The game board exposes board-size semantics plus row/column/value-or-empty labels for cells. Exact numeric tile values are visible, so color is not the only way to understand the board.

Keyboard controls, high contrast, reduced motion, system text scaling, and responsive layout are also part of the accessibility foundation.

See [`ACCESSIBILITY.md`](ACCESSIBILITY.md) for implementation details and manual release checks.

## Privacy

Normal gameplay is offline-first. There is no default analytics, advertising, account, cloud-sync, or remote-AI service.

External network/platform handlers are used only after you explicitly open GitHub, LinkedIn, email, or Buy Me a Coffee.

Game Backup writes/reads clipboard text only after explicit backup actions.

See [`PRIVACY.md`](PRIVACY.md).

## Help and support

For common issues, see [`TROUBLESHOOTING.md`](TROUBLESHOOTING.md).

Project/support contacts:

- Repository: https://github.com/sanskarIN/2048
- Support: `supportramsandesh@gmail.com`
- Business: `sanskarin@outlook.in`
- Business: `sanskarin.business@gmail.com`

Optional project support:

https://buymeacoffee.com/sanskarIN

**Made by the Sanskar**
