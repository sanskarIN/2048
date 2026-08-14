# Current Game Backup and Restore

2048 Nova supports a portable, clipboard-based backup for the **current game only**. The feature is deliberately narrow: it lets a player carry or preserve one game state without importing lifetime records or treating externally supplied data as trusted ranked progress.

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

From Home, open **Game Backup** and select **Copy game backup**. When a current game exists, the application:

1. encodes that game with `GameBackup.encode()`;
2. writes the JSON text to the system clipboard;
3. leaves the live player game unchanged;
4. shows a confirmation message.

There is no file-system permission requirement and no extra package dependency for this workflow; it uses Flutter's clipboard API and Dart JSON encoding.

## Import workflow

Select **Import from clipboard**. The application:

1. reads plain text from the clipboard;
2. rejects missing or empty text;
3. checks the maximum encoded length before JSON parsing;
4. parses the envelope as JSON;
5. validates the backup format and version;
6. validates the export timestamp;
7. requires an embedded game object;
8. passes the embedded object through strict `GameState.fromJson()` validation;
9. displays a non-dismissible preview/confirmation dialog;
10. restores only after the player explicitly chooses **Restore unranked backup**.

Cancelling the dialog leaves the current ranked game untouched.

## Validation and size limit

Current constants in `lib/domain/game_backup.dart` are:

```text
format = 2048-nova-game-backup
version = 1
maxEncodedLength = 128 KiB
```

Malformed JSON, wrong envelope type, unsupported format/version, invalid timestamps, missing game data, invalid board values, invalid dimensions, invalid counters, unsupported save schemas, and other invalid `GameState` fields are rejected rather than partially trusted.

The size check happens before JSON parsing so unexpectedly large clipboard content is refused early.

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
