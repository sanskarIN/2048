# Windows Build Guide

2048 Nova supports a native Flutter Windows desktop build. The main visible executable is an `.exe`, but the distributable application is the **complete generated release directory**, not the EXE alone.

## Host requirement

Build Windows releases on **Windows** with Flutter's required Visual Studio desktop C++ toolchain installed.

## Prerequisites

Install:

- Flutter SDK;
- Visual Studio with the Desktop development with C++ workload/components required by Flutter;
- Windows SDK and CMake/Ninja components as reported by `flutter doctor`.

Verify:

```powershell
flutter --version
flutter doctor -v
flutter config --enable-windows-desktop
flutter devices
```

Install dependencies:

```powershell
flutter pub get
```

## Development run

```powershell
flutter run -d windows
```

## Release build

```powershell
flutter build windows --release
```

Current x64 output used by repository CI:

```text
build/windows/x64/runner/Release/
```

The directory contains the main application executable together with required Flutter/runtime DLLs, plugin DLLs, ICU/data files, and application assets.

## Important: do not distribute only the EXE

The generated `.exe` depends on files located next to it and in its generated data structure. Copying only the EXE can produce startup errors or missing functionality.

Distribute either:

- the complete generated release directory;
- the repository-compatible ZIP containing that complete directory's contents; or
- a properly built installer/package that includes all required generated runtime files.

## CI-compatible ZIP

The hosted `Platform Builds` workflow currently packages Windows like this:

```powershell
Compress-Archive -Path build/windows/x64/runner/Release/* `
  -DestinationPath nova-2048-windows-x64.zip -Force
```

Generate SHA-256:

```powershell
$hash = (Get-FileHash nova-2048-windows-x64.zip -Algorithm SHA256).Hash.ToLower()
"$hash  nova-2048-windows-x64.zip" | Out-File -Encoding ascii nova-2048-windows-x64.zip.sha256
```

Verify:

```powershell
Get-FileHash .\nova-2048-windows-x64.zip -Algorithm SHA256
Get-Content .\nova-2048-windows-x64.zip.sha256
```

Compare the values exactly.

## Debug/profile concepts

For development, prefer:

```powershell
flutter run -d windows
```

Release packaging should use:

```powershell
flutter build windows --release
```

If you create profile builds for performance work, do not distribute them as stable release artifacts.

## Architecture

The permanent hosted workflow currently packages the x64 Windows release path. If the project's Windows architecture support changes later, update this guide, CI packaging paths, artifact names, and qualification evidence together.

Do not assume a package labeled x64 works on every Windows CPU/edition without testing the target environment.

## Installer boundary

Flutter's Windows release build produces the application bundle, not a polished end-user installer by itself.

Possible future packaging approaches may include an installer or store package, but any such format must:

- include every required file from the generated release bundle;
- preserve application assets/plugins;
- use correct application identity/version metadata;
- support clean install/uninstall/upgrade behavior;
- be independently tested;
- use signing credentials outside this public repository when code signing is enabled.

Do not document an installer format as supported until the repository actually configures and validates it.

## Code signing boundary

Production distribution may use Windows Authenticode/code signing. Private signing keys/certificates must not be committed.

A ZIP checksum and a code signature serve different purposes:

- SHA-256 sidecar: transfer/integrity comparison;
- code signature: publisher identity and executable/package trust when backed by a valid certificate.

The current qualification workflow generates checksums but does not pretend that hosted builds are production-signed Windows releases.

## Clean rebuild

```powershell
flutter clean
flutter pub get
flutter config --enable-windows-desktop
flutter build windows --release
```

If generated plugin registration changes, inspect repository diffs rather than blindly committing or discarding generated files.

## Common failures

### Visual Studio toolchain missing

Run:

```powershell
flutter doctor -v
```

Install the exact missing Visual Studio C++/Windows SDK components Flutter reports.

### CMake/Ninja problem

Use `flutter doctor -v` and the build log to determine whether the required native build tool is missing or conflicting. Do not modify project CMake files merely to hide a local environment problem.

### EXE runs on build machine but not another PC

Confirm that you copied the **entire release directory** or used the complete ZIP, not only the EXE. Then check target Windows version/architecture, security policy, extracted DLL/data files, and any code-signing warnings.

### Antivirus/SmartScreen warning

Unsigned or newly distributed executables can trigger reputation/security warnings. A successful build does not remove the need for proper code signing and safe distribution practices.

## Real-target qualification

Test the packaged release on representative Windows machines:

- launch/relaunch;
- window resize/minimize/restore;
- keyboard controls and focus;
- save/resume after app restart;
- file open/save/cancel for Game Backup;
- clipboard copy/paste;
- external browser/email handlers;
- Narrator/screen reader;
- large text/high contrast/reduced motion;
- English/Hindi switching;
- Replay/Full Replay/Auto Play controls;
- long-session stability.

## Release checklist

1. `flutter doctor -v` confirms a usable Windows toolchain.
2. Dependencies and repository quality checks pass.
3. `flutter build windows --release` succeeds.
4. Complete `Release/` bundle is preserved.
5. ZIP is created from all required files.
6. SHA-256 is generated and verified.
7. Exact packaged build is tested on representative machines.
8. Installer/signing is configured and tested if used.
9. Icon/window/native presentation is reviewed.
10. Required stable-release evidence is recorded before publication.