# Linux Native Toolchain Handbook

This guide explains the native Linux development packages used by Flutter to build the **2048 Nova** Linux desktop runner: Clang, CMake, Ninja, pkg-config, GTK 3 development libraries, the C++ standard library, package managers, upgrades, and troubleshooting.

## 1. Shared Dart versus native Linux build

Most application source lives in Dart under `lib/`.

A Linux desktop build also contains a native runner and plugin integration. Flutter therefore needs native C/C++ build tools and Linux UI/system development libraries.

Tracked native source lives under:

```text
linux/
```

Generated release output lives under:

```text
build/linux/...
```

## 2. Debian/Ubuntu baseline packages

A common Flutter Linux baseline is:

```bash
sudo apt-get update
sudo apt-get install -y clang cmake ninja-build pkg-config libgtk-3-dev libstdc++-12-dev
```

Package names differ between distributions. Use equivalent packages from the distribution's official repositories.

## 3. `clang`

Clang is a C/C++ compiler frontend/toolchain used to compile the native Linux runner and native plugin code.

Verify:

```bash
clang --version
clang++ --version
```

Flutter normally orchestrates compiler invocation through CMake/Ninja rather than requiring manual compilation commands.

## 4. C versus C++ compiler

`clang` commonly invokes the C compiler driver.

`clang++` invokes the C++ driver and automatically links/configures C++ runtime expectations appropriate to C++ compilation.

The Flutter Linux runner/plugin ecosystem uses C++ in native integration.

## 5. `cmake`

CMake is a cross-platform build-configuration generator.

Verify:

```bash
cmake --version
```

Flutter's Linux runner includes CMake configuration files under `linux/`. CMake generates the native build plan consumed by a build executor such as Ninja.

## 6. `ninja`

Ninja is a fast low-level build executor.

Verify:

```bash
ninja --version
```

On Debian/Ubuntu the package is named:

```text
ninja-build
```

while the executable is:

```text
ninja
```

## 7. `pkg-config`

`pkg-config` helps build systems discover installed native libraries and the compiler/linker flags required to use them.

Verify:

```bash
pkg-config --version
```

For GTK 3:

```bash
pkg-config --modversion gtk+-3.0
```

If this fails, the GTK development package may be missing or not visible to the selected environment.

## 8. GTK 3

GTK is the Linux graphical toolkit used by Flutter's current Linux desktop embedding.

The Debian/Ubuntu development package is:

```text
libgtk-3-dev
```

A **development** package contains headers and metadata needed to compile against GTK. Installing only runtime GTK libraries is not enough for compilation.

## 9. C++ standard library development files

The C++ compiler needs standard-library headers/libraries.

On a supported Debian/Ubuntu baseline the Flutter documentation can require a package such as:

```text
libstdc++-12-dev
```

The exact package/version depends on distribution/toolchain. Do not force a Debian package name on Fedora/Arch/openSUSE.

## 10. Install on Debian/Ubuntu

```bash
sudo apt-get update
sudo apt-get install -y clang cmake ninja-build pkg-config libgtk-3-dev libstdc++-12-dev
```

Then:

```bash
clang --version
cmake --version
ninja --version
pkg-config --version
pkg-config --modversion gtk+-3.0
flutter doctor -v
```

## 11. Fedora

Fedora uses `dnf` and package names differ.

Search for the distribution's official equivalents of:

- Clang;
- CMake;
- Ninja;
- pkg-config/pkgconf;
- GTK 3 development headers;
- GCC/libstdc++ development files.

Use Fedora's official repositories/documentation instead of copying Ubuntu `apt` package names.

## 12. Arch Linux

Arch uses `pacman` and a rolling-release model.

Install equivalent official repository packages and follow Arch's full-system-upgrade policy. Avoid partial upgrades that leave compiler/libraries out of sync.

## 13. openSUSE and other distributions

Use the distribution package manager and equivalent development packages.

The required **capabilities** matter more than the package names:

```text
C/C++ compiler
CMake
Ninja
pkg-config
GTK 3 headers/libraries
C++ standard-library development headers
```

## 14. Enable Linux desktop

```bash
flutter config --enable-linux-desktop
```

Then:

```bash
flutter devices
```

A healthy Linux toolchain should expose a Linux desktop target.

## 15. Run on Linux

```bash
flutter run -d linux
```

This produces a development/debug build and launches the app.

## 16. Build Linux release

```bash
flutter build linux --release
```

Current primary release bundle area:

```text
build/linux/x64/release/bundle/
```

Preserve the complete bundle, not only the `nova_2048` ELF executable.

## 17. What is ELF

ELF means **Executable and Linkable Format**. It is the common native executable/object format used on Linux.

The generated Flutter Linux application also relies on companion libraries/data in its bundle.

## 18. Dynamic libraries

Flutter and plugins can produce/use shared libraries (`.so`).

If copying only the executable causes a runtime loader error, the application was packaged incompletely.

Distribute the complete bundle or a documented package format that includes its dependencies/resources.

## 19. `ldd`

`ldd` can display shared-library dependencies of a Linux executable:

```bash
ldd build/linux/x64/release/bundle/nova_2048
```

Use it for diagnostics, not as proof that the bundle will run on every Linux distribution/version.

## 20. Distribution compatibility

A Linux binary built on one distribution/toolchain may depend on glibc/system libraries not available on older distributions.

The project should not claim universal Linux compatibility without defining/testing supported distribution/runtime baselines.

Hosted build success is qualification for that runner environment, not every Linux machine.

## 21. Update package indexes

Debian/Ubuntu:

```bash
sudo apt-get update
```

This refreshes available package metadata. It does not by itself install all upgrades.

## 22. Inspect available upgrades

Debian/Ubuntu:

```bash
apt list --upgradable
```

Fedora:

```bash
sudo dnf check-upgrade
```

Arch's normal model uses full system synchronization/upgrade rather than selectively holding a partially upgraded system.

## 23. Upgrade native tools carefully

A distro upgrade can change Clang/GCC/CMake/GTK/glibc simultaneously.

After significant native package changes:

```bash
flutter doctor -v
flutter clean
flutter pub get
flutter analyze
flutter test
flutter build linux --release
```

## 24. Unsupported distribution release

If the Linux OS release reaches EOL:

- upgrade to a supported distribution release;
- reinstall/verify native development packages;
- verify Flutter support;
- rerun project builds/tests;
- do not keep an unsupported OS as the permanent release build machine.

See [`UPGRADING_AND_SUPPORT.md`](UPGRADING_AND_SUPPORT.md).

## 25. Unsupported compiler

If the distribution/compiler version is no longer supported by the selected Flutter/native dependency stack, migrate to the vendor/distribution-supported compiler set.

Do not use random binary compilers from unknown download sites to bypass package-manager compatibility.

## 26. CMake version mismatch

If CMake reports a minimum-version/configuration error:

1. check `cmake --version`;
2. inspect `linux/CMakeLists.txt` and plugin CMake requirements;
3. compare Flutter's supported Linux prerequisites;
4. upgrade through the distribution/toolchain supported method;
5. rebuild.

Do not lower a plugin's required CMake version blindly.

## 27. Ninja missing

Typical symptom: CMake/Flutter reports no Ninja build program.

Check:

```bash
ninja --version
```

On Debian/Ubuntu install:

```bash
sudo apt-get install -y ninja-build
```

## 28. GTK missing

Check:

```bash
pkg-config --modversion gtk+-3.0
```

If missing on Debian/Ubuntu:

```bash
sudo apt-get install -y libgtk-3-dev
```

Runtime GTK packages alone may not include headers/pkg-config metadata.

## 29. `pkg-config` cannot find GTK despite install

Inspect:

```bash
pkg-config --variable pc_path pkg-config
pkg-config --cflags gtk+-3.0
pkg-config --libs gtk+-3.0
```

Custom environment variables such as `PKG_CONFIG_PATH` can make a shell discover different libraries than the system default. Avoid permanently pointing it at stale/incompatible custom prefixes without a reason.

## 30. Compiler path

```bash
which clang
which clang++
type -a clang
type -a clang++
```

Multiple compiler installations can cause inconsistent local builds.

## 31. CMake path

```bash
which cmake
type -a cmake
```

A manually installed `/usr/local/bin/cmake` can shadow the distribution package. Know which one Flutter invokes.

## 32. Ninja path

```bash
which ninja
type -a ninja
```

## 33. Native Flutter plugins

Flutter packages may include Linux plugin C/C++ code.

A dependency upgrade can therefore require newer CMake/compiler/GTK APIs even if Dart source remains compatible.

After plugin upgrades, always rebuild Linux native output.

## 34. Linux runner CMake source

Tracked source under `linux/` can include:

- top-level CMake configuration;
- runner C++ source;
- generated plugin integration hooks/templates;
- application identifier/name configuration.

Do not edit generated portions without understanding Flutter's conventions.

## 35. Clean generated native output

```bash
flutter clean
flutter pub get
flutter build linux --release
```

This regenerates project build intermediates. It does not replace missing system development packages.

## 36. Permissions

The generated executable needs executable permission. Flutter/build packaging normally handles this.

If a ZIP/archive process strips file modes, the extracted Linux executable may not run until execute permission is restored.

This is why Linux release packaging should be tested, not only the raw pre-archive build directory.

## 37. Archive packaging

The repository's native workflow packages the complete Linux release bundle and adds a SHA-256 sidecar.

A compressed archive preserves transport convenience but is not the same as a distribution-native installer/package manager package.

## 38. `.deb`, `.rpm`, AppImage, Snap, Flatpak

These are distinct packaging/distribution ecosystems.

The base Flutter Linux build does not automatically make all of them maintained project artifacts.

Adding one requires explicit:

- reproducible build configuration;
- metadata/versioning;
- dependency/runtime policy;
- signing/integrity as applicable;
- install/update/uninstall behavior;
- testing and CI documentation.

## 39. Wayland/X11

Linux desktop environments can use different display stacks.

Do not claim complete X11/Wayland/distribution/desktop-environment coverage unless it has been tested. Flutter/GTK/runtime behavior can differ with host graphics/input configuration.

## 40. Headless CI

Hosted CI may compile the Linux bundle without interactively launching the graphical app.

A successful headless compile does not prove real display/input/accessibility behavior.

## 41. Accessibility on Linux

GTK/desktop accessibility behavior needs actual representative environment testing. Widget tests and native compilation are not substitutes for a real assistive-technology qualification.

## 42. Common error: `clang` not found

```bash
clang --version
```

Install the distribution's Clang package, reopen shell if needed, then rerun Flutter Doctor/build.

## 43. Common error: missing C++ headers

Compiler errors for standard headers can indicate missing C++ development packages/toolchain installation.

Install the distribution-supported C++ standard-library/development packages rather than copying header directories manually.

## 44. Common error: GTK headers not found

Verify:

```bash
pkg-config --cflags gtk+-3.0
```

Install GTK 3 development headers for the distro.

## 45. Common error: linker cannot find library

Inspect the first linker message. Verify the corresponding development/runtime package and `pkg-config` output.

Avoid adding arbitrary `-L` paths to project CMake files until you know why standard dependency discovery failed.

## 46. Common error: app runs on build machine but not another Linux machine

Possible causes:

- missing system runtime libraries;
- glibc/libstdc++ baseline difference;
- architecture mismatch;
- packaging omitted shared libraries/data;
- desktop/graphics stack differences;
- executable permission lost.

Define/test supported Linux baselines before claiming broad distribution compatibility.

## 47. First Linux-native verification

```bash
clang --version
cmake --version
ninja --version
pkg-config --version
pkg-config --modversion gtk+-3.0
flutter --version
flutter doctor -v
flutter pub get
dart format --output=none --set-exit-if-changed lib test tool
flutter analyze
flutter test
dart run tool/repository_audit.dart --json
dart run tool/source_completion_audit.dart --json
flutter build linux --release
```

## 48. Related documentation

- [`LINUX.md`](LINUX.md) — full Linux workstation setup.
- [`FLUTTER_AND_DART.md`](FLUTTER_AND_DART.md) — Flutter/Dart SDK.
- [`UPGRADING_AND_SUPPORT.md`](UPGRADING_AND_SUPPORT.md) — EOL/support migration.
- [`../build/LINUX.md`](../build/LINUX.md) — Linux artifact packaging.
- [`../BUILDING_EXECUTABLES.md`](../BUILDING_EXECUTABLES.md) — all builds.
- [`../COMMAND_REFERENCE.md`](../COMMAND_REFERENCE.md) — command meanings.
