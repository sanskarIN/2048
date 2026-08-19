from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def replace_once(path: str, old: str, new: str) -> None:
    target = ROOT / path
    text = target.read_text(encoding="utf-8")
    if new in text:
        return
    if old not in text:
        raise RuntimeError(f"Expected anchor not found in {path}: {old[:80]!r}")
    target.write_text(text.replace(old, new, 1), encoding="utf-8")


def replace_line_prefix(path: str, prefix: str, replacement: str) -> None:
    target = ROOT / path
    lines = target.read_text(encoding="utf-8").splitlines()
    matches = [index for index, line in enumerate(lines) if line.startswith(prefix)]
    if len(matches) != 1:
        raise RuntimeError(
            f"Expected exactly one line starting {prefix!r} in {path}; found {len(matches)}"
        )
    lines[matches[0]] = replacement
    target.write_text("\n".join(lines) + "\n", encoding="utf-8")


def append_once(path: str, marker: str, block: str) -> None:
    target = ROOT / path
    text = target.read_text(encoding="utf-8")
    if marker in text:
        return
    separator = "" if text.endswith("\n") else "\n"
    target.write_text(f"{text}{separator}\n{block.rstrip()}\n", encoding="utf-8")


def main() -> None:
    replace_once(
        "CHANGELOG.md",
        "### Added\n",
        "### Added\n"
        "- Read-only Version 1.5 qualification status reporter with human/JSON output, pending-only detail filtering, canonical 13-check validation, and an optional fail-if-incomplete exit code for maintainer automation.\n"
        "- Process-level regression coverage for qualification summaries, filtering, malformed evidence, incomplete enforcement, and fully-passed synthetic fixtures; permanent CI now reports the live incomplete qualification set without fabricating manual evidence.\n",
    )

    replace_once(
        "docs/README.md",
        "| [`QUALIFICATION_RECORDER.md`](QUALIFICATION_RECORDER.md) | Guarded CLI for listing and recording genuine manual qualification evidence without hand-editing JSON. |\n",
        "| [`QUALIFICATION_RECORDER.md`](QUALIFICATION_RECORDER.md) | Guarded CLI for listing and recording genuine manual qualification evidence without hand-editing JSON. |\n"
        "| [`QUALIFICATION_STATUS.md`](QUALIFICATION_STATUS.md) | Read-only human/JSON status reporter for the canonical 13-check manual qualification manifest, including pending-only views and strict evidence-shape validation. |\n",
    )
    replace_once(
        "docs/README.md",
        "| [`PHASE_30_VERIFICATION.md`](PHASE_30_VERIFICATION.md) | Phase 30 recorder implementation, safety boundaries, regression coverage, and manual-evidence boundary. |\n",
        "| [`PHASE_30_VERIFICATION.md`](PHASE_30_VERIFICATION.md) | Phase 30 recorder implementation, safety boundaries, regression coverage, and manual-evidence boundary. |\n"
        "| [`PHASE_31_VERIFICATION.md`](PHASE_31_VERIFICATION.md) | Phase 31 read-only qualification reporting, canonical-check validation, regression coverage, CI integration, and evidence trust boundary. |\n",
    )
    replace_once(
        "docs/README.md",
        "- **Stable-release evidence gate:** `tool/release_readiness.dart` plus `release_qualification.json`; human procedure is `RELEASE_QUALIFICATION.md`.\n",
        "- **Stable-release evidence gate:** `tool/release_readiness.dart` plus `release_qualification.json`; human procedure is `RELEASE_QUALIFICATION.md`.\n"
        "- **Manual qualification status reporting:** `tool/release_qualification_status.dart`; command contract and trust boundary are documented in `QUALIFICATION_STATUS.md`.\n",
    )

    replace_once(
        "docs/RELEASE_QUALIFICATION.md",
        "To reduce hand-editing mistakes, maintainers may use `dart run tool/record_release_qualification.dart --list` and the guarded mutation commands documented in [`QUALIFICATION_RECORDER.md`](QUALIFICATION_RECORDER.md). The recorder does not perform or infer any real-world check; it only validates and records evidence explicitly supplied by the maintainer.\n",
        "To inspect the current state without mutation, run `dart run tool/release_qualification_status.dart --pending-only` (or add `--json`) as documented in [`QUALIFICATION_STATUS.md`](QUALIFICATION_STATUS.md). To reduce hand-editing mistakes when evidence is genuinely available, maintainers may use `dart run tool/record_release_qualification.dart --list` and the guarded mutation commands documented in [`QUALIFICATION_RECORDER.md`](QUALIFICATION_RECORDER.md). Neither tool performs or infers a real-world check: the reporter is read-only, and the recorder only validates and stores evidence explicitly supplied by the maintainer.\n",
    )
    replace_once(
        "docs/RELEASE_QUALIFICATION.md",
        "dart run tool/release_readiness.dart --json\ndart run tool/solver_benchmark.dart 8\nflutter build web --release\n",
        "dart run tool/release_readiness.dart --json\ndart run tool/release_qualification_status.dart --json --pending-only\ndart run tool/repository_audit.dart --json\ndart run tool/solver_benchmark.dart 8\nflutter build web --release\n",
    )

    replace_line_prefix(
        "what_changed.md",
        "- **Current phase:**",
        "- **Current phase:** Phase 31 — read-only release-qualification status reporting implemented, canonically formatted, regression-tested in source, CI-wired, and documented; the latest previously accepted full CI/native evidence remains the Phase 29 Version 1.5 baseline until a newer maintained workflow result is explicitly recorded; the stable qualification boundary remains 0/13 and GitHub issues #10 and #12 remain explicit",
    )

    append_once(
        "what_changed.md",
        "# Phase 31 — Read-only release qualification status reporting",
        """# Phase 31 — Read-only release qualification status reporting

Date: **2026-08-19**

## Why this phase was selected

The Version 1.5 source tree already contains the major gameplay, replay, backup, Challenge Code, localization, solver, platform, build, and release-readiness work. The remaining stable-release blockers are the 13 real-world checks in `docs/release_qualification.json`. Those checks require representative physical devices, assistive technology, native/external handlers, signing/provisioning, or store review and therefore cannot be truthfully manufactured by hosted automation.

Phase 31 improves the maintainer workflow around that real boundary without weakening it. It adds a deterministic read-only status reporter, focused process-level tests, permanent CI reporting, and documentation that makes the remaining checks easier to inspect while preserving the existing fail-closed stable gate.

## Implementation commits

```text
2f1766489a19fd77e45cc7fdbc3637e39af1a516  feat: add release qualification status reporter
648a7f7580957f3938b0d9acd719262376221af9  fix: preserve qualification summary when filtering
843d4ec5efaa279489d91514445ce1c6e857b116  fix: enforce canonical qualification checklist
2f11942f22a492f136c1fcb97e306f599263b271  test: cover release qualification status reporter
01ed738ece67d59121fd84c30cda7a9134ba4459  ci: report manual qualification status
2fbf6e9f71dc1a69f49b482e17922258705488ef  docs: document qualification status reporter
6005018e49476be8fd770e57c9fcddad76f03997  docs: add qualification status reference
db86c5d1b79e68b6695b35cdf281f7effc2c83fd  docs: record qualification status tooling in roadmap
e35d39658ee106dcd15e06f84671597eadf0e315  docs: add Phase 31 verification record
```

## Reporter contract

`tool/release_qualification_status.dart` supports:

```text
--json
--pending-only
--fail-if-incomplete
--root=<path>
--help / -h
```

It validates schema version 1, a non-empty candidate, exactly the canonical 13 manual-check IDs, unique IDs, valid statuses, clean pending entries, evidence for passed/blocked entries, and explicit-timezone ISO-8601 evidence timestamps. Normal report mode exits successfully for a structurally valid manifest even when real checks remain pending. `--fail-if-incomplete` uses exit code 3 specifically when a caller intentionally wants incompleteness to fail. Malformed arguments/evidence use exit code 64.

The `--pending-only` implementation filters only the detail array. Full aggregate totals remain based on the canonical 13 checks; this corrects an early implementation design before permanent adoption and is covered by regression tests.

## Permanent CI behavior

Permanent CI now runs the read-only command:

```bash
dart run tool/release_qualification_status.dart --json --pending-only
```

This validates and surfaces the live incomplete set in job logs. CI still separately exercises `tool/release_readiness.dart --stable` as a fail-closed boundary. The reporter does not mutate `docs/release_qualification.json` and cannot mark a manual check passed.

## Evidence boundary retained

At the time Phase 31 source work was committed, the live qualification manifest still recorded **0/13** genuine real-world checks as passed. No device, accessibility, signing, provisioning, external-handler, branding, or store evidence was invented. The stable `1.5.0` promotion remains blocked until those checks are actually performed and recorded.

Full Phase 31 command semantics, regression scope, and trust boundaries are documented in `docs/QUALIFICATION_STATUS.md` and `docs/PHASE_31_VERIFICATION.md`.
""",
    )


if __name__ == "__main__":
    main()
