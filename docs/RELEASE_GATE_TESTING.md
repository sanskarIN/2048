# Release Gate Regression Testing

The stable-release gate is a release-engineering safety boundary, so it is tested against temporary repository fixtures rather than only against the current live `0.9.x` checkout.

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

1. A valid `0.9.0+1` release candidate passes candidate mode while remaining not ready for stable promotion.
2. A complete `1.0.0+1` fixture with a `[1.0.0]` changelog section and passed evidence for all 13 required checks succeeds in strict stable mode.
3. A nominal `1.0.0` fixture with pending manual evidence is rejected by strict stable mode.
4. A qualification-manifest candidate that disagrees with `pubspec.yaml` is rejected.
5. A check marked `passed` without evidence or a timestamp is rejected.
6. A manifest missing one of the required stable check IDs is rejected.

These tests are intentionally file-system/process level. They protect argument parsing, root resolution, required-file checks, version parsing, JSON decoding, manifest validation, evidence policy, stable metadata requirements, exit codes, and JSON output together instead of mocking those boundaries independently.

## Trust boundary

Fixture tests prove that the gate accepts and rejects metadata correctly. They do **not** count as evidence that a real Android/iOS device, screen reader, external handler, signing configuration, or store listing was qualified. Real-world evidence still belongs in `docs/release_qualification.json` only after the corresponding manual work is actually performed.

## Verification record

Accepted current-source evidence:

```text
Source: 57c6312ee26eed0cea8597ebf6417d442cf988cc
CI run: 31932367464
CI job: 95129044532
Formatting: PASS — 97 files, 0 changed
Analysis: PASS — No issues found
Tests: PASS — 200/200, including all 6 gate fixture scenarios
Candidate gate: PASS — 0/13 real-world checks complete; readyForStable=false
Stable boundary: PASS — current RC refused exactly as intended
Solver smoke: PASS
Web/WASM verification: PASS
```

Historical Phase 22 evidence remains valid for the first gate implementation, while this run supersedes its automated test count for the current source state. Full details are also recorded in `docs/VERIFICATION.md` and `what_changed.md`.
