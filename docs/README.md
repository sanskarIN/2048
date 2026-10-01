# 2048 Nova Documentation

This directory is the canonical user, contributor, architecture, platform, privacy, security, build, testing, setup, maintenance, and release documentation set for **2048 Nova**.

Current source identity:

```text
Marketing version: 2.0.12
Flutter package/build version: 2.0.12+2012
Source scope: feature-complete
Manual real-world qualification: 0/13 recorded passed evidence
```

Source completion, automated same-commit verification, real-world qualification, and stable distribution are deliberately separate states. No documentation or hosted build may fabricate physical-device, assistive-technology, external-handler, signing/provisioning, installed-PWA, or store evidence.

## 1. New contributor reading path

Read these in order if you are starting from a new computer:

1. [`setup/README.md`](setup/README.md) — environment setup index.
2. [`setup/PREREQUISITES.md`](setup/PREREQUISITES.md) — required/optional tools and why they exist.
3. Your host guide: [`setup/WINDOWS.md`](setup/WINDOWS.md), [`setup/MACOS.md`](setup/MACOS.md), or [`setup/LINUX.md`](setup/LINUX.md).
4. [`setup/ANDROID.md`](setup/ANDROID.md) for Android maintenance, or [`setup/LINUX_NATIVE_TOOLCHAIN.md`](setup/LINUX_NATIVE_TOOLCHAIN.md) for deep Linux-native work.
5. [`DOCUMENTATION_READING_GUIDE.md`](DOCUMENTATION_READING_GUIDE.md) — notation, paths, placeholders, shell symbols, versions, and safe command reading.
6. [`COMMAND_REFERENCE.md`](COMMAND_REFERENCE.md) — command/subcommand/flag meanings.
7. [`GLOSSARY.md`](GLOSSARY.md) — terminology and abbreviations.
8. [`NEW_CONTRIBUTOR_TUTORIAL.md`](NEW_CONTRIBUTOR_TUTORIAL.md) — zero-to-safe-change workflow.
9. [`ARCHITECTURE.md`](ARCHITECTURE.md) and [`ARCHITECTURE_WALKTHROUGH.md`](ARCHITECTURE_WALKTHROUGH.md) — boundaries and end-to-end flows.
10. [`DEVELOPMENT.md`](DEVELOPMENT.md) — normal source workflow.
11. [`TESTING.md`](TESTING.md) — verification model.
12. [`BUILDING_EXECUTABLES.md`](BUILDING_EXECUTABLES.md) — every maintained artifact.
13. [`ERROR_REFERENCE.md`](ERROR_REFERENCE.md) and [`TROUBLESHOOTING.md`](TROUBLESHOOTING.md) — diagnosis.
14. [`REPOSITORY_FILE_ATLAS.md`](REPOSITORY_FILE_ATLAS.md) and [`FILE_COVERAGE_CONTRACT.md`](FILE_COVERAGE_CONTRACT.md) — repository/no-skip coverage.
15. [`DOCUMENTATION_AUDIT_CHECKLIST.md`](DOCUMENTATION_AUDIT_CHECKLIST.md) — final documentation/release audit.

If a tool is old, deprecated, unsupported, insecure, or end-of-life, compare it with [`setup/TOOL_SUPPORT_MATRIX.md`](setup/TOOL_SUPPORT_MATRIX.md) and then use [`setup/UPGRADING_AND_SUPPORT.md`](setup/UPGRADING_AND_SUPPORT.md) before changing project pins.

## 2. Current release and source-completion documents

| Document | Purpose |
| --- | --- |
| [`../README.md`](../README.md) | Public project overview, features, setup, controls, platforms, and project links. |
| [`FINAL_2_0_12_SOURCE_AUDIT.md`](FINAL_2_0_12_SOURCE_AUDIT.md) | Version 2.0.12 source-level completion verdict and source/release boundary. |
| [`FINAL_2_0_12_INTEGRATION_AUDIT.md`](FINAL_2_0_12_INTEGRATION_AUDIT.md) | Final integration audit after Custom Game Builder entered the Version 2.0.12 line; preserves the exact same-commit evidence rule. |
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
| [`setup/PREREQUISITES.md`](setup/PREREQUISITES.md) | Git, Flutter, Dart, editors, Android, Apple, Windows, Linux, and Web prerequisites. |
| [`setup/WINDOWS.md`](setup/WINDOWS.md) | Windows PATH, Flutter, Android Studio, JDK, Visual Studio C++, editors, builds, upgrades, troubleshooting. |
| [`setup/MACOS.md`](setup/MACOS.md) | Flutter, Xcode, CocoaPods, Android, iOS/macOS/Web builds, upgrades, troubleshooting. |
| [`setup/LINUX.md`](setup/LINUX.md) | Linux Flutter/native dependencies, Android, Web/Linux builds, upgrades, troubleshooting. |
| [`setup/LINUX_NATIVE_TOOLCHAIN.md`](setup/LINUX_NATIVE_TOOLCHAIN.md) | Clang/CMake/Ninja/pkg-config/GTK, native bundle, packaging, linker/runtime diagnosis. |
| [`setup/ANDROID.md`](setup/ANDROID.md) | Android Studio, SDK, ADB, emulator/AVD, JDK 17, Gradle, AGP, Kotlin, APK/AAB, signing. |
| [`setup/TOOL_SUPPORT_MATRIX.md`](setup/TOOL_SUPPORT_MATRIX.md) | Project baseline, installed-version checks, support-state meanings, upgrade decisions. |
| [`setup/UPGRADING_AND_SUPPORT.md`](setup/UPGRADING_AND_SUPPORT.md) | End-of-support/EOL detection, migration, rollback, CI adoption, and per-tool upgrade procedures. |
| [`ANDROID_TOOLCHAIN.md`](ANDROID_TOOLCHAIN.md) | Repository-specific accepted AGP/Kotlin/Gradle/JDK baseline and compatibility evidence. |

## 4. Command, terminology, repository, and diagnosis reference

| Document | Purpose |
| --- | --- |
| [`DOCUMENTATION_READING_GUIDE.md`](DOCUMENTATION_READING_GUIDE.md) | Inline/fenced code, placeholders, paths, environment variables, pipes, exit codes, versions, source-of-truth terminology. |
| [`COMMAND_REFERENCE.md`](COMMAND_REFERENCE.md) | Shell/Git/Flutter/Pub/test/build/Gradle/Android/Xcode/CocoaPods/checksum/package-manager commands and flags. |
| [`GLOSSARY.md`](GLOSSARY.md) | Flutter/Dart/Git/Android/Apple/build/release/security/testing/gameplay definitions. |
| [`REPOSITORY_FILE_ATLAS.md`](REPOSITORY_FILE_ATLAS.md) | Root/source/test/tool/CI/platform/docs responsibilities and tracked-file enumeration. |
| [`FILE_COVERAGE_CONTRACT.md`](FILE_COVERAGE_CONTRACT.md) | Exact-file/family/generated/archive coverage and no-skip rule. |
| [`ERROR_REFERENCE.md`](ERROR_REFERENCE.md) | Actionable source, persistence, trust, build, and platform diagnosis. |
| [`DOCUMENTATION_AUDIT_CHECKLIST.md`](DOCUMENTATION_AUDIT_CHECKLIST.md) | Human audit checklist for source identity, behavior, security/privacy, accessibility, builds, CI, and qualification boundaries. |
| [`build/QUICK_COMMANDS.md`](build/QUICK_COMMANDS.md) | Compact build-command sheet for experienced contributors. |

## 5. Player and behavior documentation

| Document | Purpose |
| --- | --- |
| [`USER_GUIDE.md`](USER_GUIDE.md) | Player guide for rules, modes, Custom Game Builder, controls, Undo, Hint, backups, replays, Challenge Codes, settings, and data controls. |
| [`FAQ.md`](FAQ.md) | Common player/developer questions and release-status explanations. |
| [`GAME_ENGINE.md`](GAME_ENGINE.md) | Exact movement/merge/spawn rules, deterministic RNG, terminal-state behavior, invariants. |
| [`GAME_MODES.md`](GAME_MODES.md) | Classic, Quick, Extended, Challenge, Endless, Target, Time Challenge, Move Limit, Daily, Zen. |
| [`CUSTOM_GAME_BUILDER.md`](CUSTOM_GAME_BUILDER.md) | Local validated custom presets: create, play, save, edit, rename, duplicate, cancel, delete, persistence, trust boundaries. |
| [`CHALLENGE_CODES.md`](CHALLENGE_CODES.md) | Seeded challenge format, validation, QR representation, checksum, privacy, trust boundary. |
| [`HINT_SOLVER.md`](HINT_SOLVER.md) | Read-only Hint and isolated Heuristic/Expectimax Auto Play design. |
| [`SOLVER_BENCHMARKS.md`](SOLVER_BENCHMARKS.md) | Deterministic bounded solver benchmark behavior and CLI. |
| [`REPLAY_ARCHIVES.md`](REPLAY_ARCHIVES.md) | Full-session replay capture/protocol/player, validation, limits, trust model. |
| [`MODE_RECORDS.md`](MODE_RECORDS.md) | Trusted local per-mode records and import/custom isolation. |
| [`BACKUP_AND_RESTORE.md`](BACKUP_AND_RESTORE.md) | Portable current-game backup format, validation, unranked-import policy. |
| [`FILE_BACKUPS.md`](FILE_BACKUPS.md) | User-selected file transport, byte limits, handlers, platform qualification boundary. |
| [`DATA_STORAGE.md`](DATA_STORAGE.md) | Local keys, schemas, bounded histories, migration/recovery, reset behavior. |
| [`PORTABLE_TIMESTAMPS.md`](PORTABLE_TIMESTAMPS.md) | UTC serialization, legacy compatibility, timed-mode integrity, evidence timestamp rules. |

## 6. Accessibility, localization, privacy, security, and support

| Document | Purpose |
| --- | --- |
| [`ACCESSIBILITY.md`](ACCESSIBILITY.md) | Implemented semantics/input/contrast/motion support and remaining real assistive-technology checks. |
| [`LOCALIZATION.md`](LOCALIZATION.md) | English/Hindi architecture, persisted selection, fallback, contributor rules. |
| [`PRIVACY.md`](PRIVACY.md) | Offline-first data behavior, local storage, clipboard/file/replay/challenge boundaries, external navigation. |
| [`../SECURITY.md`](../SECURITY.md) | Security reporting, validation, dependencies, signing-secret, external-link, and trust boundaries. |
| [`../SUPPORT.md`](../SUPPORT.md) | Player/developer support channels and useful report information. |

## 7. Architecture and development

| Document | Purpose |
| --- | --- |
| [`ARCHITECTURE.md`](ARCHITECTURE.md) | Layer boundaries, state flow, persistence responsibilities, trust boundaries. |
| [`ARCHITECTURE_WALKTHROUGH.md`](ARCHITECTURE_WALKTHROUGH.md) | End-to-end startup, game, persistence, custom-preset, replay, backup, solver, platform, and release flow. |
| [`NEW_CONTRIBUTOR_TUTORIAL.md`](NEW_CONTRIBUTOR_TUTORIAL.md) | New-workstation-to-safe-PR tutorial with trust/test/docs rules. |
| [`DEVELOPMENT.md`](DEVELOPMENT.md) | Development environment, repository layout, local workflow, localization, quality, contribution practices. |
| [`TESTING.md`](TESTING.md) | Test strategy, regression areas, automated/manual evidence boundary. |
| [`DEPENDENCIES.md`](DEPENDENCIES.md) | Dependency rationale, Version 2.0.12 compatibility-first freeze, updates, exclusions, licensing. |
| [`SUPPLY_CHAIN.md`](SUPPLY_CHAIN.md) | SDK floors, Dependabot, lockfile, dependency review, ownership, acceptance checks. |
| [`WORKFLOW_SECURITY.md`](WORKFLOW_SECURITY.md) | Immutable Action revisions, frozen toolchains, credential policy, reproducibility boundaries. |
| [`TROUBLESHOOTING.md`](TROUBLESHOOTING.md) | Common setup, analyzer, build, save/input/replay/backup/challenge/localization/platform diagnostics. |
| [`ERROR_REFERENCE.md`](ERROR_REFERENCE.md) | Deeper diagnosis when common troubleshooting is insufficient. |
| [`../CONTRIBUTING.md`](../CONTRIBUTING.md) | Contribution quality, tests, docs, security/privacy/accessibility, PR requirements. |
| [`../CODE_OF_CONDUCT.md`](../CODE_OF_CONDUCT.md) | Community participation expectations. |
| [`../AUTHORS.md`](../AUTHORS.md) | Project authorship/credits. |
| [`../LICENSE`](../LICENSE) | MIT License. |

## 8. Platforms, builds, packaging, and distribution

| Document | Purpose |
| --- | --- |
| [`BUILDING_EXECUTABLES.md`](BUILDING_EXECUTABLES.md) | Master handbook for APK, AAB, iOS, Web, Windows, macOS, Linux, signing, packaging, checksums, CI artifacts. |
| [`build/README.md`](build/README.md) | Detailed platform build-manual index. |
| [`PLATFORMS.md`](PLATFORMS.md) | Platform setup/build commands, locale behavior, hosted-build scope, signing boundaries. |
| [`PWA.md`](PWA.md) | PWA manifest/HTML/install/deployment/icons/storage and installed-PWA qualification boundary. |
| [`RELEASE_ARTIFACTS.md`](RELEASE_ARTIFACTS.md) | Hosted checksummed qualification artifacts, retention, verification, packaging, evidence boundaries. |
| [`BRANDING.md`](BRANDING.md) | Logo/icon/splash source assets and generated native branding. |
| [`setup/LINUX_NATIVE_TOOLCHAIN.md`](setup/LINUX_NATIVE_TOOLCHAIN.md) | Linux native toolchain and complete release-bundle diagnosis/packaging. |

List the exact tracked build-document inventory with:

```bash
git ls-files 'docs/build/**' | sort
```

## 9. CI, release, qualification, and repository-owned tools

| Document | Purpose |
| --- | --- |
| [`CI_CD.md`](CI_CD.md) | GitHub Actions quality/build/maintenance workflows and evidence boundaries. |
| [`REPOSITORY_AUDIT.md`](REPOSITORY_AUDIT.md) | Integrity audit for required files, versions, metadata, cleanup, local Markdown links. |
| [`SOURCE_COMPLETION_AUDIT.md`](SOURCE_COMPLETION_AUDIT.md) | Final feature-scope audit and unresolved-current-state protection. |
| [`RELEASE_CHECKLIST.md`](RELEASE_CHECKLIST.md) | Automated and real-environment release checks. |
| [`RELEASE_QUALIFICATION.md`](RELEASE_QUALIFICATION.md) | Canonical evidence manifest, candidate/stable gates, fail-closed promotion. |
| [`RELEASE_GATE_TESTING.md`](RELEASE_GATE_TESTING.md) | Process-level release-readiness fixture testing. |
| [`QUALIFICATION_STATUS.md`](QUALIFICATION_STATUS.md) | Read-only human/JSON qualification status reporter. |
| [`QUALIFICATION_RECORDER.md`](QUALIFICATION_RECORDER.md) | Guarded CLI for recording genuine observed evidence. |
| [`VERIFICATION.md`](VERIFICATION.md) | Accepted automated evidence record with historical/current separation. |
| [`FINAL_2_0_12_INTEGRATION_AUDIT.md`](FINAL_2_0_12_INTEGRATION_AUDIT.md) | Current integration evidence boundary after the Custom Game Builder merge. |
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

Native builds separately cover Android APK+AAB, Linux, Windows, macOS, and unsigned iOS on supported hosted runners. Dependency Review remains a separate pull-request supply-chain check.

## 10. Current source-of-truth map

- Package/build version: `../pubspec.yaml` → `2.0.12+2012`.
- Marketing/in-app version: `../lib/core/constants/project_info.dart` → `2.0.12`.
- Windows fallback version: `../windows/runner/Runner.rc`.
- Android AGP/Kotlin: `../android/settings.gradle.kts`.
- Android Gradle: `../android/gradle/wrapper/gradle-wrapper.properties`.
- Android Java/Kotlin/signing: `../android/app/build.gradle.kts`.
- Game rules: `../lib/domain/game_engine.dart`, `game_state.dart`, `game_types.dart`.
- Deterministic random source: `../lib/domain/random_source.dart`.
- Custom preset model: `../lib/domain/custom_game_preset.dart`.
- Custom preset persistence: `../lib/data/custom_preset_store.dart`.
- Custom Game Builder UI: `../lib/features/modes/custom_game_builder_screen.dart`.
- Challenge Code: `../lib/domain/challenge_code.dart`.
- Backup codec: `../lib/domain/game_backup.dart`.
- Move Replay: `../lib/domain/replay_timeline.dart`.
- Full Replay Archive: `../lib/domain/replay_archive.dart`.
- Solver/Auto Play: `../lib/domain/autoplay_session.dart`, `expectimax_solver.dart`, `hint_solver.dart`, `solver_benchmark.dart`.
- Persistence: `../lib/data/local_store.dart`.
- Session/settings/ranking orchestration: `../lib/app/state/app_controller.dart`.
- Localization: `../lib/core/localization/`.
- Web/PWA shell: `../web/index.html`, `../web/manifest.json`.
- Release candidate/manual evidence: `release_qualification.json`.
- Release gate: `../tool/release_readiness.dart`.
- Qualification status/recorder: `../tool/release_qualification_status.dart`, `../tool/record_release_qualification.dart`.
- Repository integrity: `../tool/repository_audit.dart`.
- Source completion: `../tool/source_completion_audit.dart`.
- Automation: `../.github/workflows/`.
- Active continuity: `../what_changed.md`.

When current docs and current source disagree, source/tests determine behavior and current documentation must be corrected. Historical verification remains historical and must not be rewritten to pretend an older run applies to newer source.

## 11. Historical verification and continuity records

Historical phase/audit files preserve earlier evidence for traceability; they are not the primary current Version 2.0.12 status source.

Examples:

- [`FINAL_RELEASE_CANDIDATE_AUDIT.md`](FINAL_RELEASE_CANDIDATE_AUDIT.md);
- [`FINAL_1_5_AUTOMATED_VERIFICATION.md`](FINAL_1_5_AUTOMATED_VERIFICATION.md);
- `PHASE_*_VERIFICATION.md` records;
- [`PHASE_31_PWA_VERIFICATION.md`](PHASE_31_PWA_VERIFICATION.md);
- [`VERSION_1_6_ROADMAP.md`](VERSION_1_6_ROADMAP.md) — historical Custom Game Builder development roadmap, no longer current.

Continuity archives:

- [`../what_changed_archive_phase_00_30.md`](../what_changed_archive_phase_00_30.md);
- [`../what_changed_archive_phase_31.md`](../what_changed_archive_phase_31.md);
- [`../what_changed_archive_phase_32.md`](../what_changed_archive_phase_32.md);
- [`../what_changed_archive_phase_33.md`](../what_changed_archive_phase_33.md);
- [`../what_changed.md`](../what_changed.md) — active continuity.

List all tracked phase records with:

```bash
git ls-files 'docs/PHASE_*'
```

## 12. Documentation rules after source completion

- Do not restore an active optional-feature backlog inside the completed Version 2.0.12 scope.
- Do not describe historical Version 1.5 automation as current 2.0.12 evidence.
- Do not convert hosted builds into physical-device, accessibility, handler, signing, provisioning, PWA-lifecycle, or store evidence.
- Do not describe imported portable progress as trusted/ranked.
- Do not let custom configurations overwrite built-in per-mode records.
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

To enumerate **every tracked path**:

```bash
git ls-files | sort
```

[`FILE_COVERAGE_CONTRACT.md`](FILE_COVERAGE_CONTRACT.md) defines exact-file/family coverage; [`REPOSITORY_FILE_ATLAS.md`](REPOSITORY_FILE_ATLAS.md) explains responsibilities; the repository audit validates required docs and repository-local Markdown links.

## 14. Project identity

- Project: **2048 Nova**
- Creator branding: **Made by the Sanskar**
- License: MIT
- Business: `sanskarin@outlook.in`, `sanskarin.business@gmail.com`
- Support: `supportramsandesh@gmail.com`
- Buy Me a Coffee: `https://buymeacoffee.com/sanskarIN`

For current public product/profile metadata, use the root [`README.md`](../README.md).
