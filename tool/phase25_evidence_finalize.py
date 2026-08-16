from pathlib import Path


def read(path: str) -> str:
    return Path(path).read_text(encoding="utf-8")


def write(path: str, text: str) -> None:
    Path(path).write_text(text, encoding="utf-8")


# Refresh the current-state header without rewriting historical phase records.
path = "what_changed.md"
text = read(path)
old = """- **Current phase:** Phase 24 — Version 1.5 current-line migration and release-contract hardening complete; permanent CI is green at 211 tests; the hosted Android/Linux/Windows/macOS/unsigned-iOS matrix is green; 13 real-world qualification checks remain before stable promotion
- **Latest Version 1.5 native-matrix source:** `4d4fe634624b069834786a2aaad356e356281c44` — `docs(android): clarify application id and qualification signing`
- **Permanent Version 1.5 CI evidence:** run `31940994228`, job `95150049412` — SUCCESS, 211/211 tests, analyzer clean, candidate gate passed, strict stable gate correctly closed, solver smoke passed, Web release passed
- **Version 1.5 native build evidence:** Platform Builds run `31940994252` — Android, Linux, Windows, macOS, and unsigned iOS jobs all SUCCESS with checksummed artifacts retained for 14 days
"""
new = """- **Current phase:** Phase 25 — Version 1.5 dependency/toolchain and supply-chain maintenance hardening complete; permanent CI is green at 215 tests; the post-maintenance Android/Linux/Windows/macOS/unsigned-iOS matrix is green; 13 real-world qualification checks remain before stable promotion
- **Latest Version 1.5 native-matrix source:** `a719321725ab818edb9f443a8cebdc86ad4fae47` — `ci: requalify native builds after Phase 25`
- **Permanent Version 1.5 CI evidence:** run `31943081231`, job `95154949822` — SUCCESS, 215/215 tests, analyzer clean under `flutter_lints 6`, candidate gate passed, strict stable gate correctly closed, solver smoke passed, Web release passed
- **Version 1.5 native build evidence:** Platform Builds run `31943081259` — Android, Linux, Windows, macOS, and unsigned iOS jobs all SUCCESS with checksummed artifacts retained for 14 days
"""
if old not in text:
    raise SystemExit("Current Phase 24 summary not found in what_changed.md")
text = text.replace(old, new, 1)
marker = "## Phase 25 final hosted verification — maintained toolchain and native matrix"
if marker not in text:
    text += """

---

## Phase 25 final hosted verification — maintained toolchain and native matrix

Date: **2026-08-16**

- Final requalification source: `a719321725ab818edb9f443a8cebdc86ad4fae47`.
- Permanent CI run `31943081231`, job `95154949822`: SUCCESS with dependency/generated metadata synchronization, canonical formatting, zero analyzer issues under `flutter_lints 6`, **215/215 tests**, Version 1.5 candidate gate, expected-closed stable gate, deterministic solver smoke, and warning-enforced Web release build all passing.
- Platform Builds run `31943081259`: Android job `95154950015`, Linux job `95154950051`, Windows job `95154950020`, and macOS + unsigned iOS job `95154950021` all SUCCESS.
- Five fresh checksummed hosted artifacts were retained for Android, Linux x64, Windows x64, macOS, and unsigned iOS; archive IDs and GitHub artifact digests are recorded in `docs/RELEASE_ARTIFACTS.md` and `docs/PHASE_25_VERIFICATION.md`.
- This evidence verifies the maintained Dart/Flutter dependency floor and supply-chain hardening across hosted targets. It does **not** satisfy physical-device, assistive-technology, external-handler, long-session, native-branding, signing/provisioning, or store-distribution checks.
- `docs/release_qualification.json` therefore remains intentionally at **0/13** real-world checks passed.
"""
write(path, text)

# Prepend the latest compact verification section.
path = "docs/VERIFICATION.md"
text = read(path)
heading = "## Phase 25 — Dependency/toolchain and supply-chain maintenance hardening"
if heading not in text:
    insertion = "## Phase 24 — Version 1.5 current line and hosted native matrix"
    if insertion not in text:
        raise SystemExit("Phase 24 verification heading not found")
    phase25 = """## Phase 25 — Dependency/toolchain and supply-chain maintenance hardening

Date: **2026-08-16**

Current maintained package/toolchain contract:

```text
Package: 1.5.0+15
Marketing/runtime version: 1.5.0
Dart floor: >=3.9.0 <4.0.0
Flutter floor: >=3.35.0
cupertino_icons: 1.0.9
shared_preferences: ^2.5.5
flutter_lints: ^6.0.0
```

Permanent quality source:

```text
Commit: a719321725ab818edb9f443a8cebdc86ad4fae47
CI run: 31943081231
CI job: 95154949822
Result: SUCCESS
Flutter: 3.47.0 stable
Dart: 3.13.0
Metadata drift: PASS
Formatting: PASS
Static analysis: PASS — No issues found under flutter_lints 6
Tests: PASS — 215/215
Candidate readiness: PASS — candidateGatePassed=true; readyForStable=false; 0/13 manual evidence complete
Stable promotion boundary: PASS — strict stable mode correctly remained closed
Solver smoke benchmark: PASS
WASM dry run: PASS
Missing icon-font warning guard: PASS
Web release: PASS — build/web
```

Post-maintenance hosted native matrix:

```text
Commit: a719321725ab818edb9f443a8cebdc86ad4fae47
Platform Builds run: 31943081259
Android job 95154950015: SUCCESS
Linux job 95154950051: SUCCESS
Windows job 95154950020: SUCCESS
macOS + unsigned iOS job 95154950021: SUCCESS
Artifact count: 5
```

Accepted Phase 25 hosted artifact archives:

| Artifact | ID | Size | GitHub artifact digest |
| --- | ---: | ---: | --- |
| `nova-2048-android-release` | 9262595224 | 25,409,424 bytes | `sha256:3659e74e5701ffc88d97fdf6f794f99e798c72b7e220388ed874581d875ba599` |
| `nova-2048-linux-x64-release` | 9262555485 | 10,396,428 bytes | `sha256:8d44c26c652302d42b9514ceda46d07d4453a2ad19ee0a125251ae8ac86ff2d7` |
| `nova-2048-windows-x64-release` | 9262569444 | 12,655,196 bytes | `sha256:d791a3d130282fc00ace3a4138a888812cdd28418b1010de26509948bae6e009` |
| `nova-2048-macos-release` | 9262587395 | 18,739,179 bytes | `sha256:92535dfac0f4dcee76ee3955660ff1e70f40861b0b36ee581ad36bfa73444211` |
| `nova-2048-ios-unsigned-release` | 9262587677 | 8,709,412 bytes | `sha256:47a467df783846b2ce67aa1e0e0320d9482ad6aba42bcc1f6e7e4da04bcad04a` |

All five artifacts expire on **2026-08-30** under the 14-day retention policy. The focused evidence record is [`PHASE_25_VERIFICATION.md`](PHASE_25_VERIFICATION.md).

This remains hosted verification only. Real-device/accessibility/handler/signing qualification is still **0/13** and is not inferred from CI or unsigned builds.

"""
    text = text.replace(insertion, phase25 + insertion, 1)
write(path, text)

# Append the new accepted artifact set while retaining prior evidence.
path = "docs/RELEASE_ARTIFACTS.md"
text = read(path)
heading = "## Phase 25 accepted Version 1.5 maintenance artifact set"
if heading not in text:
    text += """

## Phase 25 accepted Version 1.5 maintenance artifact set

Accepted Platform Builds run: **31943081259**, source `a719321725ab818edb9f443a8cebdc86ad4fae47`.

| Artifact | ID | Size | GitHub artifact digest |
| --- | ---: | ---: | --- |
| `nova-2048-android-release` | 9262595224 | 25,409,424 bytes | `sha256:3659e74e5701ffc88d97fdf6f794f99e798c72b7e220388ed874581d875ba599` |
| `nova-2048-linux-x64-release` | 9262555485 | 10,396,428 bytes | `sha256:8d44c26c652302d42b9514ceda46d07d4453a2ad19ee0a125251ae8ac86ff2d7` |
| `nova-2048-windows-x64-release` | 9262569444 | 12,655,196 bytes | `sha256:d791a3d130282fc00ace3a4138a888812cdd28418b1010de26509948bae6e009` |
| `nova-2048-macos-release` | 9262587395 | 18,739,179 bytes | `sha256:92535dfac0f4dcee76ee3955660ff1e70f40861b0b36ee581ad36bfa73444211` |
| `nova-2048-ios-unsigned-release` | 9262587677 | 8,709,412 bytes | `sha256:47a467df783846b2ce67aa1e0e0320d9482ad6aba42bcc1f6e7e4da04bcad04a` |

Every Phase 25 hosted native dependency-sync, build, package, checksum, and upload step completed successfully. These artifacts expire on **2026-08-30**. They are hosted qualification inputs only and do not change the **0/13** real-world stable-release qualification status.
"""
write(path, text)

# Surface the focused record in the documentation index.
path = "docs/README.md"
text = read(path)
row = "| [`VERIFICATION.md`](VERIFICATION.md) | Compact current automated verification record. |"
new_row = row + "\n| [`PHASE_25_VERIFICATION.md`](PHASE_25_VERIFICATION.md) | Focused Version 1.5 SDK/dependency, supply-chain, 215-test, Web, and post-maintenance native-matrix verification record. |"
if "PHASE_25_VERIFICATION.md" not in text:
    if row not in text:
        raise SystemExit("VERIFICATION documentation index row not found")
    text = text.replace(row, new_row, 1)
write(path, text)
