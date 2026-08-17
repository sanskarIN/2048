# Android Build Guide

This guide covers the Android artifact types supported by the current 2048 Nova Flutter project: debug APK, profile APK, universal release APK, ABI-split release APKs, and release Android App Bundle (`.aab`).

## Repository baseline

The current Version 1.5 Android baseline is:

- Flutter hosted CI: **3.47.0**
- JDK hosted CI: **Temurin 17**
- Android Gradle Plugin: **9.1.0**
- Kotlin Android: **2.4.10**
- Gradle: **9.7.0**
- Android application ID: `com.sanskarin.nova_2048`

Do not casually upgrade these as independent values. See [`../ANDROID_TOOLCHAIN.md`](../ANDROID_TOOLCHAIN.md) and GitHub issue #10 for the AGP 9.3.x deferral evidence.

## Current release-signing state

The tracked `android/app/build.gradle.kts` deliberately maps the Android `release` build type to the **debug signing configuration** so public hosted CI can compile/package release-mode code without storing a private production keystore.

Therefore:

- `flutter build apk --release` produces an optimized release-mode APK, but with the repository's qualification/debug signing identity;
- `flutter build appbundle --release` produces an optimized release-mode AAB under the same tracked qualification signing configuration;
- both APK and AAB are now built and checksummed by the hosted `Platform Builds` workflow;
- neither hosted artifact should be described as the final production Play signing identity.

Before public store distribution, configure a secure production upload/signing path outside committed secrets, rebuild from the exact intended release commit, and re-qualify that production-signed output.

## Prerequisites

Install:

- Flutter SDK;
- Android SDK and platform/build tools;
- JDK compatible with the maintained Android toolchain;
- accepted Android SDK licenses;
- optional emulator or physical Android device for installation/testing.

Verify:

```bash
flutter --version
java -version
flutter doctor -v
flutter devices
```

Install dependencies:

```bash
flutter pub get
```

## Debug APK

Build:

```bash
flutter build apk --debug
```

Output:

```text
build/app/outputs/flutter-apk/app-debug.apk
```

Use only for development/debugging.

## Profile APK

Build:

```bash
flutter build apk --profile
```

Output:

```text
build/app/outputs/flutter-apk/app-profile.apk
```

Profile mode is for performance investigation on supported hardware; it is not the final public release package.

## Universal release APK

Build:

```bash
flutter build apk --release
```

Output:

```text
build/app/outputs/flutter-apk/app-release.apk
```

This is directly installable on compatible Android devices and is one of the two Android release outputs qualified by the hosted native matrix.

### APK checksum

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

## ABI-split release APKs

Build:

```bash
flutter build apk --release --split-per-abi
```

Inspect:

```text
build/app/outputs/flutter-apk/
```

Use split APKs only when the distribution path knows which ABI each user/device needs. Exact generated filenames/ABIs should be read from the output directory because Flutter/toolchain defaults can evolve.

When Flutter applies ABI-specific version-code offsets, do not assume every split has the same effective version code as the universal APK; inspect generated package metadata when that matters.

## Release Android App Bundle (AAB)

Build:

```bash
flutter build appbundle --release
```

Output:

```text
build/app/outputs/bundle/release/app-release.aab
```

Use an AAB for Google Play-style distribution. An AAB is a publishing bundle from which device-specific APKs are produced; it is not normally installed directly by tapping it on a device.

The hosted `Platform Builds` workflow now builds this AAB from the same source/toolchain as the release APK and uploads it in the `nova-2048-android-release` qualification artifact.

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

## Hosted Android qualification artifact

The current native workflow publishes:

```text
nova-2048-android-release
  app-release.apk
  app-release.apk.sha256
  app-release.aab
  app-release.aab.sha256
```

`if-no-files-found: error` prevents a missing APK/AAB from silently producing a successful empty artifact.

## Clean rebuild

When diagnosing stale Android output:

```bash
flutter clean
flutter pub get
flutter build apk --release
flutter build appbundle --release
```

If Gradle/toolchain state is suspected, inspect `flutter doctor -v`, `java -version`, Gradle/AGP/Kotlin versions, and the repository Android toolchain policy before deleting/regenerating runner configuration.

## Installing an APK for testing

For normal Flutter development:

```bash
flutter run -d <android-device-id>
```

For release qualification, install/test the exact release APK artifact intended for qualification rather than assuming a debug run proves release behavior.

The AAB itself is not the normal direct-install artifact; use the release APK for direct sideload testing unless your store/bundle workflow intentionally generates installable APKs from the AAB.

## Version/build overrides

Source version is defined in `pubspec.yaml`.

Flutter also supports build-time overrides:

```bash
flutter build apk --release --build-name=1.5.0 --build-number=15
flutter build appbundle --release --build-name=1.5.0 --build-number=15
```

For official releases, keep repository metadata aligned rather than relying only on local overrides.

## Production signing boundary

A locally/hosted generated release artifact is not automatically equivalent to a production-signed Play release.

Production Android distribution may require:

- a private upload/signing key;
- secure Gradle signing configuration or store-managed app signing;
- protected passwords/aliases;
- Play Console app/listing configuration.

Never commit:

- private `.jks`/keystore files;
- keystore passwords;
- key passwords;
- private signing properties;
- store API credentials.

If production signing is added locally or in protected CI, treat the resulting package as a different release-sensitive artifact and re-test it.

## APK versus AAB decision

Use **APK** when you need:

- direct installation/sideloading;
- device/manual qualification;
- a distribution channel that accepts APKs.

Use **AAB** when you need:

- Google Play-style publishing;
- store-generated device-specific APK delivery.

Use **split APKs** only when your delivery path explicitly manages ABIs.

## Common failures

### Android SDK/license missing

Run:

```bash
flutter doctor -v
```

Resolve Android toolchain items before retrying.

### Wrong Java runtime

```bash
java -version
flutter doctor -v
```

Hosted Android qualification uses Temurin JDK 17.

### Gradle/AGP/Kotlin failure

Consult [`../ANDROID_TOOLCHAIN.md`](../ANDROID_TOOLCHAIN.md). The project has explicit regression coverage for its accepted Android versions.

### Build succeeds but APK installation fails

Check:

- target device Android version;
- target ABI if using split APKs;
- available storage;
- installed package/signature lineage;
- whether an existing package with the same application ID was signed by a different key.

The current qualification build and a future production-signed build may use different signing identities, so Android can reject an in-place update across mismatched signatures.

### AAB builds but cannot be directly installed

That is expected. AAB is a publishing bundle, not normally a tap-to-install package.

## Release verification checklist

Before distributing an Android artifact:

1. `flutter pub get` completes without unintended lockfile drift.
2. Formatter, analyzer, and tests pass.
3. Candidate release-readiness check passes.
4. `flutter build apk --release` succeeds.
5. `flutter build appbundle --release` succeeds when AAB distribution is intended.
6. Signing identity/state is explicitly known.
7. SHA-256 sidecars are generated and verified.
8. The exact release APK is tested on representative physical Android devices.
9. Lifecycle, save/resume, gestures, orientation, long-session, Challenge Code, Backup, Replay, and external-handler behavior are checked.
10. TalkBack, large-text, high-contrast, reduced-motion, and Hindi behavior are checked.
11. Native launcher icon/splash presentation is reviewed.
12. Production signing is configured outside Git and the exact production-signed artifact is re-tested.
13. Required real-world release evidence is recorded before stable promotion.

See [`../RELEASE_QUALIFICATION.md`](../RELEASE_QUALIFICATION.md), [`../RELEASE_ARTIFACTS.md`](../RELEASE_ARTIFACTS.md), and [`SIGNING_AND_DISTRIBUTION.md`](SIGNING_AND_DISTRIBUTION.md).
