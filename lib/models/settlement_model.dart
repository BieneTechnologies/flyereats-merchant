import 'dart:convert';

class SettlementModel {
  String totalOrders;
  String totalSettlement;
  String currencyCode;
  List<String> settlementList;
  dynamic merchantEarning;
  String totalItemsSaleAmount;
  String merchantSalesAfterOffers;
  String merchantOffer;
  String feCommission;
  String taxOnComission;
  String packagingCharges;
  String merchantTax;
  String feVoucherAmount;
  dynamic totalAdjustment;
  dynamic subTotal;



  SettlementModel({
    this.totalOrders,
    this.totalSettlement,
    this.currencyCode,
    this.settlementList,
    this.feCommission,
    this.merchantEarning,
    this.feVoucherAmount,
    this.merchantOffer,
    this.merchantSalesAfterOffers,
    this.merchantTax,
    this.packagingCharges,
    this.subTotal,
    this.taxOnComission,
    this.totalAdjustment,
    this.totalItemsSaleAmount
  });

  Map<String, dynamic> toMap() {
    return {
      'total_orders': totalOrders,
      'total_settlement': totalSettlement,
      'currency_code': currencyCode,
      'settlement_list': settlementList,
      'merchant_earnings':  merchantEarning,
      'total_items_sales_amount': totalItemsSaleAmount,
      'merchant_sales_after_offers': merchantSalesAfterOffers,
      'merchant_offer': merchantOffer,
      'fe_commission':feCommission,
      'tax_on_commission':taxOnComission,
      'packaging_charges':packagingCharges,
      'merchant_tax':merchantTax,
      'fe_voucher_amount':feVoucherAmount,
      'totalAdjustment':totalAdjustment,
      'subtotal':subTotal
    };
  }

  factory SettlementModel.fromMap(Map<String, dynamic> map) {
    if (map == null) return null;

    return SettlementModel(
      totalOrders: map['total_orders'],
      totalSettlement: map['total_settlement'],
      currencyCode: map['currency_code'],
      settlementList: List<String>.from(map['settlement_list']),
        merchantEarning:  map['merchant_earnings']   ,
        totalItemsSaleAmount: map['total_items_sales_amount'] ,
        merchantSalesAfterOffers: map ['merchant_sales_after_offers'] ,
        merchantOffer :map['merchant_offer'] ,
        feCommission :map['fe_commission'],
        taxOnComission:map['tax_on_commission'],
        packagingCharges:map['packaging_charges'],
        merchantTax:map['merchant_tax'],
        feVoucherAmount :map['fe_voucher_amount'],
        totalAdjustment:map['totalAdjustment'],
        subTotal :map['subtotal']
    );
  }

  String toJson() => json.encode(toMap());

  factory SettlementModel.fromJson(String source) =>
      SettlementModel.fromMap(json.decode(source));
}

class SettlementPeriodModel {
  String id;
  String period;
  String startDate;
  String endDate;

  SettlementPeriodModel({
    this.id,
    this.period,
    this.startDate,
    this.endDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'period': period,
      'start_date': startDate,
      'end_date': endDate,
    };
  }

  factory SettlementPeriodModel.fromMap(Map<String, dynamic> map) {
    if (map == null) return null;

    return SettlementPeriodModel(
      id: map['id'],
      period: map['period'],
      startDate: map['start_date'],
      endDate: map['end_date'],
    );
  }

  String toJson() => json.encode(toMap());

  factory SettlementPeriodModel.fromJson(String source) =>
      SettlementPeriodModel.fromMap(json.decode(source));
}
