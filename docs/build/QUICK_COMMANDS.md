# Build Command Quick Reference

Use this page when you already understand the signing, packaging, and qualification boundaries documented in [`../BUILDING_EXECUTABLES.md`](../BUILDING_EXECUTABLES.md).

## Common preparation

```bash
flutter --version
flutter doctor -v
flutter pub get
dart format --output=none --set-exit-if-changed lib test tool
flutter analyze
flutter test
```

## Android

Debug APK:

```bash
flutter build apk --debug
```

Profile APK:

```bash
flutter build apk --profile
```

Universal release APK:

```bash
flutter build apk --release
```

ABI-split release APKs:

```bash
flutter build apk --release --split-per-abi
```

Release Android App Bundle:

```bash
flutter build appbundle --release
```

Current tracked release signing uses the debug signing configuration for public qualification builds. Configure private production signing outside Git before store distribution.

## iOS

Unsigned release application bundle, matching hosted compilation qualification:

```bash
flutter build ios --release --no-codesign
```

Signed/exported IPA when Apple signing/provisioning is configured:

```bash
flutter build ipa --release
```

## Web / PWA

```bash
flutter build web --release
```

Deploy the complete `build/web/` output.

## Windows

```powershell
flutter config --enable-windows-desktop
flutter build windows --release
```

Main binary is currently `nova_2048.exe`, but distribute the complete generated `Release/` bundle.

## macOS

```bash
flutter config --enable-macos-desktop
flutter build macos --release
```

Current configured product is `2048 Nova.app`.

## Linux

Debian/Ubuntu prerequisites used by hosted CI:

```bash
sudo apt-get update
sudo apt-get install -y ninja-build libgtk-3-dev liblzma-dev
```

Build:

```bash
flutter config --enable-linux-desktop
flutter build linux --release
```

Main binary is currently `nova_2048`, but distribute the complete generated `bundle/`.

## Candidate release gate

```bash
dart run tool/release_readiness.dart --json
```

## Stable release gate

Only after all required manual qualification is genuinely complete:

```bash
dart run tool/release_readiness.dart --stable --json
```

## Output paths

See [`OUTPUT_PATHS.md`](OUTPUT_PATHS.md).

## Packaging and checksums

See [`PACKAGING_AND_CHECKSUMS.md`](PACKAGING_AND_CHECKSUMS.md).

## Full per-platform instructions

- [`ANDROID.md`](ANDROID.md)
- [`IOS.md`](IOS.md)
- [`WEB.md`](WEB.md)
- [`WINDOWS.md`](WINDOWS.md)
- [`MACOS.md`](MACOS.md)
- [`LINUX.md`](LINUX.md)