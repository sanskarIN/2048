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

# Phase 33 — Deep documentation auditability extension

Date: **2026-08-19**

This extension continues the Phase 33 maintenance stream without changing the application version, product feature scope, or Phase 32 release/source-completion contract.

## Added tool-support decision matrix

`docs/setup/TOOL_SUPPORT_MATRIX.md` adds a fast, repository-grounded compatibility reference for:

- Flutter and bundled Dart;
- Git;
- Android Studio and Android SDK;
- ADB, emulator/AVD, and Android licenses;
- JDK/Java;
- Gradle Wrapper;
- AGP and Kotlin Android plugin;
- Visual Studio and Windows SDK;
- Xcode and CocoaPods;
- Linux Clang/CMake/Ninja/pkg-config/GTK toolchain;
- VS Code;
- Web/PWA tooling;
- Flutter packages;
- CI pins.

It distinguishes vendor support, project compatibility, exact pins, minimums, EOL, deprecation, newer-but-unqualified tooling, and security-driven migrations. It records the current project baseline but intentionally does not pretend to be a permanently current vendor lifecycle database.

## Added documentation reading/notation guide

`docs/DOCUMENTATION_READING_GUIDE.md` explains how to read technical documentation before executing commands, including:

- inline code and fenced code blocks;
- shell prompts;
- commands/subcommands/arguments/options/flags;
- placeholders and angle brackets;
- square brackets and ellipses;
- files/directories and relative/absolute paths;
- repository root, `.`, `..`, `./`, `.\\`;
- `PATH` and environment variables;
- pipes, redirection, quoting, standard output/error, and exit codes;
- wildcards/globs;
- versions, version constraints, and caret constraints;
- YAML and JSON;
- generated/tracked/untracked/ignored files;
- source-of-truth, baseline, floor, pin, range, and lockfile terminology;
- build/artifact/target/host/debug/profile/release/CI concepts;
- release-candidate/fail-closed/deterministic/checksum/signing meanings;
- read-only versus mutating commands and safe command-copying checks.

## Added no-skip file coverage contract

`docs/FILE_COVERAGE_CONTRACT.md` turns the “do not skip any files” requirement into an explicit maintenance rule.

The authoritative tracked inventory remains:

```bash
git ls-files | sort
```

Every tracked path must be covered by exact-file, explicit file-family, generated/platform-template, or historical/archive responsibility. The contract defines top-level boundaries, root-file treatment, application/test/platform/docs/tool/asset/workflow families, new-file rules, rename/deletion rules, binary/generated handling, and the pre-merge audit procedure.

A static file count is intentionally not treated as authoritative because it becomes stale whenever a legitimate tracked path changes.

## Canonical navigation updated

`docs/setup/README.md` and `docs/README.md` now expose the new support matrix, notation guide, and file-coverage contract in the normal reading path.

The setup index explicitly routes unsupported/outdated-tool questions through the support matrix before the deeper lifecycle migration guide.

## Regression protection expanded

`test/documentation_completeness_test.dart` now requires and checks the new documentation.

The test protects:

- current Version 2.0.12 project/toolchain values in the support matrix;
- important version-check and post-upgrade verification commands;
- documentation notation/path/exit-code/version/source-of-truth explanations;
- the exact-file/family no-skip coverage model;
- setup-index and canonical-docs-index discoverability.

## Extension commits

```text
bcd9119f  docs: add tool support and upgrade decision matrix
d0f70e8c  docs: explain documentation notation and command syntax
abfa1ef6  docs: define no-skip tracked file coverage contract
0da3a16c  docs: expose support matrix from setup index
f094b892  docs: integrate deep references into canonical index
25938e8c  test: protect deep documentation coverage contracts
```

This continuity update is committed separately so the documentation changes, index changes, regression protection, and maintenance record remain individually reviewable.

## Extension verification boundary

These extension changes are being submitted through the repository's protected-branch pull-request path. Direct writes to `main` were rejected by branch protection and were not bypassed.

No formatter, analyzer, Flutter test, native build, physical-device result, assistive-technology result, store result, or manual release qualification is claimed here unless a corresponding CI/observed evidence surface reports it.

# Phase 33 — Workflow security and repository-writer hardening

Date: **2026-08-20**

This maintenance extension strengthens GitHub Actions execution safety without changing Version `2.0.12+2012`, gameplay behavior, the completed product scope, or any manual qualification record.

## Findings corrected

The live workflow/test audit found three concrete maintenance gaps:

1. `.github/workflows/bootstrap-platforms.yml` had no finite job timeout.
2. The branding and platform bootstrap workflows can commit generated files to `main` but did not serialize overlapping writer runs with workflow concurrency cancellation.
3. `test/workflow_security_test.dart` still assumed four Platform Builds checkout steps even though the Web/PWA matrix expansion increased the read-only checkout count to five.

The stale checkout-count assertion was changed to count actual pinned checkout steps and require a matching `persist-credentials: false` for every read-only checkout, so future matrix expansion is protected without another hard-coded count migration.

## New executable workflow-security contract

`tool/workflow_security_audit.dart` now audits every maintained `.github/workflows/*.yml` / `.yaml` file and fails closed for:

- mutable remote Action references instead of full immutable commit SHAs;
- `pull_request_target`;
- blanket `write-all` permissions;
- missing explicit top-level content permissions;
- jobs without `timeout-minutes`;
- persisted checkout credentials in read-only workflows;
- unapproved `contents: write` workflows;
- approved repository writers that lose concurrency cancellation, bot-loop protection, or their explicit normal non-force main push;
- deletion of an approved repository-writing workflow;
- removal of the workflow-security audit from permanent CI.

Permanent CI now runs:

```bash
dart run tool/workflow_security_audit.dart --json
```

The maintainer verification sequence in `tool/README.md` includes the same audit.

## Regression coverage

`test/workflow_security_audit_cli_test.dart` provides process-level fail-closed fixtures for the new audit, including mutable Action refs, missing timeouts, credential persistence, missing writer concurrency, privileged triggers, CI wiring removal, and unknown CLI arguments.

`test/workflow_security_test.dart` also now protects dynamic read-only checkout credential counts and all approved writer concurrency/loop/timeout/non-force-push controls.

## Workflow documentation corrected

`docs/WORKFLOW_SECURITY.md` was refreshed from the stale Version 1.5 wording to the current Version 2.0.12 contract. It documents the executable audit, exact writer allowlist, job timeout policy, immutable Action pins, credential rules, current hosted toolchain boundary, and the current repository-protection uncertainty tracked by issue #12.

## Maintenance commits before this continuity entry

```text
43635e51  ci: bound platform bootstrap execution
11908f5a  ci: serialize branding generator writes
8e319044  tool: add workflow security audit
5c1b162a  test: cover workflow security audit
82ae13f4  test: harden workflow credential and writer guards
28cde52c  ci: enforce workflow security audit
3b98447c  docs: refresh workflow security contract
7d3d2298  docs: integrate workflow security maintainer tool
```

The work is submitted through pull request #27 (`ci: harden workflow security and writer safety`). This record does not claim CI success merely because the branch or pull request exists; formatter/analyzer/test/audit/build results are accepted only from an observed workflow result for the exact commit.

## Release boundary preserved

The stable qualification boundary remains 0/13. No physical-device, assistive-technology, installed-PWA, external-handler, native-branding, signing/provisioning, store, or other manual evidence was fabricated or advanced by this automation maintenance.
