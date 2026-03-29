import 'dart:io' show Platform, exit;

import 'package:device_info/device_info.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:merchant_delivery/main.dart';
import 'package:merchant_delivery/utils/app_theme.dart';
import 'package:merchant_delivery/utils/hex_color.dart';
import 'package:shared_preferences/shared_preferences.dart';

String getDevicePlatform() {
  if (Platform.isAndroid) {
    return "ANDROID";
  } else if (Platform.isIOS) {
    return "IOS";
  }
  return "OTHER";
}

void showMyFlushbar(BuildContext context, String message) {
  Flushbar(
    maxWidth: MediaQuery.of(context).size.width * 0.85,
    borderRadius: 25,
    margin: const EdgeInsets.only(bottom: 25),
    duration: Duration(seconds: 3),
    messageText: Text(
      message,
      textAlign: TextAlign.center,
      style: TextStyle(
        color: AppTheme.mainWhiteColor,
      ),
    ),
  )..show(context);
}

void showLoadingDialog(BuildContext context, [String text = "Loading"]) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          height: MediaQuery.of(context).size.height / 5,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: AppTheme.mainWhiteColor,
          ),
          child: Center(
            child: new Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                new CircularProgressIndicator(
                    valueColor:
                        new AlwaysStoppedAnimation<Color>(Colors.orangeAccent)),
                Padding(padding: const EdgeInsets.only(left: 25)),
                new Text(text),
              ],
            ),
          ),
        ),
      );
    },
  );
}

Widget loadingWidget(BuildContext context) {
  return Center(
    child: new Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        new CircularProgressIndicator(
            valueColor: new AlwaysStoppedAnimation<Color>(Colors.orangeAccent)),
        Padding(padding: const EdgeInsets.only(left: 25)),
        new Text("Loading"),
      ],
    ),
  );
}

Color getStatusColor(String status) {
  if (status == "successful" || status == "delivered") {
    return HexColor("#079F5A");
  } else if (status == "pending") {
    return HexColor("#E67B19");
  } else if (status == "cancelled" || status == "decline") {
    return HexColor("#FF0000");
  } else if (status == "accepted") {
    return HexColor("#FFB531");
  } else {
    return Colors.grey;
  }
}

Future<bool> onWillPop(BuildContext bc) async {
  final alertDialogAndroid = new AlertDialog(
    title: new Text("Are you sure ?"),
    content: new Text("Do you want to quit app"),
    actions: <Widget>[
      new FlatButton(
        onPressed: () => Navigator.of(bc).pop(false),
        child: new Text("No"),
      ),
      new FlatButton(
        onPressed: () async {
          debugPrint("logout func call");

          exit(0);
        },
        child: new Text("Yes"),
      ),
    ],
  );

  final alertDialogIos = new CupertinoAlertDialog(
    title: new Text("Are you sure ?"),
    content: Container(
      height: 60,
      child: Center(
        child: new Text("Do you want to quit app"),
      ),
    ),
    actions: <Widget>[
      CupertinoDialogAction(
        isDefaultAction: true,
        child: FlatButton(
          onPressed: () async {
            debugPrint("logout func call");
          },
          child: new Text("Yes"),
        ),
      ),
      CupertinoDialogAction(
        child: FlatButton(
          onPressed: () => Navigator.of(bc).pop(false),
          child: new Text("No"),
        ),
      )
    ],
  );

  return (await showDialog(
        context: bc,
        builder: (context) {
          return Platform.isIOS ? alertDialogIos : alertDialogAndroid;
        },
      )) ??
      false;
}

Future<void> logout(BuildContext context) async {
  var route = ModalRoute.of(context);

  if (route != null) {
    print(route.settings.name);
  }
  SharedPreferences prefs = await SharedPreferences.getInstance();
 // timer.cancel();
  prefs.clear();
  fcm.deleteToken();
  Navigator.pushNamed(context, '/login');
}

class UtilFun {
  static showToast(String msg) {
    print("My Toast $msg");
    Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_LONG,
      timeInSecForIosWeb: 1,
    );
  }
}


Future<int> getAndroidSdk() async {
  var androidInfo = await DeviceInfoPlugin().androidInfo;
  var release = androidInfo.version.release;
  var sdkInt = androidInfo.version.sdkInt;
  var manufacturer = androidInfo.manufacturer;
  var model = androidInfo.model;
  print('Android $release (SDK $sdkInt), $manufacturer $model');

  return sdkInt;
}
