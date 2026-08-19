# Release Gate Regression Testing

The stable-release gate is a release-engineering safety boundary, so it is tested against temporary repository fixtures rather than only against the current live **Version 2.0.12** checkout.

The current source contract uses marketing version `2.0.12` and Flutter package/build version `2.0.12+2012`.

## Fixture support

`tool/release_readiness.dart` accepts:

```bash
dart run tool/release_readiness.dart --root=<path> --json
```

`--root=<path>` changes only the repository root inspected by the maintenance CLI. It does not change application behavior, player data, build output, or release state. Its purpose is to let automated tests build isolated temporary repositories with deliberately valid or invalid release metadata.

The ordinary maintainer commands remain:

```bash
dart run tool/release_readiness.dart --json
dart run tool/release_readiness.dart --stable --json
```

## Version 2.0.12 regression scenarios

`test/release_readiness_cli_test.dart` exercises the actual CLI process against generated temporary fixtures. Current focused scenarios are:

1. A valid `2.0.12+2012` release candidate passes candidate mode while remaining not ready for stable promotion with pending manual evidence.
2. A complete synthetic `2.0.12+2012` fixture with a `[2.0.12]` changelog section and passed evidence for all 13 required checks succeeds in strict stable mode; its evidence timestamps use an explicit numeric offset.
3. A nominal `2.0.12` fixture with pending manual evidence is rejected by strict stable mode.
4. The former `1.5.0+15` candidate is rejected after the Version 2.0.12 migration.
5. An unrelated patch target such as `2.0.11+2011` is rejected rather than silently accepted as the current release.
6. A qualification-manifest candidate that disagrees with `pubspec.yaml` is rejected.
7. A check marked `passed` without evidence or a timestamp is rejected.
8. A manifest missing one of the required stable check IDs is rejected.

`test/release_evidence_timestamp_test.dart` adds a focused release-evidence timestamp boundary:

9. A Version 2.0.12 check marked `passed` with evidence but with timezone-less `updatedAt` text such as `2026-08-19T07:30:00` is rejected. Release evidence must identify an absolute instant through `Z` or an explicit numeric UTC offset.

These tests are intentionally file-system/process level. They protect argument parsing, root resolution, required-file checks, exact release-target parsing, JSON decoding, manifest validation, evidence policy, absolute timestamp requirements, stable metadata requirements, exit codes, and JSON output together instead of mocking those boundaries independently.

## Why evidence timestamps require a timezone

Manual release evidence may be recorded on Android, iOS, Windows, macOS, Linux, or Web qualification systems located in different time zones. A timestamp without `Z` or an offset is only a local wall-clock label and can be interpreted differently by another machine.

Accepted examples include:

```text
2026-08-19T02:00:00Z
2026-08-19T07:30:00+05:30
```

An ambiguous value such as this is rejected:

```text
2026-08-19T07:30:00
```

This rule applies to release qualification evidence. Legacy player-save timestamp compatibility is documented separately in [`PORTABLE_TIMESTAMPS.md`](PORTABLE_TIMESTAMPS.md).

## Trust boundary

Fixture tests prove that the gate accepts and rejects metadata correctly. They do **not** count as evidence that a real Android/iOS device, screen reader, external handler, PWA install, signing configuration, or store listing was qualified. Real-world evidence still belongs in `docs/release_qualification.json` only after the corresponding manual work is actually performed.

A synthetic fully passed fixture is deliberately allowed so the success branch of the gate remains testable. It must never be copied into the live evidence manifest merely to open stable mode.

## Relationship to Phase 32

Phase 32 intentionally tightened the gate around one exact release target instead of accepting an entire major/minor family. This prevents accidental drift to a different patch release while documentation, platform metadata, and the qualification candidate still refer to Version 2.0.12.

See [`PHASE_32_VERSION_2_0_12.md`](PHASE_32_VERSION_2_0_12.md) for the coordinated package/runtime/platform migration and [`RELEASE_QUALIFICATION.md`](RELEASE_QUALIFICATION.md) for the promotion procedure.

## Verification record

Historical accepted-source evidence remains preserved in `VERIFICATION.md`, the phase verification documents, and the continuity archives. The earlier 235-test/106-file Version 1.5 result is historical baseline evidence only; it is not automatically evidence for the current Version 2.0.12 source state.

The live Version 2.0.12 qualification manifest remains **0/13** real-world checks complete, so strict stable promotion remains intentionally fail-closed until genuine evidence and final stable metadata are present.
