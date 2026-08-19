# Changelog

All notable current changes to 2048 Nova are documented here.

The detailed pre-Version-2.0.12 development changelog is preserved verbatim in [`CHANGELOG_ARCHIVE_PRE_2_0_12.md`](CHANGELOG_ARCHIVE_PRE_2_0_12.md). Historical phase/run evidence is also preserved in `docs/VERIFICATION.md`, the phase verification records, and the `what_changed` continuity archives.

## [Unreleased]

**Current target:** Version **2.0.12**  
**Flutter package/build version:** `2.0.12+2012`  
**Source scope:** feature-complete  
**Real-world manual qualification:** `0/13` recorded passed evidence

This section describes the source-complete Version 2.0.12 candidate and its final integration hardening. It does not claim that physical-device, assistive-technology, signing/provisioning, external-handler, PWA-install, native-branding, or store-distribution qualification has been completed.

### Added

- Custom Game Builder integrated into the Version 2.0.12 source line with validated 3×3–8×8 local configurations, supported Target/Endless/Timed/Move Limit styles, optional deterministic seed, bounded local preset persistence, and a separate custom-session trust marker.
- Saved custom-preset **Edit**, safe rename, **Duplicate**, **Cancel edit**, and confirmed-delete workflows. Duplicate loads an unsaved uniquely named copy and does not write storage until explicit Save.
- Responsive Custom Game Builder preset-action menu and focused English/Hindi, narrow-screen, and increased-text-scale widget regressions.
- Final Version 2.0.12 integration audit in `docs/FINAL_2_0_12_INTEGRATION_AUDIT.md`, recording why older Custom Game Builder CI from the Version 1.5 base cannot be relabeled as current same-commit evidence.
- Current architecture walkthrough in `docs/ARCHITECTURE_WALKTHROUGH.md` covering startup, deterministic gameplay, persistence, custom games, backups, replay, solvers, localization/accessibility, platform runners, and release boundaries.
- Deep error/diagnosis reference in `docs/ERROR_REFERENCE.md`.
- Zero-to-safe-change contributor tutorial in `docs/NEW_CONTRIBUTOR_TUTORIAL.md`.
- Complete documentation audit checklist in `docs/DOCUMENTATION_AUDIT_CHECKLIST.md`.
- Linux native toolchain handbook in `docs/setup/LINUX_NATIVE_TOOLCHAIN.md`.
- Final Version 2.0.12 source-completion audit in `docs/FINAL_2_0_12_SOURCE_AUDIT.md`.
- Post-completion maintenance/non-goal policy in `docs/MAINTENANCE_POLICY.md` so normal maintenance is not mistaken for unfinished product scope.
- Dedicated `tool/source_completion_audit.dart` with JSON/fixture support and permanent CI execution.
- Self-protection for the completion audit: it requires its own CLI, regression suite, human guide, maintainer-tool index, continuity/changelog archives, and permanent CI wiring to remain present.
- Process-level source-completion audit regressions covering clean completion, package/candidate drift, restored optional backlog, missing final-doc indexing, unresolved product/tool TODO/FIXME comments, missing CI wiring, obsolete current Version 1.5 metadata, and invalid CLI arguments.
- Version 2.0.12 source-integrity enforcement across package metadata, in-app version, Windows fallback resources, qualification candidate, release tooling, roadmap, current-state tests, and documentation.
- Read-only release-qualification status reporting for the canonical 13-check manifest, including JSON output, pending-only detail filtering, strict evidence/timestamp validation, and optional fail-if-incomplete behavior.
- Guarded release-qualification evidence recorder for genuine maintainer-observed results.
- Repository-local integrity audit for required files, version consistency, Web/PWA semantics, continuity archives, temporary-helper cleanup, and local Markdown links.
- Web/PWA install metadata hardening: stable relative identity/start/scope, source language/direction, categories, regular/maskable 192/512 icons, mobile/Apple install metadata, and focused regressions.
- Android distribution regression coverage protecting both release APK and Google Play AAB commands, outputs, SHA-256 sidecars, and hosted artifact packaging.
- Complete executable/build documentation for Android APK/AAB, iOS compilation/signing boundaries, Web/PWA, Windows, macOS, Linux, checksums, packaging, and release qualification.

### Changed

- Custom Game Builder is now documented as current Version `2.0.12+2012` behavior rather than as a separate Version 1.6 feature branch outside the current candidate.
- `docs/VERSION_1_6_ROADMAP.md` is retained as an explicit historical development record instead of a current roadmap.
- Saved custom-preset actions now use a compact popup menu so long preset summaries and increased text scaling have more horizontal room.
- The canonical docs index, setup index, player guide, feature reference, changelog, and continuity records now expose the integrated custom-game workflows and final diagnostic/contributor/toolchain guides.
- Phase 33 detailed continuity is preserved in `what_changed_archive_phase_33.md`; `what_changed.md` now records the Phase 34 final-integration maintenance stream while retaining the Phase 32 canonical release/source-completion marker required by repository integrity checks.
- Project package/build version is `2.0.12+2012` and user-facing marketing version is `2.0.12`.
- Windows fallback file/product version metadata matches `2,0,12,2012` / `2.0.12`.
- Release qualification candidate matches `2.0.12+2012` while retaining all 13 real-world checks as pending until genuine evidence exists.
- `tool/release_readiness.dart` targets Version 2.0.12 exactly, rejects the previous release line and unrelated patch versions, exposes the release target in JSON, and keeps strict stable promotion fail-closed.
- `tool/source_completion_audit.dart` scans maintained Dart in `lib/`, `test/`, and `tool/` for unresolved TODO/FIXME line comments instead of limiting that guard to product source only.
- `ROADMAP.md` is a completion roadmap: Version 2.0.12 has no active source-feature backlog; previously optional expansion ideas are explicit non-goals unless a future release deliberately adopts them.
- Dependency policy uses a compatibility-first final freeze rather than last-minute freshness churn. Existing qualified pins are retained unless a concrete fix/security/compatibility need justifies a new validation cycle.
- `SECURITY.md`, README/release documentation, qualification guides, gate-testing guide, audit documentation, and maintainer tooling describe the Version 2.0.12 line rather than the former Version 1.5 current state.
- Active changelog remains a focused Version 2.0.12 record after preserving the earlier detailed changelog verbatim in `CHANGELOG_ARCHIVE_PRE_2_0_12.md`.

### Fixed

- Fixed Custom Game Builder edit/duplicate selector state: `DropdownButtonFormField.initialValue` could retain the original FormField selection after a preset was loaded. Dynamic selector keys now recreate the affected field state so the visible style, board size, target, and time/move limit match the loaded preset.
- Added regressions that assert the visible selector state after Edit, Duplicate, and Cancel edit, not only the eventual stored model.
- Prevented an edited preset from overwriting a different saved preset when the requested rename conflicts case-insensitively.
- Corrected stale Custom Game Builder documentation that still declared Version 1.6/Version 1.5 as the current feature/release boundary after the feature had already been integrated into Version 2.0.12.
- Corrected a stale user-guide reference to “stable 1.0.0”; current stable promotion is governed by Version 2.0.12 same-commit automation plus the canonical 13-check real-world qualification manifest.
- Corrected release-readiness process fixtures that still used the previous release version after the Version 2.0.12 migration.
- Corrected timezone-evidence fixture metadata so timestamp validation is tested against the current release target instead of failing early on obsolete version metadata.
- Corrected qualification-status and qualification-recorder fixtures to use `2.0.12+2012`.
- Corrected repository-integrity/current-release regressions that still asserted the former Version 1.5 security/release line.
- Corrected repository audit fixtures to enforce exact Version 2.0.12 package, runtime, qualification, Windows, PWA, and Phase 32 continuity contracts.
- Corrected the current-release test after the roadmap moved from “current release hardening” to the final feature-complete source heading.
- Corrected a completion-audit false-positive risk where documentation explaining historical/current-version validation could be mistaken for actually declaring Version 1.5 current.
- Removed temporary one-shot Phase 30/31/32 maintenance/finalizer paths from the permanent repository contract and regression-guarded their absence.
- Hardened Web/PWA audit behavior to fail closed on manifest identity/icon drift and required HTML metadata drift.

### Maintained release/toolchain boundaries

- No new runtime dependency was added for the final Custom Game Builder edit/duplicate/responsive work; existing Flutter/domain/storage primitives are reused.
- Flutter workflows remain pinned to the reviewed Flutter 3.47.0 execution baseline with composite-action caching disabled.
- Android remains on the accepted AGP 9.1.0 / Kotlin Android 2.4.10 / Gradle 9.7.0 / JDK 17 compatibility baseline for Version 2.0.12.
- The previously reproduced AGP 9.3.x/JDK-17 lint problem is treated as a future toolchain-maintenance concern, not unfinished Version 2.0.12 product work.
- Android hosted builds are expected to produce both APK and AAB with SHA-256 sidecars; Linux, Windows, macOS, and unsigned iOS hosted outputs remain checksummed qualification inputs when the maintained workflow succeeds.
- GitHub Actions remain pinned to reviewed immutable commit revisions and read-only workflows avoid persisting checkout credentials.

### Verification boundary

The Custom Game Builder feature had green formatter/analyzer/test/Web/native evidence before its final integration, but that successful feature-branch workflow identified the package candidate as:

```text
1.5.0+15
```

It is therefore historical feature evidence, not same-commit Version `2.0.12+2012` verification.

The final integration work is being submitted through PR #25 on `final/v2.0.12-integration-hardening`. The maintained current checks must be observed on the exact final PR head before merge/promotion. No green formatter, analyzer, test, Web, dependency-review, or native result is inferred merely because commits were pushed or an older workflow passed.

The latest previously accepted complete automated/native baseline remains historical Version 1.5 evidence. It is not relabeled as Version 2.0.12 verification.

### Stable-release boundary

Version 2.0.12 source completion does not bypass the release evidence gate. Stable distribution remains closed until all 13 real-world checks are genuinely completed with verifiable evidence and explicit-timezone timestamps, all required current automated/native gates are green on the exact release commit, and:

```bash
dart run tool/release_readiness.dart --stable
```

exits successfully on that exact commit.

### Source-completion rule

There is no active Version 2.0.12 hidden feature backlog after this integration-hardening pass.

Future changes belong to one of these categories:

- reproducible bug fix;
- security fix;
- accessibility/localization correction for implemented behavior;
- dependency/toolchain/platform/CI maintenance after compatibility review;
- documentation correction;
- genuine manual-qualification evidence update;
- deliberately scoped future release.

New product functionality must start a new release scope rather than silently expanding completed Version 2.0.12.
