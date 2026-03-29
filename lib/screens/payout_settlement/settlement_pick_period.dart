import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:merchant_delivery/models/settlement_model.dart';
import 'package:merchant_delivery/providers/settlement_provider.dart';
import 'package:merchant_delivery/utils/app_theme.dart';
import 'package:merchant_delivery/utils/hex_color.dart';

Future<PickedPeriod> pickPeriodBottomSheet(
    BuildContext context, Function(String, String) callback,
    [String year, String month]) async {
  PickedPeriod period = await showModalBottomSheet(
    shape: AppTheme.bottomSheetShape,
    backgroundColor: Colors.white,
    context: context,
    isScrollControlled: true,
    isDismissible: true,
    builder: (BuildContext bc) {
      return PickPeriodBottomSheet(callback, year, month); // Send parameter
    },
  );

  return period;
}

class PickPeriodBottomSheet extends StatefulWidget {
  final Function(String, String) callback;
  String year, month;

  PickPeriodBottomSheet(this.callback, this.year, this.month);

  @override
  _PickPeriodBottomSheetState createState() => _PickPeriodBottomSheetState();
}

class _PickPeriodBottomSheetState extends State<PickPeriodBottomSheet>
    with SingleTickerProviderStateMixin {
  int selectedVal = 0;

  int _radioButtonId = 4;
  TextEditingController _timeCtrl = new TextEditingController();

  String year = DateTime.now().year.toString(),
      month = (DateTime.now().month - 1).toString();

  List<SettlementPeriodModel> model;

  @override
  void initState() {
    if (widget.year != null && widget.year != "") {
      year = widget.year;
    }

    if (widget.month != null && widget.month != "") {
      month = widget.month;
      print(month);
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context)
              .viewInsets
              .bottom), // Moves to upper when keyboard opened
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        height: selectedVal == 2 ? 570 : 240,
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            SizedBox(height: 35),
            Center(
              child: Text(
                "Pick The Settlement Period",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: HexColor("#3C3C3C")),
              ),
            ),
            SizedBox(height: 40),
            Container(
              height: 100,
              child: Column(
                children: <Widget>[
                  Flexible(
                    child: Container(
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
                                      selectedVal = val;

                                      if (selectedVal == 2) {
                                        _loadDate();
                                      } else {
                                        Navigator.of(context).pop();
                                      }
                                    });
                                  },
                                ))
                            .toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 0),
            selectedVal == 2
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Expanded(
                        flex: 1,
                        child: GestureDetector(
                          onTap: () => selectMonth(),
                          child: AbsorbPointer(
                              child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 22),
                            child: TextFormField(
                              textAlign: TextAlign.left,
                              controller: _timeCtrl,
                              keyboardType: TextInputType.datetime,
                              decoration:
                                  _inputDecoration(month, Icons.calendar_today),
                              style: TextStyle(
                                  fontSize: 16, color: HexColor("#313233")),
                            ),
                          )),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: GestureDetector(
                          onTap: () => selectYear(),
                          child: AbsorbPointer(
                              child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 22),
                            child: TextFormField(
                              textAlign: TextAlign.left,
                              controller: _timeCtrl,
                              keyboardType: TextInputType.datetime,
                              decoration:
                                  _inputDecoration(year, Icons.calendar_today),
                              style: TextStyle(
                                  fontSize: 16, color: HexColor("#313233")),
                            ),
                          )),
                        ),
                      ),
                    ],
                  )
                : Material(),
            selectedVal == 2
                ? Column(
                    children: [
                      SizedBox(height: 20),
                      Text("CHOOSE DATE PERIOD FROM BELOW",
                          style: TextStyle(
                              fontSize: 18, color: HexColor("#313233"))),
                      SizedBox(height: 20),
                      model != null
                          ? _listItem("All periods", "-1","","")
                          : Text("No data in selected month/year"),
                      model != null
                          ?
                      ListView.builder(
                          key: UniqueKey(),
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: model.length,
                          padding: const EdgeInsets.only(top: 0.0, bottom: 0),
                          itemBuilder: (context, index) {
                            return _listItem(model[index].period, model[index].id,model[index].startDate,model[index].endDate);
                          })


                      // Column(
                      //         children: model.map((e) {
                      //           print("mapping");
                      //           return _listItem(e.period, e.id,e.startDate,e.endDate);
                      //         }).toList(),
                      //       )
                          : Material()
                    ],
                  )
                : Material()
          ],
        ),
      ),
    );
  }

  Widget _listItem(String name, String index,String start,String end) {

    PickedPeriod period = new PickedPeriod();
    period.period = name;
    period.id = index;
    period.month = month;
    period.year = year;
    period.startDate = start;
    period.endDate = end;

    return Column(children: [
      GestureDetector(
        onTap: () => _selectPeriod(period),
        child: AbsorbPointer(
            child: Container(
          height: 50,
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: TextFormField(
            initialValue: name,
            textAlign: TextAlign.left,
            keyboardType: TextInputType.datetime,
            decoration: _itemDecoration(),
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.blue/*HexColor("#313233")*/),
          ),
        )),
      ),
      SizedBox(height: 7),
    ]);
  }

  InputDecoration _itemDecoration() {
    return InputDecoration(
      labelStyle: TextStyle(color: AppTheme.textColor),
      hintStyle: TextStyle(color: AppTheme.textColor.withOpacity(0.50)),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.black26, width: 2.0),
        gapPadding: 10,
        borderRadius: BorderRadius.circular(AppTheme.formCornerRadius),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.black, width: 1.0),
        borderRadius: BorderRadius.circular(AppTheme.formCornerRadius),
      ),
    );
  }

  InputDecoration _inputDecoration(String hintText, IconData iconData) {
    return InputDecoration(
      hintText: hintText,
      labelStyle: TextStyle(color: AppTheme.textColor),
      hintStyle: TextStyle(color: AppTheme.textColor.withOpacity(0.50)),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.black26, width: 2.0),
        gapPadding: 10,
        borderRadius: BorderRadius.circular(AppTheme.formCornerRadius),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.black, width: 1.0),
        borderRadius: BorderRadius.circular(AppTheme.formCornerRadius),
      ),
      prefixIcon: Icon(iconData, size: 20, color: HexColor("#000000")),
    );
  }

  void _loadDate() {
    SettlementProvider provider = new SettlementProvider();
    provider.getSettlementPeriods(context, true, month, year).then((value) {
      if(model!=null)
      model.clear();
      model = value;
      setState(() {

      });
    });
  }

  selectMonth() async {
    await showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
              height: MediaQuery.of(context).size.height * 0.30,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Padding(
                      padding: EdgeInsets.all(10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).pop();
                            },
                            child: Text(
                              "DONE",
                              style: TextStyle(
                                fontSize: 18,
                                color: AppTheme.btnColor,
                              ),
                            ),
                          ),
                        ],
                      )),
                  Container(
                      height: MediaQuery.of(context).size.height * 0.23,
                      child: CupertinoPicker(
                        scrollController: FixedExtentScrollController(
                            initialItem: int.parse(month) - 1),
                        backgroundColor: Colors.white,
                        onSelectedItemChanged: (value) {
                          setState(() {
                            month = (value + 1).toString();
                          });
                        },
                        itemExtent: 32.0,
                        children: const [
                          Text('1'),
                          Text('2'),
                          Text('3'),
                          Text('4'),
                          Text('5'),
                          Text('6'),
                          Text('7'),
                          Text('8'),
                          Text('9'),
                          Text('10'),
                          Text('11'),
                          Text('12'),
                        ],
                      ))
                ],
              ));
        });

    _loadDate();
  }

  selectYear() async {
    List<String> years = new List();

    for (int i = 2019; i <= 2066; i++) {
      years.add(i.toString());
    }

    await showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
              height: MediaQuery.of(context).size.height * 0.30,
              child: Column(mainAxisSize: MainAxisSize.max, children: [
                Padding(
                    padding: EdgeInsets.all(10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                          child: Text(
                            "DONE",
                            style: TextStyle(
                              fontSize: 18,
                              color: AppTheme.btnColor,
                            ),
                          ),
                        ),
                      ],
                    )),
                Container(
                    height: MediaQuery.of(context).size.height * 0.23,
                    child: CupertinoPicker(
                        scrollController: FixedExtentScrollController(
                            initialItem: int.parse(year) - 2019),
                        backgroundColor: Colors.white,
                        onSelectedItemChanged: (value) {
                          setState(() {
                            year = (2019 + value).toString();
                          });
                        },
                        itemExtent: 32.0,
                        children: years.map<Widget>((y) {
                          return Text(y);
                        }).toList()))
              ]));
        });

    _loadDate();
  }

  _selectPeriod(PickedPeriod period) {
    if (period.id == "-1") {
      String tempPeriod = "";
      int index = 0;
      for (SettlementPeriodModel m in model) {
        tempPeriod += (index != 0 ? "," : "") + m.id;
        index++;
      }
      period.id = tempPeriod;
    }
    Navigator.of(context).pop(period);
  }
}

class PickedPeriod {
  String year;
  String month;
  String period;
  String id;
  String startDate;
  String endDate;
}

class PickDate {
  String name;
  int index;

  PickDate({this.name, this.index});
}

// region Radio button list
List<PickDate> fList = [
  PickDate(
    index: 1,
    name: "OVERALL SETTLEMENT PERIOD",
  ),
  PickDate(
    index: 2,
    name: "CHOOSE MONTH AND YEAR",
  ),
];
// endregion
