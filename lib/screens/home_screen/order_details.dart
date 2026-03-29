import 'package:flutter/material.dart';
import 'package:merchant_delivery/models/order_detail_model.dart';
import 'package:merchant_delivery/providers/order_provider.dart';
import 'package:merchant_delivery/providers/report_provider.dart';
import 'package:merchant_delivery/utils/app_theme.dart';
import 'package:merchant_delivery/utils/hex_color.dart';
import 'package:merchant_delivery/utils/util_functions.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:custom_timer/custom_timer.dart';

class OrderDetailsScreen extends StatefulWidget {
  final String orderId;
  OrderDetailsScreen({@required this.orderId});
  @override
  _OrderDetailsState createState() => _OrderDetailsState();
}

class _OrderDetailsState extends State<OrderDetailsScreen> {
  final CustomTimerController _controller = CustomTimerController();
  double value=0;
  @override
  void initState() {
    _controller.start();
    super.initState();
  }

  _downloadFile(BuildContext context) async {
    showLoadingDialog(context, "Downloading");
    final bool result =
        await Provider.of<ReportProvider>(context, listen: false)
            .downloadOrderDetails(context, widget.orderId);
    Navigator.of(context).pop();
    if (result)
      showMyFlushbar(context, "Download completed");
    else
      showMyFlushbar(context, "Error Occurred During Download");
  }

  _onFoodReadyClicked(BuildContext context, String orderId) async {
    debugPrint("food ready clicked");
    final bool result = await Provider.of<OrderProvider>(context, listen: false)
        .changeOrderStatus(context, orderId);
    if (result) {
      Navigator.pushNamed(context, "/home");
      showMyFlushbar(context, "Order status changed");
    }
  }

  var _sub;
  var addSubTotal = [];
  var total;

  bool isFoodReady = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.mainBlackColor,
      appBar: AppBar(
        backgroundColor: AppTheme.mainBlackColor,
        elevation: 0,
        title: Text("Order Details"),
        centerTitle: true,
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(Icons.keyboard_arrow_left),
        ),
        actions: [
          GestureDetector(
            onTap: () async {
              var status = await Permission.storage.status;
              if (status.isGranted) {
                // download file
                _downloadFile(context);
              } else {
                //ask permission
                var storageStatus = await Permission.storage.request();
                if (!storageStatus.isGranted) {
                  showMyFlushbar(
                      context, "Please allow to storage access to download");
                } else {
                  _downloadFile(context);
                }
              }
            },
            child: Container(
              child: Image.asset('assets/images/download_icon.png'),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: AppTheme.upperRoundedDecor,
        child: FutureBuilder(
          future: Provider.of<OrderProvider>(context, listen: false)
              .getOrderDetails(context, widget.orderId),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasError) {
              print("errorss${snapshot.error}");
              return Container(
                height: double.infinity,
                width: double.infinity,
                child: Center(child: Text("Error Occurred!")),
              );
            } else if (snapshot.connectionState != ConnectionState.done) {
              return loadingWidget(context);
            } else
              return Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.only(top: 8, bottom: 6),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: getStatusColor(snapshot.data.status),
                      borderRadius: BorderRadius.only(
                          topRight: Radius.circular(20),
                          topLeft: Radius.circular(20)),
                    ),
                    child: Center(
                      child: Text(
                        snapshot.data.status.toUpperCase(),
                        style: new TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.mainWhiteColor),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.only(
                          top: 30, bottom: 30, right: 20, left: 20),
                      shrinkWrap: true,
                      children: [
                        Row(
                          children: <Widget>[
                            Text("ORDER NO - ${snapshot.data.orderId}",
                                style: TextStyle(
                                    fontSize: 14,
                                    color: AppTheme.textColor,
                                    fontWeight: FontWeight.w500)),
                            Spacer(),
                            Icon(Icons.calendar_today,
                                color: HexColor("#000000"), size: 12),
                            Padding(padding: const EdgeInsets.only(right: 5)),
                            Text(snapshot.data.orderHistory[0].dateCreated,
                                style: TextStyle(
                                    fontSize: 12,
                                    color: HexColor("#000000"),
                                    fontWeight: FontWeight.w300)),
                            Padding(padding: const EdgeInsets.only(right: 5)),
                            Icon(Icons.alarm,
                                color: HexColor("#F73E58"), size: 12),
                            Padding(padding: const EdgeInsets.only(right: 5)),
                            Text(snapshot.data.orderHistory[0].time,
                                style: TextStyle(
                                    fontSize: 12,
                                    color: HexColor("#F73E58"),
                                    fontWeight: FontWeight.w300)),
                          ],
                        ),
                        Padding(padding: const EdgeInsets.only(top: 16)),
                        Divider(
                            color: HexColor("#D8D8D8"),
                            thickness: 1.5,
                            height: 0),
                        Padding(padding: const EdgeInsets.only(top: 25)),
                        Text("Order Details",
                            style: TextStyle(
                                fontSize: 14,
                                color: AppTheme.textColor.withOpacity(0.6))),
                        Padding(padding: const EdgeInsets.only(top: 4)),
                        _convertOrdersToWidget(snapshot.data.html.item,
                            snapshot.data.html.total.curr),
                        _convertNewSubOrdersToWidget(snapshot.data.html.item,
                            snapshot.data.html.total.curr),
                        Padding(padding: const EdgeInsets.only(top: 16)),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              _buildSubTotalArea(
                                text: "Sub Total",
                                value:
                                    "${double.parse(_getSubTotal(snapshot.data.html.item)).toStringAsFixed(2)}",
                                curr: snapshot.data.html.total.curr,
                                color: AppTheme.textColor,
                              ),
                              snapshot.data.html.total.discountedAmount !=
                                      "0.00"
                                  ? Column(
                                      children: [
                                        Padding(
                                            padding:
                                                const EdgeInsets.only(top: 12)),
                                        _buildSubTotalArea(
                                          text: (snapshot.data.html.total
                                                          .offer_paid_by !=
                                                      null &&
                                                  snapshot.data.html.total
                                                          .offer_paid_by ==
                                                      "flyereats")
                                              ? "Flyereats offer (${double.parse(snapshot.data.html.total.merchantDiscountAmount).toStringAsFixed(0)}%)"
                                              : "Merchant offer (${double.parse(snapshot.data.html.total.merchantDiscountAmount).toStringAsFixed(0)}%)",
                                          value: snapshot
                                              .data.html.total.discountedAmount,
                                          curr: snapshot.data.html.total.curr,
                                          color: HexColor("#079F5A"),
                                        ),
                                      ],
                                    )
                                  : Container(),
                              snapshot.data.html.total.lessVoucher != "0.00"
                                  ? Padding(
                                      padding: const EdgeInsets.only(top: 12))
                                  : Container(),
                              snapshot.data.html.total.lessVoucher != "0.00"
                                  ? _buildSubTotalArea(
                                      text: "FLYER EATS Voucher Discount",
                                      value:
                                          snapshot.data.html.total.lessVoucher,
                                      curr: snapshot.data.html.total.curr,
                                      color: HexColor("#079F5A"),
                                    )
                                  : Container(),
                              //Sub Total after Discounts
                              snapshot.data.html.total.lessVoucher != "0.00" ||
                                      snapshot.data.html.total.offer_paid_by !=
                                          null
                                  ? Padding(
                                      padding: const EdgeInsets.only(top: 12))
                                  : Container(),
                              snapshot.data.html.total.lessVoucher != "0.00" ||
                                      snapshot.data.html.total.offer_paid_by !=
                                          null
                                  ? _buildSubTotalArea(
                                      text: "Sub Total after Discounts",
                                      value:
                                          "${double.parse(_getSubTotalAfterDiscount(_sub, snapshot.data.html.total.lessVoucher, snapshot.data.html.total.discountedAmount)).toStringAsFixed(2)}",
                                      curr: snapshot.data.html.total.curr,
                                      color: AppTheme.textColor,
                                    )
                                  : Container(),
                              snapshot.data.html.total
                                          .merchantPackagingCharge !=
                                      "0.00"
                                  ? Padding(
                                      padding: const EdgeInsets.only(top: 12))
                                  : Container(),
                              snapshot.data.html.total
                                          .merchantPackagingCharge !=
                                      "0.00"
                                  ? _buildSubTotalArea(
                                      text: "Packaging",
                                      value: snapshot.data.html.total
                                          .merchantPackagingCharge,
                                      curr: snapshot.data.html.total.curr,
                                      color: AppTheme.textColor,
                                    )
                                  : Container(),
                              snapshot.data.html.total.taxableTotal != "0.00"
                                  ? Padding(
                                      padding: const EdgeInsets.only(top: 12))
                                  : Container(),
                              snapshot.data.html.total.taxableTotal != "0.00"
                                  ? _buildSubTotalArea(
                                      text: "Tax (" +
                                          double.parse(snapshot
                                                  .data.html.total.taxAmt)
                                              .toStringAsFixed(0) +
                                          "%)",
                                      value:
                                          snapshot.data.html.total.taxableTotal,
                                      curr: snapshot.data.html.total.curr,
                                      color: AppTheme.textColor,
                                    )
                                  : Container(),
                              Padding(padding: const EdgeInsets.only(top: 12)),
                              Divider(
                                  color: HexColor("#D8D8D8"),
                                  thickness: 1.5,
                                  height: 0),
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
                                  Padding(
                                      padding: const EdgeInsets.only(left: 20)),
                                  Text(
                                    snapshot.data.html.total.curr,
                                    style: TextStyle(
                                        color: HexColor("#000000")
                                            .withOpacity(0.5)),
                                  ),
                                  Text(
                                    "${double.parse(_getTotalAfterDiscount(_sub, snapshot.data.html.total.lessVoucher, snapshot.data.html.total.discountedAmount, snapshot.data.html.total.merchantPackagingCharge, snapshot.data.html.total.taxableTotal)).toStringAsFixed(2)}",
                                    style: TextStyle(
                                        color: AppTheme.textColor,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 18),
                                  ),
                                ],
                              ),
                              Padding(padding: const EdgeInsets.only(top: 12)),
                              Divider(
                                  color: HexColor("#D8D8D8"),
                                  thickness: 1.5,
                                  height: 0),
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
                        Text(
                          snapshot.data.deliveryInstruction,
                          style: TextStyle(
                              color: HexColor("#F27321"),
                              fontSize: 14,
                              fontWeight: FontWeight.w500),
                        ),
                        Padding(padding: const EdgeInsets.only(top: 12)),
                        snapshot.data.driverData != null
                            ? GestureDetector(
                                onTap: () {
                                  launch("tel://" +
                                      snapshot.data.driverData.phone);
                                },
                                child: Column(
                                  children: [
                                    Divider(
                                        color: HexColor("#D8D8D8"),
                                        thickness: 1.5,
                                        height: 0),
                                    Padding(
                                        padding:
                                            const EdgeInsets.only(top: 12)),
                                    Row(
                                      children: [
                                        Text("Driver Number",
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
                                        Text(
                                            "${snapshot.data.driverData.phone}",
                                            style: new TextStyle(
                                                fontSize: 18,
                                                color: AppTheme.textColor,
                                                fontWeight: FontWeight.w500)),
                                      ],
                                    ),
                                  ],
                                ))
                            : Container(),
                        Padding(padding: const EdgeInsets.only(top: 12)),
                        snapshot.data.customerNumber != null &&
                                snapshot.data.customerNumber != ""
                            ? GestureDetector(
                                onTap: () {
                                  launch(
                                      "tel://" + snapshot.data.customerNumber);
                                },
                                child: Column(
                                  children: [
                                    Divider(
                                        color: HexColor("#D8D8D8"),
                                        thickness: 1.5,
                                        height: 0),
                                    Padding(
                                        padding:
                                            const EdgeInsets.only(top: 12)),
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
                                        Text(snapshot.data.customerNumber,
                                            style: new TextStyle(
                                                fontSize: 18,
                                                color: AppTheme.textColor,
                                                fontWeight: FontWeight.w500)),
                                      ],
                                    ),
                                  ],
                                ))
                            : Container(),
                        (snapshot.data.showFoodReady &&
                                snapshot.data.status == "accepted")
                            ? Column(
                                children: [
                                  Padding(
                                      padding: const EdgeInsets.only(top: 24)),
                                  isFoodReady
                                      ? Container(
                                          width: double.infinity,
                                          child: RaisedButton(
                                            color: AppTheme.btnColor,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                            ),
                                            elevation: 3,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(10.0),
                                              child: Text(
                                                "Food Ready",
                                                style: TextStyle(
                                                  fontSize: 24,
                                                  color: AppTheme.textColor,
                                                ),
                                              ),
                                            ),
                                            onPressed: () =>
                                                _onFoodReadyClicked(
                                                    context, widget.orderId),
                                          ),
                                        )
                                      : Container(),

                                      SizedBox(height: 30,),
                                      Text(
                                        "Please click 'Food Ready' button once the food items are prepared",
                                                      style: TextStyle(
                                                        fontSize: 18,
                                                        color: AppTheme.blueColor,
                                                      ),
                                                    ),
                                  // CustomTimer(
                                  //         controller: _controller,
                                  //         begin: Duration(minutes: 2),
                                  //         end: Duration(),
                                  //         onChangeState: (state) {
                                  //           if (state ==
                                  //               CustomTimerState.finished) {
                                  //             setState(() {
                                  //               isFoodReady = true;
                                  //             });
                                  //           }
                                  //         },
                                  //         builder: (time) {
                                  //           double perc = (time.duration.inSeconds / 120) * 100;
                                  //           value = perc / 100;
                                  //           return
                                  //             Stack(
                                  //               children: [
                                  //               Container(
                                  //               height: 200,
                                  //               width: 200,
                                  //               child: Center(
                                  //                   child:
                                  //                   RichText(
                                  //                     textAlign: TextAlign.center,
                                  //                     text:  TextSpan(
                                  //                       style: TextStyle(
                                  //                         fontSize: 16.0,
                                  //                         color: Colors.black,
                                  //                       ),
                                  //                       children: <TextSpan>[
                                  //                         TextSpan(
                                  //                           text: "${time.duration.inSeconds}\n",
                                  //                           style: TextStyle(
                                  //                             fontSize: 28,
                                  //                             color: AppTheme.textColor,
                                  //                             fontWeight: FontWeight.bold
                                  //                           ),
                                  //                         ),
                                  //                         TextSpan(
                                  //                           text: "Seconds\n",
                                  //                           style: TextStyle(
                                  //                               fontSize: 20,
                                  //                               color: AppTheme.textColor,
                                  //                           ),
                                  //                         ),
                                  //                         TextSpan(
                                  //
                                  //                           text: "to enable\n'Food Ready'",
                                  //                           style: TextStyle(
                                  //                             fontSize: 20,
                                  //                             color: AppTheme.textColor,
                                  //                           ),
                                  //                         ),
                                  //                       ],
                                  //                     ),
                                  //                   ),
                                  //
                                  //                         ),
                                  //             ),
                                  //             Container(
                                  //               width: 200,
                                  //               height: 200,
                                  //               // margin: EdgeInsets.all(20),
                                  //               child:
                                  //               CircularProgressIndicator(
                                  //                 backgroundColor: AppTheme.mainBlackColor,
                                  //                 color: AppTheme.btnColor,
                                  //                 strokeWidth: 10,
                                  //                 value: value,
                                  //               ))
                                  //               ]);
                                  //           // return Container(
                                  //           //   width: double.infinity,
                                  //           //   child: RaisedButton(
                                  //           //     color: AppTheme.mainWhiteColor,
                                  //           //     shape: RoundedRectangleBorder(
                                  //           //       borderRadius:
                                  //           //       BorderRadius.circular(10.0),
                                  //           //     ),
                                  //           //     elevation: 3,
                                  //           //     child: Padding(
                                  //           //       padding:
                                  //           //       const EdgeInsets.all(10.0),
                                  //           //       child: Text(
                                  //           //         "${time.duration.inSeconds}",
                                  //           //         style: TextStyle(
                                  //           //           fontSize: 24,
                                  //           //           color: AppTheme.textColor,
                                  //           //         ),
                                  //           //       ),
                                  //           //     ),
                                  //           //     onPressed: () =>{}
                                  //           //   ),
                                  //           // );
                                  //         })
                                ],
                              )
                            : Container(),
                      ],
                    ),
                  )
                ],
              );
          },
        ),
      ),
    );
  }

  _getSubTotalAfterDiscount(var sub, String voucher, String offer) {
    return "${sub - double.parse(voucher.replaceAll(",", "")) - double.parse(offer.replaceAll(",", ""))}";
  }

  _getTotalAfterDiscount(
      var sub, String voucher, String offer, String packaging, String tax) {
    return "${sub - double.parse(voucher.replaceAll(",", "")) - double.parse(offer.replaceAll(",", "")) + double.parse(packaging.replaceAll(",", "")) + double.parse(tax.replaceAll(",", ""))}";
  }

  _getSubTotal(List<Item> items) {
    for (var a in items) {
      addSubTotal.add((a.qty * a.discountedPrice));
    }

    if (addSubTotal.length >= 2) {
      _sub = addSubTotal.reduce((a, b) => a + b);
    } else {
      _sub = addSubTotal[0];
    }

    print("subbeee$_sub");
    return "${_sub.toStringAsFixed(2)}";
  }

  _buildSubTotalArea({String text, String value, String curr, Color color}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Spacer(),
        Text(
          text,
          style: TextStyle(
              color: color, fontWeight: FontWeight.w500, fontSize: 14),
        ),
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
                  text: ' ' + value,
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
                  order.categoryName,
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
                                color: Colors.blue /*HexColor("#03fc20")*/),
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
                        addSubTotal.add(
                            addon.addonQty * double.parse(addon.addonPrice));
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
/*

*/
