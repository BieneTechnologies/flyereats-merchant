import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:merchant_delivery/models/items_category_model.dart';
import 'package:merchant_delivery/providers/base_provider.dart';
import 'package:merchant_delivery/screens/food_menu_on_off/next_opening_time_bottom_sheet.dart';
import 'package:merchant_delivery/utils/constants.dart';
import 'package:merchant_delivery/utils/util_functions.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CategoryItemProvider extends BaseProvider {
  List<ItemsWithCategoryModel> _itemsWithCategory = [];

  List<ItemsWithCategoryModel> get itemsWithCategory => [..._itemsWithCategory];

  bool _merchantOpen = false;

  bool get merchantOpen => _merchantOpen;

  Future<void> getCategoryWithItems(BuildContext context, String searchKey,
      [bool isCategory = false]) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final parameters = {
        'json': true,
        'api_key': "flyereats",
        'token': prefs.getString(Constants.token),
        'mtid': prefs.getString(Constants.merchant_id),
        'user_type': prefs.getString(Constants.user_type),
        'is_category': isCategory ? "1" : "0",
        'searchkey': searchKey,
      };

      debugPrint("params $parameters");

      Response response = await postData(
          context: context, url: "get-category-with-items", data: parameters);
      if (response != null && response.data != null) {
        final jsonResponse = json.decode(response.data);
        final responseCode = jsonResponse["code"];
        final message = jsonResponse["msg"];

        if (responseCode == Constants.responseSuccess) {
          _itemsWithCategory = [];
          final merchantStatus = jsonResponse['details']['merchant_open'];
          merchantStatus == 1 ? _merchantOpen = true : _merchantOpen = false;
          final itemsList = jsonResponse['details']['list'];
          for (final item in itemsList) {
            final itemsWithCategoryModel =
            ItemsWithCategoryModel.fromJson(item);
            _itemsWithCategory.add(itemsWithCategoryModel);
          }
          notifyListeners();
        } else if (responseCode == Constants.responseLogout) {
          logout(context);
        } else {
          showMyFlushbar(context, message);
        }
      }
    } catch (e) {
      showMyFlushbar(context, "Error Occurred");
      debugPrint("error getCategoryWithItems $e");
      throw "Error Occurred";
    }
  }

  Future<bool> getCategoryWithItemsAfterUpdate(BuildContext context, String searchKey,
      [bool isCategory = false]) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final parameters = {
        'json': true,
        'api_key': "flyereats",
        'token': prefs.getString(Constants.token),
        'mtid': prefs.getString(Constants.merchant_id),
        'user_type': prefs.getString(Constants.user_type),
        'is_category': isCategory ? "1" : "0",
        'searchkey': searchKey,
      };

      debugPrint("params $parameters");

      Response response = await postData(
          context: context, url: "get-category-with-items", data: parameters,openLoadingScreen: true);
      if (response != null && response.data != null) {
        final jsonResponse = json.decode(response.data);
        final responseCode = jsonResponse["code"];
        final message = jsonResponse["msg"];

        if (responseCode == Constants.responseSuccess) {
          _itemsWithCategory = [];
          final merchantStatus = jsonResponse['details']['merchant_open'];
          merchantStatus == 1 ? _merchantOpen = true : _merchantOpen = false;
          final itemsList = jsonResponse['details']['list'];
          for (final item in itemsList) {
            final itemsWithCategoryModel =
            ItemsWithCategoryModel.fromJson(item);
            _itemsWithCategory.add(itemsWithCategoryModel);
          }
          notifyListeners();
          return true;
        } else if (responseCode == Constants.responseLogout) {
          logout(context);
          return false;
        } else {
          showMyFlushbar(context, message);
          return false;
        }
      }
    } catch (e) {
      showMyFlushbar(context, "Error Occurred");
      debugPrint("error getCategoryWithItems $e");
      throw "Error Occurred";
    }
  }

  Future<bool> updateCategoryName(
      BuildContext context, String id, String name) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final parameters = {
        'json': true,
        'api_key': "flyereats",
        'token': prefs.getString(Constants.token),
        'user_type': prefs.getString(Constants.user_type),
        'mtid': prefs.getString(Constants.merchant_id),
        'cat_id': id,
        'category_name': name,
      };
      Response response = await postData(
          context: context,
          url: "update-item-availability",
          data: parameters,
          openLoadingScreen: true);
      final jsonResponse = json.decode(response.data);
      debugPrint("json response $jsonResponse");
      final responseCode = jsonResponse["code"];
      final message = jsonResponse["msg"];
      showMyFlushbar(context, message);
      if (responseCode == Constants.responseSuccess) {
        getCategoryWithItems(context, "");
        return true;
      } else {
        return false;
      }
    } catch (e) {
      showMyFlushbar(context, "Error Occurred");
      return false;
    }
  }

  Future<bool> updateItemNameWithSizePrice(BuildContext context, String itemId,
      String itemName, Map<String, String> price) async {
    // debugPrint("isSingleItem ${_isSingleItem(price)}");
    // if(_isSingleItem(price)){
    //   debugPrint("result ${json.encode(_convertPriceToArray(price))}");
    // }
    // bool isSingleItem = _isSingleItem(price);
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final parameters = {
        'json': true,
        'api_key': "flyereats",
        'token': prefs.getString(Constants.token),
        'user_type': prefs.getString(Constants.user_type),
        'mtid': prefs.getString(Constants.merchant_id),
        'item_id': itemId,
        'item_name': itemName,
        'price': _isSingleItem(price)
            ? json.encode([price["0"]])
            : json.encode(price),
      };

      debugPrint("update parameters: $parameters");
      Response response = await postData(
          context: context,
          url: "update-item-availability",
          data: parameters,
          openLoadingScreen: true);
      debugPrint("update response: $response");
      final jsonResponse = json.decode(response.data);
      final responseCode = jsonResponse["code"];
      final message = jsonResponse["msg"];
      showMyFlushbar(context, message);
      if (responseCode == Constants.responseSuccess) {
        getCategoryWithItems(context, "");
        return true;
      } else {
        return false;
      }
    } catch (e) {
      showMyFlushbar(context, "Error Occurred");
      return false;
    }
  }

  _isSingleItem(Map<String, String> price) =>
      price.length == 1 && price.containsKey("0");

  Future<bool> updateMerchantAvailability(
      BuildContext context, SelectedNOT selectedNOT, bool isOpen) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final parameters = {
      'json': true,
      'api_key': "flyereats",
      'token': prefs.getString(Constants.token),
      'user_type': prefs.getString(Constants.user_type),
      'mtid': prefs.getString(Constants.merchant_id),
      'date_option': selectedNOT.type == 1
          ? int.tryParse(selectedNOT.radioGroupValue)
          : "", //{1=>1 hour, 2=>1.5 hours, 3=>2 hours}
      'date': selectedNOT.type == 2
          ? selectedNOT.date
          : "", //"2020-08-09", //2020 - 08 - 09
      'time': selectedNOT.type == 2
          ? selectedNOT.time
          : "", //"10:12", // (24 hours format)
      'checked': isOpen ? '1' : '2',
    };
    debugPrint("params: $parameters");
    try {
      Response response = await postData(
          context: context,
          url: "merchantAvailabilityNew", //"update-merchant-availability", old
          data: parameters,
          openLoadingScreen: true);
      final jsonResponse = json.decode(response.data);
      final responseCode = jsonResponse["code"];
      final message = jsonResponse["msg"];
      print(response.data);
      if (responseCode == Constants.responseSuccess) {
        final merchantStatus = jsonResponse['details']['merchant_open'];
        merchantStatus == 1 ? _merchantOpen = true : _merchantOpen = false;

        notifyListeners();
        return true;
      } else {
        return false;
      }
    } catch (e) {
      showMyFlushbar(context, "Error Occurred");
      return false;
    }
  }

  Future<bool> updateItemAvailability(
      BuildContext context, SelectedNOT selectedNOT, bool isOpen,
      {String catId, String itemId}) async {
    int isOn;

    if (itemId == null) {
      if (isOpen) {
        isOn = 0;
      } else
        isOn = 1;
    } else {
      if (isOpen) {
        isOn = 1;
      } else
        isOn = 2;
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    final parameters = {
      'json': true,
      'api_key': "flyereats",
      'token': prefs.getString(Constants.token),
      'user_type': prefs.getString(Constants.user_type),
      'mtid': prefs.getString(Constants.merchant_id),
      'cat_id': catId,
      'item_id': itemId,
      'date_option': selectedNOT.type == 1
          ? int.tryParse(selectedNOT.radioGroupValue)
          : "",
      'date': selectedNOT.type == 2 ? selectedNOT.date : "",
      'time': selectedNOT.type == 2 ? selectedNOT.time : "",
      'checked': isOn, //isOn, //isOpen ? '1' : '2',
    };

    try {
      Response response = await postData(
          context: context,
          url: "update-item-availability",
          data: parameters,
          openLoadingScreen: true);
      final jsonResponse = json.decode(response.data);
      debugPrint("availability response $jsonResponse");
      final responseCode = jsonResponse["code"];
      final message = jsonResponse["msg"];
      // showMyFlushbar(context, message);
      if (responseCode == Constants.responseSuccess) {
        return getCategoryWithItemsAfterUpdate(context, "");
        // getCategoryWithItemsAfterUpdate(context, "");
        // return true;
      } else {
        return false;
      }
    } catch (e) {
      showMyFlushbar(context, "Error Occurred");
      return false;
    }
  }
}
