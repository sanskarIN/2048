# 2048 Nova — Final Active Continuity

This is the active Version 2.0.12 source/release continuity record. Detailed historical development is preserved in:

- [`what_changed_archive_phase_00_30.md`](what_changed_archive_phase_00_30.md) — Phases 0–30.
- [`what_changed_archive_phase_31.md`](what_changed_archive_phase_31.md) — complete Phase 31 qualification-status and Web/PWA hardening record.
- [`CHANGELOG_ARCHIVE_PRE_2_0_12.md`](CHANGELOG_ARCHIVE_PRE_2_0_12.md) — verbatim pre-2.0.12 active changelog history.

## Current repository state

- **Current phase:** Phase 32 — Version 2.0.12 migration and final source completion.
- **Marketing version:** `2.0.12`.
- **Flutter package/build version:** `2.0.12+2012`.
- **Source status:** feature-complete for the declared offline-first puzzle-game scope.
- **Repository:** `https://github.com/sanskarIN/2048`.
- **Branch:** `main`.
- **Manual evidence:** the stable qualification boundary remains 0/13; no physical-device, assistive-technology, real browser/PWA lifecycle, external-handler, native-branding, signing/provisioning, or store evidence has been fabricated.
- **Historical automated baseline:** Version 1.5 CI run `32018055661` with **235/235 tests** and **106 Dart files formatter-clean**; native matrix run `32015893841`. These remain historical baseline evidence until a complete maintained Version 2.0.12 verification result is actually observed and recorded.
- **Repository governance:** issue #10 is closed as not planned for the 2.0.12 source scope; issue #12 remains open because `main` branch protection is an external GitHub repository setting and is still not enabled.

The exact phrase `stable qualification boundary remains 0/13` is retained as a regression/audit contract while the live manifest remains pending.

# Phase 32 — Version 2.0.12 finalization

Date: **2026-08-19**

## Version and release contract

Version surfaces are synchronized:

```text
pubspec package/build: 2.0.12+2012
ProjectInfo marketing: 2.0.12
Windows numeric fallback: 2,0,12,2012
Windows string fallback: 2.0.12
Qualification candidate: 2.0.12+2012
Release-readiness target: 2.0.12
```

The release gate rejects the historical release line and unrelated patch versions, requires candidate/package alignment, retains exactly 13 manual evidence IDs, and keeps strict stable promotion fail-closed.

## Hidden migration drift fixed

The final migration audit corrected old current-state assumptions in:

- release-readiness fixtures;
- release-evidence timestamp fixture;
- qualification status/recorder fixtures;
- repository-integrity assertions;
- security supported-version text;
- release qualification/checklist/testing guides;
- dependency/tooling documentation;
- current-release regression tests;
- Windows resource metadata;
- repository audit fixtures.

This prevents a simple version bump from passing while hidden source/tests/docs still describe an older release line.

## Source feature completion

`ROADMAP.md` now identifies Version 2.0.12 as a **feature-complete source target** and contains no active post-2.0.12 feature backlog.

The completed product scope includes deterministic gameplay/RNG, ten modes, save/resume, bounded Undo, Daily Challenge, statistics/achievements/per-mode records, Hint, isolated Heuristic/Expectimax Auto Play, Move Replay, Full Replay Archives, Game Backup, Challenge Codes + QR, English/Hindi localization, accessibility controls, themes/settings, Android/iOS/Web/Windows/macOS/Linux runners, and complete build/release/open-source tooling/documentation.

Former “later” ideas are explicit non-goals unless a future release deliberately adopts them. They are not unfinished Version 2.0.12 work.

## Final source-completion layer

Added permanent finalization assets:

- [`docs/FINAL_2_0_12_SOURCE_AUDIT.md`](docs/FINAL_2_0_12_SOURCE_AUDIT.md);
- [`docs/MAINTENANCE_POLICY.md`](docs/MAINTENANCE_POLICY.md);
- [`docs/SOURCE_COMPLETION_AUDIT.md`](docs/SOURCE_COMPLETION_AUDIT.md);
- `tool/source_completion_audit.dart`;
- `test/source_completion_audit_cli_test.dart`.

The source-completion audit fails closed on:

- package/candidate drift;
- missing final audit/maintenance/index documents;
- restoration of an active optional-feature backlog;
- stale current Version 1.5 metadata in current release-facing documents;
- unresolved `TODO`/`FIXME` line comments in production `lib/` Dart source;
- malformed/unknown CLI arguments.

Permanent CI now runs both:

```bash
dart run tool/repository_audit.dart --json
dart run tool/source_completion_audit.dart --json
```

## Repository-integrity expansion

The repository audit now requires:

- final source audit;
- maintenance policy;
- source-completion audit guide/tool;
- archived pre-2.0.12 changelog;
- existing version/release/PWA/continuity/open-source/build/workflow assets.

Its process-level fixture was expanded to preserve clean and fail-closed coverage.

## Android APK/AAB distribution protection

The maintained Platform Builds workflow already builds and packages:

- Android release APK;
- Android release AAB for Google Play;
- SHA-256 sidecar for each;
- both payloads and both sidecars in the Android qualification artifact.

`test/android_distribution_workflow_test.dart` protects those commands, paths, checksums, and fail-closed artifact behavior.

## Changelog/documentation finalization

The former long active changelog is preserved verbatim in `CHANGELOG_ARCHIVE_PRE_2_0_12.md`.

Current `CHANGELOG.md` now focuses on the source-complete Version 2.0.12 candidate, and `docs/README.md` clearly separates current release documents from historical Phase/Version 1.5 verification records.

The complete current documentation set now covers user behavior, architecture, engine/modes, persistence, backups/replays/challenges, localization/accessibility/privacy/security, dependencies/supply chain, development/testing/troubleshooting, every supported executable/build target, CI/workflow security, release qualification, source completion, and maintenance policy.

## Dependency/toolchain final freeze

The final source freeze is compatibility-first. Existing pins remain unless a concrete defect/security/compatibility requirement justifies another cross-platform qualification cycle.

The accepted Android baseline remains:

```text
AGP 9.1.0
Kotlin Android 2.4.10
Gradle 9.7.0
JDK 17
```

Issue #10 is closed as **not planned** for Version 2.0.12. This records a deliberate baseline decision, not a claim that the prior AGP 9.3.x/JDK-17 lint failure was fixed.

## Formatter evidence

Repository-owned Format Dart automation has normalized the final Dart source/test/tool additions. Important formatter commits include:

```text
a2372253  style: format Dart sources tests and tools
254dc2ed  style: format Dart sources tests and tools
c70b464d  style: format Dart sources tests and tools
```

The latest of these follows the final source-completion audit/repository-audit/test additions. Formatter success proves Dart formatter parsing/normalization for those files; it does not by itself prove analyzer/tests/Web/native builds.

## Final source-completion commit sequence

The final pass after the initial Version 2.0.12 migration includes:

```text
9fc43029  docs: add final Version 2.0.12 source audit
14ad9fce  docs: add post-completion maintenance policy
271bb28a  docs: mark Version 2.0.12 source feature complete
f3592e63  docs: refresh Version 2.0.12 dependency policy
82ff11a6  test: guard final Version 2.0.12 source completion
49212e9f  feat: add final source completion audit
f2bea630  test: cover final source completion audit
d798bc4d  ci: enforce final source completion contract
37ab4a0a  docs: document source completion audit
b220dd42  docs: index final source completion audit tool
fac8a8a7  docs: finalize Version 2.0.12 documentation index
318bd744  docs: archive pre-2.0.12 changelog history
254dc2ed  style: format Dart sources tests and tools
8013d14d  docs: finalize active Version 2.0.12 changelog
1c6c9624  feat: require final source completion assets in repository audit
a9f668a4  test: align repository audit fixtures with final completion assets
af7dd63e  docs: finalize repository audit contract for 2.0.12
93697d57  docs: finalize Phase 32 source completion record
c70b464d  style: format Dart sources tests and tools
```

Earlier Phase 32 version-migration commits remain preserved in Git history and the Phase 32 documentation.

## External release qualification boundary

Source completion does not mark any of the 13 manual records passed. They still require genuine representative environments for Android/iOS, input/responsiveness, assistive technologies, long sessions, Auto Play, Challenge Codes, replays, backup/file handlers, browser/PWA/external handlers, native branding, and signing/provisioning/store metadata.

Only actual observed evidence may update those records.

## Repository-settings boundary

Issue #12 remains the only known open repository-governance issue: `main` branch protection/rulesets must be enabled in GitHub settings. Tracked files such as CI/CODEOWNERS cannot truthfully replace that setting, and the connected GitHub tool surface does not expose a branch-protection/ruleset write action.

This is not missing product/source functionality.

## Automated verification boundary before final PR

At this point the final Dart completion/audit additions have been formatter-normalized, but the complete current Version 2.0.12 analyzer/test/Web/native matrix has not yet been recorded in this file.

The final step is an explicit verification PR touching application source so both permanent CI and Platform Builds run against the completed repository. Only observed successful runs will replace the historical Version 1.5 automated baseline.
