# Cross-Platform Release Build Checklist

Use this checklist when producing candidate artifacts from one exact 2048 Nova commit. It supplements the broader manual qualification manifest; completing this file does not by itself qualify a stable release.

## 1. Source identity

- [ ] Record the exact Git commit SHA being built.
- [ ] Confirm the intended branch/tag.
- [ ] Confirm `pubspec.yaml` version/build number is intentional.
- [ ] Confirm the worktree is clean before building official artifacts.
- [ ] Confirm no private signing material or unrelated local files are staged/packaged.

Useful commands:

```bash
git status --short
git rev-parse HEAD
flutter --version
flutter doctor -v
```

## 2. Dependency and quality gate

- [ ] Run `flutter pub get`.
- [ ] Confirm `pubspec.lock` does not drift unexpectedly.
- [ ] Run formatter check.
- [ ] Run analyzer.
- [ ] Run tests.
- [ ] Run candidate release-readiness check.

```bash
flutter pub get
git diff --exit-code -- pubspec.lock
dart format --output=none --set-exit-if-changed lib test tool
flutter analyze
flutter test
dart run tool/release_readiness.dart --json
```

## 3. Web

- [ ] Build the standard release Web bundle.
- [ ] Confirm `build/web/` exists and contains the complete generated site.
- [ ] Serve it over HTTP/HTTPS for validation rather than `file://`.
- [ ] If using Wasm instead, add Wasm-specific server header/browser qualification.

```bash
flutter build web --release
```

Optional Wasm candidate:

```bash
flutter build web --wasm
```

## 4. Android qualification APK

- [ ] Use the maintained JDK/toolchain baseline.
- [ ] Build release APK.
- [ ] Confirm current signing state is understood (tracked qualification release currently uses debug signing configuration).
- [ ] Create SHA-256 sidecar.
- [ ] Install/test the exact APK on physical Android hardware.

```bash
flutter build apk --release
sha256sum build/app/outputs/flutter-apk/app-release.apk \
  > build/app/outputs/flutter-apk/app-release.apk.sha256
```

## 5. Android store AAB, when required

- [ ] Configure intended production upload/signing securely outside committed secrets.
- [ ] Build AAB from the exact candidate commit.
- [ ] Generate checksum.
- [ ] Validate the exact store-bound artifact and version.

```bash
flutter build appbundle --release
```

Expected location:

```text
build/app/outputs/bundle/release/app-release.aab
```

## 6. Linux

- [ ] Install/confirm GTK/native prerequisites.
- [ ] Build release.
- [ ] Preserve complete `bundle/`.
- [ ] Create CI-compatible tarball.
- [ ] Generate/verify SHA-256.
- [ ] Extract and test on representative target systems.

```bash
flutter config --enable-linux-desktop
flutter build linux --release
tar -C build/linux/x64/release -czf nova-2048-linux-x64.tar.gz bundle
sha256sum nova-2048-linux-x64.tar.gz > nova-2048-linux-x64.tar.gz.sha256
```

## 7. Windows

- [ ] Confirm Visual Studio C++ toolchain.
- [ ] Build release.
- [ ] Preserve complete `Release/` directory.
- [ ] Confirm `nova_2048.exe` remains with required DLL/data files.
- [ ] Create CI-compatible ZIP.
- [ ] Generate/verify SHA-256.
- [ ] Test extracted package on representative Windows systems.

```powershell
flutter config --enable-windows-desktop
flutter build windows --release
Compress-Archive -Path build/windows/x64/runner/Release/* -DestinationPath nova-2048-windows-x64.zip -Force
$hash = (Get-FileHash nova-2048-windows-x64.zip -Algorithm SHA256).Hash.ToLower()
"$hash  nova-2048-windows-x64.zip" | Out-File -Encoding ascii nova-2048-windows-x64.zip.sha256
```

## 8. macOS

- [ ] Confirm Xcode/macOS toolchain.
- [ ] Build release `.app`.
- [ ] Preserve the full `2048 Nova.app` bundle.
- [ ] Package with `ditto`.
- [ ] Generate/verify SHA-256.
- [ ] Test the exact app/archive on representative macOS hardware.
- [ ] Complete signing/notarization for intended public channel before claiming distribution readiness.

```bash
flutter config --enable-macos-desktop
flutter build macos --release
```

## 9. iOS unsigned compilation qualification

- [ ] Confirm Xcode/iOS toolchain.
- [ ] Build unsigned release app for hosted-CI parity.
- [ ] Package the complete `.app` with `ditto`.
- [ ] Generate/verify SHA-256.
- [ ] Do not label this archive as an installable/store-ready IPA.

```bash
flutter build ios --release --no-codesign
```

## 10. iOS signed IPA, when required

- [ ] Configure Apple Developer team/certificate/provisioning securely.
- [ ] Build/export IPA.
- [ ] Verify signing/export method and bundle ID.
- [ ] Test exact signed build on physical iOS hardware.
- [ ] Confirm TestFlight/App Store metadata and build number as applicable.

```bash
flutter build ipa --release
```

## 11. Artifact inspection

For every packaged artifact:

- [ ] Confirm filename clearly states platform/architecture/signing state.
- [ ] Confirm archive contains only intended runtime files.
- [ ] Confirm no secrets/private keys/configuration files are included.
- [ ] Confirm checksum corresponds to the final transferred archive/package.
- [ ] Re-verify checksum after download/transfer where practical.

## 12. Real-platform functional qualification

Applicable targets must still cover:

- [ ] startup/lifecycle/save-resume;
- [ ] touch/orientation/keyboard/focus/responsive behavior;
- [ ] long sessions, Daily, Time Challenge, Move Limit, Undo, win/continue;
- [ ] Challenge Code QR/copy/paste/manual entry/determinism;
- [ ] Move Replay and Full Replay Archive controls;
- [ ] Game Backup clipboard/file save/open/cancel/error/restore;
- [ ] Auto Play strategy switching/pause/performance;
- [ ] browser/email/clipboard/file-provider handlers;
- [ ] native icons/splash presentation;
- [ ] English/Hindi layout and language switching;
- [ ] representative assistive technology and large text.

## 13. Stable release gate

Only after genuine required manual evidence is recorded and stable metadata is finalized:

```bash
dart run tool/release_readiness.dart --stable --json
```

- [ ] Strict stable gate passes on the exact commit intended for release.
- [ ] No release-blocking defect remains.
- [ ] Changelog/release notes/privacy/store metadata are final.
- [ ] Production signing/provisioning is complete for distribution targets.
- [ ] Final artifacts correspond to the exact qualified release source.

The authoritative manual evidence state remains `docs/release_qualification.json`; do not mark checks passed without real evidence.