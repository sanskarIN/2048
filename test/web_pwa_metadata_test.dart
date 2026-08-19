import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Web/PWA metadata', () {
    late Map<String, dynamic> manifest;
    late String indexHtml;

    setUpAll(() {
      manifest =
          jsonDecode(File('web/manifest.json').readAsStringSync())
              as Map<String, dynamic>;
      indexHtml = File('web/index.html').readAsStringSync();
    });

    test('manifest declares stable install identity and relative scope', () {
      expect(manifest['name'], '2048 Nova');
      expect(manifest['short_name'], '2048 Nova');
      expect(manifest['id'], '.');
      expect(manifest['start_url'], '.');
      expect(manifest['scope'], '.');
      expect(manifest['display'], 'standalone');
      expect(manifest['lang'], 'en');
      expect(manifest['dir'], 'ltr');
      expect(manifest['orientation'], 'any');
      expect(manifest['prefer_related_applications'], isFalse);
      expect(
        (manifest['categories'] as List<dynamic>).cast<String>(),
        containsAll(<String>['games', 'entertainment']),
      );
    });

    test('manifest keeps theme and background colors explicit', () {
      expect(manifest['background_color'], '#111318');
      expect(manifest['theme_color'], '#6C4DFF');
      expect(manifest['description'], isA<String>());
      expect((manifest['description'] as String).trim(), isNotEmpty);
    });

    test('manifest icons cover regular and maskable 192/512 assets', () {
      final icons = (manifest['icons'] as List<dynamic>)
          .cast<Map<String, dynamic>>();

      expect(icons, hasLength(4));
      expect(
        icons.map((icon) => icon['sizes']).toSet(),
        containsAll(<String>{'192x192', '512x512'}),
      );
      expect(
        icons.map((icon) => icon['purpose']).toSet(),
        containsAll(<String>{'any', 'maskable'}),
      );

      for (final icon in icons) {
        expect(icon['type'], 'image/png');
        final source = icon['src'];
        expect(source, isA<String>());
        final file = File('web/${source as String}');
        expect(file.existsSync(), isTrue, reason: 'Missing PWA icon: $source');
        expect(file.lengthSync(), greaterThan(0));
      }
    });

    test('index declares document language and install metadata', () {
      expect(indexHtml, contains('<html lang="en">'));
      expect(
        indexHtml,
        contains('<meta name="theme-color" content="#6C4DFF">'),
      );
      expect(
        indexHtml,
        contains('<meta name="color-scheme" content="light dark">'),
      );
      expect(
        indexHtml,
        contains('<meta name="mobile-web-app-capable" content="yes">'),
      );
      expect(
        indexHtml,
        contains('<meta name="apple-mobile-web-app-capable" content="yes">'),
      );
      expect(
        indexHtml,
        contains(
          '<meta name="apple-mobile-web-app-title" content="2048 Nova">',
        ),
      );
      expect(indexHtml, contains('<link rel="manifest" href="manifest.json">'));
      expect(
        indexHtml,
        contains('<link rel="apple-touch-icon" href="icons/Icon-192.png">'),
      );
      expect(indexHtml, contains('<title>2048 Nova</title>'));
    });

    test('index retains Flutter base-href and responsive viewport contract', () {
      expect(indexHtml, contains('<base href="$FLUTTER_BASE_HREF">'));
      expect(
        indexHtml,
        contains(
          '<meta name="viewport" content="width=device-width, initial-scale=1.0, viewport-fit=cover">',
        ),
      );
      expect(indexHtml, contains('flutter_bootstrap.js'));
    });
  });
}
