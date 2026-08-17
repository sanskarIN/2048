# Cross-Platform Build Troubleshooting

Use this guide when a 2048 Nova build fails locally or differs from hosted CI. Start with environment evidence before changing source or runner configuration.

## First-response diagnostics

From the repository root:

```bash
flutter --version
flutter doctor -v
flutter devices
git status --short
flutter pub get
```

Then run:

```bash
dart format --output=none --set-exit-if-changed lib test tool
flutter analyze
flutter test
```

If a release build still fails, perform one clean rebuild:

```bash
flutter clean
flutter pub get
```

and retry the target command.

Do not repeatedly regenerate platform runner directories or disable release checks as a first troubleshooting step.

## Compare with current CI

Current permanent hosted verification freezes Flutter 3.47.0. Android hosted builds additionally use Temurin JDK 17.

See:

- [`CI_PARITY.md`](CI_PARITY.md)
- [`../VERIFICATION.md`](../VERIFICATION.md)
- [`../CI_CD.md`](../CI_CD.md)

If hosted CI is green while local builds fail, compare SDK/tool versions and local uncommitted/generated-file differences.

If hosted CI fails too, treat that failure as evidence rather than assuming the local machine is the only problem.

## Dependency/lockfile drift

After:

```bash
flutter pub get
```

check:

```bash
git diff -- pubspec.lock
git status --short
```

Unexpected dependency or generated plugin changes can indicate a different Flutter/plugin resolution environment.

Do not silently commit lockfile/generated changes without understanding why they occurred.

## Android troubleshooting

### Check Java

```bash
java -version
flutter doctor -v
```

Hosted Android CI uses JDK 17. The repository intentionally pins its accepted AGP/Kotlin/Gradle combination. See [`../ANDROID_TOOLCHAIN.md`](../ANDROID_TOOLCHAIN.md).

### AGP/Kotlin/Gradle failures

Do not solve a failure by independently jumping to the newest AGP/JDK/Gradle version. This project has documented evidence for why AGP 9.3.x is currently deferred on the normal JDK 17 release-lint path.

### Signing confusion

The tracked Android `release` build type currently uses the debug signing configuration for qualification. If you add private production signing locally, installation/update behavior can differ because Android package signatures differ.

### APK installs fail

Check:

- device ABI versus split APK ABI;
- Android version/min SDK;
- available storage;
- existing package with same application ID but different signature;
- whether package transfer completed correctly.

## iOS troubleshooting

### Xcode diagnostics

```bash
xcodebuild -version
flutter doctor -v
```

### Signing failure

For compilation parity with hosted CI:

```bash
flutter build ios --release --no-codesign
```

For actual distribution, do not use `--no-codesign` as a workaround. Configure a valid Apple team/certificate/provisioning/export flow.

### CocoaPods/plugin issue

Follow the diagnostics produced by Flutter/Xcode for the installed toolchain. Do not delete the committed `ios/` runner and regenerate it unless a deliberate runner migration is being performed and reviewed.

## Web troubleshooting

### Release build

```bash
flutter build web --release
```

Serve `build/web/` over HTTP rather than opening `index.html` with `file://`.

### Wasm build works locally but not deployed

If using:

```bash
flutter build web --wasm
```

verify production host MIME/security/cross-origin isolation header requirements and browser compatibility. The repository's permanent Web CI currently qualifies the standard release path, not Wasm.

### Clipboard/file-picker differences

Browser permissions and user-gesture policies can differ from widget tests/local development. Test the final HTTPS deployment.

## Windows troubleshooting

### Missing Visual Studio/C++ components

```powershell
flutter doctor -v
```

Install the exact Visual Studio desktop C++/Windows SDK prerequisites Flutter reports.

### EXE missing DLL/data errors

Do not copy only:

```text
nova_2048.exe
```

Use the complete generated release directory or repository-compatible ZIP. Flutter Windows release output includes adjacent DLL/data dependencies.

### CMake/Ninja issues

Verify the native toolchain installation before editing `windows/CMakeLists.txt`.

## macOS troubleshooting

### Xcode/toolchain

```bash
xcodebuild -version
flutter doctor -v
```

### `.app` damaged after transfer

Preserve the entire application bundle. The repository uses `ditto` for qualification ZIP packaging.

### Gatekeeper/notarization warning

Compilation success is not notarization. Test the exact signing/notarization flow intended for public distribution.

### Sandbox/file picker difference

Game Backup Save/Open behavior must be tested under the actual final entitlement/sandbox distribution configuration.

## Linux troubleshooting

### Missing build packages on Ubuntu/Debian

```bash
sudo apt-get update
sudo apt-get install -y ninja-build libgtk-3-dev liblzma-dev
```

Then:

```bash
flutter doctor -v
flutter build linux --release
```

### Executable fails outside build machine

Transfer the complete `bundle/`, not just `nova_2048`.

Check system dependencies and architecture. The Flutter Linux bundle still relies on operating-system libraries. Use native tooling such as `ldd` where appropriate to inspect dynamic dependencies.

## Wrong output path

Read [`OUTPUT_PATHS.md`](OUTPUT_PATHS.md), then inspect the actual generated build directory. Output paths can change after Flutter/toolchain migrations.

If the build configuration was intentionally renamed, update documentation and packaging scripts in the same change.

## Checksum mismatch

A checksum mismatch means the bytes differ.

Possible causes:

- corrupted/incomplete transfer;
- artifact rebuilt after checksum creation;
- archive recompressed;
- wrong file selected;
- sidecar from another commit/build.

Do not ignore the mismatch. Re-identify the exact artifact and regenerate/verify the sidecar from the final package.

## Build succeeds but app behavior fails

Compilation cannot prove runtime correctness. Reproduce using the exact release artifact and collect:

- target OS/device version;
- artifact filename/checksum;
- source commit SHA;
- steps to reproduce;
- expected versus actual behavior;
- logs/screenshots if safe and relevant.

Then check the relevant feature documentation/tests.

## When not to modify source

Do not alter application code solely because:

- Android SDK license is missing;
- JDK/Xcode/Visual Studio/GTK tools are not installed;
- a single executable was copied without its runtime bundle;
- signing/provisioning is absent for a distribution build;
- a Web host lacks required headers;
- the wrong ABI/package was installed.

Fix the environment/package procedure first.

## Release-safety rule

Never bypass or disable:

- analyzer/test failures;
- dependency integrity checks;
- stable release-readiness checks;
- Android lint/toolchain safeguards;
- required signing/provisioning for a production channel;
- real-world manual qualification requirements

just to make an artifact appear release-ready.

For feature/runtime troubleshooting beyond build generation, also see [`../TROUBLESHOOTING.md`](../TROUBLESHOOTING.md).