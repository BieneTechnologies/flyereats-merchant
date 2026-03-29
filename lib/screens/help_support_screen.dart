import 'package:flutter/material.dart';
import 'package:merchant_delivery/utils/app_theme.dart';
import 'package:merchant_delivery/utils/constants.dart';
import 'package:merchant_delivery/utils/hex_color.dart';
import 'package:merchant_delivery/widgets/custom_appbar.dart';

class HelpSupportScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.mainBlackColor,
      appBar: MyAppbar(title: "Help & Support"),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: AppTheme.upperRoundedDecor,
        padding: const EdgeInsets.only(top: 37, left: 20, right: 20),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "For any Support",
                style: new TextStyle(color: HexColor('#3C3C3C'), fontWeight: FontWeight.w700, fontSize: 24),
              ),
              SizedBox(height: 14),
              Text("Kindly send your queries to ", style: new TextStyle(color: HexColor("#9C9C9C"), fontSize: 18)),
              SizedBox(height: 14),
              Text(
                  // Constants.baseUrl.contains("flyereats.in")
                  Constants.baseUrl.contains("137.59.54.62")
                  ?"info@flyereats.in":"info@flyereats.ph", style: new TextStyle(color: HexColor('#3C3C3C'), fontWeight: FontWeight.w700, fontSize: 24)),
            ],
          ),
        ),
      ),
    );
  }
}
