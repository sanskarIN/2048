# Visual Studio and Windows Native Toolchain Handbook

This guide explains the **Visual Studio** requirements for building 2048 Nova as a native Windows desktop application.

Do not confuse **Visual Studio** with **Visual Studio Code**. VS Code is an editor. Visual Studio supplies the MSVC/Windows native build toolchain Flutter needs for `flutter build windows`.

## 1. What Windows desktop builds require

A Windows host needs a Flutter-supported Visual Studio installation with the **Desktop development with C++** workload.

That workload provides the native toolchain Flutter expects, including components such as:

- MSVC C/C++ compiler/linker;
- Windows SDK;
- MSBuild;
- CMake integration/native build components;
- supporting libraries/headers.

The exact component versions are managed by the installed supported Visual Studio release and Flutter's current Windows requirements.

## 2. What Visual Studio is not used for

You do not need to write the shared Flutter application in C++.

The app's main source remains Dart under `lib/`. Visual Studio builds the Windows native runner and plugin/native integration around that Flutter application.

## 3. Install Visual Studio

Use Microsoft's supported Visual Studio Installer.

During installation choose:

```text
Desktop development with C++
```

If Visual Studio is already installed, open **Visual Studio Installer > Modify** and confirm that workload remains selected.

## 4. Verify through Flutter

```powershell
flutter doctor -v
```

Look for the section similar to:

```text
Visual Studio - develop Windows apps
```

Flutter Doctor checks whether the required supported native development components are discoverable.

## 5. VS Code alone is insufficient

This can work:

```text
VS Code + Flutter extension + Flutter SDK + Visual Studio C++ workload
```

This cannot build Windows native merely by itself:

```text
VS Code + Flutter extension
```

The editor and compiler toolchain are separate layers.

## 6. Enable Windows desktop

```powershell
flutter config --enable-windows-desktop
```

Check targets:

```powershell
flutter devices
```

A healthy environment should expose a Windows desktop target.

## 7. Run on Windows

```powershell
flutter run -d windows
```

This compiles/runs a debug Windows build.

## 8. Build a release

```powershell
flutter build windows --release
```

The current project release area is under:

```text
build\windows\x64\runner\Release\
```

The main executable is expected to be:

```text
nova_2048.exe
```

Preserve the complete generated release bundle. Do not distribute only the `.exe`, because Flutter/native runtime DLLs and application data belong with it.

## 9. MSVC

**MSVC** means Microsoft Visual C++. It supplies the C/C++ compiler/linker/toolchain used by Windows native builds.

You normally do not invoke `cl.exe` manually for this project; Flutter/CMake/MSBuild orchestrate it.

## 10. MSBuild

**MSBuild** is Microsoft's build engine. Flutter's generated Windows/CMake workflow ultimately uses the Visual Studio/MSBuild toolchain to produce the native runner.

A missing/broken MSBuild installation can make `flutter build windows` fail even when Dart source is valid.

## 11. Windows SDK

The Windows SDK contains headers, libraries, metadata, tools, and APIs required to compile native Windows applications.

Install the supported SDK through Visual Studio Installer as part of the C++ workload/components.

Do not manually copy SDK directories from another machine.

## 12. CMake on Windows

Flutter's Windows runner uses CMake project definitions.

Visual Studio's C++ workload normally supplies compatible native CMake integration/tooling.

Check what Flutter sees with:

```powershell
flutter doctor -v
```

The repository's native CMake source lives under `windows/`.

## 13. Windows runner files

Important tracked categories under `windows/` include:

- CMake definitions;
- C++ runner source;
- Flutter plugin registration/integration;
- Windows resource metadata;
- application icon/resource files.

The file `windows/runner/Runner.rc` contains Version 2.0.12 fallback version metadata protected by repository tests/audits.

Do not regenerate/replace this directory blindly from a fresh Flutter template.

## 14. Flutter-generated build output versus source

Tracked source:

```text
windows/
```

Generated output:

```text
build/windows/...
```

Do not commit generated release binaries as if they were native source unless repository policy explicitly introduces release-asset storage.

## 15. Update Visual Studio

Use **Visual Studio Installer > Update**.

After updating:

```powershell
flutter doctor -v
flutter build windows --release
```

Check that the Desktop development with C++ workload remains installed.

## 16. Modify components

If Flutter Doctor reports a missing required Windows component:

1. open Visual Studio Installer;
2. select the installed Visual Studio instance;
3. choose **Modify**;
4. confirm **Desktop development with C++**;
5. install the requested supported components;
6. restart terminals/editors if necessary;
7. rerun `flutter doctor -v`.

Do not install every unrelated Visual Studio workload just to make Flutter Doctor green.

## 17. Unsupported Visual Studio release

If the installed Visual Studio release becomes unsupported or no longer satisfies Flutter's supported Windows toolchain:

- upgrade/migrate through Visual Studio Installer;
- keep the C++ workload;
- preserve project source with Git;
- run Flutter Doctor;
- rerun Windows tests/build;
- inspect any CMake/MSVC warning changes;
- update project docs/CI baseline only if a repository-controlled expectation changes.

See [`UPGRADING_AND_SUPPORT.md`](UPGRADING_AND_SUPPORT.md).

## 18. Visual Studio Preview

Do not make a Preview release the project's only build toolchain unless the project deliberately qualifies it.

Preview compilers/SDKs can change behavior before stable release. Prefer a Flutter-supported stable Visual Studio baseline for ordinary release builds.

## 19. Multiple Visual Studio installations

Flutter Doctor can report which Visual Studio installation it selects.

If multiple releases/editions are installed:

- verify the selected one is supported;
- verify it has the C++ workload;
- avoid deleting the known-good installation until the new one passes project builds.

## 20. Build after a Visual Studio update

Run:

```powershell
flutter --version
flutter doctor -v
flutter pub get
dart format --output=none --set-exit-if-changed lib test tool
flutter analyze
flutter test
flutter build windows --release
```

Also run repository audits if the change is part of a maintained toolchain migration.

## 21. Common error: Visual Studio not installed

If `flutter doctor -v` says Visual Studio is missing, installing VS Code does not resolve it.

Install Visual Studio with the C++ desktop workload.

## 22. Common error: required components missing

A Visual Studio installation can exist while required C++/Windows SDK components are absent.

Use Visual Studio Installer **Modify**, not a random third-party compiler bundle.

## 23. Common error: CMake generation failure

Possible causes include:

- missing native workload/SDK;
- stale generated build directory;
- broken plugin native configuration;
- incompatible toolchain after an upgrade;
- invalid tracked CMake edit.

First:

```powershell
flutter doctor -v
flutter clean
flutter pub get
flutter build windows --release
```

If it persists, inspect the first CMake/MSBuild/compiler error rather than only the final “build failed” line.

## 24. Common error: DLL missing when running copied EXE

If the app works from its generated release directory but fails after you copy only `nova_2048.exe`, the likely problem is incomplete packaging.

Distribute the full Windows release bundle as documented in [`../build/WINDOWS.md`](../build/WINDOWS.md).

## 25. Common error: plugin native compilation failure

Flutter packages such as file pickers, URL launchers, or preferences can have Windows native plugin code.

After a plugin/version/toolchain change:

```powershell
flutter clean
flutter pub get
flutter analyze
flutter test
flutter build windows --release
```

Review the package changelog/toolchain requirements rather than deleting the Windows runner.

## 26. Windows architecture

The current documented release path uses the x64 Windows bundle.

Do not advertise another architecture as maintained merely because a compiler might technically support it. Add architecture support only with explicit Flutter/toolchain support, build procedure, tests, and release packaging.

## 27. Native debugger

For Dart/UI logic, Flutter/VS Code/Android Studio Dart debugging is normally the first choice.

Use Visual Studio's native debugger when diagnosing:

- Windows runner C++ code;
- native plugin crashes;
- DLL/native ABI issues;
- Windows-specific platform integration.

## 28. Windows resource/version metadata

`windows/runner/Runner.rc` embeds Windows file/product information.

For Version 2.0.12 the repository protects fallback values equivalent to:

```text
2,0,12,2012
2.0.12
```

When a future release changes the application version, update all canonical version surfaces together and run repository tests/audits.

## 29. Installer formats

A successful Flutter Windows build produces an application bundle, not automatically an MSI/MSIX/setup installer.

The project should not claim maintained MSI/MSIX/installer support until it has:

- reproducible packaging configuration;
- version metadata;
- signing policy;
- upgrade/uninstall behavior;
- test documentation;
- CI/release integration.

## 30. Code signing

Compiling a Windows release does not automatically mean the `.exe`/installer is production code-signed.

If Windows distribution signing is introduced, protect private certificate keys and document the signing identity, timestamping, artifact verification, and release environment separately.

## 31. Clean uninstall of old Visual Studio components

Use Visual Studio Installer to remove workloads/instances.

Do not manually delete directories under Program Files in an attempt to reclaim space while an installation remains registered; this can leave broken installers/toolchains.

Before removing an older Visual Studio instance, verify the replacement passes `flutter doctor -v` and `flutter build windows --release`.

## 32. Disk usage

Visual Studio workloads and Windows SDKs can use significant disk space.

To reduce space safely:

- remove unused workloads/components using Visual Studio Installer;
- remove obsolete unsupported Visual Studio instances after the replacement is validated;
- keep the required C++ workload/SDK for Flutter Windows development.

## 33. First Windows-native qualification sequence

```powershell
flutter --version
flutter doctor -v
flutter devices
flutter pub get
dart format --output=none --set-exit-if-changed lib test tool
flutter analyze
flutter test
dart run tool\repository_audit.dart --json
dart run tool\source_completion_audit.dart --json
flutter build windows --release
```

## 34. Related documentation

- [`WINDOWS.md`](WINDOWS.md) — complete Windows workstation setup.
- [`VS_CODE.md`](VS_CODE.md) — VS Code editor setup.
- [`FLUTTER_AND_DART.md`](FLUTTER_AND_DART.md) — Flutter/Dart SDK.
- [`UPGRADING_AND_SUPPORT.md`](UPGRADING_AND_SUPPORT.md) — tool support lifecycle.
- [`../build/WINDOWS.md`](../build/WINDOWS.md) — Windows artifact packaging.
- [`../BUILDING_EXECUTABLES.md`](../BUILDING_EXECUTABLES.md) — all target builds.
- [`../COMMAND_REFERENCE.md`](../COMMAND_REFERENCE.md) — command meanings.
