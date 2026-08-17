# Linux Build Guide

2048 Nova supports a native Flutter Linux desktop build. The generated release is a `bundle/` directory containing the main native executable together with libraries and application data required at runtime.

## Host requirement

Build Linux releases on **Linux** with Flutter's GTK/native desktop prerequisites installed.

## Repository CI prerequisites

The hosted Ubuntu workflow installs:

```bash
sudo apt-get update
sudo apt-get install -y ninja-build libgtk-3-dev liblzma-dev
```

Other distributions should install equivalent packages using their package manager.

## Verify toolchain

```bash
flutter --version
flutter doctor -v
flutter config --enable-linux-desktop
flutter devices
flutter pub get
```

## Development run

```bash
flutter run -d linux
```

## Release build

```bash
flutter build linux --release
```

Current x64 output used by CI:

```text
build/linux/x64/release/bundle/
```

This directory contains the application executable plus supporting `lib/`, `data/`, plugin/runtime files, and other generated content required by the Flutter Linux runner.

## Important: do not distribute only the executable

The Linux executable is not intended to be detached from the generated release bundle without a separately designed packaging process.

Distribute:

- the complete `bundle/` directory;
- the repository-compatible tarball containing `bundle/`; or
- a properly built Linux package that includes every required generated file and dependency expectation.

## CI-compatible tarball

The hosted workflow packages the release with:

```bash
tar -C build/linux/x64/release -czf nova-2048-linux-x64.tar.gz bundle
```

Create SHA-256:

```bash
sha256sum nova-2048-linux-x64.tar.gz > nova-2048-linux-x64.tar.gz.sha256
```

Verify:

```bash
sha256sum -c nova-2048-linux-x64.tar.gz.sha256
```

## Extract and run for qualification

Example:

```bash
tar -xzf nova-2048-linux-x64.tar.gz
cd bundle
ls -la
```

Run the generated application executable from the extracted bundle using the actual generated filename.

If execution permission is missing due to an unusual transfer/archive process, inspect permissions before modifying them. The CI tarball should preserve normal executable permissions.

## GApplication identifier

The repository uses a valid Linux application identifier around:

```text
com.sanskarin.nova2048
```

A previous invalid underscore-based identifier was fixed and the corrected native build passed. If changing Linux identity metadata, re-run hosted and real-target validation rather than assuming the new identifier is accepted.

## Distribution package boundary

The Flutter Linux build does not automatically create every ecosystem package format such as `.deb`, `.rpm`, AppImage, Flatpak, or Snap.

Those formats are **not documented as currently supported release outputs** until the repository intentionally adds, tests, and maintains them.

If one is added later, the packaging definition must:

- include the full Flutter runtime/data payload;
- declare native dependencies correctly;
- preserve application identity/icons;
- define install/uninstall/upgrade behavior;
- be tested on representative distributions;
- be added to CI/release documentation.

## Runtime libraries

A bundle built on one Linux environment may depend on system libraries expected on the destination environment. A successful Ubuntu CI build does not guarantee compatibility with every Linux distribution/version.

Test representative target distributions before claiming broad Linux release compatibility.

## Clean rebuild

```bash
flutter clean
flutter pub get
flutter config --enable-linux-desktop
flutter build linux --release
```

## Common failures

### GTK development files missing

On Debian/Ubuntu-like systems:

```bash
sudo apt-get update
sudo apt-get install -y ninja-build libgtk-3-dev liblzma-dev
```

Then run:

```bash
flutter doctor -v
```

### CMake/Ninja/compiler failure

Inspect `flutter doctor -v` and the full CMake/Ninja output. Install the missing compiler/build dependency instead of editing application code to mask an environment issue.

### App starts on build host but not another distribution

Check:

- CPU architecture;
- system GTK/glib/native library availability;
- complete bundle transfer;
- executable permissions;
- target distribution/version;
- sandbox/security policy if repackaged.

### File picker/clipboard differences

Game Backup and Challenge Code workflows use platform handlers. Test real file chooser, cancel, clipboard, and external browser/email actions on each distribution you intend to support.

## Accessibility qualification

Depending on desktop environment and assistive technology, test:

- keyboard focus/navigation;
- large text/scaling;
- high contrast/reduced motion;
- English/Hindi behavior;
- available screen-reader integration;
- dialogs, replay controls, statistics, and long text inputs.

## Release checklist

1. Native Linux prerequisites are installed.
2. Repository formatter/analyzer/tests pass.
3. `flutter build linux --release` succeeds.
4. Complete `bundle/` is preserved.
5. CI-compatible tarball is created.
6. SHA-256 is generated and verified.
7. Extracted tarball runs on representative Linux target systems.
8. Clipboard/file/external-handler behavior is tested.
9. Accessibility/localization behavior is checked.
10. Required release evidence is recorded before stable publication.