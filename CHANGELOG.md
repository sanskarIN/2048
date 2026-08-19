# Changelog

All notable current changes to 2048 Nova are documented here.

The detailed pre-Version-2.0.12 development changelog is preserved verbatim in [`CHANGELOG_ARCHIVE_PRE_2_0_12.md`](CHANGELOG_ARCHIVE_PRE_2_0_12.md). Historical phase/run evidence is also preserved in `docs/VERIFICATION.md`, the phase verification records, and the `what_changed` continuity archives.

## [Unreleased]

**Current target:** Version **2.0.12**  
**Flutter package/build version:** `2.0.12+2012`  
**Source scope:** feature-complete  
**Real-world manual qualification:** `0/13` recorded passed evidence

This section describes the source-complete Version 2.0.12 candidate. It does not claim that physical-device, assistive-technology, signing/provisioning, external-handler, PWA-install, native-branding, or store-distribution qualification has been completed.

### Added

- Final Version 2.0.12 source-completion audit in `docs/FINAL_2_0_12_SOURCE_AUDIT.md`.
- Post-completion maintenance/non-goal policy in `docs/MAINTENANCE_POLICY.md` so normal maintenance is not mistaken for unfinished product scope.
- Dedicated `tool/source_completion_audit.dart` with JSON/fixture support and permanent CI execution.
- Process-level source-completion audit regressions covering clean completion, package/candidate drift, restored optional backlog, missing final-doc indexing, unresolved product TODO/FIXME comments, obsolete current Version 1.5 metadata, and invalid CLI arguments.
- Version 2.0.12 source-integrity enforcement across package metadata, in-app version, Windows fallback resources, qualification candidate, release tooling, roadmap, current-state tests, and documentation.
- Read-only release-qualification status reporting for the canonical 13-check manifest, including JSON output, pending-only detail filtering, strict evidence/timestamp validation, and an optional fail-if-incomplete exit path.
- Guarded release-qualification evidence recorder for genuine maintainer-observed results.
- Repository-local integrity audit for required files, version consistency, Web/PWA semantics, continuity archives, temporary-helper cleanup, and local Markdown links.
- Web/PWA install metadata hardening: stable relative identity/start/scope, source language/direction, categories, regular/maskable 192/512 icons, mobile/Apple install metadata, and focused regressions.
- Android distribution regression coverage protecting both release APK and Google Play AAB commands, outputs, SHA-256 sidecars, and hosted artifact packaging.
- Final documentation index separating current Version 2.0.12 source status from historical verification evidence.
- Complete executable/build documentation for Android APK/AAB, iOS compilation/signing boundaries, Web/PWA, Windows, macOS, Linux, checksums, packaging, and release qualification.

### Changed

- Project package/build version is now `2.0.12+2012` and user-facing marketing version is `2.0.12`.
- Windows fallback file/product version metadata now matches `2,0,12,2012` / `2.0.12`.
- Release qualification candidate now matches `2.0.12+2012` while retaining all 13 real-world checks as pending until genuine evidence exists.
- `tool/release_readiness.dart` now targets Version 2.0.12 exactly, rejects the previous release line and unrelated patch versions, exposes the release target in JSON, and keeps strict stable promotion fail-closed.
- `ROADMAP.md` is now a completion roadmap: Version 2.0.12 has no active source-feature backlog; previously optional expansion ideas are explicit non-goals unless a future release deliberately adopts them.
- Dependency policy now uses a compatibility-first final freeze rather than last-minute freshness churn. Existing qualified pins are retained unless a concrete fix/security/compatibility need justifies a new validation cycle.
- `SECURITY.md`, README/release documentation, qualification guides, gate-testing guide, audit documentation, and maintainer tooling now describe the Version 2.0.12 line rather than the former Version 1.5 current state.
- Historical Phase 0–30 and Phase 31 continuity are preserved in dedicated archives while `what_changed.md` remains the active Phase 32 completion record.
- Active changelog was reset to a focused Version 2.0.12 record after preserving the previous detailed changelog verbatim in `CHANGELOG_ARCHIVE_PRE_2_0_12.md`.

### Fixed

- Corrected release-readiness process fixtures that still used the previous release version after the Version 2.0.12 migration.
- Corrected timezone-evidence fixture metadata so timestamp validation is tested against the current release target instead of failing early on obsolete version metadata.
- Corrected qualification-status and qualification-recorder fixtures to use `2.0.12+2012`.
- Corrected repository-integrity/current-release regressions that still asserted the former Version 1.5 security/release line.
- Corrected repository audit fixtures to enforce exact Version 2.0.12 package, runtime, qualification, Windows, PWA, and Phase 32 continuity contracts.
- Corrected the current-release test after the roadmap moved from “current release hardening” to the final feature-complete source heading.
- Removed temporary one-shot Phase 30/31/32 maintenance/finalizer paths from the permanent repository contract and regression-guarded their absence.
- Hardened Web/PWA audit behavior to fail closed on manifest identity/icon drift and required HTML metadata drift.

### Maintained release/toolchain boundaries

- Flutter workflows remain pinned to the reviewed Flutter 3.47.0 execution baseline with composite-action caching disabled.
- Android remains on the accepted AGP 9.1.0 / Kotlin Android 2.4.10 / Gradle 9.7.0 / JDK 17 compatibility baseline for Version 2.0.12.
- The previously reproduced AGP 9.3.x/JDK-17 lint problem is treated as a future toolchain-maintenance concern, not unfinished Version 2.0.12 product work.
- Android hosted builds produce both APK and AAB with SHA-256 sidecars; Linux, Windows, macOS, and unsigned iOS hosted outputs remain checksummed qualification inputs.
- GitHub Actions remain pinned to reviewed immutable commit revisions and read-only workflows avoid persisting checkout credentials.

### Verification boundary

The repository-owned formatter automation produced commit:

```text
a2372253f5eb4dde16339e6c913e8581408311fc
style: format Dart sources tests and tools
```

This proves the maintained Dart formatter parsed and normalized the then-current `lib/`, `test/`, and `tool/` tree. It does **not** substitute for a complete analyzer/test/Web/native workflow result.

The latest previously accepted complete automated/native evidence remains the historical Version 1.5 baseline:

```text
CI run: 32018055661
Tests: 235/235
Dart files formatter-clean: 106
Native matrix run: 32015893841
```

Those results remain historical evidence and are not relabeled as Version 2.0.12 verification. A complete maintained Version 2.0.12 workflow result must be actually observed before it supersedes them.

### Stable-release boundary

Version 2.0.12 source completion does not bypass the release evidence gate. Stable distribution remains closed until all 13 real-world checks are genuinely completed with verifiable evidence and explicit-timezone timestamps, all required current automated/native gates are green on the exact release commit, and:

```bash
dart run tool/release_readiness.dart --stable
```

exits successfully on that exact commit.

### Source-completion rule

There is no active Version 2.0.12 feature backlog after this source-completion pass.

Future changes belong to one of these categories:

- reproducible bug fix;
- security fix;
- accessibility/localization correction for implemented behavior;
- dependency/toolchain/platform/CI maintenance after compatibility review;
- documentation correction;
- genuine manual-qualification evidence update;
- deliberately scoped future release.

New product functionality must start a new release scope rather than silently expanding completed Version 2.0.12.
