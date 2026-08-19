# Linux Development Setup

This guide configures a Linux workstation for **2048 Nova** development, Android, Web, and Linux desktop builds. It also explains the role of each native package and how to upgrade safely.

Checked against the repository on **2026-08-19**.

## 1. What Linux can build

A correctly configured Linux host can build:

- Android APK and AAB;
- Web/PWA;
- Linux desktop bundles.

Linux cannot natively build the Windows, macOS, or iOS runners. Use their native hosts or the repository's GitHub Actions matrix.

## 2. Install Git

Debian/Ubuntu:

```bash
sudo apt-get update
sudo apt-get install -y git
```

Fedora:

```bash
sudo dnf install git
```

Arch Linux:

```bash
sudo pacman -S git
```

Verify:

```bash
git --version
which git
```

`which git` prints the executable selected through the current shell `PATH`.

## 3. Install Flutter

Use Flutter's official Linux installation archive or another Flutter-supported installation method. Keep the SDK in a user-writable development directory rather than a system directory that requires root permission for every SDK update.

Example:

```text
~/development/flutter
```

For Bash, add to `~/.bashrc`:

```bash
export PATH="$HOME/development/flutter/bin:$PATH"
```

For Zsh, place the equivalent line in `~/.zshrc`.

Reload the shell:

```bash
source ~/.bashrc
```

Verify:

```bash
which flutter
flutter --version
dart --version
flutter doctor -v
```

The project accepts Flutter `>=3.35.0`; hosted repository CI uses Flutter `3.47.0` stable.

## 4. Native Linux build packages

Flutter Linux desktop needs a native compiler/build stack and GTK development libraries.

On Debian/Ubuntu-style systems:

```bash
sudo apt-get update
sudo apt-get install -y clang cmake ninja-build pkg-config libgtk-3-dev libstdc++-12-dev
```

What each package means:

- `clang` — C/C++ compiler used for the native runner and plugin code.
- `cmake` — generates native build configuration.
- `ninja-build` — fast native build executor used by Flutter's CMake workflow.
- `pkg-config` — discovers installed native libraries and compiler/linker flags.
- `libgtk-3-dev` — development headers/libraries for GTK 3, used by Flutter Linux desktop embedding.
- `libstdc++-12-dev` — C++ standard-library development components on supported Debian/Ubuntu baselines.

Verify:

```bash
clang --version
cmake --version
ninja --version
pkg-config --version
flutter doctor -v
```

On Fedora, Arch, openSUSE, and other distributions, install the equivalent official packages for your distribution. Package names are not universal.

## 5. Android requirements on Linux

Install Android Studio or the official Android command-line tools, then install the Android SDK packages required by the active Flutter stable release.

Recommended components include:

- Android SDK Platform(s) needed by Flutter/current project;
- Android SDK Build-Tools;
- Android SDK Platform-Tools;
- Android SDK Command-line Tools;
- Android Emulator if you use virtual devices.

Verify:

```bash
flutter doctor -v
```

Review Android licenses:

```bash
flutter doctor --android-licenses
```

The project's Android source targets Java/Kotlin 17 bytecode. Prefer a supported JDK 17 baseline when reproducing repository builds.

## 6. JDK 17

Check your shell Java:

```bash
java -version
javac -version
which java
```

More importantly, inspect which JDK Flutter itself selects:

```bash
flutter doctor -v
```

If you intentionally maintain a specific JDK 17 for Flutter:

```bash
flutter config --jdk-dir="/absolute/path/to/jdk17"
```

Do not configure a JRE-only directory; Android builds require a JDK.

## 7. Gradle Wrapper

The repository already pins Gradle through `android/gradle/wrapper/gradle-wrapper.properties`. No global Gradle installation is required.

Verify the wrapper:

```bash
cd android
./gradlew --version
cd ..
```

The wrapper currently selects Gradle `9.7.0` and is paired with AGP `9.1.0`, Kotlin Android `2.4.10`, and JDK 17 for this project's accepted Android baseline.

## 8. VS Code optionally

Install VS Code using a distribution/vendor-supported method if you want it as your editor. Install the Flutter and Dart extensions.

When the `code` CLI is available:

```bash
code --install-extension Dart-Code.flutter
code --install-extension Dart-Code.dart-code
```

Verify:

```bash
code --version
```

An editor does not replace the native Linux packages or Android SDK.

## 9. Clone the repository

```bash
mkdir -p ~/development
cd ~/development
git clone https://github.com/sanskarIN/2048.git
cd 2048
flutter pub get
```

Optional repository-local author identity:

```bash
git config user.name "Sanskar"
git config user.email "sanskarin@outlook.in"
```

## 10. Validate the source

```bash
dart format --output=none --set-exit-if-changed lib test tool
flutter analyze
flutter test
```

Repository-specific checks:

```bash
dart run tool/release_readiness.dart --json
dart run tool/repository_audit.dart --json
dart run tool/source_completion_audit.dart --json
```

A passing source-level check is not evidence of real-device/store behavior. The project keeps those evidence classes separate.

## 11. Enable Linux desktop

```bash
flutter config --enable-linux-desktop
flutter devices
```

If the Linux target is healthy, `flutter devices` should expose a Linux desktop target.

Run:

```bash
flutter run -d linux
```

## 12. Build Linux release

```bash
flutter build linux --release
```

The maintained release bundle is under Flutter's generated Linux release bundle directory. Preserve the complete bundle: executable, libraries, and data belong together.

See [`../build/LINUX.md`](../build/LINUX.md) for packaging/checksum detail.

## 13. Build Web release

```bash
flutter build web --release
```

Deploy the whole `build/web/` output directory. A production web deployment additionally needs a correctly configured web server/host and HTTPS as appropriate.

## 14. Build Android artifacts

After Android SDK/JDK health is confirmed:

```bash
flutter build apk --release
flutter build appbundle --release
```

The APK can be installed/sideloaded when appropriately signed for the intended use. The AAB is primarily a store publishing bundle.

## 15. Upgrade Linux packages safely

The exact command depends on distribution.

Debian/Ubuntu:

```bash
sudo apt-get update
apt list --upgradable
```

Review the list before upgrading. A broad operating-system upgrade can change compilers, CMake, GTK, graphics libraries, and SDK dependencies simultaneously.

Fedora commonly uses:

```bash
sudo dnf check-upgrade
```

Arch commonly uses a rolling full-system upgrade model:

```bash
sudo pacman -Syu
```

Follow the distribution's official upgrade policy; do not partially upgrade a rolling-release system if that distribution explicitly warns against it.

## 16. Upgrade Flutter

```bash
flutter channel stable
flutter upgrade
flutter doctor -v
```

Then rerun:

```bash
flutter pub get
dart format --output=none --set-exit-if-changed lib test tool
flutter analyze
flutter test
flutter build web --release
flutter build linux --release
```

Also rerun Android builds if you maintain Android on that machine.

## 17. Upgrade Android Studio/SDK

Update Android Studio using its supported stable updater/package source. Review SDK packages in Android Studio's SDK Manager.

If `sdkmanager` is available:

```bash
sdkmanager --list
sdkmanager --update
```

Afterward:

```bash
flutter doctor -v
cd android
./gradlew --version
cd ..
```

An Android Studio update does not mean the repository's AGP/Kotlin/Gradle pins should be changed automatically.

## 18. Native dependency troubleshooting

### `clang` missing

```bash
clang --version
```

Install your distribution's Clang package.

### `cmake` missing

```bash
cmake --version
```

Install your distribution's CMake package.

### `ninja` missing

```bash
ninja --version
```

The package may be named `ninja-build` while the executable is `ninja`.

### GTK development package missing

```bash
pkg-config --modversion gtk+-3.0
```

If this fails, install the GTK 3 development package for your distribution.

## 19. PATH troubleshooting

```bash
printf '%s\n' "$PATH" | tr ':' '\n'
type -a flutter
type -a dart
type -a git
```

`type -a` shows all matching executable locations known to the shell. Remove stale SDK path entries if an older Flutter installation shadows the intended SDK.

## 20. Clean rebuild

```bash
flutter clean
flutter pub get
flutter analyze
flutter test
```

Use this for stale generated output, not as a way to hide a real source/toolchain error.

## 21. Final Linux readiness

```bash
git --version
flutter --version
dart --version
clang --version
cmake --version
ninja --version
pkg-config --version
flutter doctor -v
flutter pub get
dart format --output=none --set-exit-if-changed lib test tool
flutter analyze
flutter test
flutter build web --release
flutter build linux --release
```

If Android is maintained on the machine, also verify the Gradle Wrapper and build APK/AAB artifacts.

For command semantics, see [`../COMMAND_REFERENCE.md`](../COMMAND_REFERENCE.md). For unsupported/out-of-support tooling, see [`UPGRADING_AND_SUPPORT.md`](UPGRADING_AND_SUPPORT.md).