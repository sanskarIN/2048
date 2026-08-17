from pathlib import Path


def replace_once(path: str, old: str, new: str) -> None:
    file = Path(path)
    text = file.read_text(encoding="utf-8")
    if new in text:
        return
    if old not in text:
        raise SystemExit(f"Expected text not found in {path}: {old[:120]!r}")
    file.write_text(text.replace(old, new, 1), encoding="utf-8")


def main() -> None:
    replace_once(
        "what_changed.md",
        "- **Current phase:** Phase 29 — cross-platform timestamp and release-evidence integrity hardening complete; permanent CI is green at 232 tests with 105 Dart files formatter-clean, analyzer-clean Flutter 3.47.0 / Dart 3.13.0, UTC-normalized persisted/portable timestamps, explicit-offset release evidence enforcement, and a fail-closed 0/13 stable qualification boundary; AGP issue #10 and repository-protection issue #12 remain explicit\n- **Latest accepted Version 1.5 native-matrix source:** `439a4441ebd2b36c4e1b6e0700d6f3d3359bd016` — `fix: normalize daily record timestamps to utc`\n- **Permanent Version 1.5 CI evidence:** run `32016750775`, job `95347802636` — SUCCESS, 232/232 tests, 105 files formatter-clean, analyzer clean, Flutter 3.47.0 / Dart 3.13.0, candidate gate passed, strict stable gate correctly closed at 0/13 manual evidence, solver smoke passed, WASM dry run passed, Web release passed",
        "- **Current phase:** Phase 29 — cross-platform timestamp and release-evidence integrity hardening complete and final Version 1.5 release-candidate source audit complete; permanent CI is green at 235 tests with 106 Dart files formatter-clean, analyzer-clean Flutter 3.47.0 / Dart 3.13.0, UTC-normalized persisted/portable timestamps, explicit-offset release evidence enforcement, current-state drift regressions, and a fail-closed 0/13 stable qualification boundary; AGP issue #10 and repository-protection issue #12 remain explicit\n- **Latest accepted Version 1.5 native-matrix source:** `439a4441ebd2b36c4e1b6e0700d6f3d3359bd016` — `fix: normalize daily record timestamps to utc`\n- **Permanent Version 1.5 CI evidence:** final audit source `657cfb986090a15429ebb38ddf8196b02095f9e4`, run `32018055661`, job `95351676619` — SUCCESS, 235/235 tests, 106 files formatter-clean, analyzer clean, Flutter 3.47.0 / Dart 3.13.0, candidate gate passed, strict stable gate correctly closed at 0/13 manual evidence, solver smoke passed, WASM dry run passed, Web release passed",
    )

    verification_path = Path("docs/VERIFICATION.md")
    verification = verification_path.read_text(encoding="utf-8")
    final_record = """## Final Version 1.5 release-candidate verification

Date: **2026-08-17**

```text
Final audit source: 657cfb986090a15429ebb38ddf8196b02095f9e4
CI run: 32018055661
CI job: 95351676619
Result: SUCCESS
Runner: 2.336.0 / Ubuntu 24.04.4 LTS
Flutter: 3.47.0 stable
Dart: 3.13.0
Formatting: PASS — 106 files, 0 changed
Static analysis: PASS — No issues found
Tests: PASS — 235/235
Candidate readiness: PASS — candidateGatePassed=true; readyForStable=false; 0/13 manual evidence complete
Stable promotion boundary: PASS — strict stable mode correctly remained closed
Solver smoke benchmark: PASS
WASM dry run: PASS
Web release: PASS — build/web
```

This run verifies the finalized Phase 29 tree together with the permanent current-release-state drift regressions. The Phase 29 232-test record below remains historical evidence for the timestamp-hardening source before the three final state-consistency tests were added.

"""
    if "## Final Version 1.5 release-candidate verification" not in verification:
        anchor = "## Phase 29 — Cross-platform timestamp and release-evidence integrity hardening\n"
        if anchor not in verification:
            raise SystemExit("Phase 29 verification anchor not found")
        verification_path.write_text(
            verification.replace(anchor, final_record + anchor, 1),
            encoding="utf-8",
        )

    replace_once(
        "ROADMAP.md",
        "Phase 29 current maintained CI is 232/232 tests with 105 Dart files formatter-clean, UTC-normalized portable timestamps, and explicit-offset release-evidence validation.",
        "Final Version 1.5 candidate CI is 235/235 tests with 106 Dart files formatter-clean; Phase 29 UTC-normalized portable timestamps, explicit-offset release-evidence validation, and current-state drift regressions are all covered.",
    )

    replace_once(
        "CHANGELOG.md",
        "- Maintained CI now passes 232/232 tests, 105-file formatting, metadata drift checks, release gates, solver smoke, and a warning-enforced Web build after Phase 29 timestamp/release-evidence hardening.",
        "- Final Version 1.5 candidate CI passes 235/235 tests, 106-file formatting, metadata drift checks, release gates, solver smoke, current-state drift regressions, and a warning-enforced Web build after Phase 29 timestamp/release-evidence hardening.",
    )

    audit_path = Path("docs/FINAL_RELEASE_CANDIDATE_AUDIT.md")
    audit = audit_path.read_text(encoding="utf-8")
    post_final = """## Post-finalization permanent CI

Final audit source:

`657cfb986090a15429ebb38ddf8196b02095f9e4` — `docs: record final Version 1.5 source audit`

Permanent CI run `32018055661`, job `95351676619`: **SUCCESS**.

- Flutter **3.47.0 stable** / Dart **3.13.0**;
- **106** Dart files formatter-clean;
- analyzer: **No issues found**;
- **235/235 tests passed**, including all three `current_release_state_test.dart` drift checks;
- candidate release gate: **passed**;
- strict stable gate: correctly remained **closed** with **0/13** manual checks;
- deterministic solver smoke benchmark: **passed**;
- WASM dry run: **passed**;
- Web release build: **passed**.

This supersedes the 232-test Phase 29 CI count only for the current finalized candidate tree; the earlier run remains valid historical evidence for the timestamp-hardening source itself.

"""
    if "## Post-finalization permanent CI" not in audit:
        anchor = "## Final source audit\n"
        if anchor not in audit:
            raise SystemExit("Final source audit anchor not found")
        audit_path.write_text(audit.replace(anchor, post_final + anchor, 1), encoding="utf-8")

    test_path = Path("test/current_release_state_test.dart")
    test = test_path.read_text(encoding="utf-8")
    test = test.replace("232/232 tests", "235/235 tests")
    test = test.replace("105 files formatter-clean", "106 files formatter-clean")
    test = test.replace("32016750775", "32018055661")
    test = test.replace("Tests: PASS — 232/232", "Tests: PASS — 235/235")
    test = test.replace(
        "Phase 29 current maintained CI is 232/232 tests",
        "Final Version 1.5 candidate CI is 235/235 tests",
    )
    test = test.replace(
        "Maintained CI now passes 232/232 tests",
        "Final Version 1.5 candidate CI passes 235/235 tests",
    )
    if "235/235 tests" not in test or "32018055661" not in test:
        raise SystemExit("Failed to promote final current-release-state test expectations")
    test_path.write_text(test, encoding="utf-8")


if __name__ == "__main__":
    main()
