# Final Version 1.5 Automated Verification

This document records the final accepted automated source/build evidence for the **2048 Nova `1.5.0+15` release candidate**. It does not promote the package to stable `1.5.0` and it does not replace any real-world manual qualification requirement.

## Accepted source

The formatter-clean Version 1.5 source was:

```text
e94965bdb7e464cdd1076f247d0f10977ab20c19
```

Comment-only verification PR #18 exercised that source through the maintained pull-request workflows. The PR was closed unmerged after acceptance so no comment-only verification marker needed to become part of the product source.

## CI quality gate

- Workflow: **CI**
- Run: `32142335530`
- Job: `95727735420`
- Result: **SUCCESS**
- Flutter: **3.47.0**
- Dart: **3.13.0**

Verified in the same job:

- 112 Dart files formatter-clean;
- Flutter analyzer clean;
- **262/262 tests passed**;
- Version 1.5 release-candidate readiness metadata passed;
- repository integrity audit passed;
- strict stable gate correctly remained closed because manual evidence is incomplete;
- deterministic solver smoke benchmark passed;
- WASM dry-run passed;
- Web release build passed without missing-font warnings.

## Dependency review

- Workflow: **Dependency Review**
- Run: `32142335654`
- Result: **SUCCESS**

## Native release-build matrix

- Workflow: **Platform Builds**
- Run: `32142335514`
- Overall result: **SUCCESS**

Jobs:

| Target | Job | Result |
| --- | --- | --- |
| Android release APK + AAB | `95727735642` | SUCCESS |
| Linux release | `95727735432` | SUCCESS |
| Windows release | `95727735566` | SUCCESS |
| macOS + unsigned iOS release | `95727735651` | SUCCESS |

The native jobs also completed their configured packaging, SHA-256 checksum generation, and qualification-artifact upload steps.

## Manual qualification remains separate

`docs/release_qualification.json` remains the source of truth for the 13 real-world checks. At this automated-acceptance point all 13 remain pending, so the stable boundary remains **0/13**.

Automated compilation/tests are not evidence for:

- physical Android or iOS gameplay/lifecycle testing;
- real touch/orientation/keyboard/focus/responsive behavior;
- TalkBack, VoiceOver, Narrator, or browser screen-reader qualification;
- long-session behavior on representative devices;
- real Auto Play responsiveness;
- Challenge Code camera/scanner/clipboard behavior on representative targets;
- Move Replay or Full Replay Archive behavior on real targets;
- actual clipboard/file-provider backup workflows;
- real browser/email/file handlers;
- native splash/icon presentation;
- private distribution signing/provisioning;
- store/privacy/package metadata review.

No manual evidence has been synthesized from CI.

## Release state

- Candidate: `1.5.0+15`
- Stable target: `1.5.0`
- Automated source/build acceptance: complete for the source above.
- Manual stable-release qualification: incomplete, 0/13.
- Strict stable readiness command must therefore remain fail-closed.

The next development line may continue separately, but it must not rewrite this Version 1.5 evidence or inherit its manual evidence for newly introduced features.