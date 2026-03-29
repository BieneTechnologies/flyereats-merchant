import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:merchant_delivery/models/ratings_model.dart';
import 'package:merchant_delivery/providers/base_provider.dart';
import 'package:merchant_delivery/utils/constants.dart';
import 'package:merchant_delivery/utils/util_functions.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RatingsProvider extends BaseProvider {
  RatingsModel model;
  int currentPage = 0;

  Future<RatingsModel> getRating(
      BuildContext context, int page, bool loading) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final parameters = {
        'json': true,
        'api_key': "flyereats",
        'token': prefs.getString(Constants.token),
        'mtid': prefs.getString(Constants.merchant_id),
        'user_type': prefs.getString(Constants.user_type),
        'page': page
      };

      print("ratingParams: $parameters");

      Response response = await postData(
          context: context,
          url: "get-reviews",
          data: parameters,
          openLoadingScreen: loading);

      if (response != null && response.data != null) {
        final jsonResponse = json.decode(response.data);
        final responseCode = jsonResponse["code"];
        print(response.data);
        if (responseCode == Constants.responseSuccess) {
          return RatingsModel.fromMap(jsonResponse["details"]);
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

  Future<RatingsProvider> firstPage(BuildContext context) async {
    currentPage = 0;
    model = await getRating(context, currentPage, false);
    return this;
  }

  Future<RatingsProvider> nextPage(BuildContext context) async {
    currentPage++;
    RatingsModel temp = await getRating(context, currentPage, true);
    model.items.addAll(temp.items);
    return this;
  }
}
