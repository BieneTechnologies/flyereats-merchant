import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:merchant_delivery/models/sales_report_model.dart';
import 'package:merchant_delivery/utils/hex_color.dart';

class TopSalesItems extends StatefulWidget {
  final List<SalesItems> salesItems;

  TopSalesItems({this.salesItems});

  @override
  _TopSalesItemsState createState() => _TopSalesItemsState();
}

class _TopSalesItemsState extends State<TopSalesItems> {
  List<charts.Series<SalesItems, String>> _seriesPieData;

  _generateData() {
    _seriesPieData.add(
      charts.Series(
        id: 'SalesItems',
        domainFn: (SalesItems task, _) => task.itemName,
        measureFn: (SalesItems task, _) => int.tryParse(task.totalQty),
        colorFn: (SalesItems task, _) => charts.ColorUtil.fromDartColor(task.color),
        data: widget.salesItems,
        labelAccessorFn: (SalesItems row, _) => '${row.totalQty}',
      ),
    );
  }

  @override
  void initState() {
    _seriesPieData = List<charts.Series<SalesItems, String>>();
    _generateData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: SingleChildScrollView(
          physics: ScrollPhysics(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Container(
                height: MediaQuery.of(context).size.height * 0.30,
                child: widget.salesItems.length != 0
                    ? charts.PieChart(
                        _seriesPieData,
                        animate: true,
                        animationDuration: Duration(seconds: 3),
                        /*defaultRenderer: charts.ArcRendererConfig(
                          arcRendererDecorators: [
                            new charts.ArcLabelDecorator(
                              showLeaderLines: true,
                              labelPadding: 6,
                              labelPosition: charts.ArcLabelPosition.auto,
                              insideLabelStyleSpec: new charts.TextStyleSpec(fontSize: 16, color: charts.Color.fromHex(code: "#FFFFFF")),
                            )
                          ],
                        ),*/
                      )
                    : Center(
                        child: Text(
                        "Data Not Exists",
                        style: TextStyle(color: HexColor("#3C3C3C"), fontSize: 18, fontWeight: FontWeight.bold),
                      )),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: widget.salesItems.length,
                itemBuilder: (context, i) {
                  return Padding(
                    padding: const EdgeInsets.only(left: 40, right: 35, bottom: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            widget.salesItems[i].itemName,
                            style: TextStyle(color: widget.salesItems[i].color, fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
//                        Spacer(),
                        Text(
                          widget.salesItems[i].totalQty,
                          style: TextStyle(color: HexColor("#3C3C3C"), fontSize: 18, fontWeight: FontWeight.bold),
                        )
                      ],
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
}
