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

## Phase 23 accepted hosted artifact set

Accepted Platform Builds run: **31934181987**, source `5b22795d5aba661bd587e7bcbf2ae6442c8b4b3a`.

| Artifact | ID | Size | GitHub artifact digest |
| --- | ---: | ---: | --- |
| `nova-2048-android-release` | 9260209072 | 25,409,651 bytes | `sha256:d88a691dd33bcb3e12544f5fb9b35f623cd5890fe96e74dcefe8af4ada75df5d` |
| `nova-2048-linux-x64-release` | 9260177318 | 10,396,367 bytes | `sha256:8556a5d31017faa4ff7f8c128e097aafc5664cf36e219075ea24499bc58dfcef` |
| `nova-2048-windows-x64-release` | 9260197932 | 12,655,196 bytes | `sha256:9ac4fcc2ce969139e9412466f7d568c361a84b666d0812184b1c671a0966e463` |
| `nova-2048-macos-release` | 9260232848 | 18,739,502 bytes | `sha256:20f52591cb0c3cbd5da330b129a98c03831388d2f8dceadf90d760cf7c7193dc` |
| `nova-2048-ios-unsigned-release` | 9260233269 | 8,709,732 bytes | `sha256:44a0adb2482ef422637eb241659a54fc0b7ed59c343ee7d8e104920783e03721` |

Every build, package, checksum, and upload step completed successfully. These GitHub artifact digests cover the stored Actions artifact archives; each artifact also contains the payload-level SHA-256 sidecar created by the workflow.

The artifacts expire on **2026-08-30** under the configured 14-day retention policy. Expiration does not invalidate the source/build evidence recorded here, but future manual qualification should use a current artifact from the exact commit being qualified when practical.


## Phase 24 accepted Version 1.5 hosted artifact set

Accepted Platform Builds run: **31940994252**, source `4d4fe634624b069834786a2aaad356e356281c44`.

| Artifact | ID | Size | GitHub artifact digest |
| --- | ---: | ---: | --- |
| `nova-2048-android-release` | 9262064041 | 25,409,571 bytes | `sha256:777c912745e7c3fdbdbe6f682699e0edbee9d32e0144dd3d7e72c87f25a5bd00` |
| `nova-2048-linux-x64-release` | 9262027429 | 10,396,713 bytes | `sha256:187975b54ec73f23b49fc8e50f6cd7c5f2e044f551ce153603c13cd75273422a` |
| `nova-2048-windows-x64-release` | 9262041028 | 12,655,269 bytes | `sha256:5d53a9c534b3327b5881087b2f5a9c2d744b841de70e20f9e05115f1f8f18ac1` |
| `nova-2048-macos-release` | 9262077872 | 18,739,219 bytes | `sha256:15cb2d98188fcd0718c382244be0f527a41b5799fc59d5cef57173b2be10097f` |
| `nova-2048-ios-unsigned-release` | 9262078294 | 8,710,168 bytes | `sha256:b09afe7ae21b7563d5407e80de17458e2e5d66e557b591db6aea47bca5b6ac1c` |

Every Version 1.5 build, package, checksum, and upload step completed successfully. The artifacts expire on **2026-08-30**. As with the Phase 23 set, these are qualification inputs and hosted-build evidence only; they do not change the **0/13** real-world qualification status.


## Phase 25 accepted Version 1.5 maintenance artifact set

Accepted Platform Builds run: **31943081259**, source `a719321725ab818edb9f443a8cebdc86ad4fae47`.

| Artifact | ID | Size | GitHub artifact digest |
| --- | ---: | ---: | --- |
| `nova-2048-android-release` | 9262595224 | 25,409,424 bytes | `sha256:3659e74e5701ffc88d97fdf6f794f99e798c72b7e220388ed874581d875ba599` |
| `nova-2048-linux-x64-release` | 9262555485 | 10,396,428 bytes | `sha256:8d44c26c652302d42b9514ceda46d07d4453a2ad19ee0a125251ae8ac86ff2d7` |
| `nova-2048-windows-x64-release` | 9262569444 | 12,655,196 bytes | `sha256:d791a3d130282fc00ace3a4138a888812cdd28418b1010de26509948bae6e009` |
| `nova-2048-macos-release` | 9262587395 | 18,739,179 bytes | `sha256:92535dfac0f4dcee76ee3955660ff1e70f40861b0b36ee581ad36bfa73444211` |
| `nova-2048-ios-unsigned-release` | 9262587677 | 8,709,412 bytes | `sha256:47a467df783846b2ce67aa1e0e0320d9482ad6aba42bcc1f6e7e4da04bcad04a` |

Every Phase 25 hosted native dependency-sync, build, package, checksum, and upload step completed successfully. These artifacts expire on **2026-08-30**. They are hosted qualification inputs only and do not change the **0/13** real-world stable-release qualification status.
