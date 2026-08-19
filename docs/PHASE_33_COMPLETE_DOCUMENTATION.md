# Phase 33 — Complete Documentation and Toolchain Lifecycle Hardening

Date: **2026-08-19**

Version line: **2.0.12+2012**

## 1. Purpose

Phase 33 is a documentation and maintainability phase inside the already feature-complete Version 2.0.12 source line.

It does **not** reopen the product-feature backlog.

Its goal is to make the repository understandable from:

```text
fresh computer
→ tool installation
→ SDK/IDE setup
→ project architecture
→ feature behavior
→ testing
→ builds
→ error diagnosis
→ tool upgrades/EOL migration
→ contribution/PR
→ release qualification
```

without forcing a reader to copy commands they do not understand or guess the meaning of technical terms.

## 2. Release-phase compatibility

The repository's protected Version 2.0.12 release/source-completion contract remains Phase 32.

Phase 33 is an **active maintenance stream**, not a new product release phase.

This distinction preserves the existing repository-audit contract while allowing substantial documentation hardening.

## 3. Source/toolchain facts used by this phase

The documentation was grounded in the live repository values:

```text
Package/build: 2.0.12+2012
Dart: >=3.9.0 <4.0.0
Flutter floor: >=3.35.0
Hosted CI Flutter: 3.47.0 stable
Android Gradle Plugin: 9.1.0
Kotlin Android plugin: 2.4.10
Gradle Wrapper: 9.7.0
Android Java/Kotlin target: JVM 17
Android application ID: com.sanskarin.nova_2048
```

## 4. Important stale-documentation defect corrected

The old `docs/BUILDING_EXECUTABLES.md` still used the obsolete current package/build value:

```text
1.5.0+15
```

while the live source was:

```text
2.0.12+2012
```

The handbook was rebuilt around the actual Version 2.0.12 source/toolchain contract.

This is a meaningful correctness fix because release-facing build documentation must not contradict `pubspec.yaml`.

## 5. Complete setup documentation added

Phase 33 adds a dedicated setup tree under:

```text
docs/setup/
```

including:

- `README.md` — setup index;
- `PREREQUISITES.md` — every required/optional tool and purpose;
- `WINDOWS.md` — Windows workstation setup;
- `MACOS.md` — macOS/iOS workstation setup;
- `LINUX.md` — Linux workstation setup;
- `ANDROID.md` — complete Android toolchain;
- `UPGRADING_AND_SUPPORT.md` — unsupported/EOL tool lifecycle;
- `FLUTTER_AND_DART.md` — Flutter/Dart SDK handbook;
- `GIT.md` — Git/GitHub contributor handbook;
- `VS_CODE.md` — VS Code setup/debugging;
- `ANDROID_STUDIO.md` — Android Studio/SDK/AVD/Gradle IDE handbook;
- `VISUAL_STUDIO_WINDOWS.md` — Windows native Visual Studio toolchain;
- `XCODE_AND_COCOAPODS.md` — Apple native toolchain;
- `LINUX_NATIVE_TOOLCHAIN.md` — Clang/CMake/Ninja/pkg-config/GTK.

## 6. Prerequisites guide

`docs/setup/PREREQUISITES.md` explains why each tool is needed instead of producing a flat install list.

It distinguishes:

```text
Flutter SDK
bundled Dart SDK
Git
editor
native IDE/toolchain
Android SDK/JDK/Gradle layers
Apple toolchain
Linux native packages
Web browser/deployment requirements
```

It also explicitly lists common tools that are **not required** merely to build this Flutter project, reducing unnecessary installs/conflicts.

## 7. Windows guide

`docs/setup/WINDOWS.md` covers:

- Git/WinGet;
- Flutter SDK placement and PATH;
- duplicate SDK diagnosis;
- stable-channel upgrade workflow;
- VS Code;
- Android Studio/SDK/licenses;
- JDK selection;
- Gradle Wrapper;
- Visual Studio C++ desktop requirement;
- clone/verify/run/build flow;
- Android APK/AAB;
- Windows/Web releases;
- upgrade and PATH recovery.

## 8. macOS/iOS guide

`docs/setup/MACOS.md` covers:

- Apple Command Line Tools;
- Flutter PATH;
- Xcode selection/first launch;
- CocoaPods;
- Android Studio/VS Code;
- macOS release;
- iOS Simulator;
- unsigned iOS qualification;
- signed IPA boundary;
- Apple secret safety;
- tool upgrades/troubleshooting.

## 9. Linux guide

`docs/setup/LINUX.md` covers:

- Git/Flutter;
- Clang;
- CMake;
- Ninja;
- pkg-config;
- GTK development libraries;
- Android/JDK;
- Gradle Wrapper;
- Linux/Web/Android builds;
- distribution package-manager differences;
- native diagnostics/upgrades.

## 10. Android toolchain guide

`docs/setup/ANDROID.md` explains the complete relationship between:

```text
Android Studio
Android SDK
ADB
AVD/Emulator
JDK/JRE/JVM
Gradle/Wrapper
AGP
Kotlin
compileSdk
targetSdk
minSdk
NDK
application ID/namespace
APK
AAB
signing
```

It also documents private production signing versus hosted release-mode qualification fallback.

## 11. Tool support and EOL lifecycle

`docs/setup/UPGRADING_AND_SUPPORT.md` establishes the project policy:

```text
supported + compatible + reproducible + validated
```

rather than:

```text
never upgrade
```

or:

```text
install newest everything at once
```

It contains separate upgrade procedures for Flutter, Dart, Git, Android Studio/SDK/JDK/Gradle/AGP/Kotlin, Xcode/CocoaPods, Visual Studio/VS Code, CMake/Ninja, OSes, dependencies, CI pins, and external store/platform deadlines.

## 12. Flutter/Dart handbook

`docs/setup/FLUTTER_AND_DART.md` explains:

- SDK relationship;
- installation locations;
- PATH;
- channels;
- Flutter Doctor;
- devices/emulators;
- Pub/lockfile;
- formatting/analyzer/tests;
- build modes;
- SDK move/duplicate diagnosis;
- template migration;
- rollback/support policy.

## 13. Git/GitHub handbook

`docs/setup/GIT.md` explains:

- Git versus GitHub;
- installation/upgrades;
- identity;
- working tree/index/commit;
- diffs/staging;
- branches/fetch/pull/push;
- HTTPS/SSH credential boundary;
- `.gitignore`/`.gitattributes`;
- restore/revert/stash;
- merge/rebase/conflicts;
- tags/PRs/issues/Actions;
- branch protection;
- secret handling;
- safe recovery.

## 14. VS Code handbook

`docs/setup/VS_CODE.md` explains:

- VS Code versus Visual Studio;
- Flutter/Dart extensions;
- project-root opening;
- SDK selection;
- integrated terminal;
- analysis/formatting;
- device selector;
- debug/hot reload/restart;
- tests;
- Source Control;
- updates;
- common editor/SDK/device troubleshooting.

## 15. Android Studio handbook

`docs/setup/ANDROID_STUDIO.md` explains:

- Android Studio versus Android SDK;
- SDK Manager;
- Platform-Tools/ADB;
- Command-line Tools;
- Flutter plugin;
- bundled JBR/JDK;
- Gradle sync/Wrapper;
- AGP/Kotlin update boundaries;
- Device Manager/AVDs;
- emulator acceleration;
- Logcat;
- physical-device debugging;
- signing/local properties;
- updates/caches/multiple SDKs.

## 16. Visual Studio Windows handbook

`docs/setup/VISUAL_STUDIO_WINDOWS.md` explains:

- why VS Code is insufficient for Windows native builds;
- Desktop development with C++ workload;
- MSVC;
- MSBuild;
- Windows SDK;
- CMake;
- Windows runner/resource metadata;
- full runtime bundle packaging;
- Visual Studio upgrades/unsupported versions;
- common native Windows errors.

## 17. Xcode/CocoaPods handbook

`docs/setup/XCODE_AND_COCOAPODS.md` explains:

- Xcode/Command Line Tools;
- `xcode-select`/`xcodebuild`;
- CocoaPods install/upgrade/path conflicts;
- Simulator;
- macOS/iOS builds;
- signing/provisioning/entitlements;
- notarization;
- Organizer/archive;
- Xcode upgrade implications;
- deployment-target/Pod/signing troubleshooting.

## 18. Linux native toolchain handbook

`docs/setup/LINUX_NATIVE_TOOLCHAIN.md` explains:

- Clang/Clang++;
- CMake;
- Ninja;
- pkg-config;
- GTK development libraries;
- C++ standard-library development packages;
- distro package-manager differences;
- ELF/shared-library/runtime-bundle behavior;
- Linux distribution compatibility;
- `.deb`/`.rpm`/AppImage/Snap/Flatpak boundaries;
- common linker/compiler/library errors.

## 19. Command reference

`docs/COMMAND_REFERENCE.md` explains what commands and flags **mean** rather than only listing them.

It covers shell/Git/Flutter/Pub/formatter/analyzer/test/build/repository-tool/Gradle/Android SDK/Java/Xcode/CocoaPods/checksum/package-manager commands and exit codes.

## 20. Glossary

`docs/GLOSSARY.md` defines the major:

- Flutter/Dart/Git terms;
- Android/Apple/Windows/Linux build terms;
- CI/release/security/testing terms;
- package/dependency/supply-chain terms;
- gameplay/solver/replay/challenge terms;
- documentation/current-versus-historical terms.

## 21. Repository file atlas

`docs/REPOSITORY_FILE_ATLAS.md` explains the responsibilities of root/source/test/tool/platform/docs areas and provides the literal no-skip inventory command:

```bash
git ls-files
```

It deliberately avoids a hard-coded permanent file count that would become stale after the next legitimate commit.

## 22. Feature reference

`docs/FEATURE_REFERENCE.md` provides one consolidated map of all implemented Version 2.0.12 features and their source/canonical documentation.

It includes the core engine, ten modes, save/Undo, stats/achievements, solvers/Auto Play, replays/backups/challenges, localization/accessibility, platform/build/release tooling, privacy, and CI.

## 23. Architecture walkthrough

`docs/ARCHITECTURE_WALKTHROUGH.md` follows real flows through:

```text
startup
moves/merge/spawn
mode lifecycle
Undo
save/resume
settings/theme/localization
statistics/records
daily challenge
challenge codes/QR
backup/file transport
replay archives
hint/heuristic/expectimax/autoplay
platform runners
build pipelines
audits/CI/release gates
```

and explains major trust boundaries.

## 24. Error reference

`docs/ERROR_REFERENCE.md` provides a large diagnostic map for:

- Flutter/Dart/Pub/PATH;
- formatting/analyzer/tests;
- game/backup/replay/challenge behavior;
- Android SDK/ADB/emulator/JDK/Gradle/signing;
- Windows Visual Studio/CMake/bundling;
- Xcode/CocoaPods/signing;
- Linux native dependencies;
- Web/PWA deployment;
- repository/source/release audits;
- Git/PR protection;
- dependency/tool/OS upgrades.

It consistently warns against weakening validation/security gates simply to produce a green command.

## 25. New contributor tutorial

`docs/NEW_CONTRIBUTOR_TUTORIAL.md` takes a contributor through:

```text
install/verify tools
clone
Git identity
protected-main branch flow
baseline tests/audits
repository exploration
architecture tracing
safe docs/code edit
format/analyze/test/audit/build
review/stage/commit
push branch
open PR
observe checks
merge/update local main
```

## 26. Documentation audit checklist

`docs/DOCUMENTATION_AUDIT_CHECKLIST.md` makes future documentation maintenance reproducible.

It covers:

- no-skip Markdown inventory;
- version/toolchain reconciliation;
- current-versus-historical review;
- setup/build/index/commands/glossary/feature/architecture/error docs;
- dependency/privacy/security/accessibility/game/portable-format/build/signing/CI wording;
- link checks;
- secret/shell/cross-platform/EOL checks;
- final automated commands and PR checklist.

## 27. Documentation regression protection

`test/documentation_completeness_test.dart` was introduced during Phase 33 so key current setup/reference documents cannot disappear or silently revert to the obsolete Version 1.5 build-handbook identity.

It is extended as Phase 33 adds canonical guides.

## 28. Continuity preservation

The former long Phase 32 continuity record was preserved in:

```text
what_changed_archive_phase_32.md
```

The active `what_changed.md` retains the exact frozen Phase 32 release/source-completion marker required by repository audit while separately recording Phase 33 as the active maintenance stream.

## 29. Protected-main transition during Phase 33

Early Phase 33 commits were accepted directly on `main` before the repository rule became active.

During the phase, GitHub began rejecting direct `main` writes with:

```text
Changes must be made through a pull request.
```

At that point the remaining work moved to:

```text
docs/phase-33-complete-documentation
```

for a normal pull request into protected `main`.

This is treated as improved repository governance, not an error to bypass.

## 30. Evidence boundary

Phase 33 documentation work does not alter the manual stable-release evidence.

The stable qualification boundary remains 0/13 until genuine representative environments are tested and recorded.

No documentation count, commit count, hosted compile, or unit/widget test can substitute for those real checks.

## 31. Automated verification expected for the PR

The maintained validation path includes:

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

Native platform builds are separate workflow/evidence.

A workflow must be actually observed as completed/successful before it is recorded as passed.

## 32. Phase completion rule

Phase 33 is complete when:

```text
[ ] all intended guides exist
[ ] setup/docs indexes link them
[ ] documentation regression tests protect them
[ ] current build/version references match source
[ ] repository-local links pass audit
[ ] formatter/analyzer/tests/audits pass on the PR head
[ ] required PR checks/reviews pass
[ ] protected-main PR is merged
[ ] active continuity records the final merged commit/evidence honestly
```

The 13 manual stable-release checks remain a separate release-qualification activity.
