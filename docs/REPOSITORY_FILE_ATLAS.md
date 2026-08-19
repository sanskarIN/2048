# Repository File Atlas — No-Skip Guide

This document explains how the **2048 Nova** repository is organized, what each tracked file category is responsible for, which files are source-of-truth, which files are historical evidence, and how to perform a literal **no-skip file audit**.

Checked against `main` on **2026-08-19**, Version **2.0.12+2012**.

## 1. The only reliable way to enumerate every tracked file

From the repository root:

```bash
git ls-files
```

Meaning:

- `git` — run Git;
- `ls-files` — list files known to Git's index.

This is more reliable than manually looking through the file explorer because it includes dotfiles and nested tracked files.

Count tracked files:

macOS/Linux:

```bash
git ls-files | wc -l
```

PowerShell:

```powershell
(git ls-files).Count
```

List paths in deterministic sorted order:

```bash
git ls-files | sort
```

PowerShell:

```powershell
git ls-files | Sort-Object
```

Find untracked files not included in that inventory:

```bash
git status --short
```

A no-skip audit should examine both the tracked inventory and `git status` so an important new untracked file is not ignored.

## 2. Root files

### `.editorconfig`
Defines editor-neutral formatting basics such as line endings/indent behavior. Editors that support EditorConfig can apply these conventions consistently.

### `.gitattributes`
Controls Git path attributes such as text normalization. This helps avoid cross-platform line-ending problems.

### `.gitignore`
Defines files/directories Git should ignore, especially generated builds, machine-local configuration, caches, and private signing material. An ignored file is not automatically safe to delete; it simply is not meant to be committed.

### `.metadata`
Flutter project metadata used by Flutter tooling to understand project/platform migration state. Do not casually rewrite it by hand.

### `AUTHORS.md`
Authorship/credit information.

### `CHANGELOG.md`
Current release-facing change history. It must not claim unobserved verification results or stale current versions.

### `CHANGELOG_ARCHIVE_PRE_2_0_12.md`
Preserved historical changelog content from before the current Version 2.0.12 active changelog. It is history, not current release state.

### `CODE_OF_CONDUCT.md`
Community participation expectations.

### `CONTRIBUTING.md`
Contributor workflow, code quality, documentation, testing, security, privacy, and pull-request expectations.

### `LICENSE`
MIT License for the repository's own code/content under its terms.

### `README.md`
Public project landing page: product overview, features, setup, usage, builds, project identity, and documentation links.

### `ROADMAP.md`
Version-scope and maintenance/non-goal record. Current Version 2.0.12 source scope is feature-complete rather than an open-ended feature backlog.

### `SECURITY.md`
Security policy, reporting guidance, trust boundaries, signing/secret rules, and security-specific maintenance expectations.

### `SUPPORT.md`
Support/contact and issue-report guidance.

### `analysis_options.yaml`
Dart analyzer/lint configuration. `flutter analyze` consumes this policy.

### `pubspec.yaml`
Primary Flutter/Dart package source-of-truth: package name, version `2.0.12+2012`, SDK constraints, dependencies, assets, and Material configuration.

### `pubspec.lock`
Concrete resolved dependency versions. Review lockfile diffs during dependency/toolchain maintenance.

### `what_changed.md`
Active project continuity/development record.

### `what_changed_archive_phase_00_30.md`
Historical continuity record for Phases 0–30.

### `what_changed_archive_phase_31.md`
Historical continuity record for Phase 31.

## 3. `.github/` — GitHub collaboration and automation

### `.github/CODEOWNERS`
Defines review ownership/responsibility patterns for repository paths.

### `.github/FUNDING.yml`
GitHub funding/support configuration.

### `.github/ISSUE_TEMPLATE/`
Structured GitHub issue forms:

- `bug_report.yml` — bug reports;
- `documentation.yml` — documentation issues;
- `feature_request.yml` — feature proposals;
- `config.yml` — issue-template configuration/contact links.

### `.github/pull_request_template.md`
Default checklist/context template for pull requests.

### `.github/dependabot.yml`
Dependabot update configuration. It controls automated dependency-update proposal behavior; it does not mean updates are auto-approved.

### `.github/workflows/ci.yml`
Permanent quality workflow. It resolves dependencies, checks tracked metadata drift, verifies formatting, analyzes, tests with coverage, runs release/qualification/repository/source-completion tools, smoke-tests the solver benchmark, and builds Web release output.

### `.github/workflows/platform-builds.yml`
Native platform qualification build matrix for Android, Linux, Windows, macOS, and unsigned iOS outputs.

### `.github/workflows/dependency-review.yml`
Dependency-change review automation.

### `.github/workflows/format-code.yml`
Repository-owned Dart formatting automation.

### `.github/workflows/lock-dependencies.yml`
Workflow/action dependency integrity maintenance.

### `.github/workflows/bootstrap-branding.yml`
Branding generation/bootstrap workflow.

### `.github/workflows/bootstrap-platforms.yml`
Platform runner/bootstrap workflow used when platform scaffolding maintenance is required.

Never edit workflow permissions, third-party Action pins, or secret use casually. See `docs/WORKFLOW_SECURITY.md`.

## 4. `lib/` — application source

`lib/` is the primary Dart application source tree.

### `lib/main.dart`
Flutter entry point. It initializes Flutter/application state and launches the app.

### `lib/app/nova_app.dart`
Top-level application widget, theming/localization/navigation shell wiring.

### `lib/app/state/app_controller.dart`
Central application/session orchestration. It coordinates gameplay lifecycle, persistence, settings, ranking/trust boundaries, replays, challenge behavior, and related app state.

### `lib/app/state/app_scope.dart`
Provides application controller/state access to descendant widgets without placing core game rules into UI screens.

## 5. `lib/core/`
Cross-cutting application primitives.

### `lib/core/constants/`
Project constants/identity metadata. `project_info.dart` is a current marketing-version/project-information source of truth.

### `lib/core/localization/`
Localization framework and translations. The repository includes English/Hindi behavior and fallback logic; see `docs/LOCALIZATION.md`.

### `lib/core/theme/`
Color/theme/visual design definitions shared across screens/components.

## 6. `lib/data/`
Persistence/infrastructure layer.

### `lib/data/local_store.dart`
Local storage implementation. It owns serialization/persistence for settings, save state, statistics, replay/history records, migration/recovery behavior, and bounded local data responsibilities described in `docs/DATA_STORAGE.md`.

This file is a trust boundary: imported/portable data must not silently become trusted ranked state.

## 7. `lib/domain/` — deterministic game and portable formats

The domain directory contains the core logic that should remain as UI-independent and deterministic as practical.

### `autoplay_session.dart`
Defines isolated Auto Play session behavior and solver-driven move flow.

### `challenge_code.dart`
Challenge Code encoding/decoding, validation, deterministic challenge parameters, and integrity/checksum handling.

### `daily_record.dart`
Daily Challenge record representation/serialization and date-related record behavior.

### `expectimax_solver.dart`
Bounded Expectimax search implementation used by the stronger solver strategy.

### `game_backup.dart`
Portable current-game backup codec/validation representation.

### `game_engine.dart`
Core 2048 movement, merge, spawn, score, and terminal-state engine behavior.

### `game_state.dart`
Serializable/immutable-or-controlled game state model and state transitions/data representation.

### `game_types.dart`
Shared game enums/types/mode definitions used by domain and application layers.

### `hint_solver.dart`
Read-only heuristic hint evaluation path.

### `random_source.dart`
Deterministic pseudo-random source abstraction/state used to make seeded behavior reproducible.

### `replay_archive.dart`
Full replay archive representation/codec/validation.

### `replay_archive_contract.dart`
Shared limits/protocol constants for replay archives.

### `replay_timeline.dart`
Move replay timeline/state stepping behavior.

### `solver_benchmark.dart`
Reusable deterministic benchmark definitions/logic used by the CLI benchmark tool.

When changing domain files, corresponding domain tests and behavior documentation are required.

## 8. `lib/features/` — user-facing screens/features

The current feature folders are:

```text
about/
achievements/
backup/
challenge_codes/
daily_challenge/
game/
guide/
home/
modes/
replay/
settings/
solver_demo/
splash/
statistics/
support/
```

Their responsibilities are intentionally feature-oriented:

- `about/` — project/author/version/open-source/support information UI;
- `achievements/` — achievement presentation;
- `backup/` — backup/import/export UI;
- `challenge_codes/` — Challenge Code text/QR flows;
- `daily_challenge/` — Daily Challenge entry/history/presentation;
- `game/` — gameplay board, controls, overlays, session interaction;
- `guide/` — in-app how-to-play/help content;
- `home/` — main landing/navigation experience;
- `modes/` — mode-selection/configuration UI;
- `replay/` — replay archive/timeline playback UI;
- `settings/` — theme/language/accessibility/game preference UI;
- `solver_demo/` — isolated solver/Auto Play demonstration surface;
- `splash/` — startup branding/splash UI;
- `statistics/` — statistics/records presentation;
- `support/` — support/contact/donation/external-link UI.

A UI folder must not redefine game-engine rules that belong in `lib/domain/`.

## 9. `lib/shared/`
Reusable widgets/helpers that serve multiple features. Shared code should be genuinely cross-feature rather than a dumping ground for feature-specific behavior.

## 10. `test/` — automated regression suite

The test tree contains unit/widget/process/regression tests for the application and repository contracts.

Examples visible in the current tree include:

```text
android_distribution_workflow_test.dart
android_signing_test.dart
app_controller_test.dart
autoplay_session_test.dart
autoplay_strategy_test.dart
challenge_code_qr_localization_test.dart
challenge_code_qr_test.dart
challenge_code_screen_test.dart
challenge_code_test.dart
current_release_state_test.dart
daily_record_test.dart
daily_record_utc_test.dart
daily_replay_history_test.dart
expectimax_solver_test.dart
external_link_test.dart
...
```

The directory continues with tests for the remaining gameplay, persistence, replay, localization, UI, release-gate, repository-audit, platform, source-completion, PWA, and tool contracts.

To enumerate **every** current test without depending on this prose staying manually synchronized:

macOS/Linux:

```bash
git ls-files 'test/**' | sort
```

PowerShell:

```powershell
git ls-files 'test/**' | Sort-Object
```

Run the whole suite:

```bash
flutter test
```

Run with coverage:

```bash
flutter test --coverage
```

No test filename should be removed merely to make a failing build green; understand whether the behavior or the test contract is wrong.

## 11. `tool/` — repository-owned maintenance CLIs

### `tool/README.md`
Maintainer command index and verification sequence.

### `tool/branding-requirements.txt`
Python/tooling input requirements used for branding-generation support where applicable.

### `tool/record_release_qualification.dart`
Guarded writer for genuine manual qualification evidence. It must not be used to fabricate unobserved results.

### `tool/release_qualification_status.dart`
Read-only reporter for the canonical qualification manifest.

### `tool/release_readiness.dart`
Candidate/stable release gate logic. Strict stable mode intentionally fails closed when required manual evidence is incomplete.

### `tool/repository_audit.dart`
Repository integrity/local-document-link/current-contract audit.

### `tool/solver_benchmark.dart`
CLI entry point for deterministic solver benchmark smoke/performance evidence.

### `tool/source_completion_audit.dart`
Permanent Version 2.0.12 source-completion audit protecting final source/docs/non-goal/current-version contracts.

Every repository tool is invoked with `dart run tool/<name>.dart ...`; see `docs/COMMAND_REFERENCE.md`.

## 12. `assets/`
Committed application assets. The current Flutter manifest includes `assets/branding/`.

Branding assets feed Flutter UI and generated/native platform branding. Do not replace only one platform icon while leaving source branding and other runners inconsistent; use the branding guide/workflow.

Exact inventory:

```bash
git ls-files 'assets/**'
```

## 13. `android/`
Native Android runner and Gradle project.

Important paths include:

```text
android/app/build.gradle.kts
android/settings.gradle.kts
android/gradle/wrapper/gradle-wrapper.properties
android/app/src/main/AndroidManifest.xml
android/app/src/main/kotlin/...
android/app/src/main/res/...
```

Responsibilities:

- Gradle/AGP/Kotlin configuration;
- package/application identity;
- Java/Kotlin compatibility;
- release-signing selection;
- Android manifest declarations;
- native launcher/resources/icons;
- Gradle Wrapper reproducibility.

Machine-local `android/local.properties` and private signing material are not public source-of-truth files.

## 14. `ios/`
Native iOS runner/Xcode project and assets/settings.

It contains Xcode project/workspace configuration, `Runner` application files, Info.plist/entitlements where applicable, asset catalogs, launch/branding resources, Flutter-generated integration configuration, and tests/support files from Flutter's runner structure.

Do not overwrite this directory from a fresh template without comparing project-specific identifiers, branding, entitlements, deployment settings, and Flutter migrations.

Exact tracked inventory:

```bash
git ls-files 'ios/**' | sort
```

## 15. `macos/`
Native macOS runner/Xcode project. It contains application bundle metadata, assets, entitlements/configuration, runner source, Flutter integration, and Xcode project/workspace files.

Build output under `build/macos/...` is generated and is not a substitute for these tracked runner sources.

## 16. `windows/`
Native Windows runner/CMake project.

Important categories include:

- CMake build definitions;
- runner C++ source/header files;
- Windows resource/version metadata (`Runner.rc`);
- application icon/resources;
- Flutter plugin/generated integration scaffolding.

The current Windows version fallback metadata is part of Version 2.0.12 consistency checks.

## 17. `linux/`
Native Linux runner/CMake project containing GTK/Flutter embedding/native runner source and build configuration.

The generated Linux release executable is not committed; it is produced under `build/linux/...`.

## 18. `web/`
Web/PWA shell and install metadata.

Important files include:

- `index.html` — Flutter Web bootstrap/document shell and base-href behavior;
- `manifest.json` — PWA name/theme/display/icon/install metadata;
- icons/branding assets;
- favicon/other web assets where present.

The generated `build/web/` directory is deployment output, not the source Web shell.

## 19. `docs/`
Canonical documentation tree. Major categories include:

- player behavior and features;
- architecture/data/game engine;
- accessibility/localization/privacy/security;
- development/testing/troubleshooting;
- dependency/supply-chain/workflow security;
- platforms/build artifacts/signing/checksums;
- CI/release qualification/evidence;
- historical phase verification;
- source-completion/maintenance policy;
- setup/tool installation/upgrade guides;
- command reference/glossary/file atlas.

Use `docs/README.md` as the documentation index.

## 20. `docs/build/`
Dedicated platform build/distribution handbooks. Current files include guides for Android, iOS, Windows, Linux, macOS, Web, host prerequisites, output paths, CI parity, signing/distribution, packaging/checksums, supported artifacts, release build checklist, troubleshooting, and final executable audit.

Exact current inventory:

```bash
git ls-files 'docs/build/**' | sort
```

## 21. `docs/setup/`
Beginner-to-maintainer environment setup documentation:

```text
PREREQUISITES.md
WINDOWS.md
MACOS.md
LINUX.md
ANDROID.md
UPGRADING_AND_SUPPORT.md
```

The directory index is `docs/setup/README.md` after it is added in this documentation phase.

## 22. Historical documentation is intentionally not rewritten

Files named as historical phases/final audits for older releases preserve the evidence they actually recorded. A current documentation cleanup must not edit an old run ID/test count/version merely to make history look current.

Current state belongs in current release docs, `CHANGELOG.md`, and `what_changed.md`.

## 23. Generated directories and machine-local files

Common generated/local paths include things such as:

```text
.dart_tool/
build/
coverage/
android/local.properties
android/key.properties
private keystores
IDE caches/settings not intentionally committed
```

Exact ignored behavior is governed by `.gitignore` plus nested platform ignore files.

Do not document a generated binary as if it is source-controlled simply because it exists locally after a build.

## 24. Source-of-truth hierarchy

When two things disagree, use this priority:

1. current source/configuration and tests;
2. canonical current documentation;
3. active continuity/changelog;
4. historical documentation as evidence of earlier states.

Examples:

- package/build version → `pubspec.yaml`;
- marketing version → `lib/core/constants/project_info.dart`;
- Android AGP/Kotlin → `android/settings.gradle.kts`;
- Gradle → `android/gradle/wrapper/gradle-wrapper.properties`;
- Android Java/Kotlin target/signing → `android/app/build.gradle.kts`;
- game rules → `lib/domain/game_engine.dart` + domain tests;
- persistence → `lib/data/local_store.dart` + storage docs/tests;
- release qualification → `docs/release_qualification.json` + release tools;
- CI behavior → `.github/workflows/`.

Documentation that conflicts with current source is a documentation bug and should be corrected.

## 25. Literal no-skip audit procedure

### A. Save the exact inventory

```bash
git ls-files > tracked-files.txt
```

Do not commit this temporary file unless there is a deliberate reason.

### B. Check status

```bash
git status --short
```

### C. Inspect top-level categories

```bash
git ls-files '.github/**'
git ls-files 'lib/**'
git ls-files 'test/**'
git ls-files 'tool/**'
git ls-files 'docs/**'
git ls-files 'assets/**'
git ls-files 'android/**'
git ls-files 'ios/**'
git ls-files 'web/**'
git ls-files 'windows/**'
git ls-files 'macos/**'
git ls-files 'linux/**'
```

### D. Search unfinished implementation markers

Repository source-completion tooling already protects maintained Dart against unresolved product `TODO`/`FIXME` line comments. A supplemental human review can use:

```bash
git grep -n -E 'TODO|FIXME|UnimplementedError|NotImplemented|coming soon'
```

Interpret matches; documentation/history/test fixtures can intentionally contain those words.

### E. Validate links/contracts

```bash
dart run tool/repository_audit.dart --json
dart run tool/source_completion_audit.dart --json
```

### F. Validate code

```bash
dart format --output=none --set-exit-if-changed lib test tool
flutter analyze
flutter test --coverage
```

### G. Validate builds

Run the maintained Web/native target builds on their supported hosts or through the platform workflow.

### H. Do not fabricate external checks

Physical-device, assistive-technology, external-handler, signing/provisioning, installed-PWA, and store evidence must come from those real environments.

## 26. Why this atlas avoids hard-coding a permanent file count

The repository intentionally evolves. A hard-coded statement such as “there are exactly N files forever” becomes stale on the next legitimate commit. The canonical no-skip inventory is therefore executable:

```bash
git ls-files
```

This atlas explains responsibilities, while Git supplies the complete current path set.

## 27. Related documentation

- [`README.md`](README.md) — documentation index.
- [`ARCHITECTURE.md`](ARCHITECTURE.md) — architectural relationships.
- [`DEVELOPMENT.md`](DEVELOPMENT.md) — development workflow.
- [`TESTING.md`](TESTING.md) — automated/manual verification.
- [`REPOSITORY_AUDIT.md`](REPOSITORY_AUDIT.md) — repository audit contract.
- [`SOURCE_COMPLETION_AUDIT.md`](SOURCE_COMPLETION_AUDIT.md) — source-completion contract.
- [`COMMAND_REFERENCE.md`](COMMAND_REFERENCE.md) — command meanings.
- [`GLOSSARY.md`](GLOSSARY.md) — terminology.