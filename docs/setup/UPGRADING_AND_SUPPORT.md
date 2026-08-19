# Tool Upgrades, End-of-Support, and Compatibility Policy

This guide answers a critical maintenance question for **2048 Nova**:

> What should a contributor do when Flutter, Dart, Android Studio, Android SDK, JDK, Gradle, AGP, Kotlin, Xcode, CocoaPods, Visual Studio, VS Code, CMake, Ninja, Git, or an operating-system package becomes outdated or unsupported?

The goal is **supported and reproducible**, not blindly “newest everything.”

Checked against the repository on **2026-08-19**.

## 1. Current maintained baseline

The repository currently declares or pins:

```text
Application: 2.0.12+2012
Dart SDK range: >=3.9.0 <4.0.0
Flutter SDK floor: >=3.35.0
Hosted CI Flutter: 3.47.0 stable
Android Gradle Plugin: 9.1.0
Kotlin Android plugin: 2.4.10
Gradle Wrapper: 9.7.0
Android Java/Kotlin bytecode target: 17
```

Operating-system IDEs/SDKs such as Android Studio, Xcode, Visual Studio, platform SDKs, browsers, and Linux packages are partly external to the repository. Their support windows can change independently.

## 2. Definitions

### Current

A version currently offered/supported by its vendor or upstream project.

### Supported

A version for which the vendor/project still provides the applicable maintenance, compatibility, fixes, security updates, or support commitment.

### End of support / EOL

**EOL** means **end of life**. A release is no longer supported under the vendor/project's lifecycle policy.

### Deprecated

A feature/API still exists but is discouraged and may be removed later. Deprecation is an early migration signal, not necessarily immediate breakage.

### Breaking change

A change that can require source/configuration/migration work rather than being drop-in compatible.

### Pinned version

A deliberately fixed version recorded in source/CI, such as the Gradle Wrapper or CI Flutter SDK.

### Version floor

The oldest version accepted by a constraint, such as Flutter `>=3.35.0`.

### Compatibility matrix

The set of versions known or expected to work together: for example Flutter + Dart + AGP + Gradle + Kotlin + JDK + Android SDK.

## 3. “Latest” is not automatically “correct”

A cross-platform Flutter project depends on interconnected toolchains. A new major version of one component can require a new version of another.

Examples of compatibility relationships:

- Flutter ships a bundled Dart SDK.
- Flutter's Android templates/tooling expect supported AGP/Gradle/Kotlin/JDK combinations.
- AGP supports only defined Gradle/JDK ranges.
- Kotlin tooling interacts with AGP/Gradle.
- Xcode determines Apple SDK/compiler behavior.
- Flutter plugins can require newer Android/iOS/macOS platform APIs or native build tools.
- Windows Flutter builds depend on Visual Studio C++ tooling and a Windows SDK.
- Linux Flutter builds depend on native compiler/CMake/Ninja/GTK packages.

Therefore the maintenance rule is:

> Upgrade deliberately, validate the entire affected path, and record the new baseline only after it passes.

## 4. How to detect unsupported tooling

Use several signals rather than one command.

### Vendor lifecycle/support pages

Check the official support/lifecycle documentation for the tool or IDE. This is the authoritative source for whether a release is supported.

### Tool's own updater

Examples include Android Studio, Xcode/App Store, Visual Studio Installer, VS Code, and system package managers.

An available update does not necessarily mean the installed release is already unsupported; read the release/support information.

### Flutter diagnostics

```bash
flutter --version
flutter doctor -v
```

`flutter doctor -v` can reveal missing, incompatible, or incorrectly selected platform tools.

### Dependency report

```bash
flutter pub outdated
```

This reports package-update possibilities. It does not decide whether upgrading is safe for this release.

### Gradle deprecation report

macOS/Linux:

```bash
cd android
./gradlew help --warning-mode=all
```

Windows:

```powershell
cd android
.\gradlew.bat help --warning-mode=all
```

Deprecation warnings can identify work needed before a future Gradle upgrade.

### Security advisories

A supported release can still require an urgent patch. Security-driven upgrades may take priority over the normal compatibility freeze, but still require validation.

## 5. Severity classification

Treat update needs differently.

### Critical security update

Act promptly. Determine whether the vulnerability affects this project/environment and upgrade to the smallest supported fixed version when practical, then run the full validation matrix.

### Tool has reached end-of-support

Plan migration to a supported vendor-recommended release. Do not keep an EOL tool as the permanent baseline simply because it still compiles locally.

### Normal patch/minor update

Review release notes and compatibility. During a release freeze, defer nonessential churn unless it fixes a real issue, improves supportability, or is required by a platform/store policy.

### Major upgrade

Treat as a migration. Expect API/config/build behavior changes and broaden testing.

### Optional editor update

Editors such as VS Code are generally less coupled than compilers/build systems, but extension/runtime changes can still affect debugging/analysis workflows. Validate normal development after upgrading.

## 6. Never upgrade all layers at once without evidence

Avoid changing all of these together in one unexplained commit:

```text
Flutter
Dart constraints
AGP
Gradle
Kotlin
JDK
Android SDK target levels
Xcode
CocoaPods
Visual Studio
Flutter plugins
```

If the final build fails after ten simultaneous upgrades, identifying the cause becomes unnecessarily difficult.

Instead use small, meaningful commits or grouped compatibility changes with clear rationale.

## 7. Safe upgrade workflow

### Step 1 — Record the current baseline

```bash
flutter --version
dart --version
flutter doctor -v
git status
```

For Android:

```bash
cd android
./gradlew --version
cd ..
```

Capture relevant IDE/platform versions too.

### Step 2 — Start from clean Git state

```bash
git status
```

Do not start a toolchain migration on top of unrelated uncommitted source changes.

### Step 3 — Create a maintenance branch

```bash
git switch -c maintenance/toolchain-upgrade
```

This isolates the upgrade and makes rollback/review straightforward.

### Step 4 — Read official compatibility/release notes

Identify:

- supported source/target versions;
- minimum JDK/OS requirements;
- removed/deprecated APIs;
- required configuration migration;
- plugin/template changes;
- store/platform policy changes.

### Step 5 — Upgrade the smallest necessary layer

Prefer one compatibility unit at a time.

### Step 6 — Regenerate only when justified

Do not run `flutter create .` or replace native runner files casually. Generated platform projects often contain intentional repository customizations such as application IDs, signing logic, version metadata, PWA data, and branding.

If template comparison is needed, generate a temporary clean Flutter project with the new SDK and compare relevant files manually.

### Step 7 — Resolve dependencies

```bash
flutter pub get
```

Inspect:

```bash
git status
git diff -- pubspec.yaml pubspec.lock
```

### Step 8 — Run source quality checks

```bash
dart format --output=none --set-exit-if-changed lib test tool
flutter analyze
flutter test --coverage
```

### Step 9 — Run repository gates

```bash
dart run tool/release_readiness.dart --json
dart run tool/release_qualification_status.dart --json --pending-only
dart run tool/repository_audit.dart --json
dart run tool/source_completion_audit.dart --json
dart run tool/solver_benchmark.dart 8
```

### Step 10 — Build every affected target

At minimum rebuild targets whose toolchain changed.

For a Flutter SDK upgrade, that means the complete maintained platform matrix where possible:

```text
Android APK/AAB
Web
Windows
Linux
macOS
iOS unsigned build
```

Use native hosts/CI where cross-host building is not supported.

### Step 11 — Real-environment qualification

A toolchain migration can change runtime behavior even when automated tests pass. Re-run the applicable physical-device/browser/accessibility/external-handler/signing/store checks before making a stable distribution claim.

### Step 12 — Update documentation and CI

If the new toolchain becomes the project baseline, update together:

- source constraints;
- native configuration pins;
- CI SDK pins;
- dependency/Android/toolchain documentation;
- build guides;
- changelog/continuity;
- tests/audits that intentionally protect the baseline.

## 8. Flutter upgrade procedure

Check:

```bash
flutter --version
flutter channel
```

For stable:

```bash
flutter channel stable
flutter upgrade
flutter doctor -v
```

Then:

```bash
flutter pub get
flutter pub outdated
dart format --output=none --set-exit-if-changed lib test tool
flutter analyze
flutter test --coverage
```

Important:

- Flutter includes Dart; a Flutter upgrade changes the bundled Dart SDK too.
- Read Flutter breaking-change/migration notes.
- Compare any template/native changes rather than blindly overwriting project runners.
- Update `.github/workflows/` Flutter pins only after intentionally accepting the new baseline.

## 9. Dart upgrade procedure

For a Flutter app, Dart normally upgrades **with Flutter**.

Check:

```bash
dart --version
flutter --version
```

Do not point this Flutter project at an unrelated standalone Dart SDK and assume Flutter will use it.

If the project changes its Dart constraint in `pubspec.yaml`, ensure the selected Flutter version actually bundles a Dart version satisfying that constraint and run all tests/analyzer/tool CLIs.

## 10. Git upgrade procedure

Check:

```bash
git --version
```

Upgrade using your OS/vendor-supported package method.

Afterward verify:

```bash
git --version
git status
git remote -v
```

Git upgrades do not normally rewrite project files, but authentication helpers, SSH behavior, defaults, or security policies can change between major releases.

## 11. Android Studio upgrade procedure

Use Android Studio's stable supported updater or official installer.

After updating:

1. reopen SDK Manager;
2. verify SDK path/components;
3. verify emulator/device setup;
4. run `flutter doctor -v`;
5. run Android release builds.

Do not automatically replace the repository's AGP/Kotlin/Gradle versions merely because Android Studio offers newer project templates.

## 12. Android SDK upgrade procedure

Review installed/available SDK packages in Android Studio SDK Manager or:

```bash
sdkmanager --list
```

Update installed packages when appropriate:

```bash
sdkmanager --update
```

After SDK changes:

```bash
flutter doctor -v
flutter build apk --release
flutter build appbundle --release
```

If a store requires a newer target SDK, treat the target update as a release requirement and validate behavior changes associated with that Android API level.

## 13. JDK upgrade procedure

Check both system and Flutter-selected Java:

```bash
java -version
javac -version
flutter doctor -v
```

Before moving away from JDK 17, verify that the active Flutter/AGP/Gradle combination supports the intended JDK.

If selecting a JDK explicitly:

```bash
flutter config --jdk-dir="/path/to/jdk"
```

Then run Gradle and Android builds.

A newer JDK can be unsupported by an older Gradle/AGP even when `java -version` itself works.

## 14. Gradle upgrade procedure

The repository uses its Wrapper, so upgrade the wrapper—not a global Gradle installation.

Before change:

```bash
cd android
./gradlew --version
./gradlew help --warning-mode=all
```

After confirming AGP/Flutter compatibility, update using Gradle's supported wrapper process and verify the resulting `gradle-wrapper.properties`/wrapper metadata.

Then:

```bash
./gradlew --version
cd ..
flutter build apk --release
flutter build appbundle --release
```

Keep distribution checksum verification enabled.

## 15. AGP upgrade procedure

AGP is pinned in `android/settings.gradle.kts`.

Before upgrading:

- verify compatible Gradle versions;
- verify compatible JDK versions;
- read AGP migration notes;
- inspect lint/manifest/packaging/build-feature changes;
- verify Flutter supports the target combination.

After updating, run Gradle warnings/tasks, Flutter analyzer/tests, APK/AAB builds, and native CI.

## 16. Kotlin upgrade procedure

Kotlin Android is also pinned in `android/settings.gradle.kts`.

Before updating, verify compatibility with AGP/Gradle/Flutter plugins. After updating, build the Android host and exercise any Android-native plugin paths.

Do not infer that the latest Kotlin compiler is automatically compatible with every installed AGP/Gradle combination.

## 17. Xcode upgrade procedure

After installing/updating Xcode:

```bash
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
sudo xcodebuild -runFirstLaunch
xcodebuild -version
flutter doctor -v
```

Then rebuild:

```bash
flutter build macos --release
flutter build ios --release --no-codesign
```

If you perform signed Apple distribution, revalidate certificates, provisioning, archive/export, entitlements, notarization/store steps as applicable.

Xcode changes the compiler and Apple platform SDKs, so treat a major Xcode update as a native toolchain migration.

## 18. CocoaPods upgrade procedure

Check:

```bash
pod --version
```

Upgrade with the same package-management method used to install CocoaPods. Avoid mixing Homebrew, RubyGems, system Ruby, and other managers without understanding which `pod` executable wins on `PATH`.

Check:

```bash
which pod
type -a pod
```

After upgrade, run normal Flutter package resolution and Apple platform builds.

## 19. Visual Studio upgrade procedure

Use **Visual Studio Installer**.

Before/after upgrading, ensure the **Desktop development with C++** workload remains installed because Flutter Windows desktop requires native C++ tooling.

Then:

```powershell
flutter doctor -v
flutter build windows --release
```

If an old Visual Studio release is out of support, migrate to a Flutter-supported Visual Studio release and revalidate the Windows runner instead of keeping an unsupported compiler toolset indefinitely.

## 20. VS Code upgrade procedure

VS Code is an editor, not the Windows C++ compiler.

When managed by WinGet:

```powershell
winget upgrade --id Microsoft.VisualStudioCode -e
```

Update extensions:

```bash
code --update-extensions
```

Verify Flutter/Dart extension behavior, analyzer integration, debug launch, and formatting after major extension changes.

## 21. CMake upgrade procedure

Check:

```bash
cmake --version
```

CMake affects Windows/Linux native builds and plugins. Upgrade using the supported host package/IDE method, then build the affected desktop target.

Do not edit Flutter-generated/native CMake files merely to silence a version warning without understanding the compatibility requirement.

## 22. Ninja upgrade procedure

Check:

```bash
ninja --version
```

Ninja executes native build plans generated by CMake. Upgrade through the OS/IDE-supported method, then rebuild Windows/Linux native targets that depend on it.

## 23. Operating-system upgrades

An OS upgrade can implicitly change:

- compilers;
- SDKs;
- certificate stores;
- shells;
- filesystem behavior;
- code-signing/notarization requirements;
- device drivers;
- package-manager libraries.

After a major Windows/macOS/Linux update:

```bash
flutter doctor -v
```

Then rebuild the host's native target and any Android/Web targets maintained on it.

## 24. Flutter package dependency upgrades

Inspect first:

```bash
flutter pub outdated
```

Normal resolution within current constraints:

```bash
flutter pub upgrade
```

Major-version migration helper:

```bash
flutter pub upgrade --major-versions
```

The major-version form can alter dependency constraints and expose breaking APIs. Review `pubspec.yaml` and `pubspec.lock`, read package changelogs, then test all platform paths affected by native plugins.

For this project's feature-complete Version 2.0.12 line, compatibility-first freeze rules apply: do not churn dependencies without a concrete maintenance reason.

## 25. Rollback strategy

Before a migration, commit or stash only intentional work so the baseline is recoverable.

Inspect changes:

```bash
git status
git diff
```

If a source-controlled pin/config upgrade is rejected during review, restore it through normal Git history/revert rather than manually guessing old versions.

For SDK/IDE installations, use the vendor-supported version manager/installer/archive policy to restore a compatible release if necessary.

Never delete Git history to hide a failed upgrade experiment.

## 26. CI baseline updates

The permanent workflow currently pins Flutter `3.47.0`.

Changing a CI pin means changing the repository's reproducible evidence environment. Before accepting it:

1. verify local/reference behavior;
2. update dependency/native pins if compatibility requires it;
3. update docs;
4. run CI quality gates;
5. run native builds;
6. record actual observed results.

Do not describe an unobserved workflow trigger as a successful verification result.

## 27. Store/platform policy deadlines

Google Play, Apple platforms, Windows signing/distribution ecosystems, browser policies, and Linux distributions can introduce deadlines independent of source-code feature plans.

When an external policy forces an SDK/toolchain update:

- document the exact requirement/deadline;
- migrate the minimum necessary platform/toolchain layers;
- preserve cross-platform behavior;
- run the complete affected qualification set;
- update release documentation.

## 28. Unsupported dependencies

If a Flutter/Dart/native package is abandoned or incompatible with supported toolchains:

1. verify whether the project still uses the feature;
2. look for an actively maintained compatible replacement or remove the dependency if unnecessary;
3. evaluate license/security/privacy behavior;
4. migrate behind tests;
5. validate every supported platform touched by that plugin;
6. update `DEPENDENCIES.md` and supply-chain documentation.

Do not silently switch to an unknown fork merely because its version number is newer.

## 29. Unsupported operating system

If the workstation OS itself reaches end-of-support, upgrading only Flutter is insufficient. Move development/signing work to a supported OS release compatible with the required SDKs and IDEs.

Preserve source through Git; do not rely on copying generated build directories from the old machine as a migration strategy.

## 30. Upgrade acceptance checklist

An upgrade is ready to become the maintained baseline only when applicable items pass:

```text
[ ] Vendor/upstream support confirmed
[ ] Compatibility notes reviewed
[ ] Clean migration branch used
[ ] Tool versions captured
[ ] flutter doctor -v healthy for intended targets
[ ] flutter pub get completed
[ ] pubspec/lockfile diff reviewed
[ ] Dart formatting gate passed
[ ] flutter analyze passed
[ ] flutter test --coverage passed
[ ] release readiness candidate check passed as designed
[ ] repository audit passed
[ ] source completion audit passed
[ ] solver benchmark passed
[ ] Web release built
[ ] Android APK built
[ ] Android AAB built
[ ] Windows native build passed when affected
[ ] Linux native build passed when affected
[ ] macOS native build passed when affected
[ ] iOS unsigned build passed when affected
[ ] Production signing paths revalidated when affected
[ ] Real-device/browser/accessibility qualification repeated where affected
[ ] Docs/CI/toolchain pins updated together
[ ] Actual evidence recorded without exaggeration
```

The strict stable qualification state remains governed by the project's canonical release-evidence manifest; an upgrade does not waive those requirements.

## 31. Related documentation

- [`PREREQUISITES.md`](PREREQUISITES.md) — all tools and why they are needed.
- [`WINDOWS.md`](WINDOWS.md) — Windows install/upgrade detail.
- [`MACOS.md`](MACOS.md) — macOS/iOS install/upgrade detail.
- [`LINUX.md`](LINUX.md) — Linux install/upgrade detail.
- [`ANDROID.md`](ANDROID.md) — Android SDK/JDK/AGP/Gradle/Kotlin detail.
- [`../COMMAND_REFERENCE.md`](../COMMAND_REFERENCE.md) — command and flag meanings.
- [`../DEPENDENCIES.md`](../DEPENDENCIES.md) — application package dependency policy.
- [`../SUPPLY_CHAIN.md`](../SUPPLY_CHAIN.md) — dependency/workflow integrity.
- [`../ANDROID_TOOLCHAIN.md`](../ANDROID_TOOLCHAIN.md) — accepted repository Android baseline.
- [`../MAINTENANCE_POLICY.md`](../MAINTENANCE_POLICY.md) — post-completion maintenance rules.