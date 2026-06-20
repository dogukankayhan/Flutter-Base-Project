import 'package:flutter/material.dart';

/// Constant (mode independent) brand colors.
///
/// All values are compile-time const — no runtime allocation.
/// Context gerektirmez: AppBrandColors.gold, AppBrandColors.primary
///
/// For rarely used shades: Palette.primary[30]!
abstract final class AppBrandColors {
  // ─── Primary palette shortcuts ────────────────────────
  static const Color primary = Color(0xFF5b7dfb); // primary[40]
  static const Color primaryBusy = Color(0xFF3a55f7); // primary[50]
  static const Color primaryContainer = Color(0xFFdbe2fe); // primary[10]
  static const Color onPrimaryContainer = Color(0xFF171754); // primary[100]
  static const Color inversePrimary = Color(0xFF92acfe); // primary[30]

  // ─── Secondary palette shortcuts ──────────────────────
  static const Color secondaryPalette = Color(0xFF3ad7f2); // secondary[40]
  static const Color secondaryContainer = Color(0xFFcef9ff); // secondary[10]
  static const Color onSecondaryContainer = Color(0xFF073245); // secondary[100]

  // ─── Tertiary palette shortcuts ───────────────────────
  static const Color tertiary = Color(0xFFB47AFF); // tertiary[40]
  static const Color tertiaryContainer = Color(0xFFf1e6ff); // tertiary[10]
  static const Color onTertiaryContainer = Color(0xFF33006c); // tertiary[100]

  // ─── On-colors ────────────────────────────────────────
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onSecondary = Color(0xFF24262d);
  static const Color onError = Color(0xFFFF6F69);

  // ─── Semantic ─────────────────────────────────────────
  static const Color error = Color(0xFFFF5160);
  static const Color helper = Color(0xFFF20505);
  static const Color success = Color(0xFF00B69B);
  static const Color warn = Color(0xFFFC9058);
  static const Color info = Color(0xFFEBF7EC);
  static const Color primaryLight = Color(0xFF9FE2F1);
  static const Color successLight = Color(0xFFD8E3BE);

  // ─── Brand ────────────────────────────────────────────
  static const Color gold = Color(0xFFF7B519);
  static const Color goldLight = Color(0xFFFFCC5C);
  static const Color ceil = Color(0xFF969EC9);
  static const Color textBlack = Color(0xFF12141C);
  static const Color blueShadow = Color(0xFF194F5B);
  static const Color grayBase = Color(0xFF979797);
  static const Color grayDark = Color(0xFF383A40);
  static const Color grayLight = Color(0xFFD8D8D8);
  static const Color shadowGreen = Color(0xFF9DC2BA);
  static const Color tanHide = Color(0xFFFC905B);
  static const Color goldenTainoi = Color(0xFFFFCC5C);

  // ─── Shadows (withValues → const olamaz) ─────────────
  static final Color shadow = const Color(0xFF000000).withValues(alpha: 0.08);
  static final Color shadowBlack = const Color(
    0xFF000000,
  ).withValues(alpha: 0.5);

  // ─── Mode-consistent ──────────────────────────────────
  static const Color secondaryTitleColor = Color(0xFF5a6d9d); // colorGray[50]
  static const Color selectedTabIconColor = Color(0xFF5b7dfb); // primary[40]
  static const Color unSelectedTabIconColor = Color(0xFF6c748b); // gray[50]

  // ─── Primary Button ───────────────────────────────────
  static const Color primaryButtonBg = Color(0xFF5b7dfb); // primary[40]
  static const Color primaryButtonBgBusy = Color(0xFF3a55f7); // primary[50]
  static const Color primaryButtonFg = Color(0xFFffffff); // white[10]
  static const Color disabledButtonBg = Color(0xFFdbe2fe); // primary[10]
  static const Color disabledButtonFg = Color(0xFF5b7dfb); // primary[40]

  // ─── Tertiary Button ──────────────────────────────────
  static const Color tertiaryButtonBg = Color(0xFFffffff); // white[10]
  static const Color tertiaryButtonBorder = Color(0xFF9847ff); // tertiary[50]
  static const Color tertiaryButtonFg = Color(0xFF24252d); // gray[100]
  static const Color tertiaryButtonBgBusy = Color(0xFF8e3afa); // tertiary[60]
  static const Color tertiaryButtonFgBusy = Color(0xFFffffff); // white[10]
  static const Color tertiaryDisabledButtonBg = Colors.transparent;
  static const Color tertiaryDisabledButtonBorder = Color(
    0xFFd1aeff,
  ); // tertiary[30]
  static const Color tertiaryDisabledButtonFg = Color(
    0xFFd1aeff,
  ); // tertiary[30]

  // ─── Text Form Field ──────────────────────────────────
  static const Color textFieldUnFocusBorder = Color(0xFF8a91a6); // gray[40]
  static const Color textFieldUnFocusText = Color(0xFF8a91a6); // gray[40]
  static const Color textFieldFocusBorder = Color(0xFF3a55f7); // primary[50]
  static const Color textFieldFocusText = Color(0xFF575d72); // gray[60]
  static const Color textFieldErrorBorder = Color(0xFF8a91a6); // gray[40]
  static final Color textFieldDisabledBorder = const Color(
    0xFF8a91a6,
  ).withValues(alpha: .6); // gray[40] @60%
  static final Color textFieldDisabled = const Color(
    0xFF8a91a6,
  ).withValues(alpha: .6); // gray[40] @60%

  // ─── Gradients ────────────────────────────────────────
  static const LinearGradient mainGradient = LinearGradient(
    colors: [
      Color(0xFF3ad7f2),
      Color(0xFF5b7dfb),
    ], // secondary[40] → primary[40]
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [
      Color(0xFFf588ff),
      Color(0xFF8e3afa),
    ], // fourth[40ish] → tertiary[60]
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
}
