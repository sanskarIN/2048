from pathlib import Path
import subprocess


def commit(message: str, *paths: str) -> None:
    subprocess.run(["git", "add", *paths], check=True)
    subprocess.run(["git", "commit", "-m", message], check=True)


def append_once(path: str, marker: str, section: str, message: str) -> None:
    file = Path(path)
    text = file.read_text()
    if marker not in text:
        text = text.rstrip() + "\n\n" + section.strip() + "\n"
        file.write_text(text)
        commit(message, path)


def replace_once(path: str, old: str, new: str, message: str) -> None:
    file = Path(path)
    text = file.read_text()
    if new in text:
        return
    if old not in text:
        raise RuntimeError(f"Expected marker not found in {path}: {old[:80]}")
    file.write_text(text.replace(old, new, 1))
    commit(message, path)


# Documentation index: expose the focused gate-regression guide.
path = Path("docs/README.md")
text = path.read_text()
row = "| [`RELEASE_GATE_TESTING.md`](RELEASE_GATE_TESTING.md) | Process-level fixture coverage for candidate/stable release-gate acceptance and rejection paths. |"
if row not in text:
    anchor = "| [`RELEASE_QUALIFICATION.md`](RELEASE_QUALIFICATION.md) | Evidence manifest, candidate/stable readiness commands, fail-closed promotion rules, and stable-release sequence. |"
    if anchor not in text:
        raise RuntimeError("Release qualification row missing from docs index")
    path.write_text(text.replace(anchor, anchor + "\n" + row, 1))
    commit("docs: index release gate regression coverage", "docs/README.md")

# Dedicated release qualification guide.
append_once(
    "docs/RELEASE_QUALIFICATION.md",
    "## Automated gate regression fixtures",
    """
## Automated gate regression fixtures

The release gate itself is regression-tested through `test/release_readiness_cli_test.dart`. The maintenance CLI accepts `--root=<path>` so tests can construct isolated temporary repository fixtures without mutating the real checkout:

```bash
dart run tool/release_readiness.dart --root=<fixture-path> --json
```

The fixture option exists for testability only. It does not turn synthetic metadata into real release evidence. The suite exercises candidate success, complete stable success, stable refusal with pending evidence, package/manifest candidate mismatch, false `passed` entries without evidence/timestamps, and missing required qualification IDs. See [`RELEASE_GATE_TESTING.md`](RELEASE_GATE_TESTING.md).

Current accepted source `57c6312ee26eed0cea8597ebf6417d442cf988cc` passed permanent CI run `31932367464` with **200/200 tests**. The live candidate still reports **0/13** real-world qualification items complete, so strict stable mode correctly remains closed.
""",
    "docs: connect qualification guide to gate regressions",
)

# Testing strategy current-source evidence.
append_once(
    "docs/TESTING.md",
    "## Phase 22 — Release-gate regression evidence",
    """
## Phase 22 — Release-gate regression evidence

Phase 22 adds six process/filesystem integration cases in `test/release_readiness_cli_test.dart` to the previous 194-test suite, bringing the current maintained suite to **200 tests**. These cases launch the real Dart CLI against isolated temporary repository roots rather than mocking release-file parsing.

Covered release-gate scenarios:

- valid `0.9.0+1` candidate metadata passes candidate mode while remaining not ready for stable promotion;
- complete `1.0.0+1` metadata plus all 13 passed evidence records succeeds in strict stable mode;
- stable metadata with pending manual evidence fails closed;
- manifest/package candidate mismatch is rejected;
- a check falsely marked `passed` without evidence/timestamp is rejected;
- omission of a required manual-check ID is rejected.

Accepted maintained gate:

```text
Workflow: CI
Run: 31932367464
Job: 95129044532
Verified source: 57c6312ee26eed0cea8597ebf6417d442cf988cc
Runner: Ubuntu 24.04.4 LTS
Flutter: 3.47.0 stable
Dart: 3.13.0
DevTools: 2.60.0
Formatting: PASS — 97 files, 0 changed
Static analysis: PASS — No issues found
Tests: PASS — 200/200
Candidate readiness: PASS — candidateGatePassed=true; readyForStable=false; 0/13 manual evidence complete
Stable-boundary assertion: PASS — strict stable mode correctly refused current 0.9.0+1 state
Solver smoke benchmark: PASS — Heuristic + Expectimax across four deterministic seeds, 8 moves each
Web release build: PASS — build/web
WASM dry run: PASS
Overall: SUCCESS
```

The Web compiler retained the known non-fatal Cupertino icon-font warning while still producing `build/web`. These fixture tests verify release-gate behavior; they do not substitute for physical-device, assistive-technology, real-handler, signing/provisioning, branding, or distribution qualification.
""",
    "docs: record 200-test Phase 22 gate evidence",
)

# CI/CD superseding evidence.
append_once(
    "docs/CI_CD.md",
    "## Phase 22 gate regression expansion — current evidence",
    """
## Phase 22 gate regression expansion — current evidence

The fixture-testable release gate supersedes the earlier 194-test Phase 22 automation count without changing Flutter gameplay/runtime code. The permanent CI source below contains `--root=<path>` test support, all six CLI regression cases, and the focused regression-testing documentation.

```text
Source commit: 57c6312ee26eed0cea8597ebf6417d442cf988cc
CI run: 31932367464
CI job: 95129044532
Runner: Ubuntu 24.04.4 LTS
Flutter: 3.47.0 stable
Dart: 3.13.0
DevTools: 2.60.0
Formatting: PASS — 97 files, 0 changed
Analyzer: PASS — No issues found
Tests: PASS — 200/200
Candidate readiness: PASS — 0/13 real-world evidence complete; readyForStable=false
Stable boundary: PASS — strict stable mode refused the current RC as required
Solver smoke: PASS
Web release: PASS — build/web
WASM dry run: PASS
```

The accepted native runtime build matrix remains Phase 21 because Phase 22 changes release tooling/tests/documentation, not application runtime behavior.
""",
    "docs: supersede Phase 22 CI evidence with 200 tests",
)

# Release checklist adds a permanent automated gate-testing item.
append_once(
    "docs/RELEASE_CHECKLIST.md",
    "## Release-gate regression safety",
    """
## Release-gate regression safety

- [x] Candidate-mode success path is exercised through the real CLI against an isolated fixture repository.
- [x] Strict stable-mode success path is exercised with synthetic complete `1.0.0` metadata and all 13 evidence records.
- [x] Strict stable mode is verified to fail when real-world evidence remains pending.
- [x] Candidate/package mismatch is rejected.
- [x] False `passed` evidence without a timestamp/evidence body is rejected.
- [x] Missing required qualification IDs are rejected.
- [x] Current maintained CI passes **200/200 tests** on source `57c6312ee26eed0cea8597ebf6417d442cf988cc` (run `31932367464`).

These checked items validate the release gate itself. They do not mark any of the 13 manual qualification entries as complete.
""",
    "docs: add release gate regression checklist",
)

# Verification record: put the superseding Phase 22 evidence before the original Phase 22 section.
path = Path("docs/VERIFICATION.md")
text = path.read_text()
heading = "## Phase 22 — Release-gate regression expansion (current automated source)"
if heading not in text:
    anchor = "## Phase 22 — Evidence-backed stable-release promotion gate"
    if anchor not in text:
        raise RuntimeError("Phase 22 verification anchor missing")
    section = """## Phase 22 — Release-gate regression expansion (current automated source)

Date: **2026-08-16**

The release-readiness CLI now supports isolated fixture roots and is protected by six process-level regression tests. This is the current automated source for Phase 22 and supersedes the earlier 194-test count while preserving that earlier run as historical implementation evidence.

```text
Commit: 57c6312ee26eed0cea8597ebf6417d442cf988cc
CI run: 31932367464
CI job: 95129044532
Result: SUCCESS
Runner: Ubuntu 24.04.4 LTS
Flutter: 3.47.0 stable
Dart: 3.13.0
DevTools: 2.60.0
Formatting: PASS — 97 files, 0 changed
Static analysis: PASS — No issues found
Tests: PASS — 200/200
Release-gate fixture cases: PASS — 6/6
Candidate readiness: PASS — candidateGatePassed=true; readyForStable=false; manualChecksPassed=0/13
Stable promotion boundary: PASS — strict stable mode correctly rejected the live 0.9.0+1 RC
Solver benchmark smoke: PASS — both strategies, four deterministic seeds, eight moves each
Web release: PASS — build/web
WASM dry run: PASS
```

The six new cases prove both acceptance and rejection branches: candidate success, fully qualified synthetic stable success, pending-evidence refusal, version mismatch refusal, evidence-completeness refusal, and missing-ID refusal. Synthetic stable success demonstrates that the gate can open when its declared conditions are satisfied; it is not evidence that the real project has completed those conditions.

The live manifest remains at **0/13** completed manual checks. No physical-device, screen-reader, external-handler, branding, signing/provisioning, or store qualification is inferred from this CI run. The Phase 21 native runtime matrix remains the latest native evidence because no Flutter gameplay/runtime code changed here.

"""
    path.write_text(text.replace(anchor, section + anchor, 1))
    commit("docs: record current Phase 22 verification evidence", "docs/VERIFICATION.md")

# Dedicated test guide: replace prospective wording with accepted evidence.
path = Path("docs/RELEASE_GATE_TESTING.md")
text = path.read_text()
old = "The accepted CI run for this regression expansion is recorded in `docs/VERIFICATION.md` and `what_changed.md` after the permanent CI workflow completes successfully. Historical Phase 22 evidence remains valid for the earlier gate implementation, but the newer run supersedes its automated test count for the current source state."
new = """Accepted current-source evidence:

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

Historical Phase 22 evidence remains valid for the first gate implementation, while this run supersedes its automated test count for the current source state. Full details are also recorded in `docs/VERIFICATION.md` and `what_changed.md`."""
if old in text and new not in text:
    path.write_text(text.replace(old, new, 1))
    commit("docs: finalize release gate regression evidence", "docs/RELEASE_GATE_TESTING.md")

# Changelog: current Unreleased release-engineering additions.
path = Path("CHANGELOG.md")
text = path.read_text()
added_bullet = "- Process-level release-gate regression coverage with six temporary-repository fixtures spanning candidate success, stable success, pending-evidence refusal, candidate mismatch, incomplete passed evidence, and missing required IDs."
changed_bullet = "- `tool/release_readiness.dart` now accepts `--root=<path>` for isolated regression fixtures, while normal repository-root behavior and the real 13-item qualification boundary remain unchanged."
changed_bullet2 = "- Current maintained CI evidence now passes 200/200 tests and 97-file formatting on the fixture-tested release-gate source."
changed = False
if added_bullet not in text:
    marker = "### Added\n"
    if marker not in text:
        raise RuntimeError("CHANGELOG Added marker missing")
    text = text.replace(marker, marker + added_bullet + "\n", 1)
    changed = True
if changed_bullet not in text or changed_bullet2 not in text:
    marker = "### Changed\n"
    if marker not in text:
        raise RuntimeError("CHANGELOG Changed marker missing")
    insertion = ""
    if changed_bullet not in text:
        insertion += changed_bullet + "\n"
    if changed_bullet2 not in text:
        insertion += changed_bullet2 + "\n"
    text = text.replace(marker, marker + insertion, 1)
    changed = True
if changed:
    path.write_text(text)
    commit("docs: record release gate regression expansion", "CHANGELOG.md")

# Roadmap: mark process-level gate testing complete without changing manual status.
path = Path("ROADMAP.md")
text = path.read_text()
bullet = "- Release-readiness CLI regression fixtures now exercise both opening and fail-closed branches end to end, including a fully qualified synthetic stable fixture plus malformed/incomplete evidence rejection; maintained CI is 200/200 tests."
if bullet not in text:
    anchor = "- Permanent CI now formats `tool/` together with application/tests, runs the release-candidate readiness gate, and smoke-runs the deterministic solver benchmark in addition to the existing analyzer/tests/Web release build."
    if anchor not in text:
        raise RuntimeError("ROADMAP Phase 22 CI bullet missing")
    path.write_text(text.replace(anchor, anchor + "\n" + bullet, 1))
    commit("docs: mark release gate regression hardening complete", "ROADMAP.md")

# README: link the focused regression document next to release qualification docs.
path = Path("README.md")
text = path.read_text()
row = "| Release gate regression testing | [`docs/RELEASE_GATE_TESTING.md`](docs/RELEASE_GATE_TESTING.md) |"
if row not in text:
    anchor = "| Release qualification gate | [`docs/RELEASE_QUALIFICATION.md`](docs/RELEASE_QUALIFICATION.md) |"
    if anchor not in text:
        raise RuntimeError("README release qualification row missing")
    path.write_text(text.replace(anchor, anchor + "\n" + row, 1))
    commit("docs: link release gate regression evidence", "README.md")

# Continuity record required by the project workflow.
path = Path("what_changed.md")
text = path.read_text()
section_heading = "## 2026-08-16 — Phase 22 regression expansion: fixture-tested stable-release gate"
if section_heading not in text:
    phase_line = "- **Current phase:** Phase 22 — evidence-backed release qualification and fail-closed stable promotion gate complete; manual/device qualification remains before 1.0.0"
    replacement = "- **Current phase:** Phase 22 — evidence-backed release qualification plus 200-test release-gate regression hardening complete; manual/device qualification remains before 1.0.0"
    if phase_line in text:
        text = text.replace(phase_line, replacement, 1)
    section = """

---

## 2026-08-16 — Phase 22 regression expansion: fixture-tested stable-release gate

After the initial fail-closed gate was accepted at 194 tests, the gate itself was hardened with real process/filesystem regression fixtures instead of relying only on the live release-candidate invocation.

### Code and test commits

```text
9fe63472a59d4af77c92ef3da6232c96960c3134  feat: make release readiness gate fixture-testable
8b8ba77a8afbf90d93f8d05170435dce4140f309  test: cover release readiness promotion boundaries
28a48c0e7c7d99c4407d6e86b8ac8ed122188fc8  style: format Dart sources tests and tools
57c6312ee26eed0cea8597ebf6417d442cf988cc  docs: document release gate regression fixtures
```

`tool/release_readiness.dart` gained `--root=<path>` so automated tests can point the actual CLI at temporary repository fixtures. Normal invocation still validates the real checkout. JSON output now also reports the resolved root, and duplicate/nonexistent fixture-root errors fail closed.

`test/release_readiness_cli_test.dart` adds six end-to-end scenarios:

1. valid 0.9.0+1 candidate succeeds while stable readiness remains false;
2. complete 1.0.0+1 fixture with all 13 passed evidence records succeeds in strict stable mode;
3. stable metadata with pending evidence is refused;
4. manifest/package candidate mismatch is refused;
5. `passed` status without evidence/timestamp is refused;
6. a missing required manual-check ID is refused.

The stable-success fixture is intentionally synthetic. It proves the gate is capable of opening when every declared condition is satisfied; it does not claim those real checks were performed.

### Accepted current-source automated verification

Permanent CI run `31932367464`, job `95129044532`, verified source `57c6312ee26eed0cea8597ebf6417d442cf988cc`.

```text
Runner: Ubuntu 24.04.4 LTS
Flutter: 3.47.0 stable
Dart: 3.13.0
DevTools: 2.60.0
Formatting: PASS — 97 files, 0 changed
Static analysis: PASS — No issues found
Tests: PASS — 200/200
Release-gate fixture scenarios: PASS — 6/6
Candidate gate: PASS — candidateGatePassed=true; readyForStable=false; 0/13 manual evidence complete
Stable boundary: PASS — strict --stable correctly rejected the live 0.9.0+1 candidate
Solver benchmark: PASS — Heuristic + Expectimax, seeds 2048/4096/8192/20260815, 8 moves each
WASM dry run: PASS
Web release: PASS — build/web
```

The Web build retained the existing non-fatal Cupertino icon-font warning but completed successfully. No Flutter gameplay/runtime source changed in this expansion, so Phase 21 remains the latest native runtime build evidence.

### Release status after regression expansion

The codeable release-engineering boundary is now tested in both directions. The real manifest remains **0/13**, and strict stable mode therefore remains intentionally closed. Physical Android/iOS, representative input/responsive behavior, real assistive technology, long sessions, Auto Play/Challenge Code/replay/backup on real targets, external handlers, native branding, signing/provisioning, privacy/store metadata, and distribution qualification must still be performed before changing the project to stable `1.0.0`.
"""
    text = text.rstrip() + section + "\n"
    path.write_text(text)
    commit("docs: record Phase 22 200-test continuity evidence", "what_changed.md")

# Temporary helpers must not remain on main.
workflow = Path(".github/workflows/phase22-regression-docs.yml")
script = Path(".github/scripts/phase22_regression_docs.py")
workflow.unlink(missing_ok=True)
script.unlink(missing_ok=True)
subprocess.run(
    ["git", "add", "-u", ".github/workflows/phase22-regression-docs.yml", ".github/scripts/phase22_regression_docs.py"],
    check=True,
)
subprocess.run(
    ["git", "commit", "-m", "chore: remove Phase 22 regression documentation helpers"],
    check=True,
)
