# Maintenance Policy

2048 Nova **2.0.12** is feature-complete within the product scope defined by the repository documentation and final source audit.

This policy prevents normal long-term maintenance from being confused with an unfinished feature backlog.

## Current maintenance line

- Marketing version: `2.0.12`
- Package/build version: `2.0.12+2012`
- Maintained branch: `main`
- License: MIT

## Changes that remain appropriate after source completion

The project may still receive:

- reproducible defect fixes;
- security fixes;
- accessibility corrections;
- localization corrections for already-supported English/Hindi behavior;
- documentation corrections;
- dependency/toolchain maintenance after compatibility review;
- CI/workflow maintenance;
- platform-runner compatibility maintenance;
- store/distribution metadata changes;
- evidence updates after genuine manual qualification.

These are maintenance activities, not evidence that Version 2.0.12 was missing a planned feature.

## No active feature backlog

The project has no required post-2.0.12 feature list.

The following ideas are deliberately **not active backlog items**:

- additional languages beyond English/Hindi;
- in-app QR scanning or camera permissions;
- cloud accounts, cloud saves, telemetry, ads, or remote AI;
- online leaderboards or competitive anti-cheat services;
- online multiplayer;
- deeper/adaptive solver variants beyond the implemented bounded Heuristic/Expectimax sandbox;
- additional visual-effects systems;
- extra desktop/PWA convenience integrations;
- additional statistics that cannot be reconstructed truthfully from trusted local state.

A future contributor may propose one of these, but it becomes work only after a deliberate new-release decision with privacy, accessibility, testing, migration, and cross-platform implications documented in advance.

## Compatibility-first dependency policy

Do not upgrade packages simply because a newer version exists.

For dependency/toolchain changes:

1. identify the concrete benefit, compatibility requirement, security fix, or maintenance reason;
2. update only the smallest coherent set of packages/tooling;
3. keep lockfiles/generated plugin files synchronized;
4. run formatter, analyzer, full tests, repository audit, release gate, and Web build;
5. run affected native build targets;
6. preserve privacy/security/accessibility boundaries;
7. record any platform-specific failure rather than weakening quality gates to hide it.

Patch updates that are not required to fix a known defect may wait for a normal maintenance cycle rather than invalidating a release freeze.

## Android toolchain policy

The accepted baseline is intentionally pinned and regression-guarded. A newer AGP/Gradle/Kotlin/JDK combination is not automatically better for this repository.

A toolchain upgrade is acceptable only when the complete Android release path succeeds without disabling release lint or weakening checks, and the maintained native matrix remains healthy.

## Manual qualification policy

The 13 entries in `release_qualification.json` are external release/distribution evidence, not source-development tasks.

Only record `passed` after the corresponding real-world check was actually performed. Never infer physical-device, accessibility, handler, signing, provisioning, browser/PWA, branding, or store evidence from hosted tests or source inspection.

## Stable release policy

A source-complete candidate and a qualified stable distribution are different states.

The source can be feature-complete while the strict stable gate remains closed. Stable promotion requires the evidence and metadata rules in `RELEASE_QUALIFICATION.md` and must succeed through:

```bash
dart run tool/release_readiness.dart --stable
```

on the exact commit intended for tagging/publishing.

## Repository settings

Branch protection/rulesets are repository settings. They should be enabled independently of tracked source. Their absence does not imply missing gameplay/source features, but it remains a repository-governance risk until configured.

## Future release rule

If new functionality is intentionally adopted, start a new clearly named development phase/release instead of silently expanding the completed 2.0.12 scope. Update:

- `ROADMAP.md`;
- `CHANGELOG.md`;
- relevant design/security/privacy/accessibility docs;
- tests and repository-audit contracts;
- release qualification scope when real-world behavior changes.

This keeps Version 2.0.12 historically well-defined and prevents an endless “one more feature” cycle from becoming the default project state.
