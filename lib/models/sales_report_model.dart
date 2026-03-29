import 'package:flutter/material.dart';

class SalesReportModel {
  List<SalesItems> items;
  List<CategoryList> categoryList;
  int totalQuantity;
  int totalCount;

  SalesReportModel({this.items, this.categoryList, this.totalQuantity, this.totalCount});

  SalesReportModel.fromJson(Map<String, dynamic> json) {
    if (json['items'] != null) {
      items = new List<SalesItems>();
      json['items'].forEach((v) {
        items.add(new SalesItems.fromJson(v));
      });
    }
    if (json['category_list'] != null) {
      categoryList = new List<CategoryList>();
      json['category_list'].forEach((v) {
        categoryList.add(new CategoryList.fromJson(v));
      });
    }
    totalQuantity = json['totalQuantity'];
    totalCount = json['totalCount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.items != null) {
      data['items'] = this.items.map((v) => v.toJson()).toList();
    }
    if (this.categoryList != null) {
      data['category_list'] = this.categoryList.map((v) => v.toJson()).toList();
    }
    data['totalQuantity'] = this.totalQuantity;
    data['totalCount'] = this.totalCount;
    return data;
  }
}

class SalesItems {
  String totalQty;
  String count;
  String itemId;
  String itemName;
  String discountedPrice;
  String size;
  String category;
  Color color;

  SalesItems({
    this.totalQty,
    this.count,
    this.itemId,
    this.itemName,
    this.discountedPrice,
    this.size,
    this.category,
    this.color,
  });

  SalesItems.fromJson(Map<String, dynamic> json) {
    totalQty = json['total_qty'];
    count = json['count'];
    itemId = json['item_id'];
    itemName = json['item_name'];
    discountedPrice = json['discounted_price'];
    size = json['size'];
    category = json['category'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['total_qty'] = this.totalQty;
    data['count'] = this.count;
    data['item_id'] = this.itemId;
    data['item_name'] = this.itemName;
    data['discounted_price'] = this.discountedPrice;
    data['size'] = this.size;
    data['category'] = this.category;
    return data;
  }
}

class CategoryList {
  String catId;
  String quantity;
  String categoryName;
  Color color;

  CategoryList({this.catId, this.quantity, this.categoryName, this.color});

  CategoryList.fromJson(Map<String, dynamic> json) {
    catId = json['cat_id'];
    quantity = json['quantity'];
    categoryName = json['category_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['cat_id'] = this.catId;
    data['quantity'] = this.quantity;
    data['category_name'] = this.categoryName;
    return data;
  }
}
