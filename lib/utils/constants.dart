import 'package:flutter/cupertino.dart';
import 'package:merchant_delivery/models/new_order_model.dart';

class Constants {
  // static const baseUrl =
  //   "http://live.flyereats.in/merchantapp/api/";  //  "test server";

  //static const baseUrl =
  //     "https://flyereats.in/merchantapp/api/";  //  "in server";

  // static const baseUrl = "http://137.59.54.62/api/";
  static const baseUrl = "https://demo.flyereats.in/api/";
  // static const baseUrl =
  //      "https://flyereats.ph/merchantapp/api/";  //  "ph server";

  /* static const baseUrl =
      "https://pollachiarea.com/flyereats/merchantapp/api/";
*/

  static const responseSuccess = 1;
  static const responseError = 2;
  static const responseLogout = 3;

  /*Shared preferences */
  static const token = "token";
  static const username = "username";
  static const restaurant_name = "restaurant_name";
  static const contact_email = "contact_email";
  static const user_type = "user_type";
  static const merchant_id = "merchant_id";
  static const merchant_user_id = "merchant_user_id";
  static const isLoggedIn = "isLoggedIn";
  static const isFirstInstall = "isFirstInstall";

  static const optDate = "OptDt/";
  static const fixDate = "FixDt/";
  static const rangeDate = "RngDt/";
  static const fcmToken = "fcmToken";
  static String oldFCMToken = '';
  static bool isOrderStatusChanged = false;
  static BuildContext appContext;
  static NewOrderModel orderModel;
  static bool isTimerStarted = false;
  static bool isNotifReceived = false;
  static bool isNewOrderReceivedByFCM = false;
}

enum PageTitle {
  FAQ,
  TERMSANDCONDITIONS,
  PRIVACYPOLICY,
}
enum EditClickType {
  ITEM,
  CATEGORY,
}
