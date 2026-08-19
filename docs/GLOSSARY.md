# 2048 Nova Glossary

This glossary defines the important words, abbreviations, file types, build concepts, platform terms, gameplay terms, testing terms, release terms, and command-line concepts used throughout the **2048 Nova** documentation.

The goal is that a beginner should not need to guess what a technical word means before following another guide.

## A

### AAB
**Android App Bundle.** A publishing format containing compiled Android app code/resources. Stores such as Google Play use it to generate optimized APKs for individual devices. It is not normally installed directly by tapping the file.

### ABI
**Application Binary Interface.** Rules that define how compiled machine code interacts with a processor/runtime, including architecture-specific conventions. Android examples include ARM and x86-family ABIs. `--split-per-abi` creates architecture-specific APK outputs.

### ADB
**Android Debug Bridge.** Command-line tool used to communicate with Android devices/emulators for debugging, logs, app installation, shell access, and device discovery.

### AGP
**Android Gradle Plugin.** Google's plugin that adds Android-specific build functionality to Gradle. It has compatibility requirements with Gradle, JDK, Android SDK, and other tooling.

### Analysis / static analysis
Inspection of source code without running the full application. `flutter analyze` uses Dart's analyzer and repository lint configuration to detect many code problems.

### Android SDK
Collection of Android platform APIs, build tools, platform tools, command-line tools, emulator packages, and other components used to develop Android applications.

### API
**Application Programming Interface.** A defined way for software components to interact. An API can be a Dart class/method contract, Android platform API, operating-system API, web API, or service interface.

### API level
Android's integer platform-version identifier. `minSdk`, `targetSdk`, and `compileSdk` refer to Android API levels for different purposes.

### APK
**Android Package.** Installable Android application package file.

### App bundle
A structured collection of an app's executable/resources. On macOS, `.app` is a directory bundle; on Android, “App Bundle” commonly means `.aab`.

### Artifact
A generated output produced by a build or CI job, such as an APK, AAB, ZIP, `.app`, Web bundle, test report, coverage file, or checksum.

### Assertion
A program check expressing something that must be true. Assertions can catch invalid assumptions during development/testing.

### AVD
**Android Virtual Device.** Configuration describing a virtual Android device run by the Android Emulator.

## B

### Backend
Server-side service or infrastructure. 2048 Nova is intentionally offline-first and does not require a project backend for core gameplay.

### Base path / base href
Web deployment path context used so browser assets/routes resolve correctly when an app is hosted below a domain root rather than at `/`.

### Binary
Compiled executable data intended for a machine/runtime rather than human-readable source text. An `.exe` and ELF executable are binaries.

### Branch
Independent movable Git line of development pointing to a sequence of commits, such as `main` or a maintenance branch.

### Breaking change
A change that requires consumers/source/configuration to migrate rather than remaining fully backward compatible.

### Build
The process of transforming source/configuration/assets into executable/deployable output.

### Build mode
Flutter compilation mode: normally `debug`, `profile`, or `release`, each optimized for a different purpose.

### Build number
Integer-like release/build identifier used by platform packaging. The project currently uses `2012` in `2.0.12+2012`.

### Build Tools
Android SDK package containing tools used during Android compilation/packaging.

## C

### Cache
Stored reusable data intended to avoid repeating expensive work. Build/package caches can speed development but can occasionally become stale.

### Candidate release
Source/artifact considered for release but not automatically proven stable. The repository's release tooling separates candidate readiness from strict stable qualification.

### Checksum
Digest calculated from file contents, commonly SHA-256. It helps detect corruption/unexpected changes but does not prove publisher identity.

### CI
**Continuous Integration.** Automated system that checks code changes through formatting, analysis, tests, audits, builds, and other gates. This repository uses GitHub Actions.

### CI/CD
**Continuous Integration / Continuous Delivery or Deployment.** CI validates changes; CD refers to automated delivery/deployment workflows. This project deliberately keeps production-signing/store evidence separate from ordinary hosted build validation.

### CLI
**Command-Line Interface.** Text-based interface used from a terminal, such as `flutter`, `dart`, `git`, `adb`, or repository-owned Dart tools.

### Clone
A local Git repository copied from another repository, usually including its history and remote configuration.

### CMake
Cross-platform native build-configuration generator used by Flutter desktop/native tooling.

### Code signing
Cryptographic signing of application artifacts so platforms can verify signing identity/integrity according to their trust model.

### CocoaPods
Dependency manager commonly used by iOS/macOS native code and Flutter plugins on Apple platforms.

### Commit
Immutable Git history object recording a source-tree snapshot, metadata, parent commit(s), and commit message.

### Commit SHA
Cryptographic identifier for a Git commit. Often abbreviated to its leading characters.

### Compile
Translate source/intermediate representation into lower-level executable code or another build representation.

### `compileSdk`
Android API level used to compile the Android application. In this repository the value comes from the active Flutter SDK configuration.

### Compiler
Program that transforms source code into another form, commonly machine code or intermediate code. Examples include Dart/Flutter compilers, Clang, Kotlin compiler, and Java compiler.

### Constraint
Rule defining allowed versions or values. `>=3.9.0 <4.0.0` is a Dart SDK version constraint.

### Cross-platform
Software designed to run on multiple platforms while sharing substantial source code. It does not mean every native target can be compiled from every host OS.

## D

### Dart
Programming language used by Flutter and this repository's application/test/tool source.

### Dart SDK
Compiler, runtime, analyzer, formatter, package tools, and other Dart development components. Flutter bundles a compatible Dart SDK.

### Debug build
Development-oriented build with debugging facilities and lower optimization than release mode.

### Dependency
External package/library/tool that another part of the project requires.

### Dependency lockfile
File recording exact resolved package versions. For Dart/Flutter this project uses `pubspec.lock`.

### Deprecated
Still available but discouraged and potentially scheduled for later removal/replacement.

### Deployment
Making a built application available in an environment, such as uploading the Web bundle to a host.

### Deterministic
Given the same defined inputs/state/seed, produces the same defined result. Determinism is important to the game's seeded challenges, replays, tests, and solver benchmarks.

### Device ID
Identifier used by Flutter to select a target with `-d` / `--device-id`.

### Distribution signing
Production/release signing using the private identity intended for actual distribution, distinct from debug/qualification signing.

### DLL
**Dynamic-Link Library.** Windows runtime library file that can be loaded by executables. Flutter Windows output includes DLLs that must remain with the app bundle.

### Domain layer
Core business/game logic independent of presentation where practical. In this repository, `lib/domain/` contains major deterministic game data/engine functionality.

## E

### ELF
**Executable and Linkable Format.** Common binary format on Linux. The generated Linux executable is an ELF binary within a larger runtime bundle.

### Emulator
Software simulating a device/platform environment, such as Android Emulator.

### End of life (EOL)
Point at which a vendor/project stops supporting a release under its lifecycle policy.

### Entitlement
Apple-platform capability/signing declaration controlling access to specific system features/services.

### Environment variable
Named value supplied by the operating system/shell to processes. `PATH` is a key example.

### Exit code
Integer returned by a CLI program to its caller. Conventionally `0` means success and non-zero means failure or another tool-defined unsuccessful status.

### Expectimax
Search algorithm used by the project's optional solver/autoplay logic to evaluate player moves and probabilistic future tile spawns under bounded search constraints.

## F

### Feature-complete
Declared source feature scope has been implemented for the release target. It does not mean no unknown defect can exist or that external qualification is automatically complete.

### Flag / option
Command-line token modifying command behavior, commonly beginning with `-` or `--`, such as `--release`.

### Flutter
Cross-platform application framework/toolkit used to build 2048 Nova.

### Flutter channel
Release stream for Flutter SDK versions, such as `stable` or `beta`.

### Flutter Doctor
`flutter doctor` diagnostic command that checks availability/compatibility of platform development tools.

### Flutter plugin
Dart package that can include native platform integration for Android/iOS/macOS/Windows/Linux/Web.

### Formatter
Tool that applies standardized source-code formatting. This repository uses `dart format`.

### Framework
Reusable software structure/libraries that provide application architecture/runtime functionality. Flutter is a framework/toolkit.

## G

### Generated file
File created by tools/build systems rather than primarily authored by hand. Whether it belongs in Git depends on the specific tool/project contract.

### Git
Distributed version-control system used by the repository.

### GitHub
Hosting/collaboration service where the repository, issues, pull requests, and GitHub Actions workflows live.

### GitHub Actions
GitHub's automation system used for CI and platform build workflows.

### Gradle
Build automation engine used by Android builds.

### Gradle Wrapper
Project-controlled `gradlew`/`gradlew.bat` scripts and wrapper configuration that select/download the repository's intended Gradle version.

### GTK
Linux graphical toolkit used by Flutter's Linux desktop embedding. GTK 3 development libraries are required by the current Flutter Linux setup.

## H

### Hash
Fixed-size digest derived from data. Git object IDs and SHA-256 artifact checksums are examples, though they serve different purposes.

### Headless
Running without an interactive graphical display/user interface. Some CI tasks are headless.

### Hosted runner
Cloud VM/environment provided by GitHub Actions for a workflow job, such as Ubuntu, Windows, or macOS runner images.

### Hot reload
Flutter development feature that applies many Dart source changes to a running debug app while preserving much current state.

### Hot restart
Restarts Flutter application Dart state more completely than hot reload while remaining faster than a full rebuild in development.

## I

### IDE
**Integrated Development Environment.** Application combining editor, project navigation, debugger, build integrations, and other development features. Android Studio, Visual Studio, and Xcode are IDEs.

### IPA
iOS application archive/package used for signed distribution/testing workflows. Producing a usable IPA requires appropriate Apple signing/export configuration.

### Issue
Tracked task/bug/feature/discussion item in GitHub Issues.

## J

### Java
Programming language/runtime ecosystem used by Android build tooling and possibly host integration.

### JDK
**Java Development Kit.** Java runtime plus compiler/development tools. The accepted Android baseline targets Java/JVM 17.

### JRE
**Java Runtime Environment.** Runtime-only Java environment concept. Android builds need a JDK rather than merely a JRE.

### JSON
**JavaScript Object Notation.** Text data-interchange format. Several repository tools support `--json` machine-readable output.

### JVM
**Java Virtual Machine.** Runtime target for Java/Kotlin bytecode. The Android project configures JVM target 17.

## K

### Keystore
Protected file/container used by Android Java/signing tooling to store cryptographic keys/certificates. Production keystores must remain private.

### Kotlin
Programming language used for Android-native build/runner integration. The project pins a Kotlin Android plugin version independently from Dart source.

## L

### License
Legal terms governing software/source/dependencies. The repository itself uses the MIT License; third-party dependencies retain their own licenses.

### Lint
Static rule that detects suspicious, inconsistent, or undesirable source patterns. Flutter/Dart lints are evaluated by analysis.

### Local storage
Data stored on the user's device/browser rather than a remote project server. 2048 Nova is offline-first and persists game/preferences locally through platform-supported mechanisms.

### Lockfile
See **dependency lockfile**.

## M

### Manifest
Metadata file describing an application/platform resource. Android has `AndroidManifest.xml`; Web/PWA uses `manifest.json`.

### Marketing version
Human-facing release version, currently `2.0.12`, distinct from the added build number `2012`.

### Merge
Git operation combining development histories. A merge commit can have more than one parent.

### `minSdk`
Minimum Android API level allowed for installation. This project gets it from Flutter's supported Android configuration.

### MSBuild
Microsoft build engine used by Visual Studio/native Windows build tooling.

### MSVC
Microsoft Visual C++ compiler/toolchain used for Flutter Windows desktop builds.

## N

### Namespace
Android module package namespace used for generated/resources/source organization. It is separate conceptually from the final `applicationId`, although this project currently uses the same value for both.

### Native code
Platform-specific compiled code such as C/C++, Kotlin/Java, Objective-C/Swift, or platform runner configuration as opposed to shared Dart source.

### Native runner
Thin platform project/executable shell that hosts the Flutter engine/application on Windows, Linux, macOS, iOS, or Android.

### NDK
**Android Native Development Kit.** Android toolchain for C/C++ native code. This repository follows `flutter.ndkVersion`.

### Ninja
Fast native build tool often used with CMake. Flutter desktop builds use it on applicable hosts.

### Notarization
Apple service/process that checks signed macOS software for distribution trust requirements. It is separate from simply compiling a `.app`.

## O

### Offline-first
Application design where core functionality works without a continuous network service. Project data is primarily stored locally.

### Origin
Conventional Git remote name assigned by `git clone` to the source repository.

### OS
**Operating System**, such as Windows, macOS, Linux, Android, or iOS.

## P

### Package
Reusable software/library or distributable artifact; meaning depends on context. Dart dependencies are packages, while APK is also an application package.

### Package manager
Tool that installs/updates software packages. Examples: Pub, `winget`, Homebrew, `apt`, `dnf`, `pacman`, CocoaPods.

### PATH
Environment variable containing directories searched for executable commands. Incorrect or duplicate PATH entries can cause the wrong Flutter/Git/Java tool to run.

### Platform
Operating/runtime target supported by the application: Android, iOS, Web, Windows, macOS, Linux.

### Platform-Tools
Android SDK package containing `adb` and related device-side tooling.

### Plugin
Extension/component integrated into another system. Flutter packages can be plugins; IDEs also use plugins/extensions.

### Profile build
Flutter build mode intended for performance profiling on supported devices, between debug and release use cases.

### Provisioning profile
Apple-signed configuration linking application identifiers, capabilities, certificates, and allowed distribution/device contexts.

### Pub
Dart package manager used by `flutter pub ...` and `dart pub ...` commands.

### `pubspec.yaml`
Primary Dart/Flutter project metadata file defining package identity, SDK constraints, dependencies, assets, and other Flutter settings.

### `pubspec.lock`
Resolved dependency lockfile containing concrete package versions.

### Pull request (PR)
GitHub proposal to merge changes from one branch/ref into another, with review/status checks/discussion.

### PWA
**Progressive Web App.** Web application with installability/offline-capable metadata/behavior where supported by browser/platform. The repository contains dedicated PWA documentation and Web manifest data.

## Q

### Qualification
Evidence-gathering process showing an artifact/source meets defined requirements in a real or automated environment. This repository explicitly separates automated qualification from physical-device/store/accessibility evidence.

### Qualification artifact
Build output retained for checking/testing. It is not automatically production-signed or store-ready.

## R

### Release build
Optimized build intended to represent production behavior more closely than debug/profile modes.

### Release candidate
See **candidate release**.

### Release gate
Automated/policy condition that must be met before a release state can be claimed. This repository has candidate and strict stable readiness behavior.

### Remote
Git reference to another repository location. `origin` is the conventional default remote name.

### Repository
Version-controlled project history/files plus Git metadata. On GitHub it also includes issues, settings, workflows, and collaboration metadata.

### Reproducible
Process controlled enough that equivalent inputs/toolchain produce equivalent expected build/check behavior. Exact byte-for-byte reproducibility is a stronger claim and should not be assumed unless proven.

### Runtime
Environment/software executing compiled/application code.

## S

### SDK
**Software Development Kit.** Tools/libraries needed to build against a platform/framework, such as Flutter SDK or Android SDK.

### `sdkmanager`
Android command-line tool used to list/install/update Android SDK packages.

### Semantic version / SemVer
Versioning convention using `major.minor.patch` concepts. Project version `2.0.12` follows that shape, though platform-specific release semantics remain controlled by project policy.

### SHA
**Secure Hash Algorithm.** Family of cryptographic hash functions. Git SHAs identify objects; SHA-256 sidecars verify artifact contents.

### Shell
Command interpreter such as PowerShell, Bash, or Zsh.

### Signing certificate
Certificate/public identity component used with a private signing key in platform code-signing systems.

### Simulator
Software environment simulating a platform/device. Apple's Simulator is commonly used for iOS development. It is not identical to real hardware.

### Source of truth
Canonical file/system that determines a particular fact. Example: `pubspec.yaml` is source of truth for the package version.

### Stable channel
Flutter release channel intended for production/general stable use rather than preview/beta development.

### Static analysis
See **analysis**.

### Store signing
Signing performed/managed according to an application store's distribution model. It may differ from a developer's local upload signing identity.

### Subcommand
Command nested under a program, e.g. `build` in `flutter build apk`.

### Supply chain
The dependencies, SDKs, actions, artifacts, package registries, build infrastructure, and integrity/security processes that contribute to software production.

## T

### Target
Platform/device/build goal selected for compilation or execution.

### `targetSdk`
Android API level declaring the app's target behavior compatibility. It can affect platform compatibility behavior and store policy requirements.

### Test
Executable verification of expected behavior. Unit/widget/integration/manual tests cover different scopes.

### Toolchain
Set of interdependent development/build tools used to produce a platform target. Android's includes Flutter/Dart, JDK, Gradle, AGP, Kotlin, SDK/NDK, etc.

### Transitive dependency
Dependency required indirectly through another dependency rather than declared directly by the application.

## U

### Unranked import
Project trust policy where imported portable game/progress data does not automatically become trusted ranked/statistical evidence.

### Upgrade
Move software/dependency/tooling to a newer version. An upgrade is not accepted as project baseline until compatibility is validated.

### UTC
**Coordinated Universal Time.** Time standard used for portable timestamp serialization/evidence to avoid local timezone ambiguity.

## V

### Version control
System for recording/managing source changes/history. Git provides this project's version control.

### Version code
Android's monotonically managed integer release identifier. Flutter derives it from the build-number portion of the project version unless overridden.

### Version name
Human-readable Android release version, derived from Flutter build name/project version unless overridden.

### Visual Studio
Microsoft IDE/toolchain product required for Flutter Windows native builds with the Desktop development with C++ workload. It is **not Visual Studio Code**.

### Visual Studio Code (VS Code)
Lightweight cross-platform editor with Flutter/Dart extensions. It does not provide the MSVC/Windows native build toolchain by itself.

## W

### Wasm
**WebAssembly.** Portable binary instruction format supported by modern Web environments. Flutter may provide WebAssembly-oriented build paths depending on SDK/platform support.

### Web bundle
Complete generated output directory from `flutter build web`, including HTML, scripts/Wasm assets, Flutter bootstrap files, manifests, icons, and other resources.

### Widget
Flutter's primary UI composition object. Layout, text, controls, animation, and screens are assembled from widgets.

### WinGet
Windows Package Manager CLI (`winget`) used to install/update registered Windows software packages.

### Workflow
Automated GitHub Actions definition stored under `.github/workflows/`.

### Working tree / worktree
Checked-out files representing the current Git branch/commit plus local modifications.

## X

### Xcode
Apple IDE/compiler/SDK suite required to build native iOS and macOS applications.

### `xcodebuild`
Xcode command-line build tool used to query/build Apple projects and perform setup operations.

### `xcode-select`
macOS command for viewing/selecting the active developer-tools directory.

## Y

### YAML
Human-readable structured data format used by `pubspec.yaml`, GitHub Actions workflow files, issue templates, and other configuration.

## Z

### ZIP
Compressed archive format used to package complete platform bundles/artifacts for transport. A ZIP is packaging, not a code-signing mechanism.

## Gameplay terminology

### Board
Grid containing numbered tiles.

### Cell
One position in the board grid.

### Move
Player action shifting tiles in one of the allowed directions according to game rules.

### Merge
When eligible equal-valued tiles combine according to deterministic 2048 movement rules.

### Spawn
Creation of a new tile after a valid move under the selected game/mode rules.

### Seed
Input to deterministic pseudo-random generation. Same defined seed/state/rules can reproduce the same pseudo-random sequence.

### RNG
**Random Number Generator.** In deterministic game/replay contexts this means pseudo-random state whose sequence is reproducible from known state/seed.

### Undo
Bounded restoration of an earlier trusted local game state according to project rules.

### Hint
Read-only solver recommendation that evaluates current state without autonomously changing trusted gameplay until the user chooses a move.

### Auto Play
Isolated automated move selection/execution using the project's solver logic and trust/ranking boundaries.

### Replay
Recorded sequence/state metadata used to reproduce or inspect a game session without treating replay imports as trusted ranked state.

### Challenge Code
Portable encoded challenge configuration/seed. Its checksum provides accidental-corruption detection, not cryptographic authentication.

### Daily Challenge
Date-derived/defined challenge mode intended to produce deterministic comparable challenge setup under project rules.

### Classic / Quick / Extended / Challenge / Endless / Target / Time Challenge / Move Limit / Daily / Zen
The ten documented game modes. See `GAME_MODES.md` for exact rules rather than inferring behavior from the names alone.

## Testing and evidence terminology

### Unit test
Test focused on a small function/class/domain behavior in isolation.

### Widget test
Flutter test exercising UI widgets/interactions in Flutter's test environment.

### Regression test
Test added to prevent a previously identified failure/contract from silently returning.

### Coverage
Measurement of which source lines/branches/functions executed while tests ran. High coverage is useful but does not alone prove test quality.

### Smoke test
Small fast test showing a major path can execute at all; it does not replace deeper verification.

### Fixture
Controlled test input/data representing a scenario.

### Fail closed
Design where missing/invalid evidence causes a gate to reject rather than accidentally pass. The stable release gate intentionally follows this principle.

### Manual evidence
Human-observed result from a real environment/device/process that cannot be honestly substituted by hosted automation.

### Historical evidence
Verification result tied to an older commit/version. It remains useful history but must not be presented as current-source evidence.

## Security/privacy terminology

### Secret
Sensitive value that must not be committed publicly, such as signing keys, tokens, passwords, or private API credentials.

### Trust boundary
Point where data moves between components/environments with different trust assumptions, e.g. imported backup data entering local game logic.

### Input validation
Checking externally supplied/imported data for structure, limits, allowed values, and consistency before use.

### Authentication
Proof of identity/origin. A simple checksum is **not authentication**.

### Integrity
Confidence data has not unexpectedly changed. Checksums help detect changes; digital signatures can provide stronger integrity plus signer identity properties.

### Privacy
Rules/practices governing collection, storage, sharing, and handling of user data. The project's core behavior is offline-first/local.

## Documentation terminology

### Canonical
Authoritative/current reference document for a topic.

### Historical
Preserved record describing an earlier source/version phase rather than current behavior.

### Source-facing documentation
Docs that must stay synchronized with current implementation/configuration.

### Release-facing documentation
Docs describing current version, artifact, qualification, and distribution state; stale version claims are treated as defects.

### No-skip audit
Repository review process that enumerates tracked files/directories and classifies each rather than inspecting only visible application files.

## Related references

- [`COMMAND_REFERENCE.md`](COMMAND_REFERENCE.md) — command syntax and flags.
- [`setup/PREREQUISITES.md`](setup/PREREQUISITES.md) — tool inventory.
- [`setup/UPGRADING_AND_SUPPORT.md`](setup/UPGRADING_AND_SUPPORT.md) — lifecycle/support policy.
- [`ARCHITECTURE.md`](ARCHITECTURE.md) — source architecture.
- [`GAME_ENGINE.md`](GAME_ENGINE.md) — exact gameplay semantics.
- [`GAME_MODES.md`](GAME_MODES.md) — exact mode rules.
- [`BUILDING_EXECUTABLES.md`](BUILDING_EXECUTABLES.md) — artifact meanings and build procedures.