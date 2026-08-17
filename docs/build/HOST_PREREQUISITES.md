# Host and Toolchain Prerequisites

This page explains which host operating system and native tools are required to build each 2048 Nova target locally. The repository's GitHub Actions matrix remains the reproducible cross-host reference when you do not have every native host available.

## Common requirements

All local build hosts need:

- Git;
- Flutter SDK;
- Dart bundled with Flutter;
- project dependencies installed with `flutter pub get`;
- enough free disk space for Flutter caches, native SDKs, intermediate objects, and release outputs.

Verify first:

```bash
flutter --version
flutter doctor -v
flutter devices
```

For closest parity with the repository's current permanent CI, use Flutter **3.47.0**. The package floor remains defined in `pubspec.yaml`; CI's frozen version is the stronger reproducibility reference for the current Version 1.5 qualification line.

## Android host

Supported local host families:

- Windows;
- macOS;
- Linux.

Required native tooling includes:

- Android SDK/platform tools/build tools as selected by Flutter/Gradle;
- accepted Android licenses;
- Java runtime compatible with the maintained project toolchain.

The hosted Android qualification job explicitly uses Temurin **JDK 17**.

Check:

```bash
java -version
flutter doctor -v
```

Do not independently change AGP/Kotlin/Gradle/JDK versions to chase a local build error without consulting [`../ANDROID_TOOLCHAIN.md`](../ANDROID_TOOLCHAIN.md).

## iOS host

Local iOS compilation requires:

- macOS;
- Xcode;
- Xcode command-line tools;
- Flutter iOS tooling;
- CocoaPods or other plugin integration components when required by the current Flutter/plugin state.

For device/App Store/TestFlight distribution, additionally configure Apple Developer signing/provisioning outside Git.

Check:

```bash
xcodebuild -version
flutter doctor -v
```

Windows and Linux are not the repository's supported hosts for native iOS release builds.

## Web host

Flutter Web can be built on:

- Windows;
- macOS;
- Linux.

For development/qualification also have a supported browser available. Chrome is commonly used by Flutter development tooling:

```bash
flutter run -d chrome
```

Production qualification should cover the actual browsers you intend to support, not only the development browser.

## Windows host

Native Windows builds require Windows plus Visual Studio's C++ desktop toolchain as reported by `flutter doctor -v`.

Typical required categories include:

- Visual Studio;
- Desktop development with C++;
- compatible Windows SDK;
- CMake/native build tools installed through the supported Visual Studio/Flutter setup.

Check:

```powershell
flutter config --enable-windows-desktop
flutter doctor -v
```

Build Windows on Windows; cross-compiling the repository's Windows desktop release from Linux/macOS is not the documented release procedure.

## macOS host

Native macOS builds require:

- macOS;
- Xcode and command-line tools;
- Flutter macOS desktop support.

Check:

```bash
flutter config --enable-macos-desktop
xcodebuild -version
flutter doctor -v
```

Public direct distribution may additionally require Developer ID signing and notarization. Mac App Store distribution has its own signing/entitlement requirements.

## Linux host

Native Linux builds require Linux plus Flutter's GTK/native build prerequisites.

The repository's hosted Ubuntu job installs:

```bash
sudo apt-get update
sudo apt-get install -y ninja-build libgtk-3-dev liblzma-dev
```

Other distributions should install equivalent packages through their own package managers.

Check:

```bash
flutter config --enable-linux-desktop
flutter doctor -v
```

A Linux binary built on one distribution can depend on system libraries available there; qualify representative target systems before claiming broad distribution compatibility.

## Host matrix

| Target | Windows host | macOS host | Linux host |
| --- | --- | --- | --- |
| Android | Yes | Yes | Yes |
| iOS | No | Yes | No |
| Web | Yes | Yes | Yes |
| Windows desktop | Yes | No | No |
| macOS desktop | No | Yes | No |
| Linux desktop | No | No | Yes |

This table describes the repository's intended local native build procedure, not every experimental/custom cross-compilation possibility.

## Hosted CI mapping

The permanent native qualification workflow uses:

- Ubuntu runner → Android;
- Ubuntu runner → Linux;
- Windows runner → Windows;
- macOS runner → macOS + unsigned iOS.

Permanent quality CI uses Ubuntu for formatter/analyzer/tests/release gate/standard Web release build.

See [`CI_PARITY.md`](CI_PARITY.md) and [`../CI_CD.md`](../CI_CD.md).

## Clean environment diagnostics

Before changing source code to fix a local build, capture:

```bash
flutter --version
flutter doctor -v
```

and for Android:

```bash
java -version
```

for Apple platforms:

```bash
xcodebuild -version
```

Then compare with the repository's accepted CI environment and current verification records.

## Disk/cache caution

`flutter clean` removes project-generated build output but not every global SDK/cache. Use it for stale project artifacts:

```bash
flutter clean
flutter pub get
```

Do not delete `android/`, `ios/`, `windows/`, `macos/`, `linux/`, or `web/` runner/source directories merely to free space or resolve a build without first understanding the impact.

## Secrets are not prerequisites for qualification compilation

The public repository's build qualification intentionally avoids requiring committed private credentials:

- Android hosted release-mode builds use the tracked qualification/debug-key signing configuration;
- hosted iOS builds use `--no-codesign`;
- Windows/macOS hosted builds are compilation/package qualification, not production identity-signing claims.

Private signing/provisioning becomes necessary when producing the actual distribution artifact for a channel that requires it.