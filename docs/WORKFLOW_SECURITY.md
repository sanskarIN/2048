# Workflow Execution Security

This document defines the executable GitHub Actions trust and reproducibility policy for 2048 Nova Version 1.5.

## Objective

A repository commit should identify the automation code and primary build toolchain it intends to execute. Moving workflow tags and floating build-tool channels make an old repository commit behave differently when rerun later, so the maintained workflows minimize those moving inputs.

This policy complements [`SUPPLY_CHAIN.md`](SUPPLY_CHAIN.md), [`CI_CD.md`](CI_CD.md), and the release qualification gate. It does not replace GitHub repository rulesets or real-device release evidence.

## Immutable remote Action references

Maintained workflow files use full 40-character commit revisions for remote `uses:` references. Human-readable version comments are kept beside each revision.

Current qualified revisions:

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

The comment is informational. GitHub executes the commit revision before the comment.

`test/repository_integrity_test.dart` scans every maintained workflow and rejects a remote Action reference that is not a full lowercase commit SHA.

## Flutter SDK reproducibility

Workflows that execute Flutter pin:

```yaml
channel: stable
flutter-version: 3.47.0
cache: false
```

The exact version prevents a later stable-channel release from changing the compiler/framework used to rerun an unchanged repository commit.

`cache: false` is intentional. The qualified `subosito/flutter-action` composite implementation contains an internal `actions/cache@v5` reference when caching is enabled. Because that is a moving major-version reference outside this repository, 2048 Nova disables the action cache path rather than silently reintroducing mutable executable code through a transitive Action.

This trades some hosted-runner speed for stronger reproducibility. A future cache design can be adopted only when its executable reference is reviewable and immutably pinned by the repository's own workflow surface.

## Android Java and Gradle verification

The hosted Android job explicitly installs **Temurin JDK 17** through the immutable `actions/setup-java` revision above. This is important because Phase 27 demonstrated materially different AGP 9.3.1 release-lint behavior between JDK 17 and JDK 21. The accepted Version 1.5 Android baseline must therefore not depend on whichever Java runtime a future runner image happens to make default.

The Android Gradle wrapper also verifies the official Gradle 9.7.0 complete-distribution SHA-256 through `distributionSha256Sum`. Repository-integrity tests protect both the accepted Gradle version and checksum.

JDK 21 remains a diagnostic result for issue #10, not the maintained release-build baseline.

## Checkout credential persistence

Read-only CI, Dependency Review, and native matrix jobs use:

```yaml
persist-credentials: false
```

They need repository contents after checkout but do not need to push. Removing the checkout credential from local Git configuration narrows the credential exposure available to later build/test commands.

The four repository-writing workflows intentionally retain normal checkout credentials because their explicit purpose includes pushing generated assets, generated platform files, formatting repairs, or lockfile updates. Those workflows still request only `contents: write`, preserve the project commit identity, and do not force-push.

`test/workflow_security_test.dart` enforces both sides of this boundary.

## Branding generator reproducibility

`tool/branding-requirements.txt` exactly pins the Python packages used by `bootstrap-branding.yml`. The current set is based on a previously successful Ubuntu-hosted branding environment and is rerun as part of maintenance qualification.

The branding workflow installs through:

```text
python3 -m pip install --requirement tool/branding-requirements.txt
```

No floating `pip install cairosvg pillow` command is accepted. Repository-integrity tests require each non-comment requirements line to contain an exact `==` version.

These packages are build-time tools and are not shipped in the application runtime.

## Dependency Review proof

The SHA-pinned dependency-review path is not accepted from static text alone. Phase 28 opened disposable PR #13 specifically to execute the immutable checkout and Dependency Review revisions on a real pull-request event.

The PR is not a product change and was closed without merge after the dependency-review job succeeded. Exact run/job evidence is preserved in [`PHASE_28_VERIFICATION.md`](PHASE_28_VERIFICATION.md) and the chronological development log.

## Permissions

Permanent read-only verification workflows request `contents: read` unless write access is required for their explicit purpose.

Repository-writing workflows request `contents: write` and follow these rules:

- commit only expected generated/formatted/lock files;
- configure `Sanskar <sanskarin@outlook.in>` as the Git identity;
- do not force-push `main`;
- rebase before a normal push when concurrent changes may exist;
- exit without a commit when output is already current;
- do not store credentials, signing keys, or access tokens in tracked files.

The repository security regression also rejects permanent `pull_request_target` triggers and blanket `write-all` permissions.

## Dependabot update policy for Actions

Dependabot continues monitoring GitHub Actions. A proposed Action update must not be accepted solely because the version label is newer.

For an Action change:

1. identify the new immutable commit revision;
2. keep an accurate human-readable version comment;
3. review release notes and runtime requirements;
4. run Dependency Review when the changed path triggers it;
5. run permanent CI;
6. run affected native/generator workflows;
7. update repository-integrity expected revisions only after qualification;
8. preserve the stable-release `0/13` manual boundary unless actual real-world evidence exists.

## Hosted runner boundary

Pinning Action code, Flutter, JDK, Gradle, Dart packages, and branding Python packages substantially reduces drift, but GitHub-hosted runner images and OS package mirrors remain external managed infrastructure. Labels such as `ubuntu-latest`, `windows-latest`, and `macos-latest` can receive image updates over time, and the Linux native job installs system build prerequisites from the runner's configured package mirror.

For that reason, every release-candidate maintenance change still requires fresh hosted verification. An old successful build is evidence for its recorded runner environment, not proof that all future runner images are identical.

## Security-alert API visibility

Phase 28 attempted to read repository Dependabot, code-scanning, and secret-scanning alert endpoints through the connected integration. GitHub returned permission-restricted responses for those endpoints. The repository therefore does **not** claim that hidden alert sets are empty based on inaccessible APIs.

Available evidence remains the tracked-source secret/config audit, Dependency Review execution, analyzer/tests/builds, and GitHub settings that the integration can actually read.

## Repository protection boundary

Workflow files and CODEOWNERS cannot enforce `main` protection by themselves.

The Phase 28 audit found `main` currently unprotected, with required status-check enforcement off. Issue #12 tracks the necessary GitHub repository-setting change. Until the setting itself is enabled, documentation must not claim that direct pushes are technically prevented.

Recommended protection is documented in [`SUPPLY_CHAIN.md`](SUPPLY_CHAIN.md) and issue #12.

## Stable-release boundary

Immutable automation improves provenance and repeatability, but it does not satisfy physical-device, assistive-technology, external-handler, long-session, native-branding, signing, provisioning, or store-distribution qualification.

Those 13 evidence items remain controlled by the fail-closed release manifest and `tool/release_readiness.dart`.
