# Android Studio Handbook for 2048 Nova

This guide explains **Android Studio** as used by 2048 Nova: installation, Flutter/Dart plugins, Android SDK Manager, Device Manager/AVDs, bundled JDK/JBR, Gradle integration, Logcat, ADB, updates, caches, support lifecycle, and troubleshooting.

Android Studio is optional as a Dart editor, but it is the most convenient supported graphical manager for the Android SDK and Android Emulator.

## 1. Android Studio is not the Android SDK

These are related but different:

- **Android Studio** — Google's Android IDE.
- **Android SDK** — platform APIs and build/device command-line packages.
- **Android Emulator** — virtual Android device runtime.
- **AVD** — Android Virtual Device configuration.
- **ADB** — Android Debug Bridge from Platform-Tools.
- **JDK/JBR** — Java development/runtime environment used by Gradle/Android tooling.
- **Gradle** — build automation engine.
- **AGP** — Android Gradle Plugin.
- **Kotlin plugin** — Kotlin build/compiler integration.

Updating Android Studio does not automatically mean the repository should change AGP, Gradle, Kotlin, or Flutter pins.

## 2. Current project Android baseline

```text
Flutter CI baseline: 3.47.0 stable
AGP: 9.1.0
Kotlin Android plugin: 2.4.10
Gradle Wrapper: 9.7.0
Java/Kotlin bytecode target: 17
Application ID: com.sanskarin.nova_2048
```

See [`ANDROID.md`](ANDROID.md) for the complete toolchain relationship.

## 3. Install Android Studio

Use Google's official stable installer for the host operating system.

### Windows with WinGet

If the package is available in your configured WinGet source:

```powershell
winget install --id Google.AndroidStudio -e
```

Otherwise use the official installer.

### macOS/Linux

Use Google's supported installation package/instructions for that operating system. Do not mix several unrelated package-management methods unless you know which installation is active.

## 4. First-run setup wizard

On the first launch, Android Studio normally offers a setup wizard.

Install the recommended Android SDK components for the supported Flutter stable toolchain. The exact latest API/build-tool package may change over time, so use Flutter Doctor and Google's SDK Manager rather than hard-coding a permanently “latest” API number in this guide.

## 5. SDK Manager

Open Android Studio's **SDK Manager**.

It manages package families such as:

- Android SDK Platforms;
- Android SDK Build-Tools;
- Android SDK Platform-Tools;
- Android SDK Command-line Tools;
- Android Emulator;
- NDK/CMake packages when required;
- system images.

The project delegates several Android SDK/NDK values to the active Flutter SDK to stay aligned with Flutter's supported Android template/toolchain expectations.

## 6. Typical Android SDK location

Windows commonly uses:

```text
%LOCALAPPDATA%\Android\Sdk
```

macOS commonly uses a user Library Android SDK directory.

Linux commonly uses a user Android SDK directory.

Do not rely only on a guessed default. Check Android Studio settings and:

```bash
flutter doctor -v
```

The path Flutter actually reports is more important than a remembered default.

## 7. Command-line Tools

Install **Android SDK Command-line Tools** through SDK Manager.

This supplies tools such as `sdkmanager`.

Verify, when on `PATH`:

```bash
sdkmanager --list
```

If `sdkmanager` is not on `PATH`, Android Studio can still manage SDK packages through its UI.

## 8. Platform-Tools and ADB

Install **Android SDK Platform-Tools**.

Verify:

```bash
adb version
adb devices
```

ADB is used for physical/emulated Android device communication.

Flutter's view:

```bash
flutter devices
```

## 9. Android licenses

Run:

```bash
flutter doctor --android-licenses
```

This starts an interactive license review for Android SDK components required by Flutter.

Read the agreements before accepting them.

## 10. Flutter plugin for Android Studio

Open Android Studio's plugin settings and install the **Flutter** plugin.

The Flutter plugin provides:

- Flutter project awareness;
- run/debug integration;
- Flutter device selection;
- project creation/support actions;
- Dart integration.

The Dart plugin is normally installed/enabled as part of the Flutter plugin dependency chain.

The project still builds from the CLI without this IDE plugin.

## 11. Open the repository correctly

Open the repository root containing:

```text
pubspec.yaml
lib/
android/
test/
tool/
```

Do not open only `android/` if your goal is ordinary Flutter application development, because Android Studio would then treat the project mainly as a native Android Gradle project rather than the complete Flutter project.

Opening `android/` separately can still be useful for Android-specific Gradle inspection when deliberately needed.

## 12. Resolve Flutter packages

From the terminal at repository root:

```bash
flutter pub get
```

Android Studio may offer package actions through its Flutter integration, but the CLI command is the portable source of truth.

## 13. Bundled Java runtime / JBR

Android Studio includes a JetBrains Runtime and Java development tooling suitable for supported Android Studio/AGP workflows.

Check which Java Flutter chooses:

```bash
flutter doctor -v
```

Also inspect shell Java if needed:

```bash
java -version
javac -version
```

The project targets JVM 17 for Android Java/Kotlin compilation.

## 14. Selecting a JDK explicitly

Only do this when you have a clear compatibility reason:

```bash
flutter config --jdk-dir="/absolute/path/to/jdk17"
```

Then rerun:

```bash
flutter doctor -v
cd android
./gradlew --version
```

Windows uses `gradlew.bat` instead of `./gradlew`.

Do not point Flutter at a JRE-only directory.

## 15. Gradle in Android Studio

Android Studio can import/sync the native Android Gradle project, but this repository controls Gradle through the **Gradle Wrapper**.

Current wrapper:

```text
Gradle 9.7.0
```

Verify on Windows:

```powershell
cd android
.\gradlew.bat --version
```

macOS/Linux:

```bash
cd android
./gradlew --version
```

Do not change the project to use a random globally installed Gradle merely because Android Studio has another Gradle version available.

## 16. Gradle sync

Android Studio may perform a **Gradle sync** when opening `android/` or after Gradle-file changes.

Sync means Android Studio asks Gradle to evaluate project configuration/dependencies so IDE features match the build.

A sync failure is diagnostic information. Read the first root-cause error rather than repeatedly pressing Sync or invalidating caches.

## 17. AGP and Kotlin pins

The project pins these in `android/settings.gradle.kts`:

```text
com.android.application 9.1.0
org.jetbrains.kotlin.android 2.4.10
```

Android Studio may suggest newer versions. Do not accept an automatic upgrade without checking Flutter/Gradle/JDK compatibility and running the complete Android/native validation cycle.

## 18. Device Manager

Android Studio's **Device Manager** creates and manages Android Virtual Devices.

An AVD normally defines:

- device hardware profile;
- Android system image/API level;
- architecture;
- storage/memory options;
- graphics/emulation settings.

Create an AVD suitable for your host and testing goals, then verify it through Flutter.

## 19. Launch an emulator

From Android Studio Device Manager, start the AVD.

Or use Flutter:

```bash
flutter emulators
flutter emulators --launch <emulator-id>
```

Then:

```bash
flutter devices
```

## 20. Emulator hardware acceleration

The Android Emulator can use host virtualization/hardware acceleration.

If an emulator is extremely slow or refuses to start, verify:

- CPU virtualization support is enabled where required;
- the host OS virtualization stack is configured correctly;
- the selected system image supports the host architecture;
- Android Emulator is updated to a compatible stable release;
- no conflicting hypervisor configuration blocks it.

The exact acceleration technology differs by OS/CPU generation, so follow current Android Emulator documentation for the host.

## 21. Physical device debugging

For an owned/authorized device:

1. enable developer options according to device/vendor instructions;
2. enable USB debugging;
3. connect the device;
4. approve the computer's ADB authorization prompt;
5. verify:

```bash
adb devices
flutter devices
```

Do not enable debugging on devices you are not authorized to administer.

## 22. `unauthorized` device

If:

```bash
adb devices
```

shows `unauthorized`, unlock the device and approve the debugging-key prompt.

If the prompt does not appear, verify USB mode/cable/driver and revoke/re-authorize debugging keys only according to the device's normal developer settings.

## 23. Windows USB drivers

Some Android vendors require a USB driver on Windows for ADB/device recognition.

Prefer the device manufacturer's supported driver or Google USB driver where appropriate. Do not download random unsigned drivers from unknown sites.

## 24. Logcat

**Logcat** shows Android system/application logs.

Android Studio provides a Logcat tool window.

CLI alternative:

```bash
adb logcat
```

Flutter application logs also appear through:

```bash
flutter run
```

Use logs to identify actual exceptions/plugin/native errors rather than guessing from a frozen screen.

## 25. Run from Android Studio

Select an Android target and use Run/Debug.

CLI equivalent:

```bash
flutter run
```

Explicit Android device ID:

```bash
flutter run -d <device-id>
```

## 26. Build release artifacts from the CLI

APK:

```bash
flutter build apk --release
```

AAB:

```bash
flutter build appbundle --release
```

The CLI is preferred for documented/reproducible release procedures because it is portable and maps directly to CI.

## 27. Build Variants panel

Native Android Studio projects can expose build variants. For this Flutter project, ordinary release/debug selection should follow Flutter commands unless a native Android debugging task specifically requires the Gradle variant UI.

Do not assume a native Gradle variant assembled manually has the same packaging/signing semantics as the documented Flutter release command.

## 28. Signing configuration

The repository's `android/app/build.gradle.kts` checks for ignored `android/key.properties` and a private keystore for distribution signing.

Android Studio can inspect signing-related Gradle behavior, but production secrets must stay outside Git.

Never paste keystore passwords into a tracked Gradle file just to make Android Studio stop asking for configuration.

## 29. `local.properties`

Android/Flutter tooling uses a machine-local `android/local.properties` for SDK paths.

This file is machine-specific and should not be treated as portable source configuration.

If Flutter/Android Studio regenerates it, do not commit another developer's absolute SDK path into public source.

## 30. Android manifest editing

Manifest:

```text
android/app/src/main/AndroidManifest.xml
```

Android Studio can provide structured editing/navigation.

Any permission/component change must be reviewed for:

- real feature requirement;
- privacy impact;
- store policy;
- security exposure;
- tests/documentation.

Do not add network/camera/storage permissions simply because an IDE warning suggests a template example.

## 31. SDK update through Android Studio

Use SDK Manager to update installed SDK packages.

After significant SDK changes:

```bash
flutter doctor -v
cd android
./gradlew --version
cd ..
flutter build apk --release
flutter build appbundle --release
```

## 32. Update Android Studio

Use Android Studio's stable updater or official installer.

After updating:

1. restart Android Studio;
2. confirm SDK path;
3. verify Flutter plugin compatibility;
4. review SDK Manager;
5. run `flutter doctor -v`;
6. run Gradle wrapper version check;
7. build Android release outputs.

## 33. Do not accept all IDE upgrade suggestions automatically

Android Studio may suggest:

- AGP upgrades;
- Gradle upgrades;
- Kotlin upgrades;
- SDK target upgrades;
- migration of Gradle DSL/configuration.

Each can change repository-controlled source. Review the diff and project compatibility first.

## 34. Unsupported Android Studio version

If your Android Studio release reaches end-of-support or becomes incompatible with current Flutter/SDK requirements:

- install a vendor-supported stable release;
- preserve the project source in Git;
- re-check SDK/JDK paths;
- keep the repository's AGP/Gradle/Kotlin pins unless the migration explicitly requires changing them;
- run complete validation.

See [`UPGRADING_AND_SUPPORT.md`](UPGRADING_AND_SUPPORT.md).

## 35. Invalidate Caches warning

Android Studio provides cache invalidation/restart tools.

Use them only when there is evidence of an IDE-index/cache issue, such as stale code navigation despite successful CLI builds.

Cache invalidation does not fix:

- invalid Dart source;
- incompatible Gradle/JDK;
- missing SDK licenses;
- bad signing properties;
- missing Android SDK package.

## 36. `flutter clean` versus IDE caches

`flutter clean` clears project build outputs.

Android Studio cache invalidation clears/rebuilds IDE indexing caches.

They solve different classes of problems.

## 37. Gradle cache

Gradle caches dependencies/tooling under user-level directories.

Do not delete the entire global Gradle cache as the first reaction to every Gradle error. First inspect:

```bash
cd android
./gradlew --version
./gradlew tasks
./gradlew help --warning-mode=all
```

Use `gradlew.bat` on Windows.

## 38. SDK package missing error

If a build reports a missing Android platform/build tool/NDK component:

1. note the exact package/version requested;
2. check SDK Manager or `sdkmanager --list`;
3. install the compatible requested component;
4. rerun `flutter doctor -v`;
5. retry the build.

Do not change project SDK levels merely to avoid installing a required component without understanding the compatibility impact.

## 39. Java compatibility error

Check:

```bash
flutter doctor -v
java -version
cd android
./gradlew --version
```

The Gradle output shows which JVM actually starts Gradle.

A system Java command can differ from Android Studio/Flutter's selected JDK.

## 40. Gradle daemon

Gradle may use background daemon processes to speed builds.

If a daemon is stale after a JDK/toolchain switch, normal Gradle/IDE restart behavior may replace it. Do not kill arbitrary Java processes unless you know which build they belong to.

## 41. Proxy/network configuration

Android Studio/Gradle/SDK Manager need network access to download packages/dependencies.

If downloads fail behind a proxy/firewall:

- use organization/network-approved proxy settings;
- check Gradle/Android Studio proxy configuration;
- do not disable TLS/security validation;
- do not download build dependencies from untrusted mirrors as a shortcut.

## 42. Flutter plugin update

Update Android Studio's Flutter/Dart plugins through the plugin manager.

After a major plugin update, confirm:

```bash
flutter --version
flutter analyze
flutter devices
```

Editor plugin version does not change the repository's Flutter SDK pin by itself.

## 43. Android Studio memory usage

Large IDEs/emulators can consume substantial RAM/disk space.

Safe cleanup targets are typically vendor-documented caches/unused SDK images/old emulator snapshots—not project source or private keys.

Before removing an SDK platform/system image, confirm no maintained build/AVD needs it.

## 44. Remove unused emulator images

Use SDK Manager/Device Manager to remove unused AVDs/system images.

Do not manually delete random folders inside the SDK because package metadata can become inconsistent.

## 45. Multiple Android SDK installations

Check Android Studio SDK path and:

```bash
flutter doctor -v
```

If `adb`/`sdkmanager` resolve from a different SDK than Flutter, inspect PATH and environment variables.

Windows:

```powershell
where.exe adb
where.exe sdkmanager
```

macOS/Linux:

```bash
type -a adb
type -a sdkmanager
```

## 46. SDK environment variables

Modern tooling can often discover the SDK without manually setting every Android environment variable, but scripts may use `ANDROID_HOME`/related paths.

If you configure one, keep it consistent with Android Studio and Flutter Doctor. Do not point it to an incomplete copied SDK.

## 47. First complete Android Studio verification

From the repository root after setup:

```bash
flutter --version
flutter doctor -v
flutter devices
flutter pub get
dart format --output=none --set-exit-if-changed lib test tool
flutter analyze
flutter test
cd android
./gradlew --version
cd ..
flutter build apk --release
flutter build appbundle --release
```

On Windows use `gradlew.bat`.

## 48. Related documentation

- [`ANDROID.md`](ANDROID.md) — complete Android toolchain reference.
- [`WINDOWS.md`](WINDOWS.md) — Windows host setup.
- [`MACOS.md`](MACOS.md) — macOS host setup.
- [`LINUX.md`](LINUX.md) — Linux host setup.
- [`FLUTTER_AND_DART.md`](FLUTTER_AND_DART.md) — Flutter/Dart SDK.
- [`UPGRADING_AND_SUPPORT.md`](UPGRADING_AND_SUPPORT.md) — EOL/support migration.
- [`../ANDROID_TOOLCHAIN.md`](../ANDROID_TOOLCHAIN.md) — repository-specific accepted baseline.
- [`../build/ANDROID.md`](../build/ANDROID.md) — Android builds.
- [`../COMMAND_REFERENCE.md`](../COMMAND_REFERENCE.md) — command meanings.
