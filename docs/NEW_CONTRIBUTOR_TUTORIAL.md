# New Contributor Tutorial — From Zero to a Safe 2048 Nova Change

This tutorial takes a new contributor from a fresh computer/repository clone to understanding the project, running checks, making one safe change, building the relevant target, committing it, and submitting it through the repository's protected-branch workflow.

It assumes no prior knowledge of this repository.

## 1. Know what you are working on

Project:

```text
2048 Nova
```

Current package/build version:

```text
2.0.12+2012
```

Current source scope:

```text
feature-complete Version 2.0.12 line
```

That means ordinary maintenance should fix defects, documentation, compatibility, security, tests, or required platform/toolchain changes. Do not silently add a new product-feature backlog to this completed release line.

## 2. Choose your host guide

Read the setup guide for your computer:

- Windows → [`setup/WINDOWS.md`](setup/WINDOWS.md)
- macOS → [`setup/MACOS.md`](setup/MACOS.md)
- Linux → [`setup/LINUX.md`](setup/LINUX.md)

Then read:

- [`setup/PREREQUISITES.md`](setup/PREREQUISITES.md)
- [`setup/FLUTTER_AND_DART.md`](setup/FLUTTER_AND_DART.md)
- [`setup/GIT.md`](setup/GIT.md)

If you use VS Code:

- [`setup/VS_CODE.md`](setup/VS_CODE.md)

If you maintain Android:

- [`setup/ANDROID_STUDIO.md`](setup/ANDROID_STUDIO.md)
- [`setup/ANDROID.md`](setup/ANDROID.md)

## 3. Verify tools before cloning

```bash
git --version
flutter --version
dart --version
flutter doctor -v
```

Understand these commands:

- `git --version` — proves Git is installed/callable;
- `flutter --version` — identifies Flutter and its bundled Dart toolchain;
- `dart --version` — prints the active Dart SDK;
- `flutter doctor -v` — checks platform dependencies and prints detailed paths/versions.

If one fails, fix the environment before changing source.

## 4. Clone the repository

```bash
git clone https://github.com/sanskarIN/2048.git
cd 2048
```

What happens:

- Git downloads project source/history;
- a local `2048` directory is created;
- the repository's default branch is checked out;
- remote `origin` points to GitHub.

Check:

```bash
git status
git remote -v
```

## 5. Configure Git identity when needed

Repository-local values:

```bash
git config user.name "Sanskar"
git config user.email "sanskarin@outlook.in"
```

Check:

```bash
git config user.name
git config user.email
```

Omitting `--global` avoids unintentionally changing every other Git repository on the computer.

## 6. Understand protected `main`

The repository now requires changes to `main` through a pull request.

That means normal contribution flow is:

```text
main
  ↓ create branch
feature/docs/fix branch
  ↓ commits
push branch
  ↓
pull request
  ↓ required checks/review
merge to main
```

Do not try to bypass the protection with force-pushes.

## 7. Update local `main`

```bash
git switch main
git status
git pull --ff-only
```

- `git switch main` selects the main branch;
- `git status` confirms whether local changes exist;
- `git pull --ff-only` updates only when Git can fast-forward without inventing a merge commit.

If you already have uncommitted work, preserve/resolution it before pulling.

## 8. Create a branch

Example documentation branch:

```bash
git switch -c docs/improve-example
```

Example bug-fix branch:

```bash
git switch -c fix/example-bug
```

A branch name should communicate purpose.

## 9. Resolve dependencies

```bash
flutter pub get
```

This reads `pubspec.yaml`, uses the package constraints/lockfile, downloads missing dependencies, and prepares package metadata.

## 10. Run the baseline before editing

```bash
dart format --output=none --set-exit-if-changed lib test tool
flutter analyze
flutter test
```

Why run before editing?

If the baseline already fails, you can distinguish an existing/environment problem from the change you are about to make.

## 11. Run repository-specific audits

```bash
dart run tool/release_readiness.dart --json
dart run tool/repository_audit.dart --json
dart run tool/source_completion_audit.dart --json
```

The strict stable gate is different:

```bash
dart run tool/release_readiness.dart --stable --json
```

It can intentionally fail while manual release qualification remains incomplete. Do not “fix” this by inventing evidence.

## 12. Explore the repository

List every tracked file:

```bash
git ls-files
```

Read [`REPOSITORY_FILE_ATLAS.md`](REPOSITORY_FILE_ATLAS.md).

Important areas:

```text
lib/         application source
test/        automated tests
tool/        repository CLI audits/tools
docs/        documentation
assets/      app assets
android/     Android runner/build config
ios/         iOS runner
web/         Web/PWA source shell
windows/     Windows runner
macos/       macOS runner
linux/       Linux runner
.github/     GitHub automation/governance
```

## 13. Understand the architecture before editing behavior

Read:

- [`ARCHITECTURE_WALKTHROUGH.md`](ARCHITECTURE_WALKTHROUGH.md)
- [`ARCHITECTURE.md`](ARCHITECTURE.md)
- [`FEATURE_REFERENCE.md`](FEATURE_REFERENCE.md)

Core rule:

```text
UI should not silently redefine domain/game/trust rules.
```

If a move rule is wrong, fix/test the engine/controller layer that owns it—not only the visible widget.

## 14. Find code for a feature

Example search:

```bash
git grep -n "challenge" lib test docs
```

`git grep` searches tracked files. `-n` prints line numbers.

Use a feature trace:

```text
feature screen
  ↓
AppController
  ↓
domain codec/engine/solver
  ↓
LocalStore if persistence is involved
  ↓
tests
  ↓
documentation
```

## 15. Make a documentation-only change safely

Suppose you correct a command explanation.

Edit the relevant Markdown file, then:

```bash
git diff -- docs/path.md
```

Run the repository audit because it checks local Markdown links:

```bash
dart run tool/repository_audit.dart --json
```

For documentation contracts, also run tests because documentation-completeness tests are part of the suite:

```bash
flutter test
```

## 16. Make a Dart bug fix safely

Preferred workflow:

1. reproduce the defect;
2. add a failing regression test;
3. fix the owning source layer;
4. run the focused test;
5. run the whole suite;
6. update documentation if user-observable behavior changes.

Example focused test command:

```bash
flutter test test/game_engine_test.dart
```

Use the real applicable test filename from the repository.

## 17. Format Dart after editing

```bash
dart format lib test tool
```

Then verify no formatting changes remain necessary:

```bash
dart format --output=none --set-exit-if-changed lib test tool
```

## 18. Run static analysis

```bash
flutter analyze
```

Fix reported source/type/lint problems rather than weakening analyzer rules to hide them.

## 19. Run tests

```bash
flutter test
```

Coverage when required:

```bash
flutter test --coverage
```

Passing tests are necessary automated evidence, but not proof of all real-device/platform behavior.

## 20. Run repository audits again

```bash
dart run tool/release_readiness.dart --json
dart run tool/repository_audit.dart --json
dart run tool/source_completion_audit.dart --json
dart run tool/solver_benchmark.dart 8
```

The solver benchmark is especially relevant after solver/engine/performance changes.

## 21. Build the affected target

If you changed only documentation, a full native matrix may not always be needed locally, but CI/test contracts still apply.

For application/dependency/platform changes, build relevant targets.

Android:

```bash
flutter build apk --release
flutter build appbundle --release
```

Web:

```bash
flutter build web --release
```

Windows:

```powershell
flutter build windows --release
```

macOS:

```bash
flutter build macos --release
```

Linux:

```bash
flutter build linux --release
```

iOS unsigned qualification:

```bash
flutter build ios --release --no-codesign
```

Use native supported hosts.

## 22. Review working changes

```bash
git status
git diff
```

Ask:

- Are only intended files changed?
- Did a tool rewrite a lockfile unexpectedly?
- Did any generated/build output appear?
- Are there secrets/private paths?
- Are old unrelated edits mixed in?

## 23. Stage one coherent change

Example:

```bash
git add docs/NEW_CONTRIBUTOR_TUTORIAL.md
```

Then:

```bash
git diff --staged
```

This is the exact staged change that will become the commit.

## 24. Commit with a useful message

```bash
git commit -m "docs: add new contributor tutorial"
```

Good commit messages describe purpose.

Common repository prefixes:

```text
feat:
fix:
test:
docs:
ci:
style:
chore:
```

## 25. Make several meaningful commits rather than one huge commit

If a task includes independent pieces, separate them.

Example:

```text
docs: add Android Studio handbook
docs: add Visual Studio toolchain handbook
docs: add error diagnosis reference
test: protect setup documentation index
docs: update canonical docs index
```

Do not create empty/no-op commits simply to increase the number.

## 26. Re-run checks after the last commit group

Before push/PR:

```bash
dart format --output=none --set-exit-if-changed lib test tool
flutter analyze
flutter test --coverage
dart run tool/repository_audit.dart --json
dart run tool/source_completion_audit.dart --json
```

Run relevant builds too.

## 27. Push the branch

```bash
git push -u origin docs/improve-example
```

`-u` sets the upstream tracking branch.

A successful push means GitHub received commits. It does not prove CI passed.

## 28. Open the pull request

Open a pull request from your branch into `main`.

A useful PR explains:

- what changed;
- why;
- tests/checks actually run;
- affected platforms;
- documentation updated;
- remaining external/manual qualification boundaries.

Do not claim checks you did not observe.

## 29. Watch required checks

GitHub Actions can run formatting, analysis, tests, repository/source audits, Web build, and native builds according to workflow trigger/scope.

Wait for actual completed results before saying the PR is green.

A workflow that has not started/finished is not a pass.

## 30. Respond to review without destroying history

If changes are requested:

- edit the same branch;
- add focused commits;
- push them;
- rerun checks.

Avoid force-rewriting shared review history unless repository policy explicitly uses that workflow.

## 31. Merge only when policy permits

The protected branch is designed to make review/check requirements enforceable.

Use the repository's allowed merge method after required conditions pass.

Do not bypass protection because a change seems “only docs.”

## 32. Update your local main after merge

```bash
git switch main
git pull --ff-only
```

You can then delete the local feature branch when no longer needed:

```bash
git branch -d docs/improve-example
```

`-d` refuses deletion if Git believes commits are unmerged, which is safer than force deletion.

## 33. Never commit secrets

Do not commit:

- Android keystores;
- key/store passwords;
- private signing certificates/keys;
- App Store Connect private keys;
- tokens/passwords;
- private machine credential files.

Review:

```bash
git diff --staged
```

before every commit.

## 34. Android signing boundary

Public source can qualify Android release-mode compilation without carrying the private production key.

For actual store distribution, authorized release infrastructure supplies private signing configuration.

See [`build/SIGNING_AND_DISTRIBUTION.md`](build/SIGNING_AND_DISTRIBUTION.md).

## 35. Apple signing boundary

Unsigned iOS compilation can be tested with:

```bash
flutter build ios --release --no-codesign
```

A real IPA/store release needs legitimate Apple signing/provisioning.

Do not put these credentials into the public repository.

## 36. Manual qualification boundary

Some release checks must happen on actual environments:

- Android/iOS devices;
- assistive technologies;
- long sessions/performance;
- file/share/external handlers;
- installed PWA/browser lifecycle;
- native branding;
- signing/provisioning/store metadata.

The repository currently keeps strict stable promotion fail-closed until such evidence is recorded genuinely.

## 37. If a tool is unsupported

Do not upgrade every tool at once.

Read:

[`setup/UPGRADING_AND_SUPPORT.md`](setup/UPGRADING_AND_SUPPORT.md)

Create a maintenance branch, identify compatible replacements, make the smallest change, run full affected validation, and update CI/docs only after acceptance.

## 38. If you see an error you do not understand

Read:

[`ERROR_REFERENCE.md`](ERROR_REFERENCE.md)

Then collect:

```bash
flutter --version
dart --version
flutter doctor -v
git status
```

and the first root-cause error.

## 39. If you do not understand a command

Read:

[`COMMAND_REFERENCE.md`](COMMAND_REFERENCE.md)

Never paste a destructive command only because it appeared in a forum answer.

## 40. If you do not understand a technical word

Read:

[`GLOSSARY.md`](GLOSSARY.md)

The project documentation defines its major Git/Flutter/build/platform/security/gameplay terms.

## 41. If you are unsure which file owns behavior

Read:

- [`REPOSITORY_FILE_ATLAS.md`](REPOSITORY_FILE_ATLAS.md)
- [`ARCHITECTURE_WALKTHROUGH.md`](ARCHITECTURE_WALKTHROUGH.md)

Then trace UI → controller → domain/data → tests/docs.

## 42. A complete first-contribution command sequence

After the environment is installed:

```bash
git clone https://github.com/sanskarIN/2048.git
cd 2048
git config user.name "Sanskar"
git config user.email "sanskarin@outlook.in"
git switch main
git pull --ff-only
git switch -c docs/my-first-improvement
flutter pub get
dart format --output=none --set-exit-if-changed lib test tool
flutter analyze
flutter test
dart run tool/repository_audit.dart --json
dart run tool/source_completion_audit.dart --json
# edit files
git status
git diff
# run checks again
git add <intended-files>
git diff --staged
git commit -m "docs: improve contributor documentation"
git push -u origin docs/my-first-improvement
```

Then open a PR to protected `main` and observe its checks.

## 43. Contribution quality definition

A high-quality change is not only “the code compiles.” It is:

```text
correct behavior
+ regression protection
+ static quality
+ safe data/security boundaries
+ current documentation
+ compatible platform build evidence where affected
+ honest release/manual evidence claims
+ reviewable Git history
```

## 44. Related documentation

- [`DEVELOPMENT.md`](DEVELOPMENT.md) — development policy.
- [`TESTING.md`](TESTING.md) — test/evidence strategy.
- [`REPOSITORY_FILE_ATLAS.md`](REPOSITORY_FILE_ATLAS.md) — files/folders.
- [`ARCHITECTURE_WALKTHROUGH.md`](ARCHITECTURE_WALKTHROUGH.md) — code flow.
- [`ERROR_REFERENCE.md`](ERROR_REFERENCE.md) — failures.
- [`COMMAND_REFERENCE.md`](COMMAND_REFERENCE.md) — commands.
- [`BUILDING_EXECUTABLES.md`](BUILDING_EXECUTABLES.md) — artifacts.
- [`RELEASE_QUALIFICATION.md`](RELEASE_QUALIFICATION.md) — evidence/stable release policy.
- [`../CONTRIBUTING.md`](../CONTRIBUTING.md) — contributor policy.
