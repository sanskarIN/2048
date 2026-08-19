# Building Executables and Distribution Artifacts

This is the canonical build handbook for **2048 Nova**. It explains how to prepare a machine, validate the source, build every maintained platform target, understand each artifact, handle signing safely, verify checksums, and diagnose build failures.

Current source identity:

```text
Package: nova_2048
Marketing version: 2.0.12
Flutter package/build version: 2.0.12+2012
Dart constraint: >=3.9.0 <4.0.0
Flutter floor: >=3.35.0
Hosted CI Flutter: 3.47.0 stable
Android AGP: 9.1.0
Android Kotlin plugin: 2.4.10
Gradle Wrapper: 9.7.0
Android Java/Kotlin target: JVM 17
```

The configured Flutter targets are:

- Android;
- iOS;
- Web / PWA;
- Windows;
- macOS;
- Linux.

A successful compilation proves that the selected source/configuration can produce that artifact on that toolchain. It does **not** automatically prove physical-device behavior, assistive-technology behavior, production signing, provisioning, notarization, installed-PWA behavior, store acceptance, or strict stable-release qualification.

## 1. Before you build

If the machine is not configured yet, start with:

- [`setup/README.md`](setup/README.md) — setup index;
- [`setup/PREREQUISITES.md`](setup/PREREQUISITES.md) — all tools and why they exist;
- [`setup/WINDOWS.md`](setup/WINDOWS.md) — Windows;
- [`setup/MACOS.md`](setup/MACOS.md) — macOS/iOS;
- [`setup/LINUX.md`](setup/LINUX.md) — Linux;
- [`setup/ANDROID.md`](setup/ANDROID.md) — Android toolchain;
- [`setup/UPGRADING_AND_SUPPORT.md`](setup/UPGRADING_AND_SUPPORT.md) — outdated/unsupported tools;
- [`COMMAND_REFERENCE.md`](COMMAND_REFERENCE.md) — meaning of commands/flags;
- [`GLOSSARY.md`](GLOSSARY.md) — terminology.

## 2. Supported build-host combinations

Flutter native targets are not treated as arbitrary cross-compilation targets.

| Target | Supported build host for this repository |
| --- | --- |
| Android | Windows, macOS, or Linux with Android SDK/JDK |
| iOS | macOS with Xcode |
| Web/PWA | Windows, macOS, or Linux |
| Windows desktop | Windows with Visual Studio C++ desktop tooling |
| macOS desktop | macOS with Xcode |
| Linux desktop | Linux with native Flutter/GTK toolchain |

If you do not own every host OS, the repository's GitHub Actions native matrix can provide build qualification on hosted native runners. Hosted builds are still not substitutes for real-device/store evidence.

## 3. Clone and prepare

```bash
git clone https://github.com/sanskarIN/2048.git
cd 2048
flutter --version
dart --version
flutter doctor -v
flutter pub get
```

What this means:

- `git clone ...` creates a local Git working copy and history;
- `cd 2048` changes into the repository root;
- `flutter --version` identifies the Flutter SDK;
- `dart --version` identifies Flutter's active Dart SDK;
- `flutter doctor -v` checks platform toolchains and prints detailed paths/versions;
- `flutter pub get` resolves the dependencies declared by `pubspec.yaml`/lockfile.

## 4. Clean rebuild preparation

For stale generated build output:

```bash
flutter clean
flutter pub get
```

`flutter clean` removes generated build intermediates. It should not be used as a substitute for understanding a real compiler, dependency, signing, or source error.

Do **not** delete committed `android/`, `ios/`, `web/`, `windows/`, `macos/`, or `linux/` runner folders merely to solve a stale build.

## 5. Quality gates before release-style builds

Run:

```bash
dart format --output=none --set-exit-if-changed lib test tool
flutter analyze
flutter test --coverage
dart run tool/release_readiness.dart --json
dart run tool/release_qualification_status.dart --json --pending-only
dart run tool/repository_audit.dart --json
dart run tool/source_completion_audit.dart --json
dart run tool/solver_benchmark.dart 8
```

Also verify dependency/config metadata did not drift unexpectedly:

```bash
git diff --exit-code -- pubspec.lock analysis_options.yaml
```

The strict stable release check is:

```bash
dart run tool/release_readiness.dart --stable --json
```

The stable gate is intentionally fail-closed while required real-world evidence remains incomplete. Do not weaken it just to obtain a “green” local command.

# Artifact overview

## 6. Maintained artifacts

| Target | Command | Primary output/use |
| --- | --- | --- |
| Android debug APK | `flutter build apk --debug` | Development installable APK |
| Android profile APK | `flutter build apk --profile` | Performance/profile investigation |
| Android release APK | `flutter build apk --release` | Optimized installable APK |
| Android split APKs | `flutter build apk --release --split-per-abi` | ABI-specific APKs |
| Android App Bundle | `flutter build appbundle --release` | Store-oriented `.aab` |
| iOS unsigned release | `flutter build ios --release --no-codesign` | Release compilation qualification |
| iOS IPA | `flutter build ipa --release` | Signed/exported iOS distribution when configured |
| Web release | `flutter build web --release` | Deployable `build/web/` directory |
| Windows release | `flutter build windows --release` | Native `.exe` plus runtime bundle |
| macOS release | `flutter build macos --release` | `.app` application bundle |
| Linux release | `flutter build linux --release` | ELF executable plus runtime bundle |

See [`build/SUPPORTED_ARTIFACTS.md`](build/SUPPORTED_ARTIFACTS.md) for the maintained/not-maintained artifact contract.

# Android

## 7. Android prerequisites

Android builds require:

- Flutter SDK;
- Android SDK/Command-line Tools;
- compatible JDK (project baseline: 17);
- accepted required Android SDK licenses;
- repository Gradle Wrapper.

Diagnose:

```bash
flutter doctor -v
flutter devices
```

Review licenses:

```bash
flutter doctor --android-licenses
```

Do not install a random system Gradle for this project. The repository controls Gradle with `android/gradlew` / `android/gradlew.bat`.

Verify wrapper on macOS/Linux:

```bash
cd android
./gradlew --version
cd ..
```

Windows:

```powershell
cd android
.\gradlew.bat --version
cd ..
```

## 8. Debug APK

```bash
flutter build apk --debug
```

Typical output:

```text
build/app/outputs/flutter-apk/app-debug.apk
```

Use debug builds for development. They contain development/debug behavior and are not public-release artifacts.

## 9. Profile APK

```bash
flutter build apk --profile
```

Typical output:

```text
build/app/outputs/flutter-apk/app-profile.apk
```

Profile mode is intended for supported performance profiling scenarios, not ordinary store distribution.

## 10. Universal release APK

```bash
flutter build apk --release
```

Output:

```text
build/app/outputs/flutter-apk/app-release.apk
```

`--release` selects Flutter's optimized release build mode.

The artifact's signing identity depends on local signing configuration. In public CI, release-mode packaging can intentionally use a debug-signing fallback so compilation/packaging can be qualified without exposing a production key.

## 11. ABI-split APKs

```bash
flutter build apk --release --split-per-abi
```

`--split-per-abi` creates architecture-specific APKs under:

```text
build/app/outputs/flutter-apk/
```

Inspect the generated filenames. Do not assume a fixed architecture list forever and do not distribute an arbitrary split APK to a device with a different ABI.

## 12. Android App Bundle (AAB)

```bash
flutter build appbundle --release
```

Output:

```text
build/app/outputs/bundle/release/app-release.aab
```

An AAB is a store publishing bundle. A store/bundle tooling derives device-specific APKs from it. It is not normally installed by simply tapping the `.aab` file.

## 13. Android signing

The tracked `android/app/build.gradle.kts` supports two clearly separated paths.

### Distribution signing

If ignored `android/key.properties` exists with real values and the referenced private keystore exists, Gradle creates/uses the release signing configuration.

### Qualification fallback

If `android/key.properties` is absent, the repository can build optimized release-mode Android artifacts with the debug signing identity so hosted CI can verify the build without private secrets.

That fallback artifact is **not** equivalent to the final production Play signing identity.

Never commit:

- private `.jks` / `.keystore` files;
- store/key passwords;
- private signing keys;
- Play service-account credentials;
- production API tokens.

See:

- [`build/ANDROID.md`](build/ANDROID.md);
- [`build/SIGNING_AND_DISTRIBUTION.md`](build/SIGNING_AND_DISTRIBUTION.md).

## 14. Android version name and build number

Current project source:

```yaml
version: 2.0.12+2012
```

Flutter treats:

- `2.0.12` as the build/release name input;
- `2012` as the build number/version-code input.

One-off overrides are supported, for example:

```bash
flutter build apk --release --build-name=2.0.12 --build-number=2012
flutter build appbundle --release --build-name=2.0.12 --build-number=2012
```

For official releases, prefer synchronizing `pubspec.yaml`, application metadata, changelog, release evidence, and tag instead of relying on an unrecorded local override.

# iOS

## 15. iOS prerequisites

iOS native builds require macOS with Xcode. CocoaPods may be required by the active Flutter/plugin configuration.

Verify:

```bash
xcodebuild -version
xcode-select -p
pod --version
flutter doctor -v
```

Windows and Linux cannot natively produce iOS builds for this repository.

## 16. Unsigned iOS release compilation

```bash
flutter build ios --release --no-codesign
```

Expected product location:

```text
build/ios/iphoneos/Runner.app
```

`--no-codesign` disables Apple code signing for this build. It is useful for compilation qualification, but the resulting app is not an App Store-ready IPA.

## 17. Signed/exported IPA

After legitimate Apple signing/provisioning is configured:

```bash
flutter build ipa --release
```

Output directory:

```text
build/ios/ipa/
```

The exact exported IPA filename can depend on archive/export settings.

A signed iOS distribution can require certificates, private keys, provisioning profiles, entitlements, bundle identifiers, and App Store Connect access. Keep private credentials outside the public repository.

See [`build/IOS.md`](build/IOS.md).

# Web / PWA

## 18. Web release

```bash
flutter build web --release
```

Output:

```text
build/web/
```

A Flutter Web release is a directory, not a standalone `.exe`.

Deploy the **entire** directory, including the generated bootstrap/runtime files, scripts/WebAssembly-related assets as produced by the selected SDK, icons, manifest, and Flutter assets.

Do not upload only `index.html`.

For PWA/install/deployment behavior see:

- [`PWA.md`](PWA.md);
- [`build/WEB.md`](build/WEB.md).

If deploying under a subpath instead of the domain root, follow the current Flutter base-href deployment mechanism and verify actual asset/navigation behavior on the real host.

# Windows

## 19. Windows prerequisites

Requires a Windows host with **Visual Studio**, including **Desktop development with C++**. VS Code alone does not provide the required native compiler/toolchain.

Verify:

```powershell
flutter doctor -v
flutter devices
```

## 20. Windows release

```powershell
flutter config --enable-windows-desktop
flutter pub get
flutter build windows --release
```

Current primary release area:

```text
build/windows/x64/runner/Release/
```

Main executable:

```text
nova_2048.exe
```

Do **not** distribute only the EXE. The release directory contains required Flutter/runtime DLLs and data.

The repository platform workflow packages the complete Windows bundle as a ZIP with a SHA-256 sidecar.

MSI/MSIX or third-party installer formats are not automatically maintained simply because a Windows `.exe` exists. If introduced later, they require their own reproducible packaging/signing/testing documentation.

See [`build/WINDOWS.md`](build/WINDOWS.md).

# macOS

## 21. macOS prerequisites

Requires a Mac with Xcode.

Verify:

```bash
xcodebuild -version
xcode-select -p
flutter doctor -v
```

## 22. macOS release

```bash
flutter config --enable-macos-desktop
flutter pub get
flutter build macos --release
```

Current expected product:

```text
build/macos/Build/Products/Release/2048 Nova.app
```

A `.app` is a structured directory bundle even though Finder displays it as one application. Preserve the bundle structure.

The hosted platform workflow packages the complete application bundle as a ZIP with checksum for qualification.

Developer ID signing, notarization, DMG/PKG creation, and Mac App Store packaging are separate distribution processes and are not implied by `flutter build macos` alone.

See [`build/MACOS.md`](build/MACOS.md).

# Linux

## 23. Linux prerequisites

On Debian/Ubuntu-style hosts, Flutter's native Linux toolchain uses packages such as:

```bash
sudo apt-get update
sudo apt-get install -y clang cmake ninja-build pkg-config libgtk-3-dev libstdc++-12-dev
```

Package names differ by distribution.

Verify:

```bash
clang --version
cmake --version
ninja --version
pkg-config --version
flutter doctor -v
```

## 24. Linux release

```bash
flutter config --enable-linux-desktop
flutter pub get
flutter build linux --release
```

Current bundle area:

```text
build/linux/x64/release/bundle/
```

Main executable:

```text
nova_2048
```

Do **not** distribute only the ELF executable. Keep generated libraries/data with it.

The repository platform workflow packages the complete Linux bundle into a compressed archive plus SHA-256 checksum.

`.deb`, `.rpm`, AppImage, Snap, and Flatpak are not automatically maintained outputs. Adding one later requires explicit reproducibility, metadata, update/signing, and testing policy.

See [`build/LINUX.md`](build/LINUX.md).

# Packaging and checksums

## 25. Why package the complete runtime bundle

Desktop Flutter applications usually consist of more than the visible executable. They can include:

- Flutter engine/runtime libraries;
- plugin libraries;
- ICU/data/assets;
- application asset bundles;
- platform metadata/resources.

Therefore preserve the generated release directory or application bundle rather than extracting one binary.

## 26. SHA-256 checksums

Linux:

```bash
sha256sum artifact-file
```

Verify a sidecar:

```bash
sha256sum -c artifact-file.sha256
```

macOS:

```bash
shasum -a 256 artifact-file
```

PowerShell:

```powershell
Get-FileHash .\artifact-file -Algorithm SHA256
```

A SHA-256 checksum helps detect file changes/corruption. It is **not** a digital signature and does not prove who published the artifact.

See [`build/PACKAGING_AND_CHECKSUMS.md`](build/PACKAGING_AND_CHECKSUMS.md).

# CI qualification artifacts

## 27. Permanent quality CI

`.github/workflows/ci.yml` currently performs the maintained equivalent of:

```bash
flutter pub get
git diff --exit-code -- pubspec.lock analysis_options.yaml
dart format --output=none --set-exit-if-changed lib test tool
flutter analyze
flutter test --coverage
dart run tool/release_readiness.dart --json
dart run tool/release_qualification_status.dart --json --pending-only
dart run tool/repository_audit.dart --json
dart run tool/source_completion_audit.dart --json
dart run tool/solver_benchmark.dart 8
flutter build web --release
```

It also checks that strict stable readiness remains fail-closed when the canonical manual evidence manifest is incomplete.

## 28. Native platform workflow

`.github/workflows/platform-builds.yml` builds native release outputs on native hosted runners, including:

- Android release APK;
- Android release AAB;
- Linux release bundle/archive;
- Windows release bundle/archive;
- macOS release app/archive;
- unsigned iOS release app/archive;
- checksum sidecars as maintained by the workflow.

These are qualification inputs. A hosted Android artifact without private release credentials is not the final production signing identity. An unsigned iOS artifact is not a store-ready IPA.

See [`RELEASE_ARTIFACTS.md`](RELEASE_ARTIFACTS.md) and [`build/CI_PARITY.md`](build/CI_PARITY.md).

# Troubleshooting

## 29. Universal first diagnostic sequence

```bash
flutter --version
dart --version
flutter doctor -v
flutter clean
flutter pub get
dart format --output=none --set-exit-if-changed lib test tool
flutter analyze
flutter test
dart run tool/repository_audit.dart --json
dart run tool/source_completion_audit.dart --json
```

Then retry **only** the target build that failed.

Useful guides:

- [`TROUBLESHOOTING.md`](TROUBLESHOOTING.md);
- [`build/BUILD_TROUBLESHOOTING.md`](build/BUILD_TROUBLESHOOTING.md);
- [`setup/UPGRADING_AND_SUPPORT.md`](setup/UPGRADING_AND_SUPPORT.md);
- [`ANDROID_TOOLCHAIN.md`](ANDROID_TOOLCHAIN.md);
- [`build/HOST_PREREQUISITES.md`](build/HOST_PREREQUISITES.md);
- [`build/OUTPUT_PATHS.md`](build/OUTPUT_PATHS.md).

Do not “fix” build failures by disabling analyzer rules, release-readiness safeguards, dependency-integrity checks, signing validation, or repository audits merely to produce a binary.

## 30. Tool is out of support

If an SDK/IDE/toolchain component reaches end-of-support, use [`setup/UPGRADING_AND_SUPPORT.md`](setup/UPGRADING_AND_SUPPORT.md).

The required pattern is:

1. confirm vendor support status;
2. identify compatible replacement versions;
3. preserve the old baseline in Git;
4. migrate on a maintenance branch;
5. upgrade the smallest necessary compatibility unit;
6. rerun Flutter Doctor, formatting, analyzer, tests, audits, and affected platform builds;
7. repeat real-environment qualification where behavior/toolchain changed;
8. update CI pins and docs only after intentional acceptance.

“Install everything newest” is not a compatibility strategy.

# Final release procedure

## 31. Recommended order

1. Start from the exact intended release commit.
2. Confirm `git status` is clean.
3. Confirm current toolchain versions.
4. Run `flutter pub get` and inspect any lock/config drift.
5. Run formatting, analysis, tests, repository/source-completion audits, solver benchmark, and candidate readiness.
6. Build Web and all affected native targets on supported hosts/CI.
7. Produce final production-signed artifacts only in authorized release environments.
8. Compute/record checksums.
9. Verify signing identity/provisioning/notarization as applicable.
10. Perform required physical-device/browser/accessibility/external-handler checks against the exact artifact/source candidate.
11. Record genuine manual evidence through the guarded qualification process.
12. Run strict stable readiness.
13. Only when policy/evidence is complete should a stable distribution be claimed.

## 32. What not to claim

Do not claim:

- “fully production tested” because CI compiled it;
- “App Store ready” because an unsigned iOS `.app` compiled;
- “Play signed” because a CI APK/AAB exists;
- “accessible on all assistive technologies” because widget tests pass;
- “PWA works offline everywhere” because `flutter build web` completed;
- “stable qualified” while the strict evidence gate is still closed.

The repository deliberately separates source completion, automated build evidence, and real-world stable qualification.

## 33. Related documentation

- [`build/README.md`](build/README.md) — per-platform build guide index;
- [`build/RELEASE_BUILD_CHECKLIST.md`](build/RELEASE_BUILD_CHECKLIST.md) — artifact checklist;
- [`RELEASE_CHECKLIST.md`](RELEASE_CHECKLIST.md) — wider release checklist;
- [`RELEASE_QUALIFICATION.md`](RELEASE_QUALIFICATION.md) — evidence/stable gate;
- [`COMMAND_REFERENCE.md`](COMMAND_REFERENCE.md) — command/flag meanings;
- [`GLOSSARY.md`](GLOSSARY.md) — technical vocabulary;
- [`REPOSITORY_FILE_ATLAS.md`](REPOSITORY_FILE_ATLAS.md) — no-skip repository guide.