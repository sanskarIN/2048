# Building Executables and Distribution Artifacts

This is the master build handbook for **2048 Nova**. It documents how to produce every executable, installable package, application bundle, deployable Web bundle, and CI qualification archive that the current repository supports.

The configured Flutter targets are:

- Android
- iOS
- Web / PWA
- Windows
- macOS
- Linux

For platform-specific detail, use the dedicated guides in [`docs/build/`](build/README.md).

> A successful build proves that the selected source/configuration can produce that artifact on the selected toolchain. It does **not** by itself prove physical-device behavior, accessibility, production signing, provisioning, notarization, store acceptance, long-session behavior, or stable-release qualification.

## 1. Current project baseline

`pubspec.yaml` currently defines:

- package: `nova_2048`
- version: `1.5.0+15`
- Dart: `>=3.9.0 <4.0.0`
- Flutter: `>=3.35.0`

Permanent hosted CI currently uses:

- Flutter **3.47.0**
- Dart supplied by that Flutter SDK
- Android JDK **Temurin 17**
- Android Gradle Plugin **9.1.0**
- Kotlin Android **2.4.10**
- Gradle **9.7.0**

For the closest local reproduction of hosted evidence, use Flutter 3.47.0 and the target-specific prerequisites documented in [`build/HOST_PREREQUISITES.md`](build/HOST_PREREQUISITES.md).

## 2. What the repository can build

| Target | Build command | Primary output | Current repository status |
| --- | --- | --- | --- |
| Android debug APK | `flutter build apk --debug` | `app-debug.apk` | documented local build |
| Android profile APK | `flutter build apk --profile` | `app-profile.apk` | documented local build |
| Android release APK | `flutter build apk --release` | `app-release.apk` | **CI-qualified build path** |
| Android split APKs | `flutter build apk --release --split-per-abi` | ABI-specific APKs | documented local build |
| Android App Bundle | `flutter build appbundle --release` | `app-release.aab` | **CI-qualified build path** |
| iOS unsigned release app | `flutter build ios --release --no-codesign` | `Runner.app` | **CI-qualified build path** |
| iOS signed IPA | `flutter build ipa --release` | `build/ios/ipa/` | documented when Apple signing is configured |
| Web release | `flutter build web --release` | `build/web/` | **CI-qualified build path** |
| Windows release | `flutter build windows --release` | `.exe` + runtime bundle | **CI-qualified build path** |
| macOS release | `flutter build macos --release` | `.app` bundle | **CI-qualified build path** |
| Linux release | `flutter build linux --release` | ELF executable + runtime bundle | **CI-qualified build path** |

See [`build/SUPPORTED_ARTIFACTS.md`](build/SUPPORTED_ARTIFACTS.md) for the explicit supported/not-maintained artifact inventory.

## 3. Host operating-system requirements

Flutter native desktop/mobile builds are not treated as arbitrary cross-compilation targets by this repository.

| Target | Build host |
| --- | --- |
| Android | Windows, macOS, or Linux with Android SDK/JDK |
| iOS | macOS with Xcode |
| Web | Windows, macOS, or Linux |
| Windows | Windows with Visual Studio C++ desktop workload |
| macOS | macOS with Xcode |
| Linux | Linux with GTK/native build dependencies |

Use the repository's GitHub Actions matrix when you do not have every native host locally.

## 4. Clean checkout preparation

From a clean machine or clean working copy:

```bash
git clone https://github.com/sanskarIN/2048.git
cd 2048
flutter --version
flutter doctor -v
flutter pub get
```

For a fresh rebuild:

```bash
flutter clean
flutter pub get
```

Do not delete committed platform runner folders merely to fix a stale build. `flutter clean` removes generated build output while preserving source-controlled runner configuration.

## 5. Quality checks before release builds

Run:

```bash
dart format --output=none --set-exit-if-changed lib test tool
flutter analyze
flutter test --coverage
dart run tool/release_readiness.dart --json
dart run tool/solver_benchmark.dart 8
flutter build web --release
```

Verify dependency metadata did not drift unexpectedly:

```bash
git diff --exit-code -- pubspec.lock analysis_options.yaml
```

The strict stable gate is intentionally expected to fail while real-world evidence is incomplete:

```bash
dart run tool/release_readiness.dart --stable --json
```

Do not weaken that gate simply to publish a binary.

# Android

## 6. Android debug APK

```bash
flutter build apk --debug
```

Output:

```text
build/app/outputs/flutter-apk/app-debug.apk
```

Use only for development/debugging.

## 7. Android profile APK

```bash
flutter build apk --profile
```

Output:

```text
build/app/outputs/flutter-apk/app-profile.apk
```

Use for supported performance investigation, not public release.

## 8. Android universal release APK

```bash
flutter build apk --release
```

Output:

```text
build/app/outputs/flutter-apk/app-release.apk
```

This artifact can be directly installed/sideloaded on compatible Android devices.

### SHA-256

Linux:

```bash
sha256sum build/app/outputs/flutter-apk/app-release.apk \
  > build/app/outputs/flutter-apk/app-release.apk.sha256
```

PowerShell:

```powershell
$path = "build/app/outputs/flutter-apk/app-release.apk"
$hash = (Get-FileHash $path -Algorithm SHA256).Hash.ToLower()
"$hash  app-release.apk" | Out-File -Encoding ascii "$path.sha256"
```

## 9. Android ABI-split release APKs

```bash
flutter build apk --release --split-per-abi
```

Outputs are written under:

```text
build/app/outputs/flutter-apk/
```

Use split APKs only when your distribution process knows which ABI each user/device needs. Inspect the generated filenames rather than assuming a fixed architecture list forever.

## 10. Android App Bundle (AAB)

```bash
flutter build appbundle --release
```

Output:

```text
build/app/outputs/bundle/release/app-release.aab
```

An AAB is a store publishing bundle. It is not normally installed directly by tapping the file on a device; a store/bundle tool derives device-specific APKs from it.

### SHA-256

Linux:

```bash
sha256sum build/app/outputs/bundle/release/app-release.aab \
  > build/app/outputs/bundle/release/app-release.aab.sha256
```

PowerShell:

```powershell
$path = "build/app/outputs/bundle/release/app-release.aab"
$hash = (Get-FileHash $path -Algorithm SHA256).Hash.ToLower()
"$hash  app-release.aab" | Out-File -Encoding ascii "$path.sha256"
```

## 11. Android signing state

The tracked `android/app/build.gradle.kts` deliberately maps `release` to the **debug signing configuration** for public hosted qualification. Therefore the hosted release APK/AAB prove optimized release compilation and packaging, but they are **not production Play signing identities**.

For production Android distribution:

1. create/use a private upload/signing key;
2. keep keystore files and passwords outside Git;
3. configure a production signing path securely;
4. rebuild APK/AAB from the exact intended release commit;
5. re-run tests and real-device qualification against the production-signed artifact;
6. record its checksum and release evidence.

Never commit private keystores, passwords, aliases, signing certificates, or store credentials.

See [`build/ANDROID.md`](build/ANDROID.md) and [`build/SIGNING_AND_DISTRIBUTION.md`](build/SIGNING_AND_DISTRIBUTION.md).

# iOS

## 12. Unsigned iOS release application

Requires macOS + Xcode.

```bash
flutter build ios --release --no-codesign
```

Expected output location:

```text
build/ios/iphoneos/Runner.app
```

The repository CI packages this unsigned `.app` only as compilation/qualification input. It is not an App Store-ready IPA.

## 13. Signed/exported IPA

After Apple signing/provisioning is correctly configured:

```bash
flutter build ipa --release
```

Output directory:

```text
build/ios/ipa/
```

The exact exported IPA name can depend on the Apple/Xcode export configuration.

A signed iOS release requires external Apple signing/provisioning material. Never commit private certificates, private keys, provisioning secrets, App Store Connect keys, or authentication tokens.

# Web / PWA

## 14. Web release

```bash
flutter build web --release
```

Output:

```text
build/web/
```

Web does not produce a traditional `.exe`. Deploy the **entire** generated directory.

Do not distribute only `index.html`; generated JavaScript/Wasm assets, Flutter bootstrap files, icons, manifests, and other assets must remain together.

For the repository's optional Wasm-oriented path, see [`build/WEB.md`](build/WEB.md).

# Windows

## 15. Windows native release

Requires Windows with Flutter's Visual Studio C++ desktop prerequisites.

```powershell
flutter config --enable-windows-desktop
flutter pub get
flutter build windows --release
```

Current output directory:

```text
build/windows/x64/runner/Release/
```

Current main binary:

```text
nova_2048.exe
```

**Do not distribute only the EXE.** The generated release directory contains required Flutter/runtime DLLs and application data.

Repository CI packages the complete directory as:

```text
nova-2048-windows-x64.zip
nova-2048-windows-x64.zip.sha256
```

MSI/MSIX/third-party installer creation is not currently a maintained project output. If added later, it requires its own reproducible packaging, signing, testing, and documentation.

# macOS

## 16. macOS release application

Requires macOS + Xcode.

```bash
flutter config --enable-macos-desktop
flutter pub get
flutter build macos --release
```

Current expected product:

```text
build/macos/Build/Products/Release/2048 Nova.app
```

The `.app` is a directory bundle even though Finder presents it as one application. Preserve the bundle structure.

Repository CI packages it with `ditto` as:

```text
nova-2048-macos-release.zip
nova-2048-macos-release.zip.sha256
```

DMG/PKG creation, Developer ID signing, notarization, and Mac App Store packaging are separate distribution concerns and are not currently automated repository outputs.

# Linux

## 17. Linux native release

The hosted Ubuntu baseline installs:

```bash
sudo apt-get update
sudo apt-get install -y ninja-build libgtk-3-dev liblzma-dev
```

Then:

```bash
flutter config --enable-linux-desktop
flutter pub get
flutter build linux --release
```

Current output bundle:

```text
build/linux/x64/release/bundle/
```

Current main executable:

```text
nova_2048
```

**Do not distribute only the ELF executable.** Keep the generated libraries and data with it.

Repository CI packages the complete bundle as:

```text
nova-2048-linux-x64.tar.gz
nova-2048-linux-x64.tar.gz.sha256
```

`.deb`, `.rpm`, AppImage, Snap, and Flatpak are not currently maintained project outputs.

# CI and qualification artifacts

## 18. Permanent quality CI

`.github/workflows/ci.yml` verifies:

- dependency/metadata synchronization;
- formatting;
- analyzer;
- tests with coverage;
- candidate release readiness;
- fail-closed stable gate behavior;
- deterministic solver benchmark;
- Web release build.

## 19. Native Platform Builds

`.github/workflows/platform-builds.yml` builds native release outputs on native hosted runners.

Current uploaded qualification artifacts are:

```text
nova-2048-android-release
  app-release.apk
  app-release.apk.sha256
  app-release.aab
  app-release.aab.sha256

nova-2048-linux-x64-release
  nova-2048-linux-x64.tar.gz
  nova-2048-linux-x64.tar.gz.sha256

nova-2048-windows-x64-release
  nova-2048-windows-x64.zip
  nova-2048-windows-x64.zip.sha256

nova-2048-macos-release
  nova-2048-macos-release.zip
  nova-2048-macos-release.zip.sha256

nova-2048-ios-unsigned-release
  nova-2048-ios-unsigned-release.zip
  nova-2048-ios-unsigned-release.zip.sha256
```

These are retained for a bounded period as qualification inputs. They are not proof of real-device/store acceptance.

See [`RELEASE_ARTIFACTS.md`](RELEASE_ARTIFACTS.md) and [`build/CI_PARITY.md`](build/CI_PARITY.md).

# Versioning

## 20. Build name and build number

Current source metadata:

```yaml
version: 1.5.0+15
```

- `1.5.0` = build/release name
- `15` = build number/version code input

Flutter supports build-time overrides for relevant targets, for example:

```bash
flutter build apk --release --build-name=1.5.0 --build-number=15
flutter build appbundle --release --build-name=1.5.0 --build-number=15
```

For official repository releases, keep `pubspec.yaml`, changelog, release evidence, documentation, and the intended tag aligned instead of relying on a one-off local override.

# Packaging integrity

## 21. Verify checksums

Linux:

```bash
sha256sum -c artifact.sha256
```

macOS:

```bash
shasum -a 256 -c artifact.sha256
```

PowerShell:

```powershell
Get-FileHash .\artifact-file -Algorithm SHA256
```

A SHA-256 checksum detects unexpected file changes/corruption. It is **not** a digital signature and does not prove publisher identity.

# Troubleshooting

## 22. First diagnostic sequence

```bash
flutter --version
flutter doctor -v
flutter clean
flutter pub get
dart format --output=none --set-exit-if-changed lib test tool
flutter analyze
flutter test
```

Then run only the target build that is failing.

Useful guides:

- [`build/BUILD_TROUBLESHOOTING.md`](build/BUILD_TROUBLESHOOTING.md)
- [`TROUBLESHOOTING.md`](TROUBLESHOOTING.md)
- [`ANDROID_TOOLCHAIN.md`](ANDROID_TOOLCHAIN.md)
- [`build/HOST_PREREQUISITES.md`](build/HOST_PREREQUISITES.md)
- [`build/OUTPUT_PATHS.md`](build/OUTPUT_PATHS.md)
- [`build/PACKAGING_AND_CHECKSUMS.md`](build/PACKAGING_AND_CHECKSUMS.md)

Do not fix build failures by disabling analyzer/lints, release-readiness safeguards, signing checks, or dependency-integrity checks merely to obtain an artifact.

# Final release procedure

## 23. Recommended order

1. Start from the exact intended release commit.
2. Confirm a clean worktree.
3. Confirm Flutter/toolchain versions.
4. Run `flutter pub get` and inspect any generated-file drift.
5. Run formatter, analyzer, and all tests.
6. Run candidate release-readiness verification.
7. Build Web release.
8. Build the intended native/store artifact.
9. Package the **complete** runtime bundle where the platform requires multiple files.
10. Generate and verify SHA-256.
11. Test the exact built artifact on representative real targets.
12. Perform accessibility, lifecycle, long-session, file/clipboard/handler, branding, and platform-specific checks.
13. Configure production signing/provisioning outside Git.
14. Rebuild and re-test the exact production-signed artifact when signing changes the package.
15. Record truthful real-world evidence.
16. Run `dart run tool/release_readiness.dart --stable --json` on the exact intended release commit.
17. Only after the stable gate passes should a qualified stable release be tagged/published.

## 24. What a green build still does not prove

Hosted/local build success does not replace:

- physical Android/iOS lifecycle testing;
- real touch, orientation, keyboard, focus, and responsive-layout checks;
- TalkBack, VoiceOver, Narrator, or browser screen-reader qualification;
- Hindi pronunciation/layout checks;
- long-session Daily/Timed/Move Limit/Undo testing;
- Challenge Code QR/copy/paste cross-device qualification;
- Replay and Backup real-handler qualification;
- browser/email/file-provider/clipboard handler checks;
- native launcher icon/splash review;
- Android/iOS production signing/provisioning;
- macOS notarization when used;
- Windows publisher signing when used;
- store listing/declaration/acceptance review.

Those remain tracked by `docs/release_qualification.json` and [`RELEASE_QUALIFICATION.md`](RELEASE_QUALIFICATION.md).

# Detailed platform documentation

- [`build/ANDROID.md`](build/ANDROID.md)
- [`build/IOS.md`](build/IOS.md)
- [`build/WEB.md`](build/WEB.md)
- [`build/WINDOWS.md`](build/WINDOWS.md)
- [`build/MACOS.md`](build/MACOS.md)
- [`build/LINUX.md`](build/LINUX.md)
- [`build/HOST_PREREQUISITES.md`](build/HOST_PREREQUISITES.md)
- [`build/QUICK_COMMANDS.md`](build/QUICK_COMMANDS.md)
- [`build/OUTPUT_PATHS.md`](build/OUTPUT_PATHS.md)
- [`build/SUPPORTED_ARTIFACTS.md`](build/SUPPORTED_ARTIFACTS.md)
- [`build/CI_PARITY.md`](build/CI_PARITY.md)
- [`build/PACKAGING_AND_CHECKSUMS.md`](build/PACKAGING_AND_CHECKSUMS.md)
- [`build/SIGNING_AND_DISTRIBUTION.md`](build/SIGNING_AND_DISTRIBUTION.md)
- [`build/RELEASE_BUILD_CHECKLIST.md`](build/RELEASE_BUILD_CHECKLIST.md)
