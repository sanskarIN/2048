# Documentation Audit Checklist

Current source target: **2.0.12+2012**.

Use this checklist whenever a release, feature, platform/toolchain change, or large documentation pass is prepared. It complements the machine-enforced documentation/repository tests; it does not replace them.

## Source identity

- [ ] `pubspec.yaml` package/build version matches the current release contract.
- [ ] In-app marketing version matches the current release contract.
- [ ] Windows fallback version metadata matches.
- [ ] Qualification manifest candidate matches.
- [ ] Release-readiness target matches.
- [ ] Current docs do not accidentally declare an obsolete release line as current.
- [ ] Historical docs are visibly marked historical where needed.

## Canonical navigation

- [ ] Root `README.md` explains the public project accurately.
- [ ] `docs/README.md` remains the canonical documentation map.
- [ ] Setup index points to all supported host/target setup guides.
- [ ] Build index points to all supported artifact guides.
- [ ] New major documents are discoverable from an appropriate index/reference.
- [ ] Historical phase records are not presented as current source truth.

## New contributor path

- [ ] Prerequisites are documented.
- [ ] Windows setup is documented.
- [ ] macOS/iOS setup is documented.
- [ ] Linux setup is documented.
- [ ] Android setup is documented.
- [ ] Tool support/EOL handling is documented.
- [ ] Command syntax/flags are explained.
- [ ] Glossary/terminology exists.
- [ ] New contributor workflow exists.
- [ ] Error/diagnosis reference exists.

## Repository/file coverage

- [ ] `git ls-files` is the literal tracked-file inventory source.
- [ ] Root files have documented responsibilities.
- [ ] `lib/` layers are documented.
- [ ] `test/` responsibilities are documented.
- [ ] `tool/` responsibilities are documented.
- [ ] `.github/` workflows/templates are documented.
- [ ] Android/iOS/Web/Windows/macOS/Linux trees are covered.
- [ ] Generated platform files are identified as generated where appropriate.
- [ ] New/renamed/deleted files satisfy `FILE_COVERAGE_CONTRACT.md`.

## Gameplay behavior

- [ ] Merge/spawn rules match `GameEngine` tests.
- [ ] Ten built-in modes remain accurately documented.
- [ ] Win/continue/loss behavior is accurate.
- [ ] Timed/move-limit behavior is accurate.
- [ ] Undo bound and semantics are accurate.
- [ ] Hint is documented as read-only.
- [ ] Auto Play is documented as isolated from trusted player state.

## Custom Game Builder

- [ ] Board-size/target/style/limit/seed bounds match the domain model.
- [ ] Maximum preset count matches `CustomPresetStore`.
- [ ] Create/play/save/edit/rename/duplicate/cancel/delete behavior is documented.
- [ ] Duplicate is documented as unsaved until explicit Save.
- [ ] Edit name collisions are documented as rejected rather than destructive overwrite.
- [ ] Custom-session identity across save/resume/restart is documented.
- [ ] Built-in per-mode record isolation is documented.
- [ ] Clear-all behavior includes custom preset/session keys.
- [ ] Custom Challenge Code sharing remains absent unless origin/trust semantics are explicitly versioned and tested.

## Persistence and migrations

- [ ] Every current local key is documented or covered by the storage contract.
- [ ] New schema/version fields are documented.
- [ ] Corruption recovery is documented.
- [ ] Bounds on stored histories/lists are documented.
- [ ] Reset/clear behavior is documented.
- [ ] Legacy migration behavior is not misrepresented.

## Portable data and trust

- [ ] Game Backup scope is current-game-only.
- [ ] Imported backup remains unranked after restart.
- [ ] Backup size/schema/state validation is documented.
- [ ] File picker/save/open transport boundaries are documented.
- [ ] Challenge Code checksum is not described as authentication.
- [ ] Daily Challenge is isolated from arbitrary Challenge Code injection.
- [ ] Full Replay Archive import is spectator-only.
- [ ] Replay size/event bounds are documented.
- [ ] Portable timestamps use the documented UTC policy.

## Statistics and achievements

- [ ] Overall statistics fields match implemented data.
- [ ] Achievement behavior matches source/tests.
- [ ] Per-mode record trust policy is documented.
- [ ] Imported backup cannot improve trusted records.
- [ ] Custom sessions cannot overwrite built-in per-mode records.
- [ ] Statistics reset behavior with active sessions is accurate.

## Localization

- [ ] English and Hindi are the current supported languages.
- [ ] System-language fallback behavior is documented.
- [ ] Machine-readable protocol fields are not described as translated.
- [ ] New critical user-facing flows have matching Hindi coverage.
- [ ] Long Hindi strings are considered in layout docs/tests.

## Accessibility

- [ ] Board semantics are documented.
- [ ] Keyboard controls are documented.
- [ ] High-contrast behavior is documented.
- [ ] Reduced-motion behavior is documented.
- [ ] Text scaling/responsive layout expectations are documented.
- [ ] Automated accessibility tests are not presented as real assistive-technology qualification.
- [ ] TalkBack/VoiceOver/Narrator/browser-screen-reader work remains in the manual evidence boundary until genuinely performed.

## Privacy/security

- [ ] Offline-first behavior is accurate.
- [ ] No analytics/ads/accounts/cloud sync are claimed unless actually introduced.
- [ ] Clipboard/file actions are explicit user actions.
- [ ] External links are clearly user-triggered trust boundaries.
- [ ] Secrets/signing credentials are never included in docs examples as real values.
- [ ] Public docs do not expose private keystores/tokens/credentials.

## Dependencies/toolchain

- [ ] Dependency versions are taken from current source/lockfile rather than memory.
- [ ] Flutter/Dart constraints match `pubspec.yaml`.
- [ ] Hosted Flutter baseline matches workflows.
- [ ] Android AGP/Kotlin/Gradle/JDK accepted baseline matches source.
- [ ] A newer available dependency is not described as required without compatibility/security reason.
- [ ] Upgrade guidance includes rollback and cross-platform verification.

## Build artifacts

- [ ] Android APK instructions work from current source.
- [ ] Android AAB instructions work from current source.
- [ ] Android signing boundary is explicit.
- [ ] iOS unsigned compile versus signed IPA distinction is explicit.
- [ ] Web/PWA build/deployment distinction is explicit.
- [ ] Windows release bundle requirements are documented.
- [ ] macOS app/signing/notarization boundaries are documented.
- [ ] Linux bundle/native dependency requirements are documented.
- [ ] Checksums and CI artifact packaging are documented.

## CI and release evidence

- [ ] Formatter command matches CI.
- [ ] Analyzer command matches CI.
- [ ] Full test command matches CI.
- [ ] Repository audit command matches CI.
- [ ] Source-completion audit command matches CI.
- [ ] Solver smoke command matches CI.
- [ ] Web release build is documented.
- [ ] Native matrix targets are documented.
- [ ] Dependency Review is documented.
- [ ] Same-commit evidence rule is explicit.
- [ ] Historical green CI is not relabeled as current verification after source changes.

## Manual qualification boundary

- [ ] Current 13-check manifest status is stated accurately.
- [ ] Physical Android/iOS checks are not fabricated.
- [ ] Real responsive/input checks are not fabricated.
- [ ] Assistive-technology evidence is not fabricated.
- [ ] Long-session evidence is not fabricated.
- [ ] Real Challenge Code/Replay/Backup handlers are not fabricated.
- [ ] Native branding evidence is not fabricated.
- [ ] Signing/provisioning/store evidence is not fabricated.
- [ ] Stable readiness remains fail-closed until genuine evidence exists.

## Open-source/community files

- [ ] MIT `LICENSE` is present.
- [ ] `CONTRIBUTING.md` matches current quality gates.
- [ ] `CODE_OF_CONDUCT.md` is present.
- [ ] `SECURITY.md` describes the current supported release/security path.
- [ ] `SUPPORT.md` is current.
- [ ] Issue templates are current.
- [ ] PR template reflects trust/persistence/accessibility/privacy/platform review.
- [ ] CODEOWNERS covers sensitive paths.
- [ ] Dependabot/Dependency Review configuration remains valid.

## Continuity/release notes

- [ ] `CHANGELOG.md` records notable current changes.
- [ ] `what_changed.md` records the active maintenance work.
- [ ] Older detailed continuity is archived rather than erased.
- [ ] Release notes do not claim tests/builds that were not observed.
- [ ] Current manual evidence count is not inferred from source work.

## Machine checks

Run:

```bash
flutter pub get
dart format --output=none --set-exit-if-changed lib test tool
flutter analyze
flutter test --coverage
dart run tool/release_readiness.dart --json
dart run tool/release_qualification_status.dart --json --pending-only
dart run tool/repository_audit.dart --json
dart run tool/source_completion_audit.dart --json
dart run tool/solver_benchmark.dart 8
flutter build web --release
```

Then run relevant native builds or use the maintained hosted matrix.

## Final documentation verdict

Documentation is ready only when it is:

- consistent with current source;
- internally linked without broken local paths;
- clear about historical versus current evidence;
- complete enough for players, contributors, maintainers, builders, and release owners;
- explicit about trust, privacy, security, accessibility, and manual qualification boundaries;
- protected by regression tests/audits rather than depending only on human memory.