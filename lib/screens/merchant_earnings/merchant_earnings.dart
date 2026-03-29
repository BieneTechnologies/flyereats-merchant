import 'package:flutter/material.dart';
import 'package:merchant_delivery/models/merchant_earning_model.dart';
import 'package:merchant_delivery/providers/report_provider.dart';
import 'package:merchant_delivery/utils/app_theme.dart';
import 'package:merchant_delivery/utils/constants.dart';
import 'package:merchant_delivery/utils/hex_color.dart';
import 'package:merchant_delivery/utils/util_functions.dart';
import 'package:merchant_delivery/widgets/pick_date_bottom_sheet.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class MerchantEarningsScreen extends StatefulWidget {
  @override
  _MerchantEarningsScreenState createState() => _MerchantEarningsScreenState();
}

class _MerchantEarningsScreenState extends State<MerchantEarningsScreen> {
  TextEditingController _pickedDateCtrl =
      new TextEditingController(text: "OVERALL");
  double _selectedDateContainerWidth = 165;
  Future<MerchantEarningModel> _future;
  String _dateType, _startDate, _endDate;

  _getMerchantEarningReport(
      String dateType, String startDate, String endDate) async {
    _future = Provider.of<ReportProvider>(context, listen: false)
        .getMerchantEarningReport(context, dateType, startDate, endDate);
  }

  _selectPeriod() async {
    pickDateBottomSheet(context, _callBack);
  }

  _callBack(String parameter, String formattedValue) {
    String dtType, stDt, endDt;
    final dateType = parameter.substring(0, 6);
    if (dateType == Constants.optDate) {
      final optIndex = parameter.substring(6, 7);
      // region update Container width
      setState(() {
        if (optIndex == "1") {
          // Today
          _selectedDateContainerWidth = 145;
          dtType = "today";
          _dateType = "today";
        } else if (optIndex == "2") {
          // Last 7 days
          _selectedDateContainerWidth = 190;
          dtType = "weekly";
          _dateType = "weekly";
        } else if (optIndex == "3") {
          //Last 30 days
          _selectedDateContainerWidth = 210;
          dtType = "monthly";
          _dateType = "monthly";
        } else if (optIndex == "4") {
          // Overall
          _selectedDateContainerWidth = 165;
          dtType = null;
          _dateType = null;
        }
      });
      //endregion

    } else if (dateType == Constants.fixDate) {
      stDt = parameter.substring(6, 17); //Or End Date
      dtType = "fixed";
      _dateType = "fixed";
      setState(() {
        _selectedDateContainerWidth = 190;
      });
    } else if (dateType == Constants.rangeDate) {
      dtType = "range";
      _dateType = "range";
      stDt = parameter.substring(6, 17);
      endDt = parameter.split("DDD")[1].substring(0, 10);
      _startDate = stDt;
      _endDate = endDt;
      print("stdtdtdttd$stDt");
      setState(() {
        _selectedDateContainerWidth = 300;
      });
    }
    _pickedDateCtrl.text = formattedValue;
    _getMerchantEarningReport(dtType, stDt, endDt);
  }

  _downloadFile() async {
    showLoadingDialog(context, "Downloading");

    final int result = await Provider.of<ReportProvider>(context, listen: false)
        .downloadInvoice(
            context, _dateType ?? "", _startDate ?? "", _endDate ?? "");
    Navigator.of(context).pop();
    if (result == 1)
      showMyFlushbar(context, "Download completed");
    else if (result == 2)
      showMyFlushbar(context, "No file available!");
    else
      showMyFlushbar(context, "Error Occurred During Download");
  }

  @override
  void initState() {
    _getMerchantEarningReport(null, null, null);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.mainBlackColor,
      appBar: AppBar(
        backgroundColor: AppTheme.mainBlackColor,
        elevation: 0,
        title: Text("Total Earnings"),
        centerTitle: true,
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(Icons.keyboard_arrow_left),
        ),
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: AppTheme.upperRoundedDecor,
        padding: const EdgeInsets.only(top: 20, left: 16, right: 16),
        child: SafeArea(
          child: Column(
            children: [
              //#region  Top period selection screen
              GestureDetector(
                onTap: () => _selectPeriod(),
                child: AbsorbPointer(
                  child: FittedBox(
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      width: _selectedDateContainerWidth,
                      child: TextFormField(
                        textAlign: TextAlign.center,
                        controller: _pickedDateCtrl,
                        keyboardType: TextInputType.datetime,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 15),
                          isDense: true,
                          prefixIcon: Icon(Icons.calendar_today,
                              size: 20, color: HexColor("#000000")),
                          suffixIcon: Icon(Icons.keyboard_arrow_down,
                              size: 16, color: HexColor("#BCBCBC")),
                        ),
                        style:
                            TextStyle(fontSize: 16, color: AppTheme.textColor),
                      ),
                    ),
                  ),
                ),
              ),
              //endregion
              Divider(color: HexColor("#D8D8D8"), thickness: 1.5, height: 0),
              FutureBuilder(
                future:
                    _future, //Provider.of<ReportProvider>(context, listen: false).getSalesReport(context),
                builder: (BuildContext context,
                    AsyncSnapshot<MerchantEarningModel> snapshot) {
                  if (snapshot.hasError) {
                    return Container(
                      height: MediaQuery.of(context).size.height / 2,
                      child: Center(child: Text("Error Occurred!")),
                    );
                  } else if (snapshot.connectionState != ConnectionState.done) {
                    return Expanded(child: loadingWidget(context));
                  } else
                    return Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Wrap(
                                alignment: WrapAlignment.center,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                spacing: 18,
                                children: [
                                  Column(
                                    children: [
                                      Text(
                                        snapshot.data.totalOrders,
                                        style: TextStyle(
                                            fontSize: 40,
                                            fontWeight: FontWeight.bold,
                                            color: HexColor("#F27321")),
                                      ),
                                      Text(
                                        "Total Orders",
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w500,
                                            color: HexColor("#3C3C3C")),
                                      )
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      Text(
                                        snapshot.data.merchantEarnings,
                                        style: TextStyle(
                                            fontSize: 40,
                                            fontWeight: FontWeight.bold,
                                            color: HexColor("#F27321")),
                                      ),
                                      Text(
                                        "Merchant Earnings",
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w500,
                                            color: HexColor("#3C3C3C")),
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Divider(
                                color: HexColor("#D8D8D8"),
                                thickness: 1.5,
                                height: 0),
                            Padding(padding: const EdgeInsets.only(top: 15)),
                            _rowTextBuilder(
                              "Total Item Sales Amount",
                              snapshot.data.totalItemsSalesAmount,
                              new TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: HexColor("#3C3C3C")),
                            ),
                            SizedBox(height: 23),
                            _rowTextBuilder(
                              "Merchant Sales after Offer ",
                              snapshot.data.merchantSalesAfterOffers,
                              new TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: HexColor("#3C3C3C")),
                            ),
                            SizedBox(height: 14),
                            _rowTextBuilder(
                              "Merchant Offer (-) ",
                              snapshot.data.merchantOffer,
                              new TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: HexColor("#FF0000")),
                            ),
                            SizedBox(height: 25),
                            _rowTextBuilder(
                              "FLYER EATS Commission (-) ",
                              snapshot.data.feCommission,
                              new TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: HexColor("#FF0000")),
                            ),
                            SizedBox(height: 25),
                            _rowTextBuilder(
                              "Tax on Commission (-) ",
                              snapshot.data.taxOnCommission,
                              new TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: HexColor("#FF0000")),
                            ),
                            SizedBox(height: 24),
                            _rowTextBuilder(
                              "Packaging Charges (+) ",
                              snapshot.data.packagingCharges,
                              new TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: HexColor("#3C3C3C")),
                            ),
                            SizedBox(height: 28),
                            _rowTextBuilder(
                              "Merchant Tax (+) ",
                              snapshot.data.merchantTax,
                              new TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: HexColor("#3C3C3C")),
                            ),
                            SizedBox(height: 24),
                            _rowTextBuilder(
                              "Adjustment (" +
                                  (double.parse(snapshot.data.totalAdjusment) >=
                                          0
                                      ? "+"
                                      : "-") +
                                  ") ",
                              ("\u20b9 " + snapshot.data.totalAdjusment),
                              new TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: HexColor((double.parse(
                                              snapshot.data.totalAdjusment) >=
                                          0
                                      ? "3C3C3C"
                                      : "FF0000"))),
                            ),
                            SizedBox(height: 10),
                            Divider(
                                color: HexColor("#D8D8D8"),
                                thickness: 1.5,
                                height: 0),
                            SizedBox(height: 17),
                            _rowTextBuilder(
                              "Merchant Earnings ",
                              snapshot.data.merchantEarnings,
                              new TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: HexColor("#3C3C3C")),
                            ),
                            SizedBox(height: 20),
                            Divider(
                                color: HexColor("#D8D8D8"),
                                thickness: 1.5,
                                height: 0),
                            SizedBox(height: 22),
                            Text(
                              "* External adjustments are not captures in the above earnings",
                              style: new TextStyle(
                                  color: HexColor("#000000"),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12),
                            ),
                            SizedBox(height: 9),
                            Container(
                              decoration: new BoxDecoration(
                                color: HexColor("#F0F0F0"),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.only(
                                  top: 21, bottom: 5, right: 30, left: 30),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "FLYER EATS Voucher Awarded to Client",
                                    style: new TextStyle(
                                        color: HexColor("F27321"),
                                        fontWeight: FontWeight.w700,
                                        fontSize: 18),
                                  ),
                                  SizedBox(height: 8),
                                  //TODO: change data ask it
                                  Text(
                                    snapshot.data.merchantOffer,
                                    style: new TextStyle(
                                        color: HexColor("#3C3C3C"),
                                        fontSize: 30,
                                        fontWeight: FontWeight.w700),
                                  )
                                ],
                              ),
                            ),
                            SizedBox(height: 31),
                            GestureDetector(
                              onTap: () async {
                                var status = await Permission.storage.status;
                                debugPrint("status $status");
                                if (status.isGranted) {
                                  // download file
                                  _downloadFile();
                                } else {
                                  //ask permission
                                  var storageStatus =
                                      await Permission.storage.request();
                                  if (!storageStatus.isGranted) {
                                    showMyFlushbar(context,
                                        "Please allow to storage access to download");
                                  } else {
                                    _downloadFile();
                                  }
                                }
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    'assets/images/download_icon.png',
                                    height: 22,
                                  ),
                                  Padding(
                                      padding: const EdgeInsets.only(right: 8)),
                                  Text(
                                    "Download Order Details",
                                    style: new TextStyle(
                                        color: HexColor("#F27321"),
                                        fontSize: 20,
                                        fontWeight: FontWeight.w700),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 31),
                          ],
                        ),
                      ),
                    );
                },
              )
            ],
          ),
        ),
      ),
    );
  }

  _rowTextBuilder(String t1, String t2, TextStyle style) {
    return new Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(t1, style: style),
        Flexible(child: Text(t2, style: style)),
      ],
    );
  }
}
