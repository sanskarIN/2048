import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  const gumroadUrl = 'https://ramsandesh.gumroad.com';

  group('Gumroad branding integration', () {
    test('project metadata keeps the canonical Gumroad destination', () {
      final source = File(
        'lib/core/constants/project_info.dart',
      ).readAsStringSync();

      expect(source, contains("static const gumroad = '$gumroadUrl';"));
    });

    test('Home About and Support expose the Gumroad destination', () {
      final home = File(
        'lib/features/home/home_screen.dart',
      ).readAsStringSync();
      final about = File(
        'lib/features/about/about_screen.dart',
      ).readAsStringSync();
      final support = File(
        'lib/features/support/support_screen.dart',
      ).readAsStringSync();

      expect(home, contains('ProjectInfo.gumroad'));
      expect(home, contains('Ramsandesh on Gumroad'));
      expect(home, contains('Icons.storefront_rounded'));
      expect(about, contains('ProjectInfo.gumroad'));
      expect(about, contains('Icons.storefront_rounded'));
      expect(support, contains('ProjectInfo.gumroad'));
      expect(support, contains('Ramsandesh on Gumroad'));
      expect(support, contains('Open Gumroad'));
    });

    test('repository documentation prominently links Gumroad', () {
      final readme = File('README.md').readAsStringSync();
      final support = File('SUPPORT.md').readAsStringSync();
      final branding = File('docs/BRANDING.md').readAsStringSync();

      expect(readme, contains(gumroadUrl));
      expect(readme, contains('ramsandesh_gumroad_badge.svg'));
      expect(support, contains(gumroadUrl));
      expect(support, contains('ramsandesh_gumroad_badge.svg'));
      expect(branding, contains(gumroadUrl));
      expect(branding, contains('ramsandesh_gumroad_badge.svg'));
    });

    test('Gumroad badge is local, accessible, and self-contained', () {
      final badge = File(
        'assets/branding/ramsandesh_gumroad_badge.svg',
      ).readAsStringSync();

      expect(badge, contains('<title id="title">Ramsandesh on Gumroad</title>'));
      expect(badge, contains('<desc id="desc">'));
      expect(badge, contains('ramsandesh.gumroad.com'));
      expect(badge, isNot(contains('href="http')));
      expect(badge, isNot(contains('xlink:href')));
    });
  });
}
