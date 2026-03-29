import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:merchant_delivery/models/new_order_model.dart';
import 'package:merchant_delivery/providers/order_provider.dart';
import 'package:merchant_delivery/screens/home_screen/home_screen.dart';
import 'package:merchant_delivery/screens/home_screen/order_details.dart';
import 'package:merchant_delivery/screens/new_order/new_order_cancel_sheet.dart';
import 'package:merchant_delivery/utils/app_theme.dart';
import 'package:merchant_delivery/utils/constants.dart';
import 'package:merchant_delivery/utils/hex_color.dart';
import 'package:merchant_delivery/utils/util_functions.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
// import 'package:visibility_detector/visibility_detector.dart';

void newOrderBottomSheet(BuildContext context, NewOrderModel newOrderModel) {
  // Constants.isNewOrderReceivedByFCM = true;
  print("NEW-ORDER = in function = newOrderBottomSheet");
  print("NEW-ORDER = in function = orderid = ${newOrderModel.orderId}");
  showModalBottomSheet(
    shape: AppTheme.bottomSheetShape,
    backgroundColor: Colors.white,
    context: context,
    isScrollControlled: true,
    enableDrag: false,
    isDismissible: false,
    builder: (BuildContext bc) {
      return WillPopScope(
        onWillPop: () async => false,
        child: NewOrderBottomScreen(
          order: newOrderModel,
        )
      );
      // Send parameter
    },
  );
}

class NewOrderBottomScreen extends StatelessWidget {
  final NewOrderModel order;

  NewOrderBottomScreen({@required this.order});

  var _sub;
  var addSubTotal = [];

  bool subOne = false;

  @override
  Widget build(BuildContext context) {
    final orderPvd = Provider.of<OrderProvider>(context, listen: true);
    final values = order.dateCreated.split(' ');
    print('currentNewOrders: ${orderPvd.currentNewOrders}');

    final newOrdersCount = orderPvd.todayOrders
        .where((element) => element.status.contains("pending"))
        .length;

    String orderPaid = order.html.total.offer_paid_by != null &&
            order.html.total.offer_paid_by == "flyereats"
        ? "Flyereats offer"
        : "Merchant offer";

    return Container(
      decoration: AppTheme.upperRoundedDecor,
      height: MediaQuery.of(context).size.height * 0.75,
      child: ListView(
        padding:
            const EdgeInsets.only(top: 20, bottom: 20, right: 20, left: 20),
        shrinkWrap: true,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "New Order - " + orderPvd.currentNewOrders.toString(),
                style: TextStyle(
                    fontSize: 18,
                    color: HexColor("#3C3C3C"),
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Padding(padding: const EdgeInsets.only(top: 26)),
          Row(
            children: <Widget>[
              Text("ORDER NO - " + order.orderId,
                  style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.textColor,
                      fontWeight: FontWeight.w500)),
              Spacer(),
              Icon(Icons.calendar_today, color: HexColor("#000000"), size: 12),
              Padding(padding: const EdgeInsets.only(right: 5)),
              Text(
                  values[0].toString(),
                  // order.orderHistory.length > 0
                  //     ? order.orderHistory[0].dateCreated
                  //     : "",

                  style: TextStyle(
                      fontSize: 12,
                      color: HexColor("#000000"),
                      fontWeight: FontWeight.w300)),
              Padding(padding: const EdgeInsets.only(right: 5)),
              Icon(Icons.alarm, color: HexColor("#F73E58"), size: 12),
              Padding(padding: const EdgeInsets.only(right: 5)),
              Text(
                  values[1].toString(),
                  // order.orderHistory.length > 0
                  //     ? order.orderHistory[0].time
                  //     : "",
                  style: TextStyle(
                      fontSize: 12,
                      color: HexColor("#F73E58"),
                      fontWeight: FontWeight.w300)),
            ],
          ),
          Padding(padding: const EdgeInsets.only(top: 16)),
          Divider(color: HexColor("#D8D8D8"), thickness: 1.5, height: 0),
          Padding(padding: const EdgeInsets.only(top: 25)),
          Text("Order Details",
              style: TextStyle(
                  fontSize: 14, color: AppTheme.textColor.withOpacity(0.6))),
          Padding(padding: const EdgeInsets.only(top: 4)),
          _convertOrdersToWidget(order.html.item, order.html.total.curr),
          _convertNewSubOrdersToWidget(order.html.item, order.html.total.curr),
          Padding(padding: const EdgeInsets.only(top: 16)),
          Align(
            alignment: Alignment.bottomRight,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _buildSubTotalArea(
                  text: "Sub Total",
                  value: _getSubTotal(
                      order.html.item) /*order.html.total.subtotal*/,
                  curr: order.html.total.curr,
                  color: AppTheme.textColor,
                ),
                order.html.total.discountedAmount != "0.00"
                    ? Column(
                        children: [
                          Padding(padding: const EdgeInsets.only(top: 12)),
                          _buildSubTotalArea(
                            text: orderPaid +
                                " (${order.html.total.merchantDiscountAmount}%)",
                            value: order.html.total.discountedAmount,
                            curr: order.html.total.curr,
                            color: HexColor("#079F5A"),
                          ),
                        ],
                      )
                    : Container(),
                order.html.total.lessVoucher != "0.00"
                    ? Padding(padding: const EdgeInsets.only(top: 12))
                    : Container(),
                order.html.total.lessVoucher != "0.00"
                    ? _buildSubTotalArea(
                        text: "FLYER EATS Voucher Discount",
                        value: order.html.total.lessVoucher,
                        curr: order.html.total.curr,
                        color: HexColor("#079F5A"),
                      )
                    : Container(),
                //Sub Total after Discounts
                order.html.total.lessVoucher != "0.00" ||
                        order.html.total.offer_paid_by != null
                    ? Padding(padding: const EdgeInsets.only(top: 12))
                    : Container(),
                order.html.total.lessVoucher != "0.00" ||
                        order.html.total.offer_paid_by != null
                    ? _buildSubTotalArea(
                        text: "Sub Total after Discounts",
                        value: _getSubTotalAfterDiscount(
                            _sub,
                            order.html.total.lessVoucher,
                            order.html.total.discountedAmount),
                        curr: order.html.total.curr,
                        color: AppTheme.textColor,
                      )
                    : Container(),

                order.html.total.merchantPackagingCharge != "0.00"
                    ? Padding(padding: const EdgeInsets.only(top: 12))
                    : Container(),
                order.html.total.merchantPackagingCharge != "0.00"
                    ? _buildSubTotalArea(
                        text: "Packaging",
                        value: order.html.total.merchantPackagingCharge,
                        curr: order.html.total.curr,
                        color: AppTheme.textColor,
                      )
                    : Container(),
                // order.html.total.taxableTotal != "0.00"
                //     ? Padding(padding: const EdgeInsets.only(top: 12))
                //     : Container(),
                // order.html.total.taxableTotal != "0.00"
                //     ? _buildSubTotalArea(
                //         text: "Tax (" +
                //             double.parse(order.html.total.taxAmt)
                //                 .toStringAsFixed(0) +
                //             "%)",
                //         value: order.html.total.taxableTotal,
                //         curr: order.html.total.curr,
                //         color: AppTheme.textColor,
                //       )
                //     : Container(),
                Padding(padding: const EdgeInsets.only(top: 12)),
                Divider(color: HexColor("#D8D8D8"), thickness: 1.5, height: 0),
                Padding(padding: const EdgeInsets.only(top: 12)),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "TOTAL",
                      style: TextStyle(
                          color: AppTheme.textColor,
                          fontWeight: FontWeight.w500,
                          fontSize: 18),
                    ),
                    Padding(padding: const EdgeInsets.only(left: 20)),
                    Text(
                      order.html.total.curr,
                      style: TextStyle(
                          color: HexColor("#000000").withOpacity(0.5)),
                    ),
                    Text(
                      _getTotalAfterDiscount(
                          _sub,
                          order.html.total.lessVoucher,
                          order.html.total.discountedAmount,
                          order.html.total.merchantPackagingCharge,
                          order.html.total.taxableTotal),
                      style: TextStyle(
                          color: AppTheme.textColor,
                          fontWeight: FontWeight.w500,
                          fontSize: 18),
                    ),
                  ],
                ),
                Padding(padding: const EdgeInsets.only(top: 12)),
                Divider(color: HexColor("#D8D8D8"), thickness: 1.5, height: 0),
                Padding(padding: const EdgeInsets.only(top: 12)),
              ],
            ),
          ),
          Text(
            "Order Instruction",
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: HexColor("#000000")),
          ),
          Padding(padding: const EdgeInsets.only(top: 12)),
          Padding(padding: const EdgeInsets.only(top: 12)),
          order.customerNumber != null && order.customerNumber != ""
              ? GestureDetector(
                  onTap: () {
                    launch("tel://" + order.customerNumber);
                  },
                  child: Column(
                    children: [
                      Divider(
                          color: HexColor("#D8D8D8"),
                          thickness: 1.5,
                          height: 0),
                      Padding(padding: const EdgeInsets.only(top: 12)),
                      Row(
                        children: [
                          Text("Client Number",
                              style: new TextStyle(
                                  fontSize: 14,
                                  color: AppTheme.textColor,
                                  fontWeight: FontWeight.w500)),
                          Spacer(),
                          Icon(
                            Icons.phone,
                            size: 18,
                            color: AppTheme.textColor,
                          ),
                          Text(order.customerNumber,
                              style: new TextStyle(
                                  fontSize: 18,
                                  color: AppTheme.textColor,
                                  fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ],
                  ))
              : Container(),
          Text(
            order.deliveryInstruction ?? "",
            style: TextStyle(
                color: HexColor("#F27321"),
                fontSize: 14,
                fontWeight: FontWeight.w500),
          ),
          Padding(padding: const EdgeInsets.only(top: 12)),
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  // remove current newOrder screen
                  orderPvd.updateNewOrderScreenStatus(false);
                  Navigator.of(context).pop();
                  cancelOrderBottomSheet(context, order, orderPvd);
                },
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.40,
                  height: 50,
                  decoration: BoxDecoration(
                    border: Border.all(color: HexColor("#313233"), width: 2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      "CANCEL",
                      style: new TextStyle(
                          color: HexColor("#313233"), fontSize: 18),
                    ),
                  ),
                ),
              ),
              Spacer(),
              GestureDetector(
                onTap: () async {
                  // remove current newOrder screen
                  print("Accept tapped");
                  Constants.isOrderStatusChanged = false;
                  Constants.isNewOrderReceivedByFCM = false;
                  final bool result =
                      await orderPvd.acceptOrder(context, order.orderId);
                  if (result) {
                    orderPvd.updateNewOrderScreenStatus(false);
                    Navigator.pushNamed(context, "/home");
                    Provider.of<OrderProvider>(context, listen: false)
                        .listenForNewOrders(context);
                    showMyFlushbar(context, "Order accepted");
                    // Navigator.push(
                    //     context,
                    //     MaterialPageRoute(
                    //         builder: (context) =>
                    //             OrderDetailsScreen(orderId: order.orderId)));
                  }
                },
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.40,
                  height: 50,
                  decoration: BoxDecoration(
                    color: HexColor("#FFB531"),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      "ACCEPT",
                      style: new TextStyle(
                          color: HexColor("#313233"), fontSize: 18),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  _getSubTotalAfterDiscount(var sub, String voucher, String offer) {
    return "${sub - double.parse(voucher.replaceAll(",", "")) - double.parse(offer.replaceAll(",", ""))}";
  }

  _getTotalAfterDiscount(
      var sub, String voucher, String offer, String packaging, String tax) {
    // return "${sub - double.parse(voucher.replaceAll(",", "")) - double.parse(offer.replaceAll(",", "")) + double.parse(packaging.replaceAll(",", "")) + double.parse(tax.replaceAll(",", ""))}";
    return "${sub - double.parse(voucher.replaceAll(",", "")) - double.parse(offer.replaceAll(",", "")) + double.parse(packaging.replaceAll(",", ""))}";
  }

  _getSubTotal(List<Item> items) {
    if (!subOne)
      for (var a in items) {
        addSubTotal.add((a.qty * a.discountedPrice));
      }

    print("addsubtotal$addSubTotal");
    if (addSubTotal.length >= 2) {
      _sub = addSubTotal.reduce((a, b) => a + b);
    } else {
      _sub = addSubTotal[0];
    }

    print("subbeee$_sub");
    subOne = true;
    return "${_sub.toStringAsFixed(2)}";
  }

  _buildSubTotalArea({String text, String value, String curr, Color color}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Spacer(),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
                color: color, fontWeight: FontWeight.w500, fontSize: 14),
            textAlign: TextAlign.right,
          ),
        ),
        Padding(padding: const EdgeInsets.only(left: 20)),
        Container(
          width: 100,
          child: RichText(
            textAlign: TextAlign.right,
            text: TextSpan(
              text: curr,
              style: TextStyle(
                  color: HexColor("#000000").withOpacity(0.5),
                  fontSize: 14,
                  fontWeight: FontWeight.w500),
              children: <TextSpan>[
                TextSpan(
                  text: ' ' + value, //hossy
                  style: TextStyle(
                      color: AppTheme.textColor,
                      fontWeight: FontWeight.w500,
                      fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  _convertOrdersToWidget(List<Item> items, String curr) {
    return Column(
        children: items.map((order) {
      return Column(
        children: [
          Padding(padding: const EdgeInsets.only(top: 12)),
          Row(
            children: [
              Flexible(
                child: Text(
                  order.categoryName ?? '',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textColor),
                ),
              ),
            ],
          ),
          Padding(padding: const EdgeInsets.only(top: 12)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  order.itemName +
                      " (" +
                      (order.sizeWords.length > 0
                          ? order.sizeWords + " - "
                          : "") +
                      " ${order.qty} X $curr${order.discountedPrice})",
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textColor),
                ),
              ),
              Text(
                curr +
                    " " +
                    (order.qty * order.discountedPrice).toStringAsFixed(2),
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textColor),
              ),
            ],
          ),
          Padding(padding: const EdgeInsets.only(top: 12)),
          Divider(color: HexColor("#D8D8D8"), thickness: 1.5, height: 0),
        ],
      );
    }).toList());
  }

  _convertNewSubOrdersToWidget(List<Item> items, String curr) {
    return Column(
        children: items.map((order) {
      return order.newSubItem != null
          ? Column(
              children: order.newSubItem.entries.map((e) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(padding: const EdgeInsets.only(top: 12)),
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            e.key,
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: HexColor("#03fc20")),
                          ),
                        ),
                      ],
                    ),
                    Padding(padding: const EdgeInsets.only(top: 12)),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: e.value.map((addon) {
                        int lastItem = e.value.length - 1;
                        int currItemIndex = e.value.indexOf(addon);
                        if (!subOne) {
                          addSubTotal.add(
                              addon.addonQty * double.parse(addon.addonPrice));
                        }
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: Text(
                                    addon.addonName +
                                        " (${addon.addonQty} X $curr${addon.addonPrice})",
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: AppTheme.textColor),
                                    textAlign: TextAlign.left,
                                  ),
                                ),
                                Text(
                                  curr +
                                      " " +
                                      (addon.addonQty *
                                              double.parse(addon.addonPrice))
                                          .toStringAsFixed(2),
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: AppTheme.textColor),
                                ),
                              ],
                            ),
                            lastItem != currItemIndex
                                ? SizedBox(height: 8)
                                : Container(),
                          ],
                        );
                      }).toList(),
                    ),
                    Padding(padding: const EdgeInsets.only(top: 12)),
                    Divider(
                        color: HexColor("#D8D8D8"), thickness: 1.5, height: 0),
                  ],
                );
              }).toList(),
            )
          : Container();
    }).toList());
  }
}
