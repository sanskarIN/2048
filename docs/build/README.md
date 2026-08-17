# Platform Build Guides

This directory contains the detailed build instructions for every executable or deployable artifact supported by the current 2048 Nova repository.

## Guides

| Platform | Guide | Main artifact |
| --- | --- | --- |
| Android | [`ANDROID.md`](ANDROID.md) | APK, split APKs, Android App Bundle (`.aab`) |
| iOS | [`IOS.md`](IOS.md) | unsigned `.app`, signed/exported `.ipa` when Apple signing is configured |
| Web / PWA | [`WEB.md`](WEB.md) | deployable `build/web/` static bundle, plus optional Wasm build path |
| Windows | [`WINDOWS.md`](WINDOWS.md) | native `.exe` plus required runtime bundle |
| macOS | [`MACOS.md`](MACOS.md) | `.app` application bundle |
| Linux | [`LINUX.md`](LINUX.md) | native executable plus required libraries/data bundle |
| Quick commands | [`QUICK_COMMANDS.md`](QUICK_COMMANDS.md) | Compact build command reference for every supported target |
| Output names/paths | [`OUTPUT_PATHS.md`](OUTPUT_PATHS.md) | Exact current runner binary names, application IDs, bundle names, output directories, and CI archive names |
| Packaging | [`PACKAGING_AND_CHECKSUMS.md`](PACKAGING_AND_CHECKSUMS.md) | ZIP/TAR qualification archives and SHA-256 sidecars |
| Release build checklist | [`RELEASE_BUILD_CHECKLIST.md`](RELEASE_BUILD_CHECKLIST.md) | Cross-platform source, build, packaging, signing, real-target, and stable-gate checklist |

The cross-platform overview and artifact matrix are in [`../BUILDING_EXECUTABLES.md`](../BUILDING_EXECUTABLES.md).

## Important distinction

A **build output** is not always a single executable file:

- Android APK is a single installable package.
- Android AAB is a store distribution bundle, not normally a directly installed application.
- iOS `.app` and macOS `.app` are directory bundles.
- Windows requires the generated `.exe` plus adjacent Flutter/runtime files.
- Linux requires the executable plus the generated libraries/data directory contents.
- Web requires the full generated `build/web/` directory.

Do not extract one visible executable from a generated desktop/Web bundle and assume it is independently distributable.

## Common setup

From a clean checkout:

```bash
git clone https://github.com/sanskarIN/2048.git
cd 2048
flutter --version
flutter doctor -v
flutter pub get
```

Run the quality gate before release builds:

```bash
dart format --output=none --set-exit-if-changed lib test tool
flutter analyze
flutter test
```

For current hosted-CI parity, use Flutter 3.47.0. Android hosted CI additionally uses Temurin JDK 17.

## Build-host rules

- Android: Windows, macOS, or Linux with the Android SDK/toolchain.
- iOS: macOS with Xcode; distributable IPA additionally requires Apple signing/provisioning.
- Web: Windows, macOS, or Linux.
- Windows: Windows with Flutter's Visual Studio C++ prerequisites.
- macOS: macOS with Xcode/Flutter desktop prerequisites.
- Linux: Linux with GTK and required native build packages.

Cross-compiling Flutter desktop targets from a different desktop OS is not the repository's supported release procedure. Use the native host or the repository's GitHub Actions matrix.

## CI relationship

`.github/workflows/platform-builds.yml` is the source of truth for the repository's hosted native qualification builds. `.github/workflows/ci.yml` is the source of truth for the permanent standard Web release build and quality gate.

The CI artifacts are qualification inputs rather than a substitute for physical-device, accessibility, signing, provisioning, notarization, store, or external-handler testing.

## Release safety

Never commit private distribution material such as:

- Android keystore files or passwords;
- Apple signing certificates/private keys;
- provisioning profiles containing private deployment configuration;
- notarization credentials;
- Windows signing private keys;
- store API keys or access tokens.

See [`../RELEASE_QUALIFICATION.md`](../RELEASE_QUALIFICATION.md) before calling any artifact a qualified stable release.