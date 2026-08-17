# iOS Build Guide

This guide covers the iOS build outputs supported by the current 2048 Nova Flutter project: simulator/device development runs, unsigned release `.app` compilation for qualification, and signed/exported `.ipa` distribution when Apple signing is configured.

## Host requirement

iOS builds require **macOS with Xcode**. The repository does not treat Windows or Linux as supported iOS release-build hosts.

## Prerequisites

Install/configure:

- Flutter SDK;
- Xcode and command-line tools;
- CocoaPods if required by the installed Flutter/plugin toolchain;
- an iOS Simulator or physical device for interactive testing;
- for signed device/App Store builds: an Apple Developer account, signing certificate/private key, bundle registration, and provisioning configuration.

Verify:

```bash
flutter --version
flutter doctor -v
flutter devices
xcodebuild -version
```

Install dependencies:

```bash
flutter pub get
```

## Development run

With a configured simulator/device:

```bash
flutter run -d <ios-device-id>
```

Use `flutter devices` to obtain the target identifier.

## Unsigned release iOS app

The repository's hosted Apple qualification workflow uses:

```bash
flutter build ios --release --no-codesign
```

Expected output directory:

```text
build/ios/iphoneos/
```

The main generated application bundle is normally:

```text
build/ios/iphoneos/Runner.app
```

This proves release-mode iOS compilation on the hosted macOS/Xcode environment. It is **not** a signed App Store/TestFlight package and should not be described as one.

## Package the unsigned `.app` like CI

The hosted workflow locates the generated `.app` and preserves the application bundle using `ditto`:

```bash
ios_app="$(find build/ios/iphoneos -maxdepth 1 -type d -name '*.app' -print -quit)"
test -n "$ios_app"
ditto -c -k --sequesterRsrc --keepParent "$ios_app" nova-2048-ios-unsigned-release.zip
shasum -a 256 nova-2048-ios-unsigned-release.zip \
  > nova-2048-ios-unsigned-release.zip.sha256
```

Verify:

```bash
shasum -a 256 -c nova-2048-ios-unsigned-release.zip.sha256
```

The ZIP remains an unsigned qualification artifact; zipping does not make it installable or signed.

## Signed IPA

When Apple signing/provisioning is correctly configured, Flutter supports an IPA export flow:

```bash
flutter build ipa --release
```

Inspect:

```text
build/ios/ipa/
```

The exact archive/export products depend on Xcode, signing identity, provisioning, and export configuration.

If your distribution method requires a custom export options plist, use the Flutter/Xcode export mechanism appropriate to your signing setup rather than committing secrets to this repository.

## What is an IPA?

An `.ipa` is an iOS application archive used for signed distribution workflows. Unlike the repository's unsigned `Runner.app` qualification build, a distributable IPA requires a valid Apple signing/provisioning chain for its intended destination.

Potential destinations include:

- development/ad hoc testing;
- TestFlight/App Store distribution;
- other Apple-supported managed distribution flows.

Each has different signing/export requirements.

## Signing and provisioning boundary

Do not commit:

- `.p12`/private signing key material;
- Apple signing passwords;
- provisioning profiles intended as private deployment material;
- App Store Connect API private keys;
- authentication tokens;
- notarization/signing secrets.

Use Keychain and secure CI secret storage where appropriate.

The public repository can contain non-secret bundle/project configuration, but private identities and credentials must remain external.

## Bundle identifier

The verified project state uses an iOS bundle identifier around:

```text
com.sanskarin.nova2048
```

Before distribution, confirm the actual Xcode project target settings and your Apple Developer registration agree. Do not assume documentation overrides Xcode project configuration.

## Build version

The source version is controlled by `pubspec.yaml`, currently on the Version 1.5 line. Flutter may pass build name/number into Apple project metadata during builds.

For an official release, keep these aligned:

- `pubspec.yaml`;
- Xcode generated/target metadata;
- changelog/release notes;
- intended App Store/TestFlight version/build;
- release qualification evidence.

## Clean rebuild

```bash
flutter clean
flutter pub get
flutter build ios --release --no-codesign
```

If plugin/Xcode state is broken, inspect `flutter doctor -v`, Xcode selection/license status, and CocoaPods/plugin diagnostics rather than regenerating or deleting committed iOS runner files blindly.

## Common failures

### Xcode not configured

Run:

```bash
flutter doctor -v
xcodebuild -version
```

Resolve Flutter's reported Xcode/toolchain issues.

### Code signing error

If you are only reproducing hosted compilation evidence, use:

```bash
flutter build ios --release --no-codesign
```

If you need a real IPA/device distribution build, configure a valid team/certificate/provisioning profile instead of disabling signing and then labeling the result distributable.

### Provisioning mismatch

Check:

- bundle identifier;
- selected development team;
- certificate validity;
- profile application identifier;
- device registration for development/ad hoc distribution;
- App Store Connect registration for store release.

### Build works but app is not installable

An unsigned `.app` is expected not to behave like a properly signed distribution artifact. Use a valid signed build for physical-device installation/distribution qualification.

## Real-device qualification

Before stable iOS release evidence is marked passed, test on physical Apple hardware:

- launch and lifecycle;
- background/foreground behavior;
- save/resume and restart;
- touch/swipe/orientation;
- VoiceOver and large text;
- English/Hindi switching and semantics;
- Challenge Code QR display/copy/paste/manual entry;
- Game Backup clipboard/file workflows through real handlers;
- Move Replay/Full Replay/Auto Play controls;
- long sessions and timed/move-limited modes;
- splash/icon appearance.

## App Store/TestFlight boundary

A successful `flutter build ipa --release` is still only part of release preparation. Also verify:

- signing/export method;
- App Store Connect application record;
- privacy information;
- screenshots/metadata;
- age/content declarations as applicable;
- version/build uniqueness;
- TestFlight processing/testing if used;
- final release qualification manifest.

See [`../RELEASE_QUALIFICATION.md`](../RELEASE_QUALIFICATION.md) and [`../RELEASE_CHECKLIST.md`](../RELEASE_CHECKLIST.md).

## Release checklist

1. `flutter doctor -v` is clean enough for iOS work.
2. Dependencies install without unintended lockfile changes.
3. Repository formatter/analyzer/tests pass.
4. Unsigned release compilation succeeds for CI parity.
5. If distributing, signed IPA/export succeeds with external signing material.
6. Package/checksum the exact artifact under test.
7. Test the exact signed build on representative physical iOS hardware.
8. Complete VoiceOver/localization/large-text checks.
9. Confirm version, bundle ID, signing team, and store metadata.
10. Record genuine evidence before stable promotion.