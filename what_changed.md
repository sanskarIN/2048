# 2048 Nova — Active Continuity

This is the active Version 2.0.12 maintenance record.

Historical continuity is preserved in:

- [`what_changed_archive_phase_00_30.md`](what_changed_archive_phase_00_30.md) — Phases 0–30;
- [`what_changed_archive_phase_31.md`](what_changed_archive_phase_31.md) — Phase 31;
- [`what_changed_archive_phase_32.md`](what_changed_archive_phase_32.md) — detailed Version 2.0.12 migration/source-completion record;
- [`CHANGELOG_ARCHIVE_PRE_2_0_12.md`](CHANGELOG_ARCHIVE_PRE_2_0_12.md) — pre-2.0.12 changelog history.

## Current repository state

- **Current phase:** Phase 32 — Version 2.0.12 source-completion/release audit contract remains the canonical release phase protected by `tool/repository_audit.dart`.
- **Active maintenance stream:** Phase 33 — complete documentation, setup, command, terminology, and support-lifecycle hardening.
- **Marketing version:** `2.0.12`.
- **Flutter package/build version:** `2.0.12+2012`.
- **Source scope:** feature-complete; Phase 33 maintenance does not reopen the completed Version 2.0.12 product-feature backlog.
- **Branch:** `main`.
- **Manual evidence:** stable qualification boundary remains 0/13. No physical-device, assistive-technology, real browser/PWA lifecycle, external-handler, native-branding, signing/provisioning, or store evidence is being invented by documentation work.
- **Toolchain contract:** CI Flutter 3.47.0 stable; AGP 9.1.0; Kotlin Android 2.4.10; Gradle 9.7.0; Android Java/Kotlin target 17.

The `Current phase: Phase 32` line is intentionally retained because the repository integrity audit treats Phase 32 as the frozen Version 2.0.12 release/source-completion contract. Phase 33 is a maintenance/documentation stream inside that completed release line, not a new product release or feature scope.

# Phase 33 — Complete documentation and toolchain lifecycle hardening

Date: **2026-08-19**

## Goal

Make the project documentation usable from a new developer workstation through advanced maintenance without requiring readers to copy unknown commands, guess technical terms, or use unsupported tools.

Phase 33 adds or hardens:

- complete tool prerequisites and installation guidance;
- Windows, macOS/iOS, Linux, and Android-specific environment setup;
- end-of-support / EOL upgrade policy for development tools;
- command/subcommand/argument/flag explanations;
- a comprehensive glossary;
- a no-skip repository file atlas;
- a consolidated implemented-feature reference;
- complete executable/build instructions using the actual Version 2.0.12 source values;
- regression protection for the new documentation;
- continuity archives so older phases are not erased.

## Live source checked before writing

The phase inspected the repository's current source/configuration instead of using old prompt assumptions.

Confirmed current values:

```text
pubspec package/build: 2.0.12+2012
Dart constraint: >=3.9.0 <4.0.0
Flutter floor: >=3.35.0
Hosted CI Flutter: 3.47.0 stable
Android Gradle Plugin: 9.1.0
Kotlin Android plugin: 2.4.10
Gradle Wrapper: 9.7.0
Android Java/Kotlin bytecode target: 17
Android applicationId: com.sanskarin.nova_2048
```

The live `lib/`, `lib/app/`, `lib/core/`, `lib/data/`, `lib/domain/`, `lib/features/`, `test/`, `tool/`, `docs/build/`, Android build files, and CI workflow were also inspected to ground the new documentation in current paths.

## Important stale documentation bug fixed

The previous `docs/BUILDING_EXECUTABLES.md` still contained obsolete current-state `1.5.0+15` examples while `pubspec.yaml` already declared `2.0.12+2012`.

The handbook was rebuilt around the actual Version 2.0.12 source/toolchain contract instead of applying only a cosmetic version replacement.

The new handbook covers prerequisites, source validation, every maintained target, artifact meanings, signing boundaries, packaging/checksums, CI qualification, unsupported-tool handling, troubleshooting, and final release ordering.

## New complete setup documentation

### `docs/setup/PREREQUISITES.md`

Explains Git, Flutter, Dart, terminals, VS Code, Android Studio, Android SDK, JDK 17, Gradle Wrapper, Visual Studio, Xcode, CocoaPods, Linux native packages, Web prerequisites, package managers, tools not required by this Flutter project, and first environment validation.

### `docs/setup/WINDOWS.md`

Explains Git/WinGet, Flutter installation and `PATH`, duplicate SDK diagnosis, VS Code extensions, Android Studio, SDK/licenses, JDK selection, Gradle Wrapper, Visual Studio **Desktop development with C++**, clone/validation/build commands, Android/Windows/Web output, safe upgrades, and Windows troubleshooting.

### `docs/setup/MACOS.md`

Explains Apple Command Line Tools, Git, Flutter `PATH`, Xcode selection/first launch, CocoaPods, optional Android Studio/VS Code, macOS/iOS/Web/Android builds, simulator use, unsigned iOS release qualification, signed IPA boundary, tool upgrades, and Apple-platform troubleshooting.

### `docs/setup/LINUX.md`

Explains Git/Flutter installation, Clang, CMake, Ninja, pkg-config, GTK development libraries, Android/JDK, Gradle Wrapper, VS Code, Linux/Web/Android builds, distribution package-manager differences, native dependency troubleshooting, and safe upgrades.

### `docs/setup/ANDROID.md`

Explains Android Studio, Android SDK package families, SDK licenses, ADB, authorized physical-device debugging, AVD/emulator, JDK/JRE/JVM, Gradle/Wrapper, AGP, Kotlin, `compileSdk`/`targetSdk`/`minSdk`, NDK, namespace/application ID, build modes, APK/AAB, signing, `key.properties`, `sdkmanager`, deprecation checks, upgrade ordering, diagnostics, and common failures.

### `docs/setup/UPGRADING_AND_SUPPORT.md`

Provides the complete lifecycle policy for an outdated, deprecated, insecure, unsupported, or EOL tool.

It includes detection, severity classification, compatibility review, migration branches, rollback strategy, CI adoption, real-world qualification, and separate upgrade procedures for:

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
Flutter packages
CI pins
external store/platform policy deadlines
unsupported dependencies
```

### `docs/setup/README.md`

Routes a contributor by host and target and explains the first universal validation workflow, tool-versus-dependency distinctions, what Flutter Doctor proves, what it does not prove, and how to handle older/newer local toolchains.

## New command reference

`docs/COMMAND_REFERENCE.md` explains commands rather than only listing them.

Covered areas include:

- executable/command/subcommand/argument/flag terminology;
- shell/navigation commands;
- Git clone/status/diff/add/commit/pull/push/config;
- Flutter/Dart diagnostics/channel/config/devices/emulators;
- Pub resolution/outdated/upgrade/major-version behavior;
- formatting/analyzer/tests/coverage/run/clean;
- Android debug/profile/release/split APK/AAB and version overrides;
- Web/Windows/Linux/macOS/iOS/IPA builds;
- release/readiness/repository/source-completion tools and flags;
- Gradle Wrapper/tasks/deprecation warnings/upgrade syntax;
- Android `sdkmanager`;
- Java/JDK;
- Xcode;
- CocoaPods;
- SHA-256 checksums;
- WinGet and Debian/Ubuntu package commands;
- exit codes and safe command-review workflow.

## New glossary

`docs/GLOSSARY.md` defines development, build, release, security, testing, platform, and gameplay language including AAB/APK/ABI/ADB/AGP/API, artifact, compiler, SDK/NDK, Flutter/Dart/Gradle/Kotlin/JDK/JVM, Xcode/CocoaPods, Git concepts, signing/provisioning/notarization, dependency/lockfile/supply chain, PWA/Wasm, CI/qualification/fail-closed/manual evidence, deterministic RNG/seed, board/move/merge/spawn, Undo/Hint/Auto Play/replay/Challenge Code, privacy/trust boundary, and current-versus-historical documentation terminology.

## New no-skip repository file atlas

`docs/REPOSITORY_FILE_ATLAS.md` explains the responsibilities of the root files and these maintained trees:

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

The literal current tracked-file inventory is intentionally generated with:

```bash
git ls-files
```

This avoids a stale hard-coded file count and makes the no-skip audit reproducible after future maintenance commits.

## New complete feature reference

`docs/FEATURE_REFERENCE.md` consolidates the implemented Version 2.0.12 product surface:

- deterministic core gameplay and RNG;
- all ten game modes;
- touch/keyboard/input controls;
- save/resume and bounded Undo;
- statistics, achievements, and per-mode records;
- Hint;
- Heuristic and Expectimax solvers;
- isolated Auto Play and deterministic benchmark;
- Move Replay and Full Replay Archives;
- current-game backup and file import/export;
- Challenge Codes and QR representation;
- Daily Challenge;
- English/Hindi localization;
- themes, accessibility, reduced motion;
- About, Guide, Support, external links;
- offline-first/privacy/data-reset behavior;
- Android/iOS/Web/Windows/macOS/Linux runners;
- branding;
- repository/source/release audit tooling and CI.

## Documentation index rebuilt

`docs/README.md` now includes:

- beginner reading order;
- installation/toolchain guides;
- command/glossary/file reference;
- player behavior docs;
- accessibility/localization/privacy/security docs;
- architecture/development/testing/dependency docs;
- build/distribution docs;
- CI/release qualification docs;
- current source-of-truth map;
- historical evidence boundary;
- no-skip docs inventory command.

## Documentation regression tests

`test/documentation_completeness_test.dart` was added and expanded.

It protects:

- required setup/reference/feature/continuity files;
- Version `2.0.12+2012` build-handbook identity;
- absence of the obsolete `version: 1.5.0+15` current build declaration;
- setup-index links to lifecycle/commands/glossary/file atlas;
- canonical docs-index setup references;
- implemented-feature reference coverage;
- compatibility-first upgrade workflow content;
- active continuity's Phase 33 maintenance record and Phase 32 archive pointer.

## Phase 32 continuity archive

The detailed former active Phase 32 narrative is preserved in `what_changed_archive_phase_32.md`.

That archive does not change the repository audit's canonical release-phase marker: Version 2.0.12 still uses the Phase 32 source-completion/release contract while Phase 33 is the active maintenance stream.

## Phase 33 commits

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
fecada38  docs: activate Phase 33 documentation continuity
58444305  test: protect complete feature and continuity documentation
```

This continuity correction is its own commit so the protected Phase 32 release marker and Phase 33 maintenance distinction are reviewable separately.

## Verification boundary

The GitHub connector confirms the Phase 33 commits are on `main`, but the available push-run status surfaces have not yet returned a complete workflow result for the current head. Therefore no new formatter/analyzer/test/native pass is being claimed merely from the push.

The expected permanent automated path remains:

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

The current `tool/repository_audit.dart` exact Phase 32 continuity contract is satisfied again because the active file preserves `**Current phase:** Phase 32` while identifying Phase 33 separately as the maintenance stream.

Native platform builds remain a separate workflow/evidence class.

## Stable release boundary

Documentation/tooling maintenance does not alter the 13 manual release checks.

The stable qualification boundary remains 0/13 until genuine representative checks are completed and recorded. Documentation expansion, commit count, unit/widget tests, or hosted compilation cannot be used to fabricate those real-world results.
