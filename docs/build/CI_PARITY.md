# Local Build and Hosted CI Parity

This page maps local commands to the repository's permanent GitHub Actions workflows. Use it when you want a local build to resemble hosted qualification as closely as practical.

## Permanent quality CI

Workflow:

```text
.github/workflows/ci.yml
```

Current hosted Flutter version:

```text
3.47.0
```

The quality job performs:

```bash
flutter pub get
git diff --exit-code -- pubspec.lock analysis_options.yaml
dart format --output=none --set-exit-if-changed lib test tool
flutter analyze
flutter test --coverage
dart run tool/release_readiness.dart --json
# strict stable gate is also exercised and expected to remain closed while evidence is pending
dart run tool/solver_benchmark.dart 8
flutter build web --release
```

The Web step also fails on the repository's guarded missing icon-font warning.

## Local quality approximation

```bash
flutter pub get
git diff --exit-code -- pubspec.lock analysis_options.yaml
dart format --output=none --set-exit-if-changed lib test tool
flutter analyze
flutter test --coverage
dart run tool/release_readiness.dart --json
dart run tool/solver_benchmark.dart 8
flutter build web --release
```

The stricter stable command is:

```bash
dart run tool/release_readiness.dart --stable --json
```

Do not expect it to pass until stable metadata and all required real-world evidence are complete.

## Native Platform Builds workflow

Workflow:

```text
.github/workflows/platform-builds.yml
```

It runs native qualification on separate hosted operating systems so each native desktop/mobile toolchain builds on an appropriate host.

## Android parity

Hosted environment includes:

- Ubuntu runner;
- Flutter 3.47.0;
- Temurin JDK 17;
- project lockfile verification.

Local equivalent:

```bash
flutter pub get
git diff --exit-code -- pubspec.lock
flutter build apk --release
flutter build appbundle --release
```

Hosted checksums:

```bash
sha256sum build/app/outputs/flutter-apk/app-release.apk \
  > build/app/outputs/flutter-apk/app-release.apk.sha256

sha256sum build/app/outputs/bundle/release/app-release.aab \
  > build/app/outputs/bundle/release/app-release.aab.sha256
```

Hosted artifact:

```text
nova-2048-android-release
  app-release.apk
  app-release.apk.sha256
  app-release.aab
  app-release.aab.sha256
```

Remember that the tracked Android release build type currently uses debug signing for public qualification. Hosted success is not production Play signing.

## Linux parity

Hosted Ubuntu installs:

```bash
sudo apt-get update
sudo apt-get install -y ninja-build libgtk-3-dev liblzma-dev
```

Then:

```bash
flutter config --enable-linux-desktop
flutter pub get
git diff --exit-code -- \
  pubspec.lock \
  linux/flutter/generated_plugin_registrant.cc \
  linux/flutter/generated_plugins.cmake
flutter build linux --release
```

Hosted package:

```bash
tar -C build/linux/x64/release -czf nova-2048-linux-x64.tar.gz bundle
sha256sum nova-2048-linux-x64.tar.gz > nova-2048-linux-x64.tar.gz.sha256
```

## Windows parity

Hosted Windows runner performs:

```powershell
flutter config --enable-windows-desktop
flutter pub get
flutter build windows --release
```

It also verifies tracked generated plugin files/lockfile have not changed unexpectedly.

Hosted package:

```powershell
Compress-Archive -Path build/windows/x64/runner/Release/* -DestinationPath nova-2048-windows-x64.zip -Force
$hash = (Get-FileHash nova-2048-windows-x64.zip -Algorithm SHA256).Hash.ToLower()
"$hash  nova-2048-windows-x64.zip" | Out-File -Encoding ascii nova-2048-windows-x64.zip.sha256
```

## macOS parity

Hosted macOS runner performs:

```bash
flutter config --enable-macos-desktop
flutter pub get
flutter build macos --release
```

It verifies the tracked Apple generated plugin registrant before building.

Hosted package:

```bash
macos_app="$(find build/macos/Build/Products/Release -maxdepth 1 -type d -name '*.app' -print -quit)"
test -n "$macos_app"
ditto -c -k --sequesterRsrc --keepParent "$macos_app" nova-2048-macos-release.zip
shasum -a 256 nova-2048-macos-release.zip > nova-2048-macos-release.zip.sha256
```

## iOS unsigned parity

The same hosted macOS job compiles iOS without code signing:

```bash
flutter build ios --release --no-codesign
```

Hosted package:

```bash
ios_app="$(find build/ios/iphoneos -maxdepth 1 -type d -name '*.app' -print -quit)"
test -n "$ios_app"
ditto -c -k --sequesterRsrc --keepParent "$ios_app" nova-2048-ios-unsigned-release.zip
shasum -a 256 nova-2048-ios-unsigned-release.zip > nova-2048-ios-unsigned-release.zip.sha256
```

This is intentionally not a signed IPA flow.

## Web parity

Permanent quality CI builds:

```bash
flutter build web --release
```

The generated `build/web/` directory is not currently uploaded as a retained CI artifact, but build success is part of the permanent quality gate.

## Builds not currently permanent qualification artifacts

The following are buildable/documented options but are not retained permanent qualification artifacts:

- Android ABI-split APK set;
- signed iOS IPA (`flutter build ipa --release`);
- Web Wasm build (`flutter build web --wasm`);
- Windows installer/MSIX-style packaging;
- macOS DMG/PKG/notarized/store packaging;
- Linux `.deb`, `.rpm`, Snap, Flatpak, or AppImage packages.

Android AAB is no longer in this list: it is now built/checksummed together with the release APK by the hosted Android job.

## Generated-file integrity

Hosted jobs fail if selected Flutter-managed tracked files change unexpectedly during dependency resolution/build preparation. Locally inspect:

```bash
git status --short
git diff
```

A deliberate toolchain/dependency upgrade may legitimately regenerate tracked files. Review and commit such changes intentionally together with relevant tests/docs.

## Why local and CI can differ

Differences can arise from:

- Flutter/Dart version;
- JDK/Android toolchain;
- Xcode/macOS SDK version;
- Visual Studio/Windows SDK version;
- Linux distribution/system libraries;
- dependency cache state;
- signing identity;
- archive metadata/timestamps;
- platform runner changes.

A local success does not override failing permanent CI, and hosted compilation does not replace real-device qualification.

## Recommended evidence order

1. Local quality checks.
2. Local target release build where possible.
3. Permanent `CI` success.
4. Permanent `Platform Builds` success for native changes.
5. Exact artifact checksum/package verification.
6. Real-target/manual qualification.
7. Production signing/provisioning/store checks.
8. Strict stable release gate on the exact release commit.

See [`../VERIFICATION.md`](../VERIFICATION.md), [`../RELEASE_ARTIFACTS.md`](../RELEASE_ARTIFACTS.md), and [`../RELEASE_QUALIFICATION.md`](../RELEASE_QUALIFICATION.md).
