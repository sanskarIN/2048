# Android Build Guide

This guide covers every Android artifact type that is practical for the current 2048 Nova Flutter project: debug APK, profile APK, release APK, ABI-split release APKs, and release Android App Bundle (`.aab`).

## Repository baseline

The current Version 1.5 Android baseline is intentionally maintained as:

- Flutter hosted CI: **3.47.0**
- JDK hosted CI: **Temurin 17**
- Android Gradle Plugin: **9.1.0**
- Kotlin Android: **2.4.10**
- Gradle: **9.7.0**

Do not casually upgrade these as independent values. See [`../ANDROID_TOOLCHAIN.md`](../ANDROID_TOOLCHAIN.md) and GitHub issue #10 for the AGP 9.3.x deferral evidence.

## Prerequisites

Install:

- Flutter SDK;
- Android SDK and platform/build tools;
- JDK compatible with the maintained Android toolchain;
- Android licenses;
- optional emulator or physical device for installation/testing.

Verify:

```bash
flutter --version
java -version
flutter doctor -v
flutter devices
```

Install project dependencies:

```bash
flutter pub get
```

## Debug APK

Build:

```bash
flutter build apk --debug
```

Expected output:

```text
build/app/outputs/flutter-apk/app-debug.apk
```

Use a debug APK only for development/debugging. It is larger/slower and should not be presented as the production release artifact.

## Profile APK

Build:

```bash
flutter build apk --profile
```

Expected output:

```text
build/app/outputs/flutter-apk/app-profile.apk
```

Profile mode is intended for performance investigation on supported hardware. Do not treat it as the public release package.

## Release APK

Build:

```bash
flutter build apk --release
```

Expected output:

```text
build/app/outputs/flutter-apk/app-release.apk
```

This is the Android artifact currently built by `.github/workflows/platform-builds.yml` for hosted qualification.

### CI-compatible checksum

On Linux:

```bash
sha256sum build/app/outputs/flutter-apk/app-release.apk \
  > build/app/outputs/flutter-apk/app-release.apk.sha256
```

Verify later with:

```bash
sha256sum -c build/app/outputs/flutter-apk/app-release.apk.sha256
```

## ABI-split release APKs

Build smaller architecture-specific APKs with:

```bash
flutter build apk --release --split-per-abi
```

Inspect:

```text
build/app/outputs/flutter-apk/
```

Typical Flutter outputs include architecture-specific APKs for the configured Android target ABIs, such as ARM 32-bit, ARM 64-bit, and x86-64. Exact filenames/architectures should be read from the generated directory because Flutter/toolchain defaults can evolve.

### When to use split APKs

Use split APKs when:

- you control which ABI each package is delivered to;
- a distribution service accepts separate APKs;
- you want smaller per-device downloads.

Do not send one architecture-specific APK to users whose devices may require another ABI.

## Release Android App Bundle (AAB)

Build:

```bash
flutter build appbundle --release
```

Expected output:

```text
build/app/outputs/bundle/release/app-release.aab
```

Use an AAB for Google Play-style distribution. An AAB is a publishing bundle from which device-specific APKs are generated; it is not normally installed directly by tapping it on a device.

### AAB checksum

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

## Clean rebuild

When diagnosing stale Android outputs:

```bash
flutter clean
flutter pub get
flutter build apk --release
```

If Gradle/toolchain state is suspected, inspect `flutter doctor -v`, `java -version`, Gradle/AGP/Kotlin versions, and the repository's Android toolchain documentation before deleting or regenerating runner configuration.

## Installing an APK for testing

With a connected device recognized by Android tooling, a generated APK may be installed using standard Android/ADB workflows. For normal Flutter development, the simplest route is often:

```bash
flutter run -d <android-device-id>
```

For release qualification, install the exact release artifact intended for testing rather than assuming a debug run proves release behavior.

## Version overrides

Source version is defined in `pubspec.yaml`. Flutter also supports build-time overrides:

```bash
flutter build apk --release --build-name=1.5.0 --build-number=15
flutter build appbundle --release --build-name=1.5.0 --build-number=15
```

For official project releases, update and validate repository metadata instead of relying only on local command-line overrides.

## Signing boundary

A locally generated release artifact is not automatically equivalent to a production-signed Play release.

Production Android distribution may require:

- a private upload/signing key;
- Gradle signing configuration or store-managed app signing;
- secure passwords/aliases;
- Play Console application/listing configuration.

Never commit a private keystore, keystore password, key password, or secret signing property file to this public repository.

The repository's hosted qualification workflow intentionally avoids pretending that CI compilation supplies your private production identity.

## Play Store preparation boundary

Before store publication, separately verify:

- package/application ID;
- app version/build number;
- min/target SDK requirements;
- launcher icon and splash presentation;
- signing/upload key configuration;
- privacy/store declarations;
- screenshots/listing text;
- physical-device lifecycle and save/resume;
- TalkBack/accessibility behavior;
- Challenge Code QR/copy/paste behavior;
- Backup/file-provider behavior.

See `docs/release_qualification.json` and [`../RELEASE_QUALIFICATION.md`](../RELEASE_QUALIFICATION.md).

## Common failures

### Android SDK/license missing

Run:

```bash
flutter doctor -v
```

Resolve the Android toolchain items Flutter reports before retrying.

### Wrong Java runtime

Check:

```bash
java -version
flutter doctor -v
```

Current hosted Android qualification uses Temurin JDK 17. Do not switch the project baseline merely to hide a Gradle/lint failure without updating and validating the documented toolchain policy.

### Gradle/AGP/Kotlin failure

Consult [`../ANDROID_TOOLCHAIN.md`](../ANDROID_TOOLCHAIN.md). The project has explicit regression coverage around its accepted Android versions.

### Build succeeds but installation fails

Check the target device architecture, Android version, signing state, existing installed package/signature, available storage, and whether you built an ABI-specific APK incompatible with the device.

## Release verification checklist

Before distributing an Android artifact:

1. `flutter pub get` completes without unintended lockfile drift.
2. Formatter/analyzer/tests pass.
3. `flutter build apk --release` or `flutter build appbundle --release` succeeds.
4. SHA-256 is generated and verified for the packaged artifact.
5. Exact release artifact is installed/tested on representative physical Android devices.
6. Lifecycle, background/foreground, save/resume, orientation, gestures, and long-session behavior are tested.
7. TalkBack/large-text/Hindi behavior is checked.
8. Native icon/splash appearance is reviewed.
9. Production signing is configured outside Git.
10. Required release evidence is recorded before stable promotion.