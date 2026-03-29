import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:merchant_delivery/models/new_order_model.dart';
import 'package:merchant_delivery/providers/order_provider.dart';
import 'package:merchant_delivery/screens/home_screen/order_card_widget.dart';
import 'package:merchant_delivery/screens/new_order/new_order.dart';
import 'package:merchant_delivery/utils/app_theme.dart';
import 'package:merchant_delivery/utils/constants.dart';
import 'package:merchant_delivery/utils/util_functions.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TodayOrders extends StatefulWidget {
  @override
  _TodayOrdersState createState() => _TodayOrdersState();
}

class _TodayOrdersState extends State<TodayOrders> {
  Future<void> _future;
  static Timer _timer;
  int _start = 2;

  _getTodayOrders() async {
    _future = Provider.of<OrderProvider>(context, listen: false)
        .getTodayOrders(context);
  }

  @override
  void initState() {
    _getTodayOrders();
    super.initState();
  }

  void startTimer() {

    const oneSec = const Duration(seconds: 3);
    _timer = new Timer(
      oneSec,
      () {
        if (!Constants.isTimerStarted && Constants.isNotifReceived) {
          setState(() {
            Constants.isTimerStarted = true;
            Constants.isNotifReceived = false;
          });
          // newOrderBottomSheet(context, Constants.orderModel);
        }
      },
    );
  }

  @override
  void dispose() {
    //_timer.cancel();
    //Constants.isTimerStarted = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _future,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasError) {
          return Container(
            height: MediaQuery.of(context).size.height / 2,
            child: Center(child: Text("Error Occurred!")),
          );
        } else if (snapshot.connectionState != ConnectionState.done) {
          return loadingWidget(context);
        } else {
          //timer

          startTimer();
          return Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Consumer<OrderProvider>(
              builder: (context, orderProvider, _) {
                return orderProvider.todayOrders.length != 0
                    ? new ListView.builder(
                        itemCount: orderProvider.todayOrders.length,
                        itemBuilder: (BuildContext ctxt, int index) {
                          return AnimationConfiguration.staggeredList(
                            position: index,
                            duration: const Duration(milliseconds: 120),
                            child: SlideAnimation(
                              verticalOffset: 50.0,
                              child: FadeInAnimation(
                                child: OrderCardWidget(
                                    model: orderProvider.todayOrders[index]),
                              ),
                            ),
                          );
                        },
                      )
                    : new Container(
                        child: Center(
                          child: Text(
                            "No Order Yet",
                            style: new TextStyle(
                                fontSize: 18,
                                color: AppTheme.textColor,
                                fontWeight: FontWeight.w700),
                          ),
                        ),
                      );
              },
            ),
          );
        }
      },
    );
  }
}
