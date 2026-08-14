## Summary

Describe the problem and the solution. State whether this changes user-visible behavior, deterministic game rules, persisted data, imported-game trust policy, Replay/Auto Play isolation, accessibility, privacy, or platform configuration.

## Changes

- 

## Screenshots / recordings

Add before/after visuals for meaningful UI changes when useful. Do not include credentials, private backup text, or unrelated personal information.

## Testing performed

- [ ] `dart format --output=none --set-exit-if-changed lib test`
- [ ] `flutter analyze`
- [ ] `flutter test`
- [ ] `flutter build web --release` when applicable
- [ ] Relevant native build target verified when applicable
- [ ] Manual regression check performed where appropriate

List exact commands, important test names, CI runs, and remaining manual boundaries below.

## Review checklist

- [ ] Linked issue or context included
- [ ] Tests added/updated for behavior changes and regressions
- [ ] No secrets, signing material, credentials, or unrelated private data committed
- [ ] Documentation updated in the matching technical/user/release files
- [ ] `what_changed.md` updated for meaningful project-level work
- [ ] New persisted/external input is validated and corruption-safe
- [ ] Growing stored collections are bounded
- [ ] Reset/clear behavior was reviewed for any new local key
- [ ] Imported/editable data cannot silently become trusted ranked progress
- [ ] Replay remains spectator-only unless an explicit architecture change is documented
- [ ] Auto Play Demo remains isolated from trusted player saves/records unless an explicit architecture change is documented
- [ ] External destinations use the shared secure-link policy
- [ ] Dependency additions include maintenance, license, privacy, size, and cross-platform justification

## Persistence / migration impact

Describe new keys, schema changes, migrations, corruption recovery, Undo/session implications, and reset behavior, or write `None`.

## Backup / trust impact

Describe any change to portable Game Backup validation, envelope compatibility, clipboard handling, confirmation, unranked persistence, lifetime-record isolation, or write `None`.

## Accessibility impact

Describe keyboard, focus, semantics, contrast, text scaling, reduced-motion, automatic-update behavior, and real assistive-technology checks still needed.

## Privacy / security impact

Describe external data/network/clipboard/URI/dependency changes and security assumptions, or write `None`.

## Performance impact

Describe expected performance, memory, startup, persistence, or build-size impact, or write `None`.

## Platform impact

List Android, iOS, Web, Windows, macOS, and Linux implications, including signing/provisioning boundaries if relevant.

## Breaking changes

Describe compatibility/migration requirements or write `None`.

## Manual release checks still required

List any physical-device, screen-reader, clipboard, external-handler, long-session, signing, packaging, or store qualification that automated CI cannot prove.
