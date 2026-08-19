# Repository Integrity Audit

2048 Nova includes a repository-level audit in addition to Flutter formatting, static analysis, automated tests, release-readiness validation, qualification-status reporting, solver smoke testing, and platform builds.

The audit is implemented by:

```text
tool/repository_audit.dart
```

It is intended to catch source-controlled release and documentation drift that normal Dart analysis does not detect.

## Current Version 2.0.12 contract

Phase 32 defines two related version values:

```text
Marketing version: 2.0.12
Flutter package/build version: 2.0.12+2012
```

The repository audit treats those values as part of the current source-controlled release contract. A later intentional version change must update the audit, its fixtures, release gate, release documentation, continuity record, and platform fallback metadata together rather than weakening the checks.

## Run the audit

From the repository root:

```bash
dart run tool/repository_audit.dart
```

For machine-readable output:

```bash
dart run tool/repository_audit.dart --json
```

For isolated regression fixtures or another checkout:

```bash
dart run tool/repository_audit.dart --root=<path> --json
```

The permanent CI workflow runs the JSON form automatically.

## What the audit checks

### Required repository files

The audit fails when required project, open-source, release, support, security, build, signing-safety, tooling, Web/PWA, continuity, or workflow files are missing or empty. This includes the primary README, changelog, roadmap, license, `.gitignore`, contribution/security/support files, release-qualification files, qualification recorder/status documentation, Phase 31 verification history, the Phase 32 Version 2.0.12 record, build handbook, safe `android/key.properties.example` template, Windows resource metadata, maintainer tooling index, repository-owned maintenance CLIs, permanent CI workflows, Web/PWA shell/manifest/icon assets, the PWA guide, the active continuity index, and both historical continuity archives.

Requiring `.gitignore` and the Android signing template protects the documented boundary in which real `android/key.properties`, `*.jks`, and `*.keystore` material stays outside the public repository while maintainers still have a reproducible production-signing setup path.

Requiring the Web/PWA shell, manifest, favicon, regular/maskable icon matrix, and PWA guide protects the install-oriented source contract from accidental file deletion. Semantic manifest and HTML metadata are additionally covered by `test/web_pwa_metadata_test.dart`.

Requiring both `what_changed_archive_phase_00_30.md` and `what_changed_archive_phase_31.md` prevents the compact active Phase 32 continuity index from accidentally replacing detailed historical implementation/verification records.

### Version and release-state consistency

The audit checks that:

- `pubspec.yaml` is exactly `2.0.12+2012` for the current Phase 32 package/build contract;
- canonical `homepage`, `repository`, and `issue_tracker` metadata remain aligned with `sanskarIN/2048`;
- the in-app `ProjectInfo.version` is exactly `2.0.12` and matches the package marketing version;
- Windows fallback `VERSION_AS_NUMBER` is `2,0,12,2012`;
- Windows fallback `VERSION_AS_STRING` is `2.0.12`;
- the release-qualification manifest candidate exactly matches the package/build version;
- the qualification manifest contains exactly the required 13 manual check records;
- the continuity log identifies Phase 32;
- the continuity log identifies package candidate `2.0.12+2012`;
- the continuity log preserves the explicit `0/13` real-world qualification boundary while those checks remain pending.

This supplements, rather than replaces, the stricter candidate/stable validation performed by `tool/release_readiness.dart` and the canonical check/evidence validation performed by `tool/release_qualification_status.dart`.

### Web/PWA semantic consistency

The audit parses `web/manifest.json` and fails closed when install-oriented source metadata drifts from the maintained contract. It verifies:

- app name and short name;
- relative install identity, start URL, and scope (`.`);
- standalone display mode;
- English/left-to-right manifest metadata;
- orientation and related-application policy;
- `games` and `entertainment` categories;
- exactly the regular/maskable 192×192 and 512×512 PNG icon matrix.

The audit also checks required `web/index.html` fragments for the document language, Flutter base-href placeholder, theme/color-scheme metadata, generic/Apple mobile install metadata, manifest/touch-icon links, title, and Flutter bootstrap script.

This repository-level check complements `test/web_pwa_metadata_test.dart`: the audit gives maintainers a deterministic source-integrity command, while the focused Flutter test keeps the PWA contract inside the normal regression suite.

### Temporary workflow cleanup

Known one-shot Phase 30, Phase 31, and Phase 32 helper paths are forbidden from remaining in the final repository. If a temporary finalizer workflow, trigger marker, or helper script is accidentally reintroduced, the audit fails instead of allowing release-maintenance machinery to become permanent dead configuration.

### Local Markdown links

The audit scans top-level Markdown plus Markdown under `docs/`, `.github/`, and `tool/`, and validates local file/directory destinations. Because the historical continuity archives remain at repository root, their relative links retain the original resolution base and are audited with current root documentation.

It ignores:

- same-document anchors;
- `http://` and `https://` destinations;
- `mailto:`, `tel:`, and `data:` destinations;
- Markdown content inside fenced code examples.

This keeps the check deterministic and offline. It deliberately does **not** make network requests to prove that external websites are reachable.

An unclosed Markdown code fence is reported as a warning because it may make later link parsing ambiguous and usually deserves review.

## Relationship to other gates

The repository audit has a narrow role:

| Gate | Primary responsibility |
| --- | --- |
| `dart format` | Dart source formatting |
| `flutter analyze` | Dart/Flutter static analysis and linting |
| `flutter test --coverage` | Unit, domain, persistence, widget, localization, workflow, Web/PWA metadata, release-contract, and regression behavior |
| `tool/release_readiness.dart` | Version 2.0.12 candidate/stable release metadata and stable manual-evidence gate |
| `tool/release_qualification_status.dart` | Read-only canonical manual-qualification status/evidence-shape reporting |
| `tool/repository_audit.dart` | Exact version surfaces, required files, signing-safety, Web/PWA semantic/source, continuity archives, local-doc links, temporary files, and release-state drift |
| `tool/solver_benchmark.dart` | Deterministic solver smoke/regression behavior |
| Flutter Web/native builds | Build-system and target compilation compatibility |

A green repository audit, metadata regression test, or status report does not mean the application is physically qualified for stable distribution.

## Regression fixtures

`test/repository_audit_cli_test.dart` constructs isolated repositories and proves both success and fail-closed behavior. Phase 32 coverage includes:

- a clean `2.0.12+2012` / `2.0.12` fixture;
- exact package/build-version drift;
- runtime marketing-version drift;
- Windows fallback version drift;
- canonical repository metadata drift;
- qualification-candidate drift;
- Web/PWA identity and HTML-language drift;
- broken local Markdown links;
- Phase 31 and Phase 32 temporary helper rejection;
- unclosed Markdown-fence warnings.

Synthetic fixtures are audit tests only and are not release qualification evidence.

## Manual boundaries remain manual

The audit must never mark real-device qualification evidence as passed. Physical Android/iOS testing, assistive-technology checks, clipboard/file/browser/email handlers, installed-PWA/browser behavior, long-session checks, native branding review, signing/provisioning, and distribution/store metadata still require genuine representative-environment evidence in `docs/release_qualification.json`.

Use the read-only reporter described in [`QUALIFICATION_STATUS.md`](QUALIFICATION_STATUS.md) to inspect what remains. Use the guarded recorder described in [`QUALIFICATION_RECORDER.md`](QUALIFICATION_RECORDER.md) only after a check has actually been performed. Web/PWA deployment and install boundaries are documented in [`PWA.md`](PWA.md). The current version-migration boundary is documented in [`PHASE_32_VERSION_2_0_12.md`](PHASE_32_VERSION_2_0_12.md).

## Adding new documentation

When adding a Markdown document:

1. use relative local links when pointing to another repository document;
2. keep linked paths case-correct so Linux CI can resolve them;
3. avoid putting real links inside examples unless they are intended to be followed;
4. run `dart run tool/repository_audit.dart --json` before committing;
5. add important permanent documentation to [`README.md`](README.md) when it belongs in the documentation map.

If the audit reports a broken link, fix the document or the intended file path. Do not weaken the audit merely to preserve a stale link.

## Maintainer tooling map

[`../tool/README.md`](../tool/README.md) is the compact entry point for the repository audit, release-readiness gate, qualification status reporter, qualification recorder, and deterministic solver benchmark. The tooling index itself is required by the audit and its local Markdown links are scanned with the rest of the maintained documentation.

## Scope discipline

This tool intentionally avoids becoming a general internet crawler, package vulnerability scanner, code formatter, browser-install simulator, or store-release publisher. Those concerns already have dedicated workflows, tools, regression tests, or manual qualification boundaries. Keeping the audit deterministic and repository-local makes failures reproducible on every supported development host with Dart available.
