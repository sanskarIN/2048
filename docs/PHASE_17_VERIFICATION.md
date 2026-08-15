# Phase 17 Verification — Trusted Per-Mode Records

This file is the focused verification record for the Phase 17 per-mode-record release-candidate work. The canonical cross-phase verification history remains [`VERIFICATION.md`](VERIFICATION.md).

## Qualified scope

The accepted Phase 17 candidate includes:

- persisted `ModeRecord` data under `PlayerStats.modeRecords`;
- best score and highest tile per `GameMode`;
- best-score board-size and target metadata;
- backward-compatible parsing of pre-Phase-17 statistics;
- trusted local-session tracking and startup repair;
- explicit imported-Game-Backup exclusion;
- Statistics-reset baseline behavior;
- localized expandable Statistics cards using the existing English/Hindi layer;
- 10 focused tests across serialization, migration/tracking/reset, unranked isolation, and localized UI.

## Trust boundary verified

Normal locally started games, including locally seeded games, may update records. Portable Game Backup imports remain unranked and cannot create or improve mode records through import, continued play, restart repair, or Statistics reset.

The accepted regression suite also keeps the pre-existing global statistics, Daily Challenge, Replay, Auto Play, Challenge Code, backup/restore, localization, accessibility, persistence, and game-engine contracts green.

## Feature acceptance gate

The Phase 17 feature/test candidate was first accepted on:

```text
Commit: c443f9fde0cc243269be57515772378c06284e86
CI workflow run: 31867499047
CI job: 94970781061
Result: SUCCESS
Date: 2026-08-15
Runner: ubuntu-24.04
Flutter: 3.47.0 stable
Dart: 3.13.0
DevTools: 2.60.0
```

Maintained checks:

```text
Dependency resolution: PASS
Dart formatting: PASS — 74 files, 0 changed
Flutter analyze: PASS — No issues found
Automated tests: PASS — 144/144
Flutter Web release build: PASS — build/web produced
Flutter Web WASM dry run: PASS
```

## Current-source qualification gate

A later source-documentation commit was deliberately made under `lib/**` after the parser correction and all final Phase 17 documentation work. This caused the permanent CI and native Platform Builds workflows to verify the current runtime tree rather than relying on the earlier native matrix that predated the parser correction.

Current-source commit:

```text
Commit: d33d65840aff67c4e9bf69ad203f46b85146093c
docs: clarify statistics record trust boundary in source
```

Permanent CI evidence:

```text
CI workflow run: 31867788776
CI job: 94971490776
Result: SUCCESS
Runner: ubuntu-24.04
Flutter: 3.47.0 stable
Dart: 3.13.0
DevTools: 2.60.0
Dependency resolution: PASS
Dart formatting: PASS — 74 files, 0 changed
Flutter analyze: PASS — No issues found
Automated tests: PASS — 144/144
Flutter Web release build: PASS — build/web produced
Flutter Web WASM dry run: PASS
```

Current-source native matrix:

```text
Platform Builds workflow run: 31867788753
Commit: d33d65840aff67c4e9bf69ad203f46b85146093c
Result: SUCCESS

Android release APK
  Job: 94971490848
  flutter build apk --release: PASS

Linux release
  Job: 94971490809
  flutter build linux --release: PASS

Windows release
  Job: 94971490788
  flutter build windows --release: PASS

macOS and unsigned iOS release
  Job: 94971490875
  flutter build macos --release: PASS
  flutter build ios --release --no-codesign: PASS
```

This matrix closes the Phase 17 hosted native-build evidence gap: it includes the final `PlayerStats.fromJson` per-mode parser correction and the complete current runtime source used by the accepted 144-test suite.

The Web build emitted the existing non-fatal Cupertino icon-font availability warning while still producing `build/web`; it did not fail the maintained build gate. No Phase 17 source uses that warning as evidence of a failed build.

## Acceptance attempts retained for auditability

### Attempt 1 — analyzer failure

```text
Commit: f86e9499280310a431370a7f0fe9e275a3da0ec6
CI run: 31867316152
Formatting: PASS
Static analysis: FAIL
Cause: unused local variable in mode_record_serialization_test.dart
```

The test was corrected in:

```text
f42a8ab18edd4661a066419de0daa84a2ce22f85
test: remove unused per-mode record local
```

### Attempt 2 — widget expectation failure

```text
Commit: f42a8ab18edd4661a066419de0daa84a2ce22f85
CI run: 31867370893
Formatting: PASS
Static analysis: PASS
Automated tests: 142 passed, 2 failed
Web build: skipped because tests failed
```

Both failures were in `statistics_mode_records_test.dart`. The production Statistics UI intentionally renders board-size and target metadata inside one subtitle `Text` widget separated by ` • `; the test had incorrectly searched for the two metadata fragments as separate widgets in English and Hindi.

The contract-correcting test commit was:

```text
c443f9fde0cc243269be57515772378c06284e86
test: match combined mode record metadata
```

The third acceptance run on that commit passed all 144 tests and the Web/WASM gate. The subsequent current-source gate on `d33d6584...` repeated the same 144-test/Web/WASM verification and added a complete fresh native matrix.

## Test-count progression

```text
Phase 16 final: 134/134
Phase 17 focused additions: 10
Phase 17 final: 144/144
```

The Phase 17 additions are:

- 3 serialization/backward-compatibility tests;
- 3 ranked tracking/migration/reset tests;
- 2 unranked-import/seeded-ranking tests;
- 2 localized Statistics UI tests.

## Release boundary

These green automated and hosted native-build gates qualify the Phase 17 source/test/runtime candidate; they do **not** promote the application to stable `1.0.0` by themselves.

Stable `1.0.0` remains blocked on the manual qualification listed in [`ROADMAP.md`](../ROADMAP.md) and [`RELEASE_CHECKLIST.md`](RELEASE_CHECKLIST.md), including representative real-device lifecycle/gameplay, accessibility, clipboard/platform handlers, long-session behavior, native branding review, signing/provisioning, and store metadata.

Hosted compilation is evidence that the configured targets build; it is not a substitute for physical-device behavior, assistive-technology testing, signed distribution packages, or app-store review.
