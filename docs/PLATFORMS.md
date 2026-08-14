# Platform Setup and Build Guide

2048 Nova is configured for Android, iOS, Web/PWA, Windows, macOS, and Linux through Flutter. This document separates **repository configuration**, **local development prerequisites**, **automated build verification**, and **distribution signing** so a generated runner is not mistaken for a fully qualified store release.

## Common requirements

All targets require:

- Git;
- a stable Flutter SDK;
- Dart bundled with Flutter;
- project dependencies from `flutter pub get`.

Verify the toolchain:

```bash
flutter --version
flutter doctor -v
flutter devices
```

Clone:

```bash
git clone https://github.com/sanskarIN/2048.git
cd 2048
flutter pub get
```

## Android

### Repository configuration

Android runner files are under `android/`. Branding exports include launcher icons and launch-background assets.

### Development prerequisites

Typical Flutter Android development requires:

- Android Studio or the Android SDK command-line tools;
- compatible Android SDK/build tools;
- an Android emulator or physical device for interactive testing;
- required Android licenses accepted through the normal Flutter/Android setup.

Check:

```bash
flutter doctor -v
flutter devices
```

Run:

```bash
flutter run -d <android-device-id>
```

Build an unsigned/debug-development-compatible artifact as appropriate, or the repository's release APK command:

```bash
flutter build apk --release
```

### Distribution boundary

A successful CI release APK build does not configure your private production keystore or Play Console release settings. Keep signing keys/passwords outside this public repository.

## iOS

### Repository configuration

The iOS runner is under `ios/`, with bundle identifier configured around `com.sanskarin.nova2048` in the verified project state. App icon/launch assets are generated from project branding.

### Development prerequisites

iOS builds require macOS with Xcode and normal Flutter iOS tooling. Real-device distribution requires an Apple Developer identity, signing certificate, and provisioning configuration.

Check:

```bash
flutter doctor -v
flutter devices
```

Run on a simulator/device when configured:

```bash
flutter run -d <ios-device-id>
```

CI compilation verification uses:

```bash
flutter build ios --release --no-codesign
```

### Distribution boundary

`--no-codesign` proves compilation, not installability or App Store readiness. Do not commit certificates, private keys, or provisioning secrets.

## Web / PWA

### Repository configuration

Web files are under `web/`. Branding includes favicon, standard PWA icons, and maskable icons.

Run locally:

```bash
flutter run -d chrome
```

Build:

```bash
flutter build web --release
```

CI performs the release Web build after formatter, analyzer, and tests.

### Browser qualification

Manual release checks should cover:

- keyboard focus/navigation;
- responsive widths;
- clipboard export/import behavior;
- browser external-link/mail handler behavior;
- large text/reduced motion/high contrast;
- representative screen-reader behavior.

A successful Web build does not guarantee every browser feature/handler behaves identically.

## Windows

### Repository configuration

Windows runner files are under `windows/`. The project includes branded application icon resources.

### Development prerequisites

Use Windows with the Visual Studio desktop C++ tooling required by Flutter Windows development.

Enable/check:

```bash
flutter config --enable-windows-desktop
flutter doctor -v
```

Run:

```bash
flutter run -d windows
```

Build:

```bash
flutter build windows --release
```

### Distribution boundary

CI verifies the release build on a hosted Windows runner. Installer packaging, code signing, store packaging, and real hardware UX remain separate tasks.

## macOS

### Repository configuration

macOS runner files are under `macos/`, including generated/branded app icon assets.

### Development prerequisites

Use macOS with Xcode/Flutter desktop prerequisites.

Enable/check:

```bash
flutter config --enable-macos-desktop
flutter doctor -v
```

Run:

```bash
flutter run -d macos
```

Build:

```bash
flutter build macos --release
```

### Distribution boundary

Hosted CI compilation does not replace Developer ID/App Store signing, notarization, entitlements review, or real-device accessibility checks.

## Linux

### Repository configuration

Linux runner files are under `linux/`. The current application identifier uses a valid GApplication-compatible identifier (`com.sanskarin.nova2048`).

### Development prerequisites

On Debian/Ubuntu-like hosts, Flutter desktop builds typically require GTK development/native build packages. The project's CI installs:

```bash
sudo apt-get update
sudo apt-get install -y ninja-build libgtk-3-dev liblzma-dev
```

Then:

```bash
flutter config --enable-linux-desktop
flutter doctor -v
flutter run -d linux
flutter build linux --release
```

Other distributions should use equivalent packages from their package manager.

## Platform branding

The editable branding source is:

```text
assets/branding/2048_nova_logo.svg
```

Generated exports cover platform launcher/application/PWA/launch assets. See [`BRANDING.md`](BRANDING.md).

## Platform-specific feature notes

### Touch

Primary touch/swipe gameplay is most relevant to Android/iOS and touch-capable environments. Real-device gesture thresholds and orientation behavior require manual testing.

### Keyboard

Arrow/WASD/H/U/P/Escape/R shortcuts are important on Web/Windows/macOS/Linux and should be manually qualified with real focus behavior.

### Sound/haptics

These are optional and depend on platform support. The state of the game does not rely solely on them.

### Clipboard

Game Backup uses Flutter's clipboard APIs. Actual clipboard access, browser policy, and platform messages can differ by environment, so real-platform export/import must be manually checked.

### External links

The application uses platform handlers for browser and email actions. A build passing CI cannot prove that a user's system has a configured handler.

## Automated build matrix

The permanent `Platform Builds` GitHub Actions workflow verifies relevant source/native changes using:

- Ubuntu for Android;
- Ubuntu for Linux;
- Windows for Windows;
- macOS for macOS and unsigned iOS.

See [`CI_CD.md`](CI_CD.md) and [`VERIFICATION.md`](VERIFICATION.md) for current evidence.

## Stable-release qualification

Before calling a target stable/release-ready, complete the applicable items in [`RELEASE_CHECKLIST.md`](RELEASE_CHECKLIST.md), especially:

- physical-device/lifecycle testing;
- screen-reader/focus testing;
- Game Backup clipboard testing;
- Move Replay/Auto Play timer cleanup;
- real external handlers;
- performance/responsive layout;
- signing/provisioning/notarization/store packaging;
- final privacy/listing metadata.
