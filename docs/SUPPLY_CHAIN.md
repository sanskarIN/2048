# Supply-Chain Maintenance

2048 Nova keeps dependency and automation maintenance fail-closed where practical while preserving a small runtime dependency surface.

## Maintained toolchain floor and qualified SDK

Version 1.5 declares:

- Dart: `>=3.9.0 <4.0.0`
- Flutter: `>=3.35.0`

Those package floors describe compatibility. The maintained GitHub workflows separately freeze the currently qualified hosted SDK at **Flutter 3.47.0** instead of resolving whichever release later occupies the stable channel.

Every workflow that executes the pinned `subosito/flutter-action` supplies:

```yaml
channel: stable
flutter-version: 3.47.0
cache: false
```

`cache: false` is deliberate. The qualified composite action contains a moving `actions/cache@v5` reference when its cache path is enabled. Disabling that path prevents an otherwise SHA-pinned workflow from executing mutable transitive Action code. Repository-integrity coverage requires all five Flutter workflows to retain the exact SDK and disabled action cache.

## Direct dependency policy

The maintained direct package set is intentionally narrow:

- `cupertino_icons 1.0.9` — explicit Cupertino icon-font asset;
- `file_picker 11.0.2` — explicit user-selected Game Backup file transport;
- `qr_flutter 4.1.0` — local Challenge Code QR rendering only;
- `shared_preferences ^2.5.5` — local project-owned state/preferences;
- `url_launcher ^6.3.2` — validated external browser/email handoff;
- `flutter_lints ^6.0.0` — development-time analyzer baseline.

Flutter SDK packages such as `flutter_localizations` remain SDK dependencies rather than third-party services.

## Immutable GitHub Actions policy

Permanent workflows use reviewed **40-character commit revisions** rather than moving tags for executable Action code. Human-readable version comments remain beside the SHA so updates are understandable and Dependabot can continue proposing reviewed changes.

Phase 28 qualified these revisions:

- `actions/checkout@3d3c42e5aac5ba805825da76410c181273ba90b1` — v7;
- `subosito/flutter-action@1a449444c387b1966244ae4d4f8c696479add0b2` — v2;
- `actions/dependency-review-action@a1d282b36b6f3519aa1f3fc636f609c47dddb294` — v5;
- `actions/upload-artifact@043fb46d1a93c77aae656e7c1c64a875d1fc6a0a` — v7.

`test/repository_integrity_test.dart` rejects mutable remote `uses:` references and checks the currently qualified critical revisions. A version label such as `# v7` is documentation only; the SHA is the code identity actually executed.

A future Action upgrade should update the SHA and version comment together, pass Dependency Review where applicable, pass permanent CI, and run the relevant native/build automation before acceptance.

## Verified Gradle distribution

The accepted Android baseline remains AGP 9.1.0, Kotlin Android 2.4.10, and Gradle 9.7.0. The wrapper configuration now verifies the downloaded Gradle 9.7.0 complete distribution with:

```text
distributionSha256Sum=a9ecb5ac5c2ca40691e6527724d11d0b43b8c0a52825b77c09899f2a72d2d2bf
```

This checksum is the official Gradle 9.7.0 `-all` distribution SHA-256. Repository-integrity coverage requires both the 9.7.0 URL and this exact checksum, so changing only the remote ZIP URL cannot silently bypass the expected distribution identity.

## Reproducible branding-generator environment

The branding bootstrap previously installed floating `cairosvg` and `pillow` packages. Phase 28 replaced that with `tool/branding-requirements.txt`, which exactly pins the complete Python package set observed in the last proven Ubuntu branding environment.

The workflow installs only from that requirements file. Repository-integrity coverage rejects non-exact package entries and verifies the workflow continues using the pinned requirements file. The pinned environment itself was rerun successfully before Phase 28 acceptance.

These Python packages are build-time branding tools only; they are not shipped as 2048 Nova runtime dependencies.

## Dependabot

`.github/dependabot.yml` checks three ecosystems weekly:

1. Pub packages at repository root;
2. Android Gradle metadata under `/android`;
3. GitHub Actions workflow dependencies.

The configuration intentionally does not require a repository label that may not exist. Update pull requests must still pass normal CI and relevant native-build verification before merge.

## Pull-request dependency review

`.github/workflows/dependency-review.yml` runs for pull requests that change Pub, Android, or GitHub Actions dependency surfaces. It uses immutable checkout and Dependency Review revisions and fails when a dependency change introduces a known **high-or-higher severity** vulnerability.

Phase 28 exercised the immutable pair on disposable PR #13. Dependency Review run `31947619961`, job `95166040339`, completed successfully and reported no high-or-higher vulnerable dependency changes. PR #13 was then closed without merge.

This is an additional gate, not a replacement for maintainer review. License, privacy, platform support, binary-size, API compatibility, and reachable project impact must still be considered.

## Lockfile and generated metadata

`pubspec.lock` is committed because 2048 Nova is an application. CI runs `flutter pub get` and fails when the committed lockfile or Flutter-managed analysis metadata drifts. The dedicated dependency-lock workflow can resolve intentional manifest changes, but permanent CI remains the independent verification gate.

## Code ownership and branch protection

`.github/CODEOWNERS` routes default repository ownership and sensitive release/dependency/platform paths to `@sanskarIN`.

CODEOWNERS does **not** enforce merge policy by itself. The Phase 28 repository audit found that `main` currently reports branch protection disabled with no required status checks. The connected integration cannot change repository rulesets, so issue #12 tracks the required GitHub-setting change.

The recommended `main` protection baseline is:

- require pull requests for normal development;
- require permanent CI before merge;
- require Dependency Review when dependency-sensitive paths change;
- prevent force pushes and branch deletion;
- require review-conversation resolution;
- retain CODEOWNERS review for sensitive paths;
- require or explicitly verify the native matrix for dependency/plugin/platform changes.

Do not describe `main` as protected until the repository setting itself confirms that enforcement is active.

## Acceptance checks for dependency and automation changes

Before accepting a dependency or executable workflow update:

1. confirm the package/action is needed and maintained;
2. confirm SDK/platform/runtime floors remain compatible;
3. review release notes and breaking changes;
4. review licenses and privacy/network behavior;
5. use an immutable Action revision for remote workflow code;
6. freeze the qualified Flutter SDK and avoid hidden mutable transitive Action paths;
7. verify external build distributions with available publisher checksums;
8. regenerate and inspect the application lockfile when Pub metadata changes;
9. run formatter and static analysis;
10. run the complete Flutter test suite;
11. run candidate/stable release-gate checks;
12. run the deterministic solver smoke benchmark;
13. build Web release without missing-font warnings;
14. run relevant Android/Linux/Windows/macOS/iOS hosted builds for runtime/plugin/workflow changes;
15. keep real-device/signing qualification separate from hosted build evidence.

## Stable-release boundary

Supply-chain automation cannot satisfy the 13 real-world release qualification checks. Physical-device behavior, assistive technology, external handlers, long sessions, native branding, and production signing/provisioning remain evidence-backed manual release boundaries in `release_qualification.json`.
