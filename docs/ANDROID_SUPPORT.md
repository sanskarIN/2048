# Android Support Contract

2048 Nova treats Android as a first-class production target. This document defines what the repository guarantees in source and CI, how release artifacts are built, and which checks still require real devices or store infrastructure.

## Source-level guarantees

The Android runner is maintained under `android/` and uses the same Dart/Flutter game code as every other platform.

The production contract requires:

- application ID `com.sanskarin.nova_2048`;
- Flutter-managed `minSdk`, `targetSdk`, `compileSdk`, and NDK levels so the Android runner follows the selected Flutter toolchain;
- Java 17 and Kotlin JVM 17 bytecode targets;
- responsive/resizable activity behavior for phones, tablets, foldables, desktop-style Android windows, and ChromeOS-style environments;
- RTL support enabled at the Android application layer;
- touchscreen hardware marked optional so non-touch Android environments are not filtered out solely by hardware capability;
- hardware acceleration enabled for Flutter rendering;
- cleartext HTTP disabled;
- Android application backup disabled so local game state is not silently exported through platform backup;
- release code shrinking and resource shrinking through R8;
- distribution signing through ignored local `android/key.properties`, with CI using the debug key only for unsigned qualification builds.

## Supported Android artifact types

The repository qualifies all of the following release outputs:

```bash
flutter build apk --release
flutter build apk --release --split-per-abi
flutter build appbundle --release
```

The universal APK is convenient for direct installation and testing. Split APKs validate the Flutter-supported Android ABIs independently and reduce per-device download size when distributed outside an app bundle. The AAB is the preferred Play Store upload artifact.

CI stores the universal APK, split APKs, AAB, and SHA-256 checksums as temporary qualification artifacts.

## Device classes

The Flutter UI must remain usable when Android reports compact, medium, or expanded windows. The Android manifest intentionally does not lock portrait/landscape orientation and explicitly keeps the activity resizable.

Source and widget tests can protect responsive logic, but they do not replace physical qualification. Before a stable Android store release, record evidence for at least:

- a compact phone;
- a large phone;
- a tablet or large resizable emulator;
- rotation and window resizing;
- keyboard/mouse navigation where available;
- Android dark/light system modes;
- one current Android API level and one older API level still covered by the Flutter minimum SDK contract.

Do not mark those manual gates complete without real evidence.

## Signing

Never commit a keystore, passwords, or `android/key.properties`.

Copy `android/key.properties.example` to `android/key.properties`, point `storeFile` at the private keystore, and provide the real alias/store/key passwords. The Gradle build fails closed when placeholder or invalid signing values are supplied.

CI deliberately omits production credentials. Its release-mode artifacts prove compilation/package integrity, not production signing identity.

## Privacy and permissions

2048 Nova is offline-first. The main Android manifest does not request broad storage, contacts, location, microphone, camera, advertising, notification, or network permissions.

`url_launcher` query visibility is limited to HTTPS and mail handlers used by explicit user actions. `file_picker` relies on platform document providers instead of broad filesystem access.

If a future feature adds an Android permission, update this document, the Android audit, store declarations, privacy documentation, and tests in the same change.

## Automated Android audit

Run:

```bash
dart run tool/android_support_audit.dart --json
```

The audit verifies the manifest, Gradle release hardening, signing boundary, production build commands, split-ABI qualification, and required documentation.

Permanent CI also runs this audit.

## Release checklist

1. Run `flutter pub get` and ensure `pubspec.lock` is unchanged.
2. Run formatter, analyzer, and tests.
3. Run `dart run tool/android_support_audit.dart --json`.
4. Build the universal release APK.
5. Build split-per-ABI release APKs.
6. Build the release AAB.
7. Configure real signing only in the secure release environment.
8. Install/test on representative Android devices and window sizes.
9. Record manual qualification evidence instead of assuming it.
10. Upload the signed AAB to the intended store track only after all stable-release gates pass.

## Boundary of the word "supported"

The repository can prove source configuration, automated tests, and hosted release compilation. It cannot prove physical-device behavior, OEM-specific behavior, Play signing, store review acceptance, or accessibility quality without external evidence. Those remain explicit manual release gates rather than undocumented assumptions.
