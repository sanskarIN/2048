# Tool Installation and Verification Matrix

This is the compact companion to the deep setup guides. It tells you **which tool is needed for which target, what installs it, what command verifies it, and where to read the full explanation**.

Do not use this table as a substitute for compatibility notes in the detailed guides.

## 1. Core tools

| Tool | Needed for | Installation source/method | Verify | Deep guide |
| --- | --- | --- | --- | --- |
| Git | All contributors | OS/vendor-supported Git package | `git --version` | [`GIT.md`](GIT.md) |
| Flutter SDK | All app development/builds | Official Flutter stable SDK | `flutter --version` | [`FLUTTER_AND_DART.md`](FLUTTER_AND_DART.md) |
| Dart SDK | Dart source/tests/tools | Bundled with Flutter | `dart --version` | [`FLUTTER_AND_DART.md`](FLUTTER_AND_DART.md) |
| Terminal/shell | All command-line workflows | Windows Terminal/PowerShell, Terminal/Bash/Zsh, etc. | run a normal shell command | [`PREREQUISITES.md`](PREREQUISITES.md) |

## 2. Editors and IDEs

| Tool | Needed for | Required? | Verify | Deep guide |
| --- | --- | --- | --- | --- |
| VS Code | Dart/Flutter editing/debugging | Optional | `code --version` | [`VS_CODE.md`](VS_CODE.md) |
| Android Studio | Android SDK/emulator/native tooling | Strongly recommended for Android | open IDE + `flutter doctor -v` | [`ANDROID_STUDIO.md`](ANDROID_STUDIO.md) |
| Visual Studio | Windows desktop native build | **Required for Windows build** | `flutter doctor -v` | [`VISUAL_STUDIO_WINDOWS.md`](VISUAL_STUDIO_WINDOWS.md) |
| Xcode | iOS/macOS native build | **Required on Mac for Apple builds** | `xcodebuild -version` | [`XCODE_AND_COCOAPODS.md`](XCODE_AND_COCOAPODS.md) |

## 3. Android tools

| Tool/component | Purpose | Where it comes from | Verify |
| --- | --- | --- | --- |
| Android SDK Platform | Android compile APIs/resources | Android SDK Manager | `flutter doctor -v` |
| Build-Tools | Android packaging/build utilities | Android SDK Manager | SDK Manager / build |
| Platform-Tools | ADB/device tooling | Android SDK Manager | `adb version` |
| Command-line Tools | `sdkmanager` and SDK admin | Android SDK Manager | `sdkmanager --list` |
| Android Emulator | Virtual Android runtime | Android SDK Manager | `flutter emulators` |
| System Image | OS image for an AVD | Android SDK Manager | Device Manager |
| JDK/JBR | Java build runtime/compiler | Android Studio or compatible JDK | `flutter doctor -v`, `java -version` |
| Gradle Wrapper | Reproducible Gradle selection | **Already in repository** | `./gradlew --version` / `.\gradlew.bat --version` |
| AGP | Android Gradle build plugin | **Pinned in repository** | inspect `android/settings.gradle.kts` |
| Kotlin Android plugin | Android Kotlin build integration | **Pinned in repository** | inspect `android/settings.gradle.kts` |
| NDK | Native Android C/C++ toolchain when needed | Android SDK Manager / Flutter-selected version | `flutter doctor -v` / build |

Current repository Android combination:

```text
AGP 9.1.0
Kotlin Android 2.4.10
Gradle 9.7.0
Java/Kotlin target 17
```

Read [`ANDROID.md`](ANDROID.md) before changing any of these.

## 4. Windows native tools

| Component | Purpose | Installed through | Verify |
| --- | --- | --- | --- |
| Visual Studio | Native Windows IDE/toolchain container | Visual Studio Installer | `flutter doctor -v` |
| Desktop development with C++ | Flutter Windows native workload | Visual Studio Installer | `flutter doctor -v` |
| MSVC | C/C++ compiler/linker | Visual Studio C++ workload | Windows Flutter build |
| MSBuild | Native build engine | Visual Studio | Windows Flutter build |
| Windows SDK | Windows headers/libraries/tools | Visual Studio workload/components | `flutter doctor -v` / build |
| CMake integration | Generates native build configuration | Visual Studio workload/components | Windows Flutter build |

Do not confuse VS Code with Visual Studio.

## 5. Apple native tools

| Component | Purpose | Installed through | Verify |
| --- | --- | --- | --- |
| Xcode | iOS/macOS compiler/SDK/IDE | Apple-supported Xcode installation | `xcodebuild -version` |
| Xcode Command Line Tools | CLI compiler/developer tools | `xcode-select --install` / Xcode | `xcode-select -p` |
| Simulator | Virtual iOS device | Xcode | `flutter devices` |
| CocoaPods | Native Apple dependency manager | One supported installation method | `pod --version` |
| Apple signing identity | Signed distribution | Authorized Apple account/certificates | actual signed archive/export |
| Provisioning profile | iOS app/team/capability authorization | Apple developer tooling | actual signed build/export |

Private Apple signing credentials are not public repository files.

## 6. Linux native tools

| Tool/component | Purpose | Debian/Ubuntu package example | Verify |
| --- | --- | --- | --- |
| Clang | C/C++ compiler | `clang` | `clang --version` |
| CMake | Build configuration generator | `cmake` | `cmake --version` |
| Ninja | Build executor | `ninja-build` | `ninja --version` |
| pkg-config | Native library discovery | `pkg-config` | `pkg-config --version` |
| GTK 3 development files | Flutter Linux embedding headers/libs | `libgtk-3-dev` | `pkg-config --modversion gtk+-3.0` |
| C++ stdlib dev files | Native C++ headers/libs | `libstdc++-12-dev` on applicable baseline | compile/build |

Other distributions use different package names. Read [`LINUX_NATIVE_TOOLCHAIN.md`](LINUX_NATIVE_TOOLCHAIN.md).

## 7. Web tools

| Tool/component | Purpose | Required? | Verify |
| --- | --- | --- | --- |
| Flutter Web toolchain | Compile Web output | Required | `flutter build web --release` |
| Supported browser | Interactive debug/test | Recommended | `flutter devices` |
| Web server/hosting | Production deployment | Required to publish | test deployed URL |
| HTTPS/secure deployment | Browser/PWA requirements as applicable | Production requirement context | real browser diagnostics |

Node.js/npm are not required merely for Flutter's normal Web build in this repository.

## 8. Repository-owned tools

These are **already source files in the repository**. Do not install them as global programs.

| Tool | Purpose | Run |
| --- | --- | --- |
| Release readiness | Candidate/stable gate | `dart run tool/release_readiness.dart --json` |
| Qualification status | Read manual evidence state | `dart run tool/release_qualification_status.dart --json --pending-only` |
| Qualification recorder | Guarded genuine evidence writer | see `tool/README.md` |
| Repository audit | Files/version/PWA/docs-link integrity | `dart run tool/repository_audit.dart --json` |
| Source completion audit | Version 2.0.12 completion contract | `dart run tool/source_completion_audit.dart --json` |
| Solver benchmark | Deterministic solver smoke/performance | `dart run tool/solver_benchmark.dart 8` |

They use the Dart SDK bundled with Flutter.

## 9. Package managers

Package managers are installation mechanisms, not project runtime dependencies.

| OS/ecosystem | Common manager | Example |
| --- | --- | --- |
| Windows | WinGet | `winget install --id Git.Git -e` |
| macOS | Homebrew | `brew install git` |
| Debian/Ubuntu | APT | `sudo apt-get install -y git` |
| Fedora | DNF | `sudo dnf install git` |
| Arch | Pacman | `sudo pacman -S git` |
| Dart | Pub | `flutter pub get` |
| Apple native packages | CocoaPods | `pod install` |

Use one consistent supported installation source for a tool whenever possible.

## 10. PATH-sensitive commands

If the wrong installation is selected, verify command locations.

Windows:

```powershell
where.exe git
where.exe flutter
where.exe dart
where.exe java
where.exe adb
```

macOS/Linux:

```bash
type -a git
type -a flutter
type -a dart
type -a java
type -a adb
```

Multiple results are not automatically wrong, but you must know which one is first/active.

## 11. Tools that should not be installed globally for this project without need

Normal 2048 Nova compilation does not require:

- global Gradle;
- a second standalone Dart SDK;
- Node.js/npm;
- Docker;
- a database server;
- a cloud backend SDK;
- .NET SDK for the Flutter Windows runner.

Additional tools can be installed for separate personal workflows, but they are not project prerequisites.

## 12. First universal verification

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

Then verify only the native target tools relevant to the host.

## 13. If a tool is unsupported/EOL

Do not simply replace everything with the newest versions.

Read [`UPGRADING_AND_SUPPORT.md`](UPGRADING_AND_SUPPORT.md) and migrate the smallest compatible toolchain unit, then run all affected checks/builds.

## 14. Related documentation

- [`README.md`](README.md) — setup index.
- [`PREREQUISITES.md`](PREREQUISITES.md) — why each tool exists.
- [`UPGRADING_AND_SUPPORT.md`](UPGRADING_AND_SUPPORT.md) — lifecycle policy.
- [`../COMMAND_REFERENCE.md`](../COMMAND_REFERENCE.md) — command meanings.
- [`../ERROR_REFERENCE.md`](../ERROR_REFERENCE.md) — diagnosis.
