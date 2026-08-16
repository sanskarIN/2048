from pathlib import Path


def read(path: str) -> str:
    return Path(path).read_text(encoding="utf-8")


def write(path: str, text: str) -> None:
    Path(path).write_text(text, encoding="utf-8")


# Current continuity summary and chronological Phase 28 record.
path = "what_changed.md"
text = read(path)
old = """- **Current phase:** Phase 27 — Android toolchain compatibility qualification complete; AGP 9.1.0 + Kotlin 2.4.10 + Gradle 9.7.0 is the protected hosted-build baseline; permanent CI is green at 217 tests; AGP 9.3.1 remains explicitly deferred under issue #10; 13 real-world qualification checks remain before stable promotion
- **Latest accepted Version 1.5 native-matrix source:** `b5ddc657880826bb8a0a5621ff03a99050350342` — `build(android): adopt safe Kotlin and Gradle updates`
- **Permanent Version 1.5 CI evidence:** run `31945071057`, job `95159704902` — SUCCESS, 217/217 tests, analyzer clean, protected Android toolchain baseline, candidate gate passed, strict stable gate correctly closed, solver smoke passed, Web release passed
- **Version 1.5 native build evidence:** Platform Builds run `31944999081` — Android, Linux, Windows, macOS, and unsigned iOS jobs all SUCCESS with the accepted Android toolchain and checksummed artifacts retained for 14 days
"""
new = """- **Current phase:** Phase 28 — workflow and supply-chain reproducibility hardening complete; permanent CI is green at 225 tests with immutable Action revisions, Flutter 3.47.0, disabled composite-action cache execution, least-privilege checkout credentials, explicit Android Temurin 17, verified Gradle 9.7 distribution checksum, and pinned branding-generator dependencies; AGP issue #10 and repository-protection issue #12 remain explicit; 13 real-world qualification checks remain before stable promotion
- **Latest accepted Version 1.5 native-matrix source:** `f694f508057ebcf1e91a825a90cc764398051647` — `ci(android): pin hosted JDK 17 runtime`
- **Permanent Version 1.5 CI evidence:** run `31948413257`, job `95167995837` — SUCCESS, 225/225 tests, 99 files formatter-clean, analyzer clean, Flutter 3.47.0, candidate gate passed, strict stable gate correctly closed, solver smoke passed, WASM/Web release passed
- **Version 1.5 native build evidence:** Platform Builds run `31948335974` — Android, Linux, Windows, macOS, and unsigned iOS jobs all SUCCESS with immutable workflow revisions, frozen Flutter 3.47.0, read-only checkout credential persistence disabled, explicit Android JDK 17, checksummed packaging, and 14-day qualification artifacts
"""
if old not in text:
    raise SystemExit("Phase 27 current summary not found")
text = text.replace(old, new, 1)
if "## Phase 28 — Workflow and supply-chain reproducibility hardening" not in text:
    text += """

---

## Phase 28 — Workflow and supply-chain reproducibility hardening (2026-08-16)

- Audited maintained workflows, tracked secrets/signing configuration, TODO/FIXME-style debt, repository protection state, and available GitHub security surfaces.
- Replaced moving remote Action tags with reviewed full 40-character commit revisions for checkout, Flutter setup, Dependency Review, upload-artifact, and Android Java setup.
- Frozen every Flutter-executing workflow to Flutter 3.47.0 and set the composite action cache input to false. GitHub still prepares nested `actions/cache@v5` metadata from the composite action definition, but both cache execution steps are skipped; no cache action step executes.
- Added `persist-credentials: false` to read-only CI, Dependency Review, and native checkout operations. Repository-writing workflows retain only the credentials needed for their explicit push purpose.
- Replaced floating branding Python installs with exact versions in `tool/branding-requirements.txt`; Bootstrap Branding Assets run `31947463847`, job `95165649555`, succeeded with no generated drift.
- Added the official Gradle 9.7.0 complete-distribution SHA-256 to the Android wrapper configuration and regression coverage for the version/checksum pair.
- Made the hosted Android Java baseline explicit with immutable `actions/setup-java` and Temurin JDK 17 rather than relying on runner-image defaults. JDK 21 remains only a diagnostic from issue #10.
- Added repository-integrity and workflow-security regressions for immutable Action references, exact qualified revisions, frozen Flutter/cache policy, pinned branding packages, Gradle checksum, checkout credential persistence, JDK 17, rejection of `pull_request_target`/`write-all`, repository-writing identity, and no force pushes.
- Exercised immutable Dependency Review on disposable PR #13. Run `31947619961`, job `95166040339`, succeeded with no high-or-higher vulnerable dependency changes; the PR was closed without merge.
- Permanent CI run `31948413257`, job `95167995837`, passed **225/225 tests**, 99-file formatting, analyzer, candidate gate, expected-closed stable gate, solver smoke, WASM dry run, and Web release.
- Definitive native run `31948335974` passed Android `95167849002`, Linux `95167849014`, Windows `95167848969`, and macOS + unsigned iOS `95167849007`, including package checksums and artifact uploads.
- Added `docs/WORKFLOW_SECURITY.md` and `docs/PHASE_28_VERIFICATION.md` for executable trust/reproducibility policy and objective evidence.
- GitHub reported `main` as unprotected with required status enforcement off. The connected integration cannot write branch rulesets, so issue #12 tracks this repository-setting requirement rather than pretending CODEOWNERS/YAML enforces it.
- Dependabot/code-scanning/secret-scanning alert APIs were permission-restricted to the connected integration; no claim of empty hidden alert sets is made.
- AGP 9.3.1 remains deferred under issue #10. Dependabot already records the ignored exact release, while future newer AGP releases remain discoverable.
- Real-device/accessibility/handler/signing qualification remains **0/13**; no automation evidence was substituted for physical or distribution evidence.
"""
write(path, text)

# Compact verification record.
path = "docs/VERIFICATION.md"
text = read(path)
if "## Phase 28 — Workflow and supply-chain reproducibility hardening" not in text:
    marker = "## Phase 27 — Android toolchain compatibility qualification"
    phase = """## Phase 28 — Workflow and supply-chain reproducibility hardening

Date: **2026-08-16**

```text
Quality source: 234576b9e0872ca09c47cd43f47eb6d36a88e4b7
CI run: 31948413257
CI job: 95167995837
Result: SUCCESS
Runner: 2.336.0 / Ubuntu 24.04.4 LTS
Flutter: 3.47.0 stable (frozen in workflows)
Dart: 3.13.0
Formatting: PASS — 99 files, 0 changed
Static analysis: PASS — No issues found
Tests: PASS — 225/225
Candidate readiness: PASS — candidateGatePassed=true; readyForStable=false; 0/13 manual evidence complete
Stable promotion boundary: PASS — strict stable mode correctly remained closed
Solver smoke benchmark: PASS
WASM dry run: PASS
Web release: PASS — build/web
Read-only checkout credentials: not persisted
Flutter composite cache steps: skipped
```

```text
Native source: f694f508057ebcf1e91a825a90cc764398051647
Platform Builds run: 31948335974
Android job 95167849002: SUCCESS — explicit Temurin JDK 17
Linux job 95167849014: SUCCESS
Windows job 95167848969: SUCCESS
macOS + unsigned iOS job 95167849007: SUCCESS
```

Immutable Dependency Review proof: PR #13 (closed without merge), run `31947619961`, job `95166040339` — SUCCESS. Branding generator proof: run `31947463847`, job `95165649555` — SUCCESS. Focused evidence is in [`PHASE_28_VERIFICATION.md`](PHASE_28_VERIFICATION.md) and executable-policy details are in [`WORKFLOW_SECURITY.md`](WORKFLOW_SECURITY.md).

GitHub currently reports `main` unprotected; issue #12 tracks the required repository ruleset change. AGP issue #10 remains open. Real-world stable qualification remains **0/13**.

"""
    if marker not in text:
        raise SystemExit("Phase 27 verification marker not found")
    text = text.replace(marker, phase + marker, 1)
write(path, text)

# Hosted artifact ledger.
path = "docs/RELEASE_ARTIFACTS.md"
text = read(path)
if "## Phase 28 reproducibility-hardened hosted artifact set" not in text:
    text += """

## Phase 28 reproducibility-hardened hosted artifact set

Accepted Platform Builds run: **31948335974**, source `f694f508057ebcf1e91a825a90cc764398051647`.

| Artifact | ID | Size | GitHub artifact digest |
| --- | ---: | ---: | --- |
| `nova-2048-android-release` | 9263995770 | 25,409,409 bytes | `sha256:372bed361b7976e5125cbea38ff691c4c2399780fd126af8aa3a8d25c02b00b0` |
| `nova-2048-linux-x64-release` | 9263955131 | 10,396,415 bytes | `sha256:4a19198b3949389845d2cdc8b1b96beb0f0a8bc90553e3add5877151eb095892` |
| `nova-2048-windows-x64-release` | 9263974634 | 12,655,211 bytes | `sha256:6bc86e5fe55a6a90241c4d4f2b9dc2584b4e8129c2928003a59653a94c1f3053` |
| `nova-2048-macos-release` | 9263981693 | 18,739,155 bytes | `sha256:d22aa3d99353c64b190723e6588baffad276a2c6530cde94fcf04874ee81531d` |
| `nova-2048-ios-unsigned-release` | 9263981993 | 8,709,383 bytes | `sha256:d7fec66f6a781bb6e996520e6a04f93b763de2b9e09a5b8cdb1b77bffde70b18` |

Every Phase 28 hosted native dependency-sync, build, package, checksum, and upload step completed successfully. Android additionally used explicit Temurin JDK 17 and the verified Gradle 9.7.0 distribution checksum. These artifacts expire on **2026-08-30** and remain hosted qualification inputs only; stable-release real-world evidence remains **0/13**.
"""
write(path, text)

# Documentation index.
path = "docs/README.md"
text = read(path)
if "[`WORKFLOW_SECURITY.md`](WORKFLOW_SECURITY.md)" not in text:
    row = "| [`CI_CD.md`](CI_CD.md) | Permanent GitHub Actions workflows, quality gates, native build matrix, and automation boundaries. |"
    text = text.replace(row, row + "\n| [`WORKFLOW_SECURITY.md`](WORKFLOW_SECURITY.md) | Immutable Action revisions, frozen Flutter/JDK execution, least-privilege checkout credentials, reproducibility limits, and repository-setting boundaries. |", 1)
if "[`PHASE_28_VERIFICATION.md`](PHASE_28_VERIFICATION.md)" not in text:
    row = "| [`PHASE_27_VERIFICATION.md`](PHASE_27_VERIFICATION.md) | Focused Android toolchain experiment, AGP 9.3 deferral, accepted Kotlin/Gradle subset, 217-test, and post-merge native-matrix evidence. |"
    text = text.replace(row, "| [`PHASE_28_VERIFICATION.md`](PHASE_28_VERIFICATION.md) | Focused immutable-workflow, frozen-toolchain, least-privilege, 225-test, Dependency Review, branding, and native-matrix evidence. |\n" + row, 1)
write(path, text)

# CI/CD guide: replace old mutable-label baseline and stale setup wording.
path = "docs/CI_CD.md"
text = read(path)
old = """## Maintained GitHub Actions runtime baseline

Permanent workflows use `actions/checkout@v7`. Pull-request dependency review uses `actions/dependency-review-action@v5`. The maintained Node 24 action baseline was verified on GitHub-hosted runner `2.336.0` and is regression-guarded by `test/repository_integrity_test.dart`; checkout v4, v5, and v6 references are rejected.

Phase 26 also exercised checkout v7 on Ubuntu, Windows, and macOS through the native matrix and executed Dependency Review v5 on a real disposable pull request. See [`PHASE_26_VERIFICATION.md`](PHASE_26_VERIFICATION.md) for the exact run/job evidence.

Dependency Review remains an additional pull-request gate, not a replacement for formatter, analyzer, tests, release gates, solver smoke, Web build, native builds, or manual stable-release qualification.
"""
new = """## Maintained GitHub Actions and toolchain baseline

Permanent workflows execute reviewed full 40-character commit revisions rather than moving Action tags. The qualified set includes checkout v7, Flutter Action v2, Dependency Review v5, upload-artifact v7, and setup-java v5 at the exact revisions recorded in [`WORKFLOW_SECURITY.md`](WORKFLOW_SECURITY.md).

All Flutter workflows also freeze `flutter-version: 3.47.0` and set `cache: false`. The Flutter composite action declares a nested moving `actions/cache@v5`, so disabling its cache input ensures the corresponding cache execution steps are skipped. Read-only CI, Dependency Review, and native jobs use `persist-credentials: false`; repository-writing workflows retain checkout credentials only when pushing is their explicit purpose.

The hosted Android job additionally installs explicit Temurin JDK 17 and the Gradle wrapper verifies the official Gradle 9.7.0 complete-distribution SHA-256. Phase 28 regression tests fail if these trust/reproducibility controls drift.

Phase 26 remains the historical major-runtime migration record. Phase 28 adds immutable revisions and deeper transitive/toolchain hardening; see [`PHASE_28_VERIFICATION.md`](PHASE_28_VERIFICATION.md).

Dependency Review remains an additional pull-request gate, not a replacement for formatter, analyzer, tests, release gates, solver smoke, Web build, native builds, or manual stable-release qualification.
"""
if old not in text:
    raise SystemExit("Old CI/CD runtime baseline not found")
text = text.replace(old, new, 1)
text = text.replace("2. installs stable Flutter;", "2. installs pinned Flutter 3.47.0 with composite-action caching disabled;", 1)
android_marker = "This verifies a release APK can be produced. Store distribution signing remains a separate release responsibility."
if "explicit Temurin JDK 17" not in text[text.find("### Android"):text.find("### Linux")]:
    text = text.replace(android_marker, "The Android job first installs explicit Temurin JDK 17 through an immutable setup-java revision. The Gradle 9.7.0 wrapper distribution is SHA-256 verified before the build path can use it.\n\n" + android_marker, 1)
if "tool/branding-requirements.txt" not in text:
    text += """

## Branding generator environment

The branding bootstrap installs its Python image-generation stack from `tool/branding-requirements.txt`, where CairoSVG, Pillow, and their build-time dependencies are exactly version-pinned. Phase 28 reran the generator successfully with no asset drift.

## Repository settings boundary

CI YAML and CODEOWNERS cannot technically prevent direct pushes to an unprotected branch. The Phase 28 GitHub settings audit reports `main` protection disabled and required status-check enforcement off. Issue #12 tracks enabling an actual GitHub branch protection rule or ruleset; documentation does not claim that protection exists before the repository setting confirms it.
"""
write(path, text)

# Changelog.
path = "CHANGELOG.md"
text = read(path)
if "Phase 28 workflow-execution security" not in text:
    text = text.replace("### Added\n", "### Added\n- Phase 28 workflow-execution security and focused verification documentation covering immutable Action revisions, frozen Flutter/JDK toolchains, credential persistence, verified Gradle distribution, pinned branding tooling, and repository-setting boundaries.\n- Workflow-security regressions for least-privilege checkout, explicit Android JDK 17, rejection of privileged PR-target/write-all patterns, and repository-writing identity/no-force-push policy.\n- Repository-integrity regressions for immutable remote Actions, exact qualified revisions, frozen Flutter 3.47.0/cache policy, exact branding Python pins, and the official Gradle 9.7.0 distribution checksum.\n", 1)
    text = text.replace("### Changed\n", "### Changed\n- Permanent workflow `uses:` references now execute reviewed 40-character commit SHAs rather than moving major-version tags; human-readable version comments remain for maintenance clarity.\n- All Flutter workflows now use exact Flutter 3.47.0 with composite-action caching disabled; the nested cache steps are skipped rather than executing the composite action's moving `actions/cache@v5` path.\n- Read-only CI, Dependency Review, and native checkouts no longer persist Git credentials after checkout; repository-writing workflows retain only the credential needed for their explicit push purpose.\n- Android hosted builds now install explicit Temurin JDK 17 through immutable setup-java and verify the Gradle 9.7.0 complete distribution with the publisher SHA-256.\n- Branding export now installs an exactly pinned Python build-time environment from `tool/branding-requirements.txt` instead of floating CairoSVG/Pillow packages.\n- Maintained CI now passes 225/225 tests, 99-file formatting, metadata drift checks, release gates, solver smoke, and a warning-enforced Web build.\n", 1)
    text = text.replace("- Maintained CI now passes 217/217 tests, 98-file formatting, metadata drift checks, release gates, solver smoke, and a warning-enforced Web build.\n", "", 1)
write(path, text)
