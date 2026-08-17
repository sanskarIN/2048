# Phase 29 Verification — Portable Timestamp and Release-Evidence Integrity

Phase 29 hardens cross-platform timestamp handling for player state, portable exports, Daily history, and future manual release evidence without changing the deterministic 2048 rules, ranking boundaries, backup trust model, replay spectator model, or configured release targets.

## Accepted source

The integrated Phase 29 acceptance source is:

```text
32d50735065cb4ec084990ccfe178d16ba5f0c79
```

Permanent CI:

```text
Run: 32016750775
Job: 95347802636
Result: SUCCESS
```

The native runtime matrix is anchored to the runtime timestamp-hardening source:

```text
439a4441ebd2b36c4e1b6e0700d6f3d3359bd016
```

Platform Builds:

```text
Run: 32015893841
Result: SUCCESS across every configured native qualification job
```

## Defects found and fixed

### 1. Portable game-start timestamps could be timezone-ambiguous

`GameState.startedAt` participates directly in Time Challenge expiration. Serializing a local `DateTime` without a timezone marker can turn an absolute session start into a receiver-local wall-clock value when portable JSON crosses devices or time zones.

`GameState.toJson()` now serializes `startedAt` as UTC using `toUtc().toIso8601String()`.

Consequences:

- newly persisted current games contain an unambiguous absolute start instant;
- newly persisted Undo snapshots inherit the same guarantee;
- Game Backup payloads inherit the guarantee through `GameState.toJson()`;
- Full Replay Archive initial states inherit the guarantee through `GameState.toJson()`;
- Time Challenge portable restores no longer gain or lose time merely because a new export is restored under another timezone.

The parser intentionally remains compatible with older timezone-less game-state strings. Old information that never recorded an offset cannot be reconstructed truthfully, so legacy data is accepted under the previous compatibility behavior and is normalized to UTC on its next serialization.

### 2. Game Backup export metadata could be timezone-ambiguous

`GameBackup.encode()` now normalizes `exportedAt` to UTC even when a caller supplies a local `DateTime`.

This timestamp is metadata and does not grant ranked trust, but portable records should still identify one absolute export instant.

### 3. Full Replay Archive export metadata could be timezone-ambiguous

`ReplayArchive.encode()` now normalizes `exportedAt` to UTC.

Replay event timing remains bounded elapsed milliseconds relative to the initial captured game state. The deterministic replay protocol and spectator-only trust boundary are unchanged.

### 4. Daily history serialization did not independently enforce UTC

Normal `DailyRecord.fromState()` creation already used UTC, but a directly constructed record could serialize a local timestamp without a timezone marker.

`DailyRecord.toJson()` now normalizes `updatedAt` to UTC, preventing future callers from reintroducing ambiguous Daily history metadata.

### 5. Manual release evidence accepted timezone-less timestamps

`tool/release_readiness.dart` previously accepted any `DateTime.tryParse`-parseable `updatedAt` text. That included timezone-less evidence such as:

```text
2026-08-17T14:30:00
```

Manual release evidence is an audit record and must identify one absolute instant. The gate now requires an explicit UTC or numeric offset, for example:

```text
2026-08-17T09:00:00Z
2026-08-17T14:30:00+05:30
```

The live manifest still had 0/13 passed manual checks when this rule was tightened, so no accepted real-world qualification evidence was invalidated.

## Focused regression coverage added

Phase 29 adds seven focused regression cases across six new test files:

- `test/portable_timestamp_test.dart`
  - game-start timestamps serialize with `Z`;
  - parsed state remains the same absolute instant.
- `test/portable_export_timestamp_test.dart`
  - Game Backup export metadata normalizes to UTC;
  - Full Replay Archive export metadata normalizes to UTC.
- `test/legacy_timestamp_compatibility_test.dart`
  - old timezone-less game-state timestamps remain readable;
  - subsequent serialization upgrades them to UTC.
- `test/timed_restore_timestamp_test.dart`
  - a restored Time Challenge remains active immediately before its configured deadline;
  - it expires at the same absolute deadline after serialization/restoration.
- `test/daily_record_utc_test.dart`
  - directly constructed Daily metadata serializes as UTC and preserves the same instant.
- `test/release_evidence_timestamp_test.dart`
  - a passed manual check with evidence but a timezone-less `updatedAt` is rejected by the real CLI process.

The pre-existing release-readiness fixture also continues to exercise a successful stable fixture with an explicit `+05:30` numeric offset, providing the acceptance side of the evidence-timestamp contract.

Phase 28 had a 225-test automated baseline. Phase 29 adds seven focused cases; the full hosted `flutter test --coverage` step passed on the accepted Phase 29 source. The workflow API evidence used here confirms the complete test step succeeded; this record does not invent a test-runner count that was not exposed by that API response.

## Permanent CI evidence

Permanent CI run `32016750775`, job `95347802636`, completed successfully on accepted source `32d50735065cb4ec084990ccfe178d16ba5f0c79`.

Successful steps:

1. checkout;
2. Flutter 3.47.0 setup;
3. Flutter version check;
4. dependency installation;
5. lockfile/managed metadata synchronization check;
6. formatter check;
7. static analysis;
8. full test suite with coverage;
9. release-candidate readiness metadata gate;
10. strict stable gate fail-closed verification;
11. deterministic solver benchmark smoke test;
12. Web release build without the guarded missing-font warning.

The strict stable gate continuing to refuse release is the expected success condition while manual qualification remains incomplete.

## Native matrix evidence

Platform Builds run `32015893841` completed successfully for the runtime timestamp-hardening source `439a4441ebd2b36c4e1b6e0700d6f3d3359bd016`.

### Android

```text
Job: 95345268019
Result: SUCCESS
```

Verified:

- immutable checkout action;
- explicit Temurin JDK 17;
- Flutter 3.47.0;
- synchronized dependency lockfile;
- `flutter build apk --release`;
- SHA-256 generation;
- qualification-artifact upload.

### Linux

```text
Job: 95345268049
Result: SUCCESS
```

Verified Linux prerequisites, generated dependency files, release build, archive/checksum packaging, and artifact upload.

### Windows

```text
Job: 95345268000
Result: SUCCESS
```

Verified generated dependency files, Windows release build, ZIP/checksum packaging, and artifact upload.

### macOS and unsigned iOS

```text
Job: 95345267946
Result: SUCCESS
```

Verified generated Apple dependency files, macOS release build, unsigned iOS release build, both checksummed packages, and both qualification-artifact uploads.

## Formatting automation

A Dart-format normalization generated by the repository's maintained `Format Dart` workflow was committed as:

```text
947306c35de94b1192464bad18c273d0b947f249
style: format Dart sources tests and tools
```

The workflow uses the configured identity:

```text
Sanskar <sanskarin@outlook.in>
```

The final permanent CI formatter check subsequently passed, confirming no formatting drift remains in the accepted source.

## Backward compatibility and schema decisions

No player-data or portable-protocol schema bump is required because:

- field names are unchanged;
- field JSON types are unchanged;
- ISO-8601 values with `Z` are already accepted by existing parsers;
- older timezone-less game-state timestamps remain readable;
- ranking/trust semantics are unchanged;
- replay event representation is unchanged;
- Game Backup imports remain unranked;
- imported Full Replay Archives remain spectator-only.

The release-qualification manifest also remains schema version 1 because its field shape is unchanged and the live manifest had no passed evidence relying on ambiguous timestamps.

## Audit scope and deliberate non-changes

The audit also reviewed nearby timestamp-bearing state. Achievement unlock dates remain local-only presentation metadata: they do not determine Time Challenge deadlines, portable Game Backup state, Full Replay reconstruction, Daily seeding, trusted score calculation, or release qualification. Phase 29 therefore avoids a broad unrelated controller rewrite.

The deterministic engine, move/spawn RNG semantics, Challenge Code protocol, Backup ranking isolation, replay event rules, solver behavior, localization architecture, and accessibility UI were not changed by this phase.

## Remaining explicit boundaries

Phase 29 does not fabricate or replace real-world release evidence. The manifest remains 0/13 passed checks, including physical Android/iOS testing, assistive technology, real clipboard/file/browser/email handlers, long-session qualification, native branding review, and signing/provisioning/store metadata.

Two existing external/manual boundaries also remain explicit:

- GitHub issue #10 — AGP 9.3.x remains deferred on the JDK 17 release-lint baseline; the accepted project baseline remains AGP 9.1.0 / Kotlin 2.4.10 / Gradle 9.7.0 / JDK 17.
- GitHub issue #12 — branch protection/ruleset enforcement requires repository settings and cannot be truthfully implemented by source files alone with the currently available repository actions.

## Acceptance conclusion

Phase 29 is accepted for automated/source-controlled scope:

- cross-timezone Time Challenge serialization defect fixed;
- portable export timestamps normalized;
- Daily timestamp serialization hardened;
- legacy player-state compatibility preserved;
- manual release evidence requires an absolute timestamp;
- seven focused regression cases added;
- formatter clean;
- analyzer clean;
- full tests green;
- release candidate gate green;
- strict stable boundary correctly closed;
- solver smoke green;
- Web release green;
- every configured native qualification build green.

Stable `1.5.0` promotion remains intentionally blocked until the 13 real-world qualification items are genuinely completed and recorded.