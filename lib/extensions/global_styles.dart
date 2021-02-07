import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GlobalStyles {
  static TextStyle defaultAppBarTitleTextStyle(
          {Color textColor = Colors.black}) =>
      GoogleFonts.montserrat(
        color: textColor,
        fontSize: 20,
        fontWeight: FontWeight.w500,
      );

  static TextStyle defaultTitleTextStyle({Color textColor = Colors.black}) =>
      GoogleFonts.montserrat(
        color: textColor,
        fontSize: 22,
        fontWeight: FontWeight.w700,
      );

  static TextStyle defaultBodyTextStyle({Color textColor = Colors.black}) =>
      GoogleFonts.montserrat(
        color: textColor,
        fontSize: 12,
      );

  static TextStyle defaultListTileTitleTextStyle(
          {Color textColor = Colors.black, double fontSize = 18}) =>
      GoogleFonts.montserrat(
        color: textColor,
        fontSize: fontSize,
        fontWeight: FontWeight.w600,
      );

  static TextStyle defaultListTileDescriptionTextStyle(
          {Color textColor = Colors.black}) =>
      GoogleFonts.montserrat(
        color: textColor,
        fontSize: 10,
      );
}
