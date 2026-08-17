# macOS Build Guide

2048 Nova supports a native Flutter macOS release. The generated application is a macOS `.app` bundle. Finder displays it like one application, but structurally it is a directory bundle that must remain intact.

## Host requirement

Build macOS releases on **macOS** with Xcode and Flutter's macOS desktop prerequisites.

## Prerequisites

```bash
flutter --version
xcodebuild -version
flutter doctor -v
flutter config --enable-macos-desktop
flutter devices
flutter pub get
```

## Development run

```bash
flutter run -d macos
```

## Release build

```bash
flutter build macos --release
```

Expected release location:

```text
build/macos/Build/Products/Release/
```

The directory should contain the generated `2048 Nova.app` or the current configured application name.

## Preserve the `.app` bundle

Do not copy files out of the `.app` and expect the application to remain valid. A macOS application bundle contains executable, resources, frameworks, metadata, and potentially signing information in a defined directory structure.

## CI-compatible ZIP

The hosted workflow locates the generated `.app` and packages it with `ditto`:

```bash
macos_app="$(find build/macos/Build/Products/Release -maxdepth 1 -type d -name '*.app' -print -quit)"
test -n "$macos_app"
ditto -c -k --sequesterRsrc --keepParent "$macos_app" nova-2048-macos-release.zip
shasum -a 256 nova-2048-macos-release.zip > nova-2048-macos-release.zip.sha256
```

Verify:

```bash
shasum -a 256 -c nova-2048-macos-release.zip.sha256
```

Using `ditto` helps preserve macOS bundle/resource metadata better than treating the `.app` as arbitrary loose files.

## Signing boundary

A successful Flutter `.app` build is not automatically ready for public macOS distribution.

Depending on distribution method, release preparation may require:

- Apple Developer ID or Mac App Store signing;
- correct entitlements;
- hardened runtime requirements;
- provisioning where applicable;
- notarization;
- stapling/verification;
- store metadata/package preparation.

Never commit private Apple signing keys, certificate passwords, API private keys, or notarization credentials.

## Notarization boundary

Notarization is an Apple distribution/security process separate from compilation. The repository's hosted native build verifies that the macOS application compiles and packages; it does not claim notarization.

If notarization is added later, document the exact supported workflow without exposing credentials and add qualification evidence for the notarized artifact.

## Mac App Store boundary

A Mac App Store release can have different signing, entitlements, sandbox, and packaging requirements from direct Developer ID distribution. Do not assume one signed `.app` automatically satisfies both channels.

The project already has platform-sensitive file-picker/backup behavior, so sandbox/document-provider behavior must be tested in the actual intended distribution configuration.

## Clean rebuild

```bash
flutter clean
flutter pub get
flutter config --enable-macos-desktop
flutter build macos --release
```

## Common failures

### Xcode/toolchain missing

```bash
flutter doctor -v
xcodebuild -version
```

Resolve Xcode license/command-line tool/component issues reported by Flutter.

### Plugin/native dependency failure

Run `flutter pub get`, inspect generated plugin registration changes, and compare against hosted CI. Avoid deleting committed runner configuration as a first response.

### App opens locally but is blocked elsewhere

Possible causes include quarantine, missing/notarization/signing expectations, target OS compatibility, architecture, or incomplete packaging. Verify the exact ZIP/app, signature state, and destination system.

### File Backup behaves differently under sandboxing

Test Save/Open/cancel/round-trip using the actual signed/sandboxed build configuration intended for distribution. Hosted compilation cannot substitute for real document-picker/sandbox behavior.

## Native presentation checks

Review on real macOS hardware:

- Dock icon;
- Finder application icon;
- app launch/splash presentation;
- window title and resizing;
- menu/window behavior where applicable;
- keyboard focus;
- high DPI/retina rendering.

## Accessibility qualification

Test:

- VoiceOver;
- keyboard-only focus/navigation;
- system large text/zoom where applicable;
- reduced motion/high contrast;
- English/Hindi switching and pronunciation;
- long text fields/dialogs;
- Replay, Full Replay Archive, Statistics, and Auto Play controls.

## Release checklist

1. Flutter/Xcode toolchain is healthy.
2. Repository quality checks pass.
3. `flutter build macos --release` succeeds.
4. `.app` bundle is preserved intact.
5. CI-compatible ZIP and SHA-256 are generated and verified.
6. Exact build is tested on representative macOS hardware.
7. Clipboard/file/browser/email handlers are tested.
8. Accessibility and localization are qualified.
9. Signing/notarization/store packaging are completed for the intended channel.
10. Real release evidence is recorded before stable promotion.