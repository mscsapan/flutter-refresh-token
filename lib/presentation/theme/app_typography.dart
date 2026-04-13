import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../utils/constraints.dart';

class AppTypography extends ThemeExtension<AppTypography> {
  const AppTypography({
    required this.paragraph18,
    required this.heading12,
    required this.appRegular10,
    required this.appMedium10,
    required this.appRegular12,
    required this.appMedium12,
    required this.appRegular14,
    required this.appMedium14,
    required this.appRegular16,
    required this.appMedium16,
    required this.appSemiBold16,
    required this.appRegular18,
    required this.appMedium18,
    required this.appSemiBold20,
    required this.appSemiBold22,
    required this.h1,
    required this.h2,
    required this.h4,
    required this.h5,
    required this.h6,
    required this.h7,
    required this.sub1,
    required this.bodyText,
    required this.sub2,
    required this.sub3,
    required this.sub4,
  });

  final TextStyle paragraph18;
  final TextStyle heading12;

  final TextStyle appRegular10;
  final TextStyle appMedium10;
  final TextStyle appRegular12;
  final TextStyle appMedium12;
  final TextStyle appRegular14;
  final TextStyle appMedium14;
  final TextStyle appRegular16;
  final TextStyle appMedium16;
  final TextStyle appSemiBold16;
  final TextStyle appRegular18;
  final TextStyle appMedium18;
  final TextStyle appSemiBold20;
  final TextStyle appSemiBold22;

  final TextStyle h1;
  final TextStyle h2;
  final TextStyle h4;
  final TextStyle h5;
  final TextStyle h6;
  final TextStyle h7;

  final TextStyle sub1;
  final TextStyle bodyText;
  final TextStyle sub2;
  final TextStyle sub3;
  final TextStyle sub4;

  static TextStyle _style({
    required double size,
    required double lineHeight,
    required FontWeight weight,
    Color color = blackColor,
  }) {
    return GoogleFonts.roboto(
      fontSize: size,
      height: lineHeight / size,
      fontWeight: weight,
      color: color,
    );
  }

  factory AppTypography.figma() {
    return AppTypography(
      paragraph18: _style(
        size: 18.0,
        lineHeight: 28.0,
        weight: FontWeight.w400,
      ),
      heading12: _style(size: 12.0, lineHeight: 12.0, weight: FontWeight.w400),
      appRegular10: _style(
        size: 10.0,
        lineHeight: 10.0,
        weight: FontWeight.w400,
      ),
      appMedium10: _style(
        size: 10.0,
        lineHeight: 10.0,
        weight: FontWeight.w500,
      ),
      appRegular12: _style(
        size: 12.0,
        lineHeight: 17.0,
        weight: FontWeight.w400,
      ),
      appMedium12: _style(
        size: 12.0,
        lineHeight: 20.0,
        weight: FontWeight.w500,
      ),
      appRegular14: _style(
        size: 14.0,
        lineHeight: 20.0,
        weight: FontWeight.w400,
      ),
      appMedium14: _style(
        size: 14.0,
        lineHeight: 20.0,
        weight: FontWeight.w500,
      ),
      appRegular16: _style(
        size: 16.0,
        lineHeight: 24.0,
        weight: FontWeight.w400,
      ),
      appMedium16: _style(
        size: 16.0,
        lineHeight: 24.0,
        weight: FontWeight.w500,
      ),
      appSemiBold16: _style(
        size: 16.0,
        lineHeight: 24.0,
        weight: FontWeight.w600,
      ),
      appRegular18: _style(
        size: 18.0,
        lineHeight: 26.0,
        weight: FontWeight.w400,
      ),
      appMedium18: _style(
        size: 18.0,
        lineHeight: 26.0,
        weight: FontWeight.w500,
      ),
      appSemiBold20: _style(
        size: 20.0,
        lineHeight: 28.0,
        weight: FontWeight.w600,
      ),
      appSemiBold22: _style(
        size: 22.0,
        lineHeight: 30.0,
        weight: FontWeight.w600,
      ),
      h1: _style(size: 50.0, lineHeight: 72.0, weight: FontWeight.w600),
      h2: _style(size: 38.0, lineHeight: 56.0, weight: FontWeight.w600),
      h4: _style(size: 32.0, lineHeight: 42.0, weight: FontWeight.w600),
      h5: _style(size: 28.0, lineHeight: 28.0, weight: FontWeight.w600),
      h6: _style(size: 24.0, lineHeight: 24.0, weight: FontWeight.w600),
      h7: _style(size: 20.0, lineHeight: 28.0, weight: FontWeight.w600),
      sub1: _style(size: 18.0, lineHeight: 18.0, weight: FontWeight.w500),
      bodyText: _style(size: 16.0, lineHeight: 26.0, weight: FontWeight.w400),
      sub2: _style(size: 16.0, lineHeight: 16.0, weight: FontWeight.w500),
      sub3: _style(size: 14.0, lineHeight: 14.0, weight: FontWeight.w500),
      sub4: _style(size: 12.0, lineHeight: 14.0, weight: FontWeight.w500),
    );
  }

  TextTheme toTextTheme() {
    return TextTheme(
      displayLarge: h1,
      displayMedium: h2,
      headlineMedium: h4,
      headlineSmall: h5,
      titleLarge: h6,
      titleMedium: h7,
      bodyLarge: bodyText,
      bodyMedium: appRegular14,
      bodySmall: appRegular12,
      labelLarge: appSemiBold16,
      labelMedium: appMedium14,
      labelSmall: appRegular10,
    );
  }

  @override
  AppTypography copyWith({
    TextStyle? paragraph18,
    TextStyle? heading12,
    TextStyle? appRegular10,
    TextStyle? appMedium10,
    TextStyle? appRegular12,
    TextStyle? appMedium12,
    TextStyle? appRegular14,
    TextStyle? appMedium14,
    TextStyle? appRegular16,
    TextStyle? appMedium16,
    TextStyle? appSemiBold16,
    TextStyle? appRegular18,
    TextStyle? appMedium18,
    TextStyle? appSemiBold20,
    TextStyle? appSemiBold22,
    TextStyle? h1,
    TextStyle? h2,
    TextStyle? h4,
    TextStyle? h5,
    TextStyle? h6,
    TextStyle? h7,
    TextStyle? sub1,
    TextStyle? bodyText,
    TextStyle? sub2,
    TextStyle? sub3,
    TextStyle? sub4,
  }) {
    return AppTypography(
      paragraph18: paragraph18 ?? this.paragraph18,
      heading12: heading12 ?? this.heading12,
      appRegular10: appRegular10 ?? this.appRegular10,
      appMedium10: appMedium10 ?? this.appMedium10,
      appRegular12: appRegular12 ?? this.appRegular12,
      appMedium12: appMedium12 ?? this.appMedium12,
      appRegular14: appRegular14 ?? this.appRegular14,
      appMedium14: appMedium14 ?? this.appMedium14,
      appRegular16: appRegular16 ?? this.appRegular16,
      appMedium16: appMedium16 ?? this.appMedium16,
      appSemiBold16: appSemiBold16 ?? this.appSemiBold16,
      appRegular18: appRegular18 ?? this.appRegular18,
      appMedium18: appMedium18 ?? this.appMedium18,
      appSemiBold20: appSemiBold20 ?? this.appSemiBold20,
      appSemiBold22: appSemiBold22 ?? this.appSemiBold22,
      h1: h1 ?? this.h1,
      h2: h2 ?? this.h2,
      h4: h4 ?? this.h4,
      h5: h5 ?? this.h5,
      h6: h6 ?? this.h6,
      h7: h7 ?? this.h7,
      sub1: sub1 ?? this.sub1,
      bodyText: bodyText ?? this.bodyText,
      sub2: sub2 ?? this.sub2,
      sub3: sub3 ?? this.sub3,
      sub4: sub4 ?? this.sub4,
    );
  }

  @override
  AppTypography lerp(ThemeExtension<AppTypography>? other, double t) {
    if (other is! AppTypography) return this;
    return AppTypography(
      paragraph18:
          TextStyle.lerp(paragraph18, other.paragraph18, t) ?? paragraph18,
      heading12: TextStyle.lerp(heading12, other.heading12, t) ?? heading12,
      appRegular10:
          TextStyle.lerp(appRegular10, other.appRegular10, t) ?? appRegular10,
      appMedium10:
          TextStyle.lerp(appMedium10, other.appMedium10, t) ?? appMedium10,
      appRegular12:
          TextStyle.lerp(appRegular12, other.appRegular12, t) ?? appRegular12,
      appMedium12:
          TextStyle.lerp(appMedium12, other.appMedium12, t) ?? appMedium12,
      appRegular14:
          TextStyle.lerp(appRegular14, other.appRegular14, t) ?? appRegular14,
      appMedium14:
          TextStyle.lerp(appMedium14, other.appMedium14, t) ?? appMedium14,
      appRegular16:
          TextStyle.lerp(appRegular16, other.appRegular16, t) ?? appRegular16,
      appMedium16:
          TextStyle.lerp(appMedium16, other.appMedium16, t) ?? appMedium16,
      appSemiBold16:
          TextStyle.lerp(appSemiBold16, other.appSemiBold16, t) ??
          appSemiBold16,
      appRegular18:
          TextStyle.lerp(appRegular18, other.appRegular18, t) ?? appRegular18,
      appMedium18:
          TextStyle.lerp(appMedium18, other.appMedium18, t) ?? appMedium18,
      appSemiBold20:
          TextStyle.lerp(appSemiBold20, other.appSemiBold20, t) ??
          appSemiBold20,
      appSemiBold22:
          TextStyle.lerp(appSemiBold22, other.appSemiBold22, t) ??
          appSemiBold22,
      h1: TextStyle.lerp(h1, other.h1, t) ?? h1,
      h2: TextStyle.lerp(h2, other.h2, t) ?? h2,
      h4: TextStyle.lerp(h4, other.h4, t) ?? h4,
      h5: TextStyle.lerp(h5, other.h5, t) ?? h5,
      h6: TextStyle.lerp(h6, other.h6, t) ?? h6,
      h7: TextStyle.lerp(h7, other.h7, t) ?? h7,
      sub1: TextStyle.lerp(sub1, other.sub1, t) ?? sub1,
      bodyText: TextStyle.lerp(bodyText, other.bodyText, t) ?? bodyText,
      sub2: TextStyle.lerp(sub2, other.sub2, t) ?? sub2,
      sub3: TextStyle.lerp(sub3, other.sub3, t) ?? sub3,
      sub4: TextStyle.lerp(sub4, other.sub4, t) ?? sub4,
    );
  }
}

extension AppTypographyContextX on BuildContext {
  AppTypography get appTypography {
    final extension = Theme.of(this).extension<AppTypography>();
    return extension ?? AppTypography.figma();
  }
}
