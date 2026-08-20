# 2048 Nova Environment Setup

This directory is the canonical installation, workstation setup, toolchain maintenance, and end-of-support migration guide for **2048 Nova**.

Current project baseline:

```text
Application: 2.0.12+2012
Dart: >=3.9.0 <4.0.0
Flutter floor: >=3.35.0
Hosted CI Flutter: 3.47.0 stable
Android Gradle Plugin: 9.1.0
Kotlin Android plugin: 2.4.10
Gradle Wrapper: 9.7.0
Android Java/Kotlin target: JVM 17
```

## Start here

| Guide | Use it when |
| --- | --- |
| [`PREREQUISITES.md`](PREREQUISITES.md) | You want to know every required/optional tool and why it exists. |
| [`WINDOWS.md`](WINDOWS.md) | You develop on Windows or need Android/Windows/Web setup. |
| [`MACOS.md`](MACOS.md) | You develop on macOS or need Android/macOS/iOS/Web setup. |
| [`LINUX.md`](LINUX.md) | You develop on Linux or need Android/Linux/Web setup. |
| [`LINUX_NATIVE_TOOLCHAIN.md`](LINUX_NATIVE_TOOLCHAIN.md) | You need the Linux compiler/CMake/Ninja/pkg-config/GTK toolchain, native build, packaging, or linker/runtime diagnosis. |
| [`ANDROID.md`](ANDROID.md) | You want deep Android Studio/SDK/JDK/Gradle/AGP/Kotlin/APK/AAB/signing detail. |
| [`UPGRADING_AND_SUPPORT.md`](UPGRADING_AND_SUPPORT.md) | A tool is outdated, deprecated, insecure, unsupported, or end-of-life. |
| [`TOOL_SUPPORT_MATRIX.md`](TOOL_SUPPORT_MATRIX.md) | You want the current project baseline, version-check commands, and a fast upgrade/compatibility decision table for every major tool family. |
| [`../DOCUMENTATION_READING_GUIDE.md`](../DOCUMENTATION_READING_GUIDE.md) | You want to understand notation, placeholders, paths, version operators, pipes, exit codes, and how to read commands safely. |
| [`../COMMAND_REFERENCE.md`](../COMMAND_REFERENCE.md) | You want to understand what each command and flag means. |
| [`../GLOSSARY.md`](../GLOSSARY.md) | A technical word/abbreviation is unfamiliar. |
| [`../REPOSITORY_FILE_ATLAS.md`](../REPOSITORY_FILE_ATLAS.md) | You want a no-skip explanation of the repository and how to enumerate every tracked file. |
| [`../FILE_COVERAGE_CONTRACT.md`](../FILE_COVERAGE_CONTRACT.md) | You want the auditable rule that defines how every tracked path is covered without relying on a stale hard-coded file count. |

## Choose by target

### Android

Supported development hosts: Windows, macOS, Linux.

Read in this order:

1. your host OS guide;
2. [`ANDROID.md`](ANDROID.md);
3. [`../ANDROID_TOOLCHAIN.md`](../ANDROID_TOOLCHAIN.md);
4. [`../build/ANDROID.md`](../build/ANDROID.md);
5. [`../build/SIGNING_AND_DISTRIBUTION.md`](../build/SIGNING_AND_DISTRIBUTION.md).

### Web / PWA

Supported development hosts: Windows, macOS, Linux.

Read:

1. your host OS guide;
2. [`../PWA.md`](../PWA.md);
3. [`../build/WEB.md`](../build/WEB.md);
4. [`../BUILDING_EXECUTABLES.md`](../BUILDING_EXECUTABLES.md).

### Windows desktop

Requires a Windows host with Visual Studio's **Desktop development with C++** workload.

Read:

1. [`WINDOWS.md`](WINDOWS.md);
2. [`../build/WINDOWS.md`](../build/WINDOWS.md);
3. [`../BUILDING_EXECUTABLES.md`](../BUILDING_EXECUTABLES.md).

### macOS desktop

Requires a Mac with Xcode.

Read:

1. [`MACOS.md`](MACOS.md);
2. [`../build/MACOS.md`](../build/MACOS.md);
3. [`../BUILDING_EXECUTABLES.md`](../BUILDING_EXECUTABLES.md).

### iOS

Requires a Mac with Xcode. Signed distribution additionally requires legitimate Apple signing/provisioning credentials outside the public repository.

Read:

1. [`MACOS.md`](MACOS.md);
2. [`../build/IOS.md`](../build/IOS.md);
3. [`../build/SIGNING_AND_DISTRIBUTION.md`](../build/SIGNING_AND_DISTRIBUTION.md);
4. [`../BUILDING_EXECUTABLES.md`](../BUILDING_EXECUTABLES.md).

### Linux desktop

Requires a Linux host with Clang, CMake, Ninja, pkg-config, GTK 3 development files, and compatible C++ standard-library development packages.

Read:

1. [`LINUX.md`](LINUX.md);
2. [`LINUX_NATIVE_TOOLCHAIN.md`](LINUX_NATIVE_TOOLCHAIN.md);
3. [`../build/LINUX.md`](../build/LINUX.md);
4. [`../BUILDING_EXECUTABLES.md`](../BUILDING_EXECUTABLES.md).

## First-time universal workflow

After installing the appropriate tools:

```bash
git clone https://github.com/sanskarIN/2048.git
cd 2048
flutter --version
dart --version
flutter doctor -v
flutter pub get
dart format --output=none --set-exit-if-changed lib test tool
flutter analyze
flutter test
```

Then run the build for the target you intend to maintain.

If any command notation is unclear before you execute it, read [`../DOCUMENTATION_READING_GUIDE.md`](../DOCUMENTATION_READING_GUIDE.md), then use [`../COMMAND_REFERENCE.md`](../COMMAND_REFERENCE.md) for the command-specific explanation.

## What `flutter doctor -v` does and does not prove

It is a diagnostic tool that checks whether Flutter can find major platform dependencies and reports detailed versions/paths.

A healthy doctor result does **not** prove:

- all project tests pass;
- a release artifact builds;
- production signing is correct;
- a real device behaves correctly;
- accessibility has been manually verified;
- a store will accept the artifact.

Those are separate checks.

## When your installed tool is too old

Do not immediately delete everything and install random latest versions.

Start with [`TOOL_SUPPORT_MATRIX.md`](TOOL_SUPPORT_MATRIX.md) to compare the local tool with the repository baseline and identify the correct version-check command. Then use [`UPGRADING_AND_SUPPORT.md`](UPGRADING_AND_SUPPORT.md) to:

1. identify whether the tool is actually unsupported;
2. check official compatibility requirements;
3. preserve the current source baseline in Git;
4. migrate the smallest compatible toolchain layer;
5. rerun analyzer/tests/audits/builds;
6. update CI/documentation only after adoption is intentional.

## When your installed tool is newer than the repository baseline

Newer is not automatically a problem, but it is also not automatically qualified.

If your newer tool works locally:

- do not silently change project pins only to match your workstation;
- compare its behavior with the repository's pinned CI/toolchain baseline;
- report concrete incompatibilities;
- treat an intentional baseline upgrade as a maintenance change with complete validation.

## Tools versus project dependencies

Do not confuse:

- **development tools** — Flutter, Git, Xcode, Visual Studio, Android Studio, JDK, CMake, Ninja;
- **SDK/toolchain components** — Android SDK/NDK, AGP, Gradle, Kotlin;
- **Dart/Flutter package dependencies** — entries in `pubspec.yaml`/`pubspec.lock`;
- **GitHub Actions** — CI workflow dependencies under `.github/workflows/`;
- **operating-system libraries** — GTK/native compiler packages on Linux.

Each category has a different upgrade mechanism and compatibility policy.

## Do not install these merely because another programming project uses them

2048 Nova does not require Node.js/npm, a database server, Docker, a standalone global Gradle, or a second standalone Dart SDK just to compile the Flutter application.

Install extra tools only when a documented task actually needs them.

## Support lifecycle rule

The project favors a **supported, reproducible, validated compatibility set** over both extremes:

- freezing unsupported tooling forever;
- chasing every newest release without qualification.

Security requirements, OS/store policy deadlines, and vendor end-of-support events are valid reasons to open a maintenance migration.

## No-skip repository rule

The literal tracked-file inventory comes from Git:

```bash
git ls-files | sort
```

[`../FILE_COVERAGE_CONTRACT.md`](../FILE_COVERAGE_CONTRACT.md) defines how every tracked path must be covered by an exact-file or explicit file-family explanation, while [`../REPOSITORY_FILE_ATLAS.md`](../REPOSITORY_FILE_ATLAS.md) provides the detailed repository map.

## Next documentation

After environment setup:

- [`../NEW_CONTRIBUTOR_TUTORIAL.md`](../NEW_CONTRIBUTOR_TUTORIAL.md) — zero-to-safe-change contributor path;
- [`../DEVELOPMENT.md`](../DEVELOPMENT.md) — normal source-development workflow;
- [`../TESTING.md`](../TESTING.md) — test/evidence model;
- [`../BUILDING_EXECUTABLES.md`](../BUILDING_EXECUTABLES.md) — all release artifacts;
- [`../ERROR_REFERENCE.md`](../ERROR_REFERENCE.md) — detailed failure/diagnosis reference;
- [`../TROUBLESHOOTING.md`](../TROUBLESHOOTING.md) — common failures and diagnostics;
- [`../README.md`](../README.md) — complete docs index.
