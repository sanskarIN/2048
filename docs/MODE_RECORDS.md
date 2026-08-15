# Per-Mode Records

2048 Nova keeps lightweight best-progress records for each supported game mode. These records are local-only, offline-first statistics designed to answer a simple question: **what is the strongest trusted progress this installation has reached in each mode?**

## Recorded fields

For every mode with trusted local progress, `PlayerStats.modeRecords` can persist:

- `bestScore` — the highest score observed in that mode.
- `highestTile` — the highest tile observed in that mode.
- `bestScoreBoardSize` — board size used when the saved best score was established.
- `bestScoreTarget` — target tile configured when the saved best score was established.

The board-size and target fields describe the best-score configuration. They are intentionally attached to the score record rather than pretending that every mode always uses one fixed configuration. This matters for configurable Target games and locally started seeded configurations.

## Trust boundary

Per-mode records follow the same local ranking boundary as the existing aggregate statistics:

- A game started normally inside 2048 Nova is ranked and may update its mode record.
- A locally started deterministic/seeded game remains ranked. A seed by itself does not make a session untrusted.
- A current game imported through Game Backup is explicitly **unranked** and cannot update per-mode records.
- Continuing to move an imported unranked board still cannot update per-mode records.
- Resetting statistics while an imported board is active does not seed a mode record from that imported board.
- Replay and Auto Play Demo remain spectator/sandbox features and do not write player statistics.

This prevents portable backup payloads from becoming a way to manufacture trusted local mode records.

## Update behavior

A ranked mode record is updated when trusted current-game progress is observed at normal session boundaries:

1. Starting a new ranked game seeds that mode's observed highest-tile baseline from the generated board.
2. A successful ranked move can raise the mode's best score and/or highest tile.
3. Challenge-status refresh can preserve a newly observed trusted record before a terminal transition is persisted.
4. Restoring a ranked current game from an older local statistics schema can seed the missing mode record from the observable current board and score.

Records are maxima, not reversible counters. Undoing a move does not lower a previously reached mode best, just as the global best score is not reduced by Undo.

## Statistics reset behavior

`Reset statistics` clears historical per-mode records together with the other local statistics.

If a **ranked** game is currently active, the controller rebuilds a minimal statistics baseline for that active session. Its current mode therefore receives a fresh record based only on the active board/score. Historical records for other modes remain cleared.

If the active game is an imported **unranked** backup, no per-mode record is rebuilt.

## Persistence and compatibility

Per-mode records are nested under the existing local statistics payload as `modeRecords`, keyed by `GameMode.name`.

Example shape:

```json
{
  "gamesPlayed": 12,
  "gamesWon": 4,
  "bestScore": 16384,
  "highestTile": 2048,
  "modeRecords": {
    "classic": {
      "bestScore": 16384,
      "highestTile": 2048,
      "bestScoreBoardSize": 4,
      "bestScoreTarget": 2048
    },
    "target": {
      "bestScore": 9200,
      "highestTile": 1024,
      "bestScoreBoardSize": 4,
      "bestScoreTarget": 4096
    }
  }
}
```

Compatibility rules:

- Older statistics payloads that do not contain `modeRecords` remain valid.
- Unknown future mode keys are ignored rather than treated as current records.
- Invalid record objects are ignored or sanitized field-by-field.
- Negative/non-integral scores are rejected to zero.
- Highest-tile and target values must be valid powers of two within the application bounds.
- Stored best-score board size must remain within the supported 3×3 through 8×8 range.
- Empty records are not serialized.

The feature does not require a storage-key migration because it extends the validated JSON object already stored for statistics.

## User interface

The Statistics screen keeps the existing global totals first. Modes with local record progress then appear as expandable cards in `GameMode.values` order.

Each card shows:

- localized mode name;
- best-score board/target metadata when available;
- best score;
- highest tile.

The screen reuses the existing `NovaLocalizations.modeName`, `boardSize`, `targetTile`, `Best score`, and `Highest tile` translations. No separate network translation service or new data collection is involved.

## Non-goals

Phase 17 deliberately does **not** add:

- online leaderboards;
- cloud synchronization;
- account identity;
- analytics or telemetry;
- imported-backup ranking;
- reversible per-mode counters;
- guessed historical mode records for games that are no longer observable;
- a claimed exact "fewest winning moves" record for old sessions where the winning move count cannot be reconstructed reliably.

Future mode-specific metadata should preserve these trust and migration principles.

## Source and tests

Primary source:

- `lib/app/state/app_controller.dart` — `ModeRecord`, `PlayerStats.modeRecords`, trusted tracking, migration, reset behavior.
- `lib/features/statistics/statistics_screen.dart` — localized per-mode record presentation.

Focused regression coverage:

- `test/mode_record_serialization_test.dart`
- `test/mode_record_tracking_test.dart`
- `test/mode_record_unranked_test.dart`
- `test/statistics_mode_records_test.dart`

See also:

- [`DATA_STORAGE.md`](DATA_STORAGE.md)
- [`BACKUP_AND_RESTORE.md`](BACKUP_AND_RESTORE.md)
- [`ARCHITECTURE.md`](ARCHITECTURE.md)
- [`TESTING.md`](TESTING.md)
- [`../ROADMAP.md`](../ROADMAP.md)
