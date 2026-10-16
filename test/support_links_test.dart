import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  const bmc = 'https://buymeacoffee.com/SanskarCodes';
  const razorpay = 'https://razorpay.me/@SanskarCodes';
  const paypal = 'https://paypal.me/SanskarCodes';
  const website = 'https://sanskarin.github.io';
  const contact = 'https://sanskarin.github.io/contact';

  test('canonical project links use current owned destinations', () {
    final project = File(
      'lib/core/constants/project_info.dart',
    ).readAsStringSync();

    expect(project, contains("static const website = '$website';"));
    expect(project, contains("static const contact = '$contact';"));
    expect(project, contains("static const buyMeACoffee = '$bmc';"));
    expect(project, contains("static const razorpay = '$razorpay';"));
    expect(project, contains("static const paypal = '$paypal';"));
    expect(project.toLowerCase(), isNot(contains('gumroad')));
    expect(project, isNot(contains('supportEmail')));
  });

  test('Home, About, and Support use current project destinations', () {
    final home = File('lib/features/home/home_screen.dart').readAsStringSync();
    final about = File('lib/features/about/about_screen.dart')
        .readAsStringSync();
    final support = File('lib/features/support/support_screen.dart')
        .readAsStringSync();

    for (final screen in [home, about, support]) {
      expect(screen.toLowerCase(), isNot(contains('gumroad')));
      expect(screen, isNot(contains('ProjectInfo.supportEmail')));
    }

    expect(home, contains('ProjectInfo.buyMeACoffee'));
    for (final screen in [about, support]) {
      for (final destination in [
        'ProjectInfo.website',
        'ProjectInfo.contact',
        'ProjectInfo.buyMeACoffee',
        'ProjectInfo.razorpay',
        'ProjectInfo.paypal',
      ]) {
        expect(screen, contains(destination));
      }
    }
  });

  test('readme, support, funding, and security policies expose live links', () {
    final readme = File('README.md').readAsStringSync();
    final support = File('SUPPORT.md').readAsStringSync();
    final funding = File('.github/FUNDING.yml').readAsStringSync();
    final policy = File('SECURITY.md').readAsStringSync();

    for (final document in [readme, support, funding]) {
      for (final url in [bmc, razorpay, paypal]) {
        expect(document, contains(url));
      }
      expect(document.toLowerCase(), isNot(contains('gumroad')));
    }
    for (final document in [readme, support, policy]) {
      expect(document, contains(contact));
    }
    expect(readme, contains(website));
    expect(
      File('assets/branding/ramsandesh_gumroad_badge.svg').existsSync(),
      isFalse,
    );
  });
}
