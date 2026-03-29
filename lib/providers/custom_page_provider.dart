import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:merchant_delivery/models/custom_page_model.dart';
import 'package:merchant_delivery/models/faq_model.dart';
import 'package:merchant_delivery/providers/base_provider.dart';
import 'package:merchant_delivery/utils/constants.dart';
import 'package:merchant_delivery/utils/util_functions.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomPageProvider extends BaseProvider {
  List<FAQModel> _listFaqs = [];
  List<FAQModel> _allFaqs = [];

  List<FAQModel> get listFaqs => [..._listFaqs];

  Future<CustomPageModel> getCustomPage(BuildContext context, String pageType) async {
    final parameters = {
      'json': true,
      'api_key': "flyereats",
      'page_type': pageType,
    };

    try {
      Response response = await postData(context: context, url: "get-custom-page", data: parameters);
      if (response != null && response.data != null) {
        final jsonResponse = json.decode(response.data);
        final responseCode = jsonResponse["code"];
        final message = jsonResponse["msg"];
        final pageData = jsonResponse["details"]["page_data"];
        final pageDataModel = CustomPageModel.fromJson(pageData);
        return pageDataModel;
      }
      return null;
    } catch (e) {
      throw "Error occurred";
    }
  }



  Future<void> getFAQs(BuildContext context) async {
    List<FAQModel> _loadedFAQs = new List();
    _listFaqs = [];

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final parameters = {
        'json': true,
        'api_key': "flyereats",
        'token': prefs.getString(Constants.token),
        'mtid': prefs.getString(Constants.merchant_id),
        'user_type': prefs.getString(Constants.user_type),
      };

      Response response = await postData(context: context, url: "faq", data: parameters);
      if (response != null && response.data != null) {
        final jsonResponse = json.decode(response.data);
        final responseCode = jsonResponse["code"];
        final message = jsonResponse["msg"];
        if (responseCode == Constants.responseSuccess) {
          final faqsArr = jsonResponse["details"];
          for (final faq in faqsArr) {
            final FAQModel faqModel = FAQModel.fromJson(faq);
            debugPrint(faqModel.question);
            _loadedFAQs.add(faqModel);
          }
          _listFaqs = [..._loadedFAQs];
          _allFaqs = [..._loadedFAQs];
          notifyListeners();
        } else if (responseCode == Constants.responseLogout) {
          logout(context);
        } else
          showMyFlushbar(context, message);
      }
    } catch (e) {
      debugPrint("error $e");
      showMyFlushbar(context, "Error Occurred");
      throw "Error Occurred";
    }
  }

  Future<void> searchFAQs(String searchKey) async {
    List<FAQModel> _temp = new List();
    _temp = [..._allFaqs];
    _listFaqs = _temp.where((model) => model.answer.contains(searchKey) || model.question.contains(searchKey)).toList();
    notifyListeners();
  }
}
