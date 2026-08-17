# Branding and Asset Pipeline

2048 Nova uses an original geometric tile logo maintained in the repository.

## Source assets

`assets/branding/2048_nova_logo.svg` is the editable application-logo source. The design uses four rounded puzzle/tile blocks, a purple-to-teal Nova gradient, and a central 2048 mark. It is intended to remain recognizable at launcher-icon sizes while avoiding copied third-party game artwork.

`assets/branding/ramsandesh_gumroad_badge.svg` is an original repository-owned storefront badge that highlights the Ramsandesh Gumroad destination without copying or presenting itself as an official Gumroad logo. It contains the exact storefront address `https://ramsandesh.gumroad.com` and is intended for README/support/documentation surfaces.

## Generated assets

The `Bootstrap Branding Assets` GitHub Actions workflow renders the 2048 Nova application SVG into platform-specific files while preserving the dimensions expected by Flutter's generated runners:

- Android launcher PNGs for each density.
- iOS AppIcon exports.
- iOS native launch image exports.
- macOS AppIcon exports.
- Windows multi-resolution ICO.
- Web/PWA 192×192 and 512×512 icons plus maskable variants.
- Web favicon PNG.
- Reusable `assets/branding/2048_nova_icon_1024.png`.

The generated application files are committed so release builds do not depend on CairoSVG or Pillow. Those tools are only used inside the branding-generation workflow. The Gumroad storefront badge is already an editable SVG and does not require platform launcher export.

## Splash behavior

Native startup assets show the project branding while Flutter initializes. The Flutter splash screen then immediately routes to Home after the first frame and does not add an artificial delay. It includes the project name and **Made by the Sanskar** identity.

## Gumroad

The canonical storefront destination is:

**https://ramsandesh.gumroad.com**

The application highlights this destination with a standard Material storefront icon on About and Support screens. Repository documentation may use `assets/branding/ramsandesh_gumroad_badge.svg` as a prominent linked badge. The badge is project-owned presentation artwork; it must not be described as an official Gumroad logo or imply Gumroad endorsement.

## Buy Me a Coffee

The application uses a clearly labeled coffee/support control rather than bundling an unofficial copy of a proprietary BMC logo. It opens `https://buymeacoffee.com/sanskarIN`, uses the semantic label **Support Sanskar on Buy Me a Coffee**, and never implies that payment is required or that the project is officially endorsed by Buy Me a Coffee.

## Asset policy

Do not add copied proprietary game art, unlicensed fonts, copyrighted audio, or third-party branding without confirming compatible usage terms. Keep source assets, attribution, and licensing information in the repository when attribution is required. Storefront/support badges created by this project should use original geometry and text rather than copied third-party logo artwork unless explicit compatible usage rights are documented.
