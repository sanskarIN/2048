from pathlib import Path
import re
import subprocess


def commit(message: str, *paths: str) -> None:
    subprocess.run(["git", "add", *paths], check=True)
    subprocess.run(["git", "commit", "-m", message], check=True)


def replace_once(text: str, old: str, new: str, label: str) -> str:
    if old not in text:
        raise RuntimeError(f"Expected {label} marker was not found")
    return text.replace(old, new, 1)


# README
path = Path("README.md")
text = path.read_text()
old = (
    "The repository is currently on the **`0.9.0+1` release-candidate line**. "
    "Automated quality and native build evidence is documented, while physical-device, "
    "real screen-reader, signing/provisioning, long-session, and store-release qualification "
    "remain explicit manual boundaries before a stable 1.0.0 claim."
)
new = old + (
    "\n\nRelease promotion is now fail-closed: `dart run tool/release_readiness.dart` "
    "validates candidate metadata and the evidence manifest, while "
    "`dart run tool/release_readiness.dart --stable` refuses promotion until the package "
    "is actually `1.0.0`, the changelog has a stable release section, and every required "
    "real-world qualification item has recorded passed evidence. See "
    "[`docs/RELEASE_QUALIFICATION.md`](docs/RELEASE_QUALIFICATION.md)."
)
text = replace_once(text, old, new, "README release-candidate paragraph")
text = replace_once(
    text,
    "| Release qualification | [`docs/RELEASE_CHECKLIST.md`](docs/RELEASE_CHECKLIST.md) |",
    "| Release qualification gate | [`docs/RELEASE_QUALIFICATION.md`](docs/RELEASE_QUALIFICATION.md) |\n"
    "| Release checklist | [`docs/RELEASE_CHECKLIST.md`](docs/RELEASE_CHECKLIST.md) |",
    "README release qualification table row",
)
path.write_text(text)
commit("docs: expose fail-closed release qualification", "README.md")

# Documentation index
path = Path("docs/README.md")
text = path.read_text()
anchor = (
    "| [`RELEASE_CHECKLIST.md`](RELEASE_CHECKLIST.md) | Automated and manual qualification "
    "checklist before stable release. |"
)
text = replace_once(
    text,
    anchor,
    "| [`RELEASE_QUALIFICATION.md`](RELEASE_QUALIFICATION.md) | Evidence manifest, candidate/stable "
    "readiness commands, fail-closed promotion rules, and stable-release sequence. |\n" + anchor,
    "documentation index release checklist row",
)
source_anchor = "- **Automated quality gates:** `.github/workflows/`."
text = replace_once(
    text,
    source_anchor,
    source_anchor
    + "\n- **Stable-release evidence gate:** `tool/release_readiness.dart` plus "
    "`release_qualification.json`; human procedure is `RELEASE_QUALIFICATION.md`.",
    "documentation index quality source line",
)
path.write_text(text)
commit("docs: index release readiness evidence gate", "docs/README.md")

# CI/CD and release checklist
path = Path("docs/CI_CD.md")
text = path.read_text()
text = replace_once(
    text,
    "`ci.yml` | Format verification, analyzer, test suite with coverage, and Web release build.",
    "`ci.yml` | Format verification for application/tests/tools, analyzer, test suite with coverage, "
    "release-readiness gates, deterministic solver smoke benchmark, and Web release build.",
    "CI workflow summary",
)
old_commands = (
    "flutter --version\n"
    "flutter pub get\n"
    "dart format --output=none --set-exit-if-changed lib test\n"
    "flutter analyze\n"
    "flutter test --coverage\n"
    "flutter build web --release"
)
new_commands = (
    "flutter --version\n"
    "flutter pub get\n"
    "dart format --output=none --set-exit-if-changed lib test tool\n"
    "flutter analyze\n"
    "flutter test --coverage\n"
    "dart run tool/release_readiness.dart --json\n"
    "# CI also verifies that --stable fails closed while the package is 0.9.x\n"
    "dart run tool/solver_benchmark.dart 8\n"
    "flutter build web --release"
)
text = replace_once(text, old_commands, new_commands, "CI command block")
text = replace_once(
    text,
    "It runs on relevant `main` changes to `lib/`, `test/`, or the workflow itself and can be manually dispatched.",
    "It runs on relevant `main` changes to `lib/`, `test/`, `tool/`, or the workflow itself and can be manually dispatched.",
    "formatter scope sentence",
)
text = replace_once(
    text,
    "4. runs `dart format lib test`;",
    "4. runs `dart format lib test tool`;",
    "formatter command",
)
phase = """

## Phase 22 release-promotion gate

Phase 22 adds an evidence-backed release boundary without pretending that hosted automation performs physical-device or assistive-technology qualification. `tool/release_readiness.dart` validates required release files, package/candidate version consistency, the exact manual-check ID set, allowed statuses, evidence/timestamp requirements, changelog/roadmap boundaries, and stable metadata. Candidate mode is CI-safe while required manual checks remain pending; strict `--stable` mode fails until all stable conditions are genuinely satisfied.

Accepted Phase 22 CI evidence:

```text
Source commit: 86aaddeb6cfcbfef45c86889060ec5313fdbab31
CI run: 31932018261
CI job: 95128223530
Runner: Ubuntu 24.04
Flutter: 3.47.0 stable
Dart: 3.13.0
Formatting: PASS — 96 files, 0 changed
Analyzer: PASS — No issues found
Tests: PASS — 194/194
Candidate readiness: PASS — candidateGatePassed=true; readyForStable=false; 0/13 manual evidence complete
Stable-boundary assertion: PASS — strict stable mode correctly refused 0.9.0+1
Solver smoke benchmark: PASS — Heuristic and Expectimax, four deterministic seeds, eight moves each
Web release: PASS — build/web
WASM dry run: PASS
```

The same run intentionally proves both sides of the boundary: the release candidate is structurally valid, and a stable release is not yet qualified. Native runtime code did not change in Phase 22, so the latest accepted native compilation evidence remains the Phase 21 matrix; real-device/manual checks remain outstanding in the evidence manifest and release checklist.
"""
if "## Phase 22 release-promotion gate" not in text:
    text += phase
path.write_text(text)

path = Path("docs/RELEASE_CHECKLIST.md")
text = path.read_text()
intro = "Current objective evidence is recorded in `docs/VERIFICATION.md` and `what_changed.md`."
text = replace_once(
    text,
    intro,
    intro
    + " The machine-readable manual evidence state is `docs/release_qualification.json`; the exact "
    "promotion procedure and fail-closed commands are in "
    "[`RELEASE_QUALIFICATION.md`](RELEASE_QUALIFICATION.md).",
    "release checklist evidence intro",
)
text = replace_once(
    text,
    "- [x] `dart format --output=none --set-exit-if-changed lib test`",
    "- [x] `dart format --output=none --set-exit-if-changed lib test tool`",
    "release checklist formatting item",
)
marker = "- [x] `flutter test --coverage`"
text = replace_once(
    text,
    marker,
    marker
    + "\n- [x] `dart run tool/release_readiness.dart --json` validates candidate metadata/manifest structure"
    + "\n- [x] Permanent CI proves strict `--stable` remains fail-closed while the package is `0.9.x`"
    + "\n- [x] `dart run tool/solver_benchmark.dart 8` smoke-runs both deterministic Auto Play strategies",
    "release checklist test marker",
)
stable_marker = "- [ ] Promote version/tag to `1.0.0` only after the stable-release criteria are satisfied"
text = replace_once(
    text,
    stable_marker,
    "- [ ] `dart run tool/release_readiness.dart --stable` exits successfully on the exact release commit\n"
    + stable_marker,
    "stable promotion checklist marker",
)
path.write_text(text)
commit(
    "docs: align CI and stable release checklist",
    "docs/CI_CD.md",
    "docs/RELEASE_CHECKLIST.md",
)

# Changelog
path = Path("CHANGELOG.md")
text = path.read_text()
text = replace_once(
    text,
    "### Added\n",
    "### Added\n"
    "- Evidence-backed release qualification with `docs/release_qualification.json`, covering the exact 13 real-device/accessibility/handler/branding/distribution checks that must be completed before stable promotion.\n"
    "- `tool/release_readiness.dart` candidate/stable CLI with JSON output, required-file/version/manifest validation, evidence/timestamp enforcement, and a fail-closed `--stable` mode.\n"
    "- Dedicated `docs/RELEASE_QUALIFICATION.md` procedure for recording verifiable manual evidence and promoting the exact qualified commit.\n",
    "CHANGELOG Added section",
)
text = replace_once(
    text,
    "### Changed\n",
    "### Changed\n"
    "- Permanent CI now formats `tool/`, validates release-candidate metadata, proves the stable gate remains closed on the `0.9.x` line, smoke-runs both deterministic solver strategies, and then produces the Web release build.\n"
    "- Formatter automation now covers `lib/`, `test/`, and `tool/` so maintenance CLIs cannot drift outside canonical Dart formatting.\n"
    "- Stable `1.0.0` promotion criteria are machine-enforced instead of depending only on prose checklists; pending real-world checks remain explicit rather than being fabricated from hosted automation.\n",
    "CHANGELOG Changed section",
)
path.write_text(text)
commit("docs: record release qualification infrastructure", "CHANGELOG.md")

# Verification record
path = Path("docs/VERIFICATION.md")
text = path.read_text()
intro = (
    "This document records objective automated evidence for the current 2048 Nova release-candidate line. "
    "It distinguishes formatter/analyzer/test/Web verification, native compilation evidence, transparent "
    "intermediate failures, and manual release boundaries.\n"
)
section = """

## Phase 22 — Evidence-backed stable-release promotion gate

Date: **2026-08-16**

Accepted maintained CI source:

```text
Commit: 86aaddeb6cfcbfef45c86889060ec5313fdbab31
CI run: 31932018261
CI job: 95128223530
Result: SUCCESS
Runner: Ubuntu 24.04
Flutter: 3.47.0 stable
Dart: 3.13.0
DevTools: 2.60.0
Formatting: PASS — 96 files, 0 changed
Static analysis: PASS — No issues found
Tests: PASS — 194/194
Candidate readiness: PASS
Stable promotion boundary: PASS — strict stable mode correctly rejected the current RC
Solver smoke benchmark: PASS — Heuristic + Expectimax, seeds 2048/4096/8192/20260815, 8 moves each
Web release: PASS — build/web
WASM dry run: PASS
```

Candidate-gate output on the accepted source reported `candidateGatePassed=true`, `readyForStable=false`, and **0/13** required manual evidence items passed. The CI then deliberately invoked strict stable mode and required it to fail; it correctly rejected version `0.9.0+1`, the absence of a `[1.0.0]` changelog section, and every still-pending manual evidence item. The workflow treats that expected refusal as a passing assertion, so a future accidental weakening of the boundary fails CI.

Phase 22 changes release engineering and documentation only; it does not alter Flutter gameplay/runtime behavior. Therefore the latest native runtime build evidence remains the Phase 21 Android/Linux/Windows/macOS/unsigned-iOS matrix. Physical-device, real screen-reader, external-handler, native-branding, signing/provisioning, and store metadata checks remain unqualified until genuine evidence is recorded in `release_qualification.json`.
"""
if intro not in text:
    raise RuntimeError("Verification intro not found")
if "## Phase 22 — Evidence-backed stable-release promotion gate" not in text:
    text = text.replace(intro, intro + section, 1)
path.write_text(text)
commit("docs: record Phase 22 CI evidence", "docs/VERIFICATION.md")

# Continuity log
path = Path("what_changed.md")
text = path.read_text()
text, count = re.subn(
    r"- \*\*Current phase:\*\*.*",
    "- **Current phase:** Phase 22 — evidence-backed release qualification and fail-closed stable promotion gate complete; manual/device qualification remains before 1.0.0",
    text,
    count=1,
)
if count != 1:
    raise RuntimeError("what_changed current phase line not found")
section = """

---

## 2026-08-16 — Phase 22: Evidence-backed release qualification and fail-closed stable promotion

Phase 22 continued from the Phase 21 release-candidate state without pretending that hosted automation can perform physical-device, assistive-technology, external-handler, signing, or store qualification. The repository already had a mature gameplay/runtime feature set, so this phase hardened the transition from `0.9.x` to a future stable `1.0.0`.

### Implemented release evidence model

Added `docs/release_qualification.json` with schema version 1 and exactly 13 required real-world qualification IDs: `android-device`, `ios-device`, `input-responsive`, `assistive-tech`, `long-session`, `autoplay-real-target`, `challenge-code-real-target`, `move-replay-real-target`, `full-replay-real-target`, `backup-real-target`, `external-handlers`, `native-branding`, and `distribution-metadata`. Every item begins `pending` with no invented evidence. Passed items require non-empty evidence and a valid ISO-8601 timestamp.

### Implemented release readiness CLI

`tool/release_readiness.dart` now validates required release/support/security/CI/continuity files, package/candidate version consistency, manifest JSON/schema, the exact manual-check ID set, allowed statuses, passed-evidence/timestamp completeness, the `[Unreleased]` changelog boundary, and the explicit ROADMAP pre-1.0 boundary. Candidate mode remains usable while qualification is pending; strict `--stable` requires real `1.0.0` metadata and complete passed evidence.

### Permanent CI hardening

The permanent CI gate now formats `lib test tool`, runs analyzer and all tests, validates candidate readiness, asserts that the current RC cannot pass strict stable mode, smoke-runs both deterministic solver strategies, and builds Web. Formatter automation now also owns `tool/**` and correctly produced the canonical-format commit `aa8d3d639d681f7e3972fba020b797d04bab15dc` for the new CLI.

### Phase 22 implementation commits before final documentation

```text
372c4c2377d55eddd6023aeab7d14acfdeb5882c  chore: add release qualification evidence manifest
fff686994ae708ca6022948b21cae95311165fd4  feat: add release readiness gate
8e531d358fd7d6ea8b1cee778ef19ecfa2310b46  ci: enforce release readiness and tool quality
3431724cf66a583b51a89f3e035ab1cd7df3bcef  docs: add evidence-backed release qualification guide
dc905663a0e7ebf1505b0595d70b8a1265b7b1f9  ci: include tool sources in formatter automation
aa8d3d639d681f7e3972fba020b797d04bab15dc  style: format Dart sources tests and tools
593f037c6dfcce2dc2bc2b2eabd2cb95c1189ed5  docs: add machine-enforced stable release boundary
86aaddeb6cfcbfef45c86889060ec5313fdbab31  ci: verify release promotion boundary fails closed
```

### Accepted automated verification

Permanent CI run `31932018261`, job `95128223530`, verified source `86aaddeb6cfcbfef45c86889060ec5313fdbab31` on Ubuntu 24.04 with Flutter 3.47.0, Dart 3.13.0, and DevTools 2.60.0.

```text
Formatting: PASS — 96 files, 0 changed
Static analysis: PASS — No issues found
Automated tests: PASS — 194/194
Candidate release gate: PASS — candidateGatePassed=true; readyForStable=false; 0/13 evidence items passed
Stable boundary assertion: PASS — strict --stable correctly rejected 0.9.0+1, missing [1.0.0] changelog metadata, and all 13 pending evidence items
Solver benchmark smoke: PASS — Heuristic + Expectimax; seeds 2048, 4096, 8192, 20260815; move budget 8 each
Web release: PASS — build/web
Web WASM dry run: PASS
```

The existing non-fatal Cupertino icon-font warning remained visible during Web compilation; the Web build completed successfully. No Flutter gameplay/runtime source changed in Phase 22, so the latest accepted native runtime matrix remains Phase 21 rather than being falsely relabeled.

### Transparent helper failure

Temporary documentation workflow run `31932187504` failed at workflow-definition validation before creating any job or modifying any project file. The cause was the first helper YAML embedding unindented multiline Python string contents inside a YAML block. It was replaced by a small valid workflow plus this repository-local temporary Python helper. This failure did not invalidate permanent CI run `31932018261` and is retained here rather than hidden.

### Documentation synchronized

README, documentation index, CI/CD guide, release checklist, changelog, roadmap, verification record, dedicated release qualification guide, and this continuity log now describe one consistent path from release candidate to stable release.

### Remaining stable-release boundary

The project is intentionally **not** marked `1.0.0`. All 13 real-world evidence items remain pending until actually performed. The stable gate prevents missing manual checks from being silently converted into a stable-release claim by a version edit alone.
"""
if "## 2026-08-16 — Phase 22: Evidence-backed release qualification" not in text:
    text += section
path.write_text(text)
commit("docs: record complete Phase 22 implementation log", "what_changed.md")

# Clean up both temporary helpers in a final logical commit.
Path(".github/workflows/phase22-docs.yml").unlink()
Path("tool/phase22_docs.py").unlink()
subprocess.run(
    ["git", "add", "-u", ".github/workflows/phase22-docs.yml", "tool/phase22_docs.py"],
    check=True,
)
subprocess.run(
    ["git", "commit", "-m", "chore: remove Phase 22 documentation helpers"],
    check=True,
)
