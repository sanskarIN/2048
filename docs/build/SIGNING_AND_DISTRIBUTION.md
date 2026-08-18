# Signing and Distribution Boundaries

This document separates **building** 2048 Nova from **signing, notarizing, packaging, and publishing** it. Compilation success is not the same as a production distribution identity.

## General rule

Never commit private release credentials to this public repository.

Keep outside Git:

- Android keystores, private keys, aliases/passwords;
- Apple certificate private keys and signing passwords;
- private provisioning/export credentials;
- App Store Connect API private keys/tokens;
- Windows code-signing private keys/certificates;
- notarization credentials;
- store API secrets;
- unrelated secret `.env` or credential files.

Use platform secure storage and protected CI secrets when signing automation is intentionally introduced.

## Android

### Current repository state

`android/app/build.gradle.kts` supports two explicit Android release-signing paths:

1. **Distribution signing:** if ignored `android/key.properties` exists, Gradle loads the configured alias/passwords and keystore path and uses a real `release` signing configuration.
2. **Qualification fallback:** if `android/key.properties` is absent, the release build deliberately uses the debug signing configuration so public hosted CI can verify release-mode compilation without a production keystore.

The safe committed starting point is:

```text
android/key.properties.example
```

Copy it to the ignored path:

```text
android/key.properties
```

and replace all placeholders. `storeFile` is resolved relative to `android/`, so the template value:

```properties
storeFile=app/upload-keystore.jks
```

points to a local `android/app/upload-keystore.jks` file.

`.gitignore` excludes `android/key.properties`, `*.jks`, and `*.keystore`.

Therefore the repository's hosted `app-release.apk` and `app-release.aab` are:

- optimized release-mode application code;
- suitable as qualification build inputs;
- intentionally built without private distribution credentials;
- **not the final production Play signing identity**.

### Production distribution

Before Google Play or another production channel:

1. establish a production upload/signing key strategy;
2. keep private key material outside Git;
3. copy/fill `android/key.properties.example` into ignored `android/key.properties`;
4. verify the keystore path/alias/passwords;
5. rebuild the APK/AAB from the exact candidate source;
6. verify the resulting signing identity;
7. test the exact newly signed artifact;
8. record distribution metadata, checksum, and real-device evidence.

If `android/key.properties` exists but is invalid, fix the signing configuration rather than committing secrets or silently treating a qualification/debug-key package as production-signed.

Do not assume a debug-key qualification APK can upgrade seamlessly to a production-key package already installed with another signature.

## iOS

### Current repository state

Hosted CI builds:

```bash
flutter build ios --release --no-codesign
```

This produces an unsigned release-mode `.app` for compilation qualification.

### Production/TestFlight distribution

A signed IPA requires:

- valid Apple Developer team;
- correct bundle identifier registration;
- signing certificate/private key;
- provisioning/export configuration;
- intended distribution method.

Build when configured:

```bash
flutter build ipa --release
```

Then test the exact signed/exported build on physical hardware and in the intended TestFlight/App Store flow as applicable.

## macOS

### Build output

```bash
flutter build macos --release
```

produces `2048 Nova.app` in the current configuration.

### Direct distribution

Public distribution outside the Mac App Store typically introduces signing/notarization requirements. Compilation alone does not satisfy those requirements.

### Mac App Store

The Mac App Store can require different signing, sandbox, entitlement, and packaging configuration from direct Developer ID distribution.

Because 2048 Nova uses user-selected file operations for Game Backup, verify file-picker/document access under the exact final sandbox/entitlement configuration.

## Windows

### Build output

```powershell
flutter build windows --release
```

produces `nova_2048.exe` plus required runtime files in the generated release directory.

### Code signing

Windows distribution may use Authenticode or store-specific signing. The current hosted qualification archive is checksummed but should not be described as production publisher-signed unless an actual trusted signing flow has been applied and verified.

If an installer/package is introduced, sign/verify the intended level (executables, installer/package, or both) according to that distribution design.

## Linux

Linux does not have one universal application-signing/distribution model. The current repository supports the raw Flutter release bundle and a CI tarball qualification artifact.

Package ecosystems such as `.deb`, `.rpm`, Snap, Flatpak, or AppImage are not current maintained project release outputs. If introduced later, document their package/repository/signing model and test it independently.

## Web

Web delivery does not use native executable code signing in the same way as mobile/desktop packages.

Production trust instead depends heavily on:

- HTTPS/TLS hosting;
- secure deployment credentials;
- correct host/domain control;
- deployment integrity;
- browser security headers when required (especially if a Wasm deployment path is selected);
- keeping source maps/private diagnostics private when desired.

A local Web archive checksum does not replace HTTPS or hosting-account security.

## Checksums versus signatures

### SHA-256 checksum

Useful for:

- confirming an artifact was transferred without byte changes;
- comparing a downloaded file to the published hash;
- identifying exactly which qualification package was tested.

Not sufficient for:

- proving publisher identity;
- establishing platform trust;
- replacing Android/Apple/Windows signatures;
- detecting malicious origin if both artifact and checksum came from the same compromised source.

### Platform signature

A platform signature can establish package/publisher identity and integrity within that platform's trust model, but it still does not replace functional/security/accessibility qualification.

## Never hide release state in filenames

Artifact names should make important boundaries clear, especially:

- `unsigned` for unsigned iOS qualification packages;
- architecture such as `x64` where applicable;
- qualification versus production-signed distinction in release records.

Do not label an artifact `store-ready`, `production-signed`, or `notarized` unless that exact artifact actually satisfies and has passed that process.

## Secure CI guidance

If signing is automated later:

- restrict secret availability to trusted branches/environments;
- avoid exposing secrets to untrusted pull requests;
- use least-privilege permissions;
- prevent log echoing of secret values;
- rotate/revoke credentials after exposure;
- pin/review workflow dependencies;
- separate public compilation qualification from privileged production-release jobs where practical.

The current repository intentionally keeps its permanent public qualification workflows free of private distribution credentials.

## Final distribution checklist

Before publishing any production artifact:

1. Exact source commit is recorded.
2. Automated quality/native builds are green.
3. Correct production signing/notarization/export path is applied.
4. Final artifact is checksummed after packaging/signing where appropriate.
5. Exact final artifact is tested on representative targets.
6. Accessibility/localization/handler qualification is complete.
7. Store/listing/privacy/version metadata is final.
8. Required real evidence is recorded in `docs/release_qualification.json`.
9. Strict stable readiness passes on the release commit.
10. Only the genuinely qualified artifact is published.
