# Tool Support and Upgrade Decision Matrix

This page is the fast compatibility and lifecycle companion to the deeper setup manuals for **2048 Nova**.

It answers four practical questions for every important development tool:

1. **Why is this tool used?**
2. **What project baseline is fixed by this repository?**
3. **How do I check what is installed on my computer?**
4. **What should I do if my version is old, unsupported, newer than the baseline, or incompatible?**

Checked against the repository on **2026-08-19**, application **2.0.12+2012**.

> This file is not a live vendor lifecycle database. Vendor support windows, IDE releases, operating-system support, store policy, and security advisories can change after this document is committed. Use the repository values below as the project baseline, then verify current vendor support from the official vendor/project lifecycle and release documentation before changing a pinned toolchain.

## 1. Current repository baseline

| Component | Repository baseline or rule | Source of truth |
| --- | --- | --- |
| Application | `2.0.12+2012` | `pubspec.yaml` |
| Dart SDK | `>=3.9.0 <4.0.0` | `pubspec.yaml` |
| Flutter SDK floor | `>=3.35.0` | `pubspec.yaml` |
| Hosted CI Flutter | `3.47.0` stable | `.github/workflows/` |
| Android Gradle Plugin | `9.1.0` | `android/settings.gradle.kts` |
| Kotlin Android plugin | `2.4.10` | `android/settings.gradle.kts` |
| Gradle Wrapper | `9.7.0` | `android/gradle/wrapper/gradle-wrapper.properties` |
| Android JVM bytecode target | Java/Kotlin `17` | `android/app/build.gradle.kts` |
| Flutter packages | Resolved dependency graph | `pubspec.yaml` + `pubspec.lock` |

A **baseline** means the version or range the project deliberately declares, pins, or validates. It does not mean that every tool in the world should be downgraded to exactly that version.

## 2. Support-state meanings

### Supported

The upstream vendor/project still maintains the release under the support policy relevant to that product. Support can include compatibility updates, security fixes, bug fixes, or a defined maintenance window.

### Unsupported / EOL

**EOL** means **end of life**. The vendor/project no longer supports that release under its normal lifecycle. An EOL tool should not remain the long-term project baseline merely because one local build still works.

### Deprecated

The feature or API still exists but has been marked for replacement/removal. Deprecation is a migration warning.

### Project-compatible

The version works with this repository's declared source, build configuration, dependencies, tests, and target platforms.

### Vendor-supported but not yet project-qualified

A newer tool may be fully supported by its vendor while still being untested or incompatible with this repository. Vendor support and project qualification are separate questions.

### Pinned

The repository intentionally fixes an exact version rather than accepting whichever version happens to be installed globally.

## 3. Fast decision table

| Your local state | Recommended action |
| --- | --- |
| Matches repository baseline and vendor-supported | Keep it; run normal validation. |
| Newer and vendor-supported | Do not rewrite project pins automatically. Run compatibility validation first. |
| Older but still vendor-supported and within project constraints | It may be acceptable; compare against project minimums and CI. |
| Below a declared project minimum | Upgrade before expecting supported builds. |
| Vendor EOL/unsupported | Plan migration to a supported compatible version. |
| Security advisory affects the installed version | Prioritize an upgrade to an appropriate fixed supported release and validate the affected matrix. |
| Tool works locally but CI fails | Compare exact versions, paths, environment variables, package resolution, and platform prerequisites. |
| CI works but local machine fails | Diagnose local tool discovery/path/configuration before changing repository pins. |

## 4. Core SDK and source-control tools

### Flutter SDK

**Purpose:** Flutter is the application framework and primary build CLI. It compiles/runs the Dart application and coordinates platform toolchains.

**Project requirement:** Flutter `>=3.35.0`; hosted CI currently uses Flutter `3.47.0` stable.

Check:

```bash
flutter --version
flutter channel
flutter doctor -v
```

Meaning:

- `flutter --version` prints the selected Flutter SDK and bundled Dart version;
- `flutter channel` reports the selected Flutter release channel;
- `flutter doctor -v` performs verbose environment diagnostics and reports detected platform tools/paths.

If too old:

```bash
flutter channel stable
flutter upgrade
flutter doctor -v
```

Do not upgrade merely because a newer release exists. Read Flutter migration/breaking-change information and validate the project after adoption.

Deep guide: [`FLUTTER_AND_DART.md`](FLUTTER_AND_DART.md).

### Dart SDK

**Purpose:** Dart is the programming language/runtime/tooling used by Flutter source, formatter, analyzer, tests, and repository-owned Dart CLIs.

For this Flutter application, Dart normally comes **with Flutter**.

Check:

```bash
dart --version
flutter --version
```

Do not install a separate Dart SDK just to force this Flutter project onto a different Dart runtime. Upgrade Flutter when the Flutter-bundled Dart SDK must change.

### Git

**Purpose:** Git tracks repository history, branches, commits, diffs, tags, and local source state.

Check:

```bash
git --version
git status
```

If Git is unsupported on the host, upgrade with the operating system or vendor-supported installation method, then verify `git --version` and normal clone/status operations.

Deep guide: [`GIT.md`](GIT.md).

## 5. Android toolchain

Android uses several tools that must work **together**. Do not treat Android Studio, Android SDK, JDK, AGP, Gradle, and Kotlin as interchangeable names.

### Android Studio

**Purpose:** Android IDE plus convenient Android SDK/AVD/device tooling management.

Android Studio itself is not pinned by this repository. Use a vendor-supported release that works with the required Android/Flutter toolchain.

Useful checks:

```bash
flutter doctor -v
flutter doctor --android-licenses
```

Android Studio's own About/Settings pages provide the exact IDE version and SDK Manager state.

Deep guide: [`ANDROID_STUDIO.md`](ANDROID_STUDIO.md).

### Android SDK

**Purpose:** Platform APIs, build tools, platform tools such as ADB, and emulator tooling used to build/test Android apps.

Check Flutter's detected SDK:

```bash
flutter doctor -v
```

Check ADB:

```bash
adb version
adb devices
```

`adb devices` is a discovery/status command; it does not itself prove that a release artifact is store-ready.

Use SDK Manager or `sdkmanager` for installed SDK packages. Do not remove an SDK platform merely because a newer one exists if current project/plugin/toolchain compatibility still requires it.

### JDK / Java

**Purpose:** Java toolchain used by the Android Gradle build.

The Android project currently targets Java/Kotlin JVM bytecode level **17**. That target is not the same thing as saying every installed JDK must have the version number 17; the accepted runtime/toolchain must satisfy Flutter/AGP/Gradle compatibility.

Check:

```bash
java -version
javac -version
flutter doctor -v
```

If multiple JDKs are installed, diagnose which JDK Flutter/Gradle is actually using before deleting or changing installations.

### Gradle Wrapper

**Purpose:** Runs the repository-selected Gradle distribution reproducibly without requiring a separately installed global Gradle.

Pinned version: **9.7.0**.

Windows:

```powershell
cd android
.\gradlew.bat --version
```

macOS/Linux:

```bash
cd android
./gradlew --version
```

Prefer the wrapper over a global `gradle` command for this project.

### Android Gradle Plugin (AGP)

**Purpose:** Connects the Android application build model to Gradle.

Pinned version: **9.1.0** in `android/settings.gradle.kts`.

AGP upgrades must be checked together with supported Gradle, JDK, Android SDK, Flutter template/tooling, and Kotlin combinations.

### Kotlin Android plugin

**Purpose:** Compiles/integrates Kotlin Android runner code.

Pinned version: **2.4.10** in `android/settings.gradle.kts`.

Do not change it in isolation merely to match a globally installed Kotlin compiler.

### Android emulator / AVD

**Purpose:** Provides virtual Android devices for development and test workflows.

Check Flutter-visible emulators/devices:

```bash
flutter emulators
flutter devices
```

A physical device remains important for applicable real-device qualification; an emulator is not evidence for every hardware/runtime behavior.

Deep Android guide: [`ANDROID.md`](ANDROID.md).

## 6. Windows desktop toolchain

### Visual Studio

**Purpose:** Provides the MSVC C++ compiler, Windows SDK integration, CMake tooling, and native build environment required by Flutter Windows desktop builds.

This means **Visual Studio**, not Visual Studio Code.

Required workload for Flutter Windows development: **Desktop development with C++** and the compatible Windows build components selected by Flutter/Visual Studio.

Check:

```bash
flutter doctor -v
```

Use **Visual Studio Installer** to update/modify the installation. After an upgrade, rerun `flutter doctor -v` and a Windows build.

Deep guide: [`VISUAL_STUDIO_WINDOWS.md`](VISUAL_STUDIO_WINDOWS.md).

### Windows SDK

**Purpose:** Headers, libraries, tools, and platform metadata used to build Windows applications.

It is normally managed through Visual Studio Installer for this workflow. Do not remove SDK components until you have confirmed no supported project/toolchain target needs them.

### CMake and Ninja on Windows

Flutter/Visual Studio/native tooling may supply or discover these as part of the Windows build path. Diagnose what Flutter detects before installing multiple competing copies globally.

## 7. Apple toolchain

### Xcode

**Purpose:** Apple compiler, SDKs, simulator/device tools, signing/provisioning integration, and project build system for iOS/macOS.

Apple platform builds require a compatible macOS/Xcode environment.

Check command-line selection/version:

```bash
xcodebuild -version
xcode-select -p
flutter doctor -v
```

After Xcode upgrades, confirm the selected developer directory and run the required first-launch/license/setup steps reported by Xcode/Flutter.

Deep guide: [`XCODE_AND_COCOAPODS.md`](XCODE_AND_COCOAPODS.md).

### CocoaPods

**Purpose:** Dependency integration mechanism used by many Flutter plugins on Apple platforms.

Check:

```bash
pod --version
```

When CocoaPods or pod resolution changes, inspect generated/resolved changes and rebuild the affected iOS/macOS targets.

### Apple signing and provisioning

Certificates, private keys, provisioning profiles, and account credentials are **not** ordinary public repository dependencies and must not be committed to Git.

A successful unsigned build does not prove signed App Store distribution readiness.

## 8. Linux desktop toolchain

Flutter Linux desktop builds depend on native packages such as:

- Clang/compiler tooling;
- CMake;
- Ninja;
- `pkg-config`;
- GTK 3 development files;
- compatible C++ standard-library development packages.

Useful checks include:

```bash
clang --version
cmake --version
ninja --version
pkg-config --version
flutter doctor -v
```

Package names and support lifecycles depend on the Linux distribution. Upgrade with the distribution-supported package manager and verify that Flutter/native builds still succeed.

Deep guide: [`LINUX.md`](LINUX.md).

## 9. Editor tools

### VS Code

**Purpose:** Optional editor/debugger frontend. It is not the Flutter compiler and does not replace Android Studio's Android SDK or Visual Studio's Windows native compiler.

Check:

```bash
code --version
```

The Flutter and Dart extensions should remain compatible with the selected SDK. If editor diagnostics disagree with command-line diagnostics, compare the SDK path configured in the editor with the SDK returned by `flutter --version`.

Deep guide: [`VS_CODE.md`](VS_CODE.md).

### Android Studio versus VS Code versus Visual Studio

- **Android Studio**: Android IDE and SDK/device tooling.
- **VS Code**: lightweight editor/debugger frontend.
- **Visual Studio**: Microsoft IDE/toolchain required for Flutter Windows native builds.

They are three different products.

## 10. Web/PWA tools

Flutter Web development requires a supported Flutter Web toolchain and a compatible browser for development/qualification.

Useful commands:

```bash
flutter devices
flutter run -d chrome
flutter build web --release
```

A successful compile does not prove installed-PWA lifecycle behavior in every target browser. Browser/PWA qualification remains a real-environment responsibility.

## 11. Flutter package dependencies

Check resolved/update state:

```bash
flutter pub get
flutter pub outdated
```

Meanings:

- `flutter pub get` resolves dependencies allowed by `pubspec.yaml` and installs/uses the resolved graph;
- `flutter pub outdated` reports newer dependency versions and constraint relationships; it does not automatically modify the project.

Do not use a major dependency upgrade as routine cleanup. Read package changelogs/migration notes and run the complete affected tests/builds.

## 12. GitHub Actions and CI tool pins

CI is part of the compatibility contract, not just an online convenience.

When a local toolchain baseline changes intentionally:

1. update the source/configuration pin;
2. update the relevant CI pin in the same compatibility migration;
3. keep workflow permissions/secrets minimal;
4. run the repository test/audit/build gates;
5. do not convert a hosted build into claims of physical-device or store qualification.

See [`../WORKFLOW_SECURITY.md`](../WORKFLOW_SECURITY.md) and [`../CI_CD.md`](../CI_CD.md).

## 13. Standard post-upgrade verification

From the repository root:

```bash
flutter --version
dart --version
flutter doctor -v
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

Then build every platform affected by the upgrade on a supported host.

For a Flutter SDK migration, assume the full maintained platform matrix is affected until evidence shows otherwise.

## 14. When to downgrade

Downgrading may be appropriate when a newly installed version is vendor-supported but has a confirmed incompatibility with the current project and no safe migration has yet been accepted.

Do not downgrade to an unsupported or vulnerable release as a permanent solution. Record the incompatibility and plan the supported migration.

## 15. When to remove an old installation

Remove an old SDK/JDK/IDE/toolchain only after confirming:

- the new installation is selected by the shell/IDE/Flutter;
- the required project builds/tests run;
- no other maintained project depends on the old installation;
- environment variables and PATH no longer point to the old location;
- rollback files/configuration are not being destroyed accidentally.

Multiple installations can cause confusing path selection, but deleting first and diagnosing later is riskier than identifying the active path first.

## 16. Support escalation checklist

When reporting a toolchain problem, include:

```text
Operating system and version
flutter --version
dart --version
flutter doctor -v
git --version
Affected target platform
Exact command that failed
First useful error message
Relevant JDK/Gradle/Xcode/Visual Studio version
Whether CI passes or fails
Whether the source tree is clean
```

Do not include signing passwords, private keys, tokens, account credentials, or other secrets.

## 17. Related documentation

- [`UPGRADING_AND_SUPPORT.md`](UPGRADING_AND_SUPPORT.md) — full lifecycle/migration policy.
- [`PREREQUISITES.md`](PREREQUISITES.md) — what every prerequisite is and why it exists.
- [`FLUTTER_AND_DART.md`](FLUTTER_AND_DART.md) — deep Flutter/Dart installation and upgrade guide.
- [`ANDROID.md`](ANDROID.md) — complete Android toolchain guide.
- [`WINDOWS.md`](WINDOWS.md), [`MACOS.md`](MACOS.md), [`LINUX.md`](LINUX.md) — host setup.
- [`../COMMAND_REFERENCE.md`](../COMMAND_REFERENCE.md) — command/flag meanings.
- [`../GLOSSARY.md`](../GLOSSARY.md) — technical term meanings.
- [`../BUILDING_EXECUTABLES.md`](../BUILDING_EXECUTABLES.md) — maintained release artifacts and builds.
