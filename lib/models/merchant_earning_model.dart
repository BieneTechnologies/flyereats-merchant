class MerchantEarningModel {
  String totalOrders;
  String merchantEarnings;
  String totalItemsSalesAmount;
  String merchantSalesAfterOffers;
  String merchantOffer;
  String feCommission;
  String taxOnCommission;
  String packagingCharges;
  String merchantTax;
  String feVoucherAmount;
  String totalAdjusment;

  MerchantEarningModel(
      {this.totalOrders,
      this.merchantEarnings,
      this.totalItemsSalesAmount,
      this.merchantSalesAfterOffers,
      this.merchantOffer,
      this.feCommission,
      this.taxOnCommission,
      this.packagingCharges,
      this.merchantTax,
      this.feVoucherAmount,
      this.totalAdjusment});

  MerchantEarningModel.fromJson(Map<String, dynamic> json) {
    totalOrders = json['total_orders'];
    merchantEarnings = json['merchant_earnings'];
    totalItemsSalesAmount = json['total_items_sales_amount'];
    merchantSalesAfterOffers = json['merchant_sales_after_offers'];
    merchantOffer = json['merchant_offer'];
    feCommission = json['fe_commission'];
    taxOnCommission = json['tax_on_commission'];
    packagingCharges = json['packaging_charges'];
    merchantTax = json['merchant_tax'];
    feVoucherAmount = json['fe_voucher_amount'];
    totalAdjusment = json['totalAdjustment'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['total_orders'] = this.totalOrders;
    data['merchant_earnings'] = this.merchantEarnings;
    data['total_items_sales_amount'] = this.totalItemsSalesAmount;
    data['merchant_sales_after_offers'] = this.merchantSalesAfterOffers;
    data['merchant_offer'] = this.merchantOffer;
    data['fe_commission'] = this.feCommission;
    data['tax_on_commission'] = this.taxOnCommission;
    data['packaging_charges'] = this.packagingCharges;
    data['merchant_tax'] = this.merchantTax;
    data['fe_voucher_amount'] = this.feVoucherAmount;
    data['totalAdjustment'] = this.totalAdjusment;
    return data;
  }
}
