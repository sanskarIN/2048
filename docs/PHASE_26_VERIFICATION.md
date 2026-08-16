# Phase 26 Verification — GitHub Actions Runtime Hardening

Date: **2026-08-16**

This record captures objective hosted verification for the Phase 26 GitHub Actions runtime migration in 2048 Nova Version 1.5.

## Maintained Actions baseline

Phase 26 moved the maintained workflow baseline to:

- `actions/checkout@v7` for repository checkout across permanent workflows;
- `actions/dependency-review-action@v5` for pull-request dependency review;
- hosted runner version observed during validation: `2.336.0`;
- Flutter `3.47.0` stable;
- Dart `3.13.0`;
- package version remains `1.5.0+15`;
- runtime/marketing version remains `1.5.0`.

Repository-integrity tests now reject checkout v4, v5, and v6 references in maintained workflow YAML and require checkout v7 / Dependency Review v5 on the corresponding permanent workflows.

## Permanent CI evidence

Strict permanent CI source: `f21dda252527dee14b8bf9e942cb5aadfda899ca`.

```text
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
Candidate readiness: PASS — candidateGatePassed=true
Stable readiness: correctly false
Manual qualification: 0/13
Solver smoke benchmark: PASS
WASM dry run: PASS
Missing icon-font warning guard: PASS
Web release: PASS — build/web
```

The strict stable gate correctly remains closed because real-world release qualification is incomplete. No hosted workflow result is interpreted as physical-device, assistive-technology, external-handler, long-session, native-branding, signing/provisioning, or store-distribution evidence.

## Checkout v7 native matrix

The permanent Platform Builds workflow was migrated to checkout v7 and exercised on every configured hosted OS family.

```text
Source: bd11a4bdeec6115f132d6b2d2cebef0be34d74f7
Platform Builds run: 31943702153
Android job: 95156471990 — SUCCESS
Linux job: 95156471965 — SUCCESS
Windows job: 95156471956 — SUCCESS
macOS + unsigned iOS job: 95156471915 — SUCCESS
```

Each native job completed `actions/checkout@v7`, dependency/generated-file synchronization, release compilation, packaging, checksum creation, and artifact upload successfully.

## Accepted Phase 26 hosted artifacts

| Artifact | ID | Size | GitHub artifact digest |
| --- | ---: | ---: | --- |
| `nova-2048-android-release` | 9262763908 | 25,409,422 bytes | `sha256:758c74787c24dad9915468945c380c3a32fd09ee6cc33d5cf65208c3757b0bfe` |
| `nova-2048-linux-x64-release` | 9262718392 | 10,396,456 bytes | `sha256:09c86fa70896ba88fc5ff7add7959ab7f92da922c1670c2c2728a3f94e04c8cc` |
| `nova-2048-windows-x64-release` | 9262742599 | 12,655,200 bytes | `sha256:1d21c9c709fca1734b7468e90558bdcd4a3df57ca38e0212650703effd052e7e` |
| `nova-2048-macos-release` | 9262745277 | 18,739,174 bytes | `sha256:f74a1cb1f3012e91d15b41c69b29994c184feb1db73b52d544f3d3631c144af7` |
| `nova-2048-ios-unsigned-release` | 9262745460 | 8,709,430 bytes | `sha256:135b93eabbb27ef5ded28d289cb3777467c7b40cc21fa8c3aa9c38922f34974b` |

The artifacts are retained for 14 days and expire on **2026-08-30**. They remain hosted qualification inputs only.

## Real Dependency Review v5 execution

A disposable pull request, **#8**, was created solely to exercise the maintained pull-request workflow after the v5 migration. It changed only a workflow comment, made no product or dependency change, and was closed without merge after evidence capture.

```text
PR: #8 — ci: validate Dependency Review v5 runtime
Head: fb851365249733367bc4a631f6331ced6a78c324
Dependency Review run: 31943963173
Dependency Review job: 95157100528
Result: SUCCESS
Runner: 2.336.0 / Ubuntu 24.04.4 LTS
Checkout: actions/checkout@v7
Dependency Review: actions/dependency-review-action@v5
Policy: fail-on-severity=high
Detected high-or-higher vulnerable packages: none
Merged: no
```

This proves the v5 action on an actual `pull_request` event instead of relying only on static YAML assertions.

## Guarded migration failure and recovery

The initial guarded Phase 26 migration workflow validated the complete migration successfully before push, including 216 tests and the Web release build. Its final push was rejected by GitHub because the workflow token was not permitted to modify another workflow file. That was an authorization boundary, not a code/test failure.

The already-validated workflow changes were therefore applied directly through GitHub in granular commits, with a temporary compatibility assertion during the staged migration. The final strict repository-integrity assertion was then restored and permanent CI/native/PR evidence was collected from the actual migrated repository state.

## Stable-release boundary

Phase 26 changes CI/runtime infrastructure only. `docs/release_qualification.json` remains intentionally **0/13** complete. Stable promotion remains fail-closed until all required real-world evidence is truthfully recorded and stable release metadata is finalized.
