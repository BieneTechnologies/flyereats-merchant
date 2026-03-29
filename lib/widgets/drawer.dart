import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:merchant_delivery/providers/order_provider.dart';
import 'package:merchant_delivery/screens/change_password.dart';
import 'package:merchant_delivery/screens/custom_page_screen.dart';
import 'package:merchant_delivery/screens/faq/faq.dart';
import 'package:merchant_delivery/screens/help_support_screen.dart';
import 'package:merchant_delivery/screens/merchant_earnings/merchant_earnings.dart';
import 'package:merchant_delivery/screens/my_ratings/my_ratings_screen.dart';

import 'package:merchant_delivery/screens/payout_settlement/payout_settlement.dart';
import 'package:merchant_delivery/screens/top_selling_report/top_selling_report.dart';
import 'package:merchant_delivery/utils/app_theme.dart';
import 'package:merchant_delivery/utils/constants.dart';
import 'package:merchant_delivery/utils/hex_color.dart';
import 'package:merchant_delivery/utils/util_functions.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class MyDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final bool enableEditMenu =
        Provider.of<OrderProvider>(context, listen: true).enableEditMenu;
    return Drawer(
      child: SafeArea(
        child: Column(
          children: <Widget>[
            Flexible(
              child: ListView(
                children: <Widget>[
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => TopSellingReportScreen()));
                    },
                    child: ListTile(
                        title: Text("Top Selling Report", style: _textStyle),
                        trailing: _icon),
                  ),
                  _divider,
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => MerchantEarningsScreen()));
                    },
                    child: ListTile(
                        title: Text("Merchant Earnings", style: _textStyle),
                        trailing: _icon),
                  ),
                  _divider,
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                        Navigator.push(
                           context,
                            MaterialPageRoute(
                                builder: (context) =>   PayoutSettlementScreen()  ));
                    },
                    child: ListTile(
                        title: Text("Payout settlement", style: _textStyle),
                        trailing: _icon),
                  ),
                  _divider,
                  enableEditMenu
                      ? Column(
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.of(context).pop();
                                Navigator.pushNamed(context, '/editMenu');
                              },
                              child: ListTile(
                                  title: Text("Edit Menu", style: _textStyle),
                                  trailing: _icon),
                            ),
                            _divider,
                          ],
                        )
                      : Container(),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => MyRatingsScreen()));
                    },
                    child: ListTile(
                        title: Text("My ratings", style: _textStyle),
                        trailing: _icon),
                  ),
                  _divider,
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ChangePasswordScreen()));
                    },
                    child: ListTile(
                        title: Text("Change Password", style: _textStyle),
                        trailing: _icon),
                  ),
                  _divider,
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => HelpSupportScreen()));
                    },
                    child: ListTile(
                        title: Text("Help & Support", style: _textStyle),
                        trailing: _icon),
                  ),
                  _divider,
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => CustomPageScreen(
                                    pageTitle: PageTitle.TERMSANDCONDITIONS,
                                  )));
                    },
                    child: ListTile(
                        title: Text("T & C", style: _textStyle),
                        trailing: _icon),
                  ),
                  _divider,
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => CustomPageScreen(
                                    pageTitle: PageTitle.PRIVACYPOLICY,
                                  )));
                    },
                    child: ListTile(
                        title: Text("Privacy Policy", style: _textStyle),
                        trailing: _icon),
                  ),
                  _divider,
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => FAQScreen()));
                    },
                    child: ListTile(
                        title: Text("FAQ`s", style: _textStyle),
                        trailing: _icon),
                  ),
                  _divider,
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Column(
                children: <Widget>[
                  _divider,
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                      logout(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Text(
                        "Logout",
                        style: TextStyle(
                            color: AppTheme.textColor.withOpacity(0.5)),
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  TextStyle _textStyle = new TextStyle(
    fontSize: 18,
    color: AppTheme.textColor,
    fontWeight: FontWeight.w500,
  );
  Icon _icon = new Icon(
    Icons.arrow_forward_ios,
    color: AppTheme.textColor,
    size: 18,
  );
  Padding _divider = new Padding(
    padding: const EdgeInsets.symmetric(horizontal: 14.0),
    child: Divider(color: HexColor("#D8D8D8"), thickness: 1.5, height: 0),
  );
}
