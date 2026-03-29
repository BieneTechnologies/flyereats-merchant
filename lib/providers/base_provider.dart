//import 'package:connectivity/connectivity.dart';
import 'package:connectivity/connectivity.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:merchant_delivery/utils/constants.dart';
import 'package:merchant_delivery/utils/util_functions.dart';

class BaseProvider extends ChangeNotifier {

  BaseOptions options = new BaseOptions(
    baseUrl: Constants.baseUrl,
    contentType: "application/json",
    followRedirects: false,
    validateStatus: (status) {
      return status < 500;
    },
    connectTimeout: 90000,
    receiveTimeout: 90000,
  );


  Future<Response> getData(
      {@required BuildContext context,
      String url,
      Map<String, dynamic> data,
      openLoadingScreen = false}) async {
    try {
      var connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult != ConnectivityResult.none) {
        Dio dio = new Dio(options);
        if (openLoadingScreen) {
          showLoadingDialog(context);
        }
        Response response = await dio.get(url, queryParameters: data);
        if (openLoadingScreen) {
          Navigator.of(context).pop();
        }
        return response;
      } else {
        String e = "Please check internet connection";
        showMyFlushbar(context, e);
        throw e;
      }
    } catch (e) {
      debugPrint("Error on post method: $e");
      if (openLoadingScreen) {
        Navigator.of(context).pop();
      }
      throw e;
    }
  }

  Future<Response> postData(
      {@required BuildContext context,
      String url,
      Map<String, dynamic> data,
      openLoadingScreen = false}) async {
    try {
      var connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult != ConnectivityResult.none) {
        Dio dio = new Dio(options);
        if (openLoadingScreen) {
          showLoadingDialog(context);
        }

        Response response = await dio.post(url, queryParameters: data);

        if (openLoadingScreen) {
          Navigator.of(context).pop();
        }
        return response;
      } else {
        String e = "Please check internet connection";
        showMyFlushbar(context, e);
        throw e;
      }
    } catch (e) {
      debugPrint("Error on post method: $e");
      if (openLoadingScreen) {
        Navigator.of(context).pop();
      }
      throw e;
    }
  }
}
