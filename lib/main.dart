import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:autostart/autostart.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:clear_all_notifications/clear_all_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:merchant_delivery/providers/base_provider.dart';
import 'package:merchant_delivery/providers/category_item_provider.dart';
import 'package:merchant_delivery/providers/custom_page_provider.dart';
import 'package:merchant_delivery/providers/order_provider.dart';
import 'package:merchant_delivery/providers/rating_provider.dart';
import 'package:merchant_delivery/providers/report_provider.dart';
import 'package:merchant_delivery/providers/user_provider.dart';
import 'package:merchant_delivery/screens/home_screen/home_screen.dart';
import 'package:merchant_delivery/screens/home_screen/todays_orders.dart';
import 'package:merchant_delivery/screens/login.dart';
import 'package:merchant_delivery/screens/menu_edit/menu_edit_screen.dart';
import 'package:merchant_delivery/screens/new_order/new_order.dart';

import 'package:merchant_delivery/utils/constants.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:merchant_delivery/utils/util_functions.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'models/new_order_model.dart';


// Notification setting
FlutterLocalNotificationsPlugin fltrNotification;
final FirebaseMessaging fcm = FirebaseMessaging.instance;


// To start and cancel timer. User for listen new-orders
Timer timer;
String currentNewOrderId;


Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
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



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AwesomeNotifications().initialize(
      'resource://drawable/ic_stat_notifications',
      [
        // Your notification channels go here
      ]
  );

  await Firebase.initializeApp();
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );


  SharedPreferences prefs = await SharedPreferences.getInstance();
  Constants.oldFCMToken = prefs.getString(Constants.fcmToken)??'';

  fcm.getToken().then((value) {
    print("token value main page: $value");
    prefs.setString(Constants.fcmToken, value);
  });

  // FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  //
  HttpOverrides.global = new MyHttpOverrides();
  //client dart
  runApp(MyApp());
}


Future<void> _showNotification(String title, String message) async {

  var androidInit = new AndroidInitializationSettings('app_icon');

  var iOSInit = new IOSInitializationSettings();
  var initSettings =
  new InitializationSettings(android: androidInit, iOS: iOSInit);
  fltrNotification = new FlutterLocalNotificationsPlugin();
  fltrNotification.initialize(initSettings,
      onSelectNotification: (String payload) async {
        OpenFile.open(payload);
      });

  var androidDetails = new AndroidNotificationDetails(
      "kmrs_merchant_channel", "Orders", "This is my channel",
      icon: "app_icon",
      importance: Importance.max, playSound: true, 
      sound: RawResourceAndroidNotificationSound('merchant_notify'));
  var iOSDetails = new IOSNotificationDetails();
  var generalNotificationDetails =
  new NotificationDetails(android: androidDetails, iOS: iOSDetails);

  await fltrNotification.show(0, title, message, generalNotificationDetails);
}


class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey(debugLabel: "Main Navigator");


  bool isLoggedIn = false;

  _getAppStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final bool status = prefs.getBool(Constants.isLoggedIn) ?? false;
    setState(() {
      isLoggedIn = status;
    });
  }

  _initNotificationSettings() {
    var androidInit = new AndroidInitializationSettings('app_icon');

    var iOSInit = new IOSInitializationSettings();
    var initSettings =
        new InitializationSettings(android: androidInit, iOS: iOSInit);
    fltrNotification = new FlutterLocalNotificationsPlugin();
    fltrNotification.initialize(initSettings,
        onSelectNotification: (String payload) async {
      OpenFile.open(payload);
    });

    _createNotificationChannel(
        "kmrs_merchant_channel", "Orders", "Orders", "merchant_notify");
  }

  Future<void> _createNotificationChannel(
      String id, String name, String description, String sound) async {
    final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    var androidNotificationChannel = AndroidNotificationChannel(
      id,
      name,
      description,
      sound: RawResourceAndroidNotificationSound(sound),
      playSound: true,
      importance: Importance.max
    );
  }

  void _checkAutoStartManager(BuildContext context) async {
    int androidSdkVersion = await getAndroidSdk();
    if (androidSdkVersion == 24 || androidSdkVersion == 25) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      bool isFirstTimeInstall = prefs.getBool(Constants.isFirstInstall) ?? true;
      if (isFirstTimeInstall) {
        bool isAutoStartPermissionAvailable =
        await Autostart.isAutoStartPermissionAvailable;
        if (isAutoStartPermissionAvailable) {
          print('test available ok');
          Autostart.getAutoStartPermission();
        } else {
          print('test available fail');
        }
      }
      prefs.setBool(Constants.isFirstInstall, false);
    }
  }




  @override
  void initState() {
    super.initState();

    _checkAutoStartManager(context);
    _getAppStatus();
    _initNotificationSettings();

    FirebaseMessaging.onMessageOpenedApp.listen(_firebaseMessagingOnClickHandler);

  }

  Future<void> _firebaseMessagingOnClickHandler(RemoteMessage message) async {

    /*SharedPreferences sp = await SharedPreferences.getInstance();
    Map orderMap = jsonDecode(sp.getString('notifOrder'));
    var order = NewOrderModel.fromJson(orderMap);
    *///newOrderBottomSheet(Constants.appContext, Constants.orderModel);
    Constants.isTimerStarted = false;
    Constants.isNotifReceived = true;

    await ClearAllNotifications.clear();

    navigatorKey.currentState.push(
        MaterialPageRoute(builder: (_) => HomeScreen())
    );
  }


  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => ReportProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => CustomPageProvider()),
        ChangeNotifierProvider(create: (_) => CategoryItemProvider()),
        ChangeNotifierProvider(create: (_) => RatingsProvider()),
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
        title: 'Merchant Delivery',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(visualDensity: VisualDensity.adaptivePlatformDensity),
        home: isLoggedIn ? HomeScreen() : LoginScreen(),
        routes: <String, WidgetBuilder>{
          '/editMenu': (context) => MenuEditScreen(),
          '/home': (context) => HomeScreen(),
          '/login': (context) =>  LoginScreen() ,
        },
      ),
    );
  }





}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}




