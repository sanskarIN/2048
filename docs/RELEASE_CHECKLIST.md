# Release Checklist

- [ ] `dart format --output=none --set-exit-if-changed lib test`
- [ ] `flutter analyze`
- [ ] `flutter test`
- [ ] `flutter build web --release`
- [ ] Verify core moves and no-double-merge behavior manually
- [ ] Verify save/resume and undo
- [ ] Verify time and move-limit challenges
- [ ] Verify statistics and achievements
- [ ] Verify theme and high-contrast switching
- [ ] Verify reduced-motion behavior
- [ ] Verify keyboard and touch controls
- [ ] Verify BMC, GitHub, LinkedIn, and email links
- [ ] Verify responsive layout at phone, tablet, and desktop widths
- [ ] Check README, CHANGELOG, version, and `what_changed.md`
- [ ] Confirm no secrets are committed
- [ ] Document known limitations
