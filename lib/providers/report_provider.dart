import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:file_utils/file_utils.dart';
import 'package:flushbar/flushbar_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:merchant_delivery/models/merchant_earning_model.dart';
import 'package:merchant_delivery/models/sales_report_model.dart';
import 'package:merchant_delivery/providers/base_provider.dart';
import 'package:merchant_delivery/utils/constants.dart';
import 'package:merchant_delivery/utils/util_functions.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as path;

import '../main.dart';
import '../utils/constants.dart';

class ReportProvider extends BaseProvider {
  Future<SalesReportModel> getSalesReport(BuildContext context, String dateType,
      String startDate, String endDate) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final parameters = {
        'json': true,
        'api_key': "flyereats",
        'token': prefs.getString(Constants.token),
        'mtid': prefs.getString(Constants.merchant_id),
        'user_type': prefs.getString(Constants.user_type),
        'date_type': dateType,
        'start_date': startDate,
        'end_date': endDate,
      };

      debugPrint("salesReport params: $parameters");
//      today
//      weekly
//      monthly
//      fixed
//      range
      Response response = await postData(
          context: context, url: "salesReport", data: parameters);

      if (response != null && response.data != null) {
        final jsonResponse = json.decode(response.data);
        final responseCode = jsonResponse["code"];
        final message = jsonResponse["msg"];
        if (responseCode == Constants.responseSuccess) {
          final saleReport = jsonResponse['details'];

          debugPrint("salesReport: $saleReport");
          final saleReportModel = SalesReportModel.fromJson(saleReport);
          for (var model in saleReportModel.categoryList) {
            model.color = Color((Random().nextDouble() * 0xFFFFFF).toInt())
                .withOpacity(1.0);
          }
          for (var model in saleReportModel.items) {
            model.color = Color((Random().nextDouble() * 0xFFFFFF).toInt())
                .withOpacity(1.0);
          }
          return saleReportModel;
        } else if (responseCode == Constants.responseLogout) {
          logout(context);
          throw message;
        } else {
          showMyFlushbar(context, message);
          throw "Error Occurred";
        }
      }
      throw "Error Occurred";
    } catch (e) {
      debugPrint("error $e");
      throw "Error Occurred";
    }
  }

  Future<MerchantEarningModel> getMerchantEarningReport(BuildContext context,
      String dateType, String startDate, String endDate) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final parameters = {
        'json': true,
        'api_key': "flyereats",
        'token': prefs.getString(Constants.token),
        'mtid': prefs.getString(Constants.merchant_id),
        'user_type': prefs.getString(Constants.user_type),
        'date_type': dateType,
        'start_date': startDate,
        'end_date': endDate,
      };

//      today
//      weekly
//      monthly
//      fixed
//      range

      Response response = await postData(
          context: context, url: "merchantEarnings", data: parameters);

      print("mercahnt earninggg$response");

      if (response != null && response.data != null) {
        final jsonResponse = json.decode(response.data);
        final responseCode = jsonResponse["code"];
        final message = jsonResponse["msg"];
        if (responseCode == Constants.responseSuccess) {
          final earningReport = jsonResponse['details'];

          return MerchantEarningModel.fromJson(earningReport);
        } else if (responseCode == Constants.responseLogout) {
          logout(context);
          throw message;
        } else {
          showMyFlushbar(context, message);
          throw "Error Occurred";
        }
      }
      throw "Error Occurred";
    } catch (e) {
      debugPrint("error $e");
      throw "Error Occurred";
    }
  }

  Future<bool> downloadOrderDetails(
      BuildContext context, String orderId) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      Directory pathDir = await getApplicationDocumentsDirectory();
      final savePath = path.join(pathDir.path, "order_" + orderId + ".pdf");

      String _link =
          Constants.baseUrl+"/downloadOrderDetails?json=true&api_key=flyereats&token=" +
              prefs.getString(Constants.token) +
              "&mtid=" +
              prefs.getString(Constants.merchant_id) +
              "&user_type=" +
              prefs.getString(Constants.user_type) +
              "&order_id=" +
              orderId;

      Dio dio = Dio();
      String dirloc = "";

      FileUtils.mkdir([dirloc]);
      await dio.download(_link, savePath);


      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
              "kmrs_merchant_channel", "Orders", "This is my channel"
      );
      const NotificationDetails platformChannelSpecifics =
          NotificationDetails(android: androidPlatformChannelSpecifics);

      fltrNotification.show(0, "Flyer Eats - Download",
          "Order details downloaded.", platformChannelSpecifics,
          payload: savePath);

      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<int> downloadInvoice(BuildContext context, String dateType,
      var startDate, var endDate) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      String _link =
          Constants.baseUrl+"/downloadInvoice?json=true&api_key=flyereats&token=" +
              prefs.getString(Constants.token) +
              "&mtid=" +
              prefs.getString(Constants.merchant_id) +
              "&user_type=" +
              prefs.getString(Constants.user_type) +
              "&date_type=" +
              dateType +
              "&start_date=" +
              startDate +
              "&end_date=" +
              endDate;

      print("paran${prefs.getString(Constants.token)}");
      print("mtid${prefs.getString(Constants.merchant_id)}");
      print("user_type${prefs.getString(Constants.user_type)}");

      print("date_type$dateType");

      print("start_date$startDate");

      print("end_date$endDate");


      Dio dio = Dio();
      String dirloc = "";
      Directory pathDir;
      if (Platform.isAndroid) {
        // dirloc = "/sdcard/download/";
        dirloc = "/storage/emulated/0/Download'";
        pathDir = Directory('/storage/emulated/0/Download');
      } else {
        dirloc = (await getApplicationDocumentsDirectory()).path;
        pathDir = await getApplicationDocumentsDirectory();
      }

      pathDir = await getApplicationDocumentsDirectory();
      final savePath =
          path.join(pathDir.path, "MerchantPayoutInvoice_" + endDate + ".pdf");
      print("link$_link");
      print("path$savePath");
      FileUtils.mkdir([dirloc]);
      Response resp = await dio.download(_link, savePath);

      if (resp.statusCode == 200) {
        const AndroidNotificationDetails androidPlatformChannelSpecifics =
            AndroidNotificationDetails(
                "kmrs_merchant_channel", "Orders", "This is my channel"
        );
        const NotificationDetails platformChannelSpecifics =
            NotificationDetails(android: androidPlatformChannelSpecifics);

        fltrNotification.show(0, "Flyer Eats - Download",
            "Merchant earnings downloaded.", platformChannelSpecifics,
            payload: savePath);

        return 1;
      } else if (resp.statusCode == 404) {}
    } catch (e) {
      if (e.toString().contains("404")) {
        return 2;
      } else {
        return 0;
      }
    }
  }
}
/*
 https://www.flyereats.in/merchantapp/api/downloadInvoice?json=true&api_key=flyereats&token=73xj4stewq309on026fc839bacde3e85787e51572274fc0&mtid=10872&user_type=user&date_type=monthly&start_date=&end_date=
*/
