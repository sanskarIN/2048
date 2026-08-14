# Accessibility

Accessibility is part of the 2048 Nova definition of done.

## Implemented foundations

- Every non-empty tile exposes its exact value through semantics; empty cells are identified as empty.
- Tile values are rendered as text, so gameplay never relies on color alone.
- Arrow Keys and W/A/S/D provide keyboard gameplay controls.
- Interactive toolbar controls use tooltips and semantic labels where additional context is useful.
- Buy Me a Coffee is explicitly labeled as optional support.
- Material 3 controls provide keyboard/focus behavior on supported desktop and web targets.
- High-contrast mode increases generated color-scheme contrast.
- Reduced-motion disables tile transition durations.
- The implementation also respects the platform `disableAnimations` preference.
- Layouts use responsive constraints rather than a single fixed phone size.
- Text remains under Flutter's normal system text-scaling behavior.
- Large tile values use fitted/responsive text rather than silent truncation.
- Sound and haptic feedback can be disabled independently.

## Manual release checks

Before a stable release, verify:

1. Navigate primary screens using keyboard only.
2. Play a full game with Arrow Keys and W/A/S/D.
3. Confirm visible focus indicators on interactive controls.
4. Inspect tile and control semantics with a screen reader.
5. Test both light and dark modes with high contrast on and off.
6. Test large system text scaling without clipped primary actions.
7. Test reduced motion and platform animation reduction.
8. Verify values remain understandable without distinguishing colors.
9. Check portrait, landscape, narrow desktop, and wide desktop layouts.
10. Verify destructive actions remain clearly labeled and require confirmation.

## Known scope

Automated tests can cover semantics and layout regressions, but they do not replace assistive-technology testing on physical target platforms. Stable release notes must distinguish automated verification from manual screen-reader/device verification.
