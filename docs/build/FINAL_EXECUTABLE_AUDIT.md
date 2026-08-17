# Final Executable Build and Code Audit

**Project:** 2048 Nova  
**Version:** `1.5.0+15`  
**Audit date:** 2026-08-17  
**Status:** release-candidate source is automated-check clean and all maintained hosted build targets compile successfully; stable release remains intentionally blocked by real-world qualification/signing evidence.

This document is the final executable/build-focused audit for the current Version 1.5 release-candidate line. It records what was checked, what was fixed, which artifacts were actually built, which warnings remain, and what is still required before calling a build a qualified stable release.

## 1. Audited source points

Two hosted source points are relevant because documentation-only commits followed the native workflow update:

### Latest full quality/documentation head

```text
77c6cd5d5c2f56df31a868e023eee57d9e5d1f27
```

GitHub Actions quality run:

```text
Run: 32027060137
Job: 95378641630
```

This head contains:

- the About-screen version fix;
- its regression guard;
- the Android APK+AAB workflow change;
- the completed executable/build documentation set.

### Native executable qualification head

```text
67b145b992672ee7854472edc31287721c9f0d0b
```

GitHub Actions Platform Builds run:

```text
Run: 32026830893
```

All commits between this native source point and the latest quality/documentation head are documentation-only changes. Therefore the native runner/code/toolchain content qualified by this run is the same executable source/toolchain state represented by the final documentation head.

## 2. Final defect found and fixed

The final audit found one concrete stale product-state defect:

```text
lib/features/about/about_screen.dart
```

The About screen still described the application as:

```text
Release candidate 0.9
```

while the project version is:

```text
1.5.0+15
```

The stale literal was replaced with the canonical runtime version source:

```dart
Version ${ProjectInfo.version} release candidate
```

Fix commit:

```text
0de1a9380272593ae0daa4f78108a3089d2ba0c2
```

Regression-guard commit:

```text
6ab67b216829a1fb10ad89d5a27e07fed715ac98
```

The regression check now rejects the old `Release candidate 0.9` text and verifies that the About screen uses `ProjectInfo.version`.

## 3. Android qualification gap found and fixed

Before this audit, the documentation already described both Android release formats:

- APK;
- Android App Bundle (`.aab`).

However, the permanent native qualification workflow only built/uploaded the APK. That meant AAB creation was documented but not continuously proven by the hosted native matrix.

The Android job was changed from APK-only qualification to:

```bash
flutter build apk --release
flutter build appbundle --release
```

It now also creates:

```text
app-release.apk.sha256
app-release.aab.sha256
```

and uploads all four files in one qualification artifact.

Workflow commit:

```text
67b145b992672ee7854472edc31287721c9f0d0b
```

This gap is now closed by an actual successful hosted APK+AAB run, not only by documentation.

## 4. Final automated quality evidence

Latest quality run `32027060137`, job `95378641630`, completed successfully.

### Formatting

```text
Formatted 107 files (0 changed)
```

Result:

```text
PASS
```

### Static analysis

```text
No issues found!
```

Result:

```text
PASS
```

### Automated tests

```text
239 tests passed
```

Result:

```text
239/239 PASS
```

### Candidate release-readiness gate

```text
version: 1.5.0+15
candidateGatePassed: true
readyForStable: false
manualChecksPassed: 0
manualChecksRequired: 13
```

Result:

```text
PASS for release-candidate metadata
```

### Stable release gate

The strict stable gate correctly failed closed because real-world/manual qualification is incomplete.

Current status:

```text
0/13 manual checks have passed evidence
```

This is expected and correct. The audit did not weaken or bypass the gate.

### Deterministic solver benchmark

Both maintained solver paths completed successfully for the fixed benchmark seeds and move budget.

Result:

```text
PASS
```

### Web release build

```bash
flutter build web --release
```

Result:

```text
Built build/web
```

The Wasm compatibility dry run also succeeded and the guarded missing-icon-font failure condition did not occur.

## 5. Final native executable build evidence

Platform Builds run:

```text
32026830893
```

### Android

Job:

```text
95377963948
```

Release APK:

```text
build/app/outputs/flutter-apk/app-release.apk
54.4 MB
PASS
```

Release AAB:

```text
build/app/outputs/bundle/release/app-release.aab
53.3 MB
PASS
```

Checksum generation:

```text
APK SHA-256 sidecar: PASS
AAB SHA-256 sidecar: PASS
```

Uploaded artifact:

```text
Name: nova-2048-android-release
Artifact ID: 9287546150
Stored size: 78,374,947 bytes
GitHub artifact digest:
sha256:20b5dd1a43c127cc01aceeecdeca3a3a853772b5ca923108ff9896f715f9defc
```

The upload step confirmed that exactly four files were included:

```text
app-release.apk
app-release.apk.sha256
app-release.aab
app-release.aab.sha256
```

### Windows

Job:

```text
95377963919
```

Result:

```text
flutter build windows --release: PASS
ZIP packaging: PASS
SHA-256 creation: PASS
artifact upload: PASS
```

Artifact:

```text
Name: nova-2048-windows-x64-release
Artifact ID: 9287488362
GitHub artifact digest:
sha256:fdb2e8bd867518ae299a5e404d81dd5366911630fe7e6d4350e56b3573be98d6
```

### Linux

Job:

```text
95377964052
```

Result:

```text
flutter build linux --release: PASS
tar.gz packaging: PASS
SHA-256 creation: PASS
artifact upload: PASS
```

Artifact:

```text
Name: nova-2048-linux-x64-release
Artifact ID: 9287444468
GitHub artifact digest:
sha256:a35e7b885e9968449c22730952e39b51e3ba7384096ed0590f2858527eb5b10f
```

### macOS

Apple job:

```text
95377964106
```

Result:

```text
flutter build macos --release: PASS
.app ZIP packaging: PASS
SHA-256 creation: PASS
artifact upload: PASS
```

Artifact:

```text
Name: nova-2048-macos-release
Artifact ID: 9287519165
GitHub artifact digest:
sha256:b253653773c4edbe446685c0df9d9020bcd990f9c85edf3af942d5884b6a2d13
```

### iOS

The same Apple job compiled the maintained unsigned qualification target:

```bash
flutter build ios --release --no-codesign
```

Result:

```text
unsigned iOS release compilation: PASS
.app ZIP packaging: PASS
SHA-256 creation: PASS
artifact upload: PASS
```

Artifact:

```text
Name: nova-2048-ios-unsigned-release
Artifact ID: 9287520184
GitHub artifact digest:
sha256:9cd9bac8619bda77e6b8c79ff4958d385d325dcf817477d9f8a64362f8db3514
```

This is compile/package evidence only. It is not a signed IPA and is not App Store/TestFlight qualification.

## 6. Complete executable/build documentation coverage

The master guide is:

```text
docs/BUILDING_EXECUTABLES.md
```

Detailed build documentation is organized under:

```text
docs/build/
```

Current documented coverage includes:

- Android debug APK;
- Android profile APK;
- Android universal release APK;
- Android ABI-split release APKs;
- Android release AAB;
- Android checksum and signing boundaries;
- iOS unsigned release `.app`;
- iOS signed/exported IPA path when signing is configured;
- Web/PWA standard release bundle;
- optional Web Wasm build path;
- Windows native release bundle and `.exe` boundary;
- macOS `.app` build and packaging boundary;
- Linux native release bundle;
- native CI packaging and SHA-256 verification;
- local-versus-hosted CI parity;
- host prerequisites;
- output paths and application/bundle identities;
- signing, provisioning, notarization, store, and secret-management boundaries;
- troubleshooting;
- release build checklist;
- explicitly unsupported/not-maintained installer/package formats.

Key files:

```text
docs/BUILDING_EXECUTABLES.md
docs/build/README.md
docs/build/ANDROID.md
docs/build/IOS.md
docs/build/WEB.md
docs/build/WINDOWS.md
docs/build/MACOS.md
docs/build/LINUX.md
docs/build/HOST_PREREQUISITES.md
docs/build/QUICK_COMMANDS.md
docs/build/OUTPUT_PATHS.md
docs/build/SUPPORTED_ARTIFACTS.md
docs/build/CI_PARITY.md
docs/build/PACKAGING_AND_CHECKSUMS.md
docs/build/SIGNING_AND_DISTRIBUTION.md
docs/build/BUILD_TROUBLESHOOTING.md
docs/build/RELEASE_BUILD_CHECKLIST.md
docs/RELEASE_ARTIFACTS.md
```

## 7. Android signing truth

The tracked Android `release` build type currently uses the debug signing configuration so public hosted CI can compile/package release-mode binaries without storing a private production keystore.

Therefore the successful hosted APK and AAB prove:

- optimized Android release compilation;
- APK packaging;
- AAB packaging;
- checksum creation;
- artifact upload.

They do **not** prove the final production Play signing identity.

A production Android release still requires secure signing/upload-key configuration outside Git followed by qualification of the exact production-signed output.

## 8. Future-compatibility warning discovered during successful Android builds

The successful Android APK and AAB logs contain a Flutter warning for:

```text
file_picker 11.0.2
```

The plugin currently applies the Kotlin Gradle Plugin in a way Flutter warns will stop being accepted by a future Flutter release.

This is **not a present build failure**. Both Android release formats built successfully on Flutter 3.47.0 with Temurin JDK 17.

Upstream `file_picker 12.0.0` is now a stable release and includes Android Built-in-Kotlin/KGP cleanup. However, it also raises its package requirements to:

```text
Dart >=3.10.0
Flutter >=3.38.0
```

while this project currently advertises:

```text
Dart >=3.9.0
Flutter >=3.35.0
```

For that reason, this audit deliberately does **not** silently replace `file_picker 11.0.2` with 12.0.0. Doing so would change the project's declared minimum supported SDKs and requires an intentional compatibility-policy decision plus the full quality/native matrix.

The updated state has been recorded on GitHub issue #10.

## 9. Other known release boundaries

### AGP 9.3.x / JDK 17

GitHub issue #10 remains open for the previously isolated Android Gradle Plugin 9.3.x release-lint/JDK 17 incompatibility. The accepted baseline remains the tested combination documented in the Android toolchain guide.

### Main branch protection

GitHub issue #12 remains open for repository branch-protection policy. This is a repository governance/release-safety boundary, not an application runtime defect.

### Real-world stable qualification

The release manifest still reports:

```text
0/13 manual checks passed
```

The following categories still require genuine target evidence before stable promotion:

- physical Android behavior;
- physical iOS behavior;
- responsive/input behavior;
- assistive technology;
- long-session behavior;
- Auto Play real-target behavior;
- Challenge Code real-target behavior;
- Move Replay real-target behavior;
- Full Replay Archive real-target behavior;
- Game Backup real-target behavior;
- external handlers;
- native branding;
- distribution metadata.

No automated build result was used to falsify these manual checks as passed.

## 10. Final error/bug conclusion

At the end of this audit:

```text
Formatting: PASS — 107 files, 0 changed
Analyzer: PASS — no issues found
Tests: PASS — 239/239
Candidate release gate: PASS
Stable gate: correctly CLOSED — 0/13 manual evidence
Solver benchmark: PASS
Web release: PASS
Android APK: PASS
Android AAB: PASS
Windows release: PASS
Linux release: PASS
macOS release: PASS
unsigned iOS release: PASS
```

The stale About-screen 0.9 version defect was fixed and regression-guarded.

No current analyzer failure, automated-test failure, release-candidate metadata failure, Web build failure, or maintained native build failure remains in the audited source state.

The remaining items are explicit release/toolchain/governance boundaries rather than hidden green-status claims:

- production signing/provisioning;
- 13 real-world qualification checks;
- AGP 9.3.x/JDK 17 follow-up;
- `file_picker` 12.0.0/minimum-SDK policy decision;
- branch protection.

## 11. Recommended stable-release sequence

1. Decide whether to retain the current minimum Flutter/Dart support or raise it for `file_picker 12.0.0`.
2. If dependency/toolchain versions change, re-run full quality and native matrices.
3. Configure production Android/Apple/Windows signing where the intended distribution channel requires it.
4. Build the exact signed release artifacts from the exact intended release commit.
5. Re-run checks against those exact artifacts.
6. Complete all 13 real-world qualification categories with truthful evidence.
7. Confirm distribution metadata/version/store requirements.
8. Enable the intended branch-protection policy.
9. Run:

```bash
dart run tool/release_readiness.dart --stable --json
```

10. Publish/tag a stable release only when the strict stable gate genuinely passes.
