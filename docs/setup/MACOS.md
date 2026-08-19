# macOS Development Setup

This guide configures a Mac for **2048 Nova** development across Flutter, Android, Web, macOS desktop, and iOS.

Checked against the repository on **2026-08-19**.

## 1. What macOS can build

A properly configured Mac can build:

- Android APK/AAB;
- Web/PWA;
- macOS `.app`;
- iOS unsigned release app;
- signed iOS IPA when Apple signing/provisioning is configured.

A Mac does not build the Windows native runner; use Windows or the repository's native CI matrix for that target.

## 2. Install Apple's command-line tools

Run:

```bash
xcode-select --install
```

This requests Apple's Command Line Tools when they are not already installed.

Verify:

```bash
xcode-select -p
```

A normal full-Xcode path is:

```text
/Applications/Xcode.app/Contents/Developer
```

## 3. Install Git

Apple Command Line Tools include Git. Verify:

```bash
git --version
```

If you intentionally manage Git with Homebrew:

```bash
brew install git
```

Upgrade Homebrew-managed Git:

```bash
brew update
brew upgrade git
```

Do not keep several accidental Git installations on `PATH` without knowing which one your shell selects. Check:

```bash
which git
type -a git
```

## 4. Install Flutter

Download the stable Flutter SDK from Flutter's official installation page, extract it to a writable development location, and add `flutter/bin` to your shell `PATH`.

Example location:

```text
~/development/flutter
```

For Zsh, a typical `~/.zshrc` entry is:

```bash
export PATH="$HOME/development/flutter/bin:$PATH"
```

Reload the shell:

```bash
source ~/.zshrc
```

Verify:

```bash
which flutter
flutter --version
dart --version
flutter doctor -v
```

The project accepts Flutter `>=3.35.0`; repository CI is pinned to Flutter `3.47.0` stable.

## 5. Install Xcode

Install the current supported Xcode release from Apple's supported distribution channel.

After installing/updating Xcode:

```bash
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
sudo xcodebuild -runFirstLaunch
xcodebuild -version
```

What these do:

- `xcode-select --switch`: selects the Xcode developer directory used by command-line tools.
- `xcodebuild -runFirstLaunch`: performs required first-launch component/setup actions.
- `xcodebuild -version`: proves the command-line build tool can run.

If Apple requires a license agreement for the installed Xcode version, complete the official license flow before building.

## 6. CocoaPods

Some Flutter plugins use native Apple dependencies managed through CocoaPods.

Verify:

```bash
pod --version
```

If you use Homebrew to manage CocoaPods:

```bash
brew install cocoapods
```

Upgrade:

```bash
brew update
brew upgrade cocoapods
```

After a CocoaPods or Xcode change, use Flutter's normal package/build workflow first. Do not delete Podfiles, lockfiles, or generated Apple runner configuration simply because a Pod command reports an error.

## 7. Install Android Studio when Android is required

Install Android Studio, run its setup wizard, and install the recommended Android SDK components and Command-line Tools.

Verify through Flutter:

```bash
flutter doctor -v
```

Accept Android licenses when required:

```bash
flutter doctor --android-licenses
```

The Android build uses Java/Kotlin 17 bytecode settings. Prefer the JDK/JBR selected by the supported Android Studio/Flutter combination unless a reproducibility task explicitly configures another JDK 17.

## 8. Install VS Code optionally

If Homebrew Cask is used:

```bash
brew install --cask visual-studio-code
```

When the `code` command is available:

```bash
code --install-extension Dart-Code.flutter
code --install-extension Dart-Code.dart-code
```

VS Code is optional; Xcode remains mandatory for native Apple builds.

## 9. Clone the repository

```bash
mkdir -p ~/development
cd ~/development
git clone https://github.com/sanskarIN/2048.git
cd 2048
flutter pub get
```

Configure repository-local Git identity when needed:

```bash
git config user.name "Sanskar"
git config user.email "sanskarin@outlook.in"
```

## 10. Validate source quality

```bash
dart format --output=none --set-exit-if-changed lib test tool
flutter analyze
flutter test
```

Repository audits:

```bash
dart run tool/release_readiness.dart --json
dart run tool/repository_audit.dart --json
dart run tool/source_completion_audit.dart --json
```

These checks validate source/repository contracts. They do not replace real-device or store qualification.

## 11. macOS desktop build

Enable desktop support:

```bash
flutter config --enable-macos-desktop
```

Build:

```bash
flutter pub get
flutter build macos --release
```

A macOS `.app` is a directory bundle with metadata, executable, frameworks, and resources. Preserve the complete bundle.

Signing, Developer ID distribution, notarization, DMG/PKG packaging, and Mac App Store submission are separate release concerns. See [`../build/MACOS.md`](../build/MACOS.md).

## 12. iOS simulator

Open Simulator:

```bash
open -a Simulator
```

List Flutter targets:

```bash
flutter devices
```

Run on an available simulator:

```bash
flutter run
```

or select a device ID explicitly:

```bash
flutter run -d <device-id>
```

## 13. Unsigned iOS release build

For source/build qualification without code signing:

```bash
flutter build ios --release --no-codesign
```

This proves release compilation on the selected toolchain. It does **not** create an App Store-ready signed IPA.

## 14. Signed iOS IPA

When a legitimate Apple development/distribution identity, provisioning setup, bundle configuration, and account access are present:

```bash
flutter build ipa --release
```

Never commit:

- private signing keys;
- `.p12` credentials/passwords;
- App Store Connect private API keys;
- provisioning secrets;
- account tokens.

The public repository intentionally keeps such material outside source control.

## 15. Web build on macOS

```bash
flutter build web --release
```

The complete `build/web/` directory is the deployable output.

## 16. Android build on macOS

After Android SDK/JDK health is confirmed:

```bash
flutter build apk --release
flutter build appbundle --release
```

The Android Gradle Wrapper is repository-controlled. Verify it with:

```bash
cd android
./gradlew --version
cd ..
```

A separate global Gradle installation is not required.

## 17. Upgrade Flutter

```bash
flutter channel stable
flutter upgrade
flutter doctor -v
```

After a Flutter upgrade, rerun analyzer, tests, repository audits, and every native target you maintain. Read Flutter breaking-change/migration notes before adopting a new baseline in source/CI.

## 18. Upgrade Xcode

Use Apple's supported update path. After the update:

```bash
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
sudo xcodebuild -runFirstLaunch
xcodebuild -version
flutter doctor -v
```

Xcode upgrades can change iOS/macOS SDKs, compiler behavior, deployment constraints, signing behavior, simulator runtimes, and generated project requirements. Treat a major Xcode upgrade as a toolchain change requiring native build verification.

## 19. Upgrade Android tools

Update Android Studio through its stable updater and SDK packages through SDK Manager.

If `sdkmanager` is configured:

```bash
sdkmanager --list
sdkmanager --update
```

Then:

```bash
flutter doctor -v
cd android
./gradlew --version
cd ..
```

Do not independently bump AGP, Kotlin, or Gradle merely because Android Studio itself updated. The repository pins a tested combination.

## 20. Upgrade CocoaPods

Homebrew-managed installation:

```bash
brew update
brew upgrade cocoapods
pod --version
```

If your installation method differs, use the corresponding CocoaPods-supported update procedure instead of mixing package managers.

## 21. Common macOS troubleshooting

### Wrong Xcode selected

```bash
xcode-select -p
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
```

### CocoaPods missing

```bash
pod --version
flutter doctor -v
```

Install/update CocoaPods using one consistent supported method.

### Stale Flutter output

```bash
flutter clean
flutter pub get
flutter analyze
flutter test
```

### Shell cannot find Flutter

```bash
which flutter
echo "$PATH"
```

Correct the Flutter `bin` entry in your shell startup file, then open a new terminal or source the file.

### Multiple Flutter installations

```bash
type -a flutter
```

The first matching executable is the one your shell normally runs.

## 22. Final macOS readiness

```bash
git --version
flutter --version
dart --version
xcodebuild -version
xcode-select -p
pod --version
flutter doctor -v
flutter pub get
dart format --output=none --set-exit-if-changed lib test tool
flutter analyze
flutter test
flutter build web --release
flutter build macos --release
flutter build ios --release --no-codesign
```

Run Android builds too if Android Studio/SDK are installed.

For command meanings, see [`../COMMAND_REFERENCE.md`](../COMMAND_REFERENCE.md). For all artifact types, see [`../BUILDING_EXECUTABLES.md`](../BUILDING_EXECUTABLES.md).