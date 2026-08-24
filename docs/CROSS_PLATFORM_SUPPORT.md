# Cross-Platform Support Contract

2048 Nova is maintained as one Flutter application targeting **Android, iOS, Web/PWA, Windows, macOS, and Linux**. This document defines what the repository guarantees at source and CI level, how every stable target is built, and which release claims still require real hardware, browser, signing, or store evidence.

## Supported target families

| Target | Repository runner | Maintained release build | CI qualification package |
| --- | --- | --- | --- |
| Android | `android/` | universal APK + split ABI APKs + Android App Bundle | APKs, AAB, SHA-256 checksums |
| iOS | `ios/` | unsigned release app in CI | unsigned app ZIP + SHA-256 checksum |
| Web / PWA | `web/` | Flutter Web release | Web/PWA tarball + SHA-256 checksum |
| Windows | `windows/` | Windows desktop release | x64 ZIP + SHA-256 checksum |
| macOS | `macos/` | macOS desktop release | app ZIP + SHA-256 checksum |
| Linux | `linux/` | Linux desktop release | x64 tarball + SHA-256 checksum |

The platform families above are the complete **stable maintained platform scope for Version 2.0.12**. Android tablets/foldables/resizable windows, iPad, touch-capable desktops, installable web-app experiences, and responsive browser layouts are handled inside those target families rather than as separate source trees.

## Next-release prepared target

A **Browser Extension** target is now prepared for a future release without changing the Version 2.0.12 stable platform contract.

| Prepared target | Shared payload | Package families | Current status |
| --- | --- | --- | --- |
| Browser Extension | Flutter Web build | Chromium (Chrome/Edge-compatible) + Firefox Manifest V3 packages | prepared and CI-packaged; not yet stable-supported |

The extension reuses the same Flutter application, is wrapped by permission-free browser-specific manifests, and has its own qualification workflow. See [`BROWSER_EXTENSION.md`](BROWSER_EXTENSION.md). It must not be promoted into the stable target table until real browser/store qualification is recorded for the intended future release.

## Cross-platform source guarantees

A change is considered source-level cross-platform compatible only when all of the following remain true:

1. all six stable Flutter runner families are present;
2. shared Dart/Flutter source remains analyzer-clean;
3. automated tests remain green;
4. Android universal APK, split-per-ABI APK, and AAB release builds are defined;
5. unsigned iOS release compilation is defined;
6. Web/PWA release compilation and packaging are defined;
7. Windows, macOS, and Linux release builds are defined;
8. the dedicated Platform Builds workflow reacts to changes in every stable platform runner, including `web/**`;
9. every retained CI qualification package has a SHA-256 checksum;
10. the repository-owned platform support audit passes.

Run the stable platform audit locally from the repository root:

```bash
dart run tool/platform_support_audit.dart
```

Machine-readable form:

```bash
dart run tool/platform_support_audit.dart --json
```

Android has an additional production-target audit:

```bash
dart run tool/android_support_audit.dart --json
```

The stable platform audit fails closed if a required runner file, release-build command, Web/PWA qualification package, platform workflow path trigger, or permanent CI invocation is removed. The Android audit adds Android-specific manifest, release-optimization, signing-boundary, and artifact checks.

The prepared extension has a separate non-stable readiness audit:

```bash
dart run tool/browser_extension_audit.dart --json
```

A passing extension audit reports preparation readiness while keeping `stableSupportDeclared` false.

## Build commands

Install dependencies first:

```bash
flutter pub get
```

### Android universal APK

```bash
flutter build apk --release
```

Typical output:

```text
build/app/outputs/flutter-apk/app-release.apk
```

### Android split ABI APKs

```bash
flutter build apk --release --split-per-abi
```

Qualified outputs include:

```text
build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk
build/app/outputs/flutter-apk/app-arm64-v8a-release.apk
build/app/outputs/flutter-apk/app-x86_64-release.apk
```

### Android App Bundle

```bash
flutter build appbundle --release
```

Typical output:

```text
build/app/outputs/bundle/release/app-release.aab
```

The Android release configuration also enables R8 code minification and resource shrinking. See [`ANDROID_SUPPORT.md`](ANDROID_SUPPORT.md) for the full Android device, privacy, signing, and qualification contract.

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

### Browser extension preparation

The extension payload uses a dedicated base path because the generated Flutter application is placed below the extension root:

```bash
flutter build web --release --base-href /app/
dart run tool/package_browser_extension.dart --browser=all --json
```

Generated unpacked packages:

```text
build/browser-extension/chromium/
build/browser-extension/firefox/
```

These are next-release preparation artifacts, not Version 2.0.12 stable-platform artifacts.

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
| Browser Extension preparation | Windows, macOS, or Linux for Flutter web/package generation; target browsers for manual qualification |
| Windows | Windows with Flutter desktop prerequisites and Visual Studio C++ tooling |
| macOS | macOS with Xcode |
| Linux | Linux with Flutter GTK/native prerequisites |

GitHub Actions mirrors the stable-target constraints: Ubuntu builds Android, Web/PWA, and Linux; Windows builds Windows; macOS builds macOS and unsigned iOS. A separate Ubuntu workflow packages the prepared Chromium and Firefox extension ZIPs.

## Shared feature parity

The product architecture intentionally keeps gameplay and most behavior in shared Flutter/Dart code. The maintained feature set is expected to remain available across all six stable targets unless the operating system or browser itself prevents a capability.

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

The browser-extension preparation intentionally packages this same application rather than creating a second gameplay implementation.

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

## Android parity rules

Android is a first-class production target. In addition to shared Flutter behavior, the repository protects:

- Flutter-managed SDK/NDK compatibility;
- Java/Kotlin 17 compilation;
- a resizable activity without a hard orientation lock;
- RTL application support;
- optional touchscreen hardware declaration for non-touch Android environments;
- hardware-accelerated Flutter rendering;
- disabled cleartext traffic;
- disabled Android backup for local game state;
- release R8 code/resource shrinking;
- universal APK, split ABI APK, and AAB qualification;
- signing secrets outside source control.

Physical Android device classes, OEM behavior, production signing, and Play review remain manual qualification boundaries.

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

## Browser-extension preparation rules

The prepared extension must remain:

- Manifest V3;
- split into Chromium and Firefox manifests where browser metadata differs;
- free of broad extension permissions and host permissions unless a future reviewed feature genuinely requires them;
- packaged entirely from repository/local Flutter output rather than remote executable code;
- built from the same Flutter game implementation;
- separately CI-packaged and checksummed;
- explicitly non-stable until manual browser/store evidence exists.

See [`BROWSER_EXTENSION.md`](BROWSER_EXTENSION.md) for the detailed next-release promotion gates.

## Android distribution boundary

The public repository does not contain private Play Store signing credentials. CI may compile release-mode APK/AAB output using non-production signing solely for qualification. Production publication requires a protected keystore and Play Console configuration outside the repository.

## Apple distribution boundary

Unsigned iOS CI output proves release compilation, not App Store installation. Signed iOS distribution requires certificates and provisioning. macOS public distribution can additionally require Developer ID signing, hardened runtime review, notarization, and App Store configuration.

## Desktop distribution boundary

Windows and Linux CI packages are qualification artifacts. A polished public distribution may additionally use an installer/package format and platform signing or repository metadata appropriate to the chosen distribution channel.

## Cross-platform CI matrix

The permanent `.github/workflows/platform-builds.yml` matrix performs:

- Android universal release APK build;
- Android split-per-ABI release APK builds;
- Android release AAB build;
- Web/PWA release build and package validation;
- Linux release build;
- Windows release build;
- macOS release build;
- unsigned iOS release build;
- SHA-256 checksum creation for every retained qualification package.

The general `.github/workflows/ci.yml` workflow separately runs formatting, static analysis, tests, repository/release audits, the stable cross-platform support audit, the Android support audit, the next-release browser-extension readiness audit, and a Web release smoke build.

The separate `.github/workflows/browser-extension.yml` workflow builds the `/app/`-scoped Flutter web payload and packages/checksums Chromium and Firefox preparation ZIPs. It does not alter the Version 2.0.12 stable target count.

## Maintainer verification sequence

For a cross-platform-sensitive change, run the portable checks first:

```bash
flutter pub get
dart format --output=none --set-exit-if-changed lib test tool
flutter analyze
flutter test
dart run tool/platform_support_audit.dart --json
dart run tool/android_support_audit.dart --json
dart run tool/browser_extension_audit.dart --json
flutter build web --release
```

Then require the hosted Platform Builds workflow to compile every stable maintained target family. For extension-sensitive changes, also require the Browser Extension Preparation workflow. Platform-specific release signing and real-device/browser qualification happen after automated compilation succeeds.

## What automated support does not prove

A green cross-platform matrix does **not** prove all of the following without real-environment evidence:

- physical-device gesture feel;
- screen-reader quality;
- browser install/update and optional custom-service-worker lifecycle;
- browser-extension popup/persistence/update behavior in actual target browsers;
- extension-store signing/review/acceptance;
- OS clipboard policy;
- user-selected file picker behavior;
- external browser/mail handlers;
- long-session performance on representative hardware;
- signed iOS installation;
- Android production signing;
- macOS signing/notarization;
- store listing, review, and distribution readiness.

Those are qualification steps rather than missing source-platform support. The release gate must continue to distinguish automated source/build evidence from real-world release evidence.

## Adding or removing a stable platform

The six-target stable list is a maintained Version 2.0.12 contract. A future stable platform change must update together:

- runner/wrapper source;
- build workflow;
- `tool/platform_support_audit.dart`;
- its regression tests;
- this document;
- platform/build documentation;
- release artifacts documentation;
- release qualification expectations where applicable.

The prepared browser extension is intentionally outside that list until a future release completes its promotion gates. When it is promoted, update the stable support contract deliberately rather than merely changing a marketing statement.

Do not silently remove a runner or build job to make CI pass. Fix the compatibility problem or deliberately scope a future release that changes the supported-platform contract.
