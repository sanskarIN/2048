# 2048 Nova — Active Development Continuity

This is the current development/release continuity record. Historical implementation detail is preserved in:

- [`what_changed_archive_phase_00_30.md`](what_changed_archive_phase_00_30.md) — Phases 0–30.
- [`what_changed_archive_phase_31.md`](what_changed_archive_phase_31.md) — complete Phase 31 qualification-status and Web/PWA hardening record.

## Current repository state

- **Current phase:** Phase 32 — Version 2.0.12 migration and release-contract hardening.
- **Marketing version:** `2.0.12`.
- **Flutter package/build version:** `2.0.12+2012`.
- **Repository:** `https://github.com/sanskarIN/2048`.
- **Branch:** `main`.
- **Stable qualification boundary remains 0/13:** no real-device, assistive-technology, browser/PWA lifecycle, external-handler, native-branding, signing/provisioning, or store evidence has been fabricated.
- **Latest previously accepted complete automated evidence:** Version 1.5 CI run `32018055661` with 235/235 tests and 106 Dart files formatter-clean; native matrix run `32015893841`. These remain historical baseline evidence until a complete maintained Version 2.0.12 workflow result is observed and recorded.
- **Known external/open blockers:** GitHub issue #10 (AGP 9.3.x/JDK-17 lint compatibility remains intentionally deferred) and issue #12 (`main` branch protection/ruleset still requires repository-setting action outside tracked source).

# Phase 32 — Version 2.0.12 migration

Date: **2026-08-19**

## Version policy

The project now uses:

```text
Marketing version: 2.0.12
Flutter package version: 2.0.12+2012
```

The `+2012` suffix is the platform build number. The user-facing semantic version remains `2.0.12`.

The build number intentionally moves forward from the former Version 1.5 build number and is suitable for Flutter-generated Android/iOS/desktop build metadata.

## Package and runtime metadata

Updated:

- `pubspec.yaml` → `2.0.12+2012`;
- `lib/core/constants/project_info.dart` → `2.0.12`;
- `windows/runner/Runner.rc` fallback file/product version → `2,0,12,2012` / `2.0.12`;
- `docs/release_qualification.json` candidate → `2.0.12+2012`.

The 13 manual qualification records remain pending. A version migration is not evidence that any real-world qualification check passed.

## Release readiness gate migration

`tool/release_readiness.dart` now has a single explicit current release target:

```text
2.0.12
```

The gate now:

- accepts `2.0.12` with an optional numeric Flutter build suffix;
- rejects the former 1.5 line;
- rejects unrelated 2.0 patch versions such as 2.0.11;
- exposes `releaseTarget: 2.0.12` in JSON output;
- requires the qualification manifest candidate to exactly match the package version;
- keeps the canonical 13 manual evidence checks;
- keeps stable mode fail-closed until all manual evidence is valid;
- requires a `[2.0.12]` changelog section only for stable promotion;
- requires the roadmap to preserve an explicit `Remaining release qualification before 2.0.12` boundary.

## Release-gate regression migration

`test/release_readiness_cli_test.dart` now uses Version 2.0.12 fixtures and verifies:

1. a `2.0.12+2012` candidate passes the candidate gate while remaining not ready for stable with 0/13 evidence;
2. a synthetic fully qualified Version 2.0.12 fixture can pass stable mode;
3. pending real-world evidence keeps stable mode closed;
4. Version 1.5 candidates are rejected;
5. other 2.0 patch versions are rejected;
6. qualification-candidate mismatch remains rejected;
7. passed checks without evidence/timestamps remain rejected;
8. missing canonical manual-check IDs remain rejected.

Synthetic fully passed fixtures test gate behavior only. They are not evidence for the real repository candidate.

## Roadmap migration

`ROADMAP.md` now identifies Version **2.0.12** as the current release target and retains the same real-world qualification requirements. It also records that the latest complete automated evidence still belongs to the earlier Version 1.5 source state until a new complete Version 2.0.12 run is actually observed.

## Historical continuity preservation

The complete prior Phase 31 `what_changed.md` was preserved before replacing the active continuity index:

- `what_changed_archive_phase_31.md`

The earlier Phase 0–30 archive remains untouched.

## Phase 32 commit sequence so far

```text
9997da33  chore: start Version 2.0.12 package line
d770312b  feat: expose Version 2.0.12 in app metadata
6f341c2f  chore: retarget qualification manifest to Version 2.0.12
fe3aa483  chore: align Windows fallback version with 2.0.12
6a92dd3a  feat: migrate release gate to Version 2.0.12
afc52ef5  test: migrate release gate fixtures to Version 2.0.12
5fedb71a  docs: move roadmap to Version 2.0.12
710d725f  docs: preserve complete Phase 31 continuity
```

## Verification boundary

The Version 2.0.12 source migration is being committed in small atomic changes. A newer complete formatter/analyzer/test/Web/native workflow result has not yet been accepted into this file.

Until such evidence is actually observable, do not describe the Version 2.0.12 head as having passed the old 235-test/106-file evidence set. Those numbers belong to the previously verified Version 1.5 source state.

## Stable-release boundary retained

Stable `2.0.12` remains blocked until all 13 real-world checks are genuinely completed and recorded with valid evidence and explicit-timezone timestamps.

Hosted compilation, source inspection, regression fixture design, generated artifacts, and documentation updates are not substitutes for physical-device/accessibility/external-handler/signing/store qualification.
