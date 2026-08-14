# Frequently Asked Questions

## Is 2048 Nova the original official 2048 app?

No. 2048 Nova is an independent open-source Flutter implementation of the familiar 2048 puzzle rules. The repository does not claim to be the original official 2048 application and does not bundle proprietary third-party 2048 artwork.

## Is the project free and open source?

Yes. The repository is released under the MIT License. You may use, study, modify, and redistribute it subject to the license terms.

## Does the game need internet access?

Core gameplay does not require a project server. Save/resume, Daily Challenge generation, Hint, Auto Play Demo, Move Replay, statistics, achievements, and Game Backup work locally.

Network/platform handlers are used only when you explicitly open an external destination such as GitHub, LinkedIn, email, or Buy Me a Coffee.

## Does the app contain ads, analytics, or an account system?

The default repository does not include an advertising SDK, analytics tracker, account backend, or cloud-sync service.

## Which platforms are configured?

The repository contains Flutter runners for Android, iOS, Web/PWA, Windows, macOS, and Linux.

Configured does not automatically mean store-ready. See [`PLATFORMS.md`](PLATFORMS.md) and [`RELEASE_CHECKLIST.md`](RELEASE_CHECKLIST.md) for build/signing/manual qualification boundaries.

## Which game modes are available?

There are ten built-in modes:

1. Classic 4×4
2. Quick 3×3
3. Extended 5×5
4. Challenge 6×6
5. Endless
6. Target
7. Time Challenge
8. Move Limit
9. Daily Challenge
10. Zen

See [`GAME_MODES.md`](GAME_MODES.md) for exact targets and limits.

## How are new tiles generated?

A new tile appears only after a valid board-changing move. The current rule is 90% probability for a 2 and 10% for a 4.

The pseudo-random generator is deterministic and its state is saved with the game so save/resume and Undo can restore the expected sequence.

## Does an invalid swipe consume a move or spawn a tile?

No. If the board does not change, the game does not increment the valid-move count and does not spawn a new tile.

## Why didn’t `[2, 2, 4]` become `8` in one move?

Because each source tile may merge at most once during a move. Moving left produces `[4, 4, 0]`, not `[8, 0, 0]`.

## Can I continue after reaching 2048?

For target-based modes, the win flow pauses the board until you explicitly continue or choose another action. If you continue, the win is acknowledged so it is not counted again for the same run.

Endless and Zen do not stop at the nominal target.

## How many Undo steps are saved?

Undo history is capped at the latest 50 snapshots. This prevents unbounded local storage growth.

## Why doesn’t Undo reduce my lifetime best score or achievements?

Undo is a board/session operation. Lifetime records and already-earned achievements are treated as application progress and are not generally rolled back by returning to an earlier board.

## Why does Move Replay sometimes start after move zero?

Move Replay reuses the bounded retained Undo snapshots. If a game has more history than the 50-snapshot limit, the earliest moves are no longer available to reconstruct. The viewer intentionally discloses this instead of inventing missing frames.

## Can Move Replay change my live game?

No. Replay uses defensive copied snapshots and is spectator-only. Scrubbing or playback cannot move the live board, consume RNG, change score, alter Undo, update statistics/achievements, or write Daily results.

## Is the Hint an AI model?

No. The current Hint is a deterministic local heuristic. It evaluates legal moves using board mobility, immediate merges, corner placement, monotonicity, and smoothness.

It does not call a cloud AI service or download a model.

## Does requesting a Hint change the next random tile?

No. Hint evaluates copied board data and does not consume the player's RNG state.

## What is Auto Play Demo?

Auto Play Demo is a separate seeded in-memory sandbox that repeatedly uses the same heuristic recommendation logic for demonstration.

It can auto-play, pause, step, change speed, and reset the seed. It is not machine learning, is not guaranteed optimal, and cannot modify your current save, lifetime statistics, achievements, or Daily history.

## How is the Daily Challenge generated?

The Daily Challenge uses the current **UTC** calendar date as a numeric `YYYYMMDD` seed. Because it is generated locally, no server is needed to obtain the challenge.

## Why can Daily Challenge date differ from my local date near midnight?

Because the seed uses UTC, not local midnight. Time zones ahead of or behind UTC can temporarily have a different local calendar date.

## Can a weaker Daily replay overwrite my better result?

No. Local Daily history preserves the stronger score result, maximum highest tile, sticky completion/win state, and newest update timestamp.

## What is Game Backup?

Game Backup copies the **current game only** as versioned validated JSON to the system clipboard. It does not export settings, lifetime statistics, achievements, Daily history, or old Undo history.

## Is Game Backup encrypted?

No. The current portable format is plain JSON. Treat copied backup text as normal clipboard content and share it only when intended.

## Can someone edit a backup to fake records or achievements?

The text is user-editable, so the app deliberately does not trust it as ranked progress. Every imported backup is restored as an **unranked** session.

Imported play may continue/save/Undo normally but cannot update lifetime statistics, achievements, streaks, or Daily history.

## Does an imported game remain unranked after restarting the app?

Yes. The unranked status is stored locally in a project-owned marker separate from the imported game JSON.

## Can an imported backup overwrite my lifetime best score?

No. The embedded historical `bestScore` is not trusted as a lifetime record. The device's lifetime statistics remain authoritative.

## What happens to Undo when I import a backup?

The previous game's Undo history is cleared so snapshots from another session cannot attach to the imported board. New moves made after import can create new Undo snapshots for that same unranked session.

## What happens if backup text is malformed or too large?

Import is rejected. The app checks the maximum input size before parsing, validates envelope format/version/timestamp, and strictly validates the embedded `GameState`.

## Does Clear All erase other apps’ or unrelated preferences?

No. 2048 Nova removes only its own project-owned keys rather than calling a blanket SharedPreferences clear.

## What does Reset Statistics do while a normal game is active?

It clears historical statistics while keeping the active ranked game represented as the current post-reset session, so later win-rate/streak accounting remains coherent. Retained Undo snapshots are normalized so an old lifetime best cannot be resurrected by Undo.

An imported unranked session stays unranked after Reset Statistics.

## Is Time Challenge paused if I close the app?

No. The challenge uses the persisted start timestamp. Closing and reopening the application does not reset the 180-second limit.

## Which accessibility options are implemented?

The project includes positional board/tile semantic labels, keyboard controls, high contrast, reduced motion, visible numeric values rather than color-only state, responsive layout, and normal system text scaling support.

Automated semantics tests do not replace final TalkBack, VoiceOver, Narrator/browser-screen-reader, keyboard-only, and real-device qualification.

## Why can external links show a Copy fallback?

The app validates approved `https` and non-empty `mailto` destinations and asks the platform to open them. If no suitable platform handler is available, the app can offer to copy the destination rather than trying an unsafe alternative.

## Are Android and iOS store builds already signed?

No. CI verifies an Android release APK can compile and verifies iOS with `--no-codesign`. Production signing/provisioning and store packaging must use private platform credentials outside the public repository.

## Does passing CI mean there are zero bugs?

No. CI provides evidence for formatter, analyzer, automated tests, Web build, and configured native compilation. It cannot prove universal device compatibility or absence of every possible defect.

The project remains a `0.9.0+1` release candidate until the manual qualification in [`RELEASE_CHECKLIST.md`](RELEASE_CHECKLIST.md) is complete.

## Where can I report a bug?

Use the GitHub bug-report template:

https://github.com/sanskarIN/2048/issues/new?template=bug_report.yml

For security-sensitive reports, follow [`../SECURITY.md`](../SECURITY.md) instead of publishing exploit details.

## Where can I ask for support?

- Support: `supportramsandesh@gmail.com`
- Business: `sanskarin@outlook.in`
- Business: `sanskarin.business@gmail.com`
- Repository: https://github.com/sanskarIN/2048

Optional project support:

https://buymeacoffee.com/sanskarIN

**Made by the Sanskar**
