import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:merchant_delivery/models/ratings_model.dart';
import 'package:merchant_delivery/models/settlement_model.dart';
import 'package:merchant_delivery/providers/base_provider.dart';
import 'package:merchant_delivery/utils/constants.dart';
import 'package:merchant_delivery/utils/util_functions.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettlementProvider extends BaseProvider {

  RatingsModel model;
  int currentPage = 0;

  Future<SettlementModel> getSettlement(
      BuildContext context, bool loading, String period) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var parameters = {
        'json': true,
        'api_key': "flyereats",
        'token': prefs.getString(Constants.token),
        'mtid': prefs.getString(Constants.merchant_id),
        'user_type': prefs.getString(Constants.user_type),
      };

      if (period != "") {
        parameters.addAll({'settlement_ids': period});
      }

      print("getSettlementParams: $parameters");

      Response response = await postData(
          context: context,
          url: "getMerchantPayout",
          data: parameters,
          openLoadingScreen: loading);

      if (response != null && response.data != null) {
        final jsonResponse = json.decode(response.data);
        final responseCode = jsonResponse["code"];
        print("eeeeeee${response.data}");
        if (responseCode == Constants.responseSuccess) {
          return SettlementModel.fromMap(jsonResponse["details"]);
        } else if (responseCode == Constants.responseLogout) {
          logout(context);
        }
      } else
        throw "error";
    } catch (e) {
      print("error${e.toString()}");
      showMyFlushbar(context, "Error Occurred");
      throw "error";
    }
  }

  Future<List<SettlementPeriodModel>> getSettlementPeriods(
      BuildContext context, bool loading, String month, String year) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final parameters = {
        'json': true,
        'api_key': "flyereats",
        'token': prefs.getString(Constants.token),
        'mtid': prefs.getString(Constants.merchant_id),
        'user_type': prefs.getString(Constants.user_type),
        'month': month, //month,
        'year': year
      };

      print("getSettlementParams: $parameters");

      Response response = await postData(
          context: context,
          url: "getDatePeriod",
          data: parameters,
          openLoadingScreen: loading);

      print("ressss$response");
      if (response != null && response.data != null) {
        final jsonResponse = json.decode(response.data);
        final responseCode = jsonResponse["code"];
        print(response.data);
        if (responseCode == Constants.responseSuccess) {
          List<SettlementPeriodModel> periods = new List();
          for (var i in jsonResponse["details"]) {
            periods.add(SettlementPeriodModel.fromMap(i));
          }
          return periods;
        } else if (responseCode == Constants.responseLogout) {
          logout(context);
        }
      } else
        throw "error";
    } catch (e) {
      showMyFlushbar(context, "Error Occurred");
      throw "error";
    }
  }
}
