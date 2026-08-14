import 'package:flutter_test/flutter_test.dart';
import 'package:nova_2048/shared/external_link.dart';

void main() {
  group('isAllowedExternalUri', () {
    test('allows secure web links with a host', () {
      expect(
        isAllowedExternalUri(Uri.parse('https://github.com/sanskarIN/2048')),
        isTrue,
      );
    });

    test('allows mailto links with a recipient', () {
      expect(
        isAllowedExternalUri(Uri.parse('mailto:supportramsandesh@gmail.com')),
        isTrue,
      );
    });

    test('rejects insecure and unsupported schemes', () {
      expect(isAllowedExternalUri(Uri.parse('http://example.com')), isFalse);
      expect(isAllowedExternalUri(Uri.parse('javascript:alert(1)')), isFalse);
      expect(isAllowedExternalUri(Uri.parse('file:///tmp/example')), isFalse);
    });

    test('rejects malformed empty destinations', () {
      expect(isAllowedExternalUri(Uri.parse('https:')), isFalse);
      expect(isAllowedExternalUri(Uri.parse('mailto:')), isFalse);
    });
  });
}
