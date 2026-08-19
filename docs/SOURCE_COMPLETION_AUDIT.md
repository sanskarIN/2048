# Source Completion Audit

`tool/source_completion_audit.dart` is the final source-scope guard for **2048 Nova 2.0.12**. It complements, rather than replaces, the broader repository-integrity and release-readiness tools.

## Purpose

Version 2.0.12 is feature-complete within its declared offline-first puzzle-game scope. The source-completion audit keeps that statement testable by checking the files and invariants that define the completed release scope and by protecting its own permanent test/documentation/CI wiring.

Run it from the repository root:

```bash
dart run tool/source_completion_audit.dart
```

For machine-readable output:

```bash
dart run tool/source_completion_audit.dart --json
```

Regression fixtures may use:

```bash
dart run tool/source_completion_audit.dart --root=<path> --json
```

## What it checks

The audit fails closed when any of these source-completion boundaries drift:

- required final release/completion documents are missing or empty;
- the preserved pre-2.0.12 changelog archive or active continuity record disappears;
- the completion audit CLI, its regression suite, maintainer-tool index, human documentation, or permanent CI workflow disappears;
- `pubspec.yaml` is no longer `2.0.12+2012`;
- the release qualification candidate no longer matches `2.0.12+2012`;
- the qualification manifest no longer contains exactly 13 manual checks;
- `ROADMAP.md` loses the Version 2.0.12 feature-complete heading;
- `ROADMAP.md` loses the explicit external qualification boundary;
- `ROADMAP.md` loses the no-active-feature-backlog contract;
- the old `## Later — Optional expansion` section returns as active Version 2.0.12 work;
- the final source audit loses its explicit feature-complete verdict;
- the maintenance policy loses its no-active-feature-backlog boundary;
- the documentation index stops linking the final source audit, maintenance policy, or this source-completion audit guide;
- current release-facing documentation regresses to obsolete `1.5.0+15` metadata or describes Version 1.5 as the current line;
- permanent CI stops executing `dart run tool/source_completion_audit.dart --json`;
- `tool/README.md` stops indexing the completion audit;
- this document stops identifying `test/source_completion_audit_cli_test.dart` as the process-level regression suite;
- maintained Dart under `lib/`, `test/`, or `tool/` contains an unresolved line comment beginning with `TODO` or `FIXME`.

The unresolved-marker rule intentionally targets maintained Dart source only. Historical documents and prose may legitimately discuss TODO/FIXME terminology without creating unfinished executable or test/tool work.

## Self-protection

The completion audit is part of the release contract, so it now verifies its own permanent support surface:

```text
tool/source_completion_audit.dart
test/source_completion_audit_cli_test.dart
docs/SOURCE_COMPLETION_AUDIT.md
tool/README.md
.github/workflows/ci.yml
```

A completion gate that can silently disappear is not a durable completion gate. These paths are therefore required and CI wiring is checked semantically for the maintained command.

## Relationship to the other tools

| Tool | Responsibility |
| --- | --- |
| `tool/release_readiness.dart` | Candidate/stable release metadata and fail-closed real-world evidence gate. |
| `tool/release_qualification_status.dart` | Read-only validation/reporting of the canonical 13 manual checks. |
| `tool/record_release_qualification.dart` | Guarded storage of evidence a maintainer genuinely observed. |
| `tool/repository_audit.dart` | Required repository files, version consistency, Web/PWA semantics, temporary helpers, and local Markdown links. |
| `tool/source_completion_audit.dart` | Final Version 2.0.12 feature-scope/completion contract, self-wiring, and unresolved maintained-Dart work markers. |
| `tool/solver_benchmark.dart` | Deterministic Heuristic/Expectimax smoke and benchmark behavior. |

The permanent CI workflow runs both repository audits because they answer different questions: repository integrity asks whether the repository is internally coherent; source completion asks whether the completed 2.0.12 scope has accidentally been reopened, regressed, or had its final guardrails removed.

## Regression coverage

`test/source_completion_audit_cli_test.dart` exercises process-level fixtures for:

1. clean feature-complete success;
2. package/build-version drift;
3. restored optional-feature backlog;
4. missing final documentation-index entries;
5. unresolved product TODO comments;
6. unresolved maintenance-tool FIXME comments;
7. missing permanent-CI source-completion wiring;
8. stale Version 1.5 current-release metadata;
9. release-qualification candidate mismatch;
10. malformed/unknown CLI arguments.

Synthetic fixtures test the audit contract only. They are not gameplay, device, accessibility, signing, or store qualification evidence.

## What it does not prove

A passing source-completion audit does **not** prove:

- that no software defect can ever exist;
- that the current head has passed every Flutter/native workflow unless those workflows were actually observed;
- physical Android/iOS behavior;
- real assistive-technology quality;
- real browser/PWA lifecycle/storage behavior;
- clipboard/file/email/document-provider handler behavior;
- native icon/splash presentation;
- production signing/provisioning;
- Play Store/App Store acceptance.

Those remain separate automated or real-environment release boundaries documented in `RELEASE_CHECKLIST.md` and `RELEASE_QUALIFICATION.md`.

## Maintenance rule

After Version 2.0.12 source completion, a change that intentionally adds new product functionality should start a new release scope and update the roadmap/completion contract deliberately. Do not weaken this audit merely to make an unplanned feature appear as though it had always belonged to the completed 2.0.12 scope.
