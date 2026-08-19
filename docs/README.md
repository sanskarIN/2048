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

1. [`setup/README.md`](setup/README.md) — complete environment/tool setup index.
2. [`setup/TOOL_MATRIX.md`](setup/TOOL_MATRIX.md) — compact install/verify matrix.
3. [`setup/PREREQUISITES.md`](setup/PREREQUISITES.md) — every required/optional tool and why it exists.
4. Your host guide: [`setup/WINDOWS.md`](setup/WINDOWS.md), [`setup/MACOS.md`](setup/MACOS.md), or [`setup/LINUX.md`](setup/LINUX.md).
5. [`setup/FLUTTER_AND_DART.md`](setup/FLUTTER_AND_DART.md) — SDK/Pub/channel/upgrade model.
6. [`setup/GIT.md`](setup/GIT.md) — Git/GitHub/protected-branch workflow.
7. [`setup/VS_CODE.md`](setup/VS_CODE.md) if you use VS Code.
8. Target-specific tool guide: Android Studio, Visual Studio, Xcode/CocoaPods, or Linux native toolchain.
9. [`COMMAND_REFERENCE.md`](COMMAND_REFERENCE.md) — understand commands and flags instead of copying blindly.
10. [`GLOSSARY.md`](GLOSSARY.md) — technical vocabulary.
11. [`NEW_CONTRIBUTOR_TUTORIAL.md`](NEW_CONTRIBUTOR_TUTORIAL.md) — zero-to-first-PR tutorial.
12. [`ARCHITECTURE_WALKTHROUGH.md`](ARCHITECTURE_WALKTHROUGH.md) — end-to-end source/state flows.
13. [`FEATURE_REFERENCE.md`](FEATURE_REFERENCE.md) — all implemented features.
14. [`TESTING.md`](TESTING.md) — verification/evidence model.
15. [`BUILDING_EXECUTABLES.md`](BUILDING_EXECUTABLES.md) — every maintained artifact.
16. [`ERROR_REFERENCE.md`](ERROR_REFERENCE.md) — detailed failure diagnosis.
17. [`REPOSITORY_FILE_ATLAS.md`](REPOSITORY_FILE_ATLAS.md) — no-skip repository map.

If a tool is old, deprecated, unsupported, insecure, or end-of-life, use [`setup/UPGRADING_AND_SUPPORT.md`](setup/UPGRADING_AND_SUPPORT.md) before changing project pins.

## 2. Phase 33 complete-documentation record

| Document | Purpose |
| --- | --- |
| [`PHASE_33_COMPLETE_DOCUMENTATION.md`](PHASE_33_COMPLETE_DOCUMENTATION.md) | Phase 33 documentation/toolchain hardening scope, files, release boundary, and protected-main transition. |
| [`DOCUMENTATION_AUDIT_CHECKLIST.md`](DOCUMENTATION_AUDIT_CHECKLIST.md) | No-skip future documentation audit procedure. |
| [`../what_changed.md`](../what_changed.md) | Active continuity; keeps Phase 32 frozen release marker plus Phase 33 maintenance stream. |
| [`../what_changed_archive_phase_32.md`](../what_changed_archive_phase_32.md) | Detailed preserved Phase 32 source-completion history. |

## 3. Installation and toolchain setup

| Document | Purpose |
| --- | --- |
| [`setup/README.md`](setup/README.md) | Complete setup index by host, target, and tool. |
| [`setup/TOOL_MATRIX.md`](setup/TOOL_MATRIX.md) | Compact tool/install/verify/target matrix. |
| [`setup/PREREQUISITES.md`](setup/PREREQUISITES.md) | Git, Flutter, Dart, editors, Android, Apple, Windows, Linux, Web prerequisites and why each tool exists. |
| [`setup/FLUTTER_AND_DART.md`](setup/FLUTTER_AND_DART.md) | Flutter/Dart install, PATH, channel, Pub, lockfile, Doctor, devices, upgrades, duplicate SDKs, migration. |
| [`setup/GIT.md`](setup/GIT.md) | Git/GitHub install, identity, branches, staging, commits, sync, PRs, protection, recovery, secret safety. |
| [`setup/VS_CODE.md`](setup/VS_CODE.md) | VS Code Flutter/Dart extensions, SDK/device selection, debug, tests, Source Control, updates, troubleshooting. |
| [`setup/WINDOWS.md`](setup/WINDOWS.md) | Windows installation, PATH, Flutter, Android, Visual Studio, builds, upgrades, recovery. |
| [`setup/MACOS.md`](setup/MACOS.md) | macOS installation, Flutter, Xcode/CocoaPods, Android, iOS/macOS builds, upgrades. |
| [`setup/LINUX.md`](setup/LINUX.md) | Linux Flutter/native dependencies, Android, Web/Linux builds, upgrades. |
| [`setup/ANDROID.md`](setup/ANDROID.md) | Complete Android SDK/JDK/Gradle/AGP/Kotlin/ADB/AVD/APK/AAB/signing model. |
| [`setup/ANDROID_STUDIO.md`](setup/ANDROID_STUDIO.md) | Android Studio, SDK Manager, Device Manager, ADB, Logcat, JBR/JDK, Gradle sync, updates. |
| [`setup/VISUAL_STUDIO_WINDOWS.md`](setup/VISUAL_STUDIO_WINDOWS.md) | Visual Studio C++, MSVC, MSBuild, Windows SDK, CMake and Windows bundle builds. |
| [`setup/XCODE_AND_COCOAPODS.md`](setup/XCODE_AND_COCOAPODS.md) | Xcode, Simulator, CocoaPods, signing, provisioning, notarization, Apple build troubleshooting. |
| [`setup/LINUX_NATIVE_TOOLCHAIN.md`](setup/LINUX_NATIVE_TOOLCHAIN.md) | Clang, CMake, Ninja, pkg-config, GTK, ELF/shared libraries, distro compatibility. |
| [`setup/UPGRADING_AND_SUPPORT.md`](setup/UPGRADING_AND_SUPPORT.md) | End-of-support/EOL detection, safe migrations, rollback, and per-tool upgrade procedures. |
| [`ANDROID_TOOLCHAIN.md`](ANDROID_TOOLCHAIN.md) | Repository-specific accepted Android baseline/evidence. |

## 4. Command, terminology, error, and file references

| Document | Purpose |
| --- | --- |
| [`COMMAND_REFERENCE.md`](COMMAND_REFERENCE.md) | Shell/Git/Flutter/Pub/test/build/Gradle/Android/Xcode/CocoaPods/checksum/package-manager commands and flag meanings. |
| [`GLOSSARY.md`](GLOSSARY.md) | Definitions for Flutter/Dart/Git/platform/build/release/security/testing/gameplay vocabulary. |
| [`ERROR_REFERENCE.md`](ERROR_REFERENCE.md) | Detailed root-cause diagnosis for environment, source, tests, Android, Windows, Apple, Linux, Web, CI, Git, and release errors. |
| [`REPOSITORY_FILE_ATLAS.md`](REPOSITORY_FILE_ATLAS.md) | Root/source/test/tool/CI/platform/docs path responsibilities and literal `git ls-files` audit. |
| [`build/QUICK_COMMANDS.md`](build/QUICK_COMMANDS.md) | Compact build-command sheet for experienced contributors. |

## 5. Product, feature, and architecture guides

| Document | Purpose |
| --- | --- |
| [`FEATURE_REFERENCE.md`](FEATURE_REFERENCE.md) | Consolidated implemented Version 2.0.12 feature map with source/doc pointers. |
| [`ARCHITECTURE_WALKTHROUGH.md`](ARCHITECTURE_WALKTHROUGH.md) | Startup, move, persistence, challenge, backup, replay, solver, platform, CI, and trust-boundary flows. |
| [`ARCHITECTURE.md`](ARCHITECTURE.md) | Formal layer boundaries, state flow, persistence, trust boundaries, feature architecture. |
| [`USER_GUIDE.md`](USER_GUIDE.md) | Complete player guide. |
| [`FAQ.md`](FAQ.md) | Common player/developer/release-status questions. |
| [`GAME_ENGINE.md`](GAME_ENGINE.md) | Exact movement/merge/spawn rules and deterministic engine invariants. |
| [`GAME_MODES.md`](GAME_MODES.md) | Exact behavior for all ten modes. |
| [`CHALLENGE_CODES.md`](CHALLENGE_CODES.md) | Challenge format, determinism, validation, QR, checksum and trust boundary. |
| [`HINT_SOLVER.md`](HINT_SOLVER.md) | Hint and isolated Heuristic/Expectimax Auto Play design. |
| [`SOLVER_BENCHMARKS.md`](SOLVER_BENCHMARKS.md) | Deterministic solver benchmark behavior/CLI. |
| [`REPLAY_ARCHIVES.md`](REPLAY_ARCHIVES.md) | Full replay protocol/player/validation/limits/trust model. |
| [`MODE_RECORDS.md`](MODE_RECORDS.md) | Trusted local per-mode records and import isolation. |
| [`BACKUP_AND_RESTORE.md`](BACKUP_AND_RESTORE.md) | Portable current-game backup format and unranked-import policy. |
| [`FILE_BACKUPS.md`](FILE_BACKUPS.md) | User-selected file transport and platform qualification boundary. |
| [`DATA_STORAGE.md`](DATA_STORAGE.md) | Local storage schema, bounded histories, migration/recovery, reset behavior. |
| [`PORTABLE_TIMESTAMPS.md`](PORTABLE_TIMESTAMPS.md) | UTC serialization/compatibility/timed-mode integrity. |

## 6. Accessibility, localization, privacy, security, support

| Document | Purpose |
| --- | --- |
| [`ACCESSIBILITY.md`](ACCESSIBILITY.md) | Implemented accessibility support and remaining real assistive-technology checks. |
| [`LOCALIZATION.md`](LOCALIZATION.md) | English/Hindi architecture, persisted selection, fallback, contributor rules. |
| [`PRIVACY.md`](PRIVACY.md) | Offline-first data behavior, local storage, portable-data/external-link boundaries. |
| [`../SECURITY.md`](../SECURITY.md) | Security reporting, validation, dependency, signing-secret, external-link and trust boundaries. |
| [`../SUPPORT.md`](../SUPPORT.md) | Support/reporting guidance. |

## 7. Development, testing, dependencies, maintenance

| Document | Purpose |
| --- | --- |
| [`NEW_CONTRIBUTOR_TUTORIAL.md`](NEW_CONTRIBUTOR_TUTORIAL.md) | Complete protected-branch contribution workflow from clone to PR. |
| [`DEVELOPMENT.md`](DEVELOPMENT.md) | Development environment/layout/workflow/localization/quality practices. |
| [`TESTING.md`](TESTING.md) | Unit/widget/process/manual verification and evidence boundaries. |
| [`DOCUMENTATION_AUDIT_CHECKLIST.md`](DOCUMENTATION_AUDIT_CHECKLIST.md) | Complete documentation freshness/no-skip audit. |
| [`DEPENDENCIES.md`](DEPENDENCIES.md) | Runtime/development dependency rationale and compatibility-first freeze policy. |
| [`SUPPLY_CHAIN.md`](SUPPLY_CHAIN.md) | SDK floors, Dependabot, lockfile, dependency review, code ownership, acceptance. |
| [`WORKFLOW_SECURITY.md`](WORKFLOW_SECURITY.md) | Action revisions, frozen toolchains, credentials, reproducibility, repository settings. |
| [`TROUBLESHOOTING.md`](TROUBLESHOOTING.md) | Existing project troubleshooting guide. |
| [`MAINTENANCE_POLICY.md`](MAINTENANCE_POLICY.md) | Post-completion maintenance rules and future-release policy. |
| [`../CONTRIBUTING.md`](../CONTRIBUTING.md) | Contribution requirements. |
| [`../CODE_OF_CONDUCT.md`](../CODE_OF_CONDUCT.md) | Community expectations. |
| [`../AUTHORS.md`](../AUTHORS.md) | Authorship/credits. |
| [`../LICENSE`](../LICENSE) | MIT License. |

## 8. Platforms, builds, packaging, distribution

| Document | Purpose |
| --- | --- |
| [`BUILDING_EXECUTABLES.md`](BUILDING_EXECUTABLES.md) | Version 2.0.12 master handbook for APK, AAB, iOS, Web, Windows, macOS, Linux, signing, packaging, checksums, CI artifacts. |
| [`build/README.md`](build/README.md) | Dedicated platform build-manual index. |
| [`PLATFORMS.md`](PLATFORMS.md) | Platform setup/build commands, locale behavior, hosted-build scope, signing boundaries. |
| [`PWA.md`](PWA.md) | PWA manifest/install/deployment/icons/storage/lifecycle boundary. |
| [`RELEASE_ARTIFACTS.md`](RELEASE_ARTIFACTS.md) | Hosted checksummed qualification artifacts, retention, verification, packaging/evidence boundaries. |
| [`BRANDING.md`](BRANDING.md) | Logo/icon/splash source and native branding. |

Exact build-doc inventory:

```bash
git ls-files 'docs/build/**' | sort
```

## 9. CI, release, qualification, repository-owned tools

| Document | Purpose |
| --- | --- |
| [`CI_CD.md`](CI_CD.md) | GitHub Actions quality/build/maintenance workflows and evidence boundaries. |
| [`REPOSITORY_AUDIT.md`](REPOSITORY_AUDIT.md) | Repository integrity audit contract. |
| [`SOURCE_COMPLETION_AUDIT.md`](SOURCE_COMPLETION_AUDIT.md) | Final feature-scope/current-state source-completion protection. |
| [`RELEASE_CHECKLIST.md`](RELEASE_CHECKLIST.md) | Automated and real-environment release checks. |
| [`RELEASE_QUALIFICATION.md`](RELEASE_QUALIFICATION.md) | Canonical evidence manifest and fail-closed stable promotion. |
| [`RELEASE_GATE_TESTING.md`](RELEASE_GATE_TESTING.md) | Process-level release-readiness fixture testing. |
| [`QUALIFICATION_STATUS.md`](QUALIFICATION_STATUS.md) | Read-only qualification status reporter. |
| [`QUALIFICATION_RECORDER.md`](QUALIFICATION_RECORDER.md) | Guarded genuine evidence recorder. |
| [`VERIFICATION.md`](VERIFICATION.md) | Accepted automated evidence record with historical/current separation. |
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

Native builds separately cover Android APK+AAB, Linux, Windows, macOS, and unsigned iOS on compatible hosted runners.

## 10. Current release and source-completion documents

| Document | Purpose |
| --- | --- |
| [`FINAL_2_0_12_SOURCE_AUDIT.md`](FINAL_2_0_12_SOURCE_AUDIT.md) | Final Version 2.0.12 source-level completion verdict and source/release boundary. |
| [`MAINTENANCE_POLICY.md`](MAINTENANCE_POLICY.md) | Compatibility-first post-completion maintenance policy. |
| [`PHASE_32_VERSION_2_0_12.md`](PHASE_32_VERSION_2_0_12.md) | Version 2.0.12 migration/release contract. |
| [`PHASE_33_COMPLETE_DOCUMENTATION.md`](PHASE_33_COMPLETE_DOCUMENTATION.md) | Current documentation-hardening maintenance phase. |
| [`../ROADMAP.md`](../ROADMAP.md) | Feature-complete source scope/non-goals/external qualification boundary. |
| [`SOURCE_COMPLETION_AUDIT.md`](SOURCE_COMPLETION_AUDIT.md) | Permanent source-completion audit contract. |
| [`../what_changed.md`](../what_changed.md) | Active continuity. |
| [`../CHANGELOG.md`](../CHANGELOG.md) | Current release-facing changelog. |

## 11. Current source-of-truth map

- Package/build version: `../pubspec.yaml` → `2.0.12+2012`.
- Marketing/in-app version: `../lib/core/constants/project_info.dart` → `2.0.12`.
- Windows fallback version: `../windows/runner/Runner.rc`.
- Android AGP/Kotlin: `../android/settings.gradle.kts`.
- Android Gradle: `../android/gradle/wrapper/gradle-wrapper.properties`.
- Android Java/Kotlin/signing: `../android/app/build.gradle.kts`.
- Game rules: `../lib/domain/game_engine.dart`, `game_state.dart`, `game_types.dart`.
- Deterministic RNG: `../lib/domain/random_source.dart`.
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

When current docs and current source disagree, source/tests determine behavior and current documentation must be corrected. Historical verification files remain historical.

## 12. Historical verification records

Historical phase/audit files preserve earlier evidence and are not current Version 2.0.12 verification claims.

Examples:

- [`FINAL_RELEASE_CANDIDATE_AUDIT.md`](FINAL_RELEASE_CANDIDATE_AUDIT.md);
- [`FINAL_1_5_AUTOMATED_VERIFICATION.md`](FINAL_1_5_AUTOMATED_VERIFICATION.md);
- `PHASE_*_VERIFICATION.md` records;
- [`PHASE_31_PWA_VERIFICATION.md`](PHASE_31_PWA_VERIFICATION.md).

List all phase records:

```bash
git ls-files 'docs/PHASE_*'
```

Continuity archives:

- [`../what_changed_archive_phase_00_30.md`](../what_changed_archive_phase_00_30.md);
- [`../what_changed_archive_phase_31.md`](../what_changed_archive_phase_31.md);
- [`../what_changed_archive_phase_32.md`](../what_changed_archive_phase_32.md);
- [`../what_changed.md`](../what_changed.md) — active continuity.

## 13. Documentation rules after source completion

- Do not restore an active optional-feature backlog inside completed Version 2.0.12 scope.
- Do not describe historical Version 1.5 automation as current 2.0.12 evidence.
- Do not convert hosted builds into physical-device, accessibility, handler, signing, provisioning, PWA-lifecycle, or store evidence.
- Do not describe imported portable progress as trusted/ranked.
- Do not describe Challenge Code checksums as authentication.
- Do not silently add analytics, ads, accounts, cloud services, remote AI, camera permissions, or network dependencies.
- Keep signing secrets/private credentials outside public source.
- When behavior changes in a future release, update source, tests, user/architecture/privacy/security/accessibility/build/release docs together.

## 14. Literal no-skip documentation inventory

```bash
git ls-files 'docs/**' | sort
```

PowerShell:

```powershell
git ls-files 'docs/**' | Sort-Object
```

The repository audit validates required documentation and repository-local Markdown links. [`DOCUMENTATION_AUDIT_CHECKLIST.md`](DOCUMENTATION_AUDIT_CHECKLIST.md) defines the complete future review sequence.

## 15. Project identity

- Project: **2048 Nova**
- Creator branding: **Made by the Sanskar**
- License: MIT
- Business: `sanskarin@outlook.in`, `sanskarin.business@gmail.com`
- Support: `supportramsandesh@gmail.com`
- Buy Me a Coffee: `https://buymeacoffee.com/sanskarIN`

For current public profile/product links, use the root [`README.md`](../README.md).