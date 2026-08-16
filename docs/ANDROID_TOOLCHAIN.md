# Android Toolchain Compatibility Policy

This document records the maintained Android build-tool baseline for 2048 Nova Version 1.5 and the evidence required before changing it.

## Current maintained baseline

The accepted Android toolchain on `main` is:

- Android Gradle Plugin (AGP): **9.1.0**
- Kotlin Android plugin: **2.4.10**
- Gradle wrapper: **9.7.0**
- Java baseline for normal hosted Android qualification: the GitHub-hosted/Flutter-supported JDK 17 environment unless a future project-wide decision intentionally raises it
- Flutter: current stable channel in CI; package floor remains the value declared in `pubspec.yaml`

The exact version strings are regression-guarded by `test/repository_integrity_test.dart`.

## Why AGP 9.3.x is deferred

Phase 27 evaluated AGP 9.3.1 together with Kotlin 2.4.10 and Gradle 9.7.0 on PR #9.

The experiment passed normal Flutter CI, Dependency Review, and the non-Android hosted build targets. However, the Android release build failed on the normal JDK 17 baseline while running:

```text
:url_launcher_android:lintVitalAnalyzeRelease
```

The failure was a `java.lang.NoSuchMethodError` involving:

```text
java.util.List.removeLast()
```

The stack passed through Android lint JavaDoc/comment parsing. Release lint was **not** disabled to force the build through.

A branch-only Temurin JDK 21 diagnostic then built the same AGP 9.3.1 / Kotlin 2.4.10 / Gradle 9.7.0 stack successfully, including Android release lint, APK creation, checksum creation, and artifact upload. That diagnostic isolated the observed failure to the Java-runtime/lint interaction rather than to 2048 Nova Dart/Flutter source.

Because the AGP 9.3 compatibility contract still documents JDK 17 support, 2048 Nova does not raise its Android build JDK solely to mask that mismatch. The evidence and follow-up are tracked in GitHub issue **#10**.

## Accepted Phase 27 subset

PR #11 separated the independently useful updates from the failing AGP major:

- AGP remained at 9.1.0;
- Kotlin Android moved from 2.4.0 to 2.4.10;
- Gradle moved from 9.3.1 to 9.7.0.

Before merge, PR #11 passed:

- Dependency Review v5;
- formatter and analyzer;
- the complete 216-test suite that existed before the new toolchain-pin regression;
- Version 1.5 candidate/stable release-gate behavior;
- deterministic solver smoke benchmark;
- Web release build;
- Android release APK on the normal JDK 17 baseline;
- Linux release build;
- Windows release build;
- macOS release build;
- unsigned iOS release build;
- native package/checksum/artifact upload steps.

The PR was then merged to `main` as merge commit `b5ddc657880826bb8a0a5621ff03a99050350342`.

## file_picker and built-in Kotlin warning

The AGP 9.3 experiment also surfaced a Flutter warning that the current stable `file_picker 11.0.2` still applies the legacy Kotlin Gradle plugin and that a future Flutter release will reject that behavior.

The project deliberately keeps **stable `file_picker 11.0.2`** for the current Version 1.5 line. The built-in-Kotlin cleanup is presently associated with the package's 12.0.0 prerelease line. 2048 Nova will not replace a stable runtime dependency with a beta solely to remove a forward-looking build warning.

Revisit this decision when a compatible stable file_picker release contains the required Android/Kotlin integration changes.

## Upgrade acceptance rule

An Android build-tool update is not accepted merely because Dependabot proposes it.

Before promotion to `main`, a coordinated toolchain change must pass:

1. Dependency Review;
2. formatter and analyzer;
3. complete Flutter tests;
4. candidate and stable release-gate behavior;
5. solver smoke benchmark;
6. Web release build;
7. Android release APK with release lint enabled;
8. native generated-file synchronization;
9. Linux, Windows, macOS, and unsigned iOS hosted controls when the change could affect Flutter/plugin integration;
10. package/checksum/artifact upload steps;
11. repository-integrity assertions for the accepted baseline when a deferral must remain explicit.

Do not disable `lintVital`, weaken static analysis, suppress dependency-review findings, or fabricate manual-device evidence to make a toolchain upgrade appear compatible.

## Revisit conditions for AGP 9.3+

AGP 9.3 or a later line can be re-evaluated when at least one of these is true:

- the upstream Android lint/JDK 17 failure is fixed;
- Android's documented Java baseline changes and the project intentionally adopts that new baseline;
- relevant Flutter/plugin integration releases make the migration clearly supported;
- a newer AGP release supersedes the failing path and passes the complete project qualification matrix.

Until then, issue #10 remains the explicit maintenance follow-up and AGP 9.1.0 remains the validated Version 1.5 baseline.

## Stable-release boundary

Android hosted build-tool compatibility is not physical-device or store-distribution qualification. The 13 real-world evidence items in `docs/release_qualification.json` remain separate and must not be inferred from hosted Gradle/Flutter build success.
