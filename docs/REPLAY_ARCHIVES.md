# Full Replay Archives

2048 Nova supports two deliberately different replay systems:

1. **Move Replay** is the lightweight read-only viewer backed by the current game plus the bounded retained Undo history. It is available for legacy/restored sessions but may show only the most recent retained history.
2. **Full Replay Archive** records compact deterministic actions from the beginning of a newly started local session. A complete capture can be copied as portable JSON and opened later as a spectator-only replay without replacing the live game.

The two systems share the same core game rules but have different storage and portability goals.

## Design goals

The full-session format is designed to be:

- offline and account-free;
- deterministic rather than video-based;
- compact compared with storing a full board snapshot for every move;
- strictly validated before playback;
- bounded so an unusually long session cannot create an unlimited local history;
- spectator-only when imported;
- isolated from trusted player statistics, achievements, streaks, per-mode records, and Daily Challenge history.

It is not a signed competitive replay, anti-cheat proof, cloud sync format, or authentication mechanism.

## Archive envelope

The portable JSON envelope uses:

```text
format: nova2048.fullReplay
version: 1
exportedAt: ISO-8601 timestamp
capture: replay capture object
```

`ReplayArchive.decode` rejects an empty document, malformed JSON, unsupported format/version, invalid export timestamp, missing capture, incomplete capture, oversized text, invalid event data, or any action sequence that cannot be deterministically reconstructed.

The current encoded text limit is **1,000,000 characters**.

## Capture model

A capture contains:

- a validated copied `GameState` representing the beginning of the recorded range;
- `startsAtSessionStart`;
- `overflowed`;
- a bounded ordered list of replay events.

A true portable full-session export requires:

```text
startsAtSessionStart = true
overflowed = false
```

For a capture marked as beginning at session start, the initial state must represent a fresh playable session: zero moves, zero score, zero merges, playing status, and no acknowledged win. The opening board and deterministic RNG state are retained in the initial `GameState`.

## Replay events

Version 1 supports four event kinds:

### `move`

Stores:

- direction (`up`, `down`, `left`, or `right`);
- elapsed milliseconds from the session start.

During reconstruction, `GameEngine.move` receives the recorded replay time. This matters for timed modes because status checks must use the original event timeline rather than the spectator device's current wall clock.

A recorded move must actually change the reconstructed board. A no-op, terminal-state move, or otherwise impossible move invalidates the archive.

### `undo`

Rewinds to the immediately preceding valid move snapshot inside the replay player's private Undo stack. An Undo with no available replay move is invalid.

This is separate from the app's persisted 50-snapshot Undo retention. A valid full-session replay can therefore reconstruct earlier actions even after those snapshots are no longer retained by normal gameplay Undo storage.

### `continueAfterWin`

Represents the player's explicit choice to continue after reaching a non-Endless target. It is valid only when the reconstructed state is currently won and has not already acknowledged that win.

### `statusRefresh`

Records a status transition produced without a board-changing move, primarily deterministic timed-challenge expiry. The recorded timestamp is supplied to `GameEngine.refreshStatus`. A status-refresh event that does not actually change status is rejected as redundant/invalid.

## Deterministic timing

Replay events store **elapsed milliseconds**, not a new independent absolute timestamp for each action.

The spectator reconstructs event time as:

```text
initialState.startedAt + event.elapsedMilliseconds
```

Recorded elapsed times must be non-negative and nondecreasing. They are bounded to 365 days. This prevents replay playback from depending on the current clock while also keeping serialized values within an explicit validation range.

The engine's ordinary callers remain compatible because `GameEngine.move(..., now:)` is optional. Normal gameplay still uses the current clock when no explicit time is supplied.

## Bounded capture policy

Full replay capture is intentionally limited to:

```text
4096 events per session
```

When a session exceeds that limit:

- the capture is marked `overflowed`;
- additional full-session events are no longer recorded;
- the normal game continues normally;
- normal save/Undo/statistics behavior is unaffected;
- portable full-session export is disabled.

The app does **not** silently export a truncated archive as though it represented the complete session.

This preserves the repository's rule that growing local histories remain bounded.

## Legacy and restored sessions

A session can be playable even when its earlier replay actions are unavailable. Examples include:

- a game saved before full-session replay capture existed;
- a portable Game Backup restored partway through a game;
- recovered/corrupt replay metadata where the current game itself remains valid.

2048 Nova creates an **incomplete** replay capture for those sessions. It can continue maintaining safe local replay metadata, but it is not advertised or exported as a true full-session archive.

Starting a fresh new game creates a complete capture from that new session's opening state.

## Persistence

The current in-progress capture uses the project-owned SharedPreferences key:

```text
nova.replay_capture.v1
```

The capture is saved alongside current-game persistence and is cleared with the current game or with Clear All Data.

Malformed replay-capture persistence is removed safely. A stored capture must belong to the active session and pass deterministic reconstruction checks before the controller accepts it as the current capture. Otherwise the current valid game is preserved and replay capture falls back to an incomplete local capture instead of trusting mismatched replay metadata.

## Portable export

The Full Replay Archive screen enables **Copy full replay** only when the active capture begins at the session start and has not overflowed.

Before encoding, the complete event sequence is reconstructed again. This prevents an internally inconsistent event list from being exported merely because its flags claim it is complete.

The archive contains replay/session data and should be treated as shareable user-generated text. It is not encrypted.

## Import and spectator isolation

A portable replay archive is never restored through `AppController.importGameBackup` and never replaces the active player game.

The Full Replay Archive workspace:

- reads archive text only after an explicit clipboard/manual-entry action;
- validates the envelope, initial state, events, event order, action legality, and deterministic reconstruction;
- builds defensive spectator frames in memory;
- allows scrubbing, stepping, play/pause, and 1/2/4-frame-per-second viewing;
- leaves the live `AppController.game` untouched;
- does not write imported replay data into player statistics or trusted local progress.

Imported spectator replay frames are not promoted to current game progress, Game Backup progress, Daily Challenge history, achievements, lifetime bests, per-mode records, or streaks.

## Clipboard boundary

Like Challenge Codes and Game Backup, replay clipboard access is explicit. The app does not continuously inspect clipboard contents.

- **Copy full replay** writes only after the user chooses the action.
- **Open from clipboard** reads only after the user chooses the action.
- **Enter replay text** provides a manual alternative when clipboard access is unavailable or undesirable.

Actual OS/browser clipboard permission behavior remains a manual platform qualification item.

## Privacy and networking

Full Replay Archive uses no project server, analytics service, remote AI, account, or cloud database. Encoding, decoding, validation, and playback occur locally.

The archive can reveal the game's configuration, starting state, deterministic RNG state, move directions, action timing, score evolution, and board evolution. Users should share replay text only when they are comfortable sharing that gameplay information.

## Integrity and trust boundary

The archive's validation establishes structural and deterministic consistency, not authorship.

Because JSON text is user-editable, a technically skilled person can construct a different valid replay sequence. Therefore:

- an imported replay is evidence only of a self-consistent spectator sequence;
- it is **not** proof that a particular player produced that sequence;
- it is never accepted as trusted lifetime progress;
- it cannot improve statistics, achievements, Daily records, streaks, or per-mode records.

A future competitive authenticity scheme would require a separate signed/trusted design and is outside version 1.

## Failure behavior

Invalid archives fail closed. Examples include:

- unknown event kind;
- missing/unsupported move direction;
- fractional or out-of-range event time;
- events out of chronological order;
- move that does not change the board;
- Undo with no private replay history;
- continue-after-win from a non-won state;
- status refresh that causes no transition;
- malformed initial state/configuration;
- too many events;
- incomplete or overflowed capture presented as portable full-session data.

Opening a rejected archive does not replace or clear the current live game.

## Manual release checks

Automated tests and hosted builds do not replace real-environment qualification. Before stable release, manually check representative platforms for:

- large replay clipboard copy/paste;
- manual text entry and validation feedback;
- imported replay scrub/step/play/pause controls;
- navigation between Move Replay and Full Replay Archive;
- large text and narrow layouts;
- TalkBack, VoiceOver, Narrator, and browser screen-reader announcements;
- 1/2/4-frame-per-second timer cleanup when navigating away/backgrounding;
- responsiveness on slower devices with long but valid captures;
- behavior near the 4096-event safety boundary.
