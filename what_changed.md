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

The Version 2.0.12 release tests now cover:

1. `2.0.12+2012` candidate success with stable readiness still false at 0/13 evidence;
2. synthetic fully qualified Version 2.0.12 stable success;
3. strict stable refusal with pending evidence;
4. rejection of Version 1.5 candidates;
5. rejection of unrelated 2.0 patch versions;
6. qualification-candidate mismatch;
7. passed evidence without evidence/timestamps;
8. missing canonical manual-check IDs;
9. ambiguous timezone-less evidence timestamps;
10. qualification status reporting using `2.0.12+2012` fixtures;
11. qualification recorder behavior using `2.0.12+2012` fixtures.

Synthetic fully passed fixtures test tooling only. They are not evidence for the live candidate.

## Repository-integrity hardening

`tool/repository_audit.dart` now enforces the exact Phase 32 source contract:

- package/build version `2.0.12+2012`;
- marketing version `2.0.12`;
- Windows fallback numeric/string versions;
- exact qualification-candidate alignment;
- exactly 13 manual qualification records;
- Phase 32 active continuity;
- preserved Phase 0–30 and Phase 31 continuity archives;
- required Phase 32 verification documentation;
- existing Web/PWA source/semantic contracts;
- rejection of leftover Phase 30/31/32 temporary maintenance helpers.

Its process-level fixtures now prove exact build-version, runtime-version, Windows-resource, qualification-candidate, PWA metadata, Markdown-link, and temporary-helper failure paths.

## Hidden Version 1.5 drift discovered and corrected

The migration audit found several source-controlled assumptions that a simple `pubspec.yaml` version bump would have missed:

- `test/release_evidence_timestamp_test.dart` still created a `1.5.0+15` fixture;
- `test/repository_integrity_test.dart` still required `SECURITY.md` to claim Version 1.5 was current;
- qualification status/recorder fixtures still used the former candidate;
- `docs/RELEASE_GATE_TESTING.md` described Version 1.5 fixture scenarios;
- `docs/QUALIFICATION_STATUS.md` called the canonical checklist Version 1.5;
- `docs/RELEASE_CHECKLIST.md` carried historical Version 1.5 automated checks as currently completed.

All of those current-state surfaces now use Version 2.0.12. The rebuilt release checklist deliberately leaves current-head automated/native checks unchecked until a complete maintained Version 2.0.12 result is actually observed.

## Android distribution regression guard

The maintained Platform Builds workflow already creates both Android release formats:

- APK: `build/app/outputs/flutter-apk/app-release.apk`;
- AAB: `build/app/outputs/bundle/release/app-release.aab`.

It also generates SHA-256 sidecars for both and uploads all four Android distribution files. Phase 32 adds `test/android_distribution_workflow_test.dart` to guard the APK build, Play Store AAB build, checksum commands, artifact paths, and fail-closed upload policy against future workflow drift.

This protects source-controlled distribution automation only; a real production-signed AAB still requires genuine signing and Play Store qualification.

## Security and maintainer documentation

`SECURITY.md` now identifies Version 2.0.12 / `2.0.12+2012` as the active security-maintenance line while preserving all existing input-validation, trust, dependency, secret-management, backup, replay, QR, and signing boundaries.

`tool/README.md`, `README.md`, `ROADMAP.md`, `docs/README.md`, `docs/RELEASE_QUALIFICATION.md`, `docs/REPOSITORY_AUDIT.md`, `docs/RELEASE_GATE_TESTING.md`, `docs/QUALIFICATION_STATUS.md`, `docs/RELEASE_CHECKLIST.md`, and `docs/PHASE_32_VERSION_2_0_12.md` now describe the new target and its fail-closed verification boundary.

## Historical continuity preservation

The complete prior Phase 31 `what_changed.md` was preserved before replacing the active continuity index:

- `what_changed_archive_phase_31.md`

The earlier Phase 0–30 archive remains untouched.

## Phase 32 commit sequence

The Version 2.0.12 migration was intentionally split into small reviewable commits:

```text
9997da33  chore: start Version 2.0.12 package line
d770312b  feat: expose Version 2.0.12 in app metadata
6f341c2f  chore: retarget qualification manifest to Version 2.0.12
fe3aa483  chore: align Windows fallback version with 2.0.12
6a92dd3a  feat: migrate release gate to Version 2.0.12
afc52ef5  test: migrate release gate fixtures to Version 2.0.12
5fedb71a  docs: move roadmap to Version 2.0.12
710d725f  docs: preserve complete Phase 31 continuity
e758efaa  docs: advance continuity to Phase 32 Version 2.0.12
a3190e1c  docs: migrate release qualification guide to 2.0.12
5b3ac377  docs: add Phase 32 Version 2.0.12 verification record
7243fd03  feat: enforce Version 2.0.12 repository integrity
4ac3cc16  test: migrate repository audit fixtures to Phase 32
6eadeba0  test: advance current release state to Phase 32
71529f8e  docs: index Phase 32 Version 2.0.12 migration
7a1e545d  docs: align repository audit with Phase 32
d3b6d402  docs: present Version 2.0.12 in project README
f756c4d6  test: migrate release timestamp fixture to 2.0.12
00aa6384  docs: migrate release gate testing guide to 2.0.12
c24e2252  docs: align qualification status guide with 2.0.12
4a8d8e72  docs: rebuild release checklist for Version 2.0.12
a7351f2a  test: align repository integrity with Version 2.0.12
85883abb  docs: move security policy to Version 2.0.12
c4228922  test: migrate qualification status fixtures to 2.0.12
5ffca7a5  test: migrate qualification recorder fixtures to 2.0.12
409c89f7  docs: align maintainer tools with Version 2.0.12
13aa0f47  docs: finalize Phase 32 Version 2.0.12 continuity
45516a17  test: guard Android APK and AAB distribution artifacts
1f53533a  docs: record Version 2.0.12 Android distribution guard
```

## Verification boundary

The Version 2.0.12 source migration has been committed in small atomic changes. The connected environment does not expose a local Dart/Flutter runtime here, and no newer complete maintained formatter/analyzer/test/Web/native workflow result has been observed through the available GitHub connector yet.

Therefore:

- the older 235/235-test, 106-file formatting result remains historical Version 1.5 evidence only;
- no current Version 2.0.12 test count is being invented;
- no current native-matrix result is being inferred;
- the release checklist keeps current-head automation unchecked pending real evidence.

## Stable-release boundary retained

Stable `2.0.12` remains blocked until all 13 real-world checks are genuinely completed and recorded with valid evidence and explicit-timezone timestamps, and the complete maintained automated/native gate succeeds on the exact release commit.

Hosted compilation, source inspection, regression fixture design, generated artifacts, and documentation updates are not substitutes for physical-device/accessibility/external-handler/PWA/signing/store qualification.
