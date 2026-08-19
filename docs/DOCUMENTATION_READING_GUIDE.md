# Documentation Reading Guide — Notation, Commands, Paths, and Technical Language

This guide explains **how to read the 2048 Nova documentation itself**. It is intended for contributors who do not want to copy commands or configuration blindly.

For definitions of project and platform terminology, also use [`GLOSSARY.md`](GLOSSARY.md). For detailed command-by-command behavior, use [`COMMAND_REFERENCE.md`](COMMAND_REFERENCE.md).

## 1. Why this guide exists

Technical documentation compresses a lot of meaning into symbols, code formatting, filenames, placeholders, flags, version expressions, and short words such as **build**, **target**, **artifact**, or **pin**.

A command can be valid while still being wrong for your machine if:

- you are in the wrong directory;
- the command is for another operating system;
- a placeholder was copied literally;
- the required tool is not installed or is not on `PATH`;
- the project expects a different toolchain version;
- a command changes files when you intended only to inspect them.

Understanding the notation makes the documentation safer and more useful.

## 2. Inline code

Text inside backticks, such as `flutter doctor`, `pubspec.yaml`, `main`, or `2.0.12+2012`, is usually a literal technical value.

Depending on context it can mean:

- a command to type;
- a filename or directory;
- a branch name;
- a configuration key;
- a version;
- an identifier from source code;
- an expected literal output/value.

Do not assume every inline-code item is a command. Read the sentence around it.

## 3. Fenced code blocks

A block such as:

```bash
flutter pub get
flutter analyze
```

contains commands or code that should remain visually separate from explanation.

The word after the opening fence describes the language or shell:

- `bash` — shell syntax commonly used on Linux/macOS and in cross-platform examples;
- `powershell` — Windows PowerShell syntax;
- `text` — literal output/example text, not necessarily executable;
- `json` — JSON data;
- `yaml` — YAML configuration;
- `dart` — Dart source code;
- `kotlin` — Kotlin source/configuration syntax.

A code block marked `text` should not automatically be pasted into a terminal.

## 4. Shell prompt characters

Documentation generally omits shell prompt characters so commands can be copied cleanly.

If another source shows:

```text
$ flutter doctor
```

or:

```text
PS C:\Project> flutter doctor
```

then `$` or `PS C:\Project>` is normally the prompt, not part of the command.

In this repository, prefer copying only the command text shown inside the code block.

## 5. Command, subcommand, argument, option, and flag

Consider:

```bash
flutter build apk --release
```

Its parts are:

- `flutter` — executable/command;
- `build` — subcommand telling Flutter which operation family to use;
- `apk` — a more specific build target argument/subcommand;
- `--release` — a long option/flag selecting release build mode.

Another example:

```bash
dart run tool/repository_audit.dart --json
```

- `dart` starts Dart tooling;
- `run` asks Dart to execute a Dart program;
- `tool/repository_audit.dart` is the program path;
- `--json` requests machine-readable JSON output from that repository-owned tool.

See [`COMMAND_REFERENCE.md`](COMMAND_REFERENCE.md) for deeper explanations.

## 6. Short and long flags

A **flag** changes command behavior.

Examples:

```text
-v
--verbose
--release
--coverage
--json
```

A single dash often introduces a short flag such as `-v`. Two dashes often introduce a long flag such as `--verbose`.

Do not assume two similarly named flags are interchangeable. The command's own help output is authoritative for its accepted syntax.

Useful pattern:

```bash
<command> --help
```

Replace `<command>` with the actual executable or command form; do not type the angle brackets literally.

## 7. Placeholders and angle brackets

Documentation may use a placeholder such as:

```text
<device-id>
<path>
<version>
<your-value>
```

Angle brackets mean **replace this with a real value** unless the surrounding text explicitly says otherwise.

Example template:

```bash
flutter run -d <device-id>
```

If `flutter devices` reports a device ID of `chrome`, the real command becomes:

```bash
flutter run -d chrome
```

Do not type `flutter run -d <device-id>` literally.

## 8. Square brackets in prose

When documentation uses a pattern such as `[optional]`, it normally means the item is optional, not that the square brackets must be typed.

However, square brackets can be literal syntax in programming languages, JSON, regular expressions, or shell expressions. Context decides the meaning.

Never remove punctuation from source/configuration just because documentation sometimes uses it as notation.

## 9. Ellipsis (`...`)

An ellipsis usually means **additional omitted values or steps exist**.

Example:

```text
flutter build <target> ...
```

The `...` is explanatory shorthand. It normally should not be typed unless a specific command explicitly documents literal ellipsis syntax.

## 10. Paths

### File

A file is a named unit such as `pubspec.yaml` or `lib/main.dart`.

### Directory / folder

A directory contains files or other directories, such as `lib/`, `docs/`, or `android/`.

A trailing slash is often used in prose to make it obvious that the item is a directory.

### Relative path

A relative path is interpreted from the current working directory.

Example:

```text
docs/README.md
```

From the repository root, this means the README inside the `docs` directory.

### Absolute path

An absolute path starts from the filesystem's root/location and identifies a location independently of the current working directory.

Examples can look like:

```text
C:\Development\flutter
/Users/name/development/flutter
/home/name/development/flutter
```

Do not copy example usernames/drives blindly.

### Repository root

The **repository root** is the top-level `2048` checkout directory containing files such as `pubspec.yaml`, `README.md`, `lib/`, and `docs/`.

Many project commands assume the terminal is currently at this location.

Check the current location with:

```bash
pwd
```

In PowerShell, `Get-Location` is the explicit equivalent; `pwd` is also an alias in normal PowerShell environments.

## 11. `cd`

`cd` means **change directory**.

Example:

```bash
cd android
```

This changes the current working directory into the `android` directory. It does not build the project and does not edit a file.

After running Android-specific wrapper commands, return to the repository root before running root-relative commands.

## 12. Current directory markers

### `.`

A single dot means the **current directory** in many shells/path contexts.

### `..`

Two dots mean the **parent directory**.

Example:

```bash
cd ..
```

moves one directory upward.

### `./`

On macOS/Linux, `./gradlew` means execute the `gradlew` file located in the current directory rather than searching `PATH` for a global executable.

### `.\`

In PowerShell, `.\gradlew.bat` similarly means execute the file from the current directory.

## 13. `PATH`

`PATH` is an operating-system environment variable containing directories searched when you type a command name.

If Flutter is installed but:

```bash
flutter --version
```

reports that `flutter` is unknown/not found, a common cause is that the Flutter SDK's executable directory is not correctly discoverable through `PATH`.

Adding something to `PATH` does not install the tool; it tells the shell where to search for an already installed executable.

## 14. Environment variables

An **environment variable** is a named value supplied by the operating system/shell/process environment.

Examples in development can influence SDK discovery, build behavior, or credentials.

Never commit private tokens/passwords just because a tool can also read them as environment variables.

## 15. Pipes (`|`)

In a shell, a pipe usually sends the standard output of one command into the standard input of another.

Example:

```bash
git ls-files | sort
```

Meaning:

1. `git ls-files` prints tracked paths;
2. `|` forwards that text;
3. `sort` sorts the received lines.

The pipe does not mean logical OR in this shell example, although `|` can have other meanings in programming/configuration languages.

## 16. Redirection (`>`, `>>`)

Shell redirection can write command output to a file.

Typical meanings:

- `>` — create/replace a destination with redirected output;
- `>>` — append redirected output.

Because `>` can overwrite a file, do not add redirection to a command unless the documentation explicitly requires it and you understand the destination.

## 17. Quoting

Quotes keep text together or control how the shell interprets characters.

Examples:

```bash
git ls-files 'docs/**'
git commit -m "docs: improve setup guide"
```

Do not casually remove quotes from paths/arguments containing spaces or shell metacharacters.

PowerShell, Bash, CMD, YAML, JSON, Dart, and other languages have different quoting/escaping rules.

## 18. Exit codes

A command normally returns an integer **exit code** to the operating system.

Conventionally:

- `0` means success;
- non-zero means some form of failure, difference, or exceptional state.

The exact meaning of a non-zero value is command-specific.

A CI system can use exit codes to decide whether a job passed or failed.

## 19. Standard output and standard error

### Standard output (`stdout`)

Normal command results are commonly written to standard output.

### Standard error (`stderr`)

Warnings/errors/diagnostics are commonly written to standard error.

A command can emit warnings and still return success. Read both the output and exit status when diagnosing a build.

## 20. Wildcards and globs

Patterns such as:

```text
docs/**
*.dart
PHASE_*
```

can represent groups of matching paths.

Their exact expansion rules depend on the shell/tool.

For example, this repository uses Git's path matching when running:

```bash
git ls-files 'docs/**'
```

Quoting keeps the shell from changing the pattern before Git receives it.

## 21. Version numbers

A version such as:

```text
2.0.12
```

usually has major/minor/patch components.

This project's Flutter package version is:

```text
2.0.12+2012
```

The `+2012` is build metadata/build-number information used by Flutter package/application versioning.

Do not assume every external tool follows exactly the same versioning policy.

## 22. Version constraints

The project currently declares:

```text
>=3.9.0 <4.0.0
```

for Dart.

Read it as:

- `>=3.9.0` — version must be greater than or equal to 3.9.0;
- `<4.0.0` — version must be lower than 4.0.0.

Both conditions must be true.

### Caret constraints

A dependency may use syntax such as:

```yaml
shared_preferences: ^2.5.5
```

The caret is a package-version constraint operator interpreted by Dart Pub. It allows a compatible range according to Pub's versioning rules; it does not mean “always install every future version.”

`pubspec.lock` records the resolved dependency versions for reproducibility.

## 23. YAML

YAML is used by files such as `pubspec.yaml` and GitHub workflow/configuration files.

Important characteristics:

- indentation carries structure;
- `key: value` represents a mapping entry;
- lists often start with `-`;
- whitespace mistakes can change meaning.

Do not convert tabs/spaces or indentation casually in YAML.

## 24. JSON

JSON is a structured text data format using objects, arrays, strings, numbers, booleans, and `null`.

Example:

```json
{
  "status": "pass",
  "count": 3
}
```

Repository tools support `--json` when machine-readable output is useful. JSON output is designed for parsers/automation as well as humans.

## 25. Source code versus generated files

### Source-owned file

A file intentionally maintained as project source/configuration/documentation.

### Generated file

A file created by Flutter, a platform tool, dependency generator, or build process.

Some generated platform registration files can still be tracked because the platform template/toolchain expects them in source control.

Never assume “generated” means “safe to delete permanently.” Check the repository atlas and Flutter/platform conventions first.

## 26. Tracked, untracked, ignored

### Tracked

Git knows the file as part of repository history.

List tracked files:

```bash
git ls-files
```

### Untracked

The file exists locally but has not been added to Git history/index.

Check:

```bash
git status
```

### Ignored

Git ignore rules intentionally exclude matching local/build/secret/generated paths from normal tracking.

Inspect ignore rules in `.gitignore` and platform-specific `.gitignore` files.

## 27. Source of truth

A **source of truth** is the authoritative current location for a fact.

Examples in this repository:

- `pubspec.yaml` is authoritative for the package/build version and Dart/Flutter constraints;
- Android plugin pins live in `android/settings.gradle.kts`;
- the Gradle distribution lives in `android/gradle/wrapper/gradle-wrapper.properties`;
- current application behavior ultimately comes from source plus tests, not from an older historical prose document.

When docs and current source disagree, investigate and correct the stale documentation rather than silently changing source to make the prose true.

## 28. Baseline, floor, pin, range, and lock

### Baseline

The selected project configuration that maintainers currently expect to validate.

### Floor / minimum

The lowest declared acceptable version, such as Flutter `>=3.35.0`.

### Pin

An intentionally exact version, such as a specific AGP or Gradle Wrapper release.

### Range

Multiple versions are allowed when they satisfy a declared constraint.

### Lockfile

A file recording resolved dependency versions. In this repository, `pubspec.lock` is part of the reproducibility model.

## 29. Build

**Build** can mean either the process of transforming source into runnable/distributable output or the produced output context.

Examples:

```bash
flutter build apk --release
flutter build web --release
flutter build windows --release
```

A successful build proves that the relevant build process completed in that environment. It does not prove every manual/device/store requirement.

## 30. Artifact

A build **artifact** is an output intended for testing, packaging, installation, distribution, or evidence.

Examples include APKs, AABs, web build directories, desktop bundles, and CI-generated archives/checksums.

See [`BUILDING_EXECUTABLES.md`](BUILDING_EXECUTABLES.md) and [`RELEASE_ARTIFACTS.md`](RELEASE_ARTIFACTS.md).

## 31. Target

A **target** is the platform/output being built or run, such as Android, iOS, Web, Windows, macOS, or Linux.

It can also refer to a specific build configuration or device depending on context.

## 32. Host versus target

- **Host** — the computer/operating system performing the build.
- **Target** — the platform the application is being built for.

Examples:

- Windows host → Android/Web/Windows targets;
- macOS host → Android/Web/iOS/macOS targets;
- Linux host → Android/Web/Linux targets.

Some targets require a particular host because their native vendor toolchain is host-specific.

## 33. Debug, profile, and release

### Debug

Development-oriented build with debugging conveniences and less production-oriented optimization.

### Profile

Performance-analysis-oriented build mode where supported.

### Release

Optimized distribution-oriented build mode. Release mode alone does not create production signing credentials or store approval.

## 34. CI

**CI** means **continuous integration**: automated jobs that run checks/builds when repository events occur.

CI provides reproducible automated evidence. It does not simulate every physical-device, accessibility, external-handler, signing/provisioning, PWA lifecycle, or store-review condition.

## 35. Release candidate and stable qualification

A **release candidate** is a build/source state proposed for release validation.

A **stable qualification gate** is the set of evidence required before describing a candidate as fully qualified for the project's defined stable-distribution contract.

2048 Nova deliberately separates source completion from unresolved real-world qualification. Do not rewrite `0/13` pending manual evidence into a pass without genuine observed evidence.

## 36. Fail closed

**Fail closed** means uncertainty or missing required evidence results in a blocked/not-qualified state rather than optimistic success.

This is important for release readiness and evidence integrity.

## 37. Deterministic

A deterministic operation produces the same result when given the same relevant starting state/input.

The project uses determinism for seeded gameplay/replay/solver-related behavior where documented. Deterministic does not mean cryptographically secure.

## 38. Checksum

A checksum is a derived value used to detect accidental changes/corruption or verify file equality.

A checksum is not automatically a digital signature or authentication mechanism.

## 39. Signing

Signing associates an application/artifact with a cryptographic signing identity required by platform distribution models.

Signing secrets/private keys must not be committed to the public repository.

## 40. Deprecated versus unsupported

These are not synonyms:

- **deprecated** — still present but discouraged/planned for replacement;
- **unsupported/EOL** — no longer maintained under the relevant lifecycle.

A deprecated API may still be supported temporarily. An unsupported tool can sometimes still run, but that does not make it an acceptable maintained baseline.

## 41. “Run from repository root”

When documentation says **run from repository root**, first ensure your terminal is in the checkout containing `pubspec.yaml`.

A quick Git check is:

```bash
git rev-parse --show-toplevel
```

It prints the top-level path of the current Git work tree when run inside the repository.

## 42. Read-only versus mutating commands

### Read-only / diagnostic examples

```bash
flutter --version
flutter doctor -v
git status
git diff
flutter pub outdated
```

These primarily inspect/report state.

### Mutating examples

```bash
flutter upgrade
flutter pub upgrade
git add
git commit
git push
```

These can change an SDK, dependency resolution, Git index/history, or remote repository state.

Before running a command from an issue/comment/random webpage, determine whether it is diagnostic or mutating.

## 43. Destructive operations

Commands that delete, overwrite, reset, force-push, rewrite history, remove SDKs, or erase credentials require extra care.

This documentation intentionally prefers reversible diagnostics and compatibility checks before destructive cleanup.

Do not interpret a troubleshooting suggestion to “clean” generated build output as permission to delete arbitrary source files.

## 44. Copying commands safely

Before executing a command, answer:

1. Which executable will run?
2. Which directory am I in?
3. Is this command for my host OS?
4. Are there placeholders to replace?
5. Does it inspect state or change state?
6. Could it expose a secret in logs/history?
7. Does the project expect a pinned/wrapper tool instead of a global tool?
8. What output indicates success?

## 45. Related references

- [`COMMAND_REFERENCE.md`](COMMAND_REFERENCE.md) — detailed command meanings and flags.
- [`GLOSSARY.md`](GLOSSARY.md) — technical vocabulary.
- [`REPOSITORY_FILE_ATLAS.md`](REPOSITORY_FILE_ATLAS.md) — repository paths and responsibilities.
- [`setup/README.md`](setup/README.md) — environment setup entry point.
- [`setup/TOOL_SUPPORT_MATRIX.md`](setup/TOOL_SUPPORT_MATRIX.md) — tool support/version decisions.
- [`BUILDING_EXECUTABLES.md`](BUILDING_EXECUTABLES.md) — artifact/build guide.
- [`TROUBLESHOOTING.md`](TROUBLESHOOTING.md) — failure diagnosis.
