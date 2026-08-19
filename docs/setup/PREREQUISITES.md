# Development Prerequisites

This guide explains **every tool category needed to work on 2048 Nova**, why it exists, how to verify it, and whether it is required or optional.

Checked against the repository on **2026-08-19**.

## 1. Project toolchain contract

The current source of truth is [`../../pubspec.yaml`](../../pubspec.yaml):

```text
Package: nova_2048
Version: 2.0.12+2012
Dart SDK: >=3.9.0 <4.0.0
Flutter SDK: >=3.35.0
Hosted CI Flutter: 3.47.0 stable
Android compile target: Java 17 bytecode
Android Gradle Plugin: 9.1.0
Kotlin Android plugin: 2.4.10
Gradle wrapper: 9.7.0
```

The minimum SDK range answers **“what can parse and resolve this project?”**. The hosted CI version answers **“what environment is used for the repository's reproducible automated checks?”**. For the closest local reproduction, prefer the CI baseline unless a maintenance task explicitly upgrades it.

## 2. Required for every contributor

### Git

**What it is:** Git is the distributed version-control system that records project history as commits.

**Why this project needs it:** cloning, branches, commits, merges, reviewing diffs, and synchronizing with GitHub all depend on Git.

Verify:

```bash
git --version
```

A successful result prints a version such as `git version X.Y.Z`.

Useful identity configuration for this repository:

```bash
git config user.name "Sanskar"
git config user.email "sanskarin@outlook.in"
```

Without `--global`, these settings apply only to the current repository. That is safer when you use different identities for different projects.

### Flutter SDK

**What it is:** Flutter is the cross-platform UI toolkit and build tool used by this application.

**Why this project needs it:** the `flutter` command resolves packages, runs the app, checks the environment, launches tests, and creates Android, iOS, Web, Windows, macOS, and Linux builds.

Verify:

```bash
flutter --version
flutter doctor -v
```

`flutter --version` identifies the SDK. `flutter doctor -v` checks platform-specific dependencies and prints detailed diagnostics.

The repository accepts Flutter `>=3.35.0`, while CI is intentionally pinned to Flutter `3.47.0` for reproducibility.

### Dart SDK

**What it is:** Dart is the programming language used by Flutter and by this repository's maintainer tools.

**How it is installed:** a compatible Dart SDK is bundled with Flutter. Do not install a second unrelated Dart SDK merely for this project unless you have a specific tooling need.

Verify:

```bash
dart --version
```

The project requires Dart `>=3.9.0 <4.0.0`.

### A terminal or shell

You need a command-line environment to run Git, Flutter, Dart, platform build tools, and repository audits.

Common choices:

- Windows: PowerShell or Windows Terminal.
- macOS: Terminal, iTerm2, or another POSIX shell.
- Linux: Bash, Zsh, or another POSIX shell.

Commands shown with `bash` syntax generally work in Bash/Zsh. PowerShell-specific examples are marked explicitly.

## 3. Recommended editor

### Visual Studio Code

VS Code is optional but convenient for Flutter development.

Recommended extensions:

```text
Dart-Code.flutter
Dart-Code.dart-code
```

If the `code` CLI is available:

```bash
code --install-extension Dart-Code.flutter
code --install-extension Dart-Code.dart-code
```

`Dart-Code.flutter` provides Flutter project support. `Dart-Code.dart-code` provides Dart language analysis, navigation, completion, debugging, and formatting support.

Verify the CLI:

```bash
code --version
```

### Android Studio

Android Studio is strongly recommended for Android SDK management, emulator management, log inspection, signing configuration, and native Android debugging.

Install the Flutter plugin from Android Studio's plugin marketplace. The Dart plugin is installed as a dependency of the Flutter plugin in normal configurations.

Android Studio is **not** the same product as Visual Studio or Visual Studio Code.

## 4. Android requirements

To build Android APK or AAB artifacts, install:

1. Android Studio or Android command-line tools.
2. Android SDK Platform/Build Tools required by the Flutter stable toolchain.
3. Android SDK Command-line Tools.
4. A compatible JDK.
5. Android licenses.

This repository compiles Java/Kotlin for **JVM 17**. For reproducibility, JDK 17 is the preferred local baseline.

Verify:

```bash
java -version
flutter doctor -v
```

Accept Android SDK licenses through Flutter:

```bash
flutter doctor --android-licenses
```

The command starts an interactive license review. Read and accept only licenses you agree to.

The project already contains a Gradle Wrapper, so **a separate system Gradle installation is not required** for normal Android builds.

See [`../ANDROID_TOOLCHAIN.md`](../ANDROID_TOOLCHAIN.md) for the accepted AGP/Kotlin/Gradle/JDK combination.

## 5. Windows desktop requirements

Windows desktop builds require **Visual Studio**, not only VS Code.

Install the current supported Visual Studio release and select:

```text
Desktop development with C++
```

This workload supplies MSVC, Windows SDK components, CMake/MSBuild integration, and native tooling Flutter uses for Windows desktop builds.

Verify with:

```powershell
flutter doctor -v
flutter devices
```

The Windows and Visual Studio sections of `flutter doctor -v` should be healthy before you expect `flutter build windows` to succeed.

## 6. macOS desktop requirements

macOS builds require Xcode and Apple's command-line tools.

Verify:

```bash
xcodebuild -version
xcode-select -p
flutter doctor -v
```

If Xcode is installed in the standard Applications location but the command-line selector points elsewhere:

```bash
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
```

Then run any first-launch setup required by that Xcode release:

```bash
sudo xcodebuild -runFirstLaunch
```

## 7. iOS requirements

iOS development requires a Mac with Xcode. Windows and Linux cannot produce a native iOS build from this repository.

For Flutter plugins that contain iOS/macOS native code, CocoaPods may also be required by the installed Flutter/Xcode/plugin combination.

Verify:

```bash
xcodebuild -version
pod --version
flutter doctor -v
```

A simulator can be opened with:

```bash
open -a Simulator
```

Signed device/App Store distribution additionally requires Apple signing identities, provisioning profiles, entitlements, and appropriate developer-account access. Those secrets are external to this public repository.

## 8. Linux desktop requirements

Flutter Linux desktop builds require a native compiler toolchain and GTK development packages.

On Debian/Ubuntu-style systems, Flutter's documented baseline includes:

```bash
sudo apt-get update
sudo apt-get install -y clang cmake ninja-build pkg-config libgtk-3-dev libstdc++-12-dev
```

This repository's hosted Linux build also relies on Ninja and GTK development libraries.

Verify:

```bash
clang --version
cmake --version
ninja --version
pkg-config --version
flutter doctor -v
```

Package names differ on Fedora, Arch, openSUSE, and other distributions. Use the equivalent packages from that distribution's official repositories.

## 9. Web development requirements

A Web release build is produced by Flutter:

```bash
flutter build web --release
```

For interactive browser debugging, install a browser supported by your Flutter SDK, commonly Chrome.

Verify detected targets:

```bash
flutter devices
```

A production Web deployment also needs a Web server/hosting platform, HTTPS configuration, and correct base-path behavior. Those are deployment concerns, not Flutter SDK prerequisites.

## 10. Optional package managers

Package managers can simplify installation and upgrades but are not project dependencies.

Examples:

- Windows: `winget`.
- macOS: Homebrew (`brew`).
- Debian/Ubuntu: `apt` / `apt-get`.
- Fedora: `dnf`.
- Arch: `pacman`.

The project never requires one specific package manager.

## 11. Tools you do not need just to build this project

Do **not** install unrelated stacks unless another task requires them. The current Flutter application does not require:

- Node.js or npm for the Flutter Web build;
- Python for application compilation;
- a system-wide Gradle installation;
- a separate standalone Dart SDK;
- a database server;
- Docker;
- .NET SDK for the Flutter Windows build;
- an external backend service.

Reducing unnecessary tools reduces version conflicts and maintenance burden.

## 12. First verification after installation

Run from the repository root:

```bash
git --version
flutter --version
dart --version
flutter doctor -v
flutter pub get
dart format --output=none --set-exit-if-changed lib test tool
flutter analyze
flutter test
```

Meaning:

- `git --version`: proves Git is callable through `PATH`.
- `flutter --version`: identifies Flutter and bundled Dart.
- `dart --version`: proves the Dart CLI is callable.
- `flutter doctor -v`: checks platform toolchains.
- `flutter pub get`: resolves packages according to `pubspec.yaml` and `pubspec.lock`.
- `dart format ...`: verifies repository-owned Dart is already formatted.
- `flutter analyze`: performs static analysis/lint checks.
- `flutter test`: executes automated tests.

See [`../BUILDING_EXECUTABLES.md`](../BUILDING_EXECUTABLES.md) for artifact creation after the environment is healthy.

## 13. Official references

Use vendor documentation as the final authority for changing installation procedures:

- Flutter installation: https://docs.flutter.dev/install
- Flutter upgrade: https://docs.flutter.dev/install/upgrade
- Android Studio installation: https://developer.android.com/studio/install
- Android `sdkmanager`: https://developer.android.com/tools/sdkmanager
- Gradle Wrapper: https://docs.gradle.org/current/userguide/gradle_wrapper_basics.html
- Flutter Windows setup: https://docs.flutter.dev/platform-integration/windows/setup
- Flutter Linux setup: https://docs.flutter.dev/platform-integration/linux/setup
- Flutter iOS setup: https://docs.flutter.dev/platform-integration/ios/setup
- Git downloads/documentation: https://git-scm.com/

When a vendor changes a supported version or installation method, update this guide and the repository's CI/toolchain contract together instead of silently changing only a local workstation.