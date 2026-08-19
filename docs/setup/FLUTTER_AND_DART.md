# Flutter and Dart SDK Handbook

This guide explains the Flutter/Dart toolchain used by **2048 Nova**: what the SDKs are, how they relate, how to install and locate them, how channels and upgrades work, how package resolution works, how to diagnose duplicate SDKs, and how to change the project baseline safely.

Checked against the repository on **2026-08-19**.

## 1. Current project contract

```text
Flutter minimum accepted by pubspec: >=3.35.0
Hosted CI Flutter baseline: 3.47.0 stable
Dart SDK constraint: >=3.9.0 <4.0.0
Application package/build: 2.0.12+2012
```

The Flutter minimum and CI pin answer different questions:

- `>=3.35.0` is the project-declared minimum Flutter SDK constraint;
- `3.47.0 stable` is the repository's current hosted validation baseline.

A newer local Flutter SDK may work, but it is not automatically adopted as the maintained CI/toolchain baseline.

## 2. What Flutter is

Flutter is the project's cross-platform application framework and build tool. It provides:

- the widget/UI framework;
- rendering/runtime integration;
- platform runners and plugin integration;
- build commands for Android, iOS, Web, Windows, macOS, Linux;
- development commands such as `flutter run` and `flutter doctor`;
- Flutter-aware test/analyzer/build orchestration.

The executable command is:

```bash
flutter
```

## 3. What Dart is

Dart is the programming language used by the application's shared source, tests, and repository-owned maintenance tools.

The Flutter SDK bundles a compatible Dart SDK. For normal Flutter development, that bundled Dart is the one that matters.

The executable command is:

```bash
dart
```

## 4. Why you normally should not install a second Dart SDK

If you install an unrelated standalone Dart SDK and put it earlier on `PATH`, your shell's `dart` command can disagree with the Dart version bundled with Flutter.

This can create confusing behavior where:

- `flutter` uses one Dart SDK;
- `dart` in the terminal resolves to another;
- package/tool behavior differs;
- editor extensions select a third configured path.

For this Flutter project, prefer the Dart SDK that ships with the selected Flutter installation.

## 5. Install Flutter

Use Flutter's official stable installation method for your host OS.

Good SDK locations are user-writable development paths such as:

Windows:

```text
C:\Flutter
C:\Development\flutter
E:\Development\flutter
```

macOS/Linux:

```text
~/development/flutter
```

Avoid installing Flutter into a location that requires administrator/root permission for routine SDK updates.

## 6. Add Flutter to PATH

`PATH` is the environment variable the shell searches to find commands.

You add Flutter's **`bin` directory**, not merely the Flutter parent directory.

Windows example:

```text
C:\Development\flutter\bin
```

Bash/Zsh example:

```bash
export PATH="$HOME/development/flutter/bin:$PATH"
```

Open a new terminal after changing environment variables.

## 7. Verify which Flutter is selected

Windows:

```powershell
where.exe flutter
where.exe dart
```

macOS/Linux:

```bash
which flutter
which dart
type -a flutter
type -a dart
```

Then:

```bash
flutter --version
dart --version
```

If multiple Flutter installations are listed, the first matching executable in `PATH` normally wins.

## 8. `flutter --version`

```bash
flutter --version
```

This identifies the active Flutter installation and normally reports:

- Flutter version;
- channel;
- framework revision;
- engine revision;
- bundled Dart version;
- DevTools version when applicable.

Record this output in a toolchain migration because “Flutter works” is not enough to reproduce the environment later.

## 9. `dart --version`

```bash
dart --version
```

This prints the active Dart SDK version.

For this repository it must satisfy:

```text
>=3.9.0 <4.0.0
```

If it does not, check which Flutter/Dart installation your shell/editor is selecting.

## 10. Flutter channels

Check:

```bash
flutter channel
```

Channels are release streams. For normal project/release work, this repository uses the stable channel as its hosted baseline.

Switch to stable:

```bash
flutter channel stable
```

Switching channels changes the SDK release stream. It is not a project-local setting and can affect every Flutter project that uses that SDK installation.

## 11. Upgrade Flutter

```bash
flutter channel stable
flutter upgrade
```

Then:

```bash
flutter --version
dart --version
flutter doctor -v
```

`flutter upgrade` changes the installed SDK. It can also change:

- bundled Dart;
- generated templates;
- analyzer behavior;
- build tool integrations;
- native toolchain expectations;
- Web compilation/runtime behavior;
- plugin compatibility.

Run the complete project validation after an upgrade.

## 12. Do not change CI just because local Flutter upgraded

The CI baseline is a reproducibility choice.

Before changing `.github/workflows/` from the current Flutter 3.47.0 pin:

1. read Flutter release/breaking-change notes;
2. resolve dependency/native compatibility;
3. compare platform template changes;
4. run formatting/analyzer/tests/audits;
5. build all maintained targets on supported hosts;
6. perform real-world qualification for affected behavior;
7. update docs/CI together.

## 13. Flutter Doctor

```bash
flutter doctor -v
```

`doctor` checks whether Flutter can find major platform dependencies. `-v` means verbose.

It can report sections for:

- Flutter itself;
- Android toolchain;
- browser/Web development;
- Xcode/macOS/iOS;
- Visual Studio/Windows;
- Android Studio;
- VS Code;
- connected devices;
- network resources depending on SDK behavior.

A warning for a platform you do not intend to build may not block the platforms you do maintain. Read each doctor section rather than assuming every red marker has the same impact.

## 14. Flutter Doctor does not prove release readiness

A healthy doctor output does not prove:

- source formatting;
- static analysis;
- tests;
- release compilation;
- signing;
- real-device behavior;
- accessibility;
- store acceptance;
- strict stable qualification.

Those are separate gates.

## 15. Flutter configuration

View configurable values:

```bash
flutter config
```

Examples used by this project:

```bash
flutter config --enable-windows-desktop
flutter config --enable-macos-desktop
flutter config --enable-linux-desktop
```

JDK selection:

```bash
flutter config --jdk-dir="/path/to/jdk"
```

Flutter config settings are machine/user SDK configuration, not necessarily tracked repository state.

## 16. Devices

```bash
flutter devices
```

Lists currently detected runnable targets.

Examples may include:

- Android physical device;
- Android emulator;
- iOS simulator/device on macOS;
- Chrome/browser;
- Windows desktop;
- macOS desktop;
- Linux desktop.

Select one with `-d`:

```bash
flutter run -d windows
flutter run -d linux
flutter run -d chrome
```

## 17. Emulators

```bash
flutter emulators
```

Launch a configured emulator:

```bash
flutter emulators --launch <emulator-id>
```

The angle-bracket text is a placeholder; replace it with the actual ID.

## 18. `pubspec.yaml`

The repository's `pubspec.yaml` is the primary Dart/Flutter package manifest.

It contains:

- package name;
- description/metadata;
- `version: 2.0.12+2012`;
- Dart SDK constraint;
- Flutter SDK constraint;
- dependencies;
- dev dependencies;
- Flutter assets/settings.

Do not edit dependency versions without reviewing the lockfile and testing affected platforms.

## 19. `pubspec.lock`

The lockfile records the concrete resolved package graph.

When package resolution changes:

```bash
git diff -- pubspec.yaml pubspec.lock
```

Review both files. A lockfile diff is important supply-chain/reproducibility information.

## 20. Resolve dependencies

```bash
flutter pub get
```

This reads the package manifest, resolves/downloads dependencies, and prepares Flutter/Dart package metadata.

Run after:

- cloning;
- changing dependency constraints;
- switching branches with a different lockfile;
- `flutter clean` when package metadata must be regenerated;
- some SDK migrations.

## 21. Inspect outdated packages

```bash
flutter pub outdated
```

This reports categories such as current/upgradable/resolvable/latest versions.

It is a report, not permission to update every package.

Native Flutter plugins can change Android/iOS/macOS/Windows/Linux/Web behavior even when the Dart API looks similar.

## 22. Upgrade dependencies within constraints

```bash
flutter pub upgrade
```

This tries to resolve newer versions allowed by current constraints.

Review the resulting lockfile and rerun tests/builds.

## 23. Major-version dependency migration

```bash
flutter pub upgrade --major-versions
```

This can move constraints across major versions and expose breaking changes.

Do not run it as a routine “make project modern” command during a completed release freeze. Use a maintenance branch and review every changed dependency.

## 24. Dart formatter

Format source:

```bash
dart format lib test tool
```

CI-style check without rewriting:

```bash
dart format --output=none --set-exit-if-changed lib test tool
```

The second command returns a failing exit status if the formatter would change files.

## 25. Dart/Flutter analyzer

```bash
flutter analyze
```

Uses the project's `analysis_options.yaml` and type/lint rules to detect many source problems without launching the app.

Do not disable lints merely to make an upgrade pass. Determine whether source or lint/toolchain configuration should change.

## 26. Tests

```bash
flutter test
```

Coverage:

```bash
flutter test --coverage
```

A Flutter SDK upgrade must rerun tests because framework/widget/analyzer/runtime behavior can change.

## 27. Run the app

```bash
flutter run
```

Flutter selects/asks for a target as appropriate.

The normal debug workflow supports hot reload/hot restart.

### Hot reload

Applies many Dart code changes to a running debug application while preserving substantial current state.

### Hot restart

Restarts Dart application state more completely but still avoids a full native rebuild in many development cases.

Neither feature exists as a substitute for testing release mode.

## 28. Build modes

### Debug

```bash
flutter build apk --debug
```

Development/debugging configuration.

### Profile

```bash
flutter build apk --profile
```

Performance profiling configuration on supported targets.

### Release

```bash
flutter build apk --release
```

Optimized production-style compilation.

See `../BUILDING_EXECUTABLES.md` for every platform.

## 29. Flutter cache

The Flutter SDK maintains downloaded/cached components. Do not delete random SDK directories while Flutter is updating.

If an SDK install becomes genuinely corrupted, follow Flutter's supported reinstall/repair guidance and first preserve project source in Git.

A project `flutter clean` is different from manually deleting the Flutter SDK cache.

## 30. `flutter clean`

```bash
flutter clean
```

Removes project generated build outputs/intermediates.

Typical recovery sequence:

```bash
flutter clean
flutter pub get
flutter analyze
flutter test
```

Use only when generated-state cleanup is relevant. A compiler/type/error in source will normally return after cleaning until its cause is fixed.

## 31. Moving a Flutter SDK to another drive/path

If you intentionally move/reinstall Flutter:

1. stop running Flutter/editor processes;
2. install/extract the SDK at the new writable path;
3. update `PATH` to the new `flutter/bin`;
4. remove the old `PATH` entry;
5. open a new terminal;
6. verify with `where.exe flutter` or `type -a flutter`;
7. run `flutter --version` and `flutter doctor -v`;
8. reopen VS Code/Android Studio so extensions rediscover the SDK;
9. build/test the project before deleting a known-good old SDK copy if you need rollback safety.

Do not copy an SDK in the middle of `flutter upgrade`.

## 32. Duplicate SDK troubleshooting

Symptoms:

- terminal reports a different Flutter than the editor;
- `flutter doctor` paths look unexpected;
- Dart version differs between shells;
- one project works in one terminal but not another.

Windows:

```powershell
where.exe flutter
where.exe dart
$env:Path -split ';'
```

macOS/Linux:

```bash
type -a flutter
type -a dart
printf '%s\n' "$PATH" | tr ':' '\n'
```

Remove stale entries and configure the editor to the same intended SDK.

## 33. Downgrade/rollback principle

If a new Flutter release breaks the project:

- do not delete source changes/history;
- preserve the failing upgrade branch/diagnostics;
- restore a vendor-supported compatible Flutter release through an approved SDK management/reinstall method;
- return project source to the accepted Git commit/config pins if necessary;
- document the incompatibility before retrying another upgrade.

A downgrade is a temporary compatibility action, not an excuse to remain on an EOL SDK forever.

## 34. Temporary SDK comparison

When evaluating a new Flutter release, it can be useful to keep a separate SDK directory rather than modifying the only known-good installation.

The critical rule is to verify which SDK is active before every test:

```bash
flutter --version
```

Do not accidentally commit generated project changes from the wrong SDK without reviewing them.

## 35. Template migration

A Flutter upgrade can change generated platform templates.

Do **not** blindly run a command that overwrites all existing platform folders.

Safer approach:

1. create a temporary clean project with the new SDK;
2. compare relevant generated Android/iOS/Web/Windows/macOS/Linux files;
3. migrate only required template changes;
4. preserve project identifiers, signing rules, branding, PWA metadata, version resources, CI/release contracts;
5. run tests/builds.

## 36. SDK support and security

If the selected Flutter/Dart release becomes unsupported or a security/platform requirement forces an update, follow [`UPGRADING_AND_SUPPORT.md`](UPGRADING_AND_SUPPORT.md).

The project prioritizes:

```text
supported + compatible + reproducible + validated
```

over both “never upgrade” and “always install latest immediately.”

## 37. Project validation after a Flutter/Dart change

```bash
flutter --version
dart --version
flutter doctor -v
flutter pub get
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

Then run the native build matrix for every maintained affected target.

## 38. Related documentation

- [`README.md`](README.md) — setup index.
- [`PREREQUISITES.md`](PREREQUISITES.md) — complete tool inventory.
- [`UPGRADING_AND_SUPPORT.md`](UPGRADING_AND_SUPPORT.md) — support/EOL migration.
- [`../COMMAND_REFERENCE.md`](../COMMAND_REFERENCE.md) — exact command meanings.
- [`../DEPENDENCIES.md`](../DEPENDENCIES.md) — package policy.
- [`../BUILDING_EXECUTABLES.md`](../BUILDING_EXECUTABLES.md) — platform builds.
- [`../TROUBLESHOOTING.md`](../TROUBLESHOOTING.md) — diagnostics.