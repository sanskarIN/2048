# Phase 17 Verification — Trusted Per-Mode Records

This file is the focused verification record for the Phase 17 per-mode-record release-candidate work. The canonical cross-phase verification history remains [`VERIFICATION.md`](VERIFICATION.md).

## Candidate scope

The candidate being qualified includes:

- persisted `ModeRecord` data under `PlayerStats.modeRecords`;
- best score and highest tile per `GameMode`;
- best-score board-size and target metadata;
- backward-compatible parsing of pre-Phase-17 statistics;
- trusted local-session tracking and startup repair;
- explicit imported-Game-Backup exclusion;
- Statistics-reset baseline behavior;
- localized expandable Statistics cards using the existing English/Hindi layer;
- 10 focused tests across serialization, migration/tracking/reset, unranked isolation, and localized UI.

## Trust boundary under test

Normal locally started games, including locally seeded games, may update records. Portable Game Backup imports remain unranked and cannot create or improve mode records through import, continued play, restart repair, or Statistics reset.

## Automated gate

The final maintained `CI` run is intentionally not pre-declared here. This file is committed before the gate so the permanent workflow qualifies a stable source/test/documentation candidate rather than a moving stream of intermediate commits.

Expected maintained checks are:

- dependency resolution;
- Dart formatting;
- Flutter static analysis;
- the complete automated regression suite;
- Flutter Web release build;
- Flutter WASM dry run.

After the workflow completes, this record will be updated with the exact run, commit, toolchain, test count, and result. A passing automated gate will not be described as physical-device or assistive-technology qualification.

## Manual release boundary

Stable `1.0.0` remains blocked on the manual qualification already listed in [`ROADMAP.md`](../ROADMAP.md) and [`RELEASE_CHECKLIST.md`](RELEASE_CHECKLIST.md), including representative real-device lifecycle/gameplay, accessibility, clipboard/platform handlers, long-session behavior, native branding review, signing/provisioning, and store metadata.
