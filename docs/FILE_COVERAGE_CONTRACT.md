# No-Skip Tracked File Coverage Contract

This document defines what **“do not skip any files”** means for 2048 Nova documentation and maintenance.

The repository already contains [`REPOSITORY_FILE_ATLAS.md`](REPOSITORY_FILE_ATLAS.md), which explains the role of the repository's source, platform, test, tool, asset, workflow, and documentation trees. This contract adds an auditable rule so future files cannot silently fall outside that map.

## 1. Authoritative file inventory

The authoritative list of files tracked by Git is generated from the repository itself:

```bash
git ls-files
```

Sorted form:

```bash
git ls-files | sort
```

PowerShell:

```powershell
git ls-files | Sort-Object
```

This is deliberately preferred over a permanently hard-coded count. A static count becomes stale as soon as a legitimate file is added, renamed, or removed.

## 2. What `git ls-files` means

`git ls-files` asks Git to print paths known to the current work tree/index.

It is the correct starting point for a **tracked-file** audit because it includes tracked source/configuration/documentation files regardless of whether they are currently modified.

It does not mean “every byte anywhere on the computer.” In particular, it does not include ordinary ignored build output or unrelated files outside the repository.

## 3. Coverage model

Every tracked path must be covered in at least one of these ways:

### A. Exact-file coverage

A document names a specific file and explains its responsibility.

Examples:

- `pubspec.yaml` — Flutter package metadata, SDK constraints, dependencies, assets;
- `pubspec.lock` — resolved package dependency graph;
- `lib/main.dart` — Flutter application entry point;
- `android/settings.gradle.kts` — Android plugin resolution/pins;
- `android/gradle/wrapper/gradle-wrapper.properties` — pinned Gradle distribution;
- `web/manifest.json` — PWA/application manifest metadata.

### B. Explicit file-family coverage

A document defines the purpose of a complete file family whose members are generated/platform variants with the same responsibility.

Examples:

- Android launcher icon density variants under `android/app/src/main/res/mipmap-*`;
- Apple app-icon size variants under `ios/Runner/Assets.xcassets/` and `macos/Runner/Assets.xcassets/`;
- generated Flutter plugin registrants under platform `flutter/` directories;
- historical `docs/PHASE_*` verification records;
- tests under `test/` whose filenames identify the behavior/contract being tested.

A family rule must state its prefix/pattern and purpose; saying only “other files” is not sufficient.

### C. Generated/platform-template coverage

A tracked generated/template file may be documented as a generated family rather than pretending it is handwritten business logic.

The documentation must still explain:

- which tool/platform owns it;
- why it is tracked;
- when regeneration is appropriate;
- why blind deletion/manual editing can be risky.

### D. Historical/archive coverage

Historical records and continuity archives may be covered as an archive family when their purpose is preservation rather than current runtime behavior.

They must not be treated as the current source of truth merely because they are tracked.

## 4. Top-level coverage boundaries

The current repository file surface is intentionally divided into the following maintained areas:

| Path/family | Documentation responsibility |
| --- | --- |
| root files | package metadata, public docs, policies, configuration, continuity |
| `.github/` | issue/PR templates, ownership, dependency automation, CI workflows |
| `assets/` | source branding/static assets |
| `lib/` | application/runtime Dart source |
| `test/` | automated regression and contract tests |
| `tool/` | repository-owned maintenance/release/audit CLIs |
| `android/` | Android runner/build/resources/toolchain configuration |
| `ios/` | iOS runner/Xcode/resources/configuration |
| `web/` | Web/PWA shell, manifest, icons |
| `windows/` | Windows runner/native build/resource files |
| `macos/` | macOS runner/Xcode/resources/configuration |
| `linux/` | Linux runner/native CMake/GTK integration files |
| `docs/` | current and historical project documentation |

If a future commit introduces a new top-level family, this coverage contract and the repository atlas must be reviewed in the same change.

## 5. Root files must not disappear into a family bucket

Root files have high repository-wide significance and should normally be explained individually in [`REPOSITORY_FILE_ATLAS.md`](REPOSITORY_FILE_ATLAS.md).

Examples include:

```text
.editorconfig
.gitattributes
.gitignore
.metadata
analysis_options.yaml
pubspec.yaml
pubspec.lock
README.md
CHANGELOG.md
ROADMAP.md
SECURITY.md
SUPPORT.md
CONTRIBUTING.md
CODE_OF_CONDUCT.md
AUTHORS.md
LICENSE
what_changed.md
```

Archive root files may be covered by an explicit archive-family rule.

## 6. Application source coverage

Every file under `lib/` belongs to an intentional application layer:

```text
lib/main.dart
lib/app/
lib/core/
lib/data/
lib/domain/
lib/features/
lib/shared/
```

The atlas and architecture documentation must explain both the layer and the important concrete files inside it.

A new `lib/` file that introduces a feature, domain model, persistence mechanism, shared utility, or architectural responsibility requires documentation review.

## 7. Test coverage documentation

The literal test inventory is always available with:

```bash
git ls-files 'test/**' | sort
```

Test filenames are part of the documentation surface because they communicate the contract being protected.

Examples:

- `game_engine_test.dart` protects movement/merge/spawn behavior;
- `repository_integrity_test.dart` protects repository invariants;
- `documentation_completeness_test.dart` protects documentation requirements;
- `workflow_security_test.dart` protects workflow/security invariants;
- `web_pwa_metadata_test.dart` protects PWA metadata;
- `android_signing_test.dart` protects Android signing configuration expectations.

When adding a new test family, its purpose should be discoverable from the name and related behavior documentation.

## 8. Platform file coverage

Platform runners contain many vendor/template-specific files. No-skip documentation does not require pretending every icon size or generated registration file contains unique business behavior.

Instead, the atlas must cover each explicit family.

### Android families

```text
android/app/build.gradle.kts
android/app/src/**/AndroidManifest.xml
android/app/src/main/kotlin/**
android/app/src/main/res/drawable*/**
android/app/src/main/res/mipmap-*/**
android/app/src/main/res/values*/**
android/build.gradle.kts
android/gradle.properties
android/gradle/wrapper/**
android/key.properties.example
android/settings.gradle.kts
```

### iOS families

```text
ios/Flutter/**
ios/Runner.xcodeproj/**
ios/Runner.xcworkspace/**
ios/Runner/Assets.xcassets/**
ios/Runner/Base.lproj/**
ios/Runner/*.swift
ios/Runner/*.plist
ios/Runner/*.h
ios/RunnerTests/**
```

### macOS families

```text
macos/Flutter/**
macos/Runner.xcodeproj/**
macos/Runner.xcworkspace/**
macos/Runner/Assets.xcassets/**
macos/Runner/Base.lproj/**
macos/Runner/Configs/**
macos/Runner/*.swift
macos/Runner/*.plist
macos/Runner/*.entitlements
macos/RunnerTests/**
```

### Windows families

```text
windows/CMakeLists.txt
windows/flutter/**
windows/runner/**
```

### Linux families

```text
linux/CMakeLists.txt
linux/flutter/**
linux/runner/**
```

### Web families

```text
web/index.html
web/manifest.json
web/favicon.*
web/icons/**
```

These patterns are documentation categories, not permission to ignore changes inside them. A semantically important platform change still requires the relevant platform/build docs and tests to be updated.

## 9. Documentation coverage

List every tracked documentation file with:

```bash
git ls-files 'docs/**' | sort
```

The documentation index [`docs/README.md`](README.md) is the navigation source for current documentation families.

Historical phase records are preserved for traceability. They are not silently rewritten to make old evidence appear current.

## 10. GitHub workflow coverage

List workflow files:

```bash
git ls-files '.github/workflows/**' | sort
```

Every workflow should have a documented purpose in CI/security documentation and should remain subject to repository security tests/permissions rules.

See [`CI_CD.md`](CI_CD.md) and [`WORKFLOW_SECURITY.md`](WORKFLOW_SECURITY.md).

## 11. Tool coverage

List repository-owned maintenance tools:

```bash
git ls-files 'tool/**' | sort
```

Each executable Dart tool must be described in [`../tool/README.md`](../tool/README.md) and its relevant release/testing documentation.

Repository-owned tools are not external magic: their source is tracked and reviewable.

## 12. Asset coverage

List assets:

```bash
git ls-files 'assets/**' | sort
```

The canonical branding asset family is documented by [`BRANDING.md`](BRANDING.md). Native icon derivatives are covered by the corresponding platform asset families.

## 13. Detecting untracked local files

No-skip **tracked-file** documentation and local workspace cleanliness are separate concerns.

Check local workspace state with:

```bash
git status --short
```

An untracked local file may be:

- a legitimate new source file not yet added;
- a generated build file that should remain ignored;
- a local secret/configuration file that must not be committed;
- temporary editor/output data.

Do not automatically add every untracked file to Git.

## 14. Detecting ignored files

Git can explain ignore behavior with commands such as:

```bash
git check-ignore -v <path>
```

Replace `<path>` with the real path.

This reports the ignore rule responsible for the match. It is useful when a required source/configuration file is unexpectedly absent from `git status`.

## 15. Rename and deletion rule

If a tracked file is renamed or removed intentionally:

1. update code/configuration references;
2. update documentation links and file responsibilities;
3. update tests/audits that require the old path;
4. verify local Markdown links;
5. ensure no release/build procedure still names the removed path.

A deletion is not complete merely because Git accepts it.

## 16. New-file rule

For each new tracked file, ask:

- Which existing coverage family owns it?
- Does the atlas already explain that family precisely enough?
- Does the file introduce a new feature/architecture/toolchain/release responsibility?
- Does the docs index need a new link?
- Do tests/audits need to require or validate it?
- Does privacy/security/accessibility/build behavior change?

If no existing family fits, update this contract and the atlas before merging.

## 17. Why a static file-count badge is not authoritative

A statement such as “the repository has 250 files” is immediately wrong after file 251 is added.

The reproducible command:

```bash
git ls-files | sort
```

is stronger evidence because it derives the current list from the checkout being audited.

A count can still be produced for convenience:

### Bash/macOS/Linux

```bash
git ls-files | wc -l
```

### PowerShell

```powershell
(git ls-files).Count
```

The number is an observation, not a permanent project invariant.

## 18. Generated native files are still reviewable

Files such as generated plugin registrants may be machine-produced, but when tracked they can affect native integration and should remain reviewable.

If Flutter regeneration changes them:

- inspect the diff;
- understand which dependency/toolchain change caused it;
- keep only changes consistent with the intended migration;
- rebuild the affected target.

## 19. Binary assets

Git tracks binary images/icons even though ordinary text diff cannot explain pixels line-by-line.

For binary files, no-skip coverage means documenting:

- purpose;
- source/derivative relationship;
- target platform/size family;
- regeneration/branding process where applicable.

See [`BRANDING.md`](BRANDING.md).

## 20. Historical files

Historical verification and continuity files answer “what was recorded at that time?” They must be preserved accurately.

Current behavior/status belongs in current source, tests, active continuity, current release documents, and current qualification data.

Do not rewrite a historical report to claim newer results it never observed.

## 21. Documentation-completeness regression protection

`test/documentation_completeness_test.dart` protects required documentation files and key navigation/lifecycle contracts.

This phase extends that test so the new support matrix, documentation-reading guide, and file-coverage contract remain required and discoverable.

The test is not a replacement for human review; it makes accidental deletion/unlinking harder.

## 22. Audit procedure before a documentation-completeness change merges

Run from repository root:

```bash
git status --short
git ls-files | sort
git ls-files 'docs/**' | sort
git ls-files 'test/**' | sort
git ls-files 'tool/**' | sort
dart format --output=none --set-exit-if-changed lib test tool
flutter analyze
flutter test --coverage
dart run tool/repository_audit.dart --json
dart run tool/source_completion_audit.dart --json
```

Then review the changed-file diff and any platform/build documents affected by the change.

## 23. Meaning of “complete” in this contract

**Complete documentation does not mean repeating the same sentence for every generated icon size.** It means every tracked path has an explicit, reviewable responsibility through exact-file or precise family coverage, and semantically important files are described at the appropriate depth.

That approach gives both:

- literal no-skip inventory via Git;
- readable technical explanation via the atlas and specialized manuals.

## 24. Related documents

- [`REPOSITORY_FILE_ATLAS.md`](REPOSITORY_FILE_ATLAS.md) — detailed repository map.
- [`DOCUMENTATION_READING_GUIDE.md`](DOCUMENTATION_READING_GUIDE.md) — notation/path/command syntax meanings.
- [`GLOSSARY.md`](GLOSSARY.md) — technical vocabulary.
- [`COMMAND_REFERENCE.md`](COMMAND_REFERENCE.md) — command and flag meanings.
- [`ARCHITECTURE.md`](ARCHITECTURE.md) — source-layer responsibilities.
- [`TESTING.md`](TESTING.md) — test strategy.
- [`CI_CD.md`](CI_CD.md) — workflow responsibilities.
- [`BRANDING.md`](BRANDING.md) — asset responsibilities.
