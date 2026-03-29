import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:merchant_delivery/main.dart';
import 'package:merchant_delivery/models/login_response_model.dart';
import 'package:merchant_delivery/providers/base_provider.dart';
import 'package:merchant_delivery/utils/constants.dart';
import 'package:merchant_delivery/utils/util_functions.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';

class UserProvider extends BaseProvider {
  Future<bool> authenticateUser(
      BuildContext context, String username, String password) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String firebaseToken =
        await fcm.getToken(); /*prefs.getString(Constants.fcmToken);*/
    Clipboard.setData(new ClipboardData(text: firebaseToken));
    print("TOKEN: " + firebaseToken);
    final parameters = {
      'json': true,
      'api_key': "flyereats",
      'username': username.trim(),
      'password': password,
      'merchant_device_id': firebaseToken,
      'device_id': firebaseToken,
      'device_platform': getDevicePlatform(),
    };
    print("Baseurl: " + Constants.baseUrl);
    print("dataaa ${parameters.toString()}");
    try {
      Response response = await postData(
          context: context,
          url: "login",
          data: parameters,
          openLoadingScreen: true);


      debugPrint(json.decode(response.data).toString());
      if (response != null && response.data != null) {
        final jsonResponse = json.decode(response.data);
        final responseCode = jsonResponse["code"];
        final message = jsonResponse["msg"];
        if (responseCode == Constants.responseSuccess) {
          final loginResponse =
              LoginResponseModel.fromJson(json.decode(response.data));
          SharedPreferences prefs = await SharedPreferences.getInstance();

          prefs.setString(Constants.token, loginResponse.details.token);
          prefs.setString(
              Constants.username, loginResponse.details.info.username);
          prefs.setString(Constants.restaurant_name,
              loginResponse.details.info.restaurantName);
          prefs.setString(
              Constants.contact_email, loginResponse.details.info.contactEmail);
          prefs.setString(
              Constants.user_type, loginResponse.details.info.userType);
          prefs.setString(
              Constants.merchant_id, loginResponse.details.info.merchantId);
          prefs.setString(Constants.merchant_user_id,
              loginResponse.details.info.merchantUserId.toString());
          return true;
        } else {
          showMyFlushbar(context, message);
          return false;
        }
      }
      return false;
    } on DioError catch (e) {
      if (e.type == DioErrorType.connectTimeout) {
        showMyFlushbar(context,
            "Connection Timeout, Please Check Your Internet Connection!");
        Navigator.of(context).pop();
      }
      if (e.type == DioErrorType.receiveTimeout) {
        showMyFlushbar(
            context, "Receive Timeout, Please Check Your Internet Connection!");
        Navigator.of(context).pop();
      }
      return false;
    } catch (e) {
      print(e);
      showMyFlushbar(context, "Error Occurred");
      return false;
    }
  }

  Future<void> refreshTokenFCM(BuildContext context, String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String firebaseToken = prefs.getString(Constants.fcmToken);

    if (!prefs.getBool('isLoggedIn')) {
      return;
    }
    Clipboard.setData(new ClipboardData(text: firebaseToken));
    print("NEW TOKEN IS: " + firebaseToken);
    final parameters = {
      'json': true,
      'api_key': "flyereats",
      'mtid': prefs.getString(Constants.user_type) == 'user'
          ? prefs.getString(Constants.merchant_user_id)
          : prefs.getString(Constants.merchant_id),
      'user_type': prefs.getString(Constants.user_type),
      'token': prefs.getString(Constants.token),
      'merchant_device_id': firebaseToken,
      'device_platform' : getDevicePlatform(),
    };

    try {
      Response response = await postData(
        context: context,
        url: "refreshDeviceId",
        data: parameters,
      );

      print("onRefreshData ${parameters.toString()}");

      if (response != null && response.data != null) {
        final jsonResponse = json.decode(response.data);
        final responseCode = jsonResponse["code"];
        final message = jsonResponse["msg"];
        print("response token is $jsonResponse");
        if (responseCode == Constants.responseSuccess) {
          /*final loginResponse =
          LoginResponseModel.fromJson(json.decode(response.data));
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString(Constants.token, loginResponse.details.token);*/

          return true;
        } else {
          showMyFlushbar(context, message);
          return false;
        }
      }
      return false;
    } on DioError catch (e) {
      if (e.type == DioErrorType.connectTimeout) {
        showMyFlushbar(context,
            "Connection Timeout, Please Check Your Internet Connection!");
        Navigator.of(context).pop();
      }
      if (e.type == DioErrorType.receiveTimeout) {
        showMyFlushbar(
            context, "Receive Timeout, Please Check Your Internet Connection!");
        Navigator.of(context).pop();
      }
      return false;
    } catch (e) {
      print(e);
      showMyFlushbar(context, "Error Occurred");
      return false;
    }
  }

  Future<bool> forgotPassword(BuildContext context, String email) async {
    final parameters = {
      'json': true,
      'api_key': "flyereats",
      'email_address': email,
    };
    try {
      Response response = await postData(
          context: context,
          url: "forgot-password",
          data: parameters,
          openLoadingScreen: true);
      Navigator.pop(context); //pop dialog
      if (response != null && response.data != null) {
        print(response.data);
        final jsonResponse = json.decode(response.data);
        final responseCode = jsonResponse["code"];
        final message = jsonResponse["msg"];
        if (responseCode == Constants.responseSuccess) {
          return true;
        }
        showMyFlushbar(context, message);
        return false;
      }
      return false;
    } on DioError catch (e) {
      if (e.type == DioErrorType.connectTimeout) {
        showMyFlushbar(context,
            "Connection Timeout, Please Check Your Internet Connection!");
      }
      if (e.type == DioErrorType.receiveTimeout) {
        showMyFlushbar(
            context, "Receive Timeout, Please Check Your Internet Connection!");
      }
      return false;
    } catch (e) {
      showMyFlushbar(context, "Error Occurred");
      return false;
    }
  }

  Future<bool> changePassword(
      BuildContext context, Map<String, String> map) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final parameters = {
        'json': true,
        'api_key': "flyereats",
        'token': prefs.getString(Constants.token),
        'mtid': prefs.getString(Constants.merchant_id),
        'user_type': prefs.getString(Constants.user_type),
        'new_password': map['newPassword'],
        'old_password': map['oldPassword'],
        'confirm_password': map['confirmPassword'],
      };

      debugPrint("parameter: $parameters");
      Response response = await postData(
          context: context,
          url: "changePassword",
          data: parameters,
          openLoadingScreen: true);
      debugPrint("response $response");
      if (response != null && response.data != null) {
        final jsonResponse = json.decode(response.data);
        final responseCode = jsonResponse["code"];
        final message = jsonResponse["msg"];
        if (responseCode == Constants.responseSuccess) {
          showMyFlushbar(context, "Successful");
          return true;
        } else if (responseCode == Constants.responseLogout) {
          logout(context);
          return false;
        }
        showMyFlushbar(context, message);
        return false;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
