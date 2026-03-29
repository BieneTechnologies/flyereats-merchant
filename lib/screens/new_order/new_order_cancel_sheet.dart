import 'package:flutter/material.dart';
import 'package:merchant_delivery/models/new_order_model.dart';
import 'package:merchant_delivery/providers/order_provider.dart';
import 'package:merchant_delivery/screens/new_order/new_order.dart';
import 'package:merchant_delivery/utils/app_theme.dart';
import 'package:merchant_delivery/utils/constants.dart';
import 'package:merchant_delivery/utils/hex_color.dart';
import 'package:merchant_delivery/widgets/custom_full_width_button.dart';
import 'package:provider/provider.dart';

void cancelOrderBottomSheet(
    BuildContext context, NewOrderModel order, OrderProvider provider) {
  showModalBottomSheet(
    shape: AppTheme.bottomSheetShape,
    backgroundColor: Colors.white,
    context: context,
    isScrollControlled: true,
    enableDrag: true,
    isDismissible: true,
    builder: (_) {
      return WillPopScope(
          onWillPop: () => _return(_, order, provider),
          child: CancelOrderBottomSheet(order: order));
    },
  );
}

Future<bool> _return(
    BuildContext context, NewOrderModel order, OrderProvider provider) {
  provider.updateNewOrderScreenStatus(true);
  Navigator.of(context).pop();
  if (order != null) {
    newOrderBottomSheet(context, order);
  }

  return Future.value(true);
}

class CancelOrderBottomSheet extends StatefulWidget {
  final NewOrderModel order;

  CancelOrderBottomSheet({this.order});

  @override
  _CancelOrderBottomSheetState createState() => _CancelOrderBottomSheetState();
}

class _CancelOrderBottomSheetState extends State<CancelOrderBottomSheet> {
  int _radioButtonId = 0;
  bool _isBtnActive = false;
  TextEditingController _controller = new TextEditingController();

  _declineOrder(BuildContext ctx) async {
    String reason;
    if (_radioButtonId == 4) {
      reason = _controller.text;
    } else {
      reason =
          fList.firstWhere((element) => element.index == _radioButtonId).name;
    }
    final bool result = await Provider.of<OrderProvider>(context, listen: false)
        .declineOrder(ctx, widget.order.orderId, reason);
    if (result) {
      Navigator.pushNamed(context, "/home");
      Provider.of<OrderProvider>(context, listen: false)
          .listenForNewOrders(context);
      Constants.isOrderStatusChanged = false;
      Constants.isNewOrderReceivedByFCM = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context)
              .viewInsets
              .bottom), // Moves to upper when keyboard opened
      child: Container(
        height: MediaQuery.of(context).size.height * 0.8,
        child: ListView(
          shrinkWrap: true,
          children: [
            SizedBox(height: 35),
            Center(
              child: Text(
                "Reason for Cancellation",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: HexColor("#3C3C3C")),
              ),
            ),
            SizedBox(height: 40),
            Container(
              height: 210,
              child: Column(
                children: fList //fList
                    .map((data) => RadioListTile(
                          dense: true,
                          activeColor: HexColor("#2ECC71"),
                          title: Text("${data.name}",
                              style: TextStyle(fontSize: 16)),
                          groupValue: _radioButtonId,
                          value: data.index,
                          onChanged: (val) {
                            setState(() {
                              _radioButtonId = data.index;
                              if (_radioButtonId != 4) {
                                _isBtnActive = true;
                                _controller.clear();
                              } else {
                                _isBtnActive = false;
                              }
                            });
                          },
                        ))
                    .toList(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 24, right: 20),
              child: Container(
                height: 140,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: new ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: 200.0),
                  child: new Scrollbar(
                    child: new SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      reverse: true,
                      child: SizedBox(
                        height: 130.0,
                        child: new TextFormField(
                          enabled: _radioButtonId == 4 ? true : false,
                          controller: _controller,
                          maxLines: 70,
                          decoration: new InputDecoration(
                            hintText: _radioButtonId == 4
                                ? "Please add cancellation reason here"
                                : "",
                            contentPadding: const EdgeInsets.all(8),
                            border: InputBorder.none,
                          ),
                          onChanged: (value) {
                            setState(() {
                              if (value.isEmpty && _radioButtonId == 4) {
                                _isBtnActive = false;
                              } else {
                                _isBtnActive = true;
                              }
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 18),
            CustomFullWidthButton(
              btnTitle: "Cancel the Order",
              callback: () => _declineOrder(context),
              isBtnActive: _isBtnActive,
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class CancellationOption {
  String name;
  int index;

  CancellationOption({this.name, this.index});
}

// region Radio button list
List<CancellationOption> fList = [
  CancellationOption(
    index: 1,
    name: "Item Not Available",
  ),
  CancellationOption(
    index: 2,
    name: "Customer Cancelled the Order",
  ),
  CancellationOption(
    index: 3,
    name: "Shop Closed",
  ),
  CancellationOption(
    index: 4,
    name: "Others",
  ),
];
// endregion
