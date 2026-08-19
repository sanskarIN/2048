# Android Toolchain Setup and Maintenance

This guide explains every major Android development tool used by **2048 Nova**, how the tools relate to each other, how to verify them, how to build APK/AAB artifacts, and how to upgrade without breaking the repository's tested compatibility baseline.

Checked against the repository on **2026-08-19**.

## 1. Current accepted Android baseline

The live repository currently uses:

```text
Flutter CI baseline: 3.47.0 stable
Android Gradle Plugin (AGP): 9.1.0
Kotlin Android plugin: 2.4.10
Gradle Wrapper: 9.7.0
Java/Kotlin target: JVM 17
compileSdk: supplied by the active Flutter SDK
minSdk: supplied by the active Flutter SDK
targetSdk: supplied by the active Flutter SDK
Application ID: com.sanskarin.nova_2048
```

The source of truth is `android/settings.gradle.kts`, `android/app/build.gradle.kts`, and `android/gradle/wrapper/gradle-wrapper.properties`.

## 2. Android Studio

**Android Studio** is Google's official Android IDE. For this Flutter project it is primarily useful for:

- installing/updating Android SDK packages;
- creating and managing emulators;
- examining native Android logs/configuration;
- editing Gradle/Kotlin/manifest files;
- inspecting signing/build configuration;
- running Android-specific debugging tools.

Flutter source can still be edited in VS Code or another editor. Android Studio is not the same as the Android SDK; the SDK is a collection of command-line/build/device tools installed separately through Android Studio or command-line management.

## 3. Android SDK

The Android SDK is a family of packages rather than one executable.

Important components include:

- **SDK Platform** — APIs/resources for a specific Android API level.
- **Build-Tools** — packaging/signing/build utilities used by Android builds.
- **Platform-Tools** — device tools such as `adb`.
- **Command-line Tools** — includes `sdkmanager` and related SDK administration tools.
- **Emulator** — Android virtual-device runtime.
- **System Image** — Android OS image used by an emulator/AVD.

Flutter and AGP determine which package levels are compatible with a build. Do not hard-code a random API level into documentation when the project intentionally consumes Flutter's configured SDK values.

## 4. Install Android Studio and SDK packages

Use Android Studio's official stable installer for your host OS. Complete its first-run setup and open **SDK Manager**.

Install the current SDK packages required by the supported Flutter stable toolchain, including Android SDK Command-line Tools and Platform-Tools.

Then verify:

```bash
flutter doctor -v
```

Flutter's doctor report is the primary project-facing check because it shows which Android SDK and Java installation Flutter will actually use.

## 5. Android SDK licenses

Run:

```bash
flutter doctor --android-licenses
```

This command starts an interactive review of Android SDK license agreements needed by the installed toolchain.

Do not script “yes to everything” without understanding the agreements. License acceptance is a workstation/environment step and is not committed to this repository.

## 6. ADB

`adb` means **Android Debug Bridge**. It communicates with Android devices/emulators.

Verify:

```bash
adb version
adb devices
```

`adb devices` shows devices that the ADB server can see. A physical device may appear as `unauthorized` until the user approves the computer's debugging key on the device.

Flutter's higher-level view is:

```bash
flutter devices
```

A device appearing in ADB but not Flutter can indicate unsupported architecture/API/toolchain state or another Flutter diagnostic problem.

## 7. Physical-device development

To use an owned/authorized Android device for development:

1. enable Android's developer options according to the device vendor/Android version;
2. enable USB debugging;
3. connect with a trusted cable/connection;
4. approve the computer's debugging authorization on the device;
5. verify with `adb devices` and `flutter devices`.

The exact Settings path can change by Android/vendor release. Follow the device vendor's current documentation.

Do not enable debugging on devices you do not own or have authorization to administer.

## 8. Emulator and AVD

An **AVD** is an Android Virtual Device configuration. The **Android Emulator** runs that configuration.

Android Studio's Device Manager is the easiest way to create/manage AVDs.

Flutter can list configured emulators:

```bash
flutter emulators
```

Launch one:

```bash
flutter emulators --launch <emulator-id>
```

Then:

```bash
flutter devices
flutter run
```

Choose a system image suitable for your host and testing requirements. Emulator success does not replace real-device qualification for production claims.

## 9. JDK 17

A **JDK** (Java Development Kit) contains the Java runtime plus compiler/build-development tools.

This repository configures Java/Kotlin bytecode for version 17. Verify the JDK Flutter uses:

```bash
flutter doctor -v
```

Also inspect Java directly when useful:

```bash
java -version
javac -version
```

If an explicit JDK must be selected:

```bash
flutter config --jdk-dir="/absolute/path/to/jdk17"
```

On Windows use a Windows path. Do not point this option to a JRE-only installation.

## 10. Gradle

**Gradle** is Android's build automation engine. The project does not rely on whatever `gradle` happens to be globally installed.

Instead it uses the **Gradle Wrapper**:

Windows:

```powershell
cd android
.\gradlew.bat --version
```

macOS/Linux:

```bash
cd android
./gradlew --version
```

The wrapper configuration pins Gradle `9.7.0` and verifies its distribution checksum.

### Why the Wrapper matters

The wrapper makes contributors/CI use the project-selected Gradle version. It reduces “works on my machine” failures caused by different system Gradle installations.

## 11. Android Gradle Plugin (AGP)

**AGP** is Google's Gradle plugin that teaches Gradle how to build Android applications/libraries.

This project currently pins:

```text
com.android.application 9.1.0
```

AGP and Gradle have compatibility requirements. An AGP update can also require changes to JDK, Android SDK, manifests, DSL syntax, lint behavior, packaging, or plugins.

Therefore AGP must not be upgraded independently merely because a newer version exists.

## 12. Kotlin Android plugin

The Android host code/build uses Kotlin tooling. The project currently pins:

```text
org.jetbrains.kotlin.android 2.4.10
```

The Flutter application itself is mostly Dart; Kotlin is used for Android-side integration/build configuration where required.

Kotlin, AGP, Gradle, JDK, and Flutter compatibility must be considered as one toolchain system.

## 13. `compileSdk`, `targetSdk`, and `minSdk`

These terms are related but different:

- **compileSdk** — Android API level whose APIs/resources are used to compile the app.
- **targetSdk** — API level against which the app declares its tested/behavioral target; Android can apply compatibility behavior based on this value.
- **minSdk** — oldest Android API level on which installation is allowed.

This repository delegates these values to Flutter's supported defaults through `flutter.compileSdkVersion`, `flutter.targetSdkVersion`, and `flutter.minSdkVersion`. That intentionally keeps the Android runner aligned with the selected Flutter toolchain.

## 14. NDK

**NDK** means Android Native Development Kit. Flutter/plugins may use native C/C++ components. The project uses:

```text
ndkVersion = flutter.ndkVersion
```

This means the repository follows the NDK version expected by the selected Flutter SDK instead of independently hard-coding another NDK.

## 15. Android application ID and namespace

The app currently uses:

```text
namespace: com.sanskarin.nova_2048
applicationId: com.sanskarin.nova_2048
```

The `applicationId` is the Android package identity used for installation/store identity. Changing it creates a different app identity from Android/store perspective and is not a routine refactor.

The `namespace` controls generated/source namespace behavior in the Android module.

## 16. Debug, profile, and release modes

Flutter supports build modes with different purposes:

- **debug** — development, assertions/debug services, fastest iteration/hot reload workflow.
- **profile** — performance profiling on supported devices while retaining profiling instrumentation.
- **release** — optimized production-style build with debug facilities removed/reduced.

Build examples:

```bash
flutter build apk --debug
flutter build apk --profile
flutter build apk --release
```

## 17. APK

**APK** means Android Package. It is an installable Android application package.

Release APK:

```bash
flutter build apk --release
```

ABI splits:

```bash
flutter build apk --release --split-per-abi
```

A split-per-ABI build creates architecture-specific APKs. Do not give a user an arbitrary split APK without knowing their device architecture.

## 18. AAB

**AAB** means Android App Bundle. It is a publishing bundle used by stores such as Google Play to generate optimized APK sets for devices.

Build:

```bash
flutter build appbundle --release
```

An AAB is not normally installed directly on a phone by tapping the file.

## 19. Signing

Android requires application packages to be signed. This repository deliberately separates two cases.

### Local distribution signing

If private, ignored `android/key.properties` is present with valid keystore details, the Gradle configuration uses the real release signing configuration.

### Hosted qualification fallback

If the private signing properties are absent, the repository permits release-mode compilation/package qualification using debug signing. That proves buildability but **does not make the hosted artifact a production-signed Play release**.

Never commit:

- keystore files;
- keystore passwords;
- key passwords;
- private aliases/credentials where disclosure matters;
- Play Console/service-account secrets.

See [`../build/SIGNING_AND_DISTRIBUTION.md`](../build/SIGNING_AND_DISTRIBUTION.md).

## 20. `key.properties`

The project provides a safe example/template. A real local file typically points Gradle to a private keystore and credentials.

Because the real file is ignored by Git, each authorized release environment must provision it securely.

If release signing fails, check paths relative to the Android project and verify the keystore exists. Do not solve a signing error by committing the private keystore.

## 21. Dependency resolution

Before Android builds:

```bash
flutter pub get
```

Flutter dependencies may contain Android native plugin code. A plugin upgrade can therefore affect Gradle, Kotlin, manifests, permissions, SDK requirements, or native APIs even when application Dart code looks unchanged.

## 22. Inspect available Android SDK packages

When `sdkmanager` is available:

```bash
sdkmanager --list
```

Update installed SDK packages:

```bash
sdkmanager --update
```

Install a named package:

```bash
sdkmanager --install "platform-tools"
```

For reproducible automation, pin exact SDK package identifiers/versions rather than relying on an unspecified newest package.

## 23. Inspect Gradle deprecations

Before considering a Gradle/AGP upgrade:

```bash
cd android
./gradlew help --warning-mode=all
```

Windows:

```powershell
cd android
.\gradlew.bat help --warning-mode=all
```

This exposes deprecated Gradle behavior that may become errors in a later Gradle release.

## 24. Safe Android toolchain upgrade order

Do not upgrade AGP, Kotlin, Gradle, JDK, Flutter, Android Studio, and SDK levels all in one unreviewed step.

A safer process is:

1. record the current passing baseline;
2. create a maintenance branch;
3. read Flutter/Android/Gradle/Kotlin compatibility notes;
4. change the smallest necessary layer;
5. run `flutter doctor -v`;
6. run `flutter pub get`;
7. inspect Gradle version/deprecation output;
8. format/analyze/test;
9. run repository audits;
10. build release APK and AAB;
11. verify native CI matrix;
12. perform real-device qualification for changed behavior;
13. update toolchain docs and CI pins only when adoption is intentional.

## 25. When a tool is out of support

If Android Studio, JDK, Flutter, AGP, Kotlin, Gradle, an SDK API level, or another component reaches end-of-support:

- do not keep it forever merely because the old build still works;
- do not jump directly to unrelated newest versions without compatibility review;
- first determine vendor-supported replacement versions;
- identify transitive compatibility constraints;
- upgrade on a branch;
- keep the old lock/pins recoverable in Git;
- run the full project validation matrix;
- update documentation and CI together.

See [`UPGRADING_AND_SUPPORT.md`](UPGRADING_AND_SUPPORT.md) for the complete lifecycle policy.

## 26. First Android diagnostic sequence

```bash
flutter --version
flutter doctor -v
flutter devices
flutter pub get
```

Then from `android/`:

```bash
./gradlew --version
```

Then project checks:

```bash
dart format --output=none --set-exit-if-changed lib test tool
flutter analyze
flutter test
```

Finally retry only the target that failed:

```bash
flutter build apk --release
```

or:

```bash
flutter build appbundle --release
```

## 27. Common failures and meanings

### `flutter.sdk not set in local.properties`

The Android settings script needs Flutter's generated/local SDK path information. Run Flutter from the repository root and ensure the project was prepared normally; do not commit machine-specific `local.properties`.

### Wrong Java/JDK

Symptoms can include Gradle startup failure, unsupported class versions, or plugin compatibility errors. Check `flutter doctor -v` and the Gradle wrapper's version/JVM output.

### SDK licenses not accepted

Run:

```bash
flutter doctor --android-licenses
```

### Device unauthorized

Check:

```bash
adb devices
```

Approve debugging authorization on the owned/authorized device.

### Signing property error

For distribution signing, verify the ignored `key.properties` values and private keystore path. Do not disable validation merely to generate a package.

## 28. Android release verification

Before treating an APK/AAB as a candidate artifact:

```bash
flutter pub get
dart format --output=none --set-exit-if-changed lib test tool
flutter analyze
flutter test --coverage
dart run tool/release_readiness.dart --json
dart run tool/repository_audit.dart --json
dart run tool/source_completion_audit.dart --json
flutter build apk --release
flutter build appbundle --release
```

Then verify signing identity/checksums and perform the real-device/store qualification required by the project's release policy.

## 29. Related documentation

- [`PREREQUISITES.md`](PREREQUISITES.md) — complete tool inventory.
- [`WINDOWS.md`](WINDOWS.md) — Windows host setup.
- [`MACOS.md`](MACOS.md) — macOS/iOS host setup.
- [`LINUX.md`](LINUX.md) — Linux host setup.
- [`UPGRADING_AND_SUPPORT.md`](UPGRADING_AND_SUPPORT.md) — support/EOL and upgrade lifecycle.
- [`../ANDROID_TOOLCHAIN.md`](../ANDROID_TOOLCHAIN.md) — repository-specific accepted Android baseline/evidence.
- [`../build/ANDROID.md`](../build/ANDROID.md) — Android artifact handbook.
- [`../COMMAND_REFERENCE.md`](../COMMAND_REFERENCE.md) — command/flag meanings.