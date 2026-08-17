# Portable Timestamp Integrity

2048 Nova treats game-session timestamps as **absolute instants**, not device-local wall-clock labels. This is important because saved games, Game Backups, and Full Replay Archives can move between Android, iOS, Web, Windows, macOS, Linux, devices, and time zones.

## Why UTC serialization matters

`GameState.startedAt` participates directly in Time Challenge expiration. A timestamp such as `2026-08-17T10:30:45.000` has no timezone designator. If portable text containing that value is opened under another local timezone, the same wall-clock text can represent a different absolute instant.

Current serialization therefore writes the game start using:

```dart
startedAt.toUtc().toIso8601String()
```

The resulting ISO-8601 text contains the UTC `Z` designator. A newly serialized game therefore preserves the same instant when it is parsed on another supported platform or in another timezone.

## Current guarantees

### Game state

`GameState.toJson()` normalizes `startedAt` to UTC before serialization.

This applies transitively to:

- current-game persistence;
- Undo snapshots;
- portable Game Backup game payloads;
- Full Replay Archive initial-state payloads;
- any other feature that reuses `GameState.toJson()`.

### Game Backup metadata

`GameBackup.encode()` normalizes `exportedAt` to UTC even when a caller supplies a non-UTC `DateTime`.

The export timestamp is metadata rather than ranking/gameplay authority, but keeping it absolute avoids ambiguous portable records.

### Full Replay Archive metadata

`ReplayArchive.encode()` likewise normalizes `exportedAt` to UTC.

Replay event timing itself remains stored as bounded elapsed milliseconds from the captured initial game state. The UTC initial-state timestamp makes that baseline portable without changing the deterministic replay protocol.

### Daily Challenge history

`DailyRecord.fromState()` already creates `updatedAt` in UTC. `DailyRecord.toJson()` additionally normalizes any supplied `updatedAt` value to UTC before serialization so direct construction or future callers cannot reintroduce timezone-less Daily history metadata.

Daily records remain local history and are not included in Game Backup imports. This normalization is a persistence-consistency hardening measure rather than a change to Daily Challenge ranking or seed semantics.

## Backward compatibility

The parser intentionally continues to accept older timezone-less ISO-8601 timestamp strings. Rejecting them would make existing saved data unnecessarily unreadable.

Compatibility behavior is therefore:

1. an older timezone-less timestamp can still be parsed using the existing parser;
2. the restored game remains usable under the same compatibility rules as before;
3. when that state is serialized again, the timestamp is emitted in UTC with `Z`;
4. newly created/exported data is unambiguous across time zones.

Because an older exported string omitted its original timezone, software cannot reconstruct timezone information that was never recorded. The compatibility path avoids inventing an offset while ensuring all future writes are normalized.

## Time Challenge behavior

Time Challenge calculates expiration from the difference between the current instant and `GameState.startedAt`. Preserving `startedAt` as an absolute instant prevents a new portable save from gaining or losing time merely because it was restored on a device configured for another timezone.

Regression coverage verifies that a serialized/restored timed game still remains active immediately before its configured deadline and expires at the same absolute deadline.

## Schema compatibility

This hardening does **not** require a GameState, Game Backup, Replay Archive, or Daily history schema/version bump because:

- the JSON field names and types are unchanged;
- ISO-8601 text with `Z` is already accepted by the existing parsers;
- old timezone-less values remain accepted;
- deterministic state structure is unchanged.

A future protocol change that changes field meaning or stops accepting existing valid data should use the normal explicit version/migration process.

## Tests

Focused regression coverage lives in:

- `test/portable_timestamp_test.dart` — game-start UTC normalization and same-instant round trip;
- `test/portable_export_timestamp_test.dart` — Game Backup and Full Replay export metadata UTC normalization;
- `test/legacy_timestamp_compatibility_test.dart` — old timezone-less saves remain readable and serialize back as UTC;
- `test/timed_restore_timestamp_test.dart` — restored Time Challenge expiration preserves the same absolute deadline;
- `test/daily_record_utc_test.dart` — directly constructed Daily record metadata serializes as an absolute UTC instant.

## Non-portable local metadata

Some application metadata, such as achievement unlock display timestamps, is local-only and does not participate in Time Challenge expiration, portable Game Backup state, Full Replay Archive reconstruction, Daily seeding, or trusted score calculations. This hardening intentionally stays scoped to timestamp-bearing persistence/protocol structures where absolute-instant behavior is part of the contract.

## Trust boundary

UTC normalization prevents timezone ambiguity. It is **not** authentication, anti-cheat protection, cryptographic signing, or proof that a user-supplied portable timestamp is truthful.

Game Backup imports remain unranked, Full Replay imports remain spectator-only, and validation/ranking boundaries documented elsewhere remain unchanged.

Related documentation:

- [`DATA_STORAGE.md`](DATA_STORAGE.md)
- [`BACKUP_AND_RESTORE.md`](BACKUP_AND_RESTORE.md)
- [`REPLAY_ARCHIVES.md`](REPLAY_ARCHIVES.md)
- [`GAME_MODES.md`](GAME_MODES.md)
- [`TESTING.md`](TESTING.md)
- [`RELEASE_QUALIFICATION.md`](RELEASE_QUALIFICATION.md)
