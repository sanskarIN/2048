# 2048 Nova Documentation

This directory is the canonical user, developer, architecture, platform, privacy, security, build, testing, setup, maintenance, and release documentation set for **2048 Nova**.

Current source identity:

```text
Marketing version: 2.0.12
Flutter package/build version: 2.0.12+2012
Source scope: feature-complete
Manual real-world qualification: 0/13 recorded passed evidence
```

Source completion and stable distribution are intentionally separate states. The application source can be feature-complete while physical-device, assistive-technology, external-handler, signing/provisioning, installed-PWA, and store qualification remains pending.

## 1. New contributor reading path

Read these in order if you are starting from a new computer:

1. [`setup/README.md`](setup/README.md) — environment setup index.
2. [`setup/PREREQUISITES.md`](setup/PREREQUISITES.md) — every required/optional tool and why it is needed.
3. Your host guide: [`setup/WINDOWS.md`](setup/WINDOWS.md), [`setup/MACOS.md`](setup/MACOS.md), or [`setup/LINUX.md`](setup/LINUX.md).
4. [`setup/ANDROID.md`](setup/ANDROID.md) if you maintain Android.
5. [`DOCUMENTATION_READING_GUIDE.md`](DOCUMENTATION_READING_GUIDE.md) to understand notation, paths, placeholders, version operators, shell symbols, and safe command reading.
6. [`COMMAND_REFERENCE.md`](COMMAND_REFERENCE.md) to understand commands/flags rather than copying blindly.
7. [`GLOSSARY.md`](GLOSSARY.md) for terminology and abbreviations.
8. [`DEVELOPMENT.md`](DEVELOPMENT.md) for normal source workflow.
9. [`TESTING.md`](TESTING.md) for the verification model.
10. [`BUILDING_EXECUTABLES.md`](BUILDING_EXECUTABLES.md) for every maintained artifact.
11. [`REPOSITORY_FILE_ATLAS.md`](REPOSITORY_FILE_ATLAS.md) for the repository map.
12. [`FILE_COVERAGE_CONTRACT.md`](FILE_COVERAGE_CONTRACT.md) for the auditable no-skip tracked-file rule.

If a tool is old, deprecated, unsupported, insecure, or end-of-life, first compare it with [`setup/TOOL_SUPPORT_MATRIX.md`](setup/TOOL_SUPPORT_MATRIX.md), then use [`setup/UPGRADING_AND_SUPPORT.md`](setup/UPGRADING_AND_SUPPORT.md) before changing project pins.

## 2. Current release and source-completion documents

| Document | Purpose |
| --- | --- |
| [`../README.md`](../README.md) | Public project overview, features, setup, controls, platforms, and project links. |
| [`FINAL_2_0_12_SOURCE_AUDIT.md`](FINAL_2_0_12_SOURCE_AUDIT.md) | Final Version 2.0.12 source-level completion verdict and source/release boundary. |
| [`MAINTENANCE_POLICY.md`](MAINTENANCE_POLICY.md) | Compatibility-first post-completion maintenance policy and future-release rule. |
| [`PHASE_32_VERSION_2_0_12.md`](PHASE_32_VERSION_2_0_12.md) | Version 2.0.12 migration and release-contract details. |
| [`../ROADMAP.md`](../ROADMAP.md) | Feature-complete source scope, non-goals, and external qualification boundary. |
| [`SOURCE_COMPLETION_AUDIT.md`](SOURCE_COMPLETION_AUDIT.md) | Permanent source-completion audit contract. |
| [`../what_changed.md`](../what_changed.md) | Active continuity/change record. |
| [`../CHANGELOG.md`](../CHANGELOG.md) | Current release-facing changelog. |

## 3. Installation and toolchain setup

| Document | Purpose |
| --- | --- |
| [`setup/README.md`](setup/README.md) | Setup index by host and target. |
| [`setup/PREREQUISITES.md`](setup/PREREQUISITES.md) | Git, Flutter, Dart, editors, Android, Apple, Windows, Linux, Web prerequisites and what each tool does. |
| [`setup/WINDOWS.md`](setup/WINDOWS.md) | Windows installation, PATH, Flutter, Android Studio, JDK, Visual Studio C++, VS Code, builds, upgrades, troubleshooting. |
| [`setup/MACOS.md`](setup/MACOS.md) | macOS installation, Flutter, Xcode, CocoaPods, Android, iOS/macOS builds, upgrades, troubleshooting. |
| [`setup/LINUX.md`](setup/LINUX.md) | Linux Flutter/native dependencies, Android, Web/Linux builds, upgrades, troubleshooting. |
| [`setup/ANDROID.md`](setup/ANDROID.md) | Android Studio, Android SDK, ADB, emulator/AVD, JDK 17, Gradle, AGP, Kotlin, SDK levels, APK/AAB, signing, compatibility. |
| [`setup/UPGRADING_AND_SUPPORT.md`](setup/UPGRADING_AND_SUPPORT.md) | End-of-support/EOL detection, safe migration, rollback, and per-tool upgrade procedures. |
| [`setup/TOOL_SUPPORT_MATRIX.md`](setup/TOOL_SUPPORT_MATRIX.md) | Fast project-baseline table, installed-version checks, support-state meanings, and upgrade/compatibility decisions for Flutter/Dart/Git/Android/Windows/Apple/Linux/Web/editor/CI tool families. |
| [`ANDROID_TOOLCHAIN.md`](ANDROID_TOOLCHAIN.md) | Repository-specific accepted AGP/Kotlin/Gradle/JDK baseline and prior compatibility evidence. |

## 4. Command, notation, terminology, and file reference

| Document | Purpose |
| --- | --- |
| [`DOCUMENTATION_READING_GUIDE.md`](DOCUMENTATION_READING_GUIDE.md) | Explains inline code, code fences, placeholders, paths, PATH/environment variables, flags, pipes, redirection, exit codes, version constraints, YAML/JSON, source-of-truth language, artifacts, host/target, and safe command reading. |
| [`COMMAND_REFERENCE.md`](COMMAND_REFERENCE.md) | Full explanation of shell/Git/Flutter/Pub/test/build/Gradle/Android/Xcode/CocoaPods/checksum/package-manager commands and flags. |
| [`GLOSSARY.md`](GLOSSARY.md) | Definitions for Flutter/Dart/Git/Android/Apple/build/release/security/testing/gameplay vocabulary. |
| [`REPOSITORY_FILE_ATLAS.md`](REPOSITORY_FILE_ATLAS.md) | Explains root/source/test/tool/CI/platform/docs paths and how to enumerate every tracked file with `git ls-files`. |
| [`FILE_COVERAGE_CONTRACT.md`](FILE_COVERAGE_CONTRACT.md) | Defines exact-file/family/generated/archive coverage and the auditable rule for ensuring no tracked path is silently skipped. |
| [`build/QUICK_COMMANDS.md`](build/QUICK_COMMANDS.md) | Compact build-command sheet for experienced contributors. |

## 5. Player and behavior documentation

| Document | Purpose |
| --- | --- |
| [`USER_GUIDE.md`](USER_GUIDE.md) | Complete player guide for rules, modes, controls, Undo, Hint, Auto Play, backups, replays, Challenge Codes, settings, and data controls. |
| [`FAQ.md`](FAQ.md) | Common player/developer questions and release-status explanations. |
| [`GAME_ENGINE.md`](GAME_ENGINE.md) | Exact movement/merge/spawn rules, deterministic RNG, terminal-state behavior, and invariants. |
| [`GAME_MODES.md`](GAME_MODES.md) | Exact behavior for Classic, Quick, Extended, Challenge, Endless, Target, Time Challenge, Move Limit, Daily, and Zen. |
| [`CHALLENGE_CODES.md`](CHALLENGE_CODES.md) | Seeded challenge format, validation, QR representation, determinism, checksum, privacy, trust boundary. |
| [`HINT_SOLVER.md`](HINT_SOLVER.md) | Read-only Hint and isolated Heuristic/Expectimax Auto Play design. |
| [`SOLVER_BENCHMARKS.md`](SOLVER_BENCHMARKS.md) | Deterministic bounded solver benchmark behavior and CLI. |
| [`REPLAY_ARCHIVES.md`](REPLAY_ARCHIVES.md) | Full-session replay capture/protocol/player, validation, limits, and trust model. |
| [`MODE_RECORDS.md`](MODE_RECORDS.md) | Trusted local per-mode records and import isolation. |
| [`BACKUP_AND_RESTORE.md`](BACKUP_AND_RESTORE.md) | Portable current-game backup format, validation, and unranked-import policy. |
| [`FILE_BACKUPS.md`](FILE_BACKUPS.md) | User-selected file transport, byte limits, handlers, and platform qualification boundary. |
| [`DATA_STORAGE.md`](DATA_STORAGE.md) | Local keys, save schemas, bounded histories, migration/recovery, replay persistence, reset behavior. |
| [`PORTABLE_TIMESTAMPS.md`](PORTABLE_TIMESTAMPS.md) | UTC serialization, legacy compatibility, timed-mode integrity, and evidence timestamp rules. |

## 6. Accessibility, localization, privacy, security, support

| Document | Purpose |
| --- | --- |
| [`ACCESSIBILITY.md`](ACCESSIBILITY.md) | Implemented semantics/input/contrast/motion support and remaining real assistive-technology checks. |
| [`LOCALIZATION.md`](LOCALIZATION.md) | English/Hindi architecture, persisted selection, fallback, contributor rules, privacy/accessibility boundaries. |
| [`PRIVACY.md`](PRIVACY.md) | Offline-first data behavior, local storage, clipboard/file/replay/challenge boundaries, external navigation. |
| [`../SECURITY.md`](../SECURITY.md) | Security reporting, validation, dependencies, signing-secret, external-link, and trust boundaries. |
| [`../SUPPORT.md`](../SUPPORT.md) | Player/developer support channels and useful report information. |

## 7. Architecture and development

| Document | Purpose |
| --- | --- |
| [`ARCHITECTURE.md`](ARCHITECTURE.md) | Layer boundaries, state flow, persistence responsibilities, trust boundaries, and feature architecture. |
| [`DEVELOPMENT.md`](DEVELOPMENT.md) | Development environment, repository layout, local workflow, localization, quality, and contribution practices. |
| [`TESTING.md`](TESTING.md) | Test strategy, regression areas, automated/manual evidence boundary. |
| [`DEPENDENCIES.md`](DEPENDENCIES.md) | Runtime/development dependency rationale, Version 2.0.12 freeze policy, updates, exclusions, licensing. |
| [`SUPPLY_CHAIN.md`](SUPPLY_CHAIN.md) | SDK floors, Dependabot, lockfile, dependency review, code ownership, and acceptance checks. |
| [`WORKFLOW_SECURITY.md`](WORKFLOW_SECURITY.md) | Immutable Action revisions, frozen toolchains, credential policy, reproducibility boundaries, repository settings. |
| [`TROUBLESHOOTING.md`](TROUBLESHOOTING.md) | Setup, analyzer, build, save/input/replay/backup/challenge/localization/platform diagnostics. |
| [`REPOSITORY_FILE_ATLAS.md`](REPOSITORY_FILE_ATLAS.md) | File/folder responsibilities and no-skip auditing. |
| [`FILE_COVERAGE_CONTRACT.md`](FILE_COVERAGE_CONTRACT.md) | No-skip tracked-path responsibility and new-file/rename/deletion audit rules. |
| [`../CONTRIBUTING.md`](../CONTRIBUTING.md) | Contribution quality, tests, docs, security/privacy/accessibility, and PR requirements. |
| [`../CODE_OF_CONDUCT.md`](../CODE_OF_CONDUCT.md) | Community participation expectations. |
| [`../AUTHORS.md`](../AUTHORS.md) | Project authorship/credits. |
| [`../LICENSE`](../LICENSE) | MIT License. |

## 8. Platforms, builds, packaging, distribution

| Document | Purpose |
| --- | --- |
| [`BUILDING_EXECUTABLES.md`](BUILDING_EXECUTABLES.md) | Current Version 2.0.12 master handbook for APK, AAB, iOS, Web, Windows, macOS, Linux, signing, packaging, checksums, and CI artifacts. |
| [`build/README.md`](build/README.md) | Dedicated platform build-manual index. |
| [`PLATFORMS.md`](PLATFORMS.md) | Platform setup/build commands, locale behavior, hosted-build scope, signing boundaries. |
| [`PWA.md`](PWA.md) | PWA manifest/HTML/install/deployment/icons/storage and installed-PWA qualification boundary. |
| [`RELEASE_ARTIFACTS.md`](RELEASE_ARTIFACTS.md) | Hosted checksummed qualification artifacts, retention, verification, packaging, evidence boundaries. |
| [`BRANDING.md`](BRANDING.md) | Logo/icon/splash source assets and generated native branding. |

### `docs/build/` detailed manuals

The build subdirectory includes maintained guides for:

- Android;
- iOS;
- Windows;
- macOS;
- Linux;
- Web;
- host prerequisites;
- supported artifacts;
- output paths;
- packaging/checksums;
- signing/distribution;
- CI parity;
- build troubleshooting;
- release-build checklist;
- final executable audit;
- quick commands.

To list the exact current tracked build-document inventory:

```bash
git ls-files 'docs/build/**' | sort
```

## 9. CI, release, qualification, and repository-owned tools

| Document | Purpose |
| --- | --- |
| [`CI_CD.md`](CI_CD.md) | GitHub Actions quality/build/maintenance workflows and evidence boundaries. |
| [`REPOSITORY_AUDIT.md`](REPOSITORY_AUDIT.md) | Integrity audit for required files, versions, metadata, cleanup, and local Markdown links. |
| [`SOURCE_COMPLETION_AUDIT.md`](SOURCE_COMPLETION_AUDIT.md) | Final feature-scope audit and unresolved-current-state protection. |
| [`RELEASE_CHECKLIST.md`](RELEASE_CHECKLIST.md) | Automated and real-environment release checks. |
| [`RELEASE_QUALIFICATION.md`](RELEASE_QUALIFICATION.md) | Canonical evidence manifest, candidate/stable gates, fail-closed promotion. |
| [`RELEASE_GATE_TESTING.md`](RELEASE_GATE_TESTING.md) | Process-level release-readiness fixture testing. |
| [`QUALIFICATION_STATUS.md`](QUALIFICATION_STATUS.md) | Read-only human/JSON qualification status reporter. |
| [`QUALIFICATION_RECORDER.md`](QUALIFICATION_RECORDER.md) | Guarded CLI for recording genuine observed evidence. |
| [`VERIFICATION.md`](VERIFICATION.md) | Latest accepted automated evidence record with historical/current separation. |
| [`../tool/README.md`](../tool/README.md) | Maintainer CLI index and verification sequence. |

Permanent quality CI runs the maintained equivalent of:

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

Native builds separately cover Android APK+AAB, Linux, Windows, macOS, and unsigned iOS on supported hosted runners.

## 10. Current source-of-truth map

- Package/build version: `../pubspec.yaml` → `2.0.12+2012`.
- Marketing/in-app version: `../lib/core/constants/project_info.dart` → `2.0.12`.
- Windows fallback version: `../windows/runner/Runner.rc`.
- Android AGP/Kotlin: `../android/settings.gradle.kts`.
- Android Gradle: `../android/gradle/wrapper/gradle-wrapper.properties`.
- Android Java/Kotlin/signing: `../android/app/build.gradle.kts`.
- Game rules: `../lib/domain/game_engine.dart`, `game_state.dart`, `game_types.dart`.
- Deterministic random source: `../lib/domain/random_source.dart`.
- Challenge Code: `../lib/domain/challenge_code.dart`.
- Backup codec: `../lib/domain/game_backup.dart`.
- Move Replay: `../lib/domain/replay_timeline.dart`.
- Full Replay Archive: `../lib/domain/replay_archive.dart`.
- Solver/Auto Play: `../lib/domain/autoplay_session.dart`, `expectimax_solver.dart`, `hint_solver.dart`, `solver_benchmark.dart`.
- Persistence: `../lib/data/local_store.dart`.
- Session/settings/ranking orchestration: `../lib/app/state/app_controller.dart`.
- Localization: `../lib/core/localization/`.
- Web/PWA source shell: `../web/index.html`, `../web/manifest.json`.
- Release candidate/manual evidence: `release_qualification.json`.
- Release gate: `../tool/release_readiness.dart`.
- Qualification status/recorder: `../tool/release_qualification_status.dart`, `../tool/record_release_qualification.dart`.
- Repository integrity: `../tool/repository_audit.dart`.
- Source completion: `../tool/source_completion_audit.dart`.
- Automation: `../.github/workflows/`.
- Active continuity: `../what_changed.md`.

When current docs and current source disagree, source/tests determine behavior and the documentation must be corrected. Historical verification files remain historical and must not be rewritten to pretend an older run applies to newer source.

## 11. Historical verification records

Historical phase/audit files preserve earlier evidence. They are useful for traceability but are not the primary current Version 2.0.12 status source.

Examples include:

- [`FINAL_RELEASE_CANDIDATE_AUDIT.md`](FINAL_RELEASE_CANDIDATE_AUDIT.md);
- [`FINAL_1_5_AUTOMATED_VERIFICATION.md`](FINAL_1_5_AUTOMATED_VERIFICATION.md);
- `PHASE_*_VERIFICATION.md` records;
- [`PHASE_31_PWA_VERIFICATION.md`](PHASE_31_PWA_VERIFICATION.md).

To list all phase records without relying on a manually maintained list:

```bash
git ls-files 'docs/PHASE_*'
```

Continuity archives:

- [`../what_changed_archive_phase_00_30.md`](../what_changed_archive_phase_00_30.md);
- [`../what_changed_archive_phase_31.md`](../what_changed_archive_phase_31.md);
- [`../what_changed.md`](../what_changed.md) — active continuity.

## 12. Documentation rules after source completion

- Do not restore an active optional-feature backlog inside the Version 2.0.12 completed scope.
- Do not describe historical Version 1.5 automation as current 2.0.12 evidence.
- Do not convert hosted builds into physical-device, accessibility, handler, signing, provisioning, PWA-lifecycle, or store evidence.
- Do not describe imported portable progress as trusted/ranked.
- Do not describe Challenge Code checksums as authentication.
- Do not add analytics, ads, accounts, cloud services, remote AI, camera permissions, or network dependencies silently.
- Keep signing secrets/private credentials outside public source.
- When behavior changes in a future release, update source, tests, behavior docs, privacy/security/accessibility docs, build docs, and release contracts together.

## 13. Literal documentation and tracked-file inventory

To ensure no documentation file is skipped:

```bash
git ls-files 'docs/**' | sort
```

PowerShell:

```powershell
git ls-files 'docs/**' | Sort-Object
```

To enumerate **every tracked path** in the repository:

```bash
git ls-files | sort
```

[`FILE_COVERAGE_CONTRACT.md`](FILE_COVERAGE_CONTRACT.md) defines the exact-file/family coverage rule used to keep that inventory understandable without relying on a stale fixed count. The repository audit validates required documentation and repository-local Markdown links. The file atlas explains the repository responsibilities in depth.

## 14. Project identity

- Project: **2048 Nova**
- Creator branding: **Made by the Sanskar**
- License: MIT
- Business: `sanskarin@outlook.in`, `sanskarin.business@gmail.com`
- Support: `supportramsandesh@gmail.com`
- Buy Me a Coffee: `https://buymeacoffee.com/sanskarIN`

For product/profile links and current public metadata, use the root [`README.md`](../README.md).
