# Phase 31 Verification — Qualification Status Reporting

Phase 31 adds a read-only, repository-owned status layer for the Version 1.5 manual release qualification manifest. The feature improves visibility and automation around the remaining real-world checks without changing the evidence model or claiming that hosted verification completed physical qualification.

## Scope

Phase 31 covers:

- `tool/release_qualification_status.dart`;
- `test/release_qualification_status_cli_test.dart`;
- permanent CI execution of the reporter;
- maintainer-tool documentation;
- qualification-status reference documentation;
- roadmap/release continuity updates.

The live manual qualification manifest remains the source of truth in `docs/release_qualification.json`.

## Reporter behavior

The new CLI is read-only and supports:

```bash
dart run tool/release_qualification_status.dart
dart run tool/release_qualification_status.dart --pending-only
dart run tool/release_qualification_status.dart --json
dart run tool/release_qualification_status.dart --json --pending-only
dart run tool/release_qualification_status.dart --fail-if-incomplete
```

`--root=<path>` allows isolated fixtures and alternate checkouts to be inspected without mutating the active repository.

The reporter validates the canonical Version 1.5 evidence contract before producing output:

- schema version `1`;
- non-empty candidate version;
- exactly 13 canonical manual check IDs;
- no duplicate or unknown IDs;
- non-empty titles;
- only `pending`, `passed`, or `blocked` states;
- no stale evidence/timestamp on pending entries;
- non-empty evidence on passed/blocked entries;
- explicit-timezone ISO-8601 timestamps on passed/blocked entries.

## Aggregate-count filtering fix

The initial reporter implementation filtered the report object itself for `--pending-only`. That design would have caused aggregate totals in a filtered JSON report to describe only the visible subset instead of the canonical 13-check manifest.

Phase 31 corrects this before adoption by filtering only the `checks` detail collection. `total`, `passed`, `pending`, `blocked`, and `complete` always describe the full canonical checklist.

This invariant is covered by the CLI regression suite.

## Exit-code contract

- `0`: structurally valid report produced successfully.
- `3`: `--fail-if-incomplete` was requested and at least one canonical check remains pending or blocked.
- `64`: invalid arguments or malformed qualification evidence.

Ordinary CI uses reporting mode rather than `--fail-if-incomplete`, because pending real-world qualification is an expected state during release-candidate hardening. The strict release gate remains the responsibility of `tool/release_readiness.dart --stable`.

## Regression coverage

`test/release_qualification_status_cli_test.dart` adds process-level coverage for:

1. human-readable 0/13 pending summary;
2. JSON aggregate counts with passed, pending, and blocked states;
3. `--pending-only` detail filtering with unchanged aggregate totals;
4. distinct exit code `3` for intentional incomplete-state enforcement;
5. fully passed synthetic fixture behavior;
6. rejection of a missing canonical check ID;
7. rejection of passed evidence with an empty evidence string.

Synthetic fixtures validate tool behavior only. A synthetic passed fixture is not release evidence for 2048 Nova.

## Permanent CI integration

`.github/workflows/ci.yml` now runs:

```bash
dart run tool/release_qualification_status.dart --json --pending-only
```

This makes malformed qualification state visible to normal CI and provides a concise list of remaining real-world checks in logs. It does not mutate the manifest and does not open the stable gate.

## Trust boundary

Phase 31 deliberately does not:

- mark any manual check passed;
- generate device or accessibility evidence;
- generate signing/provisioning/store evidence;
- replace external-handler checks with widget tests;
- change the candidate version;
- weaken the strict stable release-readiness command.

As of this phase implementation, the repository still records **0/13** real-world Version 1.5 qualification checks as passed. That number must change only when a maintainer performs the corresponding checks and records verifiable evidence.

## Source commit sequence

The implementation was split into small meaningful commits:

- `2f176648` — add the release qualification status reporter;
- `648a7f75` — preserve canonical summary totals when filtering;
- `843d4ec5` — enforce the canonical qualification checklist;
- `2f11942f` — add process-level CLI regression coverage;
- `01ed738e` — wire the status reporter into permanent CI;
- `2fbf6e9f` — document the reporter in maintainer tools;
- `6005018e` — add the dedicated qualification status reference;
- `db86c5d1` — record the new tooling in the roadmap.

Additional documentation/continuity commits may follow this verification record.

## Maintainer verification commands

The maintained verification sequence for this phase is:

```bash
dart format --output=none --set-exit-if-changed lib test tool
flutter analyze
flutter test --coverage
dart run tool/release_readiness.dart --json
dart run tool/release_qualification_status.dart --json --pending-only
dart run tool/repository_audit.dart --json
dart run tool/solver_benchmark.dart 8
flutter build web --release
```

Native build verification remains governed by `.github/workflows/platform-builds.yml` and the release artifact documentation. Real-device/store qualification remains governed by `docs/release_qualification.json` and `docs/RELEASE_QUALIFICATION.md`.
