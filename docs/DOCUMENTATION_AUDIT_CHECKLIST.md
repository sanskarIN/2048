# Documentation Audit Checklist

Use this checklist when reviewing **all current 2048 Nova documentation** after a source, dependency, toolchain, platform, version, workflow, privacy, or release-policy change.

It is intentionally broader than a spell-check. Documentation is part of the repository contract and can cause real build/release mistakes when it is stale.

## 1. Start from the exact source commit

Record:

```bash
git status
git rev-parse HEAD
git branch --show-current
```

Do not audit documentation against an unspecified working copy.

## 2. Enumerate every tracked Markdown file

```bash
git ls-files '*.md'
```

All documentation under `docs/`:

```bash
git ls-files 'docs/**' | sort
```

PowerShell:

```powershell
git ls-files 'docs/**' | Sort-Object
```

Do not rely on the visible folder tree alone; `git ls-files` is the no-skip source of truth.

## 3. Enumerate setup docs

```bash
git ls-files 'docs/setup/**' | sort
```

Verify every setup/toolchain guide is indexed from `docs/setup/README.md` and/or the canonical `docs/README.md` where appropriate.

## 4. Enumerate platform build docs

```bash
git ls-files 'docs/build/**' | sort
```

Verify platform manuals do not contradict `docs/BUILDING_EXECUTABLES.md`.

## 5. Check current package version

```bash
git grep -n '^version:' pubspec.yaml
```

Current source:

```text
2.0.12+2012
```

Current marketing version:

```text
2.0.12
```

Do not update historical verification records merely because they mention an older version accurately.

## 6. Check current toolchain source files

Android pins:

```text
android/settings.gradle.kts
android/gradle/wrapper/gradle-wrapper.properties
android/app/build.gradle.kts
```

CI pin:

```text
.github/workflows/ci.yml
```

Before documenting a version, read the actual source file.

## 7. Current toolchain facts to reconcile

At the current Version 2.0.12 baseline:

```text
Dart >=3.9.0 <4.0.0
Flutter floor >=3.35.0
CI Flutter 3.47.0 stable
AGP 9.1.0
Kotlin Android 2.4.10
Gradle 9.7.0
Android JVM target 17
```

If source changes, update canonical setup/build/reference docs in the same maintenance change.

## 8. Search stale exact package metadata

Example old exact build identifier search:

```bash
git grep -n '1\.5\.0+15' -- '*.md'
```

Interpret every match:

- current release-facing doc → likely stale defect;
- historical audit/archive → may be correct historical evidence;
- test fixture explaining stale-data rejection → may be intentional.

Do not use a global replacement across history.

## 9. Search stale current-release claims

Search likely current markers:

```bash
git grep -n -E 'Current version|current version|Package version|Marketing version|release candidate' -- '*.md'
```

Check context and source of truth.

## 10. Verify current versus historical separation

Current docs should describe current behavior.

Historical docs should preserve what was actually verified at that old point in time.

Never rewrite an old test count, workflow run, commit SHA, or version simply to make history look current.

## 11. Check the canonical docs index

Open:

```text
docs/README.md
```

Verify it links to current:

- setup/toolchain docs;
- user/feature docs;
- architecture/development/testing docs;
- privacy/security/accessibility docs;
- build/platform docs;
- release/qualification docs;
- command/glossary/file references.

## 12. Check setup index

Open:

```text
docs/setup/README.md
```

Verify it routes users to all maintained installation/tool-specific guides.

## 13. Check build handbook

Open:

```text
docs/BUILDING_EXECUTABLES.md
```

Verify:

- current version/toolchain contract;
- all six platform targets;
- Android APK/AAB distinctions;
- iOS unsigned/signing distinction;
- desktop complete-bundle warnings;
- Web whole-directory deployment;
- checksum/signing distinctions;
- CI/manual evidence boundaries.

## 14. Check command documentation

Open:

```text
docs/COMMAND_REFERENCE.md
```

For every newly introduced command in current docs, verify:

- executable is named;
- subcommand/flag meaning is explained when non-obvious;
- destructive/global effects are warned about;
- shell differences are clear;
- placeholders are not presented as literal text.

## 15. Check glossary coverage

Open:

```text
docs/GLOSSARY.md
```

If a current guide introduces an important unfamiliar abbreviation/term, add it to the glossary unless the guide explains it sufficiently and it is too specialized for the shared glossary.

## 16. Check feature reference

Open:

```text
docs/FEATURE_REFERENCE.md
```

Verify every user-visible implemented feature still points to the correct source/canonical detailed guide.

## 17. Check architecture walkthrough

Open:

```text
docs/ARCHITECTURE_WALKTHROUGH.md
```

Verify major flows still match:

```text
main → app/controller/scope → feature UI → domain/data
```

and that new portable/trust-sensitive features are included.

## 18. Check repository file atlas

Open:

```text
docs/REPOSITORY_FILE_ATLAS.md
```

Verify new top-level/source/test/tool/platform directories are explained.

Do not hard-code a permanent file count; use `git ls-files`.

## 19. Check error reference

Open:

```text
docs/ERROR_REFERENCE.md
```

When a new toolchain/release gate is introduced, add the failure mode and safe diagnosis path.

Avoid troubleshooting advice that disables security/integrity/testing gates.

## 20. Check install commands against the actual supported toolchain

Examples:

- Flutter/Dart → Flutter stable project contract;
- Android → SDK/JDK/Gradle/AGP/Kotlin compatibility;
- Windows → Visual Studio C++ workload, not VS Code alone;
- Apple → Xcode/CocoaPods/macOS requirements;
- Linux → native compiler/CMake/Ninja/GTK packages.

Do not preserve a command just because it was correct several years ago.

## 21. Check upgrade/EOL guidance

Open:

```text
docs/setup/UPGRADING_AND_SUPPORT.md
```

Any new required tool should have:

- support-status detection method;
- supported upgrade mechanism;
- compatibility considerations;
- post-upgrade project verification;
- rollback/recovery guidance.

## 22. Check package/dependency docs

Compare:

```text
pubspec.yaml
pubspec.lock
docs/DEPENDENCIES.md
docs/SUPPLY_CHAIN.md
```

If dependencies changed, update rationale/security/platform implications and run cross-platform validation for native plugins.

## 23. Check privacy documentation

Any change involving:

- network access;
- analytics;
- cloud/account data;
- clipboard;
- files;
- camera/microphone;
- external URLs;
- device identifiers;
- persistent storage;

must be reflected accurately in privacy/security/platform docs.

Do not document permissions that are not actually required, and do not add permissions silently.

## 24. Check security documentation

Review:

```text
SECURITY.md
docs/WORKFLOW_SECURITY.md
docs/SUPPLY_CHAIN.md
```

when changing:

- dependency sources;
- GitHub Actions;
- signing;
- imports/portable formats;
- external links;
- release tooling;
- repository permissions.

## 25. Check accessibility documentation

Any UI/input/theme/animation/localization change should be checked against:

```text
docs/ACCESSIBILITY.md
docs/LOCALIZATION.md
```

Do not claim real screen-reader/device verification unless it happened in that environment.

## 26. Check user guide and FAQ

User-visible behavior changes should update:

```text
docs/USER_GUIDE.md
docs/FAQ.md
```

as appropriate.

A developer-only refactor that changes no behavior may not require user-guide changes.

## 27. Check game rules

For changes to movement/spawn/mode behavior:

```text
docs/GAME_ENGINE.md
docs/GAME_MODES.md
```

must match domain code/tests.

Do not let a UI tooltip become the only definition of a game rule.

## 28. Check portable formats

For challenge/backup/replay changes, audit:

```text
docs/CHALLENGE_CODES.md
docs/BACKUP_AND_RESTORE.md
docs/FILE_BACKUPS.md
docs/REPLAY_ARCHIVES.md
docs/PORTABLE_TIMESTAMPS.md
```

Verify schema/version/validation/size/trust/backward-compatibility statements.

## 29. Check build output paths

Compare actual/current Flutter output conventions and:

```text
docs/build/OUTPUT_PATHS.md
docs/BUILDING_EXECUTABLES.md
```

Do not promise a filename/path that the current build does not produce.

## 30. Check signing language

Documentation must distinguish:

```text
release-mode compilation
qualification signing fallback
production distribution signing
Apple provisioning
notarization
store submission/acceptance
```

These are not interchangeable.

## 31. Check checksum language

A SHA-256 checksum verifies content integrity/change detection.

It is not the same as a publisher digital signature.

Challenge Code checksums are also not authentication.

## 32. Check CI wording

Never write:

```text
CI passed
native build succeeded
```

unless a completed successful run for the relevant commit was actually observed.

A push/trigger is not a pass.

## 33. Check stable-release wording

Current strict stable qualification remains controlled by real manual evidence.

Documentation/source completion does not automatically complete physical-device/store/accessibility checks.

Preserve the fail-closed release boundary.

## 34. Check `what_changed.md`

Active continuity must preserve the frozen Version 2.0.12 release/source-completion contract and accurately record active maintenance.

The repository audit currently protects exact release-state markers, so update continuity and audit contracts together if a future release deliberately changes that phase/version model.

## 35. Check changelog

`CHANGELOG.md` should contain current release/maintenance changes.

Historical pre-2.0.12 details remain archived in:

```text
CHANGELOG_ARCHIVE_PRE_2_0_12.md
```

Do not duplicate entire historical archives back into the active changelog.

## 36. Check all local Markdown links automatically

Run:

```bash
dart run tool/repository_audit.dart --json
```

The audit scans repository-local Markdown destinations and fails on broken links.

Fix relative paths rather than disabling the check.

## 37. Check unclosed code fences

The repository audit can warn about unclosed Markdown code fences.

Also visually inspect large new Markdown files, especially after adding many command blocks.

## 38. Run documentation completeness tests

```bash
flutter test test/documentation_completeness_test.dart
```

Then run the full suite:

```bash
flutter test
```

## 39. Run source completion audit

```bash
dart run tool/source_completion_audit.dart --json
```

Ensure documentation work did not accidentally remove required completion/source/release assets.

## 40. Run formatting/analyzer even for documentation phases

Documentation phases can also add/update Dart regression tests or tools.

Run:

```bash
dart format --output=none --set-exit-if-changed lib test tool
flutter analyze
```

## 41. Search unfinished maintained Dart markers

Supplemental review:

```bash
git grep -n -E 'TODO|FIXME|UnimplementedError|NotImplemented|coming soon'
```

Interpret matches carefully; historical docs/test fixture strings can intentionally include these terms.

## 42. Verify shell portability

Commands in a general guide should identify when syntax differs:

- PowerShell path/executable forms;
- Bash/Zsh forms;
- `gradlew.bat` versus `./gradlew`;
- `where.exe` versus `which`/`type -a`.

## 43. Verify placeholders

Use obvious placeholders such as:

```text
<device-id>
<target-version>
```

and explicitly tell readers to replace them.

Never present a private real key/token as an example placeholder.

## 44. Verify destructive-command warnings

Commands such as hard resets, cache deletions, history rewrites, signing changes, global upgrades, and force pushes need clear consequences.

Prefer reversible/project-scoped commands when possible.

## 45. Verify no secret/private paths were added

Search staged changes:

```bash
git diff --staged
```

Look for:

- passwords;
- tokens;
- private keys;
- keystore content;
- App Store credentials;
- personal absolute paths that should be machine-local.

## 46. Verify licensing/source attribution

Do not paste long third-party documentation into this repository.

Explain commands/tool behavior in original project wording and link to official references where useful.

Respect licenses/copyright for third-party text/images.

## 47. Check cross-platform language

Avoid saying “run this on every OS” for commands that are host-specific.

Examples:

- iOS/macOS native build → Mac only;
- Windows native build → Windows only;
- Linux native build → Linux only.

Android/Web can be built on multiple supported hosts.

## 48. Check out-of-support guidance

Do not recommend keeping an unsupported OS/IDE/SDK permanently because it still builds today.

Do not recommend “latest everything” either.

The project standard is:

```text
supported + compatible + reproducible + validated
```

## 49. Check feature-complete boundary

Documentation maintenance must not reintroduce a hidden active feature backlog into Version 2.0.12.

Optional future ideas belong to a deliberately scoped future version/project planning process.

## 50. Final documentation audit sequence

```bash
git status
git ls-files 'docs/**' | sort
git diff --check
flutter pub get
dart format --output=none --set-exit-if-changed lib test tool
flutter analyze
flutter test --coverage
dart run tool/release_readiness.dart --json
dart run tool/release_qualification_status.dart --json --pending-only
dart run tool/repository_audit.dart --json
dart run tool/source_completion_audit.dart --json
dart run tool/solver_benchmark.dart 8
```

Build affected targets according to the maintenance scope.

## 51. PR review checklist

Before merging documentation changes:

```text
[ ] Every new current doc is indexed
[ ] No broken local Markdown links
[ ] Current versions match source
[ ] Historical evidence remains historical
[ ] Commands were checked for host/tool scope
[ ] Command meanings are explained or linked
[ ] Glossary covers important new terms
[ ] Upgrade/EOL guidance exists for required tools
[ ] No secret/private material
[ ] No unsupported claims of CI/manual/store success
[ ] Documentation completeness tests pass
[ ] Repository audit passes
[ ] Source completion audit passes
[ ] Affected application tests/builds pass
[ ] Pull request required checks are actually observed
```

## 52. Related documentation

- [`README.md`](README.md) — canonical docs index.
- [`REPOSITORY_FILE_ATLAS.md`](REPOSITORY_FILE_ATLAS.md) — no-skip repository audit.
- [`COMMAND_REFERENCE.md`](COMMAND_REFERENCE.md) — commands.
- [`GLOSSARY.md`](GLOSSARY.md) — terms.
- [`ERROR_REFERENCE.md`](ERROR_REFERENCE.md) — troubleshooting.
- [`setup/UPGRADING_AND_SUPPORT.md`](setup/UPGRADING_AND_SUPPORT.md) — lifecycle policy.
- [`TESTING.md`](TESTING.md) — evidence strategy.
