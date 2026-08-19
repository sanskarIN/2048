# Command Reference — What Every Common Project Command Means

This document explains the commands used throughout the **2048 Nova** documentation. It is written for readers who do not want to copy commands without understanding them.

Checked against Version **2.0.12+2012** on **2026-08-19**.

## 1. How to read a command

Example:

```bash
flutter build apk --release
```

Breakdown:

- `flutter` — the executable/program being started.
- `build` — a Flutter subcommand that creates a build artifact.
- `apk` — the requested Android Package output.
- `--release` — a long-form option/flag selecting release mode.

A **command** starts a program. A **subcommand** tells that program which operation to perform. An **argument** supplies a value or target. A **flag/option** changes behavior.

## 2. Shell notation

Documentation often uses:

```bash
command
```

for a command that works in Bash/Zsh and often PowerShell as written.

Windows-specific syntax is shown as:

```powershell
command
```

Do not type the leading `$` or `>` prompts sometimes shown by vendor documentation unless they are actually part of the command.

## 3. Navigation commands

### `cd`

```bash
cd 2048
```

`cd` means **change directory**. It changes the shell's current working directory.

Parent directory:

```bash
cd ..
```

The `..` path means “the parent of the current directory.”

### `pwd`

On macOS/Linux:

```bash
pwd
```

`pwd` means **print working directory**. It shows where the shell is currently located.

PowerShell equivalent:

```powershell
Get-Location
```

## 4. Git commands

### `git --version`

```bash
git --version
```

Checks whether Git is installed and callable through `PATH`.

### `git clone`

```bash
git clone https://github.com/sanskarIN/2048.git
```

Meaning:

- `git`: start Git.
- `clone`: create a local repository from an existing remote repository.
- URL: source repository.

A clone normally creates a working directory, Git metadata, commit history, and a remote named `origin`.

### `git status`

```bash
git status
```

Shows the current branch and whether tracked/untracked files differ from the current commit.

### `git diff`

```bash
git diff
```

Shows unstaged line-level changes to tracked files.

### `git diff --staged`

```bash
git diff --staged
```

Shows changes already placed in Git's staging area.

### `git diff --exit-code`

```bash
git diff --exit-code -- pubspec.lock analysis_options.yaml
```

Meaning:

- `diff`: compare current files with Git's recorded state.
- `--exit-code`: return exit code `1` if a difference exists and `0` if no difference exists.
- `--`: marks the end of command options; following values are paths.

This form is useful in automation because an unexpected generated-file change becomes a failing command.

### `git add`

```bash
git add docs/COMMAND_REFERENCE.md
```

Copies the current file change into Git's staging area for the next commit.

### `git commit`

```bash
git commit -m "docs: explain project commands"
```

Meaning:

- `commit`: create a new history snapshot from staged changes.
- `-m`: supplies the commit message directly.

### Repository-local Git identity

```bash
git config user.name "Sanskar"
git config user.email "sanskarin@outlook.in"
```

Without `--global`, these settings affect only the current repository.

### `git pull`

```bash
git pull --ff-only
```

Fetches remote changes and updates the current branch only when it can do so as a fast-forward. `--ff-only` refuses an implicit merge commit when histories have diverged.

### `git push`

```bash
git push origin main
```

Sends local commits to remote `origin`, branch `main`.

## 5. Flutter identity and diagnostics

### `flutter --version`

```bash
flutter --version
```

Prints Flutter version, channel/revision information, bundled Dart version, and related environment data.

### `dart --version`

```bash
dart --version
```

Prints the active Dart SDK version. In normal Flutter development this is the Dart SDK bundled with Flutter.

### `flutter doctor`

```bash
flutter doctor
```

Checks whether Flutter can find platform toolchains and devices.

Verbose form:

```bash
flutter doctor -v
```

`-v` means **verbose** and prints additional paths, versions, and diagnostic details.

### Android license review

```bash
flutter doctor --android-licenses
```

Starts the Android SDK license acceptance flow. This is interactive and may require multiple responses.

## 6. Flutter channel and SDK upgrades

### `flutter channel`

```bash
flutter channel
```

Lists available Flutter release channels and marks the current channel.

Switch to stable:

```bash
flutter channel stable
```

### `flutter upgrade`

```bash
flutter upgrade
```

Updates the Flutter SDK to the newest release available on the current channel.

This changes the SDK installation, not only the current project. Run full project verification afterward.

## 7. Flutter platform configuration

### Enable Windows desktop

```bash
flutter config --enable-windows-desktop
```

### Enable macOS desktop

```bash
flutter config --enable-macos-desktop
```

### Enable Linux desktop

```bash
flutter config --enable-linux-desktop
```

`flutter config` changes Flutter SDK/user configuration. The `--enable-...` options make the corresponding desktop target available when the host supports it.

## 8. Device and emulator commands

### `flutter devices`

```bash
flutter devices
```

Lists currently detected runnable devices/targets, including supported browsers and desktop targets.

### `flutter emulators`

```bash
flutter emulators
```

Lists configured emulators.

Launch by ID:

```bash
flutter emulators --launch <emulator-id>
```

Replace `<emulator-id>` with an actual ID from the list. Angle-bracket placeholders in documentation are not typed literally.

## 9. Dependency commands

### `flutter pub get`

```bash
flutter pub get
```

Reads `pubspec.yaml`, resolves dependencies, respects lockfile constraints where applicable, downloads missing packages, and prepares package metadata for the project.

This is usually the first dependency command after cloning.

### `flutter pub outdated`

```bash
flutter pub outdated
```

Reports current, upgradable, resolvable, and latest dependency versions. It does **not** automatically change the project.

### `flutter pub upgrade`

```bash
flutter pub upgrade
```

Attempts to update dependencies within the constraints allowed by `pubspec.yaml`, then updates the lockfile as needed.

### Major-version upgrade helper

```bash
flutter pub upgrade --major-versions
```

Allows dependency constraints to move across major versions where supported by Pub's upgrade behavior. This can introduce breaking changes and must never be treated as a routine “make everything newest” command in a release-frozen project.

### Why `pubspec.lock` matters

The lockfile records concrete resolved package versions. A changed lockfile should be reviewed as source-controlled dependency metadata, not dismissed as generated noise.

## 10. Formatting

### Format files

```bash
dart format lib test tool
```

Rewrites Dart source into the standard Dart formatter style.

### Verify formatting without changing files

```bash
dart format --output=none --set-exit-if-changed lib test tool
```

Meaning:

- `--output=none`: do not print formatted source.
- `--set-exit-if-changed`: return a non-zero exit code when any file would change.
- `lib test tool`: directories checked.

This is the CI-style formatting gate.

## 11. Static analysis

```bash
flutter analyze
```

Runs Dart/Flutter static analysis using the project's `analysis_options.yaml` and configured lints. It detects many type, API, import, style, and correctness problems without executing the app.

Passing analysis does not prove runtime behavior, so tests are still required.

## 12. Tests

### All tests

```bash
flutter test
```

Runs the Flutter/Dart tests under the project test configuration.

### Coverage

```bash
flutter test --coverage
```

Runs tests and writes coverage data, normally under `coverage/`.

`--coverage` collects execution coverage; it does not automatically guarantee a specific percentage or quality threshold.

### One test file

```bash
flutter test test/example_test.dart
```

Runs only the specified test file.

## 13. Running the app

```bash
flutter run
```

Builds a debug application and launches it on the selected/default device.

Select a device:

```bash
flutter run -d windows
flutter run -d chrome
```

`-d` is short for selecting a device ID.

### Release-mode run

```bash
flutter run --release
```

Runs an optimized release build when the target supports it. Debug features such as hot reload are not available in the same way as debug mode.

## 14. Cleaning generated output

```bash
flutter clean
```

Removes build outputs and some generated intermediates so the next build is reconstructed.

A common recovery sequence is:

```bash
flutter clean
flutter pub get
flutter analyze
flutter test
```

Do not use `flutter clean` as a substitute for understanding a real compiler or dependency error.

## 15. Android build commands

### Debug APK

```bash
flutter build apk --debug
```

Creates an Android APK in debug mode.

### Profile APK

```bash
flutter build apk --profile
```

Creates a profile-mode APK used for supported performance/profiling scenarios.

### Release APK

```bash
flutter build apk --release
```

Creates an optimized release APK.

### ABI-split APKs

```bash
flutter build apk --release --split-per-abi
```

`--split-per-abi` creates separate APKs for supported application binary interfaces instead of one universal APK.

### Android App Bundle

```bash
flutter build appbundle --release
```

Creates an `.aab` bundle for store-oriented Android distribution. An AAB is not normally installed directly by tapping it like an APK.

### Override build name/number

```bash
flutter build appbundle --release --build-name=2.0.12 --build-number=2012
```

- `--build-name`: human-facing version name input.
- `--build-number`: monotonically managed build/version-code input.

For official releases, source metadata should normally be updated rather than relying on an unrecorded one-off override.

## 16. Web build commands

```bash
flutter build web --release
```

Builds the deployable Web bundle under `build/web/`.

A Web build is a directory of HTML/JavaScript/Wasm/assets/metadata, not a traditional native executable.

If a deployment requires a non-root base path, use only the Flutter-supported base-href mechanism documented by the current SDK and verify routing/assets on the actual host.

## 17. Windows build

```powershell
flutter build windows --release
```

Compiles the native Windows runner and packages Flutter/runtime assets into the Windows release output directory.

Do not copy only the `.exe`; preserve the generated runtime bundle.

## 18. Linux build

```bash
flutter build linux --release
```

Compiles the Linux runner and produces an ELF application bundle with required data/libraries.

## 19. macOS build

```bash
flutter build macos --release
```

Creates a macOS `.app` bundle. A `.app` is a structured directory bundle even though Finder displays it as one application icon.

## 20. iOS builds

### Unsigned release compile

```bash
flutter build ios --release --no-codesign
```

- `ios`: selects the iOS target.
- `--release`: optimized release mode.
- `--no-codesign`: compiles without performing Apple distribution signing.

This is useful for source/build qualification but is not a distributable App Store IPA.

### IPA

```bash
flutter build ipa --release
```

Builds/archives iOS and exports an IPA according to available signing/export configuration. Valid Apple signing/provisioning is an external requirement.

## 21. Repository-owned Dart tools

### Release readiness

```bash
dart run tool/release_readiness.dart --json
```

- `dart run`: executes a Dart program/package entry point.
- path: repository tool being executed.
- `--json`: requests machine-readable JSON output from this tool.

Strict stable gate:

```bash
dart run tool/release_readiness.dart --stable --json
```

`--stable` requests the stricter stable-promotion decision. It is intentionally fail-closed until required qualification evidence is genuinely complete.

### Qualification status

```bash
dart run tool/release_qualification_status.dart --json --pending-only
```

`--pending-only` limits reporting to manual checks not yet recorded as passed.

### Repository audit

```bash
dart run tool/repository_audit.dart --json
```

Validates repository integrity rules such as required assets and repository-local documentation links.

### Source completion audit

```bash
dart run tool/source_completion_audit.dart --json
```

Checks the permanent Version 2.0.12 source-completion contract and rejects stale/incomplete current-state markers covered by that audit.

### Solver benchmark

```bash
dart run tool/solver_benchmark.dart 8
```

Runs the deterministic solver benchmark with `8` supplied as the tool's positional workload/sample argument.

## 22. Gradle Wrapper commands

Run from the `android/` directory.

Windows:

```powershell
.\gradlew.bat --version
```

macOS/Linux:

```bash
./gradlew --version
```

The `./` or `.\` prefix means “execute the script located in the current directory.”

### List Gradle tasks

```bash
./gradlew tasks
```

Shows tasks the build exposes.

### Deprecation warnings

```bash
./gradlew help --warning-mode=all
```

Useful before a Gradle upgrade because it reveals deprecated behavior that may fail in a future version.

### Upgrade wrapper

Example only—choose a version only after checking Flutter/AGP compatibility:

```bash
./gradlew wrapper --gradle-version <target-version>
```

The repository currently pins Gradle `9.7.0`; do not change that pin independently during the Version 2.0.12 compatibility freeze.

## 23. Android SDK Manager commands

When Android `sdkmanager` is installed and on `PATH`:

```bash
sdkmanager --list
```

Lists installed/available SDK packages.

```bash
sdkmanager --update
```

Updates installed SDK packages according to the selected channel/repositories.

Install a named package:

```bash
sdkmanager --install "platform-tools"
```

Package names are exact SDK package identifiers. Prefer a pinned package version in reproducible automation rather than an unbounded `latest` selection.

## 24. Java/JDK commands

```bash
java -version
javac -version
```

- `java`: JVM launcher/runtime.
- `javac`: Java compiler included in a JDK.

This project uses Java 17 bytecode settings for Android. `flutter doctor -v` is more important than a random system `java` command because Flutter may use Android Studio's bundled JDK instead of the first Java on your system `PATH`.

## 25. Xcode commands

```bash
xcodebuild -version
```

Prints Xcode build-tool version.

```bash
xcode-select -p
```

Prints the active developer tools directory.

```bash
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
```

Switches the system-selected Xcode developer directory. `sudo` means execute with administrator/root privileges and should be used only when required.

```bash
sudo xcodebuild -runFirstLaunch
```

Performs Xcode first-launch setup actions after installation/update when needed.

## 26. CocoaPods commands

```bash
pod --version
```

Checks CocoaPods version.

```bash
pod install
```

Resolves and installs pod dependencies for the current Apple platform project according to its Podfile/lock state. In normal Flutter work, run Flutter's documented workflow rather than repeatedly manipulating Pods without a reason.

## 27. Checksums

### Linux SHA-256

```bash
sha256sum artifact.zip
```

Computes SHA-256 digest.

Verify a sidecar file:

```bash
sha256sum -c artifact.zip.sha256
```

`-c` means check/verify listed hashes.

### macOS

```bash
shasum -a 256 artifact.zip
```

`-a 256` selects SHA-256.

### PowerShell

```powershell
Get-FileHash .\artifact.zip -Algorithm SHA256
```

Computes SHA-256 with PowerShell.

A checksum detects accidental/unexpected file changes. It is not proof of publisher identity and is not equivalent to a code-signing signature.

## 28. WinGet commands

Install exact package ID:

```powershell
winget install --id Git.Git -e
```

Upgrade exact package ID:

```powershell
winget upgrade --id Git.Git -e
```

- `--id`: package identifier.
- `-e`: exact match.

## 29. Debian/Ubuntu package commands

```bash
sudo apt-get update
```

Refreshes package index metadata; it does not itself install all package upgrades.

```bash
sudo apt-get install -y clang cmake ninja-build pkg-config libgtk-3-dev libstdc++-12-dev
```

- `install`: requests packages.
- `-y`: automatically answers yes to package-manager confirmation prompts.

Read the package list before using `-y` on an unfamiliar command.

## 30. Exit codes

Command-line programs report an integer exit status to the shell.

Conventionally:

- `0` = success.
- non-zero = failure, warning-as-failure, rejected condition, or tool-specific status.

CI relies heavily on exit codes. For example, `dart format --set-exit-if-changed` intentionally returns non-zero when formatting is needed.

PowerShell can inspect the most recent native process exit code with:

```powershell
$LASTEXITCODE
```

Bash/Zsh can inspect it with:

```bash
echo $?
```

## 31. Safe command workflow

Before running a command you do not understand:

1. identify the executable;
2. identify the subcommand;
3. identify every flag;
4. identify paths it may read/write/delete;
5. know whether it changes source, global tooling, credentials, or only generated output;
6. check `git status` before and after project-changing commands;
7. review diffs before committing.

This project favors reproducible, reviewable commands over opaque “fix everything” scripts.

## 32. Related documentation

- [`setup/PREREQUISITES.md`](setup/PREREQUISITES.md) — which tools are actually required.
- [`setup/WINDOWS.md`](setup/WINDOWS.md) — complete Windows workflow.
- [`BUILDING_EXECUTABLES.md`](BUILDING_EXECUTABLES.md) — all maintained build artifacts.
- [`build/QUICK_COMMANDS.md`](build/QUICK_COMMANDS.md) — compact command sheet.
- [`DEVELOPMENT.md`](DEVELOPMENT.md) — development workflow.
- [`TESTING.md`](TESTING.md) — testing strategy and evidence boundaries.
- [`TROUBLESHOOTING.md`](TROUBLESHOOTING.md) — failure diagnosis.