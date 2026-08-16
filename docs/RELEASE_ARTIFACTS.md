# Native Release Qualification Artifacts

2048 Nova's permanent **Platform Builds** workflow produces short-lived native release artifacts so maintainers can test a known hosted-build output on representative targets without rebuilding an untracked local copy.

These artifacts are **qualification inputs, not automatic qualification evidence**. A successful hosted build proves that the configured target compiled and that the workflow packaged the expected output. It does not prove physical-device behavior, assistive-technology quality, signing/provisioning, store acceptance, long-session behavior, or external-handler behavior. Those boundaries remain governed by [`RELEASE_QUALIFICATION.md`](RELEASE_QUALIFICATION.md) and `release_qualification.json`.

## Artifact set

A successful native matrix publishes five named artifacts:

| Artifact | Payload | Distribution status |
| --- | --- | --- |
| `nova-2048-android-release` | release APK + SHA-256 sidecar | unsigned/development qualification input; not a store bundle |
| `nova-2048-linux-x64-release` | `tar.gz` of the Flutter Linux bundle + SHA-256 sidecar | x64 hosted-runner qualification input |
| `nova-2048-windows-x64-release` | ZIP of the Windows release directory + SHA-256 sidecar | x64 hosted-runner qualification input |
| `nova-2048-macos-release` | ZIP containing the macOS `.app` bundle + SHA-256 sidecar | hosted-build qualification input; distribution signing/notarization remains separate |
| `nova-2048-ios-unsigned-release` | ZIP containing the unsigned iOS `.app` bundle + SHA-256 sidecar | compile/package evidence only until signing/provisioning is supplied externally |

The workflow uses `if-no-files-found: error`, so an expected output missing from the build directory fails the job instead of creating an empty artifact that looks successful.

## Retention

Qualification artifacts are retained by GitHub Actions for **14 days**. This intentionally keeps CI storage bounded and encourages manual qualification evidence to reference the exact source commit/workflow run rather than relying on a permanent mutable binary bucket.

A maintainer performing manual qualification should record at least:

- source commit SHA;
- Platform Builds workflow run ID;
- artifact name;
- artifact or payload SHA-256 value;
- device/OS or target environment used;
- checks actually performed;
- result and timestamp;
- issue number when a defect is found.

Do not mark a manual qualification item `passed` merely because its corresponding artifact exists.

## Checksum layers

Each platform package contains a repository-workflow-generated SHA-256 sidecar for its primary payload. GitHub Actions also records a digest for the uploaded artifact archive itself.

These two hashes serve different layers:

1. **Payload sidecar** — verifies the APK/TAR/ZIP produced by the packaging step.
2. **GitHub artifact digest** — verifies the archive stored and returned by the GitHub Actions artifact service.

They are integrity aids, not signatures or proof of authorship.

## Verify a downloaded payload

### Linux / macOS

Run the appropriate command next to the downloaded payload and sidecar:

```bash
sha256sum -c <file>.sha256
```

On macOS, where `shasum` is commonly available:

```bash
shasum -a 256 -c <file>.sha256
```

### Windows PowerShell

Compute a SHA-256 hash:

```powershell
Get-FileHash <file> -Algorithm SHA256
```

Compare the resulting hexadecimal hash with the value stored in the `.sha256` sidecar.

## Platform packaging details

### Android

The workflow builds:

```text
build/app/outputs/flutter-apk/app-release.apk
```

It uploads the APK directly together with `app-release.apk.sha256`.

### Linux

The Flutter release bundle under `build/linux/x64/release/bundle` is archived into:

```text
nova-2048-linux-x64.tar.gz
```

Archiving preserves the executable/package tree as a single qualification payload.

### Windows

The contents of `build/windows/x64/runner/Release` are archived into:

```text
nova-2048-windows-x64.zip
```

### macOS

The generated release `.app` bundle is discovered under Flutter's release products directory and packaged with `ditto` into:

```text
nova-2048-macos-release.zip
```

The workflow does not claim distribution signing or notarization.

### iOS

The workflow builds iOS with:

```bash
flutter build ios --release --no-codesign
```

The resulting `.app` bundle is packaged with `ditto` into:

```text
nova-2048-ios-unsigned-release.zip
```

An unsigned iOS build cannot replace real provisioning/device-install/store qualification. It exists to prove the source compiles into the configured iOS release target before signing credentials are introduced outside the repository.

## Relationship to stable release promotion

Native artifact publication does not change the stable gate. The real `docs/release_qualification.json` remains the source of truth for the 13 real-world checks. Stable promotion still requires:

```bash
dart run tool/release_readiness.dart --stable
```

That command must pass on the exact commit intended for release, after real evidence has been recorded and stable release metadata is correct.
