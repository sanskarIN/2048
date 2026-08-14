import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:nova_2048/core/localization/nova_localizations.dart';

Widget localizedTestApp({
  required Widget home,
  Map<String, WidgetBuilder> routes = const {},
  Locale? locale,
}) {
  return MaterialApp(
    locale: locale,
    supportedLocales: NovaLocalizations.supportedLocales,
    localizationsDelegates: const [
      NovaLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    routes: routes,
    home: home,
  );
}
