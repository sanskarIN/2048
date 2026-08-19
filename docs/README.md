# 2048 Nova Documentation

This directory is the canonical user, developer, architecture, platform, privacy, security, build, testing, maintenance, and release-documentation set for **2048 Nova**.

Current source identity:

```text
Marketing version: 2.0.12
Flutter package/build version: 2.0.12+2012
Source scope: feature-complete
Manual real-world qualification: 0/13 recorded passed evidence
```

Source completion and stable distribution are intentionally separate states. The application source can be feature-complete while physical-device, assistive-technology, external-handler, signing/provisioning, and store qualification remains pending.

## Start here

| Document | Purpose |
| --- | --- |
| [`../README.md`](../README.md) | Project overview, features, setup, controls, platforms, build commands, links, and support. |
| [`FINAL_2_0_12_SOURCE_AUDIT.md`](FINAL_2_0_12_SOURCE_AUDIT.md) | Final source-level completion verdict, version consistency, dependency freeze, source/release boundary, and post-completion rule. |
| [`MAINTENANCE_POLICY.md`](MAINTENANCE_POLICY.md) | What may change after source completion, compatibility-first dependency policy, non-goals, and future-release rule. |
| [`PHASE_32_VERSION_2_0_12.md`](PHASE_32_VERSION_2_0_12.md) | Version 2.0.12 package/runtime/release-gate migration and verification boundary. |
| [`../ROADMAP.md`](../ROADMAP.md) | Feature-complete 2.0.12 scope, external qualification boundary, non-goals, and design guardrails. |
| [`RELEASE_CHECKLIST.md`](RELEASE_CHECKLIST.md) | Automated and real-environment checks required before qualified stable distribution. |
| [`RELEASE_QUALIFICATION.md`](RELEASE_QUALIFICATION.md) | Evidence manifest, candidate/stable release gates, and fail-closed promotion procedure. |
| [`VERIFICATION.md`](VERIFICATION.md) | Latest accepted automated evidence record; historical Version 1.5 evidence remains historical until superseded by observed 2.0.12 results. |

## Player and behavior documentation

| Document | Purpose |
| --- | --- |
| [`USER_GUIDE.md`](USER_GUIDE.md) | Complete player guide for rules, modes, controls, Undo, Hint, replays, Auto Play, backups, Challenge Codes, settings, and data controls. |
| [`FAQ.md`](FAQ.md) | Common player/developer questions and release-status explanations. |
| [`GAME_ENGINE.md`](GAME_ENGINE.md) | Exact move/merge/spawn rules, deterministic RNG, terminal-state behavior, and invariants. |
| [`GAME_MODES.md`](GAME_MODES.md) | Classic, Quick, Extended, Challenge, Endless, Target, Time Challenge, Move Limit, Daily, and Zen behavior. |
| [`CHALLENGE_CODES.md`](CHALLENGE_CODES.md) | Seeded challenge format, validation, QR representation, deterministic behavior, checksum, privacy, and trust boundaries. |
| [`HINT_SOLVER.md`](HINT_SOLVER.md) | Read-only Hint and isolated Heuristic/Expectimax Auto Play design. |
| [`SOLVER_BENCHMARKS.md`](SOLVER_BENCHMARKS.md) | Bounded expectimax, deterministic benchmark library, CLI, and sandbox limits. |
| [`REPLAY_ARCHIVES.md`](REPLAY_ARCHIVES.md) | Full-session replay capture/protocol/player, 4,096-event bound, import validation, spectator-only policy, and trust model. |
| [`MODE_RECORDS.md`](MODE_RECORDS.md) | Trusted local per-mode best score/highest tile, metadata, migration, reset, and import isolation. |
| [`BACKUP_AND_RESTORE.md`](BACKUP_AND_RESTORE.md) | Portable current-game backup format, clipboard flow, validation, and persistent unranked-import policy. |
| [`FILE_BACKUPS.md`](FILE_BACKUPS.md) | User-selected `.nova2048`/`.json` file transport, byte limits, platform handlers, and qualification boundaries. |
| [`DATA_STORAGE.md`](DATA_STORAGE.md) | Local keys, save schemas, bounded histories, corruption recovery, replay capture persistence, and reset behavior. |
| [`PORTABLE_TIMESTAMPS.md`](PORTABLE_TIMESTAMPS.md) | UTC serialization, legacy compatibility, timed-mode integrity, and release-evidence timestamp rules. |

## Accessibility, localization, privacy, and security

| Document | Purpose |
| --- | --- |
| [`ACCESSIBILITY.md`](ACCESSIBILITY.md) | Implemented semantic/input/contrast/motion features and remaining real assistive-technology checks. |
| [`LOCALIZATION.md`](LOCALIZATION.md) | English/Hindi architecture, persisted selection, fallback, contributor rules, privacy, and accessibility boundaries. |
| [`PRIVACY.md`](PRIVACY.md) | Offline-first data behavior, clipboard/file/replay/challenge boundaries, local storage, and external navigation. |
| [`../SECURITY.md`](../SECURITY.md) | Security reporting, input validation, dependency, signing-secret, external-link, and trust boundaries. |
| [`../SUPPORT.md`](../SUPPORT.md) | Player/developer support channels and useful report information. |

## Architecture and development

| Document | Purpose |
| --- | --- |
| [`ARCHITECTURE.md`](ARCHITECTURE.md) | Layer boundaries, state flow, persistence responsibilities, trust boundaries, and feature architecture. |
| [`DEVELOPMENT.md`](DEVELOPMENT.md) | Development environment, repository layout, localization practices, local workflow, testing, and contribution practices. |
| [`TESTING.md`](TESTING.md) | Test strategy, regression areas, evidence rules, and manual/automated boundary. |
| [`DEPENDENCIES.md`](DEPENDENCIES.md) | Runtime/development dependency rationale, Version 2.0.12 freeze policy, exclusions, updates, and licensing. |
| [`SUPPLY_CHAIN.md`](SUPPLY_CHAIN.md) | SDK floors, Dependabot, dependency review, lockfile policy, code ownership, and acceptance checks. |
| [`WORKFLOW_SECURITY.md`](WORKFLOW_SECURITY.md) | Immutable Action revisions, frozen toolchains, credential policy, reproducibility limits, and repository-setting boundaries. |
| [`TROUBLESHOOTING.md`](TROUBLESHOOTING.md) | Setup, analyzer, build, save/input/replay/backup/challenge/localization/platform troubleshooting. |
| [`../CONTRIBUTING.md`](../CONTRIBUTING.md) | Contribution architecture, quality, tests, docs, security/privacy/accessibility, and PR requirements. |
| [`../CODE_OF_CONDUCT.md`](../CODE_OF_CONDUCT.md) | Community participation expectations. |
| [`../AUTHORS.md`](../AUTHORS.md) | Project authorship/credits. |
| [`../LICENSE`](../LICENSE) | MIT license. |

## Platforms, builds, and distribution

| Document | Purpose |
| --- | --- |
| [`BUILDING_EXECUTABLES.md`](BUILDING_EXECUTABLES.md) | Complete executable/artifact handbook for Android APK/AAB, iOS app/IPA boundary, Web/PWA, Windows, macOS, Linux, signing, packaging, and checksums. |
| [`build/README.md`](build/README.md) | Dedicated per-platform build manuals and packaging/checksum index. |
| [`PLATFORMS.md`](PLATFORMS.md) | Android/iOS/Web/Windows/macOS/Linux setup, build commands, locale behavior, hosted-build scope, and signing boundaries. |
| [`PWA.md`](PWA.md) | Web App Manifest/HTML install metadata, deployment, icons, regression coverage, browser storage, and installed-PWA qualification boundary. |
| [`ANDROID_TOOLCHAIN.md`](ANDROID_TOOLCHAIN.md) | Accepted Android AGP/Kotlin/Gradle/JDK baseline, prior experiment evidence, and future upgrade acceptance policy. |
| [`RELEASE_ARTIFACTS.md`](RELEASE_ARTIFACTS.md) | Hosted checksummed qualification artifacts, retention, verification, packaging, and evidence boundaries. |
| [`BRANDING.md`](BRANDING.md) | Logo/icon/splash source assets and generated platform branding. |

## CI, release, and repository-owned tools

| Document | Purpose |
| --- | --- |
| [`CI_CD.md`](CI_CD.md) | Permanent GitHub Actions quality/build/maintenance workflows and evidence boundaries. |
| [`REPOSITORY_AUDIT.md`](REPOSITORY_AUDIT.md) | Repository integrity audit for required files, versions, PWA metadata, cleanup, and local Markdown links. |
| [`SOURCE_COMPLETION_AUDIT.md`](SOURCE_COMPLETION_AUDIT.md) | Final 2.0.12 feature-scope audit for completion docs, roadmap/non-goals, stale current metadata, and unresolved product TODO/FIXME comments. |
| [`RELEASE_GATE_TESTING.md`](RELEASE_GATE_TESTING.md) | Process-level release-readiness fixture testing. |
| [`QUALIFICATION_STATUS.md`](QUALIFICATION_STATUS.md) | Read-only human/JSON reporter for the canonical 13-check manual qualification manifest. |
| [`QUALIFICATION_RECORDER.md`](QUALIFICATION_RECORDER.md) | Guarded CLI for recording genuine maintainer-observed qualification evidence. |
| [`../tool/README.md`](../tool/README.md) | Maintainer command index and final verification sequence. |

Permanent CI runs the maintained equivalent of:

```bash
flutter pub get
dart format --output=none --set-exit-if-changed lib test tool
flutter analyze
flutter test --coverage
dart run tool/release_readiness.dart --json
dart run tool/release_qualification_status.dart --json --pending-only
dart run tool/repository_audit.dart --json
dart run tool/source_completion_audit.dart --json
dart run tool/solver_benchmark.dart 8
flutter build web --release
```

Native builds separately cover Android APK+AAB, Linux, Windows, macOS, and unsigned iOS when their workflow triggers or is manually dispatched.

## Current source-of-truth map

- **Package/build version:** `../pubspec.yaml` → `2.0.12+2012`.
- **Marketing/in-app version:** `../lib/core/constants/project_info.dart` → `2.0.12`.
- **Windows fallback version:** `../windows/runner/Runner.rc`.
- **Game rules:** `../lib/domain/game_engine.dart`, `game_state.dart`, `game_types.dart`.
- **Localization:** `../lib/core/localization/nova_localizations.dart`, `hindi_translations.dart`.
- **Challenge Code:** `../lib/domain/challenge_code.dart`.
- **Backup codec:** `../lib/domain/game_backup.dart`.
- **Move Replay:** `../lib/domain/replay_timeline.dart`.
- **Full Replay Archive:** `../lib/domain/replay_archive.dart` plus controller/local-store capture orchestration.
- **Auto Play / solver:** `../lib/domain/autoplay_session.dart`, `expectimax_solver.dart`, `solver_benchmark.dart`.
- **Persistence:** `../lib/data/local_store.dart`.
- **Session/ranking/settings orchestration:** `../lib/app/state/app_controller.dart`.
- **Web/PWA shell:** `../web/index.html`, `../web/manifest.json`.
- **Release candidate/manual evidence:** `release_qualification.json`.
- **Release gate:** `../tool/release_readiness.dart`.
- **Qualification status/recorder:** `../tool/release_qualification_status.dart`, `../tool/record_release_qualification.dart`.
- **Repository integrity:** `../tool/repository_audit.dart`.
- **Source completion:** `../tool/source_completion_audit.dart`.
- **Permanent automation:** `../.github/workflows/`.
- **Current continuity:** `../what_changed.md`.

When documentation and current source disagree, current source/tests determine behavior and the documentation must be corrected in the same maintenance change. Historical verification files remain historical and must not be rewritten to pretend their run IDs/test counts apply to a newer source state.

## Historical verification records

These files preserve important development and verification history. They are **not** the primary current Version 2.0.12 source-status documents:

- [`FINAL_RELEASE_CANDIDATE_AUDIT.md`](FINAL_RELEASE_CANDIDATE_AUDIT.md) — historical final Version 1.5 audit.
- [`FINAL_1_5_AUTOMATED_VERIFICATION.md`](FINAL_1_5_AUTOMATED_VERIFICATION.md) — historical Version 1.5 automation record.
- [`PHASE_17_VERIFICATION.md`](PHASE_17_VERIFICATION.md)
- [`PHASE_18_VERIFICATION.md`](PHASE_18_VERIFICATION.md)
- [`PHASE_20_VERIFICATION.md`](PHASE_20_VERIFICATION.md)
- [`PHASE_21_VERIFICATION.md`](PHASE_21_VERIFICATION.md)
- [`PHASE_24_VERIFICATION.md`](PHASE_24_VERIFICATION.md)
- [`PHASE_25_VERIFICATION.md`](PHASE_25_VERIFICATION.md)
- [`PHASE_26_VERIFICATION.md`](PHASE_26_VERIFICATION.md)
- [`PHASE_27_VERIFICATION.md`](PHASE_27_VERIFICATION.md)
- [`PHASE_28_VERIFICATION.md`](PHASE_28_VERIFICATION.md)
- [`PHASE_29_VERIFICATION.md`](PHASE_29_VERIFICATION.md)
- [`PHASE_30_VERIFICATION.md`](PHASE_30_VERIFICATION.md)
- [`PHASE_31_VERIFICATION.md`](PHASE_31_VERIFICATION.md)
- [`PHASE_31_PWA_VERIFICATION.md`](PHASE_31_PWA_VERIFICATION.md)

Continuity archives:

- [`../what_changed_archive_phase_00_30.md`](../what_changed_archive_phase_00_30.md) — Phases 0–30.
- [`../what_changed_archive_phase_31.md`](../what_changed_archive_phase_31.md) — complete Phase 31 continuity.
- [`../what_changed.md`](../what_changed.md) — active/final Phase 32 continuity.

## Documentation rules after source completion

- Do not add an active 2.0.12 optional-feature backlog. A deliberate new feature starts a new release scope.
- Do not describe historical Version 1.5 automation as current 2.0.12 evidence.
- Do not convert hosted tests/builds into physical-device, accessibility, handler, signing, provisioning, or store evidence.
- Do not describe imported portable progress as trusted/ranked.
- Do not describe Challenge Code checksums as authentication.
- Do not add analytics, ads, accounts, cloud services, remote AI, camera permissions, or network dependencies silently.
- Keep build/signing secrets outside public source.
- Update behavior docs, privacy/security/accessibility docs, tests, and release contracts together when a future maintenance or release change actually affects them.

## Project identity

- Project: **2048 Nova**
- Creator branding: **Made by the Sanskar**
- Repository: https://github.com/sanskarIN/2048
- License: MIT
- Business: `sanskarin@outlook.in`, `sanskarin.business@gmail.com`
- Support: `supportramsandesh@gmail.com`
- Gumroad: https://ramsandesh.gumroad.com
- Buy Me a Coffee: https://buymeacoffee.com/sanskarIN
