# Release Gate Regression Testing

The stable-release gate is a release-engineering safety boundary, so it is tested against temporary repository fixtures rather than only against the current live `1.5.x` checkout.

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

## Regression scenarios

`test/release_readiness_cli_test.dart` exercises the actual CLI process against generated temporary fixtures. The focused scenarios are:

1. A valid `1.5.0+15` release candidate passes candidate mode while remaining not ready for stable promotion.
2. A complete `1.5.0+1` fixture with a `[1.5.0]` changelog section and passed evidence for all 13 required checks succeeds in strict stable mode; its evidence timestamps use an explicit numeric offset.
3. A nominal `1.5.0` fixture with pending manual evidence is rejected by strict stable mode.
4. A qualification-manifest candidate that disagrees with `pubspec.yaml` is rejected.
5. A check marked `passed` without evidence or a timestamp is rejected.
6. A manifest missing one of the required stable check IDs is rejected.

`test/release_evidence_timestamp_test.dart` adds a focused release-evidence timestamp boundary:

7. A check marked `passed` with evidence but with timezone-less `updatedAt` text such as `2026-08-17T14:30:00` is rejected. Release evidence must identify an absolute instant through `Z` or an explicit numeric UTC offset.

These tests are intentionally file-system/process level. They protect argument parsing, root resolution, required-file checks, version parsing, JSON decoding, manifest validation, evidence policy, absolute timestamp requirements, stable metadata requirements, exit codes, and JSON output together instead of mocking those boundaries independently.

## Why evidence timestamps require a timezone

Manual release evidence may be recorded on Android, iOS, Windows, macOS, Linux, or Web qualification systems located in different time zones. A timestamp without `Z` or an offset is only a local wall-clock label and can be interpreted differently by another machine.

Accepted examples include:

```text
2026-08-17T09:00:00Z
2026-08-17T14:30:00+05:30
```

An ambiguous value such as this is rejected:

```text
2026-08-17T14:30:00
```

This rule applies to release qualification evidence. Legacy player-save timestamp compatibility is documented separately in [`PORTABLE_TIMESTAMPS.md`](PORTABLE_TIMESTAMPS.md).

## Trust boundary

Fixture tests prove that the gate accepts and rejects metadata correctly. They do **not** count as evidence that a real Android/iOS device, screen reader, external handler, signing configuration, or store listing was qualified. Real-world evidence still belongs in `docs/release_qualification.json` only after the corresponding manual work is actually performed.

## Verification record

Historical accepted-source evidence remains preserved in `VERIFICATION.md`, the phase verification documents, and `what_changed.md`. Current Phase 29 verification records the portable timestamp and absolute release-evidence regression additions together with the latest permanent CI and native-build evidence.

The live Version 1.5 qualification manifest remains **0/13** real-world checks complete, so strict stable promotion remains intentionally fail-closed.
