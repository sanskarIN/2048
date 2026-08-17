# Building Executables and Distribution Artifacts

This is the master build handbook for **2048 Nova**. It explains how to build every platform currently configured in this repository and distinguishes runnable executables, installable packages, deployable bundles, CI qualification archives, and store/distribution packages.

The repository supports Flutter targets for:

- Android
- iOS
- Web / PWA
- Windows
- macOS
- Linux

For platform-specific detail, use the dedicated guides in [`docs/build/`](build/README.md).

> A successful local or hosted build proves compilation/package generation for that configuration. It does not by itself prove physical-device behavior, store acceptance, signing/provisioning, notarization, accessibility, external-handler behavior, or stable-release qualification.

## Current project baseline

The package metadata in `pubspec.yaml` currently defines:

- package: `nova_2048`
- application version: `1.5.0+15`
- Dart floor: `>=3.9.0 <4.0.0`
- Flutter floor: `>=3.35.0`

Permanent CI currently freezes Flutter **3.47.0** for reproducible hosted verification. Android hosted builds use Temurin **JDK 17**. The maintained Android toolchain baseline is documented in [`ANDROID_TOOLCHAIN.md`](ANDROID_TOOLCHAIN.md).

For the closest local reproduction of current hosted evidence, use Flutter 3.47.0 and the target-specific toolchain described below.

## Artifact matrix

| Target | Primary command | Main output | Artifact kind | Host required |
| --- | --- | --- | --- | --- |
| Android debug APK | `flutter build apk --debug` | `build/app/outputs/flutter-apk/app-debug.apk` | Installable APK | Windows/macOS/Linux with Android SDK |
| Android profile APK | `flutter build apk --profile` | `build/app/outputs/flutter-apk/app-profile.apk` | Installable/profile APK | Windows/macOS/Linux with Android SDK |
| Android release APK | `flutter build apk --release` | `build/app/outputs/flutter-apk/app-release.apk` | Release APK | Windows/macOS/Linux with Android SDK |
| Android split APKs | `flutter build apk --release --split-per-abi` | `build/app/outputs/flutter-apk/` | ABI-specific APKs | Windows/macOS/Linux with Android SDK |
| Android App Bundle | `flutter build appbundle --release` | `build/app/outputs/bundle/release/app-release.aab` | Play distribution bundle | Windows/macOS/Linux with Android SDK |
| iOS unsigned app | `flutter build ios --release --no-codesign` | `build/ios/iphoneos/Runner.app` | Unsigned iOS app bundle | macOS + Xcode |
| iOS signed IPA | `flutter build ipa --release` | `build/ios/ipa/` | Signed/exported IPA when signing is configured | macOS + Xcode + Apple signing |
| Web release | `flutter build web --release` | `build/web/` | Deployable static Web/PWA bundle | Windows/macOS/Linux |
| Windows release | `flutter build windows --release` | `build/windows/x64/runner/Release/` | Native EXE plus required runtime files | Windows + Visual Studio C++ workload |
| macOS release | `flutter build macos --release` | `build/macos/Build/Products/Release/*.app` | macOS `.app` bundle | macOS + Xcode |
| Linux release | `flutter build linux --release` | `build/linux/x64/release/bundle/` | Native Linux executable plus libraries/data | Linux + GTK/native toolchain |

The exact output names can vary if Flutter changes generated runner naming or a platform configuration is deliberately renamed. Always inspect the generated output directory after a toolchain upgrade.

## Build modes

Flutter commonly supports three build modes:

### Debug

Use for development and local debugging. Debug builds include debugging support and are not intended for public release.

```bash
flutter run
flutter build apk --debug
```

### Profile

Use for performance analysis on supported targets. Profile builds are not final public-release packages.

```bash
flutter build apk --profile
```

### Release

Use for optimized distribution/qualification artifacts.

```bash
flutter build apk --release
flutter build web --release
flutter build windows --release
flutter build macos --release
flutter build linux --release
flutter build ios --release --no-codesign
```

## Clean checkout build procedure

For release troubleshooting and reproducibility, prefer a clean checkout rather than relying on old generated files.

```bash
git clone https://github.com/sanskarIN/2048.git
cd 2048
flutter --version
flutter doctor -v
flutter pub get
```

Before a fresh rebuild:

```bash
flutter clean
flutter pub get
```

Then run the platform command from this guide.

Do not routinely delete committed platform runner files. `flutter clean` removes generated build outputs, not the source runner configuration.

## Pre-build verification

Before producing a release artifact, run the repository quality checks:

```bash
dart format --output=none --set-exit-if-changed lib test tool
flutter analyze
flutter test
```

For Web parity with permanent CI:

```bash
flutter build web --release
```

For candidate release metadata:

```bash
dart run tool/release_readiness.dart --json
```

For a stable release candidate only after all manual qualification is complete:

```bash
dart run tool/release_readiness.dart --stable --json
```

The strict stable command is intentionally expected to fail while required manual evidence remains pending.

## Dependency integrity

Install dependencies with:

```bash
flutter pub get
```

Then verify the lockfile did not drift unexpectedly:

```bash
git diff --exit-code -- pubspec.lock
```

Platform builds can update generated plugin registration files. If a build modifies tracked generated files, inspect the diff instead of silently discarding or committing it.

## Platform guides

- [`build/ANDROID.md`](build/ANDROID.md) — APKs, split APKs, AAB, Android signing boundaries, installation, checksum, and troubleshooting.
- [`build/IOS.md`](build/IOS.md) — simulator/device concepts, unsigned `.app`, signed archive/IPA, provisioning, export boundaries, and verification.
- [`build/WEB.md`](build/WEB.md) — release Web bundle, local serving, base path, PWA/static hosting, compression, and deployment checks.
- [`build/WINDOWS.md`](build/WINDOWS.md) — native `.exe` bundle, required adjacent files, ZIP packaging, signing/installer boundary, and verification.
- [`build/MACOS.md`](build/MACOS.md) — `.app` bundle, ZIP packaging, signing/notarization boundary, and verification.
- [`build/LINUX.md`](build/LINUX.md) — ELF executable bundle, native prerequisites, tarball packaging, permissions, and verification.
- [`build/PACKAGING_AND_CHECKSUMS.md`](build/PACKAGING_AND_CHECKSUMS.md) — repository-compatible packaging and SHA-256 verification for all hosted qualification artifacts.

## Android artifact choices

Use **APK** when you need a directly installable Android package for testing, sideloading, or a distribution channel that accepts APKs.

Use **split APKs** when you explicitly want smaller architecture-specific packages. Each split is usable only on a compatible ABI.

Use **AAB** for Google Play-style store distribution. An AAB is not normally installed directly like an APK; a store or bundle tooling produces device-specific APKs from it.

The current hosted `Platform Builds` workflow qualifies a release APK and stores its SHA-256 sidecar. It does not currently publish an AAB as a permanent CI qualification artifact.

## Apple artifact choices

The repository's hosted Apple workflow intentionally builds:

```bash
flutter build macos --release
flutter build ios --release --no-codesign
```

The iOS result is an **unsigned `Runner.app` qualification build**, zipped by CI. It is not an App Store-ready IPA.

A distributable iOS IPA requires an Apple Developer signing/provisioning configuration and an export flow such as:

```bash
flutter build ipa --release
```

Never commit signing certificates, private keys, provisioning profiles, App Store credentials, or secret export material to this public repository.

## Desktop artifact choices

### Windows

`flutter build windows --release` produces a release directory containing the main `.exe` plus Flutter/runtime DLLs and application data. **Do not distribute only the `.exe`**; keep the generated release directory together unless you build a proper installer/package that includes every required runtime file.

### macOS

`flutter build macos --release` produces a `.app` bundle. A `.app` is a directory bundle even though Finder presents it as one application. Preserve the bundle structure when zipping, signing, notarizing, or distributing it.

### Linux

`flutter build linux --release` produces a `bundle/` directory containing the native executable plus libraries and data. **Do not copy only the executable** unless you have independently packaged all required shared libraries/data and verified the result.

## Web artifact choice

Web does not produce a traditional `.exe`. `flutter build web --release` produces the complete static deployment directory under `build/web/`.

Deploy the **contents of the generated Web directory together**. Do not copy only `index.html` or only the generated JavaScript/WASM-related assets.

## Repository CI artifact parity

`.github/workflows/platform-builds.yml` currently creates these short-lived qualification artifacts:

- `nova-2048-android-release` — release APK + SHA-256
- `nova-2048-linux-x64-release` — `nova-2048-linux-x64.tar.gz` + SHA-256
- `nova-2048-windows-x64-release` — `nova-2048-windows-x64.zip` + SHA-256
- `nova-2048-macos-release` — zipped `.app` + SHA-256
- `nova-2048-ios-unsigned-release` — zipped unsigned iOS `.app` + SHA-256

These are retained temporarily as qualification inputs. See [`RELEASE_ARTIFACTS.md`](RELEASE_ARTIFACTS.md).

## Build number and version

The Flutter version is declared in `pubspec.yaml`:

```yaml
version: 1.5.0+15
```

The semantic version is before `+`; the build number is after `+`.

You can also override values for a build without editing the file when the target/toolchain supports Flutter's standard flags:

```bash
flutter build apk --release --build-name=1.5.0 --build-number=15
flutter build appbundle --release --build-name=1.5.0 --build-number=15
```

For official repository releases, keep source metadata, release notes, changelog, evidence manifest, and the intended tag aligned rather than relying on a one-off local override.

## Checksums

A SHA-256 checksum helps detect accidental corruption or unexpected artifact replacement after packaging. It is not a code-signing identity and does not prove who authored the artifact.

Linux:

```bash
sha256sum artifact-file
```

macOS:

```bash
shasum -a 256 artifact-file
```

PowerShell:

```powershell
Get-FileHash .\artifact-file -Algorithm SHA256
```

Repository-compatible packaging/checksum commands are in [`build/PACKAGING_AND_CHECKSUMS.md`](build/PACKAGING_AND_CHECKSUMS.md).

## Signing and secrets

Keep all private signing material outside Git:

- Android keystores and passwords
- Apple certificates/private keys
- Apple provisioning profiles
- notarization credentials
- Windows code-signing certificates/private keys
- store API keys/tokens

Use secure local secret storage or protected CI secrets when signing is eventually automated.

## What a successful build does not prove

A green build does not replace:

- real Android/iOS lifecycle testing;
- real touch/orientation/keyboard/focus testing;
- TalkBack/VoiceOver/Narrator/browser screen-reader qualification;
- Hindi pronunciation/layout checks;
- long-session Daily/Timed/Move Limit/Undo testing;
- Challenge Code cross-device QR/copy/paste qualification;
- Replay/Backup real-handler qualification;
- browser/email/file-provider handler checks;
- launcher icon/splash review;
- distribution signing/provisioning/store metadata review.

These remain tracked in `docs/release_qualification.json` and [`RELEASE_QUALIFICATION.md`](RELEASE_QUALIFICATION.md).

## Recommended release build order

1. Start from the exact candidate commit.
2. Confirm a clean worktree.
3. Run `flutter pub get` and verify lockfile integrity.
4. Run formatter, analyzer, and tests.
5. Run candidate release-readiness metadata checks.
6. Build Web release.
7. Build the target's native release artifact.
8. Package the complete required runtime bundle.
9. Generate SHA-256.
10. Verify the checksum from the packaged artifact.
11. Test on representative real targets.
12. Record real qualification evidence.
13. Configure signing/provisioning outside the repository.
14. Re-run strict stable readiness on the exact intended release commit.
15. Only then tag/publish the stable release.

## Troubleshooting entry points

If a build fails:

```bash
flutter doctor -v
flutter clean
flutter pub get
flutter analyze
flutter test
```

Then consult:

- [`TROUBLESHOOTING.md`](TROUBLESHOOTING.md)
- [`PLATFORMS.md`](PLATFORMS.md)
- [`ANDROID_TOOLCHAIN.md`](ANDROID_TOOLCHAIN.md) for Android Gradle/JDK issues
- [`CI_CD.md`](CI_CD.md) for hosted workflow parity
- [`VERIFICATION.md`](VERIFICATION.md) for current accepted evidence

Do not "fix" release failures by disabling linting, validation, signing checks, dependency integrity checks, or release-readiness safeguards merely to obtain an artifact.