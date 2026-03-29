import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:merchant_delivery/utils/app_theme.dart';
import 'package:merchant_delivery/utils/constants.dart';
import 'package:merchant_delivery/utils/hex_color.dart';
import 'package:merchant_delivery/utils/util_functions.dart';
import 'package:merchant_delivery/widgets/custom_full_width_button.dart';

void pickDateBottomSheet(BuildContext context, Function(String, String) callback) {
  showModalBottomSheet(
    shape: AppTheme.bottomSheetShape,
    backgroundColor: Colors.white,
    context: context,
    isScrollControlled: true,
    isDismissible: true,
    builder: (BuildContext bc) {
      return PickDateBottomSheet(callback); // Send parameter
    },
  );
}

class PickDateBottomSheet extends StatefulWidget {
  final Function(String, String) callback;

  PickDateBottomSheet(this.callback);

  @override
  _PickDateBottomSheetState createState() => _PickDateBottomSheetState();
}

class _PickDateBottomSheetState extends State<PickDateBottomSheet> with SingleTickerProviderStateMixin {
  SelectedPickDate _selectedPickDate = new SelectedPickDate(parameter: Constants.optDate + fList[3].index.toString(), name: fList[3].name);
  int _activeTabIndex = 0;
  TabController _tabController;
  double _dateSelectContainerHeight = 100;
  double _pageHeight = 540;

  int _radioButtonId = 4; // default radio button
  TextEditingController _fixedDateCtrl = new TextEditingController();
  TextEditingController _fromDateCtrl = new TextEditingController();
  TextEditingController _toDateCtrl = new TextEditingController();

  DateTime _selectedFixedDate;

  DateTime _selectedFromDate;

  DateTime _selectedEndDate;

  String _formattedDateRange = "";

  void _setActiveTabIndex() {
    if (_tabController.indexIsChanging) {
      setState(() {
        _activeTabIndex = _tabController.index;
        if (_tabController.index == 0) {
          _dateSelectContainerHeight = 100;
          _pageHeight = 540;
        } else {
          _dateSelectContainerHeight = 180;
          _pageHeight = 600;
        }
      });
    }
  }

  _onRadioButtonChanged(PickDate pickDate) {
//    widget.callback(Constants.optDate + pickDate.index.toString() + pickDate.name, pickDate.name);
    setState(() {
      _selectedPickDate = new SelectedPickDate(parameter: pickDate.index.toString(), name: pickDate.name);
    });
  }

  _onDoneButtonClicked() {
    final dateType = _selectedPickDate.parameter.substring(0, 6);
    if (dateType == Constants.rangeDate) {
      if (_selectedEndDate == null) {
        showMyFlushbar(context, "Please Select To Date");
      } else {
        widget.callback(_selectedPickDate.parameter, _selectedPickDate.name);
        Navigator.pop(context);
      }
    } else {
      widget.callback(_selectedPickDate.parameter, _selectedPickDate.name);
      Navigator.pop(context);
    }
  }

  Future<Null> _selectFixedDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2015),
      lastDate: DateTime.now(),
      builder: (BuildContext context, Widget child) => AppTheme.calendarTheme(context, child),
    );
    if (picked != null && picked != _selectedFixedDate) {
      setState(() {
        _selectedFixedDate = picked;
        String formattedDate = DateFormat('MMM dd,yyyy').format(picked);
        _fixedDateCtrl.value = TextEditingValue(text: formattedDate);
        _selectedPickDate = new SelectedPickDate(parameter: Constants.fixDate + picked.toString(), name: formattedDate);
        // reset other form fields
        _radioButtonId = 0;
        _selectedFromDate = null;
        _selectedEndDate = null;
        _fromDateCtrl.text = "";
        _toDateCtrl.text = "";
      });
    }
  }

  Future<Null> _selectFromDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2015),
      lastDate: DateTime.now(),
      builder: (BuildContext context, Widget child) => AppTheme.calendarTheme(context, child),
    );
    if (picked != null && picked != _selectedFromDate) {
      String formattedDate;
      setState(() {
        _selectedFromDate = picked;
        formattedDate = DateFormat('MMM dd,yyyy').format(picked);
        _fromDateCtrl.value = TextEditingValue(text: formattedDate);
        _formattedDateRange = _fromDateCtrl.text + " - " + _toDateCtrl.text;
        _selectedPickDate = new SelectedPickDate(parameter: Constants.rangeDate + picked.toString() + "DDD" + _selectedEndDate.toString(), name: _formattedDateRange);
        // reset other form fields
        _radioButtonId = 0;
        _selectedFixedDate = null;
        _selectedEndDate = null;
        _fixedDateCtrl.text = "";
        _toDateCtrl.text = "";
      });
    }
  }

  Future<Null> _selectToDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: _selectedFromDate,
      //DateTime(2015),
      lastDate: DateTime.now(),
      builder: (BuildContext context, Widget child) => AppTheme.calendarTheme(context, child),
    );
    if (picked != null && picked != _selectedEndDate) {
      String formattedDate;
      setState(() {
        _selectedEndDate = picked;
        formattedDate = DateFormat('MMM dd,yyyy').format(picked);
        _toDateCtrl.value = TextEditingValue(text: formattedDate);
        _formattedDateRange = _fromDateCtrl.text + " - " + _toDateCtrl.text;
        _selectedPickDate = new SelectedPickDate(parameter: Constants.rangeDate + _selectedFromDate.toString() + "DDD" + picked.toString(), name: _formattedDateRange);
        // reset other form fields
        _radioButtonId = 0;
        _selectedFixedDate = null;
        _fixedDateCtrl.text = "";
      });
    }
  }

  @override
  void initState() {
    _tabController = new TabController(length: 2, vsync: this);
    _tabController.addListener(_setActiveTabIndex);
    super.initState();
  }

  @override
  void dispose() {
    _fixedDateCtrl.dispose();
    _fromDateCtrl.dispose();
    _toDateCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom), // Moves to upper when keyboard opened
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        height: _pageHeight,
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            SizedBox(height: 35),
            Center(
              child: Text(
                "Pick Date",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: HexColor("#3C3C3C")),
              ),
            ),
            SizedBox(height: 40),
            Container(
              height: 200,
              child: Column(
                children: <Widget>[
                  Flexible(
                    child: Container(
                      child: Column(
                        children: fList //fList
                            .map((data) => RadioListTile(
                                  dense: true,
                                  activeColor: HexColor("#2ECC71"),
                                  title: Text("${data.name}", style: TextStyle(fontSize: 16)),
                                  groupValue: _radioButtonId,
                                  value: data.index,
                                  onChanged: (val) {
                                    setState(() {
                                      _radioButtonId = data.index;
                                      _selectedPickDate = new SelectedPickDate(parameter: Constants.optDate + data.index.toString(), name: data.name);
                                      _selectedFixedDate = null;
                                      _selectedFromDate = null;
                                      _selectedEndDate = null;
                                      _fixedDateCtrl.text = "";
                                      _fromDateCtrl.text = "";
                                      _toDateCtrl.text = "";
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
//            RadioGroupPickDate(
//              callback: _onRadioButtonChanged,
//              fList: fList,
//              initialButton: _initialRadioButtonIndex,
//            ),
            Center(child: Text("Or")),
            SizedBox(height: 20),
            AnimatedContainer(
              duration: Duration(milliseconds: 350),
              curve: Curves.easeIn,
              height: _dateSelectContainerHeight,
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
                            indicator: UnderlineTabIndicator(
                              borderSide: BorderSide(width: 3.0, color: HexColor("#FFC94B")),
                              insets: EdgeInsets.symmetric(horizontal: 16.0),
                            ),
                            controller: _tabController,
                            isScrollable: true,
                            tabs: [
                              Tab(
                                child: Text(
                                  "Fixed Date",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: _activeTabIndex == 0 ? AppTheme.textColor : AppTheme.textColor.withOpacity(0.5),
                                  ),
                                ),
                              ),
                              Tab(
                                child: Text(
                                  "Date Range",
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
                        Column(
                          children: <Widget>[
                            Padding(padding: const EdgeInsets.only(top: 12)),
                            GestureDetector(
                              onTap: () => _selectFixedDate(context),
                              child: AbsorbPointer(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 22),
                                  child: TextFormField(
                                    textAlign: TextAlign.left,
                                    controller: _fixedDateCtrl,
                                    keyboardType: TextInputType.datetime,
                                    decoration: _inputDecoration("Please Select Date", "Select Date", Icons.calendar_today),
                                    style: TextStyle(fontSize: 16, color: HexColor("#313233")),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        ListView(
                          children: <Widget>[
                            Padding(padding: const EdgeInsets.only(top: 12)),
                            GestureDetector(
                              onTap: () => _selectFromDate(context),
                              child: AbsorbPointer(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 22),
                                  child: TextFormField(
                                    textAlign: TextAlign.left,
                                    controller: _fromDateCtrl,
                                    keyboardType: TextInputType.datetime,
                                    decoration: _inputDecoration("Please Select From Date", "From Date", Icons.calendar_today),
                                    style: TextStyle(fontSize: 16, color: HexColor("#313233")),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 8),
                            GestureDetector(
                              onTap: () {
                                if (_selectedFromDate == null) {
                                  showMyFlushbar(context, "Please Select From Date Firstly");
                                } else {
                                  _selectToDate(context);
                                }
                              },
                              child: AbsorbPointer(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 22),
                                  child: TextFormField(
                                    textAlign: TextAlign.left,
                                    controller: _toDateCtrl,
                                    keyboardType: TextInputType.datetime,
                                    decoration: _inputDecoration("Please Select To Date", "To Date", Icons.calendar_today),
                                    style: TextStyle(fontSize: 16, color: HexColor("#313233")),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            CustomFullWidthButton(
              callback: _onDoneButtonClicked,
              btnTitle: "DONE",
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hintText, String labelText, IconData iconData) {
    return InputDecoration(
      hintText: hintText,
      labelText: labelText,
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
    name: "TODAY",
  ),
  PickDate(
    index: 2,
    name: "LAST 7 DAYS",
  ),
  PickDate(
    index: 3,
    name: "LAST 30 DAYS",
  ),
  PickDate(
    index: 4,
    name: "OVERALL",
  ),
];
// endregion

class SelectedPickDate {
  String parameter;
  String name;

  SelectedPickDate({this.parameter, this.name});
}
