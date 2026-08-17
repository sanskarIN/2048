# 2048 Nova Documentation

This directory is the user, technical, development, platform, and release documentation set for 2048 Nova. The application is a Flutter/Dart, offline-first 2048 implementation with deterministic game rules, validated local persistence, multiple modes, trusted per-mode records, English/Hindi localization, accessibility controls, bounded read-only Move Replay, portable spectator-only Full Replay Archives, an isolated Heuristic/Expectimax Auto Play Demo with deterministic solver benchmarks, portable current-game backup/restore, and offline shareable seeded challenge codes.

## Start here

| Document | Purpose |
| --- | --- |
| [`../README.md`](../README.md) | Project overview, features, setup, controls, build commands, links, and support. |
| [`USER_GUIDE.md`](USER_GUIDE.md) | Complete player guide for rules, controls, modes, Undo, Hint, Move Replay, Full Replay Archive, Auto Play, Backup, Challenge Codes, language/settings, and data controls. |
| [`FAQ.md`](FAQ.md) | Common user/developer questions about rules, modes, saves, replay systems, Auto Play, Backup, Challenge Codes, language, privacy, accessibility, platforms, and release status. |
| [`ARCHITECTURE.md`](ARCHITECTURE.md) | Layer boundaries, state flow, persistence responsibilities, trust boundaries, and feature architecture. |
| [`GAME_ENGINE.md`](GAME_ENGINE.md) | Exact move/merge/spawn rules, deterministic RNG, terminal-state behavior, and invariants. |
| [`GAME_MODES.md`](GAME_MODES.md) | All supported game modes, board sizes, targets, timers, move limits, and Daily Challenge behavior. |
| [`MODE_RECORDS.md`](MODE_RECORDS.md) | Trusted local per-mode best score/highest-tile records, migration, reset behavior, and imported-backup isolation. |
| [`CHALLENGE_CODES.md`](CHALLENGE_CODES.md) | Shareable seeded challenge format, deterministic behavior, validation, checksum, and trust model. |
| [`LOCALIZATION.md`](LOCALIZATION.md) | English/Hindi locale architecture, persisted language selection, fallback rules, contributor guidance, privacy, and accessibility boundaries. |
| [`DATA_STORAGE.md`](DATA_STORAGE.md) | Local storage keys, save schemas, bounded collections, corruption recovery, replay capture persistence, and reset behavior. |
| [`BACKUP_AND_RESTORE.md`](BACKUP_AND_RESTORE.md) | Portable current-game backup format, clipboard workflow, strict validation, and unranked-import policy. |
| [`REPLAY_ARCHIVES.md`](REPLAY_ARCHIVES.md) | Full-session deterministic replay capture, portable JSON protocol, 4,096-event bound, spectator-only import, validation, privacy, and trust model. |
| [`HINT_SOLVER.md`](HINT_SOLVER.md) | Deterministic heuristic Hint plus isolated Heuristic/Expectimax Auto Play behavior and limitations. |
| [`SOLVER_BENCHMARKS.md`](SOLVER_BENCHMARKS.md) | Bounded expectimax design, node limits, sandbox trust boundary, deterministic benchmark library, and CLI harness. |
| [`ACCESSIBILITY.md`](ACCESSIBILITY.md) | Implemented accessibility features and remaining manual assistive-technology checks, including localized semantics. |
| [`PRIVACY.md`](PRIVACY.md) | Offline-first data behavior, language/localization, clipboard, external links, local storage, both replay systems, Auto Play, Backup, and Challenge Code privacy. |
| [`DEVELOPMENT.md`](DEVELOPMENT.md) | Development environment, repository layout, localization practices, local workflow, testing, and contribution practices. |
| [`BUILDING_EXECUTABLES.md`](BUILDING_EXECUTABLES.md) | Complete artifact matrix and release-build handbook for Android APK/AAB, iOS app/IPA, Web/PWA, Windows, macOS, Linux, packaging, checksums, signing boundaries, and qualification. |
| [`build/README.md`](build/README.md) | Dedicated per-platform build manuals and packaging/checksum guide. |
| [`PLATFORMS.md`](PLATFORMS.md) | Android/iOS/Web/Windows/macOS/Linux setup, build commands, hosted verification, locale behavior, and signing/distribution boundaries. |
| [`ANDROID_TOOLCHAIN.md`](ANDROID_TOOLCHAIN.md) | Maintained AGP/Kotlin/Gradle baseline, AGP 9.3 deferral evidence, upgrade acceptance rules, and revisit criteria. |
| [`CI_CD.md`](CI_CD.md) | Permanent GitHub Actions workflows, quality gates, native build matrix, and automation boundaries. |
| [`WORKFLOW_SECURITY.md`](WORKFLOW_SECURITY.md) | Immutable Action revisions, frozen Flutter/JDK execution, least-privilege checkout credentials, reproducibility limits, and repository-setting boundaries. |
| [`TESTING.md`](TESTING.md) | Automated test strategy, regression areas, and current evidence. |
| [`VERIFICATION.md`](VERIFICATION.md) | Compact current automated verification record. |
| [`PHASE_28_VERIFICATION.md`](PHASE_28_VERIFICATION.md) | Focused immutable-workflow, frozen-toolchain, least-privilege, 225-test, Dependency Review, branding, and native-matrix evidence. |
| [`PHASE_27_VERIFICATION.md`](PHASE_27_VERIFICATION.md) | Focused Android toolchain experiment, AGP 9.3 deferral, accepted Kotlin/Gradle subset, 217-test, and post-merge native-matrix evidence. |
| [`PHASE_26_VERIFICATION.md`](PHASE_26_VERIFICATION.md) | Focused checkout v7, Dependency Review v5, 216-test, Web, and cross-platform Actions-runtime verification record. |
| [`PHASE_25_VERIFICATION.md`](PHASE_25_VERIFICATION.md) | Focused Version 1.5 SDK/dependency, supply-chain, 215-test, Web, and post-maintenance native-matrix verification record. |
| [`PHASE_18_VERIFICATION.md`](PHASE_18_VERIFICATION.md) | Focused Phase 18 bounded-expectimax, 161-test, Web/WASM, and native-matrix acceptance record. |
| [`PHASE_17_VERIFICATION.md`](PHASE_17_VERIFICATION.md) | Focused Phase 17 trusted per-mode-record acceptance history and final 144-test Web/WASM gate. |
| [`RELEASE_QUALIFICATION.md`](RELEASE_QUALIFICATION.md) | Evidence manifest, candidate/stable readiness commands, fail-closed promotion rules, and stable-release sequence. |
| [`RELEASE_GATE_TESTING.md`](RELEASE_GATE_TESTING.md) | Process-level fixture coverage for candidate/stable release-gate acceptance and rejection paths. |
| [`RELEASE_ARTIFACTS.md`](RELEASE_ARTIFACTS.md) | Checksummed hosted native qualification artifacts, retention, verification, packaging, and manual-evidence boundaries. |
| [`RELEASE_CHECKLIST.md`](RELEASE_CHECKLIST.md) | Automated and manual qualification checklist before stable release. |
| [`BRANDING.md`](BRANDING.md) | Logo/icon/splash sources and generated platform assets. |
| [`DEPENDENCIES.md`](DEPENDENCIES.md) | Runtime/development dependency rationale and licensing notes. |
| [`SUPPLY_CHAIN.md`](SUPPLY_CHAIN.md) | SDK floors, dependency update automation, dependency review, lockfile policy, code ownership, and acceptance checks. |
| [`TROUBLESHOOTING.md`](TROUBLESHOOTING.md) | Common setup, build, save, input, replay, backup, challenge-code, localization, and platform troubleshooting. |
| [`../CONTRIBUTING.md`](../CONTRIBUTING.md) | Contribution architecture, localization, quality, testing, documentation, and PR requirements. |
| [`../SECURITY.md`](../SECURITY.md) | Security-reporting and current trust boundaries. |
| [`../SUPPORT.md`](../SUPPORT.md) | User/developer support channels and report information. |
| [`../ROADMAP.md`](../ROADMAP.md) | Completed and optional future work. |
| [`../CHANGELOG.md`](../CHANGELOG.md) | Release-facing history. |
| [`../what_changed.md`](../what_changed.md) | Detailed chronological implementation and verification log. |

## Documentation principles

The documentation follows behavior implemented in the repository rather than describing aspirational features as complete. Historical verification entries are kept as historical evidence; newer entries supersede older test counts for the current source state.

Automated build success does not imply that every physical device, assistive-technology combination, app-store signing configuration, localized layout, clipboard implementation, replay length, or long-running user session has been manually validated. Those boundaries are stated explicitly in the release and verification documents.

A feature should not be documented as ranked/trusted when its source policy makes it unranked or spectator-only, a configured platform should not be described as release-qualified solely because its runner files exist, and a locale should not be described as manually qualified solely because automated localization tests pass.

## Source-of-truth boundaries

- **Game rules:** `lib/domain/game_engine.dart`, `lib/domain/game_state.dart`, and `lib/domain/game_types.dart`.
- **Localization:** `lib/core/localization/nova_localizations.dart` and `lib/core/localization/hindi_translations.dart`.
- **Challenge-code codec:** `lib/domain/challenge_code.dart`.
- **Portable backup codec:** `lib/domain/game_backup.dart`.
- **Bounded Move Replay timeline:** `lib/domain/replay_timeline.dart`.
- **Full Replay Archive protocol/player:** `lib/domain/replay_archive.dart`.
- **Full replay capture orchestration:** `lib/app/state/app_controller.dart` and `lib/data/local_store.dart`.
- **Auto Play sandbox:** `lib/domain/autoplay_session.dart`.
- **Advanced solver:** `lib/domain/expectimax_solver.dart`.
- **Solver benchmark library:** `lib/domain/solver_benchmark.dart`.
- **Local persistence:** `lib/data/local_store.dart`.
- **Player session/ranking/settings orchestration:** `lib/app/state/app_controller.dart`.
- **Per-mode record presentation:** `lib/features/statistics/statistics_screen.dart`.
- **Application routes/localization delegates:** `lib/app/nova_app.dart`.
- **Current package/version:** `pubspec.yaml`.
- **Automated quality gates:** `.github/workflows/`.
- **Executable/distribution build documentation:** `BUILDING_EXECUTABLES.md` plus `build/`; actual hosted commands remain in `.github/workflows/ci.yml` and `.github/workflows/platform-builds.yml`.
- **Hosted native qualification artifacts:** `.github/workflows/platform-builds.yml`; handling policy is `RELEASE_ARTIFACTS.md`.
- **Stable-release evidence gate:** `tool/release_readiness.dart` plus `release_qualification.json`; human procedure is `RELEASE_QUALIFICATION.md`.

When a document and source code disagree, review current source/tests and correct the documentation in the same change. Do not silently change implementation facts in documentation to match an intended-but-unimplemented design.

## Verification hierarchy

For current release confidence, consult in this order:

1. [`VERIFICATION.md`](VERIFICATION.md) for the compact latest confirmed automated state.
2. [`TESTING.md`](TESTING.md) for coverage intent and regression areas.
3. [`RELEASE_CHECKLIST.md`](RELEASE_CHECKLIST.md) for automated plus remaining manual qualification.
4. [`../what_changed.md`](../what_changed.md) for the complete chronological record, including intermediate failures and fixes.

## Project identity

- Project: **2048 Nova**
- Repository: https://github.com/sanskarIN/2048
- Creator branding: **Made by the Sanskar**
- License: MIT
- Business: `sanskarin@outlook.in`, `sanskarin.business@gmail.com`
- Support: `supportramsandesh@gmail.com`
- Buy Me a Coffee: https://buymeacoffee.com/sanskarIN

## Phase 20 file backup documentation

- [`FILE_BACKUPS.md`](FILE_BACKUPS.md) — `.nova2048` / `.json` Game Backup file transport, byte bounds, platform behavior, macOS sandbox scope, trust model, dependency boundary, tests, and manual qualification.
- [`BACKUP_AND_RESTORE.md`](BACKUP_AND_RESTORE.md) — shared clipboard/file backup envelope and persistent unranked restore policy.

Phase 20 verification: [`PHASE_20_VERIFICATION.md`](PHASE_20_VERIFICATION.md) records file-backup implementation scope, transparent CI/native failures, the AGP-9 built-in-Kotlin repair, final 189-test CI, the fully green cross-platform native matrix, and remaining real-environment release boundaries.

## Phase 21 documentation note

Challenge Code documentation now includes offline QR rendering of the exact `NOVA1` text, presentation/trust/privacy/accessibility boundaries, focused tests, and real-device scan qualification. See [`CHALLENGE_CODES.md`](CHALLENGE_CODES.md), [`ACCESSIBILITY.md`](ACCESSIBILITY.md), [`PRIVACY.md`](PRIVACY.md), [`DEPENDENCIES.md`](DEPENDENCIES.md), and the Phase 21 verification record once finalized.

## Phase 21 verification

- [`PHASE_21_VERIFICATION.md`](PHASE_21_VERIFICATION.md) — focused implementation, helper-failure, formatter, 194-test CI, native-build, QR trust/privacy/accessibility, and manual optical-scan qualification evidence for offline Challenge Code QR rendering.
