# Xcode and CocoaPods Handbook

This guide explains the Apple-platform development toolchain used by **2048 Nova** for macOS and iOS builds: Xcode, Command Line Tools, `xcode-select`, `xcodebuild`, Simulator, CocoaPods, code signing, provisioning, upgrades, and troubleshooting.

A Mac is required for native iOS and macOS builds.

## 1. What Xcode is

Xcode is Apple's integrated development environment and platform SDK/compiler suite.

For a Flutter project it provides:

- Apple Clang compiler/toolchain;
- iOS/macOS SDKs;
- Simulator runtimes/tools;
- native project/workspace support;
- code-signing/provisioning integration;
- archive/export tools;
- debugging/logging tools;
- command-line build tool `xcodebuild`.

The shared app remains Dart/Flutter; Xcode builds the native Apple runner/plugins/framework integration.

## 2. What CocoaPods is

CocoaPods is a dependency manager used by many iOS/macOS native dependencies and Flutter plugins.

Flutter can invoke CocoaPods as part of Apple-platform dependency integration when required.

CocoaPods is not a replacement for Dart Pub. They manage different dependency layers.

## 3. Install Xcode

Install a Flutter-supported Xcode release through Apple's supported distribution channel.

After installation/update, select the full Xcode developer directory:

```bash
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
```

Then perform first-launch setup when required:

```bash
sudo xcodebuild -runFirstLaunch
```

Verify:

```bash
xcodebuild -version
xcode-select -p
```

## 4. Xcode Command Line Tools

On a Mac without the full Xcode toolchain installed yet:

```bash
xcode-select --install
```

This requests Apple's Command Line Tools.

Full iOS/macOS Flutter builds still require the appropriate full Xcode installation/SDKs.

## 5. `xcode-select -p`

```bash
xcode-select -p
```

Prints the currently selected developer tools directory.

For the standard full Xcode installation it should normally resolve to:

```text
/Applications/Xcode.app/Contents/Developer
```

If it points only to standalone Command Line Tools while full Xcode is needed, switch it deliberately.

## 6. `xcodebuild -version`

```bash
xcodebuild -version
```

Confirms the selected Xcode build tool and reports its version.

Record this during an Apple toolchain migration because Xcode changes compiler and platform SDK behavior.

## 7. Flutter Doctor for Apple platforms

```bash
flutter doctor -v
```

Inspect Xcode/iOS/macOS and CocoaPods diagnostics.

A healthy doctor result is necessary but not sufficient for signed App Store distribution.

## 8. Install CocoaPods

Use one consistent supported installation method.

For a Homebrew-managed installation:

```bash
brew install cocoapods
```

Verify:

```bash
pod --version
which pod
type -a pod
```

Avoid accidentally mixing several CocoaPods installations from Homebrew, RubyGems, system Ruby, or custom Ruby managers without knowing which `pod` executable is active.

## 9. Upgrade CocoaPods

For Homebrew:

```bash
brew update
brew upgrade cocoapods
pod --version
```

If installed another way, use that installation method's supported upgrade procedure.

After upgrading, run the normal Flutter dependency/build workflow before making manual Podfile changes.

## 10. Flutter Pub versus CocoaPods

```bash
flutter pub get
```

resolves Dart/Flutter packages.

CocoaPods resolves native Apple dependencies declared/generated through the Apple platform project/plugin integration.

A Flutter plugin can participate in both layers: Dart package through Pub and native Apple library/framework through Pods.

## 11. `Podfile`

The Apple platform project can contain Podfile configuration defining CocoaPods integration/deployment behavior.

Do not replace it with a generic internet example because project/Flutter/plugin requirements can differ.

## 12. `Podfile.lock`

When present, the lockfile records resolved Pod versions and contributes to native dependency reproducibility.

Review changes instead of deleting the lockfile whenever a dependency mismatch occurs.

## 13. `pod install`

Within the appropriate Apple platform directory, CocoaPods can install the native dependencies defined by the Podfile/lock state:

```bash
pod install
```

In ordinary Flutter workflows, let Flutter's documented commands orchestrate Apple dependencies unless diagnosing a native Pod problem.

## 14. `pod repo update` caution

Refreshing CocoaPods repository metadata can change what versions are resolvable.

Do not run broad dependency-refresh commands simply to silence every error. First inspect the exact Pod/dependency constraint and Flutter/plugin requirements.

## 15. iOS Simulator

Open Simulator:

```bash
open -a Simulator
```

List Flutter-visible devices:

```bash
flutter devices
```

Run:

```bash
flutter run
```

or:

```bash
flutter run -d <device-id>
```

Simulator is useful for development but does not replace real iPhone/iPad qualification.

## 16. Simulator runtimes

Xcode manages Simulator runtimes. After a major Xcode update, old simulator runtimes may be unavailable or newer runtimes may need installation.

Use Xcode's supported platform/settings UI to manage them rather than manually copying simulator folders.

## 17. macOS desktop run

Enable macOS desktop support:

```bash
flutter config --enable-macos-desktop
```

Run:

```bash
flutter run -d macos
```

## 18. macOS release build

```bash
flutter build macos --release
```

Output is a `.app` bundle. Preserve the complete bundle.

Compilation alone does not imply Developer ID signing, notarization, DMG/PKG packaging, or Mac App Store acceptance.

## 19. Unsigned iOS release compilation

```bash
flutter build ios --release --no-codesign
```

This is valuable CI/source qualification because it verifies release compilation without requiring private signing credentials.

It is not a distributable App Store IPA.

## 20. Signed iOS IPA

When legitimate Apple developer/distribution identity and provisioning are configured:

```bash
flutter build ipa --release
```

This produces/archive-exports iOS distribution output according to available signing/export configuration.

## 21. Code signing

Code signing uses a private key and certificate identity to sign application code/artifacts.

Do not commit:

- private `.p12` files;
- private keys;
- certificate passwords;
- App Store Connect API private keys;
- signing tokens;
- private provisioning data where disclosure is unsafe.

## 22. Provisioning profile

A provisioning profile links app identity/capabilities/certificate/distribution context according to Apple's platform model.

A successful unsigned build does not prove provisioning is configured.

## 23. Bundle identifier

The iOS/macOS bundle identifier identifies the app in Apple's ecosystem.

Changing it is not merely cosmetic; it can affect signing, provisioning, store identity, keychain/container behavior, entitlements, and upgrades.

Do not change it while troubleshooting unrelated source errors.

## 24. Team selection

Xcode signed builds require an appropriate development team/account context.

Keep account credentials in Xcode/Apple-supported secure configuration, not committed source.

## 25. Automatic signing versus manual signing

Xcode can manage signing automatically or use explicitly managed provisioning depending on release policy.

Whichever mode is used for an authorized release, document it operationally and validate the exact archive/export artifact.

Do not mix a hosted unsigned CI artifact with a claim of production signing.

## 26. Entitlements

Entitlements declare Apple-platform capabilities.

Adding an entitlement can affect:

- signing/provisioning;
- sandbox access;
- privacy/security;
- App Store review;
- runtime capability.

Only add capabilities required by implemented features.

## 27. macOS sandbox

macOS app sandbox entitlements can restrict filesystem/network/system access.

File backup/export behavior should be tested with the actual final sandbox/signing configuration because host permissions can differ from a debug environment.

## 28. Notarization

Notarization is an Apple distribution trust process for macOS software.

It is separate from:

- compiling the `.app`;
- code signing;
- compressing it into a ZIP.

Do not claim a macOS artifact is notarized unless it was submitted/accepted/stapled or otherwise verified according to the actual release process.

## 29. Xcode archive

Xcode's archive process creates an archived build suitable for export/distribution workflows.

Flutter's `flutter build ipa --release` can drive the iOS archive/export path, but Xcode Organizer remains useful for inspecting archives/signing/export diagnostics.

## 30. Xcode Organizer

Organizer helps inspect archives, distribution/signing status, crash data, and related Apple development workflows.

Use it for real release diagnostics rather than storing private distribution credentials in project files.

## 31. Update Xcode

Use Apple's supported update method.

After update:

```bash
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
sudo xcodebuild -runFirstLaunch
xcodebuild -version
flutter doctor -v
```

Then:

```bash
flutter pub get
flutter build macos --release
flutter build ios --release --no-codesign
```

If you maintain signed distribution, revalidate signed archive/export too.

## 32. Xcode major upgrade implications

A major Xcode release can change:

- Swift/Clang compiler behavior;
- iOS/macOS SDK versions;
- minimum deployment requirements;
- signing/provisioning UI/behavior;
- simulator runtimes;
- build settings/warnings;
- generated project compatibility.

Treat it as a toolchain migration, not a simple editor upgrade.

## 33. Unsupported Xcode release

If Xcode becomes unsupported by Apple/Flutter or cannot satisfy store SDK requirements:

- upgrade macOS if the newer Xcode requires it and the Mac supports it;
- install a supported Xcode;
- select/run first-launch setup;
- update CocoaPods only if compatible/required;
- run Flutter Doctor and Apple builds;
- revalidate signing/provisioning/store metadata.

See [`UPGRADING_AND_SUPPORT.md`](UPGRADING_AND_SUPPORT.md).

## 34. Unsupported macOS host

If the Mac's operating system cannot run the Xcode release required by Flutter/store policy, the durable solution is a supported Mac/macOS build environment.

Keeping an EOL Xcode forever is not a release strategy.

## 35. Multiple Xcode installations

Some developers keep stable and alternate Xcode versions side by side.

Check the selected path:

```bash
xcode-select -p
xcodebuild -version
```

Switch only to a known installed Xcode path.

Do not run qualification without recording which Xcode was actually selected.

## 36. Common error: Xcode not fully installed

If Flutter Doctor reports missing Xcode components:

```bash
xcodebuild -version
xcode-select -p
sudo xcodebuild -runFirstLaunch
```

Complete any required Xcode setup/license/platform installation through supported tooling.

## 37. Common error: CocoaPods not installed

```bash
pod --version
```

If not found, install using one supported method, then:

```bash
flutter doctor -v
```

## 38. Common error: wrong CocoaPods executable

```bash
which pod
type -a pod
```

Multiple results can explain why upgrading one installation did not change the one Flutter uses.

## 39. Common error: deployment target mismatch

A plugin/Xcode can require a newer minimum iOS/macOS deployment target.

Do not raise deployment targets blindly. Check:

- Flutter's supported baseline;
- plugin minimum requirements;
- current project target/support policy;
- real device OS support expectations.

Then update intentionally and test.

## 40. Common error: signing certificate/profile missing

Unsigned qualification can still compile with:

```bash
flutter build ios --release --no-codesign
```

For actual signed distribution, configure the authorized Apple identity/profile rather than disabling signing requirements in a supposed store artifact.

## 41. Common error: Pod dependency conflict

Start with:

```bash
flutter pub get
pod --version
```

Inspect the first dependency constraint conflict. Review plugin/Podfile/lockfile/Xcode deployment requirements.

Do not immediately delete all Pods/lockfiles/caches without understanding what versions are supposed to resolve.

## 42. Common error: stale generated build

```bash
flutter clean
flutter pub get
flutter build ios --release --no-codesign
```

or:

```bash
flutter build macos --release
```

If the same compiler/signing error returns, fix its root cause.

## 43. DerivedData

Xcode stores generated/index/build data under DerivedData.

Clearing DerivedData can help with genuinely stale Xcode intermediates but is not the first fix for invalid source, signing, or dependency constraints.

Use Xcode-supported settings/location cleanup when needed.

## 44. Native project files

Tracked Apple runner source lives under:

```text
ios/
macos/
```

Do not overwrite these folders blindly with a new Flutter template. Compare project-specific:

- bundle identifiers;
- entitlements;
- Info.plist values;
- branding/assets;
- signing/build settings;
- deployment targets;
- Flutter migration changes.

## 45. Info.plist

Info.plist carries application metadata and permission-purpose strings/capabilities on Apple platforms.

Only add privacy-sensitive usage descriptions for features actually implemented and requiring them.

## 46. Privacy manifests and platform policy

Apple platform requirements can evolve independently of Flutter source scope.

When Xcode/App Store policies introduce new metadata/privacy manifest obligations, treat them as platform-maintenance work with dependency and store validation—not as an excuse to add unrelated application permissions/features.

## 47. Real-device requirement

Simulator success does not prove:

- real touch/input behavior;
- performance/memory on actual devices;
- file/share/external-handler behavior;
- device-specific accessibility;
- signed installation;
- store behavior.

The repository keeps these as genuine manual qualification boundaries.

## 48. First Apple toolchain verification

```bash
xcodebuild -version
xcode-select -p
pod --version
flutter --version
flutter doctor -v
flutter pub get
dart format --output=none --set-exit-if-changed lib test tool
flutter analyze
flutter test
flutter build macos --release
flutter build ios --release --no-codesign
```

## 49. Related documentation

- [`MACOS.md`](MACOS.md) — complete macOS/iOS host setup.
- [`FLUTTER_AND_DART.md`](FLUTTER_AND_DART.md) — Flutter SDK.
- [`UPGRADING_AND_SUPPORT.md`](UPGRADING_AND_SUPPORT.md) — support/EOL migration.
- [`../build/IOS.md`](../build/IOS.md) — iOS builds.
- [`../build/MACOS.md`](../build/MACOS.md) — macOS builds.
- [`../build/SIGNING_AND_DISTRIBUTION.md`](../build/SIGNING_AND_DISTRIBUTION.md) — signing boundaries.
- [`../COMMAND_REFERENCE.md`](../COMMAND_REFERENCE.md) — command meanings.
