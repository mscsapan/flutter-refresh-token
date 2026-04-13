import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_button_tokens.dart';
import '../theme/app_typography.dart';
import '../utils/constraints.dart';
import '../utils/utils.dart';

class MyTheme {
  static final borderRadius = BorderRadius.circular(6.0);
  static final appTypography = AppTypography.figma();
  static final appButtonTokens = AppButtonTokens.fallback().copyWith(
    labelStyle: appTypography.appMedium16,
  );
  static final theme = ThemeData(
    brightness: Brightness.light,
    primaryColor: whiteColor,
    scaffoldBackgroundColor: whiteColor,
    extensions: [appTypography, appButtonTokens],
    bottomSheetTheme: const BottomSheetThemeData(backgroundColor: whiteColor),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      centerTitle: true,
      scrolledUnderElevation: 0.0,
      titleTextStyle: GoogleFonts.roboto(
        color: blackColor,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      iconTheme: const IconThemeData(color: blackColor),
      elevation: 0,
    ),
    textTheme: appTypography.toTextTheme(),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 42.0),
        backgroundColor: whiteColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 42.0),
        side: const BorderSide(color: primaryColor, width: 1.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
      ),
    ),
    textButtonTheme: const TextButtonThemeData(
      style: ButtonStyle(
        shadowColor: WidgetStatePropertyAll(transparent),
        elevation: WidgetStatePropertyAll(0.0),
        iconSize: WidgetStatePropertyAll(20.0),
        splashFactory: NoSplash.splashFactory,
        overlayColor: WidgetStatePropertyAll((transparent)),
        padding: WidgetStatePropertyAll(EdgeInsets.zero),
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      elevation: 3,
      backgroundColor: whiteColor,
      showUnselectedLabels: true,
      selectedLabelStyle: GoogleFonts.roboto(
        fontWeight: FontWeight.w400,
        color: grayColor,
        fontSize: 14.0,
      ),
      unselectedLabelStyle: GoogleFonts.roboto(
        fontWeight: FontWeight.w400,
        color: blackColor,
        fontSize: 14.0,
      ),
      selectedItemColor: grayColor,
      unselectedItemColor: blackColor,
    ),
    inputDecorationTheme: InputDecorationTheme(
      isDense: true,
      hintStyle: GoogleFonts.roboto(
        fontWeight: FontWeight.w400,
        fontSize: 14.0,
        color: const Color(0xFFBABABA),
      ),
      labelStyle: GoogleFonts.roboto(
        fontWeight: FontWeight.w400,
        fontSize: 15.0,
        color: blackColor,
      ),
      contentPadding: Utils.symmetric(v: 6.0, h: 0.0),
      border: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: const BorderSide(color: borderColor, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: const BorderSide(color: borderColor, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: const BorderSide(color: borderColor, width: 1),
      ),
      errorStyle: GoogleFonts.roboto(
        color: redColor,
        fontSize: 12.0,
        fontWeight: FontWeight.w400,
      ),
      fillColor: grayBackgroundColor,
      filled: true,
      //focusColor: primaryColor,
    ),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: blackColor,
      selectionColor: blueColor.withValues(alpha: 0.4),
      selectionHandleColor: primaryColor,
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: primaryColor,
    ),
  );
}
