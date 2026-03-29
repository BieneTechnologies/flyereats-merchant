import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:merchant_delivery/models/order_model.dart';
import 'package:merchant_delivery/screens/home_screen/order_details.dart';
import 'package:merchant_delivery/utils/app_theme.dart';
import 'package:merchant_delivery/utils/hex_color.dart';
import 'package:merchant_delivery/utils/util_functions.dart';

class OrderCardWidget extends StatelessWidget {
  final OrderModel model;

  OrderCardWidget({this.model});

  DateFormat formatter = new DateFormat("MMM dd, yyyy");

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  OrderDetailsScreen(orderId: model.orderId))),
      child: Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 8, right: 20, left: 20),
        child: Container(
          decoration: BoxDecoration(
              color: AppTheme.mainWhiteColor,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                    color: Color.fromRGBO(0, 0, 0, 0.14),
                    blurRadius: 1.0,
                    spreadRadius: 0.9)
              ]),
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(
                    left: 16.0, right: 16, top: 16, bottom: 8),
                child: Row(
                  children: <Widget>[
                    Text(
                      "ORDER NO - ${model.orderId}",
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.textColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Spacer(),
                    Row(
                      children: <Widget>[
                        Icon(Icons.calendar_today, size: 12),
                        Padding(padding: const EdgeInsets.only(left: 3)),
                        Text(
                          model.transactionDate.substring(0, 11),
                          style: TextStyle(
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(width: 5),
                    Row(
                      children: <Widget>[
                        Icon(Icons.timer, color: HexColor("#F73E58"), size: 12),
                        Padding(padding: const EdgeInsets.only(left: 3)),
                        Text(
                          model.transactionTime,
                          style: TextStyle(
                              fontSize: 12, color: HexColor("#F73E58")),
                        ),
                      ],
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Divider(
                    height: 5, thickness: 1, color: HexColor("#DEDEDE")),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    left: 16.0, right: 16, top: 8, bottom: 8),
                child: Row(
                  children: <Widget>[
                    Text(
                      "Total items - ${model.totalItems}",
                      style: TextStyle(fontSize: 14, color: AppTheme.textColor),
                    ),
                    Spacer(),
                    Text(
                      model.totalWTaxPrety,
                      style: TextStyle(fontSize: 14, color: AppTheme.textColor),
                    ),
                  ],
                ),
              ),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: getStatusColor(model.status),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(10),
                    bottomRight: Radius.circular(10),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    model.status?.toUpperCase(),
                    style: new TextStyle(
                        color: HexColor("#FFFFFF"),
                        fontWeight: FontWeight.w500,
                        fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
