import 'package:flutter/material.dart';

class OrderModel {
  String orderId;
  String viewed;
  String status;
  String statusRaw;
  String transType;
  String transTypeRaw;
  double totalWTax;
  String totalWTaxPrety;
  String transactionDate;
  String transactionTime;
  String deliveryTime; // bool
  String deliveryAsap;
  String deliveryDate;
  String customerName;
  String totalItems;
  OrderModel(
      {this.orderId,
      this.viewed,
      this.status,
      this.statusRaw,
      this.transType,
      this.transTypeRaw,
      this.totalWTax,
      this.totalWTaxPrety,
      this.transactionDate,
      this.transactionTime,
      this.deliveryTime,
      this.deliveryAsap,
      this.deliveryDate,
      this.customerName,
      this.totalItems});

  OrderModel.fromJson(Map<String, dynamic> json) {
    orderId = json['order_id'];
    viewed = json['viewed'];
    status = json['status'];
    statusRaw = json['status_raw'];
    transType = json['trans_type'];
    transTypeRaw = json['trans_type_raw'];
    totalWTax = double.parse(json['total_w_tax'].toString());
    totalWTaxPrety = json['total_w_tax_prety'];
    transactionDate = json['transaction_date'];
    transactionTime = json['transaction_time'];
    deliveryTime = json['delivery_time_new'];
    deliveryAsap = json['delivery_asap'];
    deliveryDate = json['delivery_date'];
    customerName = json['customer_name'];
    totalItems = json['total_items'].toString();
  }
}
