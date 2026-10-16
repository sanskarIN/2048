# Branding and Asset Pipeline

2048 Nova uses an original geometric tile logo maintained in the repository.

## Source assets

`assets/branding/2048_nova_logo.svg` is the editable application-logo source. The design uses four rounded puzzle/tile blocks, a purple-to-teal Nova gradient, and a central 2048 mark. It is intended to remain recognizable at launcher-icon sizes while avoiding copied third-party game artwork.

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

The generated application files are committed so release builds do not depend on CairoSVG or Pillow. Those tools are only used inside the branding-generation workflow.

## Splash behavior

Native startup assets show the project branding while Flutter initializes. The Flutter splash screen then immediately routes to Home after the first frame and does not add an artificial delay. It includes the project name and **Made by the Sanskar** identity.

## Project support links

The project uses text and Material icons, not copied third-party payment-provider trademarks. Official optional destinations:

- Buy Me a Coffee: https://buymeacoffee.com/SanskarCodes
- Razorpay: https://razorpay.me/@SanskarCodes
- PayPal: https://paypal.me/SanskarCodes
- Website: https://sanskarin.github.io
- Contact: https://sanskarin.github.io/contact

Gameplay remains free and does not require a payment, account, or internet connection.

## Asset policy

Do not add copied proprietary game art, unlicensed fonts, copyrighted audio, or third-party branding without confirming compatible usage terms. Keep source assets, attribution, and licensing information in the repository when attribution is required. Storefront/support badges created by this project should use original geometry and text rather than copied third-party logo artwork unless explicit compatible usage rights are documented.
