# Local Build and Hosted CI Parity

This page maps local build commands to the repository's permanent GitHub Actions workflows. Use it when you want a local build to resemble the accepted hosted qualification process as closely as practical.

## Permanent quality CI

Workflow:

```text
.github/workflows/ci.yml
```

Current hosted Flutter version:

```text
3.47.0
```

The quality job performs, in order:

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

The Web step additionally guards against the repository's known missing icon-font warning.

## Local quality approximation

From the repository root:

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

The stable readiness command is intentionally stricter:

```bash
dart run tool/release_readiness.dart --stable --json
```

Do not expect it to pass until stable metadata and all required real-world evidence are complete.

## Native Platform Builds workflow

Workflow:

```text
.github/workflows/platform-builds.yml
```

It runs native qualification on separate hosts so each desktop/mobile toolchain is native to its supported environment.

## Android parity

Hosted environment includes:

- Ubuntu runner;
- Flutter 3.47.0;
- Temurin JDK 17;
- project lockfile verification.

Core local equivalent:

```bash
flutter pub get
git diff --exit-code -- pubspec.lock
flutter build apk --release
```

Hosted packaging:

```bash
sha256sum build/app/outputs/flutter-apk/app-release.apk \
  > build/app/outputs/flutter-apk/app-release.apk.sha256
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

## Builds not currently permanent native CI artifacts

The following are documented buildable formats/options but are not the permanent native qualification artifacts currently uploaded by `platform-builds.yml`:

- Android App Bundle (`flutter build appbundle --release`);
- Android ABI-split APK set;
- signed iOS IPA (`flutter build ipa --release`);
- Web Wasm build (`flutter build web --wasm`);
- Windows installer/MSIX-style packaging;
- macOS notarized/store package;
- Linux `.deb`, `.rpm`, Snap, Flatpak, or AppImage packages.

The first four can be built with Flutter/toolchain support as documented, but production use should gain explicit repository qualification if adopted as release outputs. The installer/package formats listed for desktop/Linux are not currently configured project release artifacts and must not be advertised as maintained outputs until implemented and tested.

## Generated-file integrity

Hosted jobs fail if certain Flutter-managed tracked files change during dependency resolution/build preparation. Locally, inspect:

```bash
git status --short
git diff
```

A toolchain upgrade may legitimately regenerate tracked files; if so, review and commit the changes intentionally together with relevant tests/docs rather than allowing hidden drift.

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

A local success does not override a failing permanent CI job, and a hosted compile success does not replace real-device qualification.

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