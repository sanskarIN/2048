# Branding and Asset Pipeline

2048 Nova uses an original geometric tile logo maintained in the repository.

## Source asset

`assets/branding/2048_nova_logo.svg` is the editable source. The design uses four rounded puzzle/tile blocks, a purple-to-teal Nova gradient, and a central 2048 mark. It is intended to remain recognizable at launcher-icon sizes while avoiding copied third-party game artwork.

## Generated assets

The `Bootstrap Branding Assets` GitHub Actions workflow renders the SVG into platform-specific files while preserving the dimensions expected by Flutter's generated runners:

- Android launcher PNGs for each density.
- iOS AppIcon exports.
- iOS native launch image exports.
- macOS AppIcon exports.
- Windows multi-resolution ICO.
- Web/PWA 192×192 and 512×512 icons plus maskable variants.
- Web favicon PNG.
- Reusable `assets/branding/2048_nova_icon_1024.png`.

The generated files are committed so release builds do not depend on CairoSVG or Pillow. Those tools are only used inside the branding-generation workflow.

## Splash behavior

Native startup assets show the project branding while Flutter initializes. The Flutter splash screen then immediately routes to Home after the first frame and does not add an artificial delay. It includes the project name and **Made by the Sanskar** identity.

## Buy Me a Coffee

The application uses a clearly labeled coffee/support control rather than bundling an unofficial copy of a proprietary BMC logo. It opens `https://buymeacoffee.com/sanskarIN`, uses the semantic label **Support Sanskar on Buy Me a Coffee**, and never implies that payment is required or that the project is officially endorsed by Buy Me a Coffee.

## Asset policy

Do not add copied proprietary game art, unlicensed fonts, copyrighted audio, or third-party branding without confirming compatible usage terms. Keep source assets, attribution, and licensing information in the repository when attribution is required.
