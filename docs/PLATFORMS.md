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

Build:

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
- Challenge Code Copy/Paste/manual-entry behavior under browser clipboard policy;
- Game Backup clipboard export/import behavior;
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

Challenge Codes also rely on normal keyboard focus/editing behavior for dropdowns, multiline code entry, selectable generated text, and replacement dialogs.

### Sound/haptics

These are optional and depend on platform support. The state of the game does not rely solely on them.

### Clipboard

Both **Challenge Codes** and **Game Backup** use Flutter's clipboard APIs through the shared `TextClipboard` boundary.

Challenge Codes:

- Copy writes a generated `NOVA1...` code only after explicit action;
- Paste reads text only after explicit action;
- manual text entry remains available when clipboard access is unavailable/restricted.

Game Backup similarly uses explicit copy/import actions for current-game JSON.

Actual clipboard access, browser permission policy, OS clipboard history, cross-device clipboard behavior, and platform messages can differ by environment. Real-platform testing is required even when widget tests and native compilation are green.

### Deterministic Challenge Code comparison

To qualify a platform implementation manually, use the same Challenge Code on at least two independent runs/devices and verify:

1. decoded configuration/seed match;
2. opening board and RNG-derived behavior match;
3. identical valid move sequences remain deterministic;
4. different moves are allowed to diverge naturally;
5. Daily mode cannot be opened through arbitrary Challenge Code text.

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
- Challenge Code clipboard/manual-entry/determinism testing;
- Game Backup clipboard testing;
- Move Replay/Auto Play timer cleanup;
- real external handlers;
- performance/responsive layout;
- signing/provisioning/notarization/store packaging;
- final privacy/listing metadata.

## Locale behavior across platforms

The application registers English (`en`) and Hindi (`hi`) for Android, iOS, Web, Windows, macOS, and Linux Flutter builds. **System default** follows a supported platform locale; unsupported locales fall back to English. Explicit English/Hindi selection overrides the system locale through `MaterialApp.locale`.

Hosted compilation verifies the code path can build for configured targets, but real platform font rendering, large-text wrapping, IME/input behavior, clipboard dialogs, and screen-reader pronunciation in Hindi remain manual release checks.


## Phase 17 current-source hosted build matrix

The Phase 17 hosted native-build evidence was Platform Builds run `31867788753` on commit `d33d65840aff67c4e9bf69ad203f46b85146093c`. All configured native targets completed successfully: Android release APK (`94971490848`), Linux release (`94971490809`), Windows release (`94971490788`), macOS release and unsigned iOS release (`94971490875`).

This run was intentionally triggered after the final Phase 17 per-mode-record parser correction so it verifies the complete current runtime source rather than an earlier partial Phase 17 snapshot. These hosted builds demonstrate compile/package success only; physical-device behavior, signed iOS distribution, accessibility, lifecycle, and store qualification remain manual release requirements.


## Phase 18 current runtime hosted build matrix

The latest hosted native-build evidence is Platform Builds run `31869794809` on runtime commit `e324882fc861e9e4221020aabb00515c7366a6f7`. All configured native targets completed successfully:

- Android release APK — job `94976574376`;
- Linux release — job `94976574317`;
- Windows release — job `94976574323`;
- macOS release — job `94976574495`;
- unsigned iOS release — job `94976574495`.

The later final CI commit `b114255b6f510f0e7ba8d0516e9a30eebf4451b8` changes only a test import and does not alter runtime application source, so this matrix covers the accepted Phase 18 runtime tree. It supersedes the Phase 17 matrix as the latest hosted native compilation evidence.

Hosted builds demonstrate compilation/package success only; physical-device behavior, expectimax responsiveness on representative slower devices, accessibility/focus, signed iOS distribution, signing/provisioning, and store qualification remain manual release requirements.

## Full Replay Archive platform behavior

Full Replay Archive uses Flutter clipboard access through the existing `TextClipboard` abstraction. **Copy full replay** writes only after explicit action; **Open from clipboard** reads only after explicit action; manual text entry remains available when clipboard access is restricted. Browser and OS clipboard permission, history, cross-device synchronization, and maximum practical clipboard sizes differ by environment and therefore remain manual platform checks.

Replay reconstruction itself is local Dart and Flutter logic and requires no project server. Hosted compilation can verify that the runtime source builds for configured targets, but it cannot establish real-device responsiveness for long valid captures, platform clipboard UX, screen-reader behavior, or timer cleanup after lifecycle transitions. Those checks remain in `RELEASE_CHECKLIST.md`.

## Phase 20 file picker integration

Game Backup file transport is configured for Android, iOS, Web, Windows, macOS, and Linux through pinned `file_picker 11.0.2` behind `GameBackupFilePort`.

macOS Debug/Profile and Release entitlements enable `com.apple.security.files.user-selected.read-write`. This grants access to files chosen by the user, not arbitrary filesystem traversal.

Web uses the browser's download/file-input behavior; native targets use their platform picker/document-provider behavior. Hosted release builds verify compilation/integration only. Real Save/Open/cancel/round-trip checks remain required on representative targets before stable `1.0.0`.

## Phase 20 final native matrix

`file_picker 11.0.2`, the macOS user-selected read/write entitlement, and the AGP-9 built-in-Kotlin host setting are compiled in the accepted runtime source `188e81c607eca76516018be8c668eab41b777cc1`.

```text
Platform Builds run: 31875447417
Android release APK: PASS - job 94990368847
Linux release: PASS - job 94990368919
Windows release: PASS - job 94990368886
macOS release: PASS - job 94990368933
unsigned iOS release: PASS - job 94990368933
```

The prior run `31875177571` failed Android plugin registration while all other configured native targets passed. Enabling `android.builtInKotlin=true` fixed the AGP-9 host/plugin integration, and the full fresh matrix above is the accepted evidence.

Interactive picker/document-provider/browser behavior remains a real-environment release check rather than a hosted-compilation claim.

## Phase 21 QR platform behavior

Challenge Code QR rendering is a Flutter presentation feature and requires no target-specific camera permission or scanner integration. The same canonical text is rendered on every configured target, with a fixed black-on-white QR surface inside the surrounding themed UI.

Hosted compilation can verify that the dependency and widget compile across configured targets, but it cannot verify physical screen optical scan quality. Real-device/browser qualification remains required for device-to-device scanning, density/brightness/glare, accessibility, and narrow-layout behavior.

## Phase 21 current native matrix

The final Phase 21 runtime source `2678e65824ca088c4ba93342bc8737fc18ec7708` passed the permanent Platform Builds workflow:

```text
Platform Builds run: 31877514960
Android release APK: PASS — job 94995348734
Linux release: PASS — job 94995348682
Windows release: PASS — job 94995348743
macOS release: PASS — job 94995348674
unsigned iOS release: PASS — job 94995348674
```

This verifies that the pinned local QR-rendering dependency compiles across all configured native target families. No camera permission or native QR-scanner integration is introduced. The QR remains a Flutter presentation layer over the existing Challenge Code text.

Native compilation is not optical scan qualification. Representative real displays still need device-to-device scan checks across density, brightness, glare, orientation, surrounding theme, large-text layouts, and screen-reader behavior.
