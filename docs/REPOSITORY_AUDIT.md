# Repository Integrity Audit

2048 Nova includes a repository-level audit in addition to Flutter formatting, static analysis, automated tests, release-readiness validation, qualification-status reporting, solver smoke testing, and platform builds.

The audit is implemented by:

```text
tool/repository_audit.dart
```

It is intended to catch source-controlled release and documentation drift that normal Dart analysis does not detect.

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

The audit fails when required project, open-source, release, support, security, build, signing-safety, tooling, or workflow files are missing or empty. This includes the primary README, changelog, roadmap, license, `.gitignore`, contribution/security/support files, release-qualification files, qualification recorder/status documentation, Phase 31 verification record, build handbook, safe `android/key.properties.example` template, maintainer tooling index, repository-owned maintenance CLIs, and permanent CI workflows.

Requiring `.gitignore` and the Android signing template protects the documented boundary in which real `android/key.properties`, `*.jks`, and `*.keystore` material stays outside the public repository while maintainers still have a reproducible production-signing setup path.

### Release-state consistency

The audit checks that:

- the package version in `pubspec.yaml` is parseable;
- canonical `homepage`, `repository`, and `issue_tracker` metadata remain aligned with `sanskarIN/2048`;
- the in-app `ProjectInfo.version` matches the package marketing version;
- the release-qualification manifest candidate exactly matches the package version including build suffix;
- the qualification manifest contains exactly the required 13 manual check records;
- the continuity log identifies the current Phase 31 state;
- the continuity log preserves the explicit `0/13` real-world qualification boundary while those checks remain pending.

This supplements, rather than replaces, the stricter semantic validation performed by `tool/release_readiness.dart` and the canonical check/evidence validation performed by `tool/release_qualification_status.dart`.

### Temporary workflow cleanup

Known one-shot Phase 30 and Phase 31 helper paths are forbidden from remaining in the final repository. This includes the Phase 31 documentation finalizer, its trigger marker, and its temporary Python updater. If one is accidentally reintroduced, the audit fails instead of allowing temporary release-maintenance machinery to become permanent dead configuration.

### Local Markdown links

The audit scans top-level Markdown plus Markdown under `docs/`, `.github/`, and `tool/`, and validates local file/directory destinations.

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
| `flutter test --coverage` | Unit, domain, persistence, widget, localization, workflow, and regression behavior |
| `tool/release_readiness.dart` | Candidate/stable release metadata and stable manual-evidence gate |
| `tool/release_qualification_status.dart` | Read-only canonical manual-qualification status/evidence-shape reporting |
| `tool/repository_audit.dart` | Required-file, signing-safety, local-doc-link, temporary-file, and release-state drift |
| `tool/solver_benchmark.dart` | Deterministic solver smoke/regression behavior |
| Flutter Web/native builds | Build-system and target compilation compatibility |

A green repository audit or status report does not mean the application is physically qualified for stable distribution.

## Manual boundaries remain manual

The audit must never mark real-device qualification evidence as passed. Physical Android/iOS testing, assistive-technology checks, clipboard/file/browser/email handlers, long-session checks, native branding review, signing/provisioning, and distribution/store metadata still require genuine representative-environment evidence in `docs/release_qualification.json`.

Use the read-only reporter described in [`QUALIFICATION_STATUS.md`](QUALIFICATION_STATUS.md) to inspect what remains. Use the guarded recorder described in [`QUALIFICATION_RECORDER.md`](QUALIFICATION_RECORDER.md) only after a check has actually been performed.

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

This tool intentionally avoids becoming a general internet crawler, package vulnerability scanner, code formatter, or store-release publisher. Those concerns already have dedicated workflows, tools, or manual qualification boundaries. Keeping the audit deterministic and repository-local makes failures reproducible on every supported development host with Dart available.
