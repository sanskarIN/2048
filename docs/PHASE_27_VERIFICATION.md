# Phase 27 Verification — Android Toolchain Qualification

Date: **2026-08-16**

This record captures the Version 1.5 Android build-tool maintenance work performed in Phase 27, including the rejected AGP 9.3.1 experiment, the JDK 21 diagnostic, the accepted Kotlin/Gradle subset, the final main-branch hosted native matrix, and the permanent regression that protects the accepted baseline.

## Final maintained Android baseline

The accepted Version 1.5 Android build-tool combination on `main` is:

```text
Android Gradle Plugin: 9.1.0
Kotlin Android plugin: 2.4.10
Gradle wrapper: 9.7.0
Normal hosted Android Java baseline: JDK 17
```

The safe Kotlin/Gradle subset was merged through PR **#11** as merge commit:

```text
b5ddc657880826bb8a0a5621ff03a99050350342
```

A repository-integrity regression added at:

```text
4f17442920026fdfef2c342707883c0454558195
```

requires AGP `9.1.0`, Kotlin `2.4.10`, and Gradle `9.7.0` and explicitly rejects AGP `9.3.1` while the upstream compatibility issue remains unresolved.

## Rejected coordinated AGP 9.3.1 experiment

PR **#9** evaluated these versions together rather than merging related toolchain updates independently:

```text
AGP: 9.3.1
Kotlin Android: 2.4.10
Gradle: 9.7.0
```

Normal Flutter CI, Dependency Review v5, Linux, Windows, macOS, and unsigned iOS controls were clean. The Android release APK failed on the normal hosted JDK 17 baseline.

Failure evidence:

```text
PR: #9
Head: 93443a4e03d2b41e02788c1c651156d4336830a8
Platform Builds run: 31944152743
Android job: 95157541743
Failing task: :url_launcher_android:lintVitalAnalyzeRelease
Failure: java.lang.NoSuchMethodError
Missing method: java.util.List.removeLast()
```

The stack passed through Android lint JavaDoc/comment parsing. Release lint was not disabled or weakened.

PR #9 was closed without merge. The continuing upstream/toolchain follow-up is GitHub issue **#10**.

## JDK 21 diagnostic

A branch-only diagnostic kept AGP 9.3.1 / Kotlin 2.4.10 / Gradle 9.7.0 but changed the Android job to Temurin JDK 21 using `actions/setup-java@v5`.

```text
Diagnostic head: afa7ea03ca373023bd72de695a8ad7b028466a9a
Platform Builds run: 31944454269
Android job: 95158249975
Result: SUCCESS
CI run: 31944454330 — SUCCESS
Dependency Review run: 31944454358 — SUCCESS
```

The Android job passed release lint, APK compilation, checksum creation, and artifact upload on JDK 21. Linux, Windows, macOS, and unsigned iOS controls also passed.

This diagnostic isolated the observed failure to the AGP/lint/Java-runtime interaction rather than to 2048 Nova Dart/Flutter source. The project nevertheless does not raise its Java baseline solely to mask a failure on AGP's documented JDK 17-compatible line.

## Accepted safe subset — PR #11

PR **#11** retained AGP 9.1.0 while updating only:

```text
Kotlin Android: 2.4.0 -> 2.4.10
Gradle: 9.3.1 -> 9.7.0
```

Pre-merge evidence:

```text
Head: 8c41db2dd9d202d4b0c9554cebdbb4bd25886e7c
Dependency Review run: 31944715131 — SUCCESS
CI run: 31944715306 — SUCCESS
Platform Builds run: 31944715192 — SUCCESS on Android/Linux/Windows/macOS/unsigned iOS
```

The Android release APK passed on the normal JDK 17 baseline, so the safe subset did not require the JDK 21 diagnostic workaround.

The standalone Dependabot Kotlin and Gradle PRs (#6 and #7) were closed as superseded after the coordinated safe subset was merged. The standalone AGP PR #3 was closed without merge and points to issue #10.

## Post-merge main native matrix

Source:

```text
b5ddc657880826bb8a0a5621ff03a99050350342
```

Hosted native qualification:

```text
Platform Builds run: 31944999081
Android job 95159531941: SUCCESS
Linux job 95159531882: SUCCESS
Windows job 95159531908: SUCCESS
macOS + unsigned iOS job 95159531916: SUCCESS
```

Every target passed dependency/generated-file synchronization, release compilation, packaging, checksum creation, and artifact upload.

## Accepted Phase 27 hosted artifacts

| Artifact | ID | Size | GitHub artifact digest |
| --- | ---: | ---: | --- |
| `nova-2048-android-release` | 9263084669 | 25,409,403 bytes | `sha256:9ad0c47f342114d73e6406ccaa5cff04c67e4c708fb689ae3ec3c0bdb359acb4` |
| `nova-2048-linux-x64-release` | 9263046299 | 10,396,699 bytes | `sha256:8c69f45255c519d83c1c31be865245fb4f0e8341418d7e45c37860e98281c0ef` |
| `nova-2048-windows-x64-release` | 9263072124 | 12,655,205 bytes | `sha256:6428785087a24c9159015359b1050312358f03c126f52619e321769f903042ae` |
| `nova-2048-macos-release` | 9263081008 | 18,739,173 bytes | `sha256:e83fc68b20008031de909cd80b170b1cc599aac3db6d98dd74d3390cf5a3beb1` |
| `nova-2048-ios-unsigned-release` | 9263081347 | 8,709,456 bytes | `sha256:c775b87f66d1fd48a7f1ef8714350d6f832d93a24e48744925a34c77b4f9812f` |

These artifacts expire on **2026-08-30** under the repository's 14-day retention policy.

## Permanent Android-baseline regression

The new repository-integrity test protects the accepted combination and increases the complete test suite to **217 tests**.

Evidence:

```text
Source: 4f17442920026fdfef2c342707883c0454558195
CI run: 31945071057
CI job: 95159704902
Result: SUCCESS
Formatting: PASS — 98 files, 0 changed
Static analysis: PASS — No issues found
Tests: PASS — 217/217
Candidate gate: PASS
Stable gate: correctly fail-closed at 0/13 real-world checks
Solver smoke: PASS
Web/WASM dry run: PASS
Web release: PASS
```

## file_picker stability decision

The AGP 9.3 experiment also surfaced a Flutter warning that stable `file_picker 11.0.2` still applies the legacy Kotlin Gradle plugin and that a future Flutter release will reject that behavior.

The current stable dependency remains `file_picker 11.0.2`. The relevant built-in-Kotlin cleanup is on the package's 12.0.0 prerelease line, so Version 1.5 does not replace a stable runtime package with a beta solely to remove a forward-looking warning.

This decision should be revisited when a compatible stable file_picker release contains the required integration changes.

## Acceptance policy established by Phase 27

Android build-tool changes must be evaluated as a coordinated compatibility surface rather than merged blindly from independent update PRs.

Do not:

- disable `lintVital` to make an AGP update pass;
- weaken analyzer or dependency-review policy;
- force a new Java baseline solely to mask an upstream compatibility defect;
- replace stable runtime dependencies with prereleases without a separate product/compatibility decision;
- infer physical-device or store qualification from hosted Android build success.

The maintained decision and revisit criteria are documented in [`ANDROID_TOOLCHAIN.md`](ANDROID_TOOLCHAIN.md).

## Stable-release boundary

Phase 27 improves hosted Android build compatibility evidence only. `docs/release_qualification.json` remains intentionally **0/13** complete. Physical Android/iOS devices, representative input/layouts, assistive technologies, long sessions, real-target transports, external handlers, native branding, and production signing/provisioning/store metadata remain evidence-backed manual boundaries before stable promotion.
