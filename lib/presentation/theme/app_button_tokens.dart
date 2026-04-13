import 'dart:ui';

import 'package:flutter/material.dart';

import '../utils/constraints.dart';
import 'app_typography.dart';

class AppButtonTokens extends ThemeExtension<AppButtonTokens> {
  const AppButtonTokens({
    required this.height,
    required this.radius,
    required this.horizontalPadding,
    required this.primaryBackground,
    required this.primaryForeground,
    required this.outlineBorder,
    required this.outlineForeground,
    required this.iconBackground,
    required this.iconForeground,
    required this.labelStyle,
  });

  final double height;
  final double radius;
  final double horizontalPadding;
  final Color primaryBackground;
  final Color primaryForeground;
  final Color outlineBorder;
  final Color outlineForeground;
  final Color iconBackground;
  final Color iconForeground;
  final TextStyle labelStyle;

  factory AppButtonTokens.defaults(BuildContext context) {
    final typography = context.appTypography;
    return AppButtonTokens(
      height: 44.0,
      radius: 4.0,
      horizontalPadding: 16.0,
      primaryBackground: blackColor,
      primaryForeground: whiteColor,
      outlineBorder: primaryColor,
      outlineForeground: blackColor,
      iconBackground: blackColor,
      iconForeground: whiteColor,
      labelStyle: typography.appMedium16,
    );
  }

  factory AppButtonTokens.fallback() {
    return AppButtonTokens(
      height: 44.0,
      radius: 4.0,
      horizontalPadding: 16.0,
      primaryBackground: blackColor,
      primaryForeground: whiteColor,
      outlineBorder: primaryColor,
      outlineForeground: blackColor,
      iconBackground: blackColor,
      iconForeground: whiteColor,
      labelStyle: const TextStyle(
        fontSize: 16.0,
        height: 1.5,
        fontWeight: FontWeight.w500,
        color: whiteColor,
      ),
    );
  }

  @override
  AppButtonTokens copyWith({
    double? height,
    double? radius,
    double? horizontalPadding,
    Color? primaryBackground,
    Color? primaryForeground,
    Color? outlineBorder,
    Color? outlineForeground,
    Color? iconBackground,
    Color? iconForeground,
    TextStyle? labelStyle,
  }) {
    return AppButtonTokens(
      height: height ?? this.height,
      radius: radius ?? this.radius,
      horizontalPadding: horizontalPadding ?? this.horizontalPadding,
      primaryBackground: primaryBackground ?? this.primaryBackground,
      primaryForeground: primaryForeground ?? this.primaryForeground,
      outlineBorder: outlineBorder ?? this.outlineBorder,
      outlineForeground: outlineForeground ?? this.outlineForeground,
      iconBackground: iconBackground ?? this.iconBackground,
      iconForeground: iconForeground ?? this.iconForeground,
      labelStyle: labelStyle ?? this.labelStyle,
    );
  }

  @override
  AppButtonTokens lerp(ThemeExtension<AppButtonTokens>? other, double t) {
    if (other is! AppButtonTokens) return this;
    return AppButtonTokens(
      height: lerpDouble(height, other.height, t) ?? height,
      radius: lerpDouble(radius, other.radius, t) ?? radius,
      horizontalPadding:
          lerpDouble(horizontalPadding, other.horizontalPadding, t) ??
          horizontalPadding,
      primaryBackground:
          Color.lerp(primaryBackground, other.primaryBackground, t) ??
          primaryBackground,
      primaryForeground:
          Color.lerp(primaryForeground, other.primaryForeground, t) ??
          primaryForeground,
      outlineBorder:
          Color.lerp(outlineBorder, other.outlineBorder, t) ?? outlineBorder,
      outlineForeground:
          Color.lerp(outlineForeground, other.outlineForeground, t) ??
          outlineForeground,
      iconBackground:
          Color.lerp(iconBackground, other.iconBackground, t) ?? iconBackground,
      iconForeground:
          Color.lerp(iconForeground, other.iconForeground, t) ?? iconForeground,
      labelStyle: TextStyle.lerp(labelStyle, other.labelStyle, t) ?? labelStyle,
    );
  }
}

extension AppButtonTokensContextX on BuildContext {
  AppButtonTokens get appButtonTokens {
    final extension = Theme.of(this).extension<AppButtonTokens>();
    return extension ?? AppButtonTokens.fallback();
  }
}
