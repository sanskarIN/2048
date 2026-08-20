# Cross-Platform Support Contract

2048 Nova is maintained as one Flutter application targeting **Android, iOS, Web/PWA, Windows, macOS, and Linux**. This document defines what the repository guarantees at source and CI level, how every target is built, and which release claims still require real hardware, browser, signing, or store evidence.

## Supported target families

| Target | Repository runner | Maintained release build | CI qualification package |
| --- | --- | --- | --- |
| Android | `android/` | APK + Android App Bundle | APK, AAB, SHA-256 checksums |
| iOS | `ios/` | unsigned release app in CI | unsigned app ZIP + SHA-256 checksum |
| Web / PWA | `web/` | Flutter Web release | Web/PWA tarball + SHA-256 checksum |
| Windows | `windows/` | Windows desktop release | x64 ZIP + SHA-256 checksum |
| macOS | `macos/` | macOS desktop release | app ZIP + SHA-256 checksum |
| Linux | `linux/` | Linux desktop release | x64 tarball + SHA-256 checksum |

The platform families above are the complete maintained platform scope for Version 2.0.12. Android tablets, iPad, touch-capable desktops, installable web-app experiences, and responsive browser layouts are handled inside those target families rather than as separate source trees.

## Cross-platform source guarantees

A change is considered source-level cross-platform compatible only when all of the following remain true:

1. all six Flutter runner families are present;
2. shared Dart/Flutter source remains analyzer-clean;
3. automated tests remain green;
4. Android APK and AAB release builds are defined;
5. unsigned iOS release compilation is defined;
6. Web/PWA release compilation and packaging are defined;
7. Windows, macOS, and Linux release builds are defined;
8. the dedicated Platform Builds workflow reacts to changes in every platform runner, including `web/**`;
9. every retained CI qualification package has a SHA-256 checksum;
10. the repository-owned platform support audit passes.

Run the audit locally from the repository root:

```bash
dart run tool/platform_support_audit.dart
```

Machine-readable form:

```bash
dart run tool/platform_support_audit.dart --json
```

The audit fails closed if a required runner file, release-build command, Web/PWA qualification package, platform workflow path trigger, or permanent CI invocation is removed.

## Build commands

Install dependencies first:

```bash
flutter pub get
```

### Android APK

```bash
flutter build apk --release
```

Typical output:

```text
build/app/outputs/flutter-apk/app-release.apk
```

### Android App Bundle

```bash
flutter build appbundle --release
```

Typical output:

```text
build/app/outputs/bundle/release/app-release.aab
```

### iOS

A local signed release requires macOS, Xcode, an Apple Developer identity, and appropriate provisioning. CI verifies compilation without private signing material:

```bash
flutter build ios --release --no-codesign
```

### Web / PWA

```bash
flutter build web --release
```

The dedicated platform workflow verifies that the generated Web release includes the current Flutter bootstrap and application metadata:

```text
build/web/index.html
build/web/manifest.json
build/web/flutter_bootstrap.js
```

It then packages the complete generated `build/web/` tree as:

```text
nova-2048-web-pwa.tar.gz
nova-2048-web-pwa.tar.gz.sha256
```

This keeps Web/PWA at the same checksummed qualification-artifact level as the native targets.

Current Flutter no longer generates or manages a default service worker. A deployment that needs **cold-start offline caching** must deliberately add and qualify a custom service worker using standard Web tooling. The repository therefore does not treat the obsolete generated `flutter_service_worker.js` as a required build output. This avoids tying Web support to removed Flutter behavior while preserving the manifest, icons, responsive application, installable web metadata, and full Web release package.

### Windows

```bash
flutter config --enable-windows-desktop
flutter build windows --release
```

### macOS

```bash
flutter config --enable-macos-desktop
flutter build macos --release
```

### Linux

```bash
flutter config --enable-linux-desktop
flutter build linux --release
```

On Debian/Ubuntu-family hosts, the CI baseline installs:

```bash
sudo apt-get update
sudo apt-get install -y ninja-build libgtk-3-dev liblzma-dev
```

## Host requirements

The target platform and the host used to build it are not always the same thing.

| Target | Typical required build host |
| --- | --- |
| Android | Windows, macOS, or Linux with Android toolchain |
| iOS | macOS with Xcode |
| Web/PWA | Windows, macOS, or Linux |
| Windows | Windows with Flutter desktop prerequisites and Visual Studio C++ tooling |
| macOS | macOS with Xcode |
| Linux | Linux with Flutter GTK/native prerequisites |

GitHub Actions mirrors those constraints: Ubuntu builds Android, Web/PWA, and Linux; Windows builds Windows; macOS builds macOS and unsigned iOS.

## Shared feature parity

The product architecture intentionally keeps gameplay and most behavior in shared Flutter/Dart code. The maintained feature set is expected to remain available across all six targets unless the operating system or browser itself prevents a capability.

Shared features include:

- deterministic 2048 engine and seeded behavior;
- all maintained game modes;
- save/resume and bounded Undo;
- statistics and achievements;
- Daily Challenge;
- Challenge Codes and local QR rendering;
- Game Backup validation and import/export model;
- Move Replay and replay archives;
- Hint and Auto Play Demo logic;
- localization and theme settings;
- responsive layouts;
- keyboard shortcuts where a hardware keyboard is available;
- touch/swipe input where pointer/touch input is available;
- accessibility semantics supplied by the Flutter UI;
- external-link actions through the platform handler;
- local preferences and offline-first gameplay behavior after the application has loaded.

## Platform-dependent behavior

Some features use operating-system or browser services. Cross-platform source support means the app has a maintained code path for them; it does not mean every environment grants identical behavior.

### File picker

Game Backup file transport uses the maintained Flutter file-picker dependency. Native targets use their platform picker/document provider. Web uses browser file-input/download behavior. macOS uses user-selected read/write entitlement access.

### Clipboard

Challenge Codes, backups, and replay text use explicit clipboard actions. Browser permission policy, clipboard history, enterprise policy, and cross-device clipboard behavior are external to the application.

### External URLs and email handlers

The app requests external navigation through the operating system or browser. A user may have no suitable handler installed or may block the request.

### Sound and haptics

Feedback is optional and capability-dependent. Game rules, score, accessibility, and progression never depend only on sound or vibration.

### Keyboard and pointer input

Desktop and Web targets expose keyboard-friendly gameplay. Mobile platforms may also use hardware keyboards. Touch/swipe remains the primary direct-manipulation path on phones and tablets.

## Web/PWA parity rules

Web is a first-class target, not merely a development preview. The repository therefore requires:

- `web/index.html`;
- a valid manifest;
- application icons and installable-web metadata;
- the generated `flutter_bootstrap.js` release bootstrap;
- a dedicated Platform Builds job;
- a retained checksummed Web/PWA artifact;
- the same formatter/analyzer/test gate used by native targets.

Flutter no longer supplies a default service worker, so service-worker presence is not used as a false proxy for Web support. If a deployment requires offline cold start, background caching, or an explicit update strategy, that deployment must add a custom service worker and qualify its caching/update behavior separately.

Installed-web behavior still requires real browser qualification because installation policy, storage eviction, caching, clipboard policy, external handlers, accessibility APIs, and update behavior are browser-controlled.

## Android distribution boundary

The public repository does not contain private Play Store signing credentials. CI may compile a release-mode APK/AAB using non-production signing solely for qualification. Production publication requires a protected keystore and Play Console configuration outside the repository.

## Apple distribution boundary

Unsigned iOS CI output proves release compilation, not App Store installation. Signed iOS distribution requires certificates and provisioning. macOS public distribution can additionally require Developer ID signing, hardened runtime review, notarization, and App Store configuration.

## Desktop distribution boundary

Windows and Linux CI packages are qualification artifacts. A polished public distribution may additionally use an installer/package format and platform signing or repository metadata appropriate to the chosen distribution channel.

## Cross-platform CI matrix

The permanent `.github/workflows/platform-builds.yml` matrix performs:

- Android release APK build;
- Android release AAB build;
- Web/PWA release build and package validation;
- Linux release build;
- Windows release build;
- macOS release build;
- unsigned iOS release build;
- SHA-256 checksum creation for every retained qualification package.

The general `.github/workflows/ci.yml` workflow separately runs formatting, static analysis, tests, repository/release audits, the cross-platform support audit, and a Web release smoke build.

## Maintainer verification sequence

For a cross-platform-sensitive change, run the portable checks first:

```bash
flutter pub get
dart format --output=none --set-exit-if-changed lib test tool
flutter analyze
flutter test
dart run tool/platform_support_audit.dart --json
flutter build web --release
```

Then require the hosted Platform Builds workflow to compile every maintained target family. Platform-specific release signing and real-device qualification happen after automated compilation succeeds.

## What automated support does not prove

A green cross-platform matrix does **not** prove all of the following without real-environment evidence:

- physical-device gesture feel;
- screen-reader quality;
- browser install/update and optional custom-service-worker lifecycle;
- OS clipboard policy;
- user-selected file picker behavior;
- external browser/mail handlers;
- long-session performance on representative hardware;
- signed iOS installation;
- Android production signing;
- macOS signing/notarization;
- store listing, review, and distribution readiness.

Those are qualification steps rather than missing source-platform support. The release gate must continue to distinguish automated source/build evidence from real-world release evidence.

## Adding or removing a platform

The six-target list is a maintained contract. A future platform change must update together:

- runner source;
- build workflow;
- `tool/platform_support_audit.dart`;
- its regression tests;
- this document;
- platform/build documentation;
- release artifacts documentation;
- release qualification expectations where applicable.

Do not silently remove a runner or build job to make CI pass. Fix the compatibility problem or deliberately scope a future release that changes the supported-platform contract.
