# CI/CD and Repository Automation

2048 Nova uses GitHub Actions for repeatable formatting, static analysis, automated tests, Web release builds, native release-build verification, dependency locking, platform-runner generation, and branding export. The workflows are intended to make repository state reproducible without committing credentials or using force pushes.

## Permanent workflows

The permanent workflow set lives in `.github/workflows/`:

| Workflow | Primary purpose |
| --- | --- |
| `ci.yml` | Format verification, analyzer, test suite with coverage, and Web release build. |
| `platform-builds.yml` | Android, Linux, Windows, macOS, and unsigned iOS release-build matrix. |
| `format-code.yml` | Auto-format `lib/` and `test/` on `main` and commit only when formatting changes are required. |
| `lock-dependencies.yml` | Resolve and commit `pubspec.lock` when explicitly triggered. |
| `bootstrap-platforms.yml` | Recreate Flutter native platform runners with the project package/org configuration. |
| `bootstrap-branding.yml` | Export project branding into platform-specific icon/splash assets. |

Temporary one-time patch/logging workflows used during development are removed after their purpose is complete. They are not part of the permanent automation surface.

## CI quality gate

Workflow name: **CI**

Triggers:

- every push to `main`;
- pull requests targeting `main`.

The quality job runs on Ubuntu and currently performs, in order:

```bash
flutter --version
flutter pub get
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test --coverage
flutter build web --release
```

The order is deliberate. Formatting and analysis fail fast before spending time on tests/builds when source quality is already invalid.

The workflow has read-only repository contents permission and uses concurrency cancellation so an older in-progress run for the same ref can be replaced by newer work.

Phase 15 Challenge Code coverage is part of this same permanent gate rather than a feature-specific permanent workflow. `challenge_code_test.dart`, `challenge_code_screen_test.dart`, and the app-level navigation regression execute with the rest of the suite.

## Native platform build matrix

Workflow name: **Platform Builds**

It triggers on `main`/pull-request changes affecting application source, assets, dependency manifests, native runner directories, or the workflow itself. It can also be started manually through `workflow_dispatch`.

### Android

Runner: Ubuntu

```bash
flutter pub get
flutter build apk --release
```

This verifies a release APK can be produced. Store distribution signing remains a separate release responsibility.

### Linux

Runner: Ubuntu

The workflow installs the required desktop build packages, enables Linux desktop support, resolves dependencies, and runs:

```bash
flutter build linux --release
```

### Windows

Runner: Windows

The workflow enables Windows desktop support and runs:

```bash
flutter build windows --release
```

### macOS and iOS

Runner: macOS

The Apple job enables macOS desktop support and runs:

```bash
flutter build macos --release
flutter build ios --release --no-codesign
```

The iOS command deliberately verifies an **unsigned** release. The repository does not contain Apple signing certificates or provisioning credentials.

Challenge Codes use only Dart/Flutter code plus the already-existing platform clipboard boundary, so they require no new native plugin/package setup. Native verification still matters because their Home route, screen, form controls, clipboard calls, in-app Guide/About text, and normal game-start path are compiled into every target.

## Automatic Dart formatting

Workflow name: **Format Dart**

It runs on relevant `main` changes to `lib/`, `test/`, or the workflow itself and can be manually dispatched.

The workflow:

1. checks out full history;
2. installs stable Flutter;
3. resolves dependencies;
4. runs `dart format lib test`;
5. commits only if formatter output changed files;
6. rebases on the current `main`;
7. pushes normally.

Automation-generated formatting commits use:

```text
user.name  = Sanskar
user.email = sanskarin@outlook.in
```

The job skips when the actor is `github-actions[bot]` to prevent a formatting-commit loop.

## Dependency lock workflow

Workflow name: **Lock Flutter Dependencies**

This workflow is intentionally narrow. It runs when its own workflow file changes or when manually dispatched, executes `flutter pub get`, and commits `pubspec.lock` only if resolution changes the lockfile.

The application lockfile is committed because 2048 Nova is an application, not a reusable Dart library.

Challenge Codes added no dependency and therefore require no lockfile change.

## Platform bootstrap

Workflow name: **Bootstrap Flutter Platforms**

The workflow can recreate native Flutter runner files with:

```bash
flutter create . \
  --platforms=android,ios,linux,macos,windows \
  --project-name=nova_2048 \
  --org=com.sanskarin
```

Generated changes are committed only when necessary, then rebased and pushed normally. Existing project-specific native metadata and branding must be reviewed after any intentional regeneration because `flutter create` can update generated files across Flutter versions.

## Branding bootstrap

The branding workflow generates platform icon/splash assets from the repository's original branding source rather than requiring manually maintained duplicate raster exports.

The editable source of identity remains under `assets/branding/`. See [`BRANDING.md`](BRANDING.md) for the exact source/export layout and prior successful workflow evidence.

## Commit and push policy

Repository-writing workflows:

- use the requested author identity `Sanskar <sanskarin@outlook.in>`;
- do not force-push `main`;
- rebase against current `main` before pushing when appropriate;
- exit without a commit when generated output is unchanged;
- do not store access tokens or signing secrets in repository files.

GitHub's automatically supplied workflow token is used through normal Actions checkout/push behavior.

## CI evidence policy

`docs/VERIFICATION.md` contains the compact current evidence, while `what_changed.md` preserves chronological evidence including intermediate failures that exposed real regressions.

A later successful run does not erase an earlier failure. If a failure reveals a defect, the development log records:

- failing workflow/run;
- failing gate;
- observed defect;
- correcting commit;
- later successful verification.

Superseded runs cancelled by the concurrency policy are explicitly distinguished from actual code/test failures. For example, a run whose formatter/analyzer/tests passed but whose Web build was cancelled because a newer commit arrived is not promoted as final evidence and is not mislabeled as a code failure.

## What CI proves

Successful automated workflows provide evidence that the tested repository state:

- is formatter-clean;
- passes Flutter static analysis;
- passes the automated test suite, including current Challenge Code codec/UI determinism/validation flows;
- produces a Web release build;
- when the native matrix is run, compiles configured native release targets on GitHub-hosted runners.

## What CI does not prove

CI alone does not establish:

- universal absence of defects;
- physical-device touch behavior across every device;
- real screen-reader quality;
- real Challenge Code/Game Backup clipboard permission/history behavior on every OS/browser;
- store acceptance;
- Android release-key management;
- Apple signing/provisioning;
- every browser's clipboard/external-handler behavior;
- long-duration lifecycle behavior;
- real-world performance on low-end hardware.

Those remain in [`RELEASE_CHECKLIST.md`](RELEASE_CHECKLIST.md).

## Adding a new workflow

A new permanent workflow should:

1. have one clear purpose;
2. request the minimum permissions it needs;
3. use concurrency when duplicate runs would waste resources;
4. avoid secrets in logs;
5. avoid force pushes;
6. have explicit path filters if expensive and not needed for documentation-only changes;
7. use stable/reviewed third-party Actions versions;
8. be documented here if it becomes part of the permanent project process.

One-time migration or repair workflows should be deleted after successful use rather than accumulating as inactive maintenance debt.


## Phase 17 current-source workflow evidence

Current runtime source commit `d33d65840aff67c4e9bf69ad203f46b85146093c` was verified by permanent CI run `31867788776` and Platform Builds run `31867788753`. CI passed formatting (74 files, 0 changed), static analysis, all **144/144 tests**, Web release compilation, and the Web WASM dry run. The native matrix passed Android APK, Linux, Windows, macOS, and unsigned iOS release builds.

This current-source rerun was not created to substitute documentation for testing: the `lib/**` source-documentation clarification intentionally exercised the normal maintained workflow triggers after the final runtime parser correction. The results therefore apply to the corrected runtime tree.


## Phase 18 maintained workflow evidence

Phase 18 final automated qualification uses permanent CI run `31869835223` and Platform Builds run `31869794809`. CI passed formatting (80 files, 0 changed), static analysis, **161/161 tests**, Web release compilation, and the Web WASM dry run under Flutter 3.47.0 / Dart 3.13.0.

The native workflow passed Android APK, Linux, Windows, macOS, and unsigned iOS release builds on runtime commit `e324882fc861e9e4221020aabb00515c7366a6f7`. The later CI-only commit `b114255b6f510f0e7ba8d0516e9a30eebf4451b8` fixes a missing test import and leaves runtime source unchanged.

Intermediate analyzer failures `31869526679` and `31869794852` are retained in the verification/work log. The first caught a duplicate Hindi translation key and CLI `avoid_print` issues; the second caught a missing localization import in a widget test. Permanent quality gates were not weakened to bypass either issue.

## Phase 19 replay archive gate scope

The permanent CI gate now includes full-session replay protocol, persistence and controller capture, spectator UI and navigation, and Hindi localization tests in addition to all previous regressions. Replay archive changes remain subject to the same formatter, analyzer, full tests, and Web release sequence. Runtime `lib/**` changes also trigger the permanent native Platform Builds matrix according to its path filters.

A green hosted gate proves the tested archive code parses and reconstructs the covered deterministic sequences and compiles on configured targets. It does not prove real platform clipboard behavior, long-session performance, assistive-technology quality, lifecycle timer behavior, signing, or store acceptance.

## Phase 20 plugin qualification

Because Phase 20 adds `file_picker` and macOS sandbox entitlements, its final acceptance requires both the normal CI gate and the configured native Platform Builds workflow on the completed runtime tree. The normal CI covers dependency resolution, formatting, analyzer, 189 tests, Web release, and Web WASM dry-run compatibility. Platform Builds provides Android/Linux/Windows/macOS/unsigned-iOS compilation evidence.

Neither workflow performs interactive system picker qualification. Save/Open/cancel/document-provider/browser-download behavior remains a manual release boundary.

## Phase 20 final CI and Android plugin repair

Accepted current-source automation:

```text
CI: 31875447398 / job 94990368739 - SUCCESS
Platform Builds: 31875447417 - SUCCESS
Source: 188e81c607eca76516018be8c668eab41b777cc1
```

The first native run `31875177571` was intentionally not accepted because Android job `94989728523` failed generated plugin registration for `FilePickerPlugin`. The host was migrated to AGP-9 built-in Kotlin in `188e81c607eca76516018be8c668eab41b777cc1`, after which Android job `94990368847` passed together with Linux `94990368919`, Windows `94990368886`, and macOS/unsigned-iOS `94990368933`.

CI on the repaired source passed 91-file formatting, analyzer, 189 tests, Web release, and WASM dry run. Hosted automation still does not exercise an interactive system file chooser.
