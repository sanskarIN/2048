# Phase 25 Verification — Version 1.5 Maintenance Hardening

Date: **2026-08-16**

This record captures the objective hosted verification evidence for Phase 25 of 2048 Nova. It covers the maintained SDK/dependency floor, supply-chain automation, current analyzer/test baseline, Web release validation, and the post-maintenance hosted native build matrix.

## Maintained Version 1.5 baseline

- Package version: `1.5.0+15`
- Runtime/marketing version: `1.5.0`
- Dart SDK floor: `>=3.9.0 <4.0.0`
- Flutter SDK floor: `>=3.35.0`
- Hosted verification Flutter: `3.47.0` stable
- Hosted verification Dart: `3.13.0`
- Direct maintenance updates: `cupertino_icons 1.0.9`, `shared_preferences ^2.5.5`, `flutter_lints ^6.0.0`
- Current source used for final Phase 25 requalification: `a719321725ab818edb9f443a8cebdc86ad4fae47`

## Permanent CI evidence

Permanent CI run **31943081231**, job **95154949822**, completed successfully on the exact Phase 25 requalification source.

Verified results:

- dependency resolution and committed metadata synchronization: PASS
- canonical Dart 3.9+ formatting: PASS
- static analysis under `flutter_lints 6`: PASS — no issues found
- complete Flutter test suite: PASS — **215/215**
- Version 1.5 candidate release gate: PASS
- strict stable release gate: PASS as a fail-closed boundary; stable promotion correctly remains unavailable while real-world evidence is incomplete
- deterministic solver smoke benchmark: PASS
- Web WASM dry run: PASS
- missing Cupertino icon-font warning guard: PASS
- Web release build: PASS

The candidate gate remains intentionally distinct from stable qualification: `candidateGatePassed=true`, `readyForStable=false`, and `0/13` real-world qualification items complete.

## Hosted native requalification

Platform Builds run **31943081259**, source `a719321725ab818edb9f443a8cebdc86ad4fae47`, completed successfully across every configured hosted native target:

| Target | Job | Result |
| --- | ---: | --- |
| Android release APK | 95154950015 | SUCCESS |
| Linux x64 release | 95154950051 | SUCCESS |
| Windows x64 release | 95154950020 | SUCCESS |
| macOS release + unsigned iOS release | 95154950021 | SUCCESS |

Each job passed its dependency/generated-file synchronization check before compiling. Every configured package, checksum, and artifact-upload step completed successfully.

## Accepted Phase 25 artifact archives

| Artifact | ID | Size | GitHub artifact digest |
| --- | ---: | ---: | --- |
| `nova-2048-android-release` | 9262595224 | 25,409,424 bytes | `sha256:3659e74e5701ffc88d97fdf6f794f99e798c72b7e220388ed874581d875ba599` |
| `nova-2048-linux-x64-release` | 9262555485 | 10,396,428 bytes | `sha256:8d44c26c652302d42b9514ceda46d07d4453a2ad19ee0a125251ae8ac86ff2d7` |
| `nova-2048-windows-x64-release` | 9262569444 | 12,655,196 bytes | `sha256:d791a3d130282fc00ace3a4138a888812cdd28418b1010de26509948bae6e009` |
| `nova-2048-macos-release` | 9262587395 | 18,739,179 bytes | `sha256:92535dfac0f4dcee76ee3955660ff1e70f40861b0b36ee581ad36bfa73444211` |
| `nova-2048-ios-unsigned-release` | 9262587677 | 8,709,412 bytes | `sha256:47a467df783846b2ce67aa1e0e0320d9482ad6aba42bcc1f6e7e4da04bcad04a` |

The artifacts are retained for 14 days and expire on **2026-08-30**. Each package also contains the payload-level SHA-256 sidecar produced by the permanent Platform Builds workflow.

## Phase 25 maintenance changes verified by this evidence

Phase 25 verified that:

- the declared Dart/Flutter floors match the maintained dependency set rather than advertising an SDK that cannot resolve it;
- `cupertino_icons 1.0.9`, `shared_preferences ^2.5.5`, and `flutter_lints ^6.0.0` resolve and build across the configured hosted platforms;
- the repository has been migrated to the canonical formatter behavior associated with its maintained Dart language floor;
- three new lint findings exposed by `flutter_lints 6` were fixed instead of suppressed;
- Dependabot covers Pub, Android Gradle, and GitHub Actions ecosystems;
- pull-request dependency review exists for dependency-sensitive changes;
- CODEOWNERS covers default, release, dependency, automation, and platform-sensitive paths;
- supply-chain maintenance policy is documented in `SUPPLY_CHAIN.md`;
- one-off Phase 25 migration tooling was removed after successful validation.

## Manual stable-release boundary

Hosted builds do **not** replace physical-device, assistive-technology, real external-handler, long-session, native-branding, signing/provisioning, or store-distribution evidence. `docs/release_qualification.json` remains the source of truth and is intentionally still **0/13** complete.

No manual qualification evidence is inferred from CI, package resolution, hosted native compilation, unsigned iOS output, or artifact creation.
