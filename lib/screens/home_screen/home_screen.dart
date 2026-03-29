import 'dart:async';
import 'dart:collection';

import 'package:audioplayers/audioplayers.dart';
import 'package:clear_all_notifications/clear_all_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:merchant_delivery/main.dart';
import 'package:merchant_delivery/models/new_order_model.dart';
import 'package:merchant_delivery/providers/order_provider.dart';
import 'package:merchant_delivery/providers/user_provider.dart';
import 'package:merchant_delivery/screens/home_screen/all_orders.dart';
import 'package:merchant_delivery/screens/home_screen/todays_orders.dart';
import 'package:merchant_delivery/screens/new_order/new_order.dart';
import 'package:merchant_delivery/utils/app_theme.dart';
import 'package:merchant_delivery/utils/constants.dart';
import 'package:merchant_delivery/utils/hex_color.dart';
import 'package:merchant_delivery/utils/util_functions.dart';
import 'package:merchant_delivery/widgets/custom_appbar.dart';
import 'package:merchant_delivery/widgets/drawer.dart';
import 'package:notification_permissions/notification_permissions.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:volume/volume.dart';
import 'dart:convert';

FlutterLocalNotificationsPlugin flip;

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();

  HomeScreen();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  String _merchantName;
  int _activeTabIndex = 0;
  TabController _tabController;
  String msgId = "";

  String currentNewOrderId;

  void _setActiveTabIndex() {
    if (_tabController.indexIsChanging) {
      setState(() {
        _activeTabIndex = _tabController.index;
      });
    }
  }

  void _getMerchantName() async {
    await Firebase.initializeApp();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _merchantName = prefs.getString(Constants.restaurant_name);
    });
  }

  SharedPreferences prefs;
  bool isFirstEmit = false;

  @override
  void initState() {
    ClearAllNotifications.clear();
    _getMerchantName();
    _tabController = new TabController(length: 2, vsync: this);
    _tabController.addListener(_setActiveTabIndex);
    _checkNotificationSettings();
    _refresh();
    super.initState();
    WidgetsBinding.instance
        .addObserver(this); //listener to check if app is in foreground mode

    FirebaseMessaging.onMessage.listen((event) {
      print("message on foreground mode");
      /*AudioCache player = new AudioCache();
      const alarmAudioPath = "sounds/merchant_notify.mp3";
      player.play(alarmAudioPath);
*/
      if (msgId != event.messageId) {
        msgId = event.messageId;
        _showNotification(event.notification.title, event.notification.body);

        final responseData = Map<String, dynamic>.from(event.data);
        String s = responseData["event"].toString();

        if (s.contains('orderStatusChanged')) {
          setState(() {
            print("order status changed");
            Provider.of<OrderProvider>(context, listen: false)
                .listenForNewOrders(context);
          });
        } else if (s.contains('orderPlaced')) {
          print('order placed On Foreground mode');
          final temp = responseData['event'];
          final rawData = temp.toString();
          Map valueMap = json.decode(rawData);
          // final rawNewOrder = valueMap['data']['order'];
          // final newOrder = NewOrderModel.fromJson(rawNewOrder);
          // // if (newOrder != null &&
          //     currentNewOrderId != newOrder.orderId) {
          //   if(!Constants.isNewOrderReceivedByFCM) {
          //     Provider.of<OrderProvider>(context, listen: false)
          //         .listenForNewOrders(context);
          //   }
          //   else {
          //     Provider.of<OrderProvider>(context, listen: false)
          //         .getTodayOrders(context);
          //   }
          Provider.of<OrderProvider>(context, listen: false)
              .listenForNewOrders(context);
          //Constants.isNewOrderReceivedByFCM = true;
          // newOrderBottomSheet(context, newOrder);

          print('order placed and needs to update UI');
        }
        else {
          print('order placed and needs to update UI');
          // Provider.of<OrderProvider>(context, listen: false)
          //     .listenForNewOrders(context);
        }
      }
    });

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);


    Provider.of<OrderProvider>(context, listen: false)
        .listenForNewOrders(context);
  }

  _refresh() async {
    final prefs = await SharedPreferences.getInstance();
    final String currentToken = prefs.getString(Constants.fcmToken);

    if (currentToken != Constants.oldFCMToken &&
        Constants.oldFCMToken.length != 0) {
      print('Current token: ' + currentToken);
      print('Old token: ' + Constants.oldFCMToken);

      print('token refresh: ' + currentToken);
      // add code here to do something with the updated token
      await prefs.setString(Constants.fcmToken, currentToken);

      await Provider.of<UserProvider>(context, listen: false)
          .refreshTokenFCM(context, currentToken);
    }
  }

  @override
  Widget build(BuildContext context) {
    Constants.appContext = context;

    return WillPopScope(
      onWillPop: () => onWillPop(context),
      child: Scaffold(
        backgroundColor: AppTheme.mainBlackColor,
        appBar: CustomAppbar(title: _merchantName),
        drawer: MyDrawer(),
        body: Container(
          height: MediaQuery.of(context).size.height,
          width: double.infinity,
          padding: const EdgeInsets.only(top: 30),
          decoration: AppTheme.upperRoundedDecor,
          child: SafeArea(
            //minimum: const EdgeInsets.only(right: 20, left: 20, bottom: 16),
            child: new DefaultTabController(
              length: 2,
              child: new Scaffold(
                appBar: new PreferredSize(
                  preferredSize: Size.fromHeight(24),
                  child: Align(
                    alignment: Alignment.center,
                    child: new Container(
                      color: AppTheme.mainWhiteColor,
                      height: 30.0,
                      child: Center(
                        child: TabBar(
                          labelColor: Colors.white,
                          indicator: UnderlineTabIndicator(
                            borderSide: BorderSide(
                                width: 3.0, color: HexColor("#FFC94B")),
                            insets: EdgeInsets.symmetric(horizontal: 16.0),
                          ),
                          controller: _tabController,
                          isScrollable: true,
                          tabs: [
                            Tab(
                              child: Text(
                                "Today`s Orders",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: _activeTabIndex == 0
                                      ? AppTheme.textColor
                                      : AppTheme.textColor.withOpacity(0.5),
                                ),
                              ),
                            ),
                            Tab(
                              child: Text(
                                "All Orders",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: _activeTabIndex == 1
                                      ? AppTheme.textColor
                                      : AppTheme.textColor.withOpacity(0.5),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                body: Container(
                  color: AppTheme.mainWhiteColor,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      TodayOrders(),
                      AllOrders(),
                    ]
                    /*!Constants.isOrderStatusChanged
                        ? [
                            TodayOrders(),
                            AllOrders(),
                          ]
                        : [
                            Center(child: TodayOrders()),
                            Center(child: AllOrders()),
                          ]*/
                    ,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _checkNotificationSettings() async {
    //Set volume
    AudioManager audioManager = AudioManager.STREAM_MUSIC;
    await Volume.controlVolume(audioManager);
    int maxVolumen = await Volume.getMaxVol;
    Volume.setVol(maxVolumen, showVolumeUI: ShowVolumeUI.HIDE);

    audioManager = AudioManager.STREAM_NOTIFICATION;
    await Volume.controlVolume(audioManager);
    maxVolumen = await Volume.getMaxVol;
    Volume.setVol(maxVolumen, showVolumeUI: ShowVolumeUI.HIDE);
    //Check permission
    var permission =
        await NotificationPermissions.getNotificationPermissionStatus();

    if (permission != PermissionStatus.granted) {
      await NotificationPermissions.requestNotificationPermissions();
    }
    //_emitAuth();
  }

  Future<void> _showNotification(String title, String message) async {
    var androidDetails = new AndroidNotificationDetails(
        "kmrs_merchant_channel", "Orders", "This is my channel",
        importance: Importance.max,
        playSound: true,
        priority: Priority.high,
        sound: RawResourceAndroidNotificationSound('merchant_notify'));
    var iOSDetails = new IOSNotificationDetails();
    var generalNotificationDetails =
        new NotificationDetails(android: androidDetails, iOS: iOSDetails);

    await fltrNotification.show(0, title, message, generalNotificationDetails);
  }

  Future<void> _firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    print("Handling a background messageeeee: ${message.messageId}");
    Map<String, dynamic> data = message.data;
    AudioCache player = new AudioCache();
    const alarmAudioPath = "sounds/merchant_notify.mp3";
    player.play(alarmAudioPath);

    final responseData = Map<String, dynamic>.from(data);
    String s = responseData["event"].toString();

    if(s.contains('orderPlaced')) {
      final temp = responseData['event'];
      final rawData = temp.toString();
      Map valueMap = json.decode(rawData);
      final rawNewOrder = valueMap['data']['order'];
      //final newOrder = NewOrderModel.fromJson(rawNewOrder);
      //Constants.orderModel = NewOrderModel.fromJson(rawNewOrder);
      //SharedPreferences sp = await SharedPreferences.getInstance();
      String user = jsonEncode(NewOrderModel.fromJson(rawNewOrder));
      //sp.setString('notifOrder', user);
      Constants.isNotifReceived = true;

      //hossy
      // final Directory directory = await getApplicationDocumentsDirectory();
      // final File file = File('${directory.path}/my_file.txt');
      // await file.writeAsString(user);

      // AwesomeNotifications().createNotificationFromJsonData(message.data);

    }
    else {
      print('or else');
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        print("app in resumed");
        Provider.of<OrderProvider>(context, listen: false)
            .listenForNewOrders(context);
        break;
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.paused:
        break;
      case AppLifecycleState.detached:
        break;
    }
  }
}
