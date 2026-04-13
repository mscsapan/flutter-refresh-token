import 'package:flutter/material.dart';

import '../theme/app_typography.dart';
import '../utils/constraints.dart';

enum AppTextVariant {
  paragraph18,
  heading12,
  appRegular10,
  appMedium10,
  appRegular12,
  appMedium12,
  appRegular14,
  appMedium14,
  appRegular16,
  appMedium16,
  appSemiBold16,
  appRegular18,
  appMedium18,
  appSemiBold20,
  appSemiBold22,
  h1,
  h2,
  h4,
  h5,
  h6,
  h7,
  sub1,
  body,
  sub2,
  sub3,
  sub4,
}

class CustomText extends StatelessWidget {
  const CustomText({
    super.key,
    required this.text,
    this.variant = AppTextVariant.body,
    this.style,
    this.fontWeight,
    this.fontSize,
    this.height,
    this.maxLine,
    this.color,
    this.decoration,
    this.overflow,
    this.textAlign = TextAlign.start,
  });

  const CustomText.h1({
    super.key,
    required this.text,
    this.style,
    this.fontWeight,
    this.fontSize,
    this.height,
    this.maxLine,
    this.color,
    this.decoration,
    this.overflow,
    this.textAlign = TextAlign.start,
  }) : variant = AppTextVariant.h1;

  const CustomText.body({
    super.key,
    required this.text,
    this.style,
    this.fontWeight,
    this.fontSize,
    this.height,
    this.maxLine,
    this.color,
    this.decoration,
    this.overflow,
    this.textAlign = TextAlign.start,
  }) : variant = AppTextVariant.body;

  const CustomText.sub1({
    super.key,
    required this.text,
    this.style,
    this.fontWeight,
    this.fontSize,
    this.height,
    this.maxLine,
    this.color,
    this.decoration,
    this.overflow,
    this.textAlign = TextAlign.start,
  }) : variant = AppTextVariant.sub1;

  final String text;
  final AppTextVariant variant;
  final TextStyle? style;
  final Color? color;
  final double? fontSize;
  final FontWeight? fontWeight;
  final double? height;
  final TextAlign textAlign;
  final int? maxLine;
  final TextOverflow? overflow;
  final TextDecoration? decoration;

  TextStyle _resolveBaseStyle(BuildContext context) {
    final t = context.appTypography;
    switch (variant) {
      case AppTextVariant.paragraph18:
        return t.paragraph18;
      case AppTextVariant.heading12:
        return t.heading12;
      case AppTextVariant.appRegular10:
        return t.appRegular10;
      case AppTextVariant.appMedium10:
        return t.appMedium10;
      case AppTextVariant.appRegular12:
        return t.appRegular12;
      case AppTextVariant.appMedium12:
        return t.appMedium12;
      case AppTextVariant.appRegular14:
        return t.appRegular14;
      case AppTextVariant.appMedium14:
        return t.appMedium14;
      case AppTextVariant.appRegular16:
        return t.appRegular16;
      case AppTextVariant.appMedium16:
        return t.appMedium16;
      case AppTextVariant.appSemiBold16:
        return t.appSemiBold16;
      case AppTextVariant.appRegular18:
        return t.appRegular18;
      case AppTextVariant.appMedium18:
        return t.appMedium18;
      case AppTextVariant.appSemiBold20:
        return t.appSemiBold20;
      case AppTextVariant.appSemiBold22:
        return t.appSemiBold22;
      case AppTextVariant.h1:
        return t.h1;
      case AppTextVariant.h2:
        return t.h2;
      case AppTextVariant.h4:
        return t.h4;
      case AppTextVariant.h5:
        return t.h5;
      case AppTextVariant.h6:
        return t.h6;
      case AppTextVariant.h7:
        return t.h7;
      case AppTextVariant.sub1:
        return t.sub1;
      case AppTextVariant.body:
        return t.bodyText;
      case AppTextVariant.sub2:
        return t.sub2;
      case AppTextVariant.sub3:
        return t.sub3;
      case AppTextVariant.sub4:
        return t.sub4;
    }
  }

  @override
  Widget build(BuildContext context) {
    final baseStyle = style ?? _resolveBaseStyle(context);
    final resolvedStyle = baseStyle.copyWith(
      fontWeight: fontWeight,
      fontSize: fontSize,
      height: height,
      color: color ?? baseStyle.color ?? blackColor,
      decoration: decoration,
    );

    return Text(
      text,
      textAlign: textAlign,
      overflow: overflow ?? (maxLine != null ? TextOverflow.ellipsis : null),
      maxLines: maxLine,
      style: resolvedStyle,
    );
  }
}
