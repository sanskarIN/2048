# Repository Integrity Audit

2048 Nova uses a deterministic repository-level audit in addition to Dart formatting, Flutter analysis/tests, release-readiness validation, qualification reporting, the final source-completion audit, solver smoke tests, and platform builds.

Implementation:

```text
tool/repository_audit.dart
```

## Current Version 2.0.12 contract

```text
Marketing version: 2.0.12
Flutter package/build version: 2.0.12+2012
Source scope: feature-complete
```

A later intentional version change must update package/runtime/platform metadata, qualification state, release tooling, audit fixtures, documentation, and continuity together rather than weakening the checks.

## Run the audit

```bash
dart run tool/repository_audit.dart
```

Machine-readable:

```bash
dart run tool/repository_audit.dart --json
```

Fixture/alternate root:

```bash
dart run tool/repository_audit.dart --root=<path> --json
```

Permanent CI runs the JSON form automatically.

## Required repository assets

The audit fails when permanent project/open-source/release/support/security/build/signing-safety/tooling/Web/PWA/continuity/workflow files are missing or empty.

The final Version 2.0.12 required set includes, among other files:

- `README.md`, `ROADMAP.md`, `CHANGELOG.md`;
- preserved `CHANGELOG_ARCHIVE_PRE_2_0_12.md`;
- security/support/contribution/conduct/license/authorship files;
- `what_changed.md` plus Phase 0–30 and Phase 31 continuity archives;
- `pubspec.yaml`, analyzer configuration, Android signing template, Windows resource metadata;
- complete documentation index/build/PWA/release/qualification documentation;
- `docs/FINAL_2_0_12_SOURCE_AUDIT.md`;
- `docs/MAINTENANCE_POLICY.md`;
- `docs/SOURCE_COMPLETION_AUDIT.md`;
- `tool/release_readiness.dart`;
- `tool/release_qualification_status.dart`;
- `tool/record_release_qualification.dart`;
- `tool/repository_audit.dart`;
- `tool/source_completion_audit.dart`;
- permanent GitHub Actions, CODEOWNERS, Dependabot, funding, and issue configuration;
- Web/PWA shell, manifest, favicon, and regular/maskable icon assets.

Requiring the final audit/maintenance/source-completion assets ensures the completed 2.0.12 scope cannot silently lose its own maintenance and verification contract.

## Version and release-state consistency

The audit checks:

- `pubspec.yaml` is exactly `2.0.12+2012`;
- canonical homepage/repository/issue-tracker metadata stays on `sanskarIN/2048`;
- `ProjectInfo.version` is exactly `2.0.12`;
- Windows fallback numeric version is `2,0,12,2012`;
- Windows fallback string version is `2.0.12`;
- the qualification candidate exactly matches the package/build version;
- the qualification manifest retains exactly 13 manual records;
- active continuity identifies Phase 32 and `2.0.12+2012`;
- active continuity preserves the explicit `stable qualification boundary remains 0/13` statement while those records remain pending.

`tool/release_readiness.dart` performs deeper candidate/stable validation, while `tool/release_qualification_status.dart` validates the canonical manual-check/evidence shape.

## Web/PWA consistency

The audit parses `web/manifest.json` and verifies:

- name/short name;
- relative identity/start URL/scope (`.`);
- standalone display;
- English/left-to-right metadata;
- orientation and related-app policy;
- `games` and `entertainment` categories;
- exact regular/maskable 192×192 and 512×512 PNG icon matrix.

It also checks required `web/index.html` fragments for:

- document language;
- Flutter base-href placeholder;
- theme/color-scheme metadata;
- generic/Apple mobile install metadata;
- manifest/touch-icon links;
- title;
- Flutter bootstrap script.

This complements `test/web_pwa_metadata_test.dart` and does not claim a real browser/PWA installation was manually qualified.

## Temporary-helper cleanup

Known one-shot Phase 30, Phase 31, and Phase 32 finalizer/workflow/trigger/helper paths are forbidden from remaining in the permanent repository. If one is reintroduced, the audit fails.

## Local Markdown links

The audit scans top-level Markdown and Markdown under `docs/`, `.github/`, and `tool/`.

It validates repository-local file/directory destinations and ignores:

- same-document anchors;
- external HTTP/HTTPS links;
- `mailto:`, `tel:`, and `data:` destinations;
- destinations inside fenced code examples.

It stays deterministic/offline and does not crawl external websites. Unclosed Markdown fences are warnings because they can make later link parsing ambiguous.

## Source-completion audit relationship

The broader repository audit and the final source-completion audit intentionally remain separate:

| Tool | Responsibility |
| --- | --- |
| `tool/repository_audit.dart` | Required assets, exact release/version surfaces, PWA semantics, continuity, temporary cleanup, and local Markdown links. |
| `tool/source_completion_audit.dart` | Feature-complete roadmap/final-audit/maintenance contract, current-doc version drift, and unresolved product TODO/FIXME markers. |

Permanent CI runs both. See [`SOURCE_COMPLETION_AUDIT.md`](SOURCE_COMPLETION_AUDIT.md).

## Regression fixtures

`test/repository_audit_cli_test.dart` creates isolated synthetic repositories and covers:

- clean Version `2.0.12+2012` / marketing `2.0.12` success;
- exact package/build drift;
- runtime marketing-version drift;
- Windows fallback drift;
- canonical repository metadata drift;
- qualification-candidate drift;
- Web/PWA identity and HTML-language drift;
- broken local Markdown links;
- temporary Phase 30/31/32 helper rejection;
- unclosed Markdown-fence warnings.

The fixture set also creates the final completion audit, maintenance policy, source-completion guide/tool, and archived changelog because those are now permanent repository assets.

Synthetic fixtures are automated tests only. They are not physical-device, accessibility, signing, store, or handler evidence.

## Other maintained gates

| Gate | Primary responsibility |
| --- | --- |
| `dart format` | Dart source formatting |
| `flutter analyze` | Dart/Flutter static analysis and lints |
| `flutter test --coverage` | Unit/domain/persistence/widget/localization/workflow/release/audit regressions |
| `tool/release_readiness.dart` | Candidate/stable metadata and fail-closed real-world evidence boundary |
| `tool/release_qualification_status.dart` | Read-only canonical manual-qualification reporting/validation |
| `tool/source_completion_audit.dart` | Final feature-complete source contract |
| `tool/solver_benchmark.dart` | Deterministic Heuristic/Expectimax smoke behavior |
| Web/native workflows | Actual configured target compilation/package compatibility |

A green repository audit never means the app is physically qualified for stable distribution.

## Manual boundaries remain manual

The audit never marks real-world evidence as passed. These still require genuine representative environments:

- physical Android/iOS lifecycle/gameplay;
- TalkBack/VoiceOver/Narrator/browser screen readers;
- touch/orientation/keyboard/focus/responsive layouts;
- long sessions;
- real clipboard/file/browser/email/PWA handlers;
- Challenge Code/replay/backup real-target interaction;
- native icon/splash presentation;
- production signing/provisioning;
- store metadata/privacy/data-safety review.

Use [`QUALIFICATION_STATUS.md`](QUALIFICATION_STATUS.md) to inspect the pending set and [`QUALIFICATION_RECORDER.md`](QUALIFICATION_RECORDER.md) only after a real check was genuinely performed.

## Adding or changing documentation

When a maintenance or future-release change modifies documentation:

1. keep local paths case-correct;
2. use relative links for repository documents;
3. preserve historical evidence instead of relabeling it as current;
4. run `dart run tool/repository_audit.dart --json`;
5. run `dart run tool/source_completion_audit.dart --json` when current release-scope text changes;
6. index important permanent docs in [`README.md`](README.md).

Do not weaken either audit merely to preserve stale documentation.

## Scope discipline

The repository audit is intentionally not an internet crawler, vulnerability scanner, code formatter, browser simulator, device farm, or store publisher. Those concerns have dedicated tools/workflows or genuine manual qualification boundaries.
