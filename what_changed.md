# 2048 Nova — Active Continuity

This is the active Version 2.0.12 maintenance record.

Historical continuity is preserved in:

- [`what_changed_archive_phase_00_30.md`](what_changed_archive_phase_00_30.md) — Phases 0–30;
- [`what_changed_archive_phase_31.md`](what_changed_archive_phase_31.md) — Phase 31;
- [`what_changed_archive_phase_32.md`](what_changed_archive_phase_32.md) — Version 2.0.12 migration/source-completion Phase 32;
- [`CHANGELOG_ARCHIVE_PRE_2_0_12.md`](CHANGELOG_ARCHIVE_PRE_2_0_12.md) — pre-2.0.12 changelog history.

## Current repository state

- **Current phase:** Phase 33 — complete documentation, setup, command, terminology, and support-lifecycle hardening.
- **Marketing version:** `2.0.12`.
- **Flutter package/build version:** `2.0.12+2012`.
- **Source scope:** feature-complete; Phase 33 does not reopen the completed product-feature backlog.
- **Branch:** `main`.
- **Manual evidence:** stable qualification boundary remains 0/13. No physical-device, assistive-technology, real browser/PWA lifecycle, external-handler, native-branding, signing/provisioning, or store evidence is being invented by documentation work.
- **Toolchain contract:** CI Flutter 3.47.0 stable; AGP 9.1.0; Kotlin Android 2.4.10; Gradle 9.7.0; Android Java/Kotlin target 17.

# Phase 33 — Complete documentation and toolchain lifecycle hardening

Date: **2026-08-19**

## Goal

Make the project documentation usable from beginner installation through advanced maintenance without requiring readers to copy unknown commands or guess technical terms.

The phase specifically adds:

- complete installation/prerequisite guidance;
- host-specific Windows, macOS/iOS, and Linux setup;
- deep Android Studio/SDK/JDK/Gradle/AGP/Kotlin/ADB/emulator/APK/AAB/signing guidance;
- explicit instructions for unsupported/end-of-life tools;
- explanations of command/subcommand/argument/flag meanings;
- a technical/gameplay/testing/security/build glossary;
- a no-skip repository file atlas;
- a consolidated implemented-feature reference;
- regression protection for the new documentation;
- correction of stale current-version data in the executable handbook.

## Live-source audit before writing

The documentation phase was based on the live repository rather than old assumptions.

Confirmed current source values:

```text
pubspec package/build: 2.0.12+2012
Dart: >=3.9.0 <4.0.0
Flutter floor: >=3.35.0
CI Flutter: 3.47.0
AGP: 9.1.0
Kotlin Android: 2.4.10
Gradle Wrapper: 9.7.0
Android JVM target: 17
applicationId: com.sanskarin.nova_2048
```

The phase also inspected the live `lib/`, `lib/domain/`, `lib/app/`, `lib/data/`, `lib/features/`, `test/`, `tool/`, `docs/build/`, CI, and Android configuration trees so documentation responsibilities are grounded in current files.

## Documentation defect found and fixed

`docs/BUILDING_EXECUTABLES.md` still contained old current-state `1.5.0+15` package/build examples despite the live source being `2.0.12+2012`.

That handbook was rebuilt rather than leaving a partial correction. It now describes the actual Version 2.0.12 source contract and current platform/toolchain boundaries.

This matters because release-facing documentation must not disagree with `pubspec.yaml`.

## Complete prerequisites guide

Added [`docs/setup/PREREQUISITES.md`](docs/setup/PREREQUISITES.md).

It explains:

- Git;
- Flutter SDK;
- bundled Dart SDK;
- terminal/shell choices;
- VS Code and Flutter/Dart extensions;
- Android Studio and Android SDK;
- JDK 17 project baseline;
- Gradle Wrapper versus global Gradle;
- Visual Studio versus VS Code for Windows desktop;
- Xcode/CocoaPods requirements;
- Linux Clang/CMake/Ninja/pkg-config/GTK dependencies;
- Web prerequisites;
- package managers;
- tools that are **not** required merely to build this Flutter project;
- first environment-validation sequence.

## Windows installation and maintenance guide

Added [`docs/setup/WINDOWS.md`](docs/setup/WINDOWS.md).

It covers:

- supported Windows build targets;
- recommended install order;
- Git with WinGet and repository-local identity;
- Flutter extraction/PATH placement and duplicate-SDK diagnosis;
- stable channel/upgrade behavior;
- VS Code extensions;
- Android Studio/SDK/licenses;
- JDK selection and `flutter config --jdk-dir`;
- Gradle Wrapper use;
- Visual Studio **Desktop development with C++** requirement;
- project clone/validation/run/build procedures;
- Android APK/AAB, Windows, and Web builds;
- safe upgrades;
- PATH troubleshooting;
- clean build recovery.

## macOS/iOS installation and maintenance guide

Added [`docs/setup/MACOS.md`](docs/setup/MACOS.md).

It covers:

- Apple Command Line Tools;
- Git;
- Flutter PATH setup;
- Xcode selection/first launch;
- CocoaPods;
- optional Android Studio and VS Code;
- macOS builds;
- iOS Simulator;
- unsigned iOS release compilation;
- signed IPA boundary;
- Apple signing/provisioning secret safety;
- Android/Web builds on macOS;
- Flutter/Xcode/Android/CocoaPods upgrades;
- common Xcode/CocoaPods/PATH recovery.

## Linux installation and maintenance guide

Added [`docs/setup/LINUX.md`](docs/setup/LINUX.md).

It covers:

- Git and Flutter setup;
- Clang;
- CMake;
- Ninja;
- pkg-config;
- GTK development libraries;
- Android SDK/JDK;
- Gradle Wrapper;
- optional VS Code;
- Linux/Web/Android builds;
- distribution package-manager differences;
- native dependency diagnostics;
- safe OS/tool upgrades.

## Deep Android toolchain guide

Added [`docs/setup/ANDROID.md`](docs/setup/ANDROID.md).

It defines and explains:

- Android Studio;
- Android SDK and its package families;
- SDK licenses;
- ADB;
- physical-device development authorization boundary;
- Android Emulator and AVD;
- JDK/JRE/JVM differences;
- Gradle and Gradle Wrapper;
- AGP;
- Kotlin Android plugin;
- `compileSdk`, `targetSdk`, `minSdk`;
- NDK;
- namespace/application ID;
- debug/profile/release modes;
- APK;
- AAB;
- distribution signing versus CI debug-signing qualification fallback;
- `key.properties` and keystore secret rules;
- `sdkmanager`;
- Gradle deprecation inspection;
- safe Android toolchain migration order;
- first diagnostic sequence and common failures.

## Unsupported/out-of-support upgrade lifecycle

Added [`docs/setup/UPGRADING_AND_SUPPORT.md`](docs/setup/UPGRADING_AND_SUPPORT.md).

The project now has one detailed answer for what to do when a tool becomes outdated, deprecated, insecure, unsupported, or EOL.

It defines:

- current/supported/EOL/deprecated/breaking change/pin/floor/compatibility matrix;
- why “latest” is not automatically the correct compatibility set;
- how to detect support status;
- security versus routine versus major upgrade urgency;
- why all toolchain layers should not be upgraded blindly at once;
- clean branch-based migration workflow;
- dependency/native build/CI/real-world validation expectations;
- rollback strategy.

It includes specific upgrade sections for:

```text
Flutter
Dart
Git
Android Studio
Android SDK
JDK
Gradle
AGP
Kotlin
Xcode
CocoaPods
Visual Studio
VS Code
CMake
Ninja
operating systems
Flutter package dependencies
CI pins
store/platform policy deadlines
unsupported dependencies
```

## Command reference

Added [`docs/COMMAND_REFERENCE.md`](docs/COMMAND_REFERENCE.md).

This document explains instead of merely listing commands. It covers:

- executable, command, subcommand, argument, option/flag;
- shell notation;
- navigation;
- Git commands and identity;
- Flutter/Dart diagnostic/channel/config/device commands;
- Pub dependency commands;
- formatting, analyzer, test, coverage, run, clean;
- Android build modes, ABI splits, AAB, build-name/build-number;
- Web/Windows/Linux/macOS/iOS/IPA builds;
- repository-owned audit/release tools and their flags;
- Gradle Wrapper/tasks/deprecation/upgrade syntax;
- Android `sdkmanager`;
- Java/JDK;
- Xcode;
- CocoaPods;
- checksums;
- WinGet;
- Debian/Ubuntu package commands;
- exit codes;
- safe command-review workflow.

## Glossary

Added [`docs/GLOSSARY.md`](docs/GLOSSARY.md).

It defines major terms used across the project, including:

- AAB, APK, ABI, ADB, AGP, API/API level, artifact;
- build/binary/bundle/checksum/CI/CLI/compiler;
- Dart/Flutter/Gradle/JDK/JVM/Kotlin/Xcode/CocoaPods;
- SDK/NDK/PWA/Wasm;
- signing/provisioning/notarization;
- dependencies/lockfile/supply chain;
- Git concepts;
- release/qualification/fail-closed/manual evidence;
- privacy/security/trust boundaries;
- deterministic RNG/seed;
- board/move/merge/spawn/Undo/Hint/Auto Play/replay/Challenge Code;
- documentation/current-versus-historical terminology.

## No-skip repository file atlas

Added [`docs/REPOSITORY_FILE_ATLAS.md`](docs/REPOSITORY_FILE_ATLAS.md).

It explains root files and the responsibilities of:

```text
.github/
lib/
lib/app/
lib/core/
lib/data/
lib/domain/
lib/features/
lib/shared/
test/
tool/
assets/
android/
ios/
web/
windows/
macos/
linux/
docs/
docs/build/
docs/setup/
```

The exact no-skip file inventory remains executable rather than hard-coded:

```bash
git ls-files
```

The atlas explains why this is superior to a permanent manually maintained file count and gives commands for per-directory inventories, status checks, unfinished-marker review, repository/source audits, tests, and builds.

## Setup index

Added [`docs/setup/README.md`](docs/setup/README.md).

It routes contributors by host and target, explains the first universal workflow, differentiates tools from dependencies, explains what Flutter Doctor does/does not prove, and directs unsupported tools to the lifecycle guide.

## Executable handbook rebuilt

`docs/BUILDING_EXECUTABLES.md` was replaced with a Version 2.0.12-current handbook that now covers:

- source/toolchain baseline;
- installation-document links;
- host/target compatibility;
- clone/prepare/clean/quality gates;
- artifact matrix;
- Android debug/profile/release/split APKs and AAB;
- Android signing/version fields;
- iOS unsigned and IPA boundaries;
- Web/PWA deployment output;
- Windows/macOS/Linux bundle behavior;
- checksums;
- permanent CI and native build matrix;
- troubleshooting;
- unsupported-tool workflow;
- final release order;
- explicit claims that must not be made without evidence.

## Canonical documentation index expanded

`docs/README.md` now starts with a beginner reading path and includes dedicated installation/toolchain, command/reference, player, architecture, platform/build, CI/release, source-of-truth, historical-record, and no-skip documentation sections.

## Complete feature reference

Added [`docs/FEATURE_REFERENCE.md`](docs/FEATURE_REFERENCE.md).

It consolidates the implemented product surface, including:

- core deterministic gameplay;
- all ten modes;
- controls;
- save/resume;
- Undo;
- statistics/achievements/per-mode records;
- Hint;
- Heuristic and Expectimax solvers;
- Auto Play;
- benchmark;
- Move Replay and Full Replay Archives;
- backup/file backup;
- Challenge Codes/QR;
- Daily Challenge;
- localization;
- themes/accessibility/reduced motion;
- About/Guide/Support/external links;
- offline-first/privacy/data reset;
- all six platform runners;
- branding;
- repository/source/release audits and CI.

## Documentation regression protection

Added `test/documentation_completeness_test.dart`.

It protects:

- presence of the new setup/reference documents;
- current Version 2.0.12 build-handbook identity;
- absence of the old `version: 1.5.0+15` current declaration from the build handbook;
- setup-index links to support lifecycle, command reference, glossary, and file atlas;
- docs-index discoverability;
- required compatibility-first upgrade workflow content.

The test automatically joins the existing `flutter test` suite because CI runs all tests.

## Phase 32 archive

The former active Phase 32 continuity was moved into [`what_changed_archive_phase_32.md`](what_changed_archive_phase_32.md) before this Phase 33 record became active, preserving the migration/source-completion history rather than deleting it.

## Phase 33 commit sequence so far

```text
0a3f600d  docs: add complete development prerequisites guide
bb9d41c1  docs: add deep Windows installation and setup guide
1ff6f41a  docs: add exhaustive command and flag reference
cdef662b  docs: add deep macOS and iOS host setup guide
36c36989  docs: add deep Linux installation and setup guide
61bcd3b0  docs: add complete Android toolchain setup guide
391a09fe  docs: add unsupported tool and upgrade lifecycle guide
c60bddae  docs: add comprehensive project and toolchain glossary
0e0773e5  docs: add no-skip repository file atlas
27033049  docs: add environment setup documentation index
e39a7b10  docs: rebuild executable handbook for Version 2.0.12
1f7a8ae5  docs: expand canonical documentation index
b8e7d7da  test: protect complete setup and command documentation
fcf3a112  docs: add complete implemented feature reference
f311e33b  docs: archive completed Phase 32 continuity
```

This active file is committed separately so the continuity update itself remains an auditable, granular change.

## Verification boundary for this documentation phase

The changes are being pushed directly to `main` as small meaningful commits. A push/commit is not being treated as proof that all workflows passed.

Before this phase is described as automation-verified, the maintained checks must actually be observed on the current Phase 33 head.

At minimum the expected automated path is:

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

Native platform builds remain a separate workflow/evidence class.

## Stable release boundary

Phase 33 is documentation/tooling maintenance. It does not alter the genuine manual release evidence.

The stable qualification boundary remains 0/13 until actual representative checks are completed and recorded.

No documentation expansion, test, hosted build, or commit count may be used to fabricate those real-world results.
