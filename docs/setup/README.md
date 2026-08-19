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

## 1. Start here

| Guide | Use it when |
| --- | --- |
| [`PREREQUISITES.md`](PREREQUISITES.md) | You want to know every required/optional tool and why it exists. |
| [`FLUTTER_AND_DART.md`](FLUTTER_AND_DART.md) | You need the Flutter/Dart SDK, PATH, channels, Pub, upgrades, duplicate-SDK diagnosis, or SDK migration details. |
| [`GIT.md`](GIT.md) | You need Git/GitHub installation, identity, branches, commits, protected-main/PR workflow, recovery, or secret-handling guidance. |
| [`VS_CODE.md`](VS_CODE.md) | You use VS Code for Flutter/Dart editing, debugging, tests, source control, or SDK/device selection. |
| [`WINDOWS.md`](WINDOWS.md) | You develop on Windows or need Android/Windows/Web setup. |
| [`MACOS.md`](MACOS.md) | You develop on macOS or need Android/macOS/iOS/Web setup. |
| [`LINUX.md`](LINUX.md) | You develop on Linux or need Android/Linux/Web setup. |
| [`ANDROID.md`](ANDROID.md) | You want the complete Android SDK/JDK/Gradle/AGP/Kotlin/APK/AAB/signing model. |
| [`ANDROID_STUDIO.md`](ANDROID_STUDIO.md) | You use Android Studio, SDK Manager, Device Manager/AVDs, Logcat, ADB, or Android IDE tooling. |
| [`VISUAL_STUDIO_WINDOWS.md`](VISUAL_STUDIO_WINDOWS.md) | You need the Visual Studio C++/MSVC/MSBuild/Windows SDK toolchain for Flutter Windows desktop. |
| [`XCODE_AND_COCOAPODS.md`](XCODE_AND_COCOAPODS.md) | You need Xcode, Simulator, CocoaPods, Apple signing/provisioning, or macOS/iOS native tooling. |
| [`LINUX_NATIVE_TOOLCHAIN.md`](LINUX_NATIVE_TOOLCHAIN.md) | You need Clang, CMake, Ninja, pkg-config, GTK, ELF/runtime-bundle, or Linux native troubleshooting. |
| [`UPGRADING_AND_SUPPORT.md`](UPGRADING_AND_SUPPORT.md) | A tool is outdated, deprecated, insecure, unsupported, or end-of-life. |
| [`../COMMAND_REFERENCE.md`](../COMMAND_REFERENCE.md) | You want to understand what each command and flag means. |
| [`../GLOSSARY.md`](../GLOSSARY.md) | A technical word/abbreviation is unfamiliar. |
| [`../ERROR_REFERENCE.md`](../ERROR_REFERENCE.md) | A command/build/test/toolchain error needs diagnosis. |
| [`../REPOSITORY_FILE_ATLAS.md`](../REPOSITORY_FILE_ATLAS.md) | You want a no-skip explanation of the repository and how to enumerate every tracked file. |
| [`../NEW_CONTRIBUTOR_TUTORIAL.md`](../NEW_CONTRIBUTOR_TUTORIAL.md) | You want the complete zero-to-first-PR workflow. |

## 2. Choose by host operating system

### Windows host

Recommended reading order:

1. [`PREREQUISITES.md`](PREREQUISITES.md)
2. [`FLUTTER_AND_DART.md`](FLUTTER_AND_DART.md)
3. [`GIT.md`](GIT.md)
4. [`WINDOWS.md`](WINDOWS.md)
5. [`VS_CODE.md`](VS_CODE.md) if used
6. [`ANDROID_STUDIO.md`](ANDROID_STUDIO.md) for Android
7. [`VISUAL_STUDIO_WINDOWS.md`](VISUAL_STUDIO_WINDOWS.md) for Windows desktop
8. [`UPGRADING_AND_SUPPORT.md`](UPGRADING_AND_SUPPORT.md) when maintaining tools

### macOS host

Recommended reading order:

1. [`PREREQUISITES.md`](PREREQUISITES.md)
2. [`FLUTTER_AND_DART.md`](FLUTTER_AND_DART.md)
3. [`GIT.md`](GIT.md)
4. [`MACOS.md`](MACOS.md)
5. [`VS_CODE.md`](VS_CODE.md) if used
6. [`ANDROID_STUDIO.md`](ANDROID_STUDIO.md) for Android
7. [`XCODE_AND_COCOAPODS.md`](XCODE_AND_COCOAPODS.md) for macOS/iOS
8. [`UPGRADING_AND_SUPPORT.md`](UPGRADING_AND_SUPPORT.md) when maintaining tools

### Linux host

Recommended reading order:

1. [`PREREQUISITES.md`](PREREQUISITES.md)
2. [`FLUTTER_AND_DART.md`](FLUTTER_AND_DART.md)
3. [`GIT.md`](GIT.md)
4. [`LINUX.md`](LINUX.md)
5. [`VS_CODE.md`](VS_CODE.md) if used
6. [`ANDROID_STUDIO.md`](ANDROID_STUDIO.md) for Android
7. [`LINUX_NATIVE_TOOLCHAIN.md`](LINUX_NATIVE_TOOLCHAIN.md) for Linux desktop
8. [`UPGRADING_AND_SUPPORT.md`](UPGRADING_AND_SUPPORT.md) when maintaining tools

## 3. Choose by target

### Android

Supported development hosts: Windows, macOS, Linux.

Read in this order:

1. your host OS guide;
2. [`ANDROID_STUDIO.md`](ANDROID_STUDIO.md);
3. [`ANDROID.md`](ANDROID.md);
4. [`../ANDROID_TOOLCHAIN.md`](../ANDROID_TOOLCHAIN.md);
5. [`../build/ANDROID.md`](../build/ANDROID.md);
6. [`../build/SIGNING_AND_DISTRIBUTION.md`](../build/SIGNING_AND_DISTRIBUTION.md).

### Web / PWA

Supported development hosts: Windows, macOS, Linux.

Read:

1. your host OS guide;
2. [`FLUTTER_AND_DART.md`](FLUTTER_AND_DART.md);
3. [`../PWA.md`](../PWA.md);
4. [`../build/WEB.md`](../build/WEB.md);
5. [`../BUILDING_EXECUTABLES.md`](../BUILDING_EXECUTABLES.md).

### Windows desktop

Requires a Windows host with Visual Studio's **Desktop development with C++** workload.

Read:

1. [`WINDOWS.md`](WINDOWS.md);
2. [`VISUAL_STUDIO_WINDOWS.md`](VISUAL_STUDIO_WINDOWS.md);
3. [`../build/WINDOWS.md`](../build/WINDOWS.md);
4. [`../BUILDING_EXECUTABLES.md`](../BUILDING_EXECUTABLES.md).

### macOS desktop

Requires a Mac with Xcode.

Read:

1. [`MACOS.md`](MACOS.md);
2. [`XCODE_AND_COCOAPODS.md`](XCODE_AND_COCOAPODS.md);
3. [`../build/MACOS.md`](../build/MACOS.md);
4. [`../BUILDING_EXECUTABLES.md`](../BUILDING_EXECUTABLES.md).

### iOS

Requires a Mac with Xcode. Signed distribution additionally requires legitimate Apple signing/provisioning credentials outside the public repository.

Read:

1. [`MACOS.md`](MACOS.md);
2. [`XCODE_AND_COCOAPODS.md`](XCODE_AND_COCOAPODS.md);
3. [`../build/IOS.md`](../build/IOS.md);
4. [`../build/SIGNING_AND_DISTRIBUTION.md`](../build/SIGNING_AND_DISTRIBUTION.md);
5. [`../BUILDING_EXECUTABLES.md`](../BUILDING_EXECUTABLES.md).

### Linux desktop

Requires a Linux host with Clang, CMake, Ninja, pkg-config, GTK 3 development files, and compatible C++ standard-library development packages.

Read:

1. [`LINUX.md`](LINUX.md);
2. [`LINUX_NATIVE_TOOLCHAIN.md`](LINUX_NATIVE_TOOLCHAIN.md);
3. [`../build/LINUX.md`](../build/LINUX.md);
4. [`../BUILDING_EXECUTABLES.md`](../BUILDING_EXECUTABLES.md).

## 4. First-time universal workflow

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

For a complete protected-branch contribution walkthrough, use [`../NEW_CONTRIBUTOR_TUTORIAL.md`](../NEW_CONTRIBUTOR_TUTORIAL.md).

## 5. What `flutter doctor -v` does and does not prove

It is a diagnostic tool that checks whether Flutter can find major platform dependencies and reports detailed versions/paths.

A healthy doctor result does **not** prove:

- all project tests pass;
- a release artifact builds;
- production signing is correct;
- a real device behaves correctly;
- accessibility has been manually verified;
- a store will accept the artifact.

Those are separate checks.

## 6. When your installed tool is too old

Do not immediately delete everything and install random latest versions.

Use [`UPGRADING_AND_SUPPORT.md`](UPGRADING_AND_SUPPORT.md) to:

1. identify whether the tool is actually unsupported;
2. check official compatibility requirements;
3. preserve the current source baseline in Git;
4. migrate the smallest compatible toolchain layer;
5. rerun analyzer/tests/audits/builds;
6. update CI/documentation only after adoption is intentional.

## 7. When your installed tool is newer than the repository baseline

Newer is not automatically a problem, but it is also not automatically qualified.

If your newer tool works locally:

- do not silently change project pins only to match your workstation;
- compare its behavior with the repository's pinned CI/toolchain baseline;
- report concrete incompatibilities;
- treat an intentional baseline upgrade as a maintenance change with complete validation.

## 8. Tools versus project dependencies

Do not confuse:

- **development tools** — Flutter, Git, Xcode, Visual Studio, Android Studio, JDK, CMake, Ninja;
- **SDK/toolchain components** — Android SDK/NDK, AGP, Gradle, Kotlin;
- **Dart/Flutter package dependencies** — entries in `pubspec.yaml`/`pubspec.lock`;
- **GitHub Actions** — CI workflow dependencies under `.github/workflows/`;
- **operating-system libraries** — GTK/native compiler packages on Linux.

Each category has a different upgrade mechanism and compatibility policy.

## 9. Do not install these merely because another programming project uses them

2048 Nova does not require Node.js/npm, a database server, Docker, a standalone global Gradle, or a second standalone Dart SDK just to compile the Flutter application.

Install extra tools only when a documented task actually needs them.

## 10. Support lifecycle rule

The project favors a **supported, reproducible, validated compatibility set** over both extremes:

- freezing unsupported tooling forever;
- chasing every newest release without qualification.

Security requirements, OS/store policy deadlines, and vendor end-of-support events are valid reasons to open a maintenance migration.

## 11. When something fails

Use [`../ERROR_REFERENCE.md`](../ERROR_REFERENCE.md) before deleting caches/SDKs or weakening project checks.

A reliable first snapshot is:

```bash
git status
flutter --version
dart --version
flutter doctor -v
```

Then run the narrow failing command and inspect the first root cause.

## 12. Next documentation

After environment setup:

- [`../NEW_CONTRIBUTOR_TUTORIAL.md`](../NEW_CONTRIBUTOR_TUTORIAL.md) — complete first contribution/PR;
- [`../ARCHITECTURE_WALKTHROUGH.md`](../ARCHITECTURE_WALKTHROUGH.md) — how application flows connect;
- [`../FEATURE_REFERENCE.md`](../FEATURE_REFERENCE.md) — all implemented features;
- [`../DEVELOPMENT.md`](../DEVELOPMENT.md) — normal source-development workflow;
- [`../TESTING.md`](../TESTING.md) — test/evidence model;
- [`../BUILDING_EXECUTABLES.md`](../BUILDING_EXECUTABLES.md) — all release artifacts;
- [`../ERROR_REFERENCE.md`](../ERROR_REFERENCE.md) — detailed error diagnosis;
- [`../TROUBLESHOOTING.md`](../TROUBLESHOOTING.md) — existing project troubleshooting;
- [`../DOCUMENTATION_AUDIT_CHECKLIST.md`](../DOCUMENTATION_AUDIT_CHECKLIST.md) — no-skip docs maintenance;
- [`../README.md`](../README.md) — complete docs index.