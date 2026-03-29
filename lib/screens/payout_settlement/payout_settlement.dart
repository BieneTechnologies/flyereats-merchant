import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:merchant_delivery/models/ratings_model.dart';
import 'package:merchant_delivery/models/settlement_model.dart';
import 'package:merchant_delivery/providers/rating_provider.dart';
import 'package:merchant_delivery/providers/report_provider.dart';
import 'package:merchant_delivery/providers/settlement_provider.dart';
import 'package:merchant_delivery/screens/payout_settlement/settlement_pick_period.dart';
import 'package:merchant_delivery/utils/app_theme.dart';
import 'package:merchant_delivery/utils/hex_color.dart';
import 'package:merchant_delivery/utils/util_functions.dart';
import 'package:merchant_delivery/widgets/custom_appbar.dart';
import 'package:merchant_delivery/widgets/drawer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:charts_flutter/flutter.dart' as charts;

import '../../main.dart';

class LinearSales {
  final int year;
  final double sales;
  final Color color;

  LinearSales(this.year, this.sales, this.color);
}

class PayoutSettlementScreen extends StatefulWidget {
  @override
  _PayoutSettlementScreenState createState() => _PayoutSettlementScreenState();
}

class _PayoutSettlementScreenState extends State<PayoutSettlementScreen> {
  TextEditingController _pickedDateCtrl =
      new TextEditingController(text: "OVERALL");
  double _selectedDateContainerWidth = 300;
  List<charts.Series> seriesList;

  _selectPeriod() async {
    PickedPeriod period =
        await pickPeriodBottomSheet(context, _callBack, year, month);

    if (period == null) {
      _loadSettlement();
    } else {
      _loadSettlement(period);
    }
  }

  _callBack(String parameter, String formattedValue) {}

  SettlementModel model = null;

  @override
  void initState() {
    super.initState();
    _loadSettlement();
  }

  String month = "", year = "" ,startDate = "", endDate = "",D="";


  _loadSettlement([PickedPeriod period = null]) {
    SettlementProvider provider = new SettlementProvider();
    String periods = "";
    if (period != null) {
      setState(() {

        month = period.month;
        year = period.year;

        periods = period.id;
      // String periodTime = period.period.substring(0,6)+" $year" +period.period.substring(6,16)+" $year";
        String periodTime = period.period;
       _pickedDateCtrl.text = periodTime??"";
       startDate = period.startDate;//periodTime.substring(0,11);
       endDate = period.endDate;//periodTime.substring(16,26);

      });


    } else {
      _pickedDateCtrl.text = "OVERALL";
    }

    provider.getSettlement(context, true, periods).then((value) {
      setState(() {
        model = value;
        seriesList = _createSeriesData(model.settlementList);
      });
    });
  }

  _downloadFile() async {

     showLoadingDialog(context, "Downloading");
    final int result = await Provider.of<ReportProvider>(context, listen: false)
        .downloadInvoice(context, "range", startDate??"", endDate??"");
    print("ss$startDate");
    Navigator.of(context).pop();
    if (result == 1)
      showMyFlushbar(context, "Download completed");
    else if (result == 2)
      showMyFlushbar(context, "No file available!");
    else
      showMyFlushbar(context, "Error Occurred During Download");
  }

  static List<charts.Series<LinearSales, int>> _createSeriesData(
      List<String> sData) {
    Random rand = new Random();
    rand.nextInt(200);

    List<LinearSales> data = [];
    int index = 0;
    List<int> currentColors = [];
    for (String s in sData) {
      int nextInt = rand.nextInt(Colors.primaries.length);
      /*while (currentColors.contains(nextInt)) {
        nextInt = rand.nextInt(Colors.primaries.length);
      }*/

      data.add(
          new LinearSales(index, double.parse(s), Colors.primaries[0]));
      currentColors.add(nextInt);
      index++;
    }

    return [
      new charts.Series<LinearSales, int>(
        id: 'Sales',
        domainFn: (LinearSales sales, _) => sales.year,
        measureFn: (LinearSales sales, _) => sales.sales,
        colorFn: (LinearSales task, _) =>
            charts.ColorUtil.fromDartColor(task.color),
        data: data,
        labelAccessorFn: (LinearSales row, _) =>
            '${row.sales.toStringAsFixed(2)}',
      )
    ];
  }

  _pop() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => _pop(),
      child: Scaffold(
        backgroundColor: AppTheme.mainBlackColor,
        appBar: AppBar(
          backgroundColor: AppTheme.mainBlackColor,
          elevation: 0,
          title: Text("Payout Settlement"),
          centerTitle: true,
          leading: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Icon(Icons.keyboard_arrow_left),
          ),
        ),
        body: model!=null?Container(
            height: MediaQuery.of(context).size.height,
            width: double.infinity,
            padding:
                const EdgeInsets.only(top: 30, bottom: 10, left: 30, right: 30),
            decoration: AppTheme.upperRoundedDecor,
            child: LayoutBuilder(builder: (context, constraints) {
              return ConstrainedBox(
                constraints: BoxConstraints(
                    minWidth: constraints.maxWidth,
                    minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: SafeArea(
                    child: Container(
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
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
                                      contentPadding:
                                          EdgeInsets.symmetric(vertical: 15),
                                      isDense: true,
                                      prefixIcon: Icon(Icons.calendar_today,
                                          size: 20, color: HexColor("#000000")),
                                      suffixIcon: Icon(
                                          Icons.keyboard_arrow_down,
                                          size: 16,
                                          color: HexColor("#BCBCBC")),
                                    ),
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: AppTheme.textColor),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          //endregion
                          Divider(
                              color: HexColor("#D8D8D8"),
                              thickness: 1.5,
                              height: 0),
                          Expanded(
                              child: SingleChildScrollView(
                                  child: Column(children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              child: Wrap(
                                direction: Axis.vertical,
                                alignment: WrapAlignment.spaceBetween,
                                crossAxisAlignment: WrapCrossAlignment.start,

                                spacing: 4,
                                children: [

                                  Row(

                                    children: [
                                      Column(
                                        children: [
                                          Text(
                                            model != null ? model.totalOrders : "",
                                            style: TextStyle(
                                                fontSize: 22,
                                                fontWeight: FontWeight.bold,
                                                color: HexColor("#F27321")),
                                          ),
                                          Text(
                                            "Total Orders",
                                            style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                                color: HexColor("#3C3C3C")),
                                          )
                                        ],
                                      ),


                                      SizedBox(width: 40,),

                                      Column(
                                        children: [
                                          Text(
                                            model != null
                                                // ? model.totalSettlement
                                                ? model.merchantEarning!=null && model.merchantEarning.toString().isNotEmpty?decimalFixed(2, model.merchantEarning.toString()??"00.00"):"00.00"
                                                : "",
                                            style: TextStyle(
                                                fontSize: 22,
                                                fontWeight: FontWeight.bold,
                                                color: HexColor("#F27321")),
                                          ),
                                          Text(
                                            "Settled Amount",
                                            style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                                color: HexColor("#3C3C3C")),
                                          )
                                        ],
                                      ),

                                    ],
                                  )


                                ],
                              ),
                            ),
                            Divider(
                                color: HexColor("#D8D8D8"),
                                thickness: 1.5,
                                height: 0),
                            Padding(padding: const EdgeInsets.only(top: 15)),
                            Text(
                              "Settlement Breakup",
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textColor),
                            ),
                            Padding(padding: const EdgeInsets.only(top: 15)),
                          //graph
                          /*  Container(
                                child: Center(
                                    child: SingleChildScrollView(
                                        physics: ScrollPhysics(),
                                        child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: <Widget>[
                                              Container(
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.40,
                                                child: seriesList != null
                                                    ? new charts.PieChart(
                                                        seriesList,
                                                        defaultRenderer: new charts
                                                                .ArcRendererConfig(
                                                            arcRendererDecorators: [
                                                              new charts
                                                                  .ArcLabelDecorator()
                                                            ]),
                                                        animate: true)
                                                    : Material(),
                                              )
                                            ])))),*/

                                    Table(
                                      defaultVerticalAlignment: TableCellVerticalAlignment.bottom,
                                        border:TableBorder.all(width: 0.5,color: Colors.grey),
                                      columnWidths: {
                                        0: FlexColumnWidth(4),
                                        1: FlexColumnWidth(3),

                                      },
                                      children: [
                                        TableRow(
                                            children: [
                                              Container(
                                                  height: 35,
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(8.0),
                                                    child: Text("Total Orders", style: TextStyle(
                                                        fontSize: 18
                                                    ),),
                                                  )),
                                              Container(
                                                  height: 35,
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(8.0),
                                                    child: Text(model.totalOrders??"", style: TextStyle(
                                                      fontSize: 18
                                                    ),),
                                                  )),

                                            ]
                                        ),
                                        TableRow(
                                            children: [
                                              Container(
                                                  height: 40,
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(8.0),
                                                    child: Text("Total Item Price (A)",style: TextStyle(
                                                        fontSize: 18
                                                    ),),
                                                  )),
                                              Container(
                                                  height: 40,
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(8.0),
                                                    child: Text(
                                                      model.totalItemsSaleAmount!=null && model.totalItemsSaleAmount.toString().isNotEmpty?decimalFixed(2, model.totalItemsSaleAmount??"0.00"):"0.00"
                                                          ,style: TextStyle(
                                                        fontSize: 18
                                                    ),),
                                                  )),

                                            ]
                                        ),
                                        TableRow(
                                            children: [
                                              Container(
                                                  height: 60,
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(8.0),
                                                    child: Text("Merchant Discount (B)",style: TextStyle(
                                                        fontSize: 18
                                                    ),),
                                                  )),
                                              Container(
                                                height: 60,
                                                child: Padding(
                                                  padding: const EdgeInsets.all(8.0),
                                                  child: Text(model.merchantOffer!=null && model.merchantOffer.toString().isNotEmpty?decimalFixed(2, model.merchantOffer??"0.00"):"0.00",style: TextStyle(
                                                      fontSize: 18
                                                  ),),
                                                ),
                                              ),

                                            ]
                                        ),
                                        TableRow(
                                            children: [
                                              Container(
                                                height: 60,
                                                child: Padding(
                                                  padding: const EdgeInsets.all(8.0),
                                                  child: Text("Adjustments Amount (C)",textScaleFactor: 1.0,style: TextStyle(
                                                      color: isFieldNegative(model.totalAdjustment!=null && model.totalAdjustment.toString().isNotEmpty?model.totalAdjustment.toString():"00.00")?Colors.red:Colors.green,
                                                      fontSize: 18
                                                  )),
                                                ),
                                              ),
                                              Container(
                                                height: 60,
                                                child: Padding(
                                                  padding: const EdgeInsets.all(8.0),
                                                  child: Text(model.totalAdjustment!=null && model.totalAdjustment.toString().isNotEmpty?decimalFixed(2, model.totalAdjustment.toString()??"00.00"):"00.00",textScaleFactor: 1.0,
                                                      style: TextStyle(
                                                          color: isFieldNegative(model.totalAdjustment!=null && model.totalAdjustment.toString().isNotEmpty?model.totalAdjustment.toString():"00.00")?Colors.red:Colors.green
                                                              ,fontSize: 18
                                                      )
                                                  ),
                                                ),
                                              ),

                                            ]
                                        ),

                                        TableRow(
                                            children: [
                                              Container(
                                                height: 80,
                                                child: Padding(
                                                  padding: const EdgeInsets.all(8.0),
                                                  child: Text("Item Price after Discounts (D = A-B (+/- C))",style: TextStyle(
                                                      fontSize: 18
                                                  ),),
                                                ),
                                              ),
                                              Container(
                                                height: 80,
                                                child: Padding(
                                                  padding: const EdgeInsets.all(8.0),
                                                  child: Text("${model.currencyCode} "
                                                      "${model.subTotal!=null && model.subTotal.toString().isNotEmpty?decimalFixed(2, model.subTotal.toString()??"00.00"):"00.00"}",
                                                       // "${ decimalFixed(2, ItemPriceAfterD(model.totalItemsSaleAmount, model.merchantOffer,
                                                      // model.totalAdjustment.toString() ))}",
                                                    style: TextStyle(
                                                      fontSize: 18
                                                  ),),
                                                ),
                                              ),

                                            ]
                                        ),

                                        TableRow(
                                            children: [
                                              Container(
                                                height: 35,
                                                child: Padding(
                                                  padding: const EdgeInsets.all(8.0),
                                                  child: Text("Merchant Tax (E)",style: TextStyle(
                                                      fontSize: 18
                                                  ),),
                                                ),
                                              ),
                                              Container(
                                                height: 35,
                                                child: Padding(
                                                  padding: const EdgeInsets.all(8.0),
                                                  child: Text(
                                                    // model.merchantTax??"",
                                                    "0.00",
                                                    style: TextStyle(
                                                      fontSize: 18
                                                  ),),
                                                ),
                                              ),

                                            ]
                                        ),

                                        TableRow(
                                            children: [
                                              Container(
                                                height: 60,
                                                child: Padding(
                                                  padding: const EdgeInsets.all(8.0),
                                                  child: Text("Packaging Charges (F)",style: TextStyle(
                                                      fontSize: 18
                                                  ),),
                                                ),
                                              ),
                                              Container(
                                                height: 40,
                                                child: Padding(
                                                  padding: const EdgeInsets.all(8.0),
                                                  child: Text(model.packagingCharges!=null && model.packagingCharges.toString().isNotEmpty?decimalFixed(2, model.packagingCharges??"0.00"):"0.00",style: TextStyle(
                                                      fontSize: 18
                                                  ),),
                                                ),
                                              ),

                                            ]
                                        ),



                                        TableRow(
                                            children: [
                                              Container(
                                                height: 60,
                                                child: Padding(
                                                  padding: const EdgeInsets.all(8.0),
                                                  child: Text("FLYER EATS Commission (G)",
                                                      style: TextStyle(
                                                          color: Colors.red,
                                                      fontSize: 18
                                                      )
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                height: 60,
                                                child: Padding(
                                                  padding: const EdgeInsets.all(8.0),
                                                  child: Text(model.feCommission!=null && model.feCommission.toString().isNotEmpty?decimalFixed(2, model.feCommission??"0.00"):"0.00",
                                                      style: TextStyle(
                                                          color: Colors.red,
                                                        fontSize: 18
                                                      )
                                                  ),
                                                ),
                                              ),

                                            ]
                                        ),

                                        TableRow(
                                            children: [
                                              Container(
                                                height: 60,
                                                child: Padding(
                                                  padding: const EdgeInsets.all(8.0),
                                                  child: Text("Tax on FLYER EATS Commission (H)",
                                                      style: TextStyle(
                                                          color: Colors.red,
                                                        fontSize: 18
                                                      )
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                height: 60,
                                                child: Padding(
                                                  padding: const EdgeInsets.all(8.0),
                                                  child: Text(model.taxOnComission!=null && model.taxOnComission.toString().isNotEmpty?decimalFixed(2, model.taxOnComission??"0.00"):"0.00",
                                                      style: TextStyle(
                                                          color: Colors.red,
                                                        fontSize: 18

                                                      )
                                                  ),
                                                ),
                                              ),

                                            ]
                                        ),

                                        TableRow(
                                            children: [
                                              Container(
                                                height: 60,
                                                child: Padding(
                                                  padding: const EdgeInsets.all(8.0),
                                                  child: Text("Merchant Earnings (D + E + F - G - H)",
                                                      style: TextStyle(
                                                          color: Colors.green,
                                                        fontSize: 18
                                                      )
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                height: 60,
                                                child: Padding(
                                                  padding: const EdgeInsets.all(8.0),
                                                  child: Text(/*"${model.currencyCode} "*/
                                                    // "${model.merchantEarning}"
                                                    "${model.merchantEarning!=null && model.merchantEarning.toString().isNotEmpty?decimalFixed(2, model.merchantEarning.toString()??"00.00"):"00.00"}",
                                                      // "${ decimalFixed(2,_getMerchantEarnings("0", model.packagingCharges,
                                                      // model.feCommission,model.taxOnComission ))}",
                                                    style: TextStyle(
                                                      fontSize: 18,color: Colors.green
                                                  ),),
                                                ),
                                              ),

                                            ]
                                        ),
                                      ],
                                    ),

                            Divider(
                                color: HexColor("#D8D8D8"),
                                thickness: 1.5,
                                height: 0),
                            Padding(padding: const EdgeInsets.only(top: 25)),
                            Text(
                              "* Settlement amount deposited in your given bank account",
                              style: TextStyle(
                                  fontSize: 14.0, fontWeight: FontWeight.bold),
                            ),
                            Padding(padding: const EdgeInsets.only(top: 25)),
                            GestureDetector(
                              onTap: () async {
                                var status = await Permission.storage.status;

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
                                    "Download Invoice",
                                    style: new TextStyle(
                                        color: HexColor("#F27321"),
                                        fontSize: 20,
                                        fontWeight: FontWeight.w700),
                                  ),
                                ],
                              ),
                            ),
                          ])))
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }))
        :Container(color: Colors.white,)
        ,
      ),
    );
  }

    ItemPriceAfterD(String a, String b, String c){
      double saleAmount=0;
      double merchantOffer=0;
      double adjustment=0;
      if(a!=null && a.isNotEmpty){
        saleAmount=double.parse(a.replaceAll("\u20b9", ""));
      }
      if(b!=null && b.isNotEmpty){
        merchantOffer=double.parse(b.replaceAll("\u20b9", ""));
      }
      if(c!=null && c.isNotEmpty) {
        adjustment = double.parse(c.replaceAll("\u20b9", ""));
      }
    D= "${saleAmount-merchantOffer+adjustment}";
    return D;
    }

  _getMerchantEarnings( String e, String f,String g,String h){

    return "${double.parse(D.replaceAll("\u20b9", ""))+double.parse(e.replaceAll("\u20b9", ""))
        +double.parse(f.replaceAll("\u20b9", ""))-double.parse(g.replaceAll("\u20b9", ""))
        -double.parse(h.replaceAll("\u20b9", ""))}";


  }

  String decimalFixed(int decimal,String value){
    double amount=double.parse(value);
    return amount.toStringAsFixed(decimal);
  }

  bool isFieldNegative(String value){
    if(value!=null && value.isNotEmpty){
      return double.parse(value).isNegative;
    } else{
      return false;
    }

  }
}
