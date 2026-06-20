import 'package:flutter/material.dart';
import 'palette.dart';

/// Colors changing according to theme mode.
///
/// ThemeData'ya register edilir:
///   ThemeData(extensions: [AppColors.light])
///
/// Access from Widget:
///   context.appColors.background
///   context.appColors.borderColor
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.background,
    required this.surface,
    required this.onSurface,
    required this.secondary,
    required this.disabledColor,
    required this.borderColor,
    required this.borderSecondary,
    required this.bgSecondary,
    required this.bgInfo,
    required this.highLight,
    required this.green,
    required this.container,
    required this.fastingPercentColor,
    required this.secondaryTextColor,
    required this.textColor,
    required this.primaryTitleColor,
    required this.secondaryContainer,
    required this.iconColor,
    required this.dropdownTextColor,
    required this.tertiaryButtonTextColor,
    required this.tertiaryContainerColor,
    required this.tertiaryIconColor,
    required this.calendarNameColor,
    required this.calendarTimeColor,
  });

  final Color background;
  final Color surface;
  final Color onSurface;
  final Color secondary;
  final Color disabledColor;
  final Color borderColor;
  final Color borderSecondary;
  final Color bgSecondary;
  final Color bgInfo;
  final Color highLight;
  final Color green;
  final Color container;
  final Color fastingPercentColor;
  final Color secondaryTextColor;
  final Color textColor;
  final Color primaryTitleColor;
  final Color secondaryContainer;
  final Color iconColor;
  final Color dropdownTextColor;
  final Color tertiaryButtonTextColor;
  final Color tertiaryContainerColor;
  final Color tertiaryIconColor;
  final Color calendarNameColor;
  final Color calendarTimeColor;

  // ─── Light ────────────────────────────────────────────
  static final AppColors light = AppColors(
    background: const Color(0xFFF5F6FA),
    surface: const Color(0xFFFFFFFF),
    onSurface: Palette.primary[100]!, // primary[100]
    secondary: const Color(0xFF717277),
    disabledColor: const Color(0xFFECEDED),
    borderColor: Palette.gray[20]!, // gray[20]
    borderSecondary: const Color(0xFFA0A1A4),
    bgSecondary: const Color(0xFFD9E6E9),
    bgInfo: const Color(0xFF619E45).withValues(alpha: .08),
    highLight: const Color(0xFFF2FBFD),
    green: const Color(0xFF00B69B),
    container: const Color(0xFFF5F5F6),
    fastingPercentColor: const Color(0xFFC6F0DD),
    secondaryTextColor: Palette.gray[50]!, // gray[50]
    textColor: const Color(0xFF000000),
    primaryTitleColor: Palette.primary[100]!, // primary[100]
    secondaryContainer: Palette.gray[10]!, // gray[10]
    iconColor: Palette.gray[100]!, // gray[100]
    dropdownTextColor: Palette.primary[100]!, // primary[100]
    tertiaryButtonTextColor: Palette.gray[100]!, // gray[100]
    tertiaryContainerColor: Palette.gray[10]!, // gray[10]
    tertiaryIconColor: Palette.gray[30]!, // gray[30]
    calendarNameColor: Palette.colorGray[70]!, // colorGray[70]
    calendarTimeColor: Colors.black,
  );

  // ─── Dark ─────────────────────────────────────────────
  static final AppColors dark = AppColors(
    background: Palette.colorGray[100]!, // colorGray[100]
    surface: const Color(0xFF333333),
    onSurface: Palette.white[10]!, // white[10]
    secondary: const Color(0xFF323232),
    disabledColor: const Color(0xFF44454b),
    borderColor: Palette.colorGray[90]!, // colorGray[90]
    borderSecondary: const Color(0xFF717277),
    bgSecondary: const Color(0xFF2A3664),
    bgInfo: const Color(0xFF383C49),
    highLight: const Color(0xFF29424E),
    green: const Color(0xFF04F4D1),
    container: const Color(0xFF23283D),
    fastingPercentColor: const Color(0xFF2A4F44),
    secondaryTextColor: Palette.colorGray[10]!, // colorGray[10]
    textColor: const Color(0xFFFFFFFF),
    primaryTitleColor: Palette.primary[40]!, // primary[40]
    secondaryContainer: Palette.colorGray[100]!, // colorGray[100]
    iconColor: Colors.white,
    dropdownTextColor: Colors.white,
    tertiaryButtonTextColor: Colors.white,
    tertiaryContainerColor: Palette.colorGray[80]!, // colorGray[80]
    tertiaryIconColor: Palette.colorGray[50]!, // colorGray[50]
    calendarNameColor: Palette.gray[10]!, // gray[10]
    calendarTimeColor: Palette.colorGray[30]!, // colorGray[30]
  );

  // ─── ThemeExtension ───────────────────────────────────
  @override
  AppColors copyWith({
    Color? background,
    Color? surface,
    Color? onSurface,
    Color? secondary,
    Color? disabledColor,
    Color? borderColor,
    Color? borderSecondary,
    Color? bgSecondary,
    Color? bgInfo,
    Color? highLight,
    Color? green,
    Color? container,
    Color? fastingPercentColor,
    Color? secondaryTextColor,
    Color? textColor,
    Color? primaryTitleColor,
    Color? secondaryContainer,
    Color? iconColor,
    Color? dropdownTextColor,
    Color? tertiaryButtonTextColor,
    Color? tertiaryContainerColor,
    Color? tertiaryIconColor,
    Color? calendarNameColor,
    Color? calendarTimeColor,
  }) => AppColors(
    background: background ?? this.background,
    surface: surface ?? this.surface,
    onSurface: onSurface ?? this.onSurface,
    secondary: secondary ?? this.secondary,
    disabledColor: disabledColor ?? this.disabledColor,
    borderColor: borderColor ?? this.borderColor,
    borderSecondary: borderSecondary ?? this.borderSecondary,
    bgSecondary: bgSecondary ?? this.bgSecondary,
    bgInfo: bgInfo ?? this.bgInfo,
    highLight: highLight ?? this.highLight,
    green: green ?? this.green,
    container: container ?? this.container,
    fastingPercentColor: fastingPercentColor ?? this.fastingPercentColor,
    secondaryTextColor: secondaryTextColor ?? this.secondaryTextColor,
    textColor: textColor ?? this.textColor,
    primaryTitleColor: primaryTitleColor ?? this.primaryTitleColor,
    secondaryContainer: secondaryContainer ?? this.secondaryContainer,
    iconColor: iconColor ?? this.iconColor,
    dropdownTextColor: dropdownTextColor ?? this.dropdownTextColor,
    tertiaryButtonTextColor:
        tertiaryButtonTextColor ?? this.tertiaryButtonTextColor,
    tertiaryContainerColor:
        tertiaryContainerColor ?? this.tertiaryContainerColor,
    tertiaryIconColor: tertiaryIconColor ?? this.tertiaryIconColor,
    calendarNameColor: calendarNameColor ?? this.calendarNameColor,
    calendarTimeColor: calendarTimeColor ?? this.calendarTimeColor,
  );

  @override
  AppColors lerp(covariant AppColors? other, double t) {
    if (other == null) return this;
    return AppColors(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      onSurface: Color.lerp(onSurface, other.onSurface, t)!,
      secondary: Color.lerp(secondary, other.secondary, t)!,
      disabledColor: Color.lerp(disabledColor, other.disabledColor, t)!,
      borderColor: Color.lerp(borderColor, other.borderColor, t)!,
      borderSecondary: Color.lerp(borderSecondary, other.borderSecondary, t)!,
      bgSecondary: Color.lerp(bgSecondary, other.bgSecondary, t)!,
      bgInfo: Color.lerp(bgInfo, other.bgInfo, t)!,
      highLight: Color.lerp(highLight, other.highLight, t)!,
      green: Color.lerp(green, other.green, t)!,
      container: Color.lerp(container, other.container, t)!,
      fastingPercentColor: Color.lerp(
        fastingPercentColor,
        other.fastingPercentColor,
        t,
      )!,
      secondaryTextColor: Color.lerp(
        secondaryTextColor,
        other.secondaryTextColor,
        t,
      )!,
      textColor: Color.lerp(textColor, other.textColor, t)!,
      primaryTitleColor: Color.lerp(
        primaryTitleColor,
        other.primaryTitleColor,
        t,
      )!,
      secondaryContainer: Color.lerp(
        secondaryContainer,
        other.secondaryContainer,
        t,
      )!,
      iconColor: Color.lerp(iconColor, other.iconColor, t)!,
      dropdownTextColor: Color.lerp(
        dropdownTextColor,
        other.dropdownTextColor,
        t,
      )!,
      tertiaryButtonTextColor: Color.lerp(
        tertiaryButtonTextColor,
        other.tertiaryButtonTextColor,
        t,
      )!,
      tertiaryContainerColor: Color.lerp(
        tertiaryContainerColor,
        other.tertiaryContainerColor,
        t,
      )!,
      tertiaryIconColor: Color.lerp(
        tertiaryIconColor,
        other.tertiaryIconColor,
        t,
      )!,
      calendarNameColor: Color.lerp(
        calendarNameColor,
        other.calendarNameColor,
        t,
      )!,
      calendarTimeColor: Color.lerp(
        calendarTimeColor,
        other.calendarTimeColor,
        t,
      )!,
    );
  }
}

/// Type-safe access from Widget.
///   context.appColors.background
///   context.appColors.borderColor
extension AppColorsX on BuildContext {
  AppColors get appColors => Theme.of(this).extension<AppColors>()!;
}
