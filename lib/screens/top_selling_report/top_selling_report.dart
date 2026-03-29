import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:merchant_delivery/models/sales_report_model.dart';
import 'package:merchant_delivery/providers/report_provider.dart';
import 'package:merchant_delivery/screens/top_selling_report/best_selling_category.dart';
import 'package:merchant_delivery/screens/top_selling_report/best_selling_item.dart';
import 'package:merchant_delivery/utils/app_theme.dart';
import 'package:merchant_delivery/utils/constants.dart';
import 'package:merchant_delivery/utils/hex_color.dart';
import 'package:merchant_delivery/utils/util_functions.dart';
import 'package:merchant_delivery/widgets/pick_date_bottom_sheet.dart';
import 'package:provider/provider.dart';

class TopSellingReportScreen extends StatefulWidget {
  @override
  _TopSellingReportScreenState createState() => _TopSellingReportScreenState();
}

class _TopSellingReportScreenState extends State<TopSellingReportScreen> with SingleTickerProviderStateMixin {
  TextEditingController _pickedDateCtrl = new TextEditingController(text: "OVERALL");
  double _selectedDateContainerWidth = 165;
  int _activeTabIndex = 0;
  TabController _tabController;
  Future<SalesReportModel> _future;

  _getSalesReport(String dateType, String startDate, String endDate) async {
    _future = Provider.of<ReportProvider>(context, listen: false).getSalesReport(context, dateType, startDate, endDate);
  }

  void _setActiveTabIndex() {
    if (_tabController.indexIsChanging) {
      setState(() {
        _activeTabIndex = _tabController.index;
      });
    }
  }

  _selectPeriod() async {
    pickDateBottomSheet(context, _callBack);
  }

  _callBack(String parameter, String formattedValue) {
    String dtType, stDt, endDt;
    debugPrint("value: $parameter, formattedValue: $formattedValue ");
    final dateType = parameter.substring(0, 6);
    if (dateType == Constants.optDate) {
      final optIndex = parameter.substring(6, 7);
      // region update Container width
      setState(() {
        if (optIndex == "1") {
          // Today
          _selectedDateContainerWidth = 145;
          dtType = "today";
        } else if (optIndex == "2") {
          // Last 7 days
          _selectedDateContainerWidth = 190;
          dtType = "weekly";
        } else if (optIndex == "3") {
          //Last 30 days
          _selectedDateContainerWidth = 210;
          dtType = "monthly";
        } else if (optIndex == "4") {
          // Overall
          _selectedDateContainerWidth = 165;
          dtType = null;
        }
      });
      //endregion

    } else if (dateType == Constants.fixDate) {
      stDt = parameter.substring(6, 17); //Or End Date
      dtType = "fixed";
      setState(() {
        _selectedDateContainerWidth = 190;
      });
    } else if (dateType == Constants.rangeDate) {
      dtType = "range";
      stDt = parameter.substring(6, 17);
      endDt = parameter.split("DDD")[1].substring(0, 10);
      setState(() {
        _selectedDateContainerWidth = 300;
      });
    }
    _pickedDateCtrl.text = formattedValue;
    _getSalesReport(dtType, stDt, endDt);
  }

  @override
  void initState() {
    _tabController = new TabController(length: 2, vsync: this);
    _tabController.addListener(_setActiveTabIndex);
    _getSalesReport(null, null, null);
    super.initState();
  }

//  final String selDate =

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.mainBlackColor,
      appBar: AppBar(
        backgroundColor: AppTheme.mainBlackColor,
        elevation: 0,
        title: Text("Top Selling Item/Category"),
        centerTitle: false,
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
          child: LayoutBuilder(builder: (context, constraints) {
            return ConstrainedBox(
              constraints: BoxConstraints(minWidth: constraints.maxWidth, minHeight: constraints.maxHeight),
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
                                    contentPadding: EdgeInsets.symmetric(vertical: 15),
                                    isDense: true,
                                    prefixIcon: Icon(Icons.calendar_today, size: 20, color: HexColor("#000000")),
                                    suffixIcon: Icon(Icons.keyboard_arrow_down, size: 16, color: HexColor("#BCBCBC")),
                                  ),
                                  style: TextStyle(fontSize: 16, color: AppTheme.textColor),
                                ),
                              ),
                            ),
                          ),
                        ),
                        //endregion
                        Divider(color: HexColor("#D8D8D8"), thickness: 1.5, height: 0),
                        //#region FutureBuilder
                        FutureBuilder(
                          future: _future, //Provider.of<ReportProvider>(context, listen: false).getSalesReport(context),
                          builder: (BuildContext context, AsyncSnapshot<SalesReportModel> snapshot) {
                            if (snapshot.hasError) {
                              return Container(
                                height: MediaQuery.of(context).size.height / 2,
                                child: Center(child: Text("Error Occurred!")),
                              );
                            } else if (snapshot.connectionState != ConnectionState.done) {
                              return Expanded(child: loadingWidget(context));
                            } else
                              return Expanded(
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(25.0),
                                      child: Wrap(
                                        alignment: WrapAlignment.center,
                                        crossAxisAlignment: WrapCrossAlignment.center,
                                        spacing: 8,
                                        children: [
                                          Column(
                                            children: [
                                              Text(
                                                snapshot.data.totalCount.toString(),
                                                style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: HexColor("#F27321")),
                                              ),
                                              Text(
                                                "Total Orders",
                                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: HexColor("#3C3C3C")),
                                              )
                                            ],
                                          ),
                                          Padding(padding: const EdgeInsets.symmetric(horizontal: 20)),
                                          Column(
                                            children: [
                                              Text(
                                                snapshot.data.totalQuantity.toString(),
                                                style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: HexColor("#F27321")),
                                              ),
                                              Text(
                                                "Total Quantity",
                                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: HexColor("#3C3C3C")),
                                              )
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    Divider(color: HexColor("#D8D8D8"), thickness: 1.5, height: 0),
                                    Padding(padding: const EdgeInsets.only(top: 15)),
                                    Expanded(
                                      child: new DefaultTabController(
                                        length: 2,
                                        child: new Scaffold(
                                          appBar: new PreferredSize(
                                            preferredSize: Size.fromHeight(24),
                                            child: Align(
                                              alignment: Alignment.center,
                                              child: new Container(
                                                color: AppTheme.mainWhiteColor,
                                                height: 30.0,
                                                child: Center(
                                                  child: new TabBar(
                                                    labelColor: Colors.white,
                                                    indicator: UnderlineTabIndicator(
                                                      borderSide: BorderSide(width: 3.0, color: HexColor("#FFC94B")),
                                                      insets: EdgeInsets.symmetric(horizontal: 16.0),
                                                    ),
                                                    controller: _tabController,
                                                    isScrollable: true,
                                                    tabs: [
                                                      Tab(
                                                        child: Text(
                                                          "Best Selling Category",
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                            color: _activeTabIndex == 0 ? AppTheme.textColor : AppTheme.textColor.withOpacity(0.5),
                                                          ),
                                                        ),
                                                      ),
                                                      Tab(
                                                        child: Text(
                                                          "Best Selling Item",
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                            color: _activeTabIndex == 1 ? AppTheme.textColor : AppTheme.textColor.withOpacity(0.5),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          body: Container(
                                            color: AppTheme.mainWhiteColor,
                                            child: TabBarView(
                                              controller: _tabController,
                                              children: [
                                                TopCategory(categoryList: snapshot.data.categoryList),
                                                TopSalesItems(salesItems: snapshot.data.items),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                          },
                        )

                        //endregion
                      ],
                    ),
                  ),
                ),
              ),
            );
          })),
    );
  }

  Padding _divider = new Padding(
    padding: const EdgeInsets.symmetric(horizontal: 0.0),
    child: Divider(color: HexColor("#D8D8D8"), thickness: 1.5, height: 0),
  );
}
