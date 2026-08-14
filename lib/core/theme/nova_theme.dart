import 'package:flutter/material.dart';

abstract final class NovaTheme {
  static ThemeData light(bool highContrast) {
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF6C4DFF),
      brightness: Brightness.light,
      contrastLevel: highContrast ? 1 : 0,
    );
    return _base(scheme);
  }

  static ThemeData dark(bool highContrast) {
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF8C7BFF),
      brightness: Brightness.dark,
      contrastLevel: highContrast ? 1 : 0,
    );
    return _base(scheme);
  }

  static ThemeData _base(ColorScheme scheme) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      cardTheme: CardThemeData(
        elevation: 0,
        color: scheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.linux: FadeForwardsPageTransitionsBuilder(),
        },
      ),
    );
  }

  static Color tileColor(ColorScheme scheme, int value) {
    if (value == 0) return scheme.surfaceContainerHighest.withValues(alpha: 0.55);
    final exponent = value.bitLength - 1;
    final factor = ((exponent % 8) + 1) / 9;
    return Color.lerp(scheme.primaryContainer, scheme.tertiaryContainer, factor)!;
  }
}
