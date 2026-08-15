# Current Game Backup and Restore

2048 Nova supports a portable backup for the **current game only** through either the clipboard or an explicit user-selected `.nova2048` / `.json` file. Both transports carry the same versioned JSON envelope. The feature is deliberately narrow: it lets a player carry or preserve one game state without importing lifetime records or treating externally supplied data as trusted ranked progress.

This is distinct from [`CHALLENGE_CODES.md`](CHALLENGE_CODES.md). A Challenge Code shares only a fresh-game configuration and deterministic seed; Game Backup shares actual board/session progress.

## What is exported

`GameBackup.encode()` serializes a JSON envelope containing:

```json
{
  "format": "2048-nova-game-backup",
  "version": 1,
  "exportedAt": "<UTC-compatible ISO-8601 timestamp>",
  "game": { "...": "validated GameState JSON" }
}
```

The embedded `game` object is the normal `GameState.toJson()` representation. It includes the information required to resume that board deterministically, including board cells, score, current best value stored with the game, move/merge counters, configuration, status, acknowledgement state, start time, and RNG state.

## What is intentionally excluded

The portable backup envelope does **not** contain:

- lifetime player statistics;
- achievements or unlock dates;
- settings or theme preferences;
- Daily Challenge history;
- Undo history;
- analytics or account data;
- credentials or secrets.

This separation is enforced by the codec shape and covered by automated tests.

## Export workflow

From Home, open **Game Backup**. A current game can be exported in either of two ways:

- **Copy game backup** encodes with `GameBackup.encode()` and writes the JSON text to the system clipboard.
- **Save backup file** encodes the same envelope to UTF-8 bytes and opens the explicit user-selected save flow through the file transport abstraction, proposing a UTC-stamped `.nova2048` filename.

Both flows leave the live player game unchanged. Cancelling a native Save dialog is a normal non-destructive outcome. On Web, the browser owns the download destination and the app does not require a returned filesystem path to treat the explicit download handoff as successful.

## Import workflow

Select **Import from clipboard** or **Import backup file**. Clipboard import reads text only after the explicit action. File import opens one user-selected `.nova2048` / `.json` file, rejects an oversized reported or actual byte length before full text processing, and requires strict UTF-8. Both transports then converge on the same flow:

1. reject missing/empty or invalid input;
2. check the maximum encoded text length before JSON parsing;
3. parse the envelope as JSON;
4. validate backup format and version;
5. validate export timestamp;
6. require an embedded game object;
7. pass the embedded object through strict `GameState.fromJson()` validation;
8. display a non-dismissible preview/confirmation dialog;
9. restore only after the player explicitly chooses **Restore unranked backup**.

Cancelling the picker or confirmation leaves the current ranked game untouched.

## Validation and size limit

Current constants in `lib/domain/game_backup.dart` are:

```text
format = 2048-nova-game-backup
version = 1
maxEncodedLength = 128 KiB
maxFileBytes = 512 KiB
```

Malformed JSON, wrong envelope type, unsupported format/version, invalid timestamps, missing game data, invalid board values, invalid dimensions, invalid counters, unsupported save schemas, and other invalid `GameState` fields are rejected rather than partially trusted.

The encoded-text size check happens before JSON parsing. File import adds a 512 KiB byte ceiling before UTF-8 conversion and checks the actual loaded byte length again before the existing 128 Ki-character protocol limit is applied. The filename and extension never bypass content validation.

## Unranked import policy

Every imported backup is restored as an **unranked session**. This is a permanent policy for that restored current-game session, including after an application restart.

While an imported unranked game is played:

- the board, score, move count, RNG state, save/resume, and new Undo snapshots continue normally;
- lifetime `gamesPlayed` is not incremented by the import;
- lifetime move and merge totals are not incremented;
- lifetime best score and highest tile are not raised by imported play;
- wins and streaks are not awarded;
- achievements are not unlocked by imported progress;
- Daily Challenge history is not created or changed, even if the imported configuration says `daily`;
- restored terminal states cannot award a local ranked win.

The Home screen identifies a resumable imported session as **Continue Unranked Backup**.

## Lifetime best-score handling

An imported JSON value is not trusted as proof of a lifetime record. When import occurs, the restored game's displayed `bestScore` is normalized to:

```text
max(imported current score, local lifetime best score)
```

The external backup's embedded historical `bestScore` cannot overwrite or inflate the player's local lifetime record.

## Undo policy

Import clears the previous current game's Undo history. This prevents snapshots from a ranked/local session being attached to an unrelated imported board.

Moves made **after** import can create Undo snapshots for the imported session. Those snapshots remain part of the unranked session and are subject to the same player-record isolation.

## Persistence of the unranked marker

`LocalStore` uses the project-owned key:

```text
nova.current_game_unranked.v1
```

The marker is read only when a current game exists. It is removed when:

- the current game is cleared;
- the current saved game is found corrupt and removed;
- all project-owned local data is cleared.

Starting a normal new game explicitly resets the marker to ranked/local behavior.

## Backup versus Challenge Codes

These portable-text features intentionally have different trust semantics:

| Property | Game Backup | Challenge Code |
| --- | --- | --- |
| Carries current board/progress | Yes | No |
| Carries score/moves/RNG state | Yes | No; only initial deterministic seed |
| Starts a fresh game | No | Yes |
| Imported/restored session ranked | No, always unranked | Normal local non-Daily policy |
| Can encode Daily mode | Backup can contain a Daily-configured board, but imported play remains unranked and cannot update Daily history | No; Daily is rejected |
| Format | Versioned JSON envelope | `NOVA1.<payload>.<checksum>` |
| Integrity mechanism | Strict schema/state validation | Strict config validation plus corruption checksum |

The difference is intentional. Backup text can assert an arbitrary board/score and therefore must never become trusted record progress. Challenge Codes cannot assert progress; they only choose the deterministic setup of a brand-new game.

## Privacy and security boundary

The backup is plain JSON text. It is not encrypted, signed, or authenticated. A user should treat copied backup text like any other clipboard content and share it only when intended.

Because imported data is unranked and strictly validated, the feature does not use portable backups as proof of trustworthy achievements or records. The app also does not upload backup data to a server.

Challenge Codes are also plain clipboard text, but their checksum is only corruption detection and their payload contains configuration/seed rather than progress. See [`CHALLENGE_CODES.md`](CHALLENGE_CODES.md).

## Compatibility policy

Version `1` is the only portable backup envelope version currently accepted. Future incompatible backup structures should increment the envelope version and add an explicit migration path if backward compatibility is desired. Unknown future versions are rejected rather than guessed.

The embedded game state maintains its own schema validation/migration rules independently of the outer backup envelope.

Challenge Code schema versioning is separate from the Game Backup envelope version; neither protocol should silently parse the other.

## Automated regression coverage

Current backup-related tests cover:

- exact encode/decode round trip;
- exclusion of settings/statistics/achievements/Daily/Undo;
- empty and malformed text rejection;
- unsupported format and version rejection;
- invalid timestamp and missing-game rejection;
- strict invalid game-state rejection;
- oversized text rejection;
- clipboard export producing a decodable game-only backup;
- explicit import confirmation;
- cancelled import preserving the existing game;
- invalid clipboard content preserving the existing game;
- imported best-score isolation;
- lifetime-statistics, achievement, and Daily-history isolation;
- persistent unranked marker after restart;
- new normal game exiting unranked policy;
- terminal imported games not awarding ranked wins.

See `test/game_backup_test.dart`, `test/game_backup_screen_test.dart`, `test/imported_game_policy_test.dart`, and `test/local_store_test.dart`.

Challenge Code behavior has separate codec/UI tests so changes to one portable format cannot silently weaken the other boundary.

## Manual release checks

Before stable distribution, verify on representative target platforms:

- clipboard copy and paste with real platform handlers;
- large but valid backup text;
- cancellation and replacement confirmation;
- navigation after restore;
- visible unranked labeling on Home and backup screen;
- restart/resume persistence of the unranked marker;
- Undo behavior after imported moves;
- importing Daily/target/timed/move-limit states;
- screen-reader reading of backup actions and confirmation content;
- long text and large-text layout behavior;
- switching between Challenge Code and Game Backup clipboard workflows without confusing the two formats.


## Per-mode record isolation

Phase 17 extends the existing imported-backup trust boundary to per-mode records. Importing a valid backup does not create or improve a mode best score/highest tile, continuing to play that imported board still does not update a mode record, and Reset Statistics does not rebuild a mode baseline from the unranked imported state.

This is intentional because backup JSON is portable and editable. Its board/score can be useful for restoration without being treated as authenticated evidence for trusted local records. A fresh locally started game, including a locally started seeded configuration, returns to the normal ranked record path.

## Interaction with Full Replay Archive

A Game Backup restores current progress but does not contain the sender's earlier action history. Therefore `AppController.importGameBackup()` creates an **incomplete** local replay capture for the restored board. The imported game remains playable and unranked and can continue saving and Undo normally, but it cannot be exported later as though 2048 Nova had captured the sender's complete session from move zero.

Starting a fresh local game after backup restore creates a new complete replay capture for that new session. Opening a portable Full Replay Archive is different again: it is spectator-only and never installs current-game progress at all.
