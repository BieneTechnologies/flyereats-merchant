import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:intl/intl.dart';
import 'package:merchant_delivery/providers/order_provider.dart';
import 'package:merchant_delivery/screens/home_screen/order_card_widget.dart';
import 'package:merchant_delivery/utils/app_theme.dart';
import 'package:merchant_delivery/utils/constants.dart';
import 'package:merchant_delivery/utils/hex_color.dart';
import 'package:merchant_delivery/utils/util_functions.dart';
import 'package:provider/provider.dart';

class AllOrders extends StatefulWidget {

  @override
  _AllOrdersState createState() => _AllOrdersState();
}

class _AllOrdersState extends State<AllOrders> {
  ScrollController controller;
  Future<void> _future;
  DateTime selectedDate = DateTime.now();
  TextEditingController _date;
  int _currPage = 0;
  bool _isLoadingAllData = false;

  _setInitDateTime() {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('MMM yyyy').format(now);
    _date = TextEditingController(text: formattedDate);
  }

  void _scrollListener() async {
    final orderPvd = Provider.of<OrderProvider>(context, listen: false);
    String date;
    if (_isLoadingAllData) {
      date = null;
    } else
      date = selectedDate.toString().split(' ')[0];
    //print("scroll");
    if (controller.position.pixels == controller.position.maxScrollExtent) {
      print("end" +
          orderPvd.allOrders.length.toString() +
          " - " +
          orderPvd.totalItems.toString());
      if (orderPvd.allOrders.length < orderPvd.totalItems) {
        _currPage += 1;
        showLoadingDialog(context, "Loading more data");
        await Provider.of<OrderProvider>(context, listen: false).getAllOrders(
            context,
            selectedDate.month.toString(),
            selectedDate.year.toString(),
            _currPage,
            resetAllOrders: false);
        Navigator.of(context).pop();
      }
    }
  }

  Future<Null> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2015, 1),
      lastDate: DateTime.now(),
      builder: (BuildContext context, Widget child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: HexColor("#FFB531"),
            accentColor: HexColor("#FFB531"),
            colorScheme: ColorScheme.light(primary: HexColor("#FFB531")),
            buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child,
        );
      },
    );
    if (picked != null && picked != selectedDate)
      setState(() {
        _isLoadingAllData = false;
        selectedDate = picked;
        String date = selectedDate.toString().split(' ')[0];
        _future = Provider.of<OrderProvider>(context, listen: false)
            .getAllOrders(context, selectedDate.month.toString(),
                selectedDate.year.toString(), 0);
        String formattedDate = DateFormat('MMM dd,yyyy').format(picked);
        _date.value = TextEditingValue(text: formattedDate);
      });
  }

  _getAllOrders() async {
    _future = Provider.of<OrderProvider>(context, listen: false).getAllOrders(
        context,
        selectedDate.month.toString(),
        selectedDate.year.toString(),
        0);
  }

  selectDate(BuildContext context) async {
    List<String> years = new List();

    for (int i = 2019; i <= 2066; i++) {
      years.add(i.toString());
    }

    String month = selectedDate.month.toString(),
        year = selectedDate.year.toString();

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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Please select month and year",
                            style: TextStyle(
                              fontSize: 14,
                            ),
                          ),
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
                      child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Expanded(
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
                            )),
                            Expanded(
                                child: CupertinoPicker(
                                    scrollController:
                                        FixedExtentScrollController(
                                            initialItem:
                                                int.parse(year) - 2019),
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
                          ]))
                ],
              ));
        });
    String newDate = year + "-" + month.padLeft(2, "0") + "-01";

    selectedDate = DateTime.parse(newDate);
    String formattedDate = DateFormat('MMM yyyy').format(selectedDate);
    setState(() {
      _date = TextEditingController(text: formattedDate);
    });

    _getAllOrders();
  }

  @override
  void initState() {
    _setInitDateTime();

    _getAllOrders();
    controller = new ScrollController()..addListener(_scrollListener);

    setState(() {});

    super.initState();
  }

  @override
  void dispose() {
    _date.dispose();
    controller.removeListener(_scrollListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    /*WidgetsBinding.instance.addPostFrameCallback((_) {
      Constants.isOrderStatusChanged = false;
    });*/
    return Column(
      children: <Widget>[
        GestureDetector(
          onTap: () => selectDate(context),
          child: AbsorbPointer(
            child: Container(
              width: 185,
              child: TextFormField(
                textAlign: TextAlign.center,
                controller: _date,
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
                style: TextStyle(fontSize: 16, color: AppTheme.textColor),
              ),
            ),
          ),
        ),
        FutureBuilder(
          future: _future,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasError) {
              return Container(
                height: MediaQuery.of(context).size.height / 2,
                child: Center(child: Text("Error Occurred!")),
              );
            } else if (snapshot.connectionState != ConnectionState.done) {
              return Expanded(child: loadingWidget(context));
            } else
              return Consumer<OrderProvider>(
                builder: (context, orderProvider, _) {
                  return Expanded(
                    child: orderProvider.allOrders.length != 0
                        ? new ListView.builder(
                            controller: controller,
                            itemCount: orderProvider.allOrders.length,
                            itemBuilder: (BuildContext ctxt, int index) {
                              return AnimationConfiguration.staggeredList(
                                position: index,
                                duration: const Duration(milliseconds: 120),
                                child: SlideAnimation(
                                  verticalOffset: 50.0,
                                  child: FadeInAnimation(
                                    child: OrderCardWidget(
                                        model: orderProvider.allOrders[index]),
                                  ),
                                ),
                              );
                            },
                          )
                        : new Container(
                            child: Center(
                              child: Text(
                                "No Order Yet",
                                style: new TextStyle(
                                    fontSize: 18,
                                    color: AppTheme.textColor,
                                    fontWeight: FontWeight.w700),
                              ),
                            ),
                          ),
                  );
                },
              );
          },
        ),
      ],
    );
  }


}
