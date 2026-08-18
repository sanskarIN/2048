# Release Qualification Recorder

2048 Nova keeps real-device and assistive-technology qualification separate from automated CI. The source of truth remains `docs/release_qualification.json`, while `tool/release_readiness.dart` remains the fail-closed validation gate.

To reduce manual JSON editing mistakes, maintainers can use the guarded recorder:

```bash
dart run tool/record_release_qualification.dart --list
```

The recorder never performs a device check, never infers that a check passed, and never converts hosted CI/build success into real-world qualification evidence. A maintainer must explicitly choose a status and provide evidence when recording a real result.

## List current qualification state

```bash
dart run tool/record_release_qualification.dart --list
```

This prints all 13 stable manual-check identifiers, their current status, and their human-readable title without modifying the manifest.

## Record a genuine passed result

After the real check has actually been completed, record it with the stable check ID and concise verifiable evidence:

```bash
dart run tool/record_release_qualification.dart \
  --id=android-device \
  --status=passed \
  --evidence="Physical Android release build: lifecycle, save/resume, Undo, restart, and background/foreground checks passed on the tested device."
```

If `--updated-at` is omitted for `passed` or `blocked`, the recorder uses the current UTC time. To supply the timestamp explicitly, use an unambiguous ISO-8601 value ending in `Z` or a numeric offset:

```bash
dart run tool/record_release_qualification.dart \
  --id=android-device \
  --status=passed \
  --evidence="Verified on the named physical target against the recorded release commit." \
  --updated-at=2026-08-18T15:30:00+05:30
```

The stored timestamp is normalized to UTC.

Do not use sample wording as evidence unless the described test was genuinely performed.

## Record a blocker

Use `blocked` when the check cannot currently be completed and record the actual reason:

```bash
dart run tool/record_release_qualification.dart \
  --id=ios-device \
  --status=blocked \
  --evidence="Blocked until a physical iOS signing/device test environment is available."
```

A blocked entry is not a pass and keeps stable release readiness closed.

## Return a check to pending

If previous evidence is no longer applicable, reset that item explicitly:

```bash
dart run tool/record_release_qualification.dart \
  --id=android-device \
  --status=pending
```

`pending` deliberately clears that check's evidence and timestamp. The command rejects `--evidence` or `--updated-at` when the requested status is `pending` so stale evidence is not retained accidentally.

## Preview without writing

Use `--dry-run` before a real manifest change when desired:

```bash
dart run tool/record_release_qualification.dart \
  --id=native-branding \
  --status=blocked \
  --evidence="Native presentation review has not been completed on representative targets." \
  --dry-run
```

The complete proposed JSON is printed to standard output and the repository file is left unchanged.

## Test-fixture root

The recorder accepts an alternate repository root for process-level regression fixtures:

```bash
dart run tool/record_release_qualification.dart \
  --root=/path/to/fixture \
  --list
```

This exists primarily for automated testing. Synthetic fixture results are not real release evidence.

## Guardrails

The recorder rejects:

- unknown command-line arguments;
- duplicate option values;
- missing or unknown manual-check IDs;
- statuses outside `pending`, `passed`, and `blocked`;
- `passed` or `blocked` without non-empty evidence;
- timezone-less or malformed explicit evidence timestamps;
- mutation options combined with `--list`;
- `pending` combined with evidence/timestamp input;
- malformed manifest structure, duplicate IDs, missing required IDs, or unexpected check IDs.

It preserves the existing check title/order and changes only the selected status/evidence/timestamp fields before re-encoding the manifest.

## Recommended evidence content

Evidence should be short enough to review but specific enough to reproduce or audit. Depending on the check, include the relevant combination of:

- device model and operating-system version;
- browser and version;
- tested app build, commit SHA, or qualification artifact;
- input method and orientation;
- assistive technology and language;
- exact feature paths exercised;
- pass/fail/blocker outcome;
- issue number for any discovered defect.

Do not place credentials, signing secrets, private keys, tokens, personal account secrets, or unrelated private information in the public evidence manifest.

## Validation sequence

After recording genuine evidence, run:

```bash
dart run tool/release_readiness.dart --json
```

Before stable release promotion, the strict gate must also pass:

```bash
dart run tool/release_readiness.dart --stable
```

The recorder is only an editing guardrail. `tool/release_readiness.dart` remains the authoritative release-state validator, and the physical/manual checks remain authoritative for the evidence itself.

## Regression coverage

`test/release_qualification_recorder_cli_test.dart` covers the process-level recorder contract, including:

- read-only listing;
- passed evidence recording;
- timezone-offset normalization;
- missing-evidence rejection;
- ambiguous timestamp rejection;
- unknown-ID rejection;
- resetting stale evidence back to pending;
- dry-run non-mutation behavior.

The existing release-readiness CLI tests continue to validate the final candidate/stable gate independently of the recorder.
