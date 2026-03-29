import 'package:flutter/material.dart';
import 'package:merchant_delivery/screens/food_menu_on_off/food_menu_on_off_screen.dart';
import 'package:merchant_delivery/utils/app_theme.dart';

class CustomAppbar extends StatelessWidget with PreferredSizeWidget {
  final String title;

  CustomAppbar({@required this.title});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppTheme.mainBlackColor,
      elevation: 0,
      leading: GestureDetector(
        onTap: () {
          Scaffold.of(context).openDrawer();
        },
        child: Container(
          child: Image.asset('assets/images/menu_icon.png'),
        ),
      ),
      title: Text(title ?? ""),
      centerTitle: true,
      actions: <Widget>[
        GestureDetector(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => MenuOnOffScreen()));
          },
          child: Container(
            child: Image.asset('assets/images/on_off_icon.png'),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight + 10);
}

class MyAppbar extends StatelessWidget with PreferredSizeWidget {
  final String title;

  MyAppbar({@required this.title});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppTheme.mainBlackColor,
      elevation: 0,
      title: Text(title ?? ""),
      centerTitle: true,
      leading: GestureDetector(
        onTap: () {
          Navigator.pop(context);
        },
        child: Icon(Icons.keyboard_arrow_left),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
