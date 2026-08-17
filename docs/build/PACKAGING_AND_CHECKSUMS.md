# Packaging and SHA-256 Verification

This guide documents the packaging patterns used by 2048 Nova's hosted qualification builds and provides matching local commands. Packaging preserves a complete build output for transfer/testing; SHA-256 provides integrity comparison.

A checksum is **not** code signing, authentication, encryption, malware scanning, or proof of publisher identity.

## Android release APK

Build:

```bash
flutter build apk --release
```

Artifact:

```text
build/app/outputs/flutter-apk/app-release.apk
```

Linux checksum:

```bash
sha256sum build/app/outputs/flutter-apk/app-release.apk \
  > build/app/outputs/flutter-apk/app-release.apk.sha256
```

Verify:

```bash
sha256sum -c build/app/outputs/flutter-apk/app-release.apk.sha256
```

## Android App Bundle

Build:

```bash
flutter build appbundle --release
```

Artifact:

```text
build/app/outputs/bundle/release/app-release.aab
```

Linux checksum:

```bash
sha256sum build/app/outputs/bundle/release/app-release.aab \
  > build/app/outputs/bundle/release/app-release.aab.sha256
```

The permanent hosted qualification workflow currently packages the APK, not AAB; generate and qualify an AAB separately before using it for store distribution.

## Linux release archive

Build:

```bash
flutter build linux --release
```

Package exactly like hosted CI:

```bash
tar -C build/linux/x64/release -czf nova-2048-linux-x64.tar.gz bundle
sha256sum nova-2048-linux-x64.tar.gz > nova-2048-linux-x64.tar.gz.sha256
```

Verify:

```bash
sha256sum -c nova-2048-linux-x64.tar.gz.sha256
```

The tarball contains the complete `bundle/`, not only the executable.

## Windows release archive

Build in PowerShell:

```powershell
flutter build windows --release
```

Package exactly like hosted CI:

```powershell
Compress-Archive -Path build/windows/x64/runner/Release/* `
  -DestinationPath nova-2048-windows-x64.zip -Force
```

Generate checksum:

```powershell
$hash = (Get-FileHash nova-2048-windows-x64.zip -Algorithm SHA256).Hash.ToLower()
"$hash  nova-2048-windows-x64.zip" | Out-File -Encoding ascii nova-2048-windows-x64.zip.sha256
```

Verify manually:

```powershell
(Get-FileHash nova-2048-windows-x64.zip -Algorithm SHA256).Hash.ToLower()
Get-Content nova-2048-windows-x64.zip.sha256
```

The values must match exactly.

## macOS application archive

Build:

```bash
flutter build macos --release
```

Find and preserve the `.app` bundle:

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

Use `ditto` to preserve the application bundle structure/resource metadata.

## Unsigned iOS qualification archive

Build:

```bash
flutter build ios --release --no-codesign
```

Package like hosted CI:

```bash
ios_app="$(find build/ios/iphoneos -maxdepth 1 -type d -name '*.app' -print -quit)"
test -n "$ios_app"
ditto -c -k --sequesterRsrc --keepParent "$ios_app" nova-2048-ios-unsigned-release.zip
shasum -a 256 nova-2048-ios-unsigned-release.zip > nova-2048-ios-unsigned-release.zip.sha256
```

Verify:

```bash
shasum -a 256 -c nova-2048-ios-unsigned-release.zip.sha256
```

This archive remains unsigned. It is not equivalent to a signed IPA.

## Signed iOS IPA

With valid Apple signing/provisioning:

```bash
flutter build ipa --release
```

Inspect the generated output under:

```text
build/ios/ipa/
```

Generate SHA-256 for the exact exported IPA using:

```bash
shasum -a 256 path/to/application.ipa
```

The checksum does not replace Apple's code signature or provisioning validation.

## Web release archive

Build:

```bash
flutter build web --release
```

Linux/macOS tar example:

```bash
tar -C build -czf nova-2048-web-release.tar.gz web
```

Linux checksum:

```bash
sha256sum nova-2048-web-release.tar.gz > nova-2048-web-release.tar.gz.sha256
```

macOS checksum:

```bash
shasum -a 256 nova-2048-web-release.tar.gz > nova-2048-web-release.tar.gz.sha256
```

PowerShell ZIP example:

```powershell
Compress-Archive -Path build\web\* -DestinationPath nova-2048-web-release.zip -Force
$hash = (Get-FileHash nova-2048-web-release.zip -Algorithm SHA256).Hash.ToLower()
"$hash  nova-2048-web-release.zip" | Out-File -Encoding ascii nova-2048-web-release.zip.sha256
```

A Web host normally serves the unpacked contents rather than the archive.

## Naming convention

Repository qualification artifacts use descriptive names containing:

- project identity (`nova-2048`);
- platform (`android`, `windows`, `linux`, `macos`, `ios`);
- architecture where important (`x64`);
- release/signing state where important (`release`, `unsigned`).

Keep artifact names unambiguous. Do not call an unsigned artifact `signed`, `store`, or `production`.

## Sidecar format

Linux `sha256sum` sidecars typically contain:

```text
<64-hex-digest>  filename
```

macOS `shasum -a 256` output is compatible with the same concept. PowerShell scripts in CI write lowercase hexadecimal plus the archive filename.

When verifying manually, compare the digest for the exact byte-for-byte file. Recompressing an identical folder normally changes archive bytes and therefore changes the checksum.

## Why checksum after packaging?

Hash the final archive/package that users or testers receive, because packaging itself determines the bytes being transferred.

For desktop targets:

1. build complete runtime bundle;
2. package it;
3. hash the package;
4. distribute package + sidecar;
5. verify the downloaded package;
6. extract and test.

## Reproducibility limits

Even with pinned project dependencies, archives built on different machines or toolchain versions can differ byte-for-byte due to timestamps, native compilers, signing state, SDK changes, compression metadata, or generated build details.

A checksum verifies one published artifact; it does not claim every independent rebuild will have the same checksum.

## Store packages and signatures

Store/signing systems may modify, re-sign, optimize, or transform packages. Preserve separate checksums/evidence for:

- locally built qualification artifact;
- signed/exported artifact;
- store-delivered artifact when retrievable and meaningful.

Do not use a checksum from one stage to claim another stage is identical unless the bytes were actually compared.

## Security rules

Never include secret files merely because a packaging command uses a wildcard. Review archive contents before publication.

Never package:

- signing keystores;
- certificate private keys;
- provisioning secrets;
- `.env` files containing credentials;
- store API keys/tokens;
- unrelated developer files.

The standard Flutter build output paths documented here should contain runtime artifacts, but release maintainers must still inspect final archives.

## Verification record

The permanent hosted native workflow retains short-lived qualification artifacts with SHA-256 sidecars. See:

- [`../RELEASE_ARTIFACTS.md`](../RELEASE_ARTIFACTS.md)
- [`../VERIFICATION.md`](../VERIFICATION.md)
- [`../../what_changed.md`](../../what_changed.md)

Hosted artifacts are inputs to manual qualification, not substitutes for real-device/accessibility/signing/store evidence.