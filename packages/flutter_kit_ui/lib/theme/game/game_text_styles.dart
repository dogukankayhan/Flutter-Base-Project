import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'game_colors.dart';

/// Uygulama genelinde kullanılan metin stilleri.
class AppTextStyles {
  AppTextStyles._();

  static TextStyle get label => TextStyle(
        color: AppColors.textMuted,
        fontSize: 10.sp,
        letterSpacing: 0.5.w,
      );

  static TextStyle get labelSmall => TextStyle(
        color: AppColors.textDisabled,
        fontSize: 9.sp,
      );

  static TextStyle get value => TextStyle(
        color: AppColors.textPrimary,
        fontSize: 12.sp,
        fontWeight: FontWeight.bold,
      );

  static TextStyle get valueAmber => TextStyle(
        color: Colors.amber,
        fontSize: 12.sp,
        fontWeight: FontWeight.bold,
      );

  static TextStyle get valueGreen => TextStyle(
        color: AppColors.success,
        fontSize: 12.sp,
        fontWeight: FontWeight.bold,
      );

  static TextStyle get panelTitle => TextStyle(
        color: Colors.white,
        fontSize: 22.sp,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2.w,
      );

  static TextStyle get cardHeader => TextStyle(
        color: AppColors.eraOrange,
        fontSize: 13.sp,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.8.w,
      );

  static TextStyle get requirementLabel => TextStyle(
        color: AppColors.textDisabled,
        fontSize: 11.sp,
      );

  static TextStyle get requirementValue => TextStyle(
        color: AppColors.textPrimary,
        fontSize: 11.sp,
        fontWeight: FontWeight.bold,
      );

  static TextStyle get rankName => TextStyle(
        color: AppColors.textPrimary,
        fontSize: 12.sp,
        fontWeight: FontWeight.bold,
      );

  static TextStyle get rankSub => TextStyle(
        color: Colors.grey,
        fontSize: 10.sp,
      );

  static TextStyle get navLabel => TextStyle(
        fontSize: 10.sp,
        height: 1.3,
        letterSpacing: 0.5.w,
      );

  static TextStyle get bottomNotif => TextStyle(
        color: AppColors.gold,
        fontSize: 11.sp,
        fontWeight: FontWeight.w500,
      );

  static TextStyle get buttonLabel => TextStyle(
        color: AppColors.textPrimary,
        fontSize: 12.sp,
        fontWeight: FontWeight.bold,
      );
}
