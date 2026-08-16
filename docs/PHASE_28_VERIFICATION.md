# Phase 28 Verification — Workflow and Supply-Chain Reproducibility

Date: **2026-08-16**

Phase 28 hardens the Version 1.5 automation/toolchain boundary without changing gameplay semantics or claiming any of the 13 real-world stable-release checks.

## Maintained release-candidate line

```text
Package version: 1.5.0+15
Marketing/runtime version: 1.5.0
Flutter workflow SDK: 3.47.0 stable
Dart: 3.13.0
Android hosted JDK: Temurin 17
Android baseline: AGP 9.1.0 / Kotlin 2.4.10 / Gradle 9.7.0
Manual stable qualification: 0/13
```

## Immutable workflow execution baseline

Permanent workflows now execute reviewed full commit revisions instead of moving Action tags:

```text
actions/checkout
3d3c42e5aac5ba805825da76410c181273ba90b1  # v7

subosito/flutter-action
1a449444c387b1966244ae4d4f8c696479add0b2  # v2

actions/dependency-review-action
a1d282b36b6f3519aa1f3fc636f609c47dddb294  # v5

actions/upload-artifact
043fb46d1a93c77aae656e7c1c64a875d1fc6a0a  # v7

actions/setup-java
b6effb05e454b25005698d916606bdc6ffcbf961  # v5
```

All five workflows that execute Flutter pin `flutter-version: 3.47.0` and use `cache: false`. The qualified Flutter composite action still declares `actions/cache@v5` internally, so GitHub prepares its metadata while loading the composite action; however, the actual `Cache Flutter` and `Cache pub dependencies` steps are skipped when `cache: false`. Phase 28 deliberately records that distinction instead of claiming the nested action is never resolved.

Read-only CI, Dependency Review, and native matrix jobs also set `persist-credentials: false` after checkout. Repository-writing generator/formatter/lock workflows retain the credential only because pushing is part of their explicit function.

## Permanent quality evidence

```text
Source: 234576b9e0872ca09c47cd43f47eb6d36a88e4b7
CI run: 31948413257
CI job: 95167995837
Result: SUCCESS
Runner: 2.336.0 / Ubuntu 24.04.4 LTS
Flutter: 3.47.0 stable
Dart: 3.13.0
Formatting: PASS — 99 files, 0 changed
Static analysis: PASS — No issues found
Tests: PASS — 225/225
Candidate readiness: PASS — candidateGatePassed=true; readyForStable=false; 0/13 manual evidence complete
Stable promotion boundary: PASS — strict stable mode correctly remained closed
Solver smoke benchmark: PASS
WASM dry run: PASS
Missing icon-font warning guard: PASS
Web release: PASS — build/web
Checkout credential persistence: disabled
Flutter action cache steps: skipped
```

The new tests cover immutable workflow references, exact qualified Action revisions, frozen Flutter SDK/cache policy, exact branding Python pins, Gradle distribution checksum, read-only checkout credentials, Android JDK 17, rejection of `pull_request_target`/`write-all`, and no force push in repository-writing workflows.

## Gradle distribution verification

`android/gradle/wrapper/gradle-wrapper.properties` verifies the complete Gradle 9.7.0 distribution with the publisher checksum:

```text
distributionSha256Sum=a9ecb5ac5c2ca40691e6527724d11d0b43b8c0a52825b77c09899f2a72d2d2bf
```

The hosted Android release build below passed with that configuration.

## Pinned branding generator evidence

The previous floating `pip install cairosvg pillow` environment was replaced by exact build-time pins in `tool/branding-requirements.txt`.

```text
Bootstrap Branding Assets run: 31947463847
Job: 95165649555
Result: SUCCESS
Generated asset changes required: none
```

The exact pinned set includes CairoSVG 2.9.0 and Pillow 12.3.0 plus their explicitly pinned Python dependencies.

## Real pull-request Dependency Review proof

A disposable pull request exercised the immutable checkout and Dependency Review revisions on a real pull-request event:

```text
PR: #13 — closed without merge
Dependency Review run: 31947619961
Job: 95166040339
Result: SUCCESS
High-or-higher vulnerable dependency changes: none detected
```

The disposable comment-only branch was not promoted to `main`.

## Hosted native matrix

The definitive Phase 28 native source is the commit that made the Android Java runtime explicit:

```text
Source: f694f508057ebcf1e91a825a90cc764398051647
Platform Builds run: 31948335974
Android job: 95167849002 — SUCCESS
Linux job: 95167849014 — SUCCESS
Windows job: 95167848969 — SUCCESS
macOS + unsigned iOS job: 95167849007 — SUCCESS
```

Android passed after explicitly installing Temurin JDK 17, resolving dependencies, verifying the lockfile, using the Gradle distribution checksum, compiling the release APK, creating its checksum, and uploading the qualification artifact.

## Phase 28 hosted artifacts

| Artifact | ID | Size | GitHub artifact digest |
| --- | ---: | ---: | --- |
| `nova-2048-android-release` | 9263995770 | 25,409,409 bytes | `sha256:372bed361b7976e5125cbea38ff691c4c2399780fd126af8aa3a8d25c02b00b0` |
| `nova-2048-linux-x64-release` | 9263955131 | 10,396,415 bytes | `sha256:4a19198b3949389845d2cdc8b1b96beb0f0a8bc90553e3add5877151eb095892` |
| `nova-2048-windows-x64-release` | 9263974634 | 12,655,211 bytes | `sha256:6bc86e5fe55a6a90241c4d4f2b9dc2584b4e8129c2928003a59653a94c1f3053` |
| `nova-2048-macos-release` | 9263981693 | 18,739,155 bytes | `sha256:d22aa3d99353c64b190723e6588baffad276a2c6530cde94fcf04874ee81531d` |
| `nova-2048-ios-unsigned-release` | 9263981993 | 8,709,383 bytes | `sha256:d7fec66f6a781bb6e996520e6a04f93b763de2b9e09a5b8cdb1b77bffde70b18` |

These artifacts are retained for 14 days and expire on **2026-08-30**. They are hosted compilation/packaging evidence, not physical-device or store-distribution qualification.

## Repository-setting audit

The GitHub `main` branch metadata reported:

```text
protected: false
protection.enabled: false
required_status_checks.enforcement_level: off
required status contexts: []
```

This cannot be fixed through a tracked source file. The connected GitHub integration does not expose a branch-protection/ruleset write operation. Issue **#12** therefore tracks the required repository-setting change. Documentation must not claim `main` is technically protected until GitHub itself reports an active rule/ruleset.

## Security visibility boundary

Phase 28 also attempted to read GitHub Dependabot-alert, code-scanning-alert, and secret-scanning-alert endpoints. Those APIs were permission-restricted for the connected integration. The project therefore does not infer or claim that inaccessible alert sets are empty.

Available evidence includes tracked-source secret/config searches, ignored signing files, real Dependency Review execution, repository-integrity/workflow-security tests, analyzer, Web/native builds, and readable GitHub settings.

## Existing Android upstream boundary

Issue **#10** remains open for the AGP 9.3.1/JDK 17 release-lint incompatibility. Phase 28 does not hide that issue by switching the maintained baseline to JDK 21. The accepted hosted Android path remains AGP 9.1.0 + Kotlin 2.4.10 + Gradle 9.7.0 on explicit JDK 17.

## Stable release boundary

The Phase 28 automation hardening does **not** satisfy any of the 13 evidence-backed real-world checks. Physical Android/iOS devices, responsive/input behavior, assistive technology, long sessions, Auto Play, Challenge Code, Move Replay, Full Replay, Game Backup, external handlers, native branding, and production distribution/signing/provisioning remain pending.

Current stable qualification remains **0/13** and the stable gate remains correctly fail-closed.
