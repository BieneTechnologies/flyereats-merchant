import 'dart:convert';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:merchant_delivery/main.dart';
import 'package:merchant_delivery/models/new_order_model.dart';
import 'package:merchant_delivery/models/order_detail_model.dart';
import 'package:merchant_delivery/models/order_model.dart';
import 'package:merchant_delivery/providers/base_provider.dart';
import 'package:merchant_delivery/screens/new_order/new_order.dart';
import 'package:merchant_delivery/utils/constants.dart';
import 'package:merchant_delivery/utils/util_functions.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OrderProvider extends BaseProvider {
  bool _enableEditMenu = true;

  bool get enableEditMenu => _enableEditMenu;

  bool _isNewOrderScrnOpen = false;

  bool get isNewOrderScrnOpen => _isNewOrderScrnOpen;

  String currentNewOrderId;
  int currentOrderIndex = 1, currentNewOrders = 1;

  List<NewOrderModel> _newOrders = [];

  List<NewOrderModel> get newOrders => [..._newOrders];

  List<OrderModel> _allOrders = [];

  List<OrderModel> get allOrders => [..._allOrders];

  List<OrderModel> _todayOrders = [];

  List<OrderModel> get todayOrders => [..._todayOrders];
  int _totalItems = 0;

  int get totalItems => _totalItems;

  int newOrderApiCount = 0;

  bool isPendingOrder = false;

  Future<void> getAllOrders(
      BuildContext context, String month, String year, int page,
      {bool resetAllOrders = true}) async {
    if (resetAllOrders) {
      _allOrders = [];
    }
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final parameters = {
        'json': true,
        'api_key': "flyereats",
        'token': prefs.getString(Constants.token),
        'mtid': prefs.getString(Constants.merchant_id),
        'user_type': prefs.getString(Constants.user_type),
        'month': month,
        'year': year,
        'page': page,
      };

      Response response = await postData(
          context: context, url: "getAllOrdersNew", data: parameters);
      if (response != null && response.data != null) {
        final jsonResponse = json.decode(response.data);
        final responseCode = jsonResponse["code"];
        final message = jsonResponse["msg"];
        if (responseCode == Constants.responseSuccess) {
          final rawOrderList = jsonResponse['details']['data'];
          for (final rawOrder in rawOrderList) {
            final order = OrderModel.fromJson(rawOrder);
            _allOrders.add(order);
          }
          print("all ordersss$jsonResponse");
          _totalItems = int.tryParse(jsonResponse['details']['total_items']);
          notifyListeners();
        } else if (responseCode == Constants.responseLogout) {
          logout(context);
        } else {
          showMyFlushbar(context, message);
        }
      } else
        throw "error";
    } catch (e) {
      if (page != 0) {
        Navigator.of(context).pop();
      }
      showMyFlushbar(context, "Error Occurred");
      throw "error";
    }
  }

  Future<void> getTodayOrders(BuildContext context) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final parameters = {
        'json': true,
        'api_key': "flyereats",
        'token': prefs.getString(Constants.token),
        'mtid': prefs.getString(Constants.merchant_id),
        'user_type': prefs.getString(Constants.user_type),
      };

      //  print(parameters);
      Response response = await postData(
          context: context, url: "get-todays-order", data: parameters);

      if (response != null && response.data != null) {
        final jsonResponse = json.decode(response.data);
        final responseCode = jsonResponse["code"];
        final message = jsonResponse["msg"];

        final enableEditMenu = jsonResponse['details']['enable_edit_menu'];
        currentNewOrders = jsonResponse["details"]["unopen_count"] != null
            ? int.parse(jsonResponse["details"]["unopen_count"])
            : 0;
        _enableEditMenu = enableEditMenu;

        if (currentNewOrders == 0) {
          currentOrderIndex = 1;
          // This has been placed because for some reason whenever there is a currentorder zero neworderscreen pops up
          // if(isNewOrderScrnOpen) {
          //   print("NEW-ORDER = in today orders");
          //   Navigator.of(context).pop();
          // }
        } else if (currentOrderIndex > currentNewOrders) {
          currentOrderIndex = currentNewOrders;
        }

        if (currentNewOrders > 0) {
          AudioCache player = new AudioCache();
          const alarmAudioPath = "sounds/merchant_notify.mp3";
          player.play(alarmAudioPath);
        }

        if (responseCode == Constants.responseSuccess) {
          _todayOrders = [];

          final rawOrderList = jsonResponse['details']['data'];
          for (final rawOrder in rawOrderList) {
            final order = OrderModel.fromJson(rawOrder);
            _todayOrders.add(order);
          }
          // try {
          //   final Directory directory =
          //       await getApplicationDocumentsDirectory();
          //   final File file = File('${directory.path}/my_file.txt');
          //   Map orderMap = jsonDecode(await file.readAsString());
          //   var order = NewOrderModel.fromJson(orderMap);
          //   Constants.orderModel = order;
          // } catch (e) {
          //   print("Couldn't read file");
          // }

          notifyListeners();
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

  Future<void> listenForNewOrders(BuildContext context) async {
    // getTodayOrders(context);
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final parameters = {
        'json': true,
        'api_key': "flyereats",
        'token': prefs.getString(Constants.token),
        'mtid': prefs.getString(Constants.merchant_id),
        'user_type': prefs.getString(Constants.user_type),
      };

      debugPrint("params $parameters");

      Response response =
          await postData(context: context, url: "new-order", data: parameters);
      newOrderApiCount++;
      print("number of times new-order api is called = $newOrderApiCount");

      if (response != null && response.data != null) {
        final jsonResponse = json.decode(response.data);
        //debugPrint(response.data);
        final responseCode = jsonResponse["code"];
        final message = jsonResponse["msg"];

        if (responseCode == Constants.responseSuccess) {
          getTodayOrders(context);
          final rawNewOrder = jsonResponse['details'];
          if (message == true) {
            final newOrder = NewOrderModel.fromJson(rawNewOrder);

            if (newOrder != null && currentNewOrderId != newOrder.orderId) {
              currentNewOrderId = newOrder.orderId;

              // isPendingOrder = true;

              /*AudioCache player = new AudioCache();
              const alarmAudioPath = "sounds/merchant_notify.mp3";
              player.play(alarmAudioPath);*/
              if (newOrder != null) {
                print("NEW-ORDER = newOrderBottomSheet");
                print("NEW-ORDER = orderid = ${newOrder.orderId}");
                _isNewOrderScrnOpen = true;
                newOrderBottomSheet(context, newOrder);
              }
            }
          } else {
            currentNewOrderId = null;
            if (isNewOrderScrnOpen) {
              Navigator.of(context).pop();
            }
          }
        } else if (responseCode == Constants.responseLogout) {
          logout(context);
        }
      } else
        throw "error 1";
    } catch (e) {
      throw e;
    }
  }

  Future<void> _showNotification(String message) async {
    var androidDetails = new AndroidNotificationDetails(
        "Channel ID", "Desi programmer", "This is my channel",
        importance: Importance.max);
    var iOSDetails = new IOSNotificationDetails();
    var generalNotificationDetails =
        new NotificationDetails(android: androidDetails, iOS: iOSDetails);

    await fltrNotification.show(
        0, "New order", message, generalNotificationDetails);
  }

  Future<OrderDetailModel> getOrderDetails(
      BuildContext context, String orderId) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final parameters = {
        'json': true,
        'api_key': "flyereats",
        'token': prefs.getString(Constants.token),
        'mtid': prefs.getString(Constants.merchant_id),
        'user_type': prefs.getString(Constants.user_type),
        'order_id': orderId,
      };

      print("param$parameters");

      Response response = await postData(
          context: context, url: "get-receipt", data: parameters);
      if (response != null && response.data != null) {
        final jsonResponse = json.decode(response.data);
        final responseCode = jsonResponse["code"];
        final message = jsonResponse["msg"];

        if (responseCode == Constants.responseSuccess) {
          final orderDetailModel =
              OrderDetailModel.fromJson(jsonResponse['details']);

          return orderDetailModel;
        } else if (responseCode == Constants.responseLogout) {
          showMyFlushbar(context, message);
          // logout(context);
          throw message;
        } else {
          showMyFlushbar(context, message);
          throw message;
        }
      }
      throw "Error";
    } catch (e) {
      debugPrint("eror order details: $e ");
      throw "Error roccurred, Error: $e";
    }
  }

  Future<bool> declineOrder(
      BuildContext context, String orderId, String cancelReason) async {
    currentOrderIndex++;
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final parameters = {
        'json': true,
        'api_key': "flyereats",
        'token': prefs.getString(Constants.token),
        'mtid': prefs.getString(Constants.merchant_id),
        'user_type': prefs.getString(Constants.user_type),
        'order_id': orderId,
        'reason': cancelReason,
      };

      debugPrint("parametercancel $parameters");

      Response response = await postData(
          context: context,
          url: "decline-orders",
          data: parameters,
          openLoadingScreen: true);
      final jsonResponse = json.decode(response.data);
      final responseCode = jsonResponse["code"];
      final message = jsonResponse["msg"];
      showMyFlushbar(context, message);
      if (responseCode == Constants.responseSuccess) {
        _newOrders.removeWhere((element) => element.orderId == orderId);

        return true;
      } else if (responseCode == Constants.responseLogout) {
        logout(context);
        return false;
      } else {
        return false;
      }
    } catch (e) {
      debugPrint("error $e");
      return false;
    }
  }

  Future<bool> acceptOrder(BuildContext context, String orderId) async {
    currentOrderIndex++;
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final parameters = {
        'json': true,
        'api_key': "flyereats",
        'token': prefs.getString(Constants.token),
        'mtid': prefs.getString(Constants.merchant_id),
        'user_type': prefs.getString(Constants.user_type),
        'order_id': orderId,
      };

      debugPrint("accept parameter $parameters");

      Response response = await postData(
          context: context,
          url: "accept-ordes",
          data: parameters,
          openLoadingScreen: true);
      final jsonResponse = json.decode(response.data);
      final responseCode = jsonResponse["code"];
      final message = jsonResponse["msg"];
      showMyFlushbar(context, message);
      if (responseCode == Constants.responseSuccess) {
        currentNewOrderId = null;

        return true;
      } else if (responseCode == Constants.responseLogout) {
        logout(context);
        return false;
      } else {
        return false;
      }
    } catch (e) {
      debugPrint("error $e");
      return false;
    }
  }

  Future<bool> changeOrderStatus(BuildContext context, String orderId) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final parameters = {
        'json': true,
        'api_key': "flyereats",
        'token': prefs.getString(Constants.token),
        'mtid': prefs.getString(Constants.merchant_id),
        'user_type': prefs.getString(Constants.user_type),
        'status': 'food_ready',
        'order_id': orderId,
      };

      Response response = await postData(
          context: context,
          url: "change-order-status",
          data: parameters,
          openLoadingScreen: true);
      final jsonResponse = json.decode(response.data);
      final responseCode = jsonResponse["code"];
      final message = jsonResponse["msg"];
      showMyFlushbar(context, message);
      if (responseCode == Constants.responseSuccess) {
        return true;
      } else if (responseCode == Constants.responseLogout) {
        logout(context);
        return false;
      } else {
        return false;
      }
    } catch (e) {
      debugPrint("error $e");
      return false;
    }
  }

  void updateNewOrderScreenStatus(bool status) {
    _isNewOrderScrnOpen = status;
  }
}
