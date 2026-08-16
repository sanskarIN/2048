# Supply-Chain Maintenance

2048 Nova keeps dependency and automation maintenance fail-closed where practical while preserving a small runtime dependency surface.

## Maintained toolchain floor

Version 1.5 declares:

- Dart: `>=3.9.0 <4.0.0`
- Flutter: `>=3.35.0`

These floors match the maintained direct dependency set instead of advertising SDK versions that cannot resolve it. Permanent CI still tests the current stable Flutter channel.

## Direct dependency policy

The maintained direct package set is intentionally narrow:

- `cupertino_icons 1.0.9` — explicit Cupertino icon-font asset;
- `file_picker 11.0.2` — explicit user-selected Game Backup file transport;
- `qr_flutter 4.1.0` — local Challenge Code QR rendering only;
- `shared_preferences ^2.5.5` — local project-owned state/preferences;
- `url_launcher ^6.3.2` — validated external browser/email handoff;
- `flutter_lints ^6.0.0` — development-time analyzer baseline.

Flutter SDK packages such as `flutter_localizations` remain SDK dependencies rather than third-party services.

## Dependabot

`.github/dependabot.yml` checks three ecosystems weekly:

1. Pub packages at repository root;
2. Android Gradle metadata under `/android`;
3. GitHub Actions workflow dependencies.

The configuration intentionally does not require a repository label that may not exist. Update pull requests must still pass normal CI and relevant native-build verification before merge.

## Pull-request dependency review

`.github/workflows/dependency-review.yml` runs for pull requests that change Pub, Android, or GitHub Actions dependency surfaces. It uses `actions/checkout@v7` with `actions/dependency-review-action@v5` and fails when a dependency change introduces a known **high-or-higher severity** vulnerability. Phase 26 verified this exact pair on a real pull-request event (run `31943963173`, job `95157100528`).

This is an additional gate, not a replacement for maintainer review. License, privacy, platform support, binary-size, API compatibility, and reachable project impact must still be considered.

## Lockfile and generated metadata

`pubspec.lock` is committed because 2048 Nova is an application. CI runs `flutter pub get` and fails when the committed lockfile or Flutter-managed analysis metadata drifts. The dedicated dependency-lock workflow can resolve intentional manifest changes, but permanent CI remains the independent verification gate.

## Code ownership

`.github/CODEOWNERS` routes default repository ownership and sensitive release/dependency/platform paths to `@sanskarIN`. Branch-protection enforcement is a repository setting and is not implied merely by the presence of the CODEOWNERS file.

## Acceptance checks for dependency changes

Before accepting a dependency update:

1. confirm the package is needed and maintained;
2. confirm its SDK/platform floors match `pubspec.yaml`;
3. review release notes and breaking changes;
4. review licenses and privacy/network behavior;
5. regenerate and inspect the lockfile;
6. run formatter and static analysis;
7. run the complete Flutter test suite;
8. run candidate/stable release-gate checks;
9. run the deterministic solver smoke benchmark;
10. build Web release without missing-font warnings;
11. run relevant Android/Linux/Windows/macOS/iOS hosted builds for runtime/plugin changes;
12. keep real-device/signing qualification separate from hosted build evidence.

## Stable-release boundary

Supply-chain automation cannot satisfy the 13 real-world release qualification checks. Physical-device behavior, assistive technology, external handlers, long sessions, native branding, and production signing/provisioning remain evidence-backed manual release boundaries in `release_qualification.json`.
