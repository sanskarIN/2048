# Visual Studio Code Setup for 2048 Nova

This guide explains how to install and configure **Visual Studio Code (VS Code)** for 2048 Nova, how Flutter/Dart extensions work, how to select the correct Flutter SDK/device, how to run/debug/test the app, and how to troubleshoot editor-versus-terminal differences.

## 1. VS Code is optional

VS Code is a code editor/IDE-like development environment. The project can be built entirely from the command line.

VS Code does **not** replace:

- Flutter SDK;
- Android SDK/JDK;
- Xcode on macOS/iOS;
- Visual Studio C++ tools on Windows desktop;
- Clang/CMake/Ninja/GTK on Linux.

## 2. VS Code versus Visual Studio

These are different products.

### Visual Studio Code

Cross-platform editor with extensions. Recommended for Dart/Flutter editing.

### Visual Studio

Full Microsoft IDE/toolchain. Flutter Windows desktop builds require its **Desktop development with C++** workload.

Installing VS Code alone does not satisfy Flutter's Windows native build requirement.

## 3. Install VS Code

### Windows with WinGet

```powershell
winget install --id Microsoft.VisualStudioCode -e
```

### macOS with Homebrew Cask

```bash
brew install --cask visual-studio-code
```

On Linux, use Microsoft's supported package/repository method or the distribution mechanism appropriate to your environment.

Verify when the CLI is installed:

```bash
code --version
```

## 4. Install Flutter and Dart extensions

From the Extensions view, install:

```text
Flutter
Dart
```

Extension IDs:

```text
Dart-Code.flutter
Dart-Code.dart-code
```

With the `code` CLI:

```bash
code --install-extension Dart-Code.flutter
code --install-extension Dart-Code.dart-code
```

The Flutter extension integrates Flutter commands/debugging. The Dart extension supplies language analysis, completion, navigation, formatting, refactoring, and Dart debugging support.

## 5. Open the correct project folder

Open the repository root—the directory containing:

```text
pubspec.yaml
lib/
test/
tool/
android/
ios/
web/
windows/
macos/
linux/
```

From a terminal in the repository:

```bash
code .
```

`.` means the current directory.

Opening only `lib/` can prevent VS Code/Flutter tooling from discovering package/platform metadata correctly.

## 6. Confirm Flutter is available before blaming VS Code

In an external terminal:

```bash
flutter --version
dart --version
flutter doctor -v
```

If these fail, fix the SDK/PATH installation first.

An editor extension cannot compensate for a missing/broken Flutter SDK.

## 7. Select the Flutter SDK

VS Code normally discovers Flutter through PATH or previously configured extension settings.

If it selects the wrong SDK, use the Flutter command palette option for changing/selecting the SDK and point it at the intended Flutter SDK root.

Then verify the integrated terminal:

```bash
flutter --version
```

Ensure editor and external terminal agree on the intended SDK baseline.

## 8. Duplicate Flutter installations

Windows:

```powershell
where.exe flutter
where.exe dart
```

macOS/Linux:

```bash
type -a flutter
type -a dart
```

If the editor uses a different SDK than the shell, fix PATH and any explicit VS Code Flutter SDK setting.

## 9. Integrated terminal

Open VS Code's Terminal panel. It inherits environment variables from the process that launched VS Code.

After changing PATH, fully close/reopen VS Code if its terminal still sees the old environment.

Verify:

```bash
git --version
flutter --version
dart --version
flutter doctor -v
```

## 10. Resolve dependencies

From the repository root:

```bash
flutter pub get
```

VS Code may offer automatic dependency resolution after detecting `pubspec.yaml`, but the command remains the canonical explicit operation.

## 11. Dart analysis in the editor

The Dart extension runs language analysis and displays diagnostics inline.

The repository-wide command remains:

```bash
flutter analyze
```

Do not assume “no red squiggles in the file I opened” means the whole project passes analysis.

## 12. Formatting

Format a file using VS Code's Format Document command.

Repository-wide formatter check:

```bash
dart format --output=none --set-exit-if-changed lib test tool
```

If format-on-save is enabled, it should use the Dart formatter for Dart files.

Do not install a competing generic formatter that reformats Dart differently from `dart format`.

## 13. Device selector

The Flutter extension exposes available devices in VS Code's status bar/command palette.

The underlying CLI source of truth is:

```bash
flutter devices
```

If VS Code shows no target but the terminal does, restart/reload the editor and verify the extension is using the same SDK.

## 14. Run/debug

VS Code's Run and Debug can launch the Flutter app on the selected device.

CLI equivalent:

```bash
flutter run
```

Explicit target example:

```bash
flutter run -d chrome
```

The debugger can set breakpoints, inspect variables, step through Dart code, and view logs in debug mode.

## 15. Breakpoints

A breakpoint pauses debug execution at a source location when the running code reaches it.

Use breakpoints to inspect state rather than filling permanent source with temporary print statements.

Remove temporary diagnostics before committing unless they are deliberate application logging.

## 16. Debug Console versus terminal

### Debug Console

Shows debugger/evaluation output tied to the current debug session.

### Integrated Terminal

Runs normal shell commands such as Git, Flutter tests/builds, and repository tools.

Use the appropriate surface: do not paste shell commands into the Dart debug expression evaluator.

## 17. Hot reload

While running a Flutter debug session, VS Code can trigger hot reload.

Hot reload applies many Dart changes while preserving substantial application state.

It does not fully reinitialize native runner/configuration changes.

## 18. Hot restart

Hot restart restarts Dart application state more fully than hot reload.

Use a full stop/rebuild when changing native platform configuration, build files, plugin registration, or other changes not handled by hot reload/restart.

## 19. Tests from VS Code

The Dart/Flutter extension can display/run test code lenses or test explorer entries depending on configuration/version.

Always retain command-line parity:

```bash
flutter test
flutter test --coverage
```

Run a single test file:

```bash
flutter test test/documentation_completeness_test.dart
```

## 20. Repository tools from VS Code terminal

```bash
dart run tool/release_readiness.dart --json
dart run tool/release_qualification_status.dart --json --pending-only
dart run tool/repository_audit.dart --json
dart run tool/source_completion_audit.dart --json
dart run tool/solver_benchmark.dart 8
```

These are ordinary CLI tools; they do not require a special VS Code extension.

## 21. Source Control view

VS Code integrates Git status/diffs/staging/commits.

Even if using the UI, understand the equivalent commands:

```bash
git status
git diff
git diff --staged
git add <path>
git commit -m "message"
git push
```

Review exactly what is staged before committing.

## 22. Never rely on editor “Sync” blindly

VS Code's Git Sync can perform pull/push operations depending on configuration.

For a sensitive repository state, use explicit terminal commands so you know what happens:

```bash
git status
git pull --ff-only
git push origin main
```

## 23. Recommended settings mindset

Keep project/editor settings minimal and portable.

Useful concepts:

- format Dart with Dart formatter;
- use Flutter/Dart extension SDK discovery consistently;
- avoid excluding `test/` or `tool/` from analysis accidentally;
- do not auto-save/format generated native files with unrelated formatters;
- do not configure hard-coded private SDK paths in committed workspace files unless the repository deliberately supports that.

## 24. Workspace settings

A `.vscode/settings.json` can be committed if the repository intentionally wants shared editor settings, but machine-specific absolute SDK paths should normally remain local.

Example of a bad portable setting:

```text
C:\Users\SomeOne\Downloads\flutter
```

because another contributor cannot use that path.

## 25. Extensions to avoid installing “because more is better”

The project does not need dozens of overlapping Dart/Flutter formatters, build wrappers, or AI extensions to compile.

Every extension increases editor complexity and can change formatting/diagnostics/keybindings.

Start with:

```text
Flutter
Dart
```

Add other extensions only for a clear workflow purpose.

## 26. Update VS Code

Windows/WinGet:

```powershell
winget upgrade --id Microsoft.VisualStudioCode -e
```

Other OSes: use the same supported method used for installation.

After a major update, verify:

```bash
code --version
flutter --version
flutter analyze
```

## 27. Update extensions

CLI:

```bash
code --update-extensions
```

Or use VS Code's Extensions UI.

After Flutter/Dart extension updates, confirm:

- correct SDK selection;
- analyzer diagnostics;
- formatting;
- device detection;
- debug launch;
- test integration.

## 28. If VS Code is unsupported/out of support

Move to a vendor-supported VS Code release compatible with your operating system.

Do not keep an EOL operating system merely to preserve an old editor version. The Flutter SDK/platform toolchain support requirements take priority over editor preference.

See [`UPGRADING_AND_SUPPORT.md`](UPGRADING_AND_SUPPORT.md).

## 29. “Flutter SDK not found” in VS Code

Check external terminal:

```bash
flutter --version
```

If it fails, fix PATH.

If it succeeds but VS Code fails:

1. fully restart VS Code after PATH changes;
2. verify integrated terminal PATH;
3. select the correct Flutter SDK through Flutter extension commands;
4. inspect duplicate SDK locations;
5. reload the window.

## 30. “No devices”

Run:

```bash
flutter devices
```

For Android:

```bash
adb devices
flutter emulators
```

For Windows/macOS/Linux verify the native toolchain through:

```bash
flutter doctor -v
```

For Web ensure a supported browser target is installed/detected.

## 31. Analyzer appears stuck/stale

First verify from terminal:

```bash
flutter pub get
flutter analyze
```

If CLI is healthy but editor diagnostics are stale, restart the Dart analysis server/reload VS Code through the extension command palette.

Do not delete project files to fix an editor display cache.

## 32. Wrong imports/autocomplete after branch change

```bash
flutter pub get
```

If dependencies changed, the editor needs updated package configuration.

Then reload analysis if necessary.

## 33. Native build errors are not VS Code errors

Examples:

- missing Visual Studio C++ workload;
- Android SDK license/JDK/Gradle issue;
- Xcode signing error;
- Linux GTK/CMake/Ninja issue.

Use the relevant host/toolchain guide and `flutter doctor -v` rather than reinstalling VS Code.

## 34. Recommended first VS Code session

From repository root:

```bash
code .
```

Then in integrated terminal:

```bash
flutter --version
flutter doctor -v
flutter pub get
dart format --output=none --set-exit-if-changed lib test tool
flutter analyze
flutter test
flutter devices
```

Select a device and run/debug.

## 35. Before committing from VS Code

```bash
git status
git diff
dart format --output=none --set-exit-if-changed lib test tool
flutter analyze
flutter test
dart run tool/repository_audit.dart --json
dart run tool/source_completion_audit.dart --json
```

Then review staged diff.

## 36. Related documentation

- [`README.md`](README.md) — setup index.
- [`PREREQUISITES.md`](PREREQUISITES.md) — complete prerequisite inventory.
- [`FLUTTER_AND_DART.md`](FLUTTER_AND_DART.md) — SDK handbook.
- [`GIT.md`](GIT.md) — Git/GitHub workflow.
- [`WINDOWS.md`](WINDOWS.md) — Windows native requirements.
- [`MACOS.md`](MACOS.md) — macOS/iOS requirements.
- [`LINUX.md`](LINUX.md) — Linux native requirements.
- [`../COMMAND_REFERENCE.md`](../COMMAND_REFERENCE.md) — command meanings.
