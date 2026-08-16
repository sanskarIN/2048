from pathlib import Path


def read(path: str) -> str:
    return Path(path).read_text(encoding="utf-8")


def write(path: str, text: str) -> None:
    Path(path).write_text(text, encoding="utf-8")


def replace_required(path: str, old: str, new: str, count: int = 1) -> None:
    text = read(path)
    if old not in text:
        raise SystemExit(f"Expected text not found in {path}: {old!r}")
    write(path, text.replace(old, new, count))


# Refresh the top-level continuity summary without rewriting historical phase records.
what_changed_path = "what_changed.md"
what_changed = read(what_changed_path)
what_changed = what_changed.replace(
    "## 2026-08-14 — 0.9.0 release-candidate implementation and verification",
    "## Current repository state — Version 1.5",
    1,
)
what_changed = what_changed.replace(
    "- **Version:** `0.9.0+1`",
    "- **Version:** `1.5.0+15`",
    1,
)
old_current_block = """- **Current phase:** Phase 23 — reproducible Flutter metadata, warning-free Web assets, generated-plugin integrity, and retained checksummed native qualification artifacts complete; 13 real-world checks remain before 1.0.0
- **Latest runtime/native integration commit used by Phase 23 native build verification:** `1d445c7b8291260e974a1d0132c9417f1132b48e` — `build: generate Flutter platform runners`
- **Latest release-pipeline commit used by retained native artifact verification:** `5b22795d5aba661bd587e7bcbf2ae6442c8b4b3a` — `ci: retain checksummed native qualification artifacts`
- **Latest test-fix commit used by the final quality gate:** `f3e7aaec6404139951425144cb1fb4d2fda66e27` — `test: scroll lazy mode list before asserting offscreen entries`
- **Latest documentation commit before this log refresh:** `3d5988f1a7a29d38dbd72602e2c489d5975c7b5b` — `docs: update changelog for release candidate verification`
"""
new_current_block = """- **Current phase:** Phase 24 — Version 1.5 current-line migration and release-contract hardening complete; permanent CI is green at 211 tests; the hosted Android/Linux/Windows/macOS/unsigned-iOS matrix is green; 13 real-world qualification checks remain before stable promotion
- **Latest Version 1.5 native-matrix source:** `4d4fe634624b069834786a2aaad356e356281c44` — `docs(android): clarify application id and qualification signing`
- **Permanent Version 1.5 CI evidence:** run `31940994228`, job `95150049412` — SUCCESS, 211/211 tests, analyzer clean, candidate gate passed, strict stable gate correctly closed, solver smoke passed, Web release passed
- **Version 1.5 native build evidence:** Platform Builds run `31940994252` — Android, Linux, Windows, macOS, and unsigned iOS jobs all SUCCESS with checksummed artifacts retained for 14 days
- **Manual qualification boundary:** `0/13` real-world evidence items are passed; no physical-device, assistive-technology, external-handler, long-session, signing/provisioning, or store-distribution evidence has been synthesized
"""
if old_current_block not in what_changed:
    raise SystemExit("Expected Phase 23 current-state block not found in what_changed.md")
what_changed = what_changed.replace(old_current_block, new_current_block, 1)

final_marker = "## Phase 24 final verification — Version 1.5 hosted quality and native matrix"
if final_marker not in what_changed:
    what_changed += """

---

## Phase 24 final verification — Version 1.5 hosted quality and native matrix

Date: **2026-08-16**

- Current package metadata: `1.5.0+15`; runtime marketing version: `1.5.0`.
- Permanent CI source `4d4fe634624b069834786a2aaad356e356281c44`, run `31940994228`, job `95150049412`: SUCCESS.
- CI evidence: Flutter 3.47.0 stable / Dart 3.13.0, formatter 98 files with 0 changes, analyzer `No issues found`, **211/211 tests passed**, Version 1.5 candidate gate passed, strict stable gate remained fail-closed, deterministic solver smoke passed, and Web release build completed without the missing Cupertino icon-font warning.
- Native Platform Builds run `31940994252`: Android job `95150049652`, Linux job `95150049660`, Windows job `95150049634`, and Apple job `95150049606` all SUCCESS.
- Five checksummed qualification artifacts were uploaded for Android, Linux x64, Windows x64, macOS, and unsigned iOS. Their GitHub artifact archive digests are recorded in `docs/RELEASE_ARTIFACTS.md`.
- Hosted compilation/package success is **not** physical-device or store-distribution qualification. `docs/release_qualification.json` remains intentionally at **0/13** passed real-world checks.
- Temporary Version 1.5 migration automation was removed after successful use; the repository retains only permanent release/CI tooling.
- Repository-writing automation for this phase explicitly uses `Sanskar <sanskarin@outlook.in>`.
"""
write(what_changed_path, what_changed)

# Prepend a Phase 24 current evidence section while keeping Phase 23 and older evidence historical.
verification_path = "docs/VERIFICATION.md"
verification = read(verification_path)
phase24_heading = "## Phase 24 — Version 1.5 current line and hosted native matrix"
if phase24_heading not in verification:
    marker = "## Phase 23 — Reproducible metadata, warning-free Web, and retained native artifacts"
    if marker not in verification:
        raise SystemExit("Phase 23 marker not found in docs/VERIFICATION.md")
    phase24 = """## Phase 24 — Version 1.5 current line and hosted native matrix

Date: **2026-08-16**

Current Version 1.5 package/runtime metadata:

```text
Package: 1.5.0+15
Marketing/runtime version: 1.5.0
```

Permanent quality source:

```text
Commit: 4d4fe634624b069834786a2aaad356e356281c44
CI run: 31940994228
CI job: 95150049412
Result: SUCCESS
Runner: Ubuntu 24.04.4 LTS
Flutter: 3.47.0 stable
Dart: 3.13.0
DevTools: 2.60.0
Flutter metadata drift: PASS
Formatting: PASS — 98 files, 0 changed
Static analysis: PASS — No issues found
Tests: PASS — 211/211
Candidate readiness: PASS — candidateGatePassed=true; readyForStable=false; 0/13 manual evidence complete
Stable promotion boundary: PASS — strict stable mode correctly remained closed with incomplete real-world evidence
Solver smoke benchmark: PASS
WASM dry run: PASS
Missing icon-font warning guard: PASS
Web release: PASS — build/web
```

Version 1.5 hosted native matrix:

```text
Commit: 4d4fe634624b069834786a2aaad356e356281c44
Platform Builds run: 31940994252
Android job 95150049652: SUCCESS
Linux job 95150049660: SUCCESS
Windows job 95150049634: SUCCESS
macOS + unsigned iOS job 95150049606: SUCCESS
Artifact count: 5
```

Accepted hosted artifact archives:

| Artifact | ID | Size | GitHub artifact digest |
| --- | ---: | ---: | --- |
| `nova-2048-android-release` | 9262064041 | 25,409,571 bytes | `sha256:777c912745e7c3fdbdbe6f682699e0edbee9d32e0144dd3d7e72c87f25a5bd00` |
| `nova-2048-linux-x64-release` | 9262027429 | 10,396,713 bytes | `sha256:187975b54ec73f23b49fc8e50f6cd7c5f2e044f551ce153603c13cd75273422a` |
| `nova-2048-windows-x64-release` | 9262041028 | 12,655,269 bytes | `sha256:5d53a9c534b3327b5881087b2f5a9c2d744b841de70e20f9e05115f1f8f18ac1` |
| `nova-2048-macos-release` | 9262077872 | 18,739,219 bytes | `sha256:15cb2d98188fcd0718c382244be0f527a41b5799fc59d5cef57173b2be10097f` |
| `nova-2048-ios-unsigned-release` | 9262078294 | 8,710,168 bytes | `sha256:b09afe7ae21b7563d5407e80de17458e2e5d66e557b591db6aea47bca5b6ac1c` |

All five artifacts expire on **2026-08-30** under the 14-day retention policy. Each job also produced the repository-workflow payload SHA-256 sidecar described in `RELEASE_ARTIFACTS.md`.

This matrix is objective hosted compilation/package evidence. It does **not** mark any real-world qualification item passed. Physical Android/iOS testing, representative input/responsive checks, assistive-technology passes, long sessions, real-target transport/import flows, external handlers, native branding review, and production signing/provisioning/store metadata remain governed by `release_qualification.json`, which is still **0/13** complete.

"""
    verification = verification.replace(marker, phase24 + marker, 1)
write(verification_path, verification)

# Record the current accepted artifact set alongside the historical Phase 23 set.
artifacts_path = "docs/RELEASE_ARTIFACTS.md"
artifacts = read(artifacts_path)
phase24_artifacts_heading = "## Phase 24 accepted Version 1.5 hosted artifact set"
if phase24_artifacts_heading not in artifacts:
    artifacts += """

## Phase 24 accepted Version 1.5 hosted artifact set

Accepted Platform Builds run: **31940994252**, source `4d4fe634624b069834786a2aaad356e356281c44`.

| Artifact | ID | Size | GitHub artifact digest |
| --- | ---: | ---: | --- |
| `nova-2048-android-release` | 9262064041 | 25,409,571 bytes | `sha256:777c912745e7c3fdbdbe6f682699e0edbee9d32e0144dd3d7e72c87f25a5bd00` |
| `nova-2048-linux-x64-release` | 9262027429 | 10,396,713 bytes | `sha256:187975b54ec73f23b49fc8e50f6cd7c5f2e044f551ce153603c13cd75273422a` |
| `nova-2048-windows-x64-release` | 9262041028 | 12,655,269 bytes | `sha256:5d53a9c534b3327b5881087b2f5a9c2d744b841de70e20f9e05115f1f8f18ac1` |
| `nova-2048-macos-release` | 9262077872 | 18,739,219 bytes | `sha256:15cb2d98188fcd0718c382244be0f527a41b5799fc59d5cef57173b2be10097f` |
| `nova-2048-ios-unsigned-release` | 9262078294 | 8,710,168 bytes | `sha256:b09afe7ae21b7563d5407e80de17458e2e5d66e557b591db6aea47bca5b6ac1c` |

Every Version 1.5 build, package, checksum, and upload step completed successfully. The artifacts expire on **2026-08-30**. As with the Phase 23 set, these are qualification inputs and hosted-build evidence only; they do not change the **0/13** real-world qualification status.
"""
write(artifacts_path, artifacts)
