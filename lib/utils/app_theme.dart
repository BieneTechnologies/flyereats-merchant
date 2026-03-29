import 'package:flutter/material.dart';

import './hex_color.dart';

class AppTheme {
  AppTheme._();

  static Color mainBlackColor = HexColor("#000000");
  static Color mainWhiteColor = HexColor("#FFFFFF");
  static Color blueColor = HexColor("#0000FF");
  static Color formBorderColor = HexColor("#D3D3D3");
  static Color textColor = HexColor("#313233");
  static Color btnColor = HexColor("#FFB531");

  static double formCornerRadius = 8;

  static BoxDecoration upperRoundedDecor = BoxDecoration(
    color: AppTheme.mainWhiteColor,
    borderRadius: BorderRadius.only(
      topLeft: Radius.circular(30),
      topRight: Radius.circular(30),
    ),
  );

  static ShapeBorder bottomSheetShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.only(
      topLeft: Radius.circular(30),
      topRight: Radius.circular(30),
    ),
  );

   static Theme calendarTheme(BuildContext context, Widget child) {
    return Theme(
      data: ThemeData.light().copyWith(
        primaryColor: HexColor("#FFB531"),
        accentColor: HexColor("#FFB531"),
        colorScheme: ColorScheme.light(primary: HexColor("#FFB531")),
        buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
      ),
      child: child,
    );
  }
}
