import 'package:flutter/cupertino.dart';

class NewOrderModel {
  String orderId;
  String deliveryDate;
  String deliveryTime;
  String dateCreated;
  String statusRaw;
  List<OrderHistory> orderHistory;
  String marchantName;
  String marchantLogo;
  String address;
  String merchantCity;
  String merchantState;
  String status;
  String merchantId;
  String requestCancel;
  bool isRatingAdded;
  dynamic showCancelOrder;
  String cancelStatus;
  String cancelClass;
  dynamic showReview;
  String deliveryInstruction;
  Html html;
  String correncyCode;
  String customerNumber;

  NewOrderModel(
      {this.orderId,
      this.deliveryDate,
      this.deliveryTime,
      this.dateCreated,
      this.statusRaw,
      this.orderHistory,
      this.marchantName,
      this.marchantLogo,
      this.address,
      this.merchantCity,
      this.merchantState,
      this.status,
      this.merchantId,
      this.requestCancel,
      this.isRatingAdded,
      this.showCancelOrder,
      this.cancelStatus,
      this.cancelClass,
      this.showReview,
      this.deliveryInstruction,
      this.html,
      this.correncyCode,
      this.customerNumber});

  NewOrderModel.fromJson(Map<String, dynamic> json) {
    try {
      orderId = json['order_id'];
      deliveryDate = json['delivery_date'];
      deliveryTime = json['delivery_time'];
      dateCreated = json['date_created'];
      statusRaw = json['status_raw'];

      if (json['order_history'] != null) {
        orderHistory = new List<OrderHistory>();
        json['order_history'].forEach((v) {
          orderHistory.add(new OrderHistory.fromJson(v));
        });
      }
      marchantName = json['marchant_name'];
      marchantLogo = json['marchant_logo'];
      address = json['address'];
      merchantCity = json['merchant_city'];
      merchantState = json['merchant_state'];
      status = json['status'];
      merchantId = json['merchant_id'];
      requestCancel = json['request_cancel'];
      isRatingAdded = json['is_rating_added'];
      showCancelOrder = json['show_cancel_order'];
      cancelStatus = json['cancel_status'];
      cancelClass = json['cancel_class'];
      showReview = json['show_review'];
      deliveryInstruction = json['delivery_instruction'];
      html = json['html'] != null ? new Html.fromJson(json['html']) : null;
      correncyCode = json['corrency_code'];
      customerNumber =
          json['customer_contact'] != null ? json['customer_contact'] : "";
    } catch (ex) {
      debugPrint(ex.toString());
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['order_id'] = this.orderId;
    data['delivery_date'] = this.deliveryDate;
    data['delivery_time'] = this.deliveryTime;
    data['date_created'] = this.dateCreated;
    data['status_raw'] = this.statusRaw;
    if (this.orderHistory != null) {
      data['order_history'] = this.orderHistory.map((v) => v.toJson()).toList();
    }
    data['marchant_name'] = this.marchantName;
    data['marchant_logo'] = this.marchantLogo;
    data['address'] = this.address;
    data['merchant_city'] = this.merchantCity;
    data['merchant_state'] = this.merchantState;
    data['status'] = this.status;
    data['merchant_id'] = this.merchantId;
    data['request_cancel'] = this.requestCancel;
    data['is_rating_added'] = this.isRatingAdded;
    data['show_cancel_order'] = this.showCancelOrder;
    data['cancel_status'] = this.cancelStatus;
    data['cancel_class'] = this.cancelClass;
    data['show_review'] = this.showReview;
    data['delivery_instruction'] = this.deliveryInstruction;
    if (this.html != null) {
      data['html'] = this.html.toJson();
    }
    data['corrency_code'] = this.correncyCode;
    return data;
  }
}

class OrderStatus {
  String orderID;
  String merchantID;

  OrderStatus({this.orderID, this.merchantID});

  OrderStatus.fromJson(Map<String, dynamic> json) {
    orderID = json['order_id'];
    merchantID = json['merchant_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['order_id'] = this.orderID;
    data['merchant_id'] = this.merchantID;
    return data;
  }
}

class PushNotify {
  String title;
  String body;

  PushNotify({this.title, this.body});

  PushNotify.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    body = json['body'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['title'] = this.title;
    data['body'] = this.body;
    return data;
  }
}

class OrderHistory {
  String status;
  String dateCreated;
  String time;

  OrderHistory({this.status, this.dateCreated, this.time});

  OrderHistory.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    dateCreated = json['date_created'];
    time = json['time'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['date_created'] = this.dateCreated;
    data['time'] = this.time;
    return data;
  }
}

class Html {
  List<Item> item;
  Total total;

  Html({this.item, this.total});

  Html.fromJson(Map<String, dynamic> json) {
    if (json['item'] != null) {
      item = new List<Item>();
      json['item'].forEach((v) {
        item.add(new Item.fromJson(v));
      });
    }
    total = json['total'] != null ? new Total.fromJson(json['total']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.item != null) {
      data['item'] = this.item.map((v) => v.toJson()).toList();
    }
    if (this.total != null) {
      data['total'] = this.total.toJson();
    }
    return data;
  }
}

class Addon {
  String addonName;
  String addonCategory;
  dynamic addonQty;
  String addonPrice;
  String subcategoryNameTrans;
  String subItemNameTrans;

  Addon(
      {this.addonName,
      this.addonCategory,
      this.addonQty,
      this.addonPrice,
      this.subcategoryNameTrans,
      this.subItemNameTrans});

  Addon.fromJson(Map<String, dynamic> json) {
    addonName = json['addon_name'];
    addonCategory = json['addon_category'];
    addonQty = json['addon_qty'];
    addonPrice = json['addon_price'];
    subcategoryNameTrans = json['subcategory_name_trans'];
    subItemNameTrans = json['sub_item_name_trans'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['addon_name'] = this.addonName;
    data['addon_category'] = this.addonCategory;
    data['addon_qty'] = this.addonQty;
    data['addon_price'] = this.addonPrice;
    data['subcategory_name_trans'] = this.subcategoryNameTrans;
    data['sub_item_name_trans'] = this.subItemNameTrans;
    return data;
  }
}

class Item {
  String itemId;
  String itemName;
  String sizeWords;
  dynamic qty;
  dynamic normalPrice;
  dynamic discountedPrice;
  dynamic discount;
  String orderNotes;
  // List<String> cookingRef;
  // List<String> ingredients;
  String cookingRef;
  String ingredients;
  String nonTaxable;
  String categoryId;
  String categoryName;
  CategoryNameTrans categoryNameTrans;
  String itemNameTrans;
  String sizeNameTrans;
  String cookingNameTrans;
  List<SubItem> subItem;
  Map<String, List<Addon>> newSubItem;

  Item({
    this.itemId,
    this.itemName,
    this.sizeWords,
    this.qty,
    this.normalPrice,
    this.discountedPrice,
    this.discount,
    this.orderNotes,
    this.cookingRef,
    this.ingredients,
    this.nonTaxable,
    this.categoryId,
    this.categoryName,
    this.categoryNameTrans,
    this.itemNameTrans,
    this.sizeNameTrans,
    this.cookingNameTrans,
    this.subItem,
  });

  Item.fromJson(Map<String, dynamic> json) {
    try {
      itemId = json['item_id'];
      itemName = json['item_name'];
      sizeWords = json['size_words'];
      qty = json['qty'];
      normalPrice = json['normal_price'];
      discountedPrice = json['discounted_price'];
      discount = json['discount'];
      orderNotes = json['order_notes'];
      cookingRef = json['cooking_ref'];
      ingredients = json['ingredients'];
      // if(json['cooking_ref']!=null){
      //   cookingRef = List<String>.from(json['cooking_ref']);
      // }
      // if(json['ingredients']!=null){
      //   ingredients = List<String>.from(json['ingredients']);
      // }
      nonTaxable = json['non_taxable'];
      categoryId = json['category_id'];
      categoryName = json['category_name'];
      categoryNameTrans = json['category_name_trans'] != null
          ? new CategoryNameTrans.fromJson(json['category_name_trans'])
          : null;
      itemNameTrans = json['item_name_trans'];
      sizeNameTrans = json['size_name_trans'];
      cookingNameTrans = json['cooking_name_trans'];
      if (json['sub_item'] != null) {
        subItem = new List<SubItem>();
        json['sub_item'].forEach((v) {
          subItem.add(new SubItem.fromJson(v));
        });
      }
      if (json['new_sub_item'] != null) {
        newSubItem = {};
        final Map<String, dynamic> newSubItemJson = json['new_sub_item'];
        newSubItemJson.forEach((k, v) {
          // print('${k}: ${v}');
          List<Addon> addonList = new List<Addon>();
          v.forEach((addonJson) {
            final addon = Addon.fromJson(addonJson);
            addonList.add(addon);
          });
          newSubItem[k] = addonList;
        });
        debugPrint("new_sub_item $newSubItem");
      }
    } catch (ex) {
      debugPrint(ex.toString());
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['item_id'] = this.itemId;
    data['item_name'] = this.itemName;
    data['size_words'] = this.sizeWords;
    data['qty'] = this.qty;
    data['normal_price'] = this.normalPrice;
    data['discounted_price'] = this.discountedPrice;
    data['discount'] = this.discount;
    data['order_notes'] = this.orderNotes;
    data['cooking_ref'] = this.cookingRef;
    data['ingredients'] = this.ingredients;
    data['non_taxable'] = this.nonTaxable;
    data['category_id'] = this.categoryId;
    data['category_name'] = this.categoryName;
    if (this.categoryNameTrans != null) {
      data['category_name_trans'] = this.categoryNameTrans.toJson();
    }
    data['item_name_trans'] = this.itemNameTrans;
    data['size_name_trans'] = this.sizeNameTrans;
    data['cooking_name_trans'] = this.cookingNameTrans;
    if (this.subItem != null) {
      data['sub_item'] = this.subItem.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class CategoryNameTrans {
  bool categoryNameTrans;

  CategoryNameTrans({this.categoryNameTrans});

  CategoryNameTrans.fromJson(Map<String, dynamic> json) {
    categoryNameTrans = json['category_name_trans'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['category_name_trans'] = this.categoryNameTrans;
    return data;
  }
}

class SubItem {
  String addonName;
  String addonCategory;
  dynamic addonQty;
  String addonPrice;

  SubItem({this.addonName, this.addonCategory, this.addonQty, this.addonPrice});

  SubItem.fromJson(Map<String, dynamic> json) {
    addonName = json['addon_name'];
    addonCategory = json['addon_category'];
    addonQty = (json['addon_qty']);
    addonPrice = json['addon_price'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['addon_name'] = this.addonName;
    data['addon_category'] = this.addonCategory;
    data['addon_qty'] = this.addonQty;
    data['addon_price'] = this.addonPrice;
    return data;
  }
}

class Total {
  String subtotal;
  String taxableTotal;
  String deliveryCharges;
  String total;
  String walletAmount;
  String tax;
  String taxAmt;
  String curr;
  String mid;
  String discountedAmount;
  String merchantDiscountAmount;
  String merchantPackagingCharge;
  String lessVoucher;
  String voucherType;
  String tips;
  String tipsPercent;
  String cartTipPercentage;
  dynamic ptsRedeemAmt;
  String voucherAmount;
  String voucherValue;
  String voucherTypes;
  String calculationMethod;
  dynamic ptsRedeemAmtOrig;
  dynamic lessVoucherOrig;
  String offer_paid_by;

  Total(
      {this.subtotal,
      this.taxableTotal,
      this.deliveryCharges,
      this.total,
      this.walletAmount,
      this.tax,
      this.taxAmt,
      this.curr,
      this.mid,
      this.discountedAmount,
      this.merchantDiscountAmount,
      this.merchantPackagingCharge,
      this.lessVoucher,
      this.voucherType,
      this.tips,
      this.tipsPercent,
      this.cartTipPercentage,
      this.ptsRedeemAmt,
      this.voucherAmount,
      this.voucherValue,
      this.voucherTypes,
      this.calculationMethod,
      this.ptsRedeemAmtOrig,
      this.lessVoucherOrig,
      this.offer_paid_by});

  Total.fromJson(Map<String, dynamic> json) {
    subtotal = json['subtotal'];
    taxableTotal = json['taxable_total'];
    deliveryCharges = json['delivery_charges'];
    total = json['total'];
    walletAmount = json['wallet_amount'];
    tax = json['tax'];
    taxAmt = json['tax_amt'];
    curr = json['curr'];
    mid = json['mid'];
    discountedAmount = json['discounted_amount'];
    merchantDiscountAmount = json['merchant_discount_amount'];
    merchantPackagingCharge = json['merchant_packaging_charge'];
    lessVoucher = json['less_voucher'];
    voucherType = json['voucher_type'];
    tips = json['tips'];
    tipsPercent = json['tips_percent'];
    cartTipPercentage = json['cart_tip_percentage'];
    ptsRedeemAmt = json['pts_redeem_amt'];
    voucherAmount = json['voucher_amount'];
    voucherValue = json['voucher_value'];
    voucherTypes = json['voucher_types'];
    calculationMethod = json['calculation_method'];
    ptsRedeemAmtOrig = json['pts_redeem_amt_orig'];
    lessVoucherOrig = json['less_voucher_orig'];
    offer_paid_by = json['offer_paid_by'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['subtotal'] = this.subtotal;
    data['taxable_total'] = this.taxableTotal;
    data['delivery_charges'] = this.deliveryCharges;
    data['total'] = this.total;
    data['wallet_amount'] = this.walletAmount;
    data['tax'] = this.tax;
    data['tax_amt'] = this.taxAmt;
    data['curr'] = this.curr;
    data['mid'] = this.mid;
    data['discounted_amount'] = this.discountedAmount;
    data['merchant_discount_amount'] = this.merchantDiscountAmount;
    data['merchant_packaging_charge'] = this.merchantPackagingCharge;
    data['less_voucher'] = this.lessVoucher;
    data['voucher_type'] = this.voucherType;
    data['tips'] = this.tips;
    data['tips_percent'] = this.tipsPercent;
    data['cart_tip_percentage'] = this.cartTipPercentage;
    data['pts_redeem_amt'] = this.ptsRedeemAmt;
    data['voucher_amount'] = this.voucherAmount;
    data['voucher_value'] = this.voucherValue;
    data['voucher_types'] = this.voucherTypes;
    data['calculation_method'] = this.calculationMethod;
    data['pts_redeem_amt_orig'] = this.ptsRedeemAmtOrig;
    data['less_voucher_orig'] = this.lessVoucherOrig;
    return data;
  }
}
