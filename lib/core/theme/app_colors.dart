import 'package:flutter/material.dart';

/// Light ve Dark mod için renk paletleri.
///
/// Kullanım:
///   Theme.of(context).colorScheme.primary   // Material ColorScheme
///   AppColors.light.primary                 // Doğrudan erişim
///
/// Yeni renk eklemek için:
///   1. [AppColorPalette] sınıfına field ekle
///   2. Hem [light] hem [dark] factory'ye değer ver
sealed class AppColors {
  AppColors._();

  static const light = AppColorPalette(
    primary: Color(0xFF1565C0),
    onPrimary: Colors.white,
    primaryContainer: Color(0xFFD1E4FF),
    onPrimaryContainer: Color(0xFF001D36),
    secondary: Color(0xFF535F70),
    onSecondary: Colors.white,
    secondaryContainer: Color(0xFFD7E3F7),
    onSecondaryContainer: Color(0xFF101C2B),
    tertiary: Color(0xFF6B5778),
    onTertiary: Colors.white,
    tertiaryContainer: Color(0xFFF2DAFF),
    onTertiaryContainer: Color(0xFF251431),
    error: Color(0xFFBA1A1A),
    onError: Colors.white,
    errorContainer: Color(0xFFFFDAD6),
    onErrorContainer: Color(0xFF410002),
    surface: Color(0xFFF8F9FF),
    onSurface: Color(0xFF191C20),
    surfaceContainer: Color(0xFFECEFF5),
    surfaceContainerHighest: Color(0xFFE1E2E8),
    outline: Color(0xFF73777F),
    outlineVariant: Color(0xFFC3C7CF),
    shadow: Colors.black,
    inverseSurface: Color(0xFF2E3135),
    onInverseSurface: Color(0xFFEFF0F7),
    inversePrimary: Color(0xFFA0CAFD),
    scrim: Colors.black,
  );

  static const dark = AppColorPalette(
    primary: Color(0xFFA0CAFD),
    onPrimary: Color(0xFF003258),
    primaryContainer: Color(0xFF004B7C),
    onPrimaryContainer: Color(0xFFD1E4FF),
    secondary: Color(0xFFBBC7DB),
    onSecondary: Color(0xFF253140),
    secondaryContainer: Color(0xFF3B4858),
    onSecondaryContainer: Color(0xFFD7E3F7),
    tertiary: Color(0xFFD6BEE4),
    onTertiary: Color(0xFF3B2948),
    tertiaryContainer: Color(0xFF523F5F),
    onTertiaryContainer: Color(0xFFF2DAFF),
    error: Color(0xFFFFB4AB),
    onError: Color(0xFF690005),
    errorContainer: Color(0xFF93000A),
    onErrorContainer: Color(0xFFFFDAD6),
    surface: Color(0xFF111318),
    onSurface: Color(0xFFE1E2E8),
    surfaceContainer: Color(0xFF1D2024),
    surfaceContainerHighest: Color(0xFF333539),
    outline: Color(0xFF8D9199),
    outlineVariant: Color(0xFF43474E),
    shadow: Colors.black,
    inverseSurface: Color(0xFFE1E2E8),
    onInverseSurface: Color(0xFF2E3135),
    inversePrimary: Color(0xFF1565C0),
    scrim: Colors.black,
  );
}

/// Tek bir tema modunun tüm renklerini tutan palette.
///
/// Material 3 [ColorScheme] ile 1:1 eşleşir.
/// [toColorScheme] ile dönüştürülür.
class AppColorPalette {
  final Color primary;
  final Color onPrimary;
  final Color primaryContainer;
  final Color onPrimaryContainer;
  final Color secondary;
  final Color onSecondary;
  final Color secondaryContainer;
  final Color onSecondaryContainer;
  final Color tertiary;
  final Color onTertiary;
  final Color tertiaryContainer;
  final Color onTertiaryContainer;
  final Color error;
  final Color onError;
  final Color errorContainer;
  final Color onErrorContainer;
  final Color surface;
  final Color onSurface;
  final Color surfaceContainer;
  final Color surfaceContainerHighest;
  final Color outline;
  final Color outlineVariant;
  final Color shadow;
  final Color inverseSurface;
  final Color onInverseSurface;
  final Color inversePrimary;
  final Color scrim;

  const AppColorPalette({
    required this.primary,
    required this.onPrimary,
    required this.primaryContainer,
    required this.onPrimaryContainer,
    required this.secondary,
    required this.onSecondary,
    required this.secondaryContainer,
    required this.onSecondaryContainer,
    required this.tertiary,
    required this.onTertiary,
    required this.tertiaryContainer,
    required this.onTertiaryContainer,
    required this.error,
    required this.onError,
    required this.errorContainer,
    required this.onErrorContainer,
    required this.surface,
    required this.onSurface,
    required this.surfaceContainer,
    required this.surfaceContainerHighest,
    required this.outline,
    required this.outlineVariant,
    required this.shadow,
    required this.inverseSurface,
    required this.onInverseSurface,
    required this.inversePrimary,
    required this.scrim,
  });

  /// Material 3 [ColorScheme]'e dönüştür.
  ColorScheme toColorScheme(Brightness brightness) => ColorScheme(
        brightness: brightness,
        primary: primary,
        onPrimary: onPrimary,
        primaryContainer: primaryContainer,
        onPrimaryContainer: onPrimaryContainer,
        secondary: secondary,
        onSecondary: onSecondary,
        secondaryContainer: secondaryContainer,
        onSecondaryContainer: onSecondaryContainer,
        tertiary: tertiary,
        onTertiary: onTertiary,
        tertiaryContainer: tertiaryContainer,
        onTertiaryContainer: onTertiaryContainer,
        error: error,
        onError: onError,
        errorContainer: errorContainer,
        onErrorContainer: onErrorContainer,
        surface: surface,
        onSurface: onSurface,
        surfaceContainerHighest: surfaceContainerHighest,
        outline: outline,
        outlineVariant: outlineVariant,
        shadow: shadow,
        inverseSurface: inverseSurface,
        onInverseSurface: onInverseSurface,
        inversePrimary: inversePrimary,
        scrim: scrim,
      );
}
