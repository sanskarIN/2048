# CI/CD and Repository Automation

2048 Nova uses GitHub Actions for repeatable formatting, static analysis, automated tests, Web release builds, native release-build verification, dependency locking, platform-runner generation, and branding export. The workflows are intended to make repository state reproducible without committing credentials or using force pushes.

## Permanent workflows

The permanent workflow set lives in `.github/workflows/`:

| Workflow | Primary purpose |
| --- | --- |
| `ci.yml` | Flutter-managed metadata drift guard, format verification for application/tests/tools, analyzer, test suite with coverage, release-readiness gates, deterministic solver smoke benchmark, and warning-enforced Web release build. |
| `dependency-review.yml` | Pull-request dependency diff review for dependency-sensitive changes, failing on newly introduced high-severity vulnerable dependencies. |
| `platform-builds.yml` | Android, Linux, Windows, macOS, and unsigned iOS release-build matrix with generated-dependency drift checks, packaging, SHA-256 sidecars, and retained qualification artifacts. |
| `format-code.yml` | Auto-format `lib/` and `test/` on `main` and commit only when formatting changes are required. |
| `lock-dependencies.yml` | Resolve and commit `pubspec.lock` automatically when dependency metadata changes or when manually dispatched. |
| `bootstrap-platforms.yml` | Recreate Flutter native platform runners with the project package/org configuration. |
| `bootstrap-branding.yml` | Export project branding into platform-specific icon/splash assets. |

Temporary one-time patch/logging workflows used during development are removed after their purpose is complete. They are not part of the permanent automation surface.

## Maintained GitHub Actions runtime baseline

Permanent workflows use `actions/checkout@v7`. Pull-request dependency review uses `actions/dependency-review-action@v5`. The maintained Node 24 action baseline was verified on GitHub-hosted runner `2.336.0` and is regression-guarded by `test/repository_integrity_test.dart`; checkout v4, v5, and v6 references are rejected.

Phase 26 also exercised checkout v7 on Ubuntu, Windows, and macOS through the native matrix and executed Dependency Review v5 on a real disposable pull request. See [`PHASE_26_VERIFICATION.md`](PHASE_26_VERIFICATION.md) for the exact run/job evidence.

Dependency Review remains an additional pull-request gate, not a replacement for formatter, analyzer, tests, release gates, solver smoke, Web build, native builds, or manual stable-release qualification.

## CI quality gate

Workflow name: **CI**

Triggers:

- every push to `main`;
- pull requests targeting `main`;
- explicit maintainer `workflow_dispatch` for verifying a chosen current `main` head, including heads produced by repository-writing workflows whose token-authored push intentionally does not recurse into another Actions run.

The quality job runs on Ubuntu and currently performs, in order:

```bash
flutter --version
flutter pub get
git diff --exit-code -- pubspec.lock analysis_options.yaml
dart format --output=none --set-exit-if-changed lib test tool
flutter analyze
flutter test --coverage
dart run tool/release_readiness.dart --json
# CI also verifies that --stable fails closed while real-world Version 1.5 qualification is incomplete
dart run tool/solver_benchmark.dart 8
# Web output is captured and fails if Flutter reports missing icon-font assets.
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

It runs on relevant `main` changes to `lib/`, `test/`, `tool/`, or the workflow itself and can be manually dispatched.

The workflow:

1. checks out full history;
2. installs stable Flutter;
3. resolves dependencies;
4. runs `dart format lib test tool`;
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

This workflow is intentionally narrow. It runs when `pubspec.yaml`, `pubspec.lock`, or its own workflow file changes and can also be manually dispatched. It executes `flutter pub get` and commits `pubspec.lock` only if resolution changes the lockfile.

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

## Phase 21 QR verification path

The normal CI gate covers QR Dart formatting, analyzer checks, the complete widget/unit suite, and the Web release/WASM dry run. Platform Builds must also compile the final runtime tree on Android, Linux, Windows, macOS, and unsigned iOS so the pinned QR package does not silently break a configured target.

Optical scan testing remains manual and is not inferred from a successful build. Final Phase 21 run/job identifiers are recorded in `PHASE_21_VERIFICATION.md` and the canonical verification record after source freeze.

## Phase 21 accepted workflow evidence

Phase 21 final source `2678e65824ca088c4ba93342bc8737fc18ec7708` is covered by both permanent acceptance workflows.

```text
CI run: 31877515001
CI job: 94995319221
Result: SUCCESS
Formatting: 94 files, 0 changed
Analyzer: No issues found
Tests: 194/194
Web release: PASS
WASM dry run: PASS

Platform Builds run: 31877514960
Android: PASS — 94995348734
Linux: PASS — 94995348682
Windows: PASS — 94995348743
macOS + unsigned iOS: PASS — 94995348674
```

The first final-source CI `31877417527` failed the formatter and is intentionally retained in the record. The maintained formatter workflow `31877417558` corrected the repository-wide Dart formatting drift before the final source trigger. Temporary Phase 21 implementation/product-copy/documentation helpers were removed after use and are not permanent CI infrastructure.


## Phase 22 release-promotion gate

Phase 22 adds an evidence-backed release boundary without pretending that hosted automation performs physical-device or assistive-technology qualification. `tool/release_readiness.dart` validates required release files, package/candidate version consistency, the exact manual-check ID set, allowed statuses, evidence/timestamp requirements, changelog/roadmap boundaries, and stable metadata. Candidate mode is CI-safe while required manual checks remain pending; strict `--stable` mode fails until all stable conditions are genuinely satisfied.

Accepted Phase 22 CI evidence:

```text
Source commit: 86aaddeb6cfcbfef45c86889060ec5313fdbab31
CI run: 31932018261
CI job: 95128223530
Runner: Ubuntu 24.04
Flutter: 3.47.0 stable
Dart: 3.13.0
Formatting: PASS — 96 files, 0 changed
Analyzer: PASS — No issues found
Tests: PASS — 194/194
Candidate readiness: PASS — candidateGatePassed=true; readyForStable=false; 0/13 manual evidence complete
Stable-boundary assertion: PASS — strict stable mode correctly refused 0.9.0+1
Solver smoke benchmark: PASS — Heuristic and Expectimax, four deterministic seeds, eight moves each
Web release: PASS — build/web
WASM dry run: PASS
```

The same run intentionally proves both sides of the boundary: the release candidate is structurally valid, and a stable release is not yet qualified. Native runtime code did not change in Phase 22, so the latest accepted native compilation evidence remains the Phase 21 matrix; real-device/manual checks remain outstanding in the evidence manifest and release checklist.

## Phase 22 gate regression expansion — current evidence

The fixture-testable release gate supersedes the earlier 194-test Phase 22 automation count without changing Flutter gameplay/runtime code. The permanent CI source below contains `--root=<path>` test support, all six CLI regression cases, and the focused regression-testing documentation.

```text
Source commit: 57c6312ee26eed0cea8597ebf6417d442cf988cc
CI run: 31932367464
CI job: 95129044532
Runner: Ubuntu 24.04.4 LTS
Flutter: 3.47.0 stable
Dart: 3.13.0
DevTools: 2.60.0
Formatting: PASS — 97 files, 0 changed
Analyzer: PASS — No issues found
Tests: PASS — 200/200
Candidate readiness: PASS — 0/13 real-world evidence complete; readyForStable=false
Stable boundary: PASS — strict stable mode refused the current RC as required
Solver smoke: PASS
Web release: PASS — build/web
WASM dry run: PASS
```

The accepted native runtime build matrix remains Phase 21 because Phase 22 changes release tooling/tests/documentation, not application runtime behavior.

## Phase 23 release-engineering hardening

Phase 23 hardened reproducibility and retained-build evidence without changing gameplay rules or claiming manual device qualification.

Permanent changes include:

- every repository-owned checkout moved to `actions/checkout@v6`, removing the prior Node-20 checkout warning on current runners;
- exact `cupertino_icons 1.0.8` dependency/lock entry so Web includes the referenced Cupertino icon font;
- CI fails when `flutter pub get` changes `pubspec.lock` or `analysis_options.yaml`;
- `analysis_options.yaml` contains Flutter 3.47's generated-platform exclusions, so Flutter no longer silently migrates it during CI;
- platform jobs fail when generated plugin registrants/CMake files drift from dependency metadata;
- macOS generated plugin registration now includes `FilePickerPlugin`, repairing the native file-picker registration required by Game Backup file transport;
- the Web build is captured and fails if the missing-icon-font warning returns;
- native outputs are packaged with SHA-256 sidecars and uploaded as five 14-day qualification artifacts using `actions/upload-artifact@v7`.

Accepted quality evidence:

```text
CI run: 31934616568
Job: 95134494782
Source: 1f48ebc947596915be3104aa5da56eb6ad291fff
Flutter: 3.47.0 stable
Dart: 3.13.0
DevTools: 2.60.0
Flutter metadata drift: PASS
Formatting: PASS — 98 files, 0 changed
Analyzer: PASS — No issues found
Tests: PASS — 208/208
Candidate release gate: PASS — 0/13 manual evidence remains
Stable boundary assertion: PASS — current 0.9.0+1 remains fail-closed
Solver smoke benchmark: PASS
Web/WASM dry run: PASS
Missing icon-font warning guard: PASS
Web release: PASS — build/web
```

Accepted native/package evidence:

```text
Platform Builds run: 31934181987
Source: 5b22795d5aba661bd587e7bcbf2ae6442c8b4b3a
Android job: 95133491378 — PASS
Linux job: 95133491351 — PASS
Windows job: 95133491405 — PASS
macOS + unsigned iOS job: 95133491379 — PASS
Qualification artifacts: 5/5 uploaded with SHA-256 sidecars
```

See [`RELEASE_ARTIFACTS.md`](RELEASE_ARTIFACTS.md) for the exact accepted artifact IDs/digests and the boundary between hosted artifacts and real-world qualification.


### Phase 23 final dispatch hardening

Permanent CI now supports `workflow_dispatch`. This closes a verification usability gap exposed by the Phase 23 documentation refresh: GitHub correctly does not recursively start another workflow from a push authenticated with the repository workflow token, so maintainers need an explicit supported way to run the same quality gate against the resulting head. `test/repository_integrity_test.dart` guards the dispatch trigger as the eighth repository-integrity contract.
