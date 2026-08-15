import 'package:flutter/material.dart';

enum NovaPalette { classic, midnight, neon, ocean, forest, sunset, monochrome }

extension NovaPaletteLabel on NovaPalette {
  String get label => switch (this) {
        NovaPalette.classic => 'Classic Nova',
        NovaPalette.midnight => 'Midnight',
        NovaPalette.neon => 'Neon',
        NovaPalette.ocean => 'Ocean',
        NovaPalette.forest => 'Forest',
        NovaPalette.sunset => 'Sunset',
        NovaPalette.monochrome => 'Monochrome',
      };
}

abstract final class NovaTheme {
  static ThemeData light(bool highContrast, NovaPalette palette) {
    final scheme = ColorScheme.fromSeed(
      seedColor: _seed(palette, Brightness.light),
      brightness: Brightness.light,
      contrastLevel: highContrast ? 1 : 0,
    );
    return _base(scheme);
  }

  static ThemeData dark(bool highContrast, NovaPalette palette) {
    final scheme = ColorScheme.fromSeed(
      seedColor: _seed(palette, Brightness.dark),
      brightness: Brightness.dark,
      contrastLevel: highContrast ? 1 : 0,
    );
    return _base(scheme);
  }

  static Color _seed(NovaPalette palette, Brightness brightness) {
    return switch (palette) {
      NovaPalette.classic => brightness == Brightness.dark
          ? const Color(0xFF8C7BFF)
          : const Color(0xFF6C4DFF),
      NovaPalette.midnight => const Color(0xFF455A9E),
      NovaPalette.neon => const Color(0xFF00A884),
      NovaPalette.ocean => const Color(0xFF0077B6),
      NovaPalette.forest => const Color(0xFF38761D),
      NovaPalette.sunset => const Color(0xFFE76F51),
      NovaPalette.monochrome => const Color(0xFF616161),
    };
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
          TargetPlatform.iOS: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.macOS: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.windows: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.linux: FadeForwardsPageTransitionsBuilder(),
        },
      ),
    );
  }

  static Color tileColor(ColorScheme scheme, int value) {
    if (value == 0) {
      return scheme.surfaceContainerHighest.withValues(alpha: 0.55);
    }
    final exponent = value.bitLength - 1;
    final factor = ((exponent % 8) + 1) / 9;
    return Color.lerp(
      scheme.primaryContainer,
      scheme.tertiaryContainer,
      factor,
    )!;
  }
}
