from pathlib import Path


def read(path: str) -> str:
    return Path(path).read_text(encoding="utf-8")


def write(path: str, text: str) -> None:
    Path(path).write_text(text, encoding="utf-8")


# CI/CD documentation.
path = "docs/CI_CD.md"
text = read(path)
row = "| `ci.yml` | Flutter-managed metadata drift guard, format verification for application/tests/tools, analyzer, test suite with coverage, release-readiness gates, deterministic solver smoke benchmark, and warning-enforced Web release build. |"
if "| `dependency-review.yml` |" not in text:
    if row not in text:
        raise SystemExit("CI workflow table insertion point not found")
    text = text.replace(
        row,
        row
        + "\n| `dependency-review.yml` | Pull-request dependency diff review for dependency-sensitive changes, failing on newly introduced high-severity vulnerable dependencies. |",
        1,
    )
text = text.replace(
    "# CI also verifies that --stable fails closed while the package is 0.9.x",
    "# CI also verifies that --stable fails closed while real-world Version 1.5 qualification is incomplete",
    1,
)
if "## Maintained GitHub Actions runtime baseline" not in text:
    marker = "## CI quality gate\n"
    runtime = """## Maintained GitHub Actions runtime baseline

Permanent workflows use `actions/checkout@v7`. Pull-request dependency review uses `actions/dependency-review-action@v5`. The maintained Node 24 action baseline was verified on GitHub-hosted runner `2.336.0` and is regression-guarded by `test/repository_integrity_test.dart`; checkout v4, v5, and v6 references are rejected.

Phase 26 also exercised checkout v7 on Ubuntu, Windows, and macOS through the native matrix and executed Dependency Review v5 on a real disposable pull request. See [`PHASE_26_VERIFICATION.md`](PHASE_26_VERIFICATION.md) for the exact run/job evidence.

Dependency Review remains an additional pull-request gate, not a replacement for formatter, analyzer, tests, release gates, solver smoke, Web build, native builds, or manual stable-release qualification.

"""
    if marker not in text:
        raise SystemExit("CI quality heading not found")
    text = text.replace(marker, runtime + marker, 1)
write(path, text)

# Supply-chain documentation.
path = "docs/SUPPLY_CHAIN.md"
text = read(path)
old = "`.github/workflows/dependency-review.yml` runs for pull requests that change Pub, Android, or GitHub Actions dependency surfaces. It uses GitHub's dependency-review action and fails when a dependency change introduces a known **high-or-higher severity** vulnerability."
new = "`.github/workflows/dependency-review.yml` runs for pull requests that change Pub, Android, or GitHub Actions dependency surfaces. It uses `actions/checkout@v7` with `actions/dependency-review-action@v5` and fails when a dependency change introduces a known **high-or-higher severity** vulnerability. Phase 26 verified this exact pair on a real pull-request event (run `31943963173`, job `95157100528`)."
if old in text:
    text = text.replace(old, new, 1)
elif "actions/dependency-review-action@v5" not in text:
    raise SystemExit("SUPPLY_CHAIN dependency review paragraph not found")
write(path, text)

# Changelog.
path = "CHANGELOG.md"
text = read(path)
changed = "### Changed\n"
entries = (
    "- GitHub Actions checkout runtime baseline moved to `actions/checkout@v7` across permanent workflows and was verified on Ubuntu, Windows, and macOS hosted runners.\n"
    "- Pull-request dependency review moved to `actions/dependency-review-action@v5` and was verified on a real pull-request event using hosted runner `2.336.0`.\n"
)
if "GitHub Actions checkout runtime baseline moved to `actions/checkout@v7`" not in text:
    if changed not in text:
        raise SystemExit("CHANGELOG Changed heading not found")
    text = text.replace(changed, changed + entries, 1)
text = text.replace(
    "- Repository-owned workflows now use `actions/checkout@v6`; platform artifacts use `actions/upload-artifact@v7`.",
    "- Repository-owned workflows now use `actions/checkout@v7`; platform artifacts use `actions/upload-artifact@v7`.",
    1,
)
write(path, text)

# Documentation index.
path = "docs/README.md"
text = read(path)
row = "| [`PHASE_25_VERIFICATION.md`](PHASE_25_VERIFICATION.md) | Focused Version 1.5 SDK/dependency, supply-chain, 215-test, Web, and post-maintenance native-matrix verification record. |"
if "PHASE_26_VERIFICATION.md" not in text:
    if row not in text:
        raise SystemExit("Phase 25 docs index row not found")
    text = text.replace(
        row,
        "| [`PHASE_26_VERIFICATION.md`](PHASE_26_VERIFICATION.md) | Focused checkout v7, Dependency Review v5, 216-test, Web, and cross-platform Actions-runtime verification record. |\n"
        + row,
        1,
    )
write(path, text)

# Compact current verification record.
path = "docs/VERIFICATION.md"
text = read(path)
heading = "## Phase 26 — GitHub Actions runtime hardening"
if heading not in text:
    marker = "## Phase 25 — Dependency/toolchain and supply-chain maintenance hardening"
    if marker not in text:
        raise SystemExit("Phase 25 verification marker not found")
    phase26 = """## Phase 26 — GitHub Actions runtime hardening

Date: **2026-08-16**

Permanent quality evidence:

```text
Commit: f21dda252527dee14b8bf9e942cb5aadfda899ca
CI run: 31943741993
CI job: 95156594200
Result: SUCCESS
Runner: 2.336.0 / Ubuntu 24.04.4 LTS
Checkout: actions/checkout@v7
Flutter: 3.47.0 stable
Dart: 3.13.0
Formatting: PASS — 98 files, 0 changed
Static analysis: PASS — No issues found
Tests: PASS — 216/216
Candidate readiness: PASS — candidateGatePassed=true; readyForStable=false; 0/13 manual evidence complete
Stable promotion boundary: PASS — strict stable mode correctly remained closed
Solver smoke benchmark: PASS
WASM dry run: PASS
Missing icon-font warning guard: PASS
Web release: PASS — build/web
```

Checkout-v7 hosted native matrix:

```text
Source: bd11a4bdeec6115f132d6b2d2cebef0be34d74f7
Platform Builds run: 31943702153
Android job 95156471990: SUCCESS
Linux job 95156471965: SUCCESS
Windows job 95156471956: SUCCESS
macOS + unsigned iOS job 95156471915: SUCCESS
```

Real pull-request Dependency Review v5 evidence:

```text
Temporary PR: #8 (closed without merge)
Head: fb851365249733367bc4a631f6331ced6a78c324
Run: 31943963173
Job: 95157100528
Result: SUCCESS
Checkout: actions/checkout@v7
Dependency review: actions/dependency-review-action@v5
High-or-higher vulnerable packages detected: none
```

Focused evidence, artifact digests, guarded-migration recovery, and manual-boundary details are recorded in [`PHASE_26_VERIFICATION.md`](PHASE_26_VERIFICATION.md). Real-world qualification remains **0/13**.

"""
    text = text.replace(marker, phase26 + marker, 1)
write(path, text)

# Hosted artifact record.
path = "docs/RELEASE_ARTIFACTS.md"
text = read(path)
if "## Phase 26 accepted checkout-v7 hosted artifact set" not in text:
    text += """

## Phase 26 accepted checkout-v7 hosted artifact set

Accepted Platform Builds run: **31943702153**, source `bd11a4bdeec6115f132d6b2d2cebef0be34d74f7`.

| Artifact | ID | Size | GitHub artifact digest |
| --- | ---: | ---: | --- |
| `nova-2048-android-release` | 9262763908 | 25,409,422 bytes | `sha256:758c74787c24dad9915468945c380c3a32fd09ee6cc33d5cf65208c3757b0bfe` |
| `nova-2048-linux-x64-release` | 9262718392 | 10,396,456 bytes | `sha256:09c86fa70896ba88fc5ff7add7959ab7f92da922c1670c2c2728a3f94e04c8cc` |
| `nova-2048-windows-x64-release` | 9262742599 | 12,655,200 bytes | `sha256:1d21c9c709fca1734b7468e90558bdcd4a3df57ca38e0212650703effd052e7e` |
| `nova-2048-macos-release` | 9262745277 | 18,739,174 bytes | `sha256:f74a1cb1f3012e91d15b41c69b29994c184feb1db73b52d544f3d3631c144af7` |
| `nova-2048-ios-unsigned-release` | 9262745460 | 8,709,430 bytes | `sha256:135b93eabbb27ef5ded28d289cb3777467c7b40cc21fa8c3aa9c38922f34974b` |

Every Phase 26 checkout-v7 native dependency-sync, build, package, checksum, and upload step completed successfully. These artifacts expire on **2026-08-30**. They remain hosted qualification inputs only and do not change the **0/13** real-world stable-release qualification status.
"""
write(path, text)

# Development continuity log.
path = "what_changed.md"
text = read(path)
old = """- **Current phase:** Phase 25 — Version 1.5 dependency/toolchain and supply-chain maintenance hardening complete; permanent CI is green at 215 tests; the post-maintenance Android/Linux/Windows/macOS/unsigned-iOS matrix is green; 13 real-world qualification checks remain before stable promotion
- **Latest Version 1.5 native-matrix source:** `a719321725ab818edb9f443a8cebdc86ad4fae47` — `ci: requalify native builds after Phase 25`
- **Permanent Version 1.5 CI evidence:** run `31943081231`, job `95154949822` — SUCCESS, 215/215 tests, analyzer clean under `flutter_lints 6`, candidate gate passed, strict stable gate correctly closed, solver smoke passed, Web release passed
- **Version 1.5 native build evidence:** Platform Builds run `31943081259` — Android, Linux, Windows, macOS, and unsigned iOS jobs all SUCCESS with checksummed artifacts retained for 14 days
"""
new = """- **Current phase:** Phase 26 — GitHub Actions runtime hardening complete; permanent CI is green at 216 tests; checkout v7 is verified across Ubuntu/Windows/macOS native runners; Dependency Review v5 is verified on a real pull-request event; 13 real-world qualification checks remain before stable promotion
- **Latest Version 1.5 native-matrix source:** `bd11a4bdeec6115f132d6b2d2cebef0be34d74f7` — `ci: use checkout v7 in native matrix`
- **Permanent Version 1.5 CI evidence:** run `31943741993`, job `95156594200` — SUCCESS, 216/216 tests, analyzer clean, checkout v7, candidate gate passed, strict stable gate correctly closed, solver smoke passed, Web release passed
- **Version 1.5 native build evidence:** Platform Builds run `31943702153` — Android, Linux, Windows, macOS, and unsigned iOS jobs all SUCCESS using checkout v7 with checksummed artifacts retained for 14 days
"""
if old in text:
    text = text.replace(old, new, 1)
elif "Current phase:** Phase 26" not in text:
    raise SystemExit("Current Phase 25 summary not found")
if "## Phase 26 — GitHub Actions runtime hardening" not in text:
    text += """

---

## Phase 26 — GitHub Actions runtime hardening (2026-08-16)

- Migrated every maintained repository checkout step from `actions/checkout@v6` to `actions/checkout@v7` in granular workflow commits.
- Migrated pull-request dependency review from `actions/dependency-review-action@v4` to `@v5`.
- Added a strict repository-integrity regression rejecting checkout v4/v5/v6 and requiring the v7/v5 maintained baseline; the current suite is **216 tests**.
- The initial guarded migration run `31943480975` successfully passed formatting, analysis, 216 tests, release gates, solver smoke, and Web release before its final push was rejected solely because the workflow token lacked permission to modify another workflow file.
- Recovered by applying the already-validated workflow changes directly through GitHub, keeping a temporary compatibility assertion during the staged migration and restoring the strict assertion after all permanent workflows had moved to v7.
- Permanent CI run `31943741993`, job `95156594200`, then passed on the strict migrated repository state using runner `2.336.0`, Flutter `3.47.0`, Dart `3.13.0`, checkout v7, **216/216 tests**, release gates, solver smoke, and Web release.
- Platform Builds run `31943702153` proved checkout v7 and successful release build/package/checksum/upload behavior on Android, Linux, Windows, macOS, and unsigned iOS.
- Disposable PR #8 exercised the real pull-request path; Dependency Review run `31943963173`, job `95157100528`, passed with `actions/checkout@v7` and `actions/dependency-review-action@v5`, then the PR was closed without merge.
- Phase 26 hosted artifact IDs/digests and detailed evidence are recorded in `docs/PHASE_26_VERIFICATION.md` and `docs/RELEASE_ARTIFACTS.md`.
- Real-device/accessibility/handler/signing qualification remains **0/13**; no CI or hosted-build result was substituted for manual evidence.
"""
write(path, text)
