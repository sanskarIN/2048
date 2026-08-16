import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

/// Renders the exact portable Challenge Code text as a high-contrast QR code.
///
/// This widget is presentation-only. It does not parse the code, request camera
/// access, contact a network service, or change Challenge Code trust semantics.
/// Text obtained by any external scanner must re-enter through the normal
/// Challenge Code decoder; this visual layer never validates or trusts it.
/// The QR surface deliberately stays black-on-white regardless of the surrounding
/// app theme so presentation styling cannot reduce the intended scan contrast.
class ChallengeCodeQr extends StatelessWidget {
  const ChallengeCodeQr({
    super.key,
    required this.code,
    required this.semanticsLabel,
    required this.errorLabel,
  });

  final String code;
  final String semanticsLabel;
  final String errorLabel;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.hasBoundedWidth
            ? constraints.maxWidth
            : 260.0;
        final size = availableWidth.clamp(1.0, 260.0).toDouble();
        return Center(
          child: RepaintBoundary(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.black12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: QrImageView(
                  data: code,
                  version: QrVersions.auto,
                  size: size,
                  padding: EdgeInsets.zero,
                  backgroundColor: Colors.white,
                  eyeStyle: const QrEyeStyle(color: Colors.black),
                  dataModuleStyle: const QrDataModuleStyle(color: Colors.black),
                  gapless: true,
                  semanticsLabel: semanticsLabel,
                  errorStateBuilder: (context, error) => SizedBox.square(
                    dimension: size,
                    child: Center(
                      child: Text(
                        errorLabel,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
