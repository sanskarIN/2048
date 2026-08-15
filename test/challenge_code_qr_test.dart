import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nova_2048/features/challenge_codes/challenge_code_qr.dart';
import 'package:qr_flutter/qr_flutter.dart';

void main() {
  Widget app({
    required double width,
    String code = 'NOVA1.test-payload.12345678',
  }) {
    return MaterialApp(
      home: Scaffold(
        body: Align(
          alignment: Alignment.topCenter,
          child: SizedBox(
            width: width,
            child: ChallengeCodeQr(
              code: code,
              semanticsLabel: 'Challenge code QR',
              errorLabel: 'QR error',
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('passes exact portable text into a QR renderer', (tester) async {
    const code = 'NOVA1.exact-portable-code.89abcdef';
    await tester.pumpWidget(app(width: 400, code: code));

    final wrapper =
        tester.widget<ChallengeCodeQr>(find.byType(ChallengeCodeQr));
    expect(wrapper.code, code);

    final qr = tester.widget<QrImageView>(find.byType(QrImageView));
    expect(qr.backgroundColor, Colors.white);
    expect(qr.semanticsLabel, 'Challenge code QR');
  });

  testWidgets('caps QR rendering at a scan-friendly 260 logical pixels',
      (tester) async {
    await tester.pumpWidget(app(width: 600));

    expect(tester.getSize(find.byType(QrImageView)).width, 260);
    expect(tester.getSize(find.byType(QrImageView)).height, 260);
  });

  testWidgets('does not overflow a narrower available width', (tester) async {
    await tester.pumpWidget(app(width: 140));

    final size = tester.getSize(find.byType(QrImageView));
    expect(size.width, lessThanOrEqualTo(140));
    expect(size.height, lessThanOrEqualTo(140));
    expect(tester.takeException(), isNull);
  });
}
