# Workflow Execution Security

This document defines the executable GitHub Actions trust, credential, concurrency, and reproducibility policy for **2048 Nova Version 2.0.12** (`2.0.12+2012`).

The goal is simple: an unchanged repository commit should not silently execute different third-party Action code, obtain broader credentials than necessary, run forever, or allow overlapping repository-writing jobs to race each other.

This policy complements [`SUPPLY_CHAIN.md`](SUPPLY_CHAIN.md), [`CI_CD.md`](CI_CD.md), [`REPOSITORY_AUDIT.md`](REPOSITORY_AUDIT.md), and the release qualification gate. It does not replace GitHub repository rulesets or genuine real-device release evidence.

## Automated workflow-security audit

Run the repository-owned audit from the project root:

```bash
dart run tool/workflow_security_audit.dart --json
```

The audit fails closed when it finds any of these conditions in `.github/workflows/`:

- a remote `uses:` reference that is not pinned to a full lowercase 40-character commit SHA;
- `pull_request_target` in a maintained workflow;
- blanket `write-all` permissions;
- missing explicit top-level `contents: read` / `contents: write` permission;
- a job without `timeout-minutes`;
- a read-only checkout that keeps repository credentials;
- an unapproved workflow requesting `contents: write`;
- an approved repository writer without concurrency cancellation, bot-loop protection, or its explicit normal non-force push;
- deletion of one of the four approved repository-writing workflows;
- removal of the workflow-security audit from permanent CI.

Process-level regression coverage lives in `test/workflow_security_audit_cli_test.dart`. Focused source-level workflow assertions remain in `test/workflow_security_test.dart` and `test/repository_integrity_test.dart`.

## Immutable remote Action references

Maintained workflows use full commit revisions for remote Actions. Human-readable version comments remain beside the immutable revision.

Current reviewed revisions include:

```text
actions/checkout
3d3c42e5aac5ba805825da76410c181273ba90b1  # v7

subosito/flutter-action
1a449444c387b1966244ae4d4f8c696479add0b2  # v2

actions/dependency-review-action
a1d282b36b6f3519aa1f3fc636f609c47dddb294  # v5

actions/upload-artifact
043fb46d1a93c77aae656e7c1c64a875d1fc6a0a  # v7

actions/setup-java
b6effb05e454b25005698d916606bdc6ffcbf961  # v5
```

A tag such as `@v7` is useful to humans but is mutable. The repository therefore executes the reviewed commit revision instead.

## Flutter SDK reproducibility

Workflows that execute Flutter pin the maintained hosted SDK:

```yaml
channel: stable
flutter-version: 3.47.0
cache: false
```

The exact version prevents a future stable-channel release from changing the compiler/framework used to rerun an unchanged commit.

`cache: false` remains intentional. The project does not silently enable a transitive moving cache Action through the Flutter setup Action. A future cache design must be reviewed as executable supply-chain code before adoption.

## Job execution bounds

Every maintained workflow job must declare a positive `timeout-minutes` value.

Timeouts are a reliability and security control: a stalled package mirror, native build, script, generator, or external hosted runner must not consume an unbounded job indefinitely. The workflow-security audit parses the `jobs:` section and fails if a job loses this bound.

The platform bootstrap generator previously lacked this protection; the Phase 33 maintenance hardening added a bounded timeout and regression enforcement.

## Checkout credential policy

Read-only CI, Dependency Review, and Platform Builds jobs use:

```yaml
permissions:
  contents: read
```

and every `actions/checkout` step in those workflows must include:

```yaml
persist-credentials: false
```

The regression test counts checkout steps dynamically rather than hard-coding the Platform Builds job count, so adding a new read-only build target cannot silently leave its checkout credential enabled.

## Approved repository-writing workflows

Only these maintained workflows are approved to request `contents: write`:

```text
.github/workflows/bootstrap-branding.yml
.github/workflows/bootstrap-platforms.yml
.github/workflows/format-code.yml
.github/workflows/lock-dependencies.yml
```

Their purpose is intentionally narrow: generated branding, generated Flutter platform files, canonical Dart formatting repairs, or dependency lockfile updates.

Each approved writer must retain all of these controls:

- explicit `contents: write` rather than blanket write permissions;
- `github.actor != 'github-actions[bot]'` loop protection;
- a finite job timeout;
- top-level concurrency with `cancel-in-progress: true`;
- the established `Sanskar <sanskarin@outlook.in>` commit identity;
- an ordinary `git push origin HEAD:main` after its guarded update/rebase flow;
- no `git push --force` or `git push -f`;
- no execution with write permission on `pull_request` or `pull_request_target` events.

The branding and platform bootstrap writers now use dedicated concurrency groups so overlapping generator runs cannot race each other while preparing a direct repository update.

## Android Java and Gradle verification

The hosted Android build explicitly installs **Temurin JDK 17** through the immutable `actions/setup-java` revision above. The Android Gradle wrapper pins Gradle 9.7.0 and verifies the accepted complete-distribution SHA-256 through `distributionSha256Sum`.

The current Android repository baseline is documented in [`ANDROID_TOOLCHAIN.md`](ANDROID_TOOLCHAIN.md) and the setup/tool-support documentation. A locally newer Java, Gradle, AGP, Kotlin, or Android SDK is not automatically accepted as the release baseline without compatibility verification.

## Branding generator reproducibility

`tool/branding-requirements.txt` exactly pins the Python packages used by `bootstrap-branding.yml`.

The workflow installs them with:

```text
python3 -m pip install --requirement tool/branding-requirements.txt
```

Build-time tooling is reviewed like any other executable dependency. Floating unreviewed package installs are not part of the maintained generator contract.

## Dependency Review and Action updates

Dependabot monitors GitHub Actions, but an Action update is not accepted solely because a version label is newer.

For an Action revision change:

1. identify the exact immutable commit revision;
2. verify the human-readable version comment;
3. review release notes/runtime requirements;
4. run Dependency Review when applicable;
5. run permanent CI, including the workflow-security audit;
6. run affected platform/generator workflows;
7. update documented reviewed revisions only after successful qualification;
8. preserve the manual release-evidence boundary unless genuine real-world evidence was performed.

## Hosted runner boundary

Pinning Action code, Flutter, JDK, Gradle, Dart packages, and branding packages reduces drift, but GitHub-hosted runner images and OS package mirrors remain managed external infrastructure. Labels such as `ubuntu-latest`, `windows-latest`, and `macos-latest` can change over time.

For that reason, an old successful workflow is historical evidence, not proof that a later hosted image behaves identically. Release maintenance still requires fresh hosted verification for the exact candidate commit.

## Repository protection boundary

Workflow files, CODEOWNERS, tests, and audits cannot configure GitHub branch/ruleset settings by themselves.

The latest repository observation records `main` as protected, but the available legacy protection metadata still does not expose the intended required status-check contexts. A repository ruleset may be responsible for the protected flag; the connected surface cannot prove every enforcement detail.

Issue #12 therefore remains the source of truth for repository-setting verification. Do not close it or claim full required-check enforcement until the GitHub settings themselves prove the intended merge restrictions and permanent CI requirement.

## Stable-release boundary

Workflow hardening improves source integrity and automation provenance. It does **not** satisfy physical-device, assistive-technology, real browser/PWA lifecycle, external-handler, native-branding, signing/provisioning, or store-distribution qualification.

Those 13 manual evidence items remain controlled by `docs/release_qualification.json` and the fail-closed stable gate in `tool/release_readiness.dart`.
