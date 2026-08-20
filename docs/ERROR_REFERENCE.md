# 2048 Nova Error and Diagnosis Reference

Current source target: **2.0.12+2012**.

Use this reference after the installation guides and [`TROUBLESHOOTING.md`](TROUBLESHOOTING.md). The goal is to identify the failing layer before changing versions, deleting caches, or editing platform files.

## 1. First diagnostic sequence

Run from the repository root:

```bash
flutter --version
dart --version
flutter doctor -v
flutter pub get
dart format --output=none --set-exit-if-changed lib test tool
flutter analyze
flutter test
```

Then run the project audits:

```bash
dart run tool/release_readiness.dart --json
dart run tool/repository_audit.dart --json
dart run tool/source_completion_audit.dart --json
```

Do not jump directly to `flutter clean` or dependency upgrades when the earlier command already identifies a concrete problem.

## 2. “flutter: command not found” / “not recognized”

Likely causes:

- Flutter SDK is not installed;
- the SDK `bin` directory is not on `PATH`;
- the terminal was opened before `PATH` changed;
- multiple Flutter installations are confusing shell resolution.

Check:

```bash
flutter --version
```

Windows:

```powershell
where.exe flutter
```

macOS/Linux:

```bash
which flutter
```

Use one intended SDK installation and reopen the terminal after changing `PATH`.

## 3. Flutter/Dart version mismatch

The project declares its minimum SDK constraints in `pubspec.yaml`. CI uses a reviewed Flutter 3.47.0 baseline.

If your SDK is below the declared floor, upgrade Flutter before trying to weaken project constraints. If your SDK is newer and introduces failures, compare behavior with the reviewed baseline before changing project pins.

See [`setup/TOOL_SUPPORT_MATRIX.md`](setup/TOOL_SUPPORT_MATRIX.md).

## 4. `flutter pub get` fails

Possible causes:

- unsupported Flutter/Dart version;
- network/DNS/proxy failure;
- package-host outage;
- lockfile or dependency constraint conflict;
- corrupted global package cache.

First read the exact solver/network error. Do not delete `pubspec.lock` merely because resolution failed.

Useful commands:

```bash
flutter pub get
flutter pub outdated
```

A package being “newer” does not automatically mean it should be upgraded during a release freeze.

## 5. Lockfile drift after `flutter pub get`

CI checks that dependency resolution does not unexpectedly alter controlled metadata.

Inspect:

```bash
git diff -- pubspec.lock analysis_options.yaml
```

If the diff is intentional, review dependency compatibility/licensing/platform impact and commit it with the corresponding validation. If it is not intentional, restore the tracked file rather than hiding the drift.

## 6. Formatter gate fails

Run:

```bash
dart format lib test tool
```

Then inspect:

```bash
git diff
```

Formatting is mechanical; do not manually fight canonical Dart formatting.

## 7. `flutter analyze` reports errors

Analyzer output includes file, line, rule/error, and message. Fix the source cause rather than adding broad ignores.

Common categories:

- type mismatch;
- nullable value used as non-null;
- unavailable API for the project SDK floor;
- dead/unreachable code;
- invalid imports;
- lint failures.

After a fix:

```bash
flutter analyze
flutter test
```

## 8. A widget test cannot tap a control

A failed test tap can mean the control is off-screen, covered, not laid out, or genuinely inaccessible.

Representative tests should scroll/ensure visibility before tapping rather than disabling hit-testing warnings.

For builder/action regressions, preserve realistic constrained viewport and text-scaling tests instead of forcing coordinates.

## 9. Layout overflow

Flutter reports yellow/black overflow in debug and test exceptions when content does not fit.

Check:

- narrow width;
- large text scale;
- localized Hindi strings;
- keyboard/insets;
- long user-created preset names;
- trailing actions inside `ListTile`.

Prefer responsive layout primitives (`Wrap`, flexible content, menus, scrolling) over shrinking text below accessible sizes.

## 10. Saved game will not restore

The project deliberately validates persisted state. Corrupted, malformed, incompatible, or unsafe data may be discarded/repaired rather than trusted.

Check the relevant tests and [`DATA_STORAGE.md`](DATA_STORAGE.md) before loosening validators.

A restore failure is not automatically a migration bug; invalid local data may be intentionally rejected.

## 11. Custom presets disappear after corruption

`CustomPresetStore` validates every record. Invalid neighbors can be dropped while valid presets survive; malformed top-level storage can be removed entirely.

This is corruption recovery, not silent cloud synchronization.

Storage key:

```text
nova.custom_game_presets.v1
```

See [`CUSTOM_GAME_BUILDER.md`](CUSTOM_GAME_BUILDER.md).

## 12. Custom game appears in built-in mode records

This is a trust-boundary regression.

Custom sessions must preserve `currentGameIsCustom` across save/resume and restart and must bypass built-in per-mode record updates.

Relevant tests:

- `test/custom_game_session_policy_test.dart`
- `test/custom_game_screen_policy_test.dart`

Do not “fix” it by marking all custom games unranked; imported-backup unranked policy is a different boundary.

## 13. Imported Game Backup affects trusted statistics

This is also a trust-boundary regression. Imported backups must remain unranked across restart.

Relevant tests include:

- `test/imported_game_policy_test.dart`
- `test/mode_record_unranked_test.dart`

## 14. Challenge Code rejected

Expected rejection reasons include:

- unsupported prefix/version;
- malformed payload;
- checksum mismatch;
- unsafe numeric bounds;
- unsupported mode/configuration;
- Daily Challenge injection;
- oversized input.

Do not bypass validation to open a received code. Regenerate or correct the code at its source.

## 15. Replay archive rejected

Full Replay Archives are bounded structural data. Invalid event order, unsupported schema, incomplete capture, oversized archive, or malformed fields are rejected.

A replay is spectator data, not authenticated proof of who played the game.

See [`REPLAY_ARCHIVES.md`](REPLAY_ARCHIVES.md).

## 16. Backup file picker behaves differently on a real platform

Hosted tests can validate application logic but cannot reproduce every Android document provider, iOS picker, browser save/open handler, Windows dialog, or sandbox permission behavior.

Use the manual qualification checklist. Do not record hosted test output as real handler evidence.

## 17. Android: Java/Gradle/AGP failure

Accepted Version 2.0.12 baseline:

```text
JDK 17
AGP 9.1.0
Kotlin Android 2.4.10
Gradle 9.7.0
```

Check:

```bash
java -version
cd android
./gradlew --version
```

Windows PowerShell/CMD uses:

```powershell
.\gradlew.bat --version
```

Do not upgrade only one coordinated Android toolchain component without compatibility review.

## 18. Android SDK/license failure

Run:

```bash
flutter doctor -v
flutter doctor --android-licenses
```

Then verify Android Studio SDK Manager has the required SDK/platform/build tools.

An accepted license does not prove the correct SDK package is installed.

## 19. APK builds but AAB fails

The project treats APK and AAB as separate maintained outputs.

Run both:

```bash
flutter build apk --release
flutter build appbundle --release
```

A release is not Android-store-ready solely because an APK exists.

## 20. Android signing failure

Public source must never contain real private keystores or passwords.

Use the documented local signing configuration and ensure ignored credential files exist only on the maintainer machine/secure CI secret path.

See [`BUILDING_EXECUTABLES.md`](BUILDING_EXECUTABLES.md).

## 21. Linux desktop build fails

Start with:

```bash
flutter doctor -v
cmake --version
ninja --version
pkg-config --version
```

Then confirm compiler and GTK development libraries are installed for your distribution.

See [`setup/LINUX.md`](setup/LINUX.md) and [`setup/LINUX_NATIVE_TOOLCHAIN.md`](setup/LINUX_NATIVE_TOOLCHAIN.md).

## 22. Windows desktop build fails

Flutter Windows requires Visual Studio with the **Desktop development with C++** workload, not only VS Code.

Run:

```powershell
flutter doctor -v
```

Resolve Visual Studio/C++ toolchain findings before editing generated runner files.

## 23. macOS/iOS build fails

Check:

```bash
flutter doctor -v
xcodebuild -version
pod --version
```

Open Xcode at least once, accept license/first-run components, and ensure the active developer directory is correct.

Unsigned hosted iOS compilation is not the same as signed IPA/App Store qualification.

## 24. Web build reports missing icon fonts

CI intentionally fails if the release build reports the project’s guarded missing-font warning.

Verify `pubspec.yaml` still has:

```yaml
flutter:
  uses-material-design: true
```

and that required icon dependencies/assets are intact.

## 25. PWA installs incorrectly

A successful Web compile does not prove installed PWA behavior.

Check source metadata (`web/index.html`, `web/manifest.json`, icons) and then qualify installation, launch scope, offline lifecycle, and storage on real supported browsers.

## 26. Repository audit fails

Run:

```bash
dart run tool/repository_audit.dart --json
```

Treat each failure as a repository contract violation. Common categories include:

- missing required file;
- version drift;
- broken local Markdown link;
- PWA metadata drift;
- temporary maintenance helper left behind;
- canonical project metadata mismatch.

## 27. Source-completion audit fails

Run:

```bash
dart run tool/source_completion_audit.dart --json
```

The audit protects the completed 2.0.12 source contract. It can fail on stale current-release metadata, missing completion assets/CI wiring, reopened optional backlog, or unresolved maintained Dart TODO/FIXME markers.

Do not remove the audit merely to make CI green.

## 28. Stable release gate fails at 0/13

That is expected while manual evidence is pending.

```bash
dart run tool/release_readiness.dart --stable --json
```

must fail closed until all required real-world checks have genuine evidence. Never edit evidence to satisfy the command without performing the check.

## 29. GitHub Actions passes on an old commit but current source changed

Old green CI is historical evidence only. Any product/test/tool/dependency/platform change after that commit requires appropriate gates again on the new exact candidate.

This rule is especially important for the Custom Game Builder integration because its original green feature PR was based on an older release line before integration with the 2.0.12 source tree.

## 30. Before reporting a bug

Include:

- exact commit or branch;
- OS and version;
- Flutter/Dart versions;
- `flutter doctor -v` relevant output;
- exact command;
- first meaningful error and nearby context;
- whether clean checkout reproduces it;
- whether it reproduces on the reviewed CI baseline;
- minimal steps for player-facing regressions.

Remove secrets, signing data, private backup contents, and unrelated personal information before posting logs.