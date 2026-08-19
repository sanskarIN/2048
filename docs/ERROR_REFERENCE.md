# 2048 Nova Error and Diagnosis Reference

This guide maps common development/build/release symptoms to their likely layer, the safest first diagnostic commands, and the fixes you should **not** use merely to make an error disappear.

The goal is to diagnose root causes instead of repeatedly reinstalling tools or weakening project safeguards.

## 1. Diagnostic principle: read the first root cause

Build tools often print many follow-on errors after the first real failure.

A useful process is:

1. identify the first meaningful error;
2. identify which layer emitted it;
3. confirm the selected tool versions/paths;
4. reproduce with the narrowest command;
5. fix the actual cause;
6. rerun the narrow command;
7. rerun the full project gates.

Do not focus only on the final generic line such as `BUILD FAILED`.

## 2. Universal environment snapshot

```bash
git status
flutter --version
dart --version
flutter doctor -v
flutter devices
```

For Android:

```bash
cd android
./gradlew --version
cd ..
```

Windows Android wrapper command:

```powershell
cd android
.\gradlew.bat --version
cd ..
```

This tells you what repository/toolchain you are actually using.

## 3. `flutter: command not found`

### Meaning

The shell cannot find the Flutter executable through `PATH`.

### Diagnose

Windows:

```powershell
where.exe flutter
$env:Path -split ';'
```

macOS/Linux:

```bash
type -a flutter
printf '%s\n' "$PATH" | tr ':' '\n'
```

### Fix

Add the intended Flutter SDK's `bin` directory to `PATH`, then open a new terminal.

Do not reinstall Android Studio to fix a missing Flutter PATH entry.

## 4. `dart: command not found`

The selected Flutter SDK normally supplies Dart.

Check Flutter first:

```bash
flutter --version
```

Then inspect which Dart is available:

```bash
dart --version
```

Windows:

```powershell
where.exe dart
```

macOS/Linux:

```bash
type -a dart
```

Avoid installing an unrelated standalone Dart SDK merely to hide a broken Flutter PATH.

## 5. Wrong Flutter version

Symptoms:

- SDK constraint failure;
- editor and terminal report different versions;
- new API works in one terminal but not another.

Diagnose:

```bash
flutter --version
```

Windows:

```powershell
where.exe flutter
```

macOS/Linux:

```bash
type -a flutter
```

Current project constraint:

```text
Flutter >=3.35.0
Dart >=3.9.0 <4.0.0
CI baseline Flutter 3.47.0 stable
```

## 6. `pubspec.yaml` SDK constraint failure

If Pub says the current Dart/Flutter SDK does not satisfy project constraints, the selected SDK is incompatible.

Fix the SDK selection/version. Do not weaken the project SDK constraint without an intentional compatibility decision.

## 7. `flutter pub get` dependency resolution failure

### Likely causes

- incompatible constraints;
- selected Dart/Flutter too old/new for dependencies;
- corrupted/edited `pubspec.yaml`;
- network/registry issue;
- dependency version no longer resolves under the graph.

### Diagnose

```bash
flutter --version
dart --version
flutter pub get
flutter pub outdated
```

Review:

```bash
git diff -- pubspec.yaml pubspec.lock
```

Do not delete `pubspec.lock` as the first reaction in a reproducibility-sensitive application project.

## 8. Pub network/download failure

Check whether normal HTTPS access to package infrastructure is allowed by your network/proxy.

Do not disable certificate/TLS verification or use an unknown package mirror.

If an organization proxy is required, configure it through approved OS/tool settings.

## 9. Lockfile changed unexpectedly

After:

```bash
flutter pub get
```

CI may reject unexpected metadata drift.

Inspect:

```bash
git diff -- pubspec.lock analysis_options.yaml
```

A lockfile change can be legitimate after a dependency/SDK update, but it must be intentional/reviewed.

## 10. Formatting gate failed

Command:

```bash
dart format --output=none --set-exit-if-changed lib test tool
```

If it fails, format the maintained Dart source:

```bash
dart format lib test tool
```

Review resulting diff before committing.

Do not disable the formatting check.

## 11. `flutter analyze` failed

Static-analysis failures can indicate:

- type errors;
- invalid imports;
- undefined names;
- API changes;
- lint violations;
- unreachable/dead code warnings depending on configuration.

Run:

```bash
flutter analyze
```

Fix the source/configuration cause. Do not broadly weaken `analysis_options.yaml` just to obtain a green result.

## 12. Analyzer says package/import cannot be found

Run:

```bash
flutter pub get
```

Confirm the package exists in `pubspec.yaml`/lock state and the import path is correct.

After branch changes, editor analysis can also require a reload/restart if CLI analysis is healthy.

## 13. `flutter test` failed

Run the complete suite to see the failing test:

```bash
flutter test
```

Then focus it:

```bash
flutter test test/path_to_test.dart
```

Do not delete/skip a failing regression test simply to make CI pass. Determine whether the product behavior or test expectation is wrong.

## 14. Test passes alone but fails in full suite

Possible causes:

- leaked global/static state;
- time/random dependence;
- test ordering assumption;
- shared filesystem/preferences state;
- async cleanup issue.

The correct fix is test/application isolation, not forcing a particular execution order unless the test contract explicitly requires it.

## 15. Flaky time/date test

The project uses deterministic/portable timestamp rules for relevant features.

Avoid relying on local timezone/current wall clock when a deterministic injected date/time or UTC representation is intended.

See [`PORTABLE_TIMESTAMPS.md`](PORTABLE_TIMESTAMPS.md).

## 16. Game-engine regression

If movement/merge/spawn behavior fails, focus domain tests and inspect:

```text
lib/domain/game_engine.dart
lib/domain/game_state.dart
lib/domain/random_source.dart
```

Do not patch only the visible board widget if the deterministic engine is wrong.

## 17. Challenge Code import rejected

Possible causes:

- malformed payload;
- unsupported format/version;
- checksum mismatch;
- out-of-range values;
- invalid mode/board configuration.

The rejection may be intentional safety behavior.

See [`CHALLENGE_CODES.md`](CHALLENGE_CODES.md).

## 18. Backup import rejected

Possible causes:

- file too large;
- invalid schema;
- invalid board/state values;
- corrupted/truncated content;
- unsupported format;
- security/trust validation.

Do not bypass the codec validator to import arbitrary state.

See [`BACKUP_AND_RESTORE.md`](BACKUP_AND_RESTORE.md).

## 19. Replay archive rejected

Check archive size, schema, event limits, move/state consistency, and supported version.

Rejecting malformed imported replay data is correct behavior.

See [`REPLAY_ARCHIVES.md`](REPLAY_ARCHIVES.md).

## 20. Local save does not resume

Diagnose whether:

- no active save exists;
- schema migration rejected invalid old data;
- reset was performed;
- write failed;
- controller did not persist after a state transition.

Inspect:

```text
lib/data/local_store.dart
lib/app/state/app_controller.dart
```

Run storage/controller tests before changing UI.

## 21. Statistics/records look wrong after import

Portable imports are intentionally isolated from trusted ranked/statistical state.

If imported progress does **not** update a trusted record, that can be the expected security/integrity policy.

See [`MODE_RECORDS.md`](MODE_RECORDS.md).

## 22. Hint returns no move

Possible legitimate conditions include a terminal/no-valid-move board.

If a legal move exists, inspect solver tests and `lib/domain/hint_solver.dart`.

Do not have the UI fabricate a move when the solver/domain rejected it.

## 23. Auto Play stops

Possible causes:

- terminal state;
- configured stop/budget;
- no legal move;
- isolated session policy;
- solver returns no valid recommendation.

Use deterministic benchmark/autoplay tests before changing timing loops.

## 24. `flutter doctor --android-licenses` fails

Confirm Android SDK Command-line Tools are installed and Flutter sees the correct SDK:

```bash
flutter doctor -v
```

Then retry:

```bash
flutter doctor --android-licenses
```

Do not copy license files from an unknown machine.

## 25. Android toolchain missing

Run:

```bash
flutter doctor -v
```

Install/configure Android Studio/SDK/JDK according to [`setup/ANDROID.md`](setup/ANDROID.md).

## 26. `adb: command not found`

Android SDK Platform-Tools are missing from the shell PATH or not installed.

Check Android Studio SDK Manager, then:

```bash
adb version
```

You can still rely on Flutter Doctor for the actual SDK path.

## 27. ADB device shows `unauthorized`

```bash
adb devices
```

Unlock the owned/authorized device and approve the debugging-key prompt.

Do not attempt to bypass device authorization.

## 28. ADB device not listed

Check:

- USB cable/data capability;
- USB debugging enabled;
- device authorization;
- Windows vendor driver if required;
- `adb devices`;
- `flutter devices`.

Restarting Flutter will not fix a physically charge-only cable.

## 29. Android emulator will not start

Check:

- valid AVD/system image;
- host virtualization support;
- emulator package version;
- disk/RAM availability;
- host architecture compatibility;
- Android Studio Device Manager error details.

Do not delete the entire Android SDK as the first fix.

## 30. `flutter.sdk not set in local.properties`

The Android Gradle settings need Flutter's machine-local SDK path metadata.

Run Flutter normally from repository root and ensure `android/local.properties` is generated/valid for the current machine.

Do not commit another computer's `local.properties`.

## 31. Java/JDK compatibility failure

Diagnose:

```bash
flutter doctor -v
java -version
javac -version
```

Gradle JVM:

```bash
cd android
./gradlew --version
```

Windows:

```powershell
cd android
.\gradlew.bat --version
```

Current project target baseline is Java/JVM 17.

Do not assume the shell's `java` is the same JDK Flutter/Gradle uses.

## 32. Unsupported class-file version / JVM error

This often means the Java runtime/compiler and Gradle/AGP/plugin bytecode levels are incompatible.

Check exact JDK and Gradle versions, then compare the accepted Android toolchain combination. Do not randomly install the newest JDK.

## 33. Gradle distribution download failure

The wrapper downloads the pinned Gradle distribution when needed.

Check:

- network/proxy/TLS;
- wrapper URL/checksum;
- disk space;
- whether the configured distribution is accessible.

Do not remove checksum verification to bypass a corrupted/untrusted download.

## 34. Gradle wrapper checksum mismatch

Treat it as an integrity failure.

Do not simply delete the SHA/checksum property.

Confirm the expected Gradle version/distribution from the project's accepted baseline and obtain it through the normal wrapper path.

## 35. AGP/Kotlin/Gradle incompatibility

If a tool upgrade produces plugin compatibility errors, verify:

```text
AGP 9.1.0
Kotlin Android 2.4.10
Gradle 9.7.0
JDK 17 target baseline
```

for the current repository contract.

If deliberately migrating, use [`setup/UPGRADING_AND_SUPPORT.md`](setup/UPGRADING_AND_SUPPORT.md).

## 36. Gradle deprecation warning

Inspect all warnings before the next toolchain migration:

```bash
cd android
./gradlew help --warning-mode=all
```

A warning is not necessarily today's build failure, but can become tomorrow's incompatibility.

## 37. Android SDK package missing

The error normally names an API/build/NDK component.

Inspect SDK Manager or:

```bash
sdkmanager --list
```

Install the compatible requested package. Do not lower project SDK values blindly.

## 38. Android release signing property missing

For real distribution signing, verify the ignored:

```text
android/key.properties
```

and private keystore location/credentials.

Do not commit the secret just to satisfy CI.

Hosted qualification intentionally supports a non-production signing fallback when private release credentials are absent.

## 39. Keystore file not found

Verify the path in private `key.properties` relative to the Android project configuration.

Check filesystem path spelling/permissions. Do not move the keystore into tracked source as a shortcut.

## 40. APK installs but AAB cannot be tapped/installed

Expected: an AAB is a store-oriented publishing bundle, not a normal direct-install APK.

Use the appropriate store/bundle tooling for AAB testing/distribution.

## 41. `flutter build windows` says Visual Studio missing

Installing VS Code is not enough.

Install Visual Studio with:

```text
Desktop development with C++
```

Then:

```powershell
flutter doctor -v
```

## 42. Windows native build missing C++/SDK components

Open Visual Studio Installer > Modify and confirm the Flutter-required C++ desktop workload/components.

Do not replace the MSVC toolchain with an unrelated compiler unless Flutter officially supports that path.

## 43. Windows EXE fails after copying it alone

The Windows release is a runtime **bundle**.

Keep the generated DLLs/data with `nova_2048.exe`.

See [`build/WINDOWS.md`](build/WINDOWS.md).

## 44. Windows CMake error

Run:

```powershell
flutter doctor -v
flutter clean
flutter pub get
flutter build windows --release
```

If it persists, inspect the first CMake/MSBuild/compiler error and whether a native plugin/toolchain was recently changed.

## 45. `xcodebuild` not found / wrong Xcode

Check:

```bash
xcode-select -p
xcodebuild -version
```

Select full Xcode when needed:

```bash
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
sudo xcodebuild -runFirstLaunch
```

## 46. CocoaPods not found

```bash
pod --version
```

Install CocoaPods with one supported method, then rerun Flutter Doctor.

## 47. Multiple CocoaPods installations

```bash
which pod
type -a pod
```

The shell may be using a different installation from the one you upgraded.

## 48. iOS build signing error

For source-level unsigned qualification:

```bash
flutter build ios --release --no-codesign
```

For real distribution, configure the legitimate Apple certificate/team/provisioning profile. Do not call an unsigned build “App Store ready.”

## 49. iOS provisioning profile error

Check:

- bundle identifier;
- Apple team;
- certificate/private key;
- profile capabilities;
- entitlements;
- selected signing mode.

This cannot be fixed truthfully by editing documentation or disabling release qualification.

## 50. macOS build succeeds but app is not notarized

Expected: `flutter build macos --release` compiles the app; notarization is a separate Apple distribution process.

Do not confuse successful compilation with notarization.

## 51. Pod dependency conflict

Inspect the actual native dependency constraints and deployment targets.

Start from:

```bash
flutter pub get
pod --version
```

Do not delete every Pod/lock/cache automatically.

## 52. Linux: `clang` not found

```bash
clang --version
```

Install your distribution's Clang package.

## 53. Linux: `cmake` not found

```bash
cmake --version
```

Install CMake through the supported distribution/toolchain method.

## 54. Linux: Ninja not found

```bash
ninja --version
```

On Debian/Ubuntu:

```bash
sudo apt-get install -y ninja-build
```

## 55. Linux: GTK not found

```bash
pkg-config --modversion gtk+-3.0
```

On Debian/Ubuntu:

```bash
sudo apt-get install -y libgtk-3-dev
```

## 56. Linux executable missing shared library

Check:

```bash
ldd build/linux/x64/release/bundle/nova_2048
```

Also verify you copied the complete Flutter bundle and that the target distribution provides required system runtime libraries.

## 57. Linux app loses execute permission after archive

Check:

```bash
ls -l build/linux/x64/release/bundle/nova_2048
```

A packaging process can strip Unix file modes. Test the actual distributed archive extraction path.

## 58. `flutter build web` succeeds but site is blank

Compilation success does not prove deployment configuration.

Check:

- complete `build/web/` directory uploaded;
- correct base path/base href;
- browser developer console/network errors;
- hosting MIME/cache rules;
- HTTPS/service-worker/PWA requirements where applicable.

Do not deploy only `index.html`.

## 59. Web assets 404 under subdirectory

Likely base-path/deployment mismatch.

Use Flutter's supported base-href deployment mechanism and verify the real host path.

Avoid hand-editing generated `build/web/` files as the permanent solution; fix source/build/deploy configuration.

## 60. PWA does not install

A successful Flutter Web build does not guarantee installed-PWA criteria in every browser.

Check:

- manifest retrieval/content;
- icons;
- HTTPS/secure context where required;
- service worker/build behavior;
- browser installability diagnostics;
- real deployment URL.

See [`PWA.md`](PWA.md).

## 61. PWA offline behavior differs after update

Service-worker/browser cache lifecycle can retain old assets or update asynchronously.

Qualify the actual installed PWA lifecycle in real browsers. Do not describe a hosted compile as proof of offline update behavior.

## 62. External URL/file handler works in tests but not real device

Hosted/unit/widget tests cannot fully reproduce every OS handler/provider/permission UI.

Treat this as manual qualification and inspect platform logs/handler availability.

## 63. `repository_audit.dart` fails

Run:

```bash
dart run tool/repository_audit.dart --json
```

Read each failure. Common categories can include:

- required file missing/empty;
- wrong release metadata;
- PWA metadata drift;
- broken local Markdown link;
- continuity contract drift;
- temporary helper left in repository.

Do not remove the audit from CI to hide the defect.

## 64. Broken Markdown link failure

The repository audit scans Markdown local links.

Check the reported file/line/path. Remember relative links are resolved from the Markdown file's own directory.

Examples:

From `docs/setup/example.md` to `docs/README.md`:

```text
../README.md
```

From `docs/example.md` to root `README.md`:

```text
../README.md
```

## 65. `source_completion_audit.dart` fails

Run:

```bash
dart run tool/source_completion_audit.dart --json
```

It can reject missing required completion files, current-version drift, restored active feature backlog, missing permanent CI/tool wiring, or unresolved maintained Dart `TODO`/`FIXME` line comments covered by its policy.

Fix the contract violation; do not delete the audit.

## 66. Source-completion audit sees `TODO`/`FIXME`

The audit focuses on maintained Dart directories.

If it is real unfinished implementation work, finish/remove it appropriately.

If a regression test needs the literal marker as fixture text, ensure it is not written as a live line comment that the audit intentionally flags.

## 67. Release readiness candidate check fails

```bash
dart run tool/release_readiness.dart --json
```

Read the machine-readable failure list. Fix source/release-contract problems before stable promotion.

## 68. Strict stable readiness fails because manual evidence is pending

Command:

```bash
dart run tool/release_readiness.dart --stable --json
```

If the canonical manual qualification manifest still has pending checks, failure is **expected and correct**.

Do not mark evidence passed unless the required real environment was actually observed.

## 69. Qualification status shows 0/13

That means no required manual real-world evidence has been recorded as passed.

Documentation commits, CI builds, or commit count do not change this evidence automatically.

## 70. Git commit says identity unknown

Configure repository-local identity:

```bash
git config user.name "Sanskar"
git config user.email "sanskarin@outlook.in"
```

Then retry the commit.

## 71. Git push rejected: non-fast-forward

The remote has changes not present locally.

Inspect/synchronize:

```bash
git fetch origin
git status
git log --oneline --decorate --graph --all
```

Use normal reconciliation/PR flow. Do not force-push `main` as a generic fix.

## 72. Git push rejected: pull request required

This means a repository rule/protected branch prevents direct writes.

Correct workflow:

1. create/switch to a branch;
2. commit/push changes there;
3. open a pull request to `main`;
4. satisfy required checks/reviews;
5. merge according to repository policy.

Do not bypass branch protection.

## 73. Git shows thousands of changed files after editor/OS change

Possible line-ending or generated-file churn.

Inspect:

```bash
git status --short
git diff --stat
git diff
```

Check `.gitattributes`/editor formatting before committing mass changes.

## 74. Git secret accidentally committed

Treat a real secret as compromised:

- revoke/rotate it through the provider;
- remove it from current source;
- assess history cleanup/security response according to repository policy;
- do not assume adding it to `.gitignore` makes the exposed secret safe again.

## 75. CI workflow not visible immediately after push

A push and a workflow result are different events.

Do not claim the workflow passed until GitHub reports a completed successful run for the intended commit.

## 76. CI passes Web but native target fails

The permanent quality workflow and native platform workflow test different environments/artifacts.

Investigate the failed host-specific toolchain rather than assuming Web success proves all native targets.

## 77. Native hosted build passes but real device fails

Hosted compilation proves source/build compatibility on that runner. Real-device problems can involve:

- hardware;
- OS version;
- permissions;
- file/share handlers;
- accessibility;
- signed install;
- graphics/input/performance.

Record/fix real-device evidence separately.

## 78. App version displayed incorrectly

Check canonical surfaces:

```text
pubspec.yaml → 2.0.12+2012
lib/core/constants/project_info.dart → 2.0.12
windows/runner/Runner.rc → Windows fallback values
release qualification candidate
```

Do not update only visible About-screen text.

## 79. Documentation says old version

Current release-facing documentation should match current source.

Historical audit/phase records can legitimately mention old versions as historical evidence.

Do not rewrite historical evidence just to remove old version strings.

## 80. Dependency says newer release exists

A newer package does not mean the current pin is broken.

Run:

```bash
flutter pub outdated
```

Then evaluate security/fix/compatibility need. During the Version 2.0.12 compatibility freeze, avoid unneeded cross-platform plugin churn.

## 81. Tool is unsupported/EOL

Use [`setup/UPGRADING_AND_SUPPORT.md`](setup/UPGRADING_AND_SUPPORT.md).

Do not choose between “never upgrade” and “upgrade everything at once.” Migrate the smallest compatible unit and validate it.

## 82. Disk full during build

Check free space and remove **generated** output/caches using supported mechanisms.

Safe project cleanup:

```bash
flutter clean
```

Do not delete source, Git history, private signing keys, or arbitrary SDK internals to reclaim space.

## 83. Permission denied executing command

Possible causes:

- file not executable;
- filesystem mount policy;
- wrong path/ownership;
- trying to write SDK inside protected system directory.

Prefer installing Flutter in a user-writable development path rather than running all Flutter commands as administrator/root.

## 84. `Permission denied: ./gradlew`

On Unix-like systems, the wrapper script should have execute permission in a normal clone.

Inspect:

```bash
ls -l android/gradlew
```

Do not modify executable bits randomly across the repository.

## 85. Command works only when run as administrator/root

This often indicates the SDK/project is installed in a protected location or permissions are wrong.

Normal Flutter/Git project development should not require elevated privileges for every command.

Fix ownership/location rather than permanently developing as root/Administrator.

## 86. Error after moving Flutter SDK

Check old PATH/editor SDK configuration.

Windows:

```powershell
where.exe flutter
```

macOS/Linux:

```bash
type -a flutter
```

Then:

```bash
flutter --version
flutter doctor -v
```

## 87. Error after OS update

Major OS updates can change compilers, SDKs, signing, drivers, shells, or filesystem permissions.

Rerun:

```bash
flutter doctor -v
```

Then the host's native release build and affected project checks.

## 88. Error after dependency upgrade

Review exact changes:

```bash
git diff -- pubspec.yaml pubspec.lock
flutter pub outdated
flutter analyze
flutter test
```

Then rebuild every platform touched by the package/plugin.

## 89. Error after Flutter upgrade

Record:

```bash
flutter --version
dart --version
flutter doctor -v
```

Read breaking changes, compare native templates if required, then run complete gates. Do not overwrite customized platform folders blindly.

## 90. Minimum “return to known state” sequence

When the environment is valid and generated output is the suspected issue:

```bash
git status
flutter clean
flutter pub get
dart format --output=none --set-exit-if-changed lib test tool
flutter analyze
flutter test
dart run tool/repository_audit.dart --json
dart run tool/source_completion_audit.dart --json
```

Then run **one** failed target build again.

## 91. When to create an issue

Create a reproducible issue when:

- source bug persists on accepted toolchain;
- platform-specific failure has logs/steps;
- documentation is contradictory/missing;
- dependency/tool migration is needed;
- external repository setting is required.

Include:

- exact commit/version;
- host OS;
- Flutter/Dart output;
- relevant toolchain versions;
- exact command;
- first root-cause error;
- reproduction steps;
- expected versus actual behavior.

Never paste passwords/tokens/private signing material into an issue.

## 92. Related documentation

- [`TROUBLESHOOTING.md`](TROUBLESHOOTING.md) — project troubleshooting guide.
- [`BUILDING_EXECUTABLES.md`](BUILDING_EXECUTABLES.md) — target builds.
- [`COMMAND_REFERENCE.md`](COMMAND_REFERENCE.md) — command meanings.
- [`setup/README.md`](setup/README.md) — installation index.
- [`setup/UPGRADING_AND_SUPPORT.md`](setup/UPGRADING_AND_SUPPORT.md) — EOL/tool migration.
- [`REPOSITORY_FILE_ATLAS.md`](REPOSITORY_FILE_ATLAS.md) — file ownership/responsibilities.
