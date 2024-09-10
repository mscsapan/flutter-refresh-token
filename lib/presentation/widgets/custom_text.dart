import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../utils/constraints.dart';
import '../utils/utils.dart';

class CustomText extends StatelessWidget {
  const CustomText({
    super.key,
    required this.text,
    this.fontWeight = FontWeight.w400,
    this.fontSize = 14.0,
    this.height = 1.4,
    this.maxLine = 6,
    this.color = blackColor,
    this.decoration = TextDecoration.none,
    this.overflow = TextOverflow.ellipsis,
    this.textAlign = TextAlign.start,
    this.isRoboto = true,
    this.fontFamily = bold700,
  });
  final String text;
  final Color color;
  final double fontSize;
  final FontWeight fontWeight;
  final double height;
  final TextAlign textAlign;
  final int maxLine;
  final TextOverflow overflow;
  final TextDecoration decoration;
  final bool isRoboto;
  final String fontFamily;

  @override
  Widget build(BuildContext context) {
    if (isRoboto) {
      return Padding(
        padding: Utils.only(bottom: 2.0),
        child: Text(
          text,
          textAlign: textAlign,
          overflow: overflow,
          maxLines: maxLine,
          style: GoogleFonts.roboto(
            fontWeight: fontWeight,
            fontSize: fontSize.sp,
            color: color,
            height: height.h,
            decoration: decoration,
          ),
        ),
      );
    } else {
      return Text(
        text,
        textAlign: textAlign,
        overflow: overflow,
        maxLines: maxLine,
        style: TextStyle(
          fontWeight: fontWeight,
          fontSize: fontSize.sp,
          color: color,
          fontFamily: fontFamily,
          height: height.h,
          decoration: decoration,
        ),
      );
    }
  }
}
