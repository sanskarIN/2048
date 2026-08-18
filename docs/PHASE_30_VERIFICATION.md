# Phase 30 Verification — Guarded Release Qualification Recorder

## Scope

Phase 30 reduces the risk of malformed or misleading edits to `docs/release_qualification.json` by adding a dedicated maintenance CLI while preserving the existing fail-closed stable-release policy.

This phase does **not** claim that any physical-device, assistive-technology, long-session, external-handler, signing/provisioning, branding-presentation, or store-metadata qualification has been completed.

## Source changes

Implemented:

- `tool/record_release_qualification.dart`
- `test/release_qualification_recorder_cli_test.dart`
- `docs/QUALIFICATION_RECORDER.md`

Relevant implementation commits:

- `10611015996014611018936b95195dbc5f28eeb0` — `feat: add guarded release qualification recorder`
- `59a61beb7de19be739b1ad8af6180c2c66bf91f7` — `test: cover release qualification recorder`
- `b5a11ad28b005001ab5008bdd949caffe24f5772` — `style: format Dart sources tests and tools`
- `1dd8fbaeed17fbe522cd9c4e2bfe259596c82426` — `docs: add release qualification recorder guide`

## Recorder contract

The recorder supports:

```bash
dart run tool/record_release_qualification.dart --list
```

and guarded mutations such as:

```bash
dart run tool/record_release_qualification.dart \
  --id=<required-check-id> \
  --status=passed \
  --evidence="<genuine real-world evidence>"
```

It also supports `blocked`, resetting back to `pending`, explicit ISO-8601 timestamps, `--dry-run`, and an alternate `--root=<path>` for regression fixtures.

## Safety and integrity boundaries

The recorder is intentionally unable to determine whether a device test really happened. It therefore does not infer qualification from CI, hosted builds, widget tests, generated artifacts, or fixture data.

For `passed` and `blocked`, the maintainer must explicitly provide evidence. Explicit timestamps must include `Z` or a numeric timezone offset; stored values are normalized to UTC. Returning an item to `pending` clears its evidence and timestamp so stale evidence is not retained accidentally.

The tool validates the manifest's schema shape, supported status set, exact required-ID set, duplicate IDs, missing IDs, unknown IDs, evidence requirements, and command-line option combinations before writing.

## Process-level regression coverage

`test/release_qualification_recorder_cli_test.dart` adds focused process-level coverage for:

1. `--list` read-only behavior.
2. Passed-result evidence recording.
3. Numeric-offset timestamp normalization to UTC.
4. Missing-evidence rejection.
5. Timezone-less timestamp rejection.
6. Unknown qualification-ID rejection.
7. Resetting an existing passed record back to pending.
8. `--dry-run` non-mutation behavior.

The existing `test/release_readiness_cli_test.dart` remains independent and continues to validate the final release gate itself.

## Formatting evidence

The repository's permanent `Format Dart` workflow reacted to the new `tool/` and `test/` files and produced:

- `b5a11ad28b005001ab5008bdd949caffe24f5772` — `style: format Dart sources tests and tools`

This confirms the newly added Dart sources were normalized by the repository-managed formatter workflow.

## Manual qualification state

Phase 30 does not modify `docs/release_qualification.json` and does not create synthetic qualification evidence. The stable-release boundary therefore remains dependent on genuine completion of all required manual checks.

## Required follow-up before stable release

Continue using the real-target procedures already defined in the release, accessibility, backup, replay, Challenge Code, executable-build, and platform documentation. After each real check is genuinely performed, use the recorder to enter concise verifiable evidence, then validate with:

```bash
dart run tool/release_readiness.dart --json
```

Only after the complete real-world qualification set and stable metadata are ready should the strict gate be expected to pass:

```bash
dart run tool/release_readiness.dart --stable
```
