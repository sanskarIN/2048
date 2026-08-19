# Windows Development Setup

This is the end-to-end Windows setup for **2048 Nova**: Git, Flutter, Android development, Windows desktop builds, VS Code, Visual Studio, environment variables, verification, and common recovery steps.

Checked against the repository on **2026-08-19**.

## 1. What Windows can build

A correctly configured Windows machine can build and run:

- Android APK and AAB;
- Web/PWA;
- Windows desktop.

A Windows host cannot natively produce iOS or macOS artifacts because those require Apple's Xcode toolchain on macOS.

## 2. Recommended installation order

Install in this order so later tools can discover earlier ones:

1. Windows updates.
2. Git.
3. Flutter SDK.
4. VS Code and Flutter/Dart extensions, if desired.
5. Android Studio + Android SDK, if Android is required.
6. Visual Studio + Desktop development with C++, if Windows desktop is required.
7. Run `flutter doctor -v` and resolve only the sections for platforms you intend to use.

## 3. Install Git

### With WinGet

```powershell
winget install --id Git.Git -e
```

Meaning:

- `winget`: Windows Package Manager.
- `install`: requests installation.
- `--id Git.Git`: selects Git's package identifier.
- `-e`: requires an exact ID match.

Close and reopen the terminal, then verify:

```powershell
git --version
```

### Repository-local Git identity

Inside the cloned repository:

```powershell
git config user.name "Sanskar"
git config user.email "sanskarin@outlook.in"
```

These commands write identity values to this repository's `.git/config`. They do not change another repository when `--global` is omitted.

## 4. Install Flutter SDK

The safest Windows Flutter location is a short, writable path that does not require administrator permission and does not contain troublesome special characters.

Examples:

```text
C:\Flutter
C:\Development\flutter
E:\Development\flutter
```

Avoid extracting Flutter inside `C:\Program Files` because normal SDK updates should not require elevated permissions.

After extracting Flutter, add its `bin` directory to the user `Path` environment variable, for example:

```text
C:\Flutter\bin
```

Open a **new** terminal and verify:

```powershell
flutter --version
dart --version
where.exe flutter
where.exe dart
```

`where.exe` shows which executable Windows will run. If multiple Flutter installations appear, remove stale `Path` entries or deliberately select the intended SDK.

## 5. Flutter channel and repository baseline

Check your channel:

```powershell
flutter channel
```

For normal project development, use the stable channel:

```powershell
flutter channel stable
flutter upgrade
```

The repository accepts Flutter `>=3.35.0`; permanent CI is pinned to Flutter `3.47.0`. A local SDK can be newer, but any SDK/toolchain upgrade must pass the repository's complete validation sequence before it is adopted as the maintained baseline.

## 6. Install VS Code

With WinGet:

```powershell
winget install --id Microsoft.VisualStudioCode -e
```

Install Flutter and Dart extensions when the `code` command is available:

```powershell
code --install-extension Dart-Code.flutter
code --install-extension Dart-Code.dart-code
```

Verify:

```powershell
code --version
```

VS Code is an editor. It does **not** replace the Visual Studio C++ toolchain required for native Windows builds.

## 7. Install Android Studio

With WinGet, if the package is available in your package source:

```powershell
winget install --id Google.AndroidStudio -e
```

Otherwise use the official Android Studio installer.

During the setup wizard, install the recommended Android SDK components. Then open **SDK Manager** and ensure the current stable SDK platform/build tools and Android SDK Command-line Tools are installed.

Install the Flutter plugin from Android Studio's plugin settings.

### Android SDK location

Typical location:

```text
%LOCALAPPDATA%\Android\Sdk
```

Do not copy a partially installed SDK folder from another computer and assume it is valid. Let Android Studio or `sdkmanager` manage packages.

### Accept licenses

```powershell
flutter doctor --android-licenses
```

This is interactive. Read each license before accepting.

### Verify Android setup

```powershell
flutter doctor -v
flutter devices
flutter emulators
```

- `flutter devices` lists physical/emulated targets Flutter can currently see.
- `flutter emulators` lists configured emulators Flutter can launch.

## 8. JDK and Java 17 baseline

The Android project compiles Java and Kotlin for JVM 17:

```text
sourceCompatibility = JavaVersion.VERSION_17
targetCompatibility = JavaVersion.VERSION_17
jvmTarget = JVM_17
```

Android Studio includes a JetBrains Runtime/JDK that Flutter can normally use. For reproducibility, JDK 17 is the preferred project baseline.

Check which Java Flutter reports:

```powershell
flutter doctor -v
java -version
where.exe java
```

If Flutter is using the wrong JDK and you have a deliberate JDK 17 location, configure it explicitly:

```powershell
flutter config --jdk-dir="C:\Path\To\JDK17"
```

Then rerun:

```powershell
flutter doctor -v
```

Do not point Flutter to a random JRE. Android builds require a JDK.

## 9. Gradle: do not install it separately

The repository has a Gradle Wrapper under `android/` and currently pins Gradle `9.7.0`.

From the repository root:

```powershell
cd android
.\gradlew.bat --version
cd ..
```

Meaning:

- `.\gradlew.bat`: executes the repository-controlled Windows Gradle Wrapper.
- `--version`: prints the selected Gradle/JVM/environment information.

The wrapper downloads its declared Gradle version automatically when needed. A system `gradle` installation can accidentally create version drift and is unnecessary for normal work.

## 10. Install Visual Studio for Windows desktop

Flutter Windows desktop requires **Visual Studio** with the **Desktop development with C++** workload.

Open the Visual Studio Installer, install/update the current supported Visual Studio release, and select:

```text
Desktop development with C++
```

That workload supplies native C/C++ build tools, Windows SDK components, CMake/MSBuild integration, and related dependencies Flutter expects.

After installation, verify:

```powershell
flutter doctor -v
```

The `Visual Studio - develop Windows apps` section should no longer report missing required components.

## 11. Clone and prepare the project

Choose a normal development directory:

```powershell
cd C:\Development
git clone https://github.com/sanskarIN/2048.git
cd 2048
flutter pub get
```

`git clone` creates a working copy with Git history and a default `origin` remote. `flutter pub get` resolves the packages declared by `pubspec.yaml` using the lockfile where applicable.

## 12. Validate the repository

Run:

```powershell
dart format --output=none --set-exit-if-changed lib test tool
flutter analyze
flutter test
```

Then run the repository-owned checks:

```powershell
dart run tool\release_readiness.dart --json
dart run tool\repository_audit.dart --json
dart run tool\source_completion_audit.dart --json
```

The strict stable release gate can remain intentionally closed while the documented real-world qualification evidence is incomplete. Do not weaken that gate merely to make a command exit successfully.

## 13. Run the app

List devices:

```powershell
flutter devices
```

Run on the selected/default target:

```powershell
flutter run
```

Run on Windows explicitly when the device ID is `windows`:

```powershell
flutter run -d windows
```

Run in Chrome when available:

```powershell
flutter run -d chrome
```

`-d` means `--device-id`.

## 14. Build Android artifacts

Debug APK:

```powershell
flutter build apk --debug
```

Release APK:

```powershell
flutter build apk --release
```

Play-distribution App Bundle:

```powershell
flutter build appbundle --release
```

Release signing behavior is documented in [`../build/ANDROID.md`](../build/ANDROID.md) and [`../build/SIGNING_AND_DISTRIBUTION.md`](../build/SIGNING_AND_DISTRIBUTION.md). Never commit keystore passwords or production signing secrets.

## 15. Build Windows release

```powershell
flutter config --enable-windows-desktop
flutter pub get
flutter build windows --release
```

Do not distribute only the `.exe`. Flutter Windows output includes runtime libraries and data that belong with the executable.

## 16. Build Web release

```powershell
flutter build web --release
```

Deploy the complete `build\web\` directory, not only `index.html`.

## 17. Upgrade tools safely

### Git

```powershell
winget upgrade --id Git.Git -e
```

### VS Code

```powershell
winget upgrade --id Microsoft.VisualStudioCode -e
code --update-extensions
```

### Android Studio

Use **Help > Check for Updates** or the stable update offered by Android Studio. Then open SDK Manager and review SDK tools separately.

### Android SDK packages

If `sdkmanager` is on `PATH`:

```powershell
sdkmanager --list
sdkmanager --update
```

Prefer Android Studio's SDK Manager if you are unsure which packages are required.

### Visual Studio

Use **Visual Studio Installer > Update**. If Flutter reports missing C++ components after an update, choose **Modify** and verify **Desktop development with C++** is still installed.

### Flutter

```powershell
flutter channel stable
flutter upgrade
flutter doctor -v
```

After any significant upgrade, rerun formatting verification, analyzer, tests, repository audits, and all target builds you maintain.

## 18. Windows PATH troubleshooting

### Command not found

Check:

```powershell
$env:Path -split ';'
where.exe git
where.exe flutter
where.exe dart
```

A path entry must point to the directory containing the executable, not the executable file itself.

### Multiple Flutter SDKs

If `where.exe flutter` returns several paths, the first matching path wins. Remove stale entries or reorder the user/system `Path` carefully.

### Filename too long during Flutter upgrade

Prefer a short SDK path such as:

```text
C:\Flutter
```

Flutter's official troubleshooting guidance also documents enabling Windows/Git long paths when required. Do not blindly change system policy unless the path-length error actually occurs.

## 19. Clean build recovery

For stale generated output:

```powershell
flutter clean
flutter pub get
flutter analyze
flutter test
```

`flutter clean` removes generated build output. It does not intentionally delete your source files or committed platform configuration.

If the Android Gradle cache is the suspected problem, diagnose before deleting global caches. Prefer running the wrapper with useful diagnostics first:

```powershell
cd android
.\gradlew.bat --version
.\gradlew.bat tasks
cd ..
```

## 20. Final Windows readiness checklist

A healthy Windows development machine should satisfy the relevant parts of:

```powershell
git --version
flutter --version
dart --version
flutter doctor -v
flutter devices
flutter pub get
dart format --output=none --set-exit-if-changed lib test tool
flutter analyze
flutter test
```

If you maintain Android:

```powershell
cd android
.\gradlew.bat --version
cd ..
flutter build apk --release
flutter build appbundle --release
```

If you maintain Windows desktop:

```powershell
flutter build windows --release
```

If you maintain Web:

```powershell
flutter build web --release
```

For the meanings of commands and flags, use [`../COMMAND_REFERENCE.md`](../COMMAND_REFERENCE.md) after that file is introduced in the documentation set. Until then, [`../BUILDING_EXECUTABLES.md`](../BUILDING_EXECUTABLES.md) is the authoritative build handbook.