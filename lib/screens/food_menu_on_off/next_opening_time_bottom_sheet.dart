import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:merchant_delivery/utils/app_theme.dart';
import 'package:merchant_delivery/utils/hex_color.dart';
import 'package:merchant_delivery/utils/util_functions.dart';
import 'package:merchant_delivery/widgets/custom_full_width_button.dart';

class BottomSheet extends StatefulWidget {
  final Function(SelectedNOT, bool checked) callback;

  BottomSheet({this.callback});

  @override
  _BottomSheetState createState() => _BottomSheetState();
}

class _BottomSheetState extends State<BottomSheet> {
  SelectedNOT _selectedNOT = new SelectedNOT(type: 1, radioGroupValue: "3");
  bool _isBtnActive = true;
  int _radioButtonId = 3; // default radio button
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  TextEditingController _dateCtrl = new TextEditingController();
  TextEditingController _timeCtrl = new TextEditingController();

  Future<Null> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2050),
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
    debugPrint("picked $picked $_selectedDate");
    if (picked != null && picked != _selectedDate)
      setState(() {
        _selectedDate = picked;
        String formattedDate = DateFormat('MMM dd,yyyy').format(picked);
        _dateCtrl.value = TextEditingValue(text: formattedDate);
        _radioButtonId = 0;
        if (_timeCtrl.text.trim() == "" || _timeCtrl.text == null) {
          _isBtnActive = false;
        } else {
          _isBtnActive = true;
        }

        _selectedNOT.type = 2;
        _selectedNOT.date = DateFormat('yyyy-MM-dd').format(picked);
        _selectedNOT.radioGroupValue = null;
      });
  }

  Future<Null> _selectTime(BuildContext context) async {
    final TimeOfDay picked = await showTimePicker(
      initialTime: TimeOfDay.now(),
      context: context,
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

    if (picked != null && picked != _selectedTime) {
      DateTime _checkPastDate = new DateTime(_selectedDate.year,
          _selectedDate.month, _selectedDate.day, picked.hour, picked.minute);

      if (_checkPastDate.isBefore(DateTime.now())) {
        showMyFlushbar(context, "You cannot select time in past");
        //_selectTime(context);
      } else {
        setState(() {
          _selectedTime = picked;
          String formattedTime = picked.toString().substring(10, 15);
          debugPrint("formatted Time: $formattedTime ");
          _timeCtrl.value = TextEditingValue(text: formattedTime);
          _radioButtonId = 0;
          if (_dateCtrl.text.trim() == "" || _dateCtrl.text == null) {
            _isBtnActive = false;
          } else {
            _isBtnActive = true;
          }

          _selectedNOT.type = 2;
          _selectedNOT.time = formattedTime;
          _selectedNOT.radioGroupValue = null;
        });
      }
    }
  }

  void _onButtonPressed() async {
    DateTime _checkPastDate = new DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute);
    if (_checkPastDate.isBefore(DateTime.now()) && _selectedNOT.type == 2) {
      showMyFlushbar(context, "You cannot select time in past");
    } else {
      if (_isBtnActive) {
        FocusScope.of(context).unfocus();
        widget.callback(_selectedNOT, true);
        Navigator.pop(context);
      }
    }
  }

  @override
  void dispose() {
    _dateCtrl.dispose();
    _timeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context)
              .viewInsets
              .bottom), // Moves to upper when keyboard opened
      child: Container(
        height: MediaQuery.of(context).size.height * 0.75,
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            SizedBox(height: 35),
            Center(
              child: Text(
                "Next Opening Time",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: HexColor("#3C3C3C")),
              ),
            ),
            SizedBox(height: 40),
//            Container(
//              height: 160,
//              child: RadioGroupTime(
//                callback: _onRadioButtonChanged,
//                fList: fList,
//              ),
//            ),
            Container(
              height: 160,
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
                                    _selectedDate = DateTime.now();
                                    _selectedTime = TimeOfDay.now();
                                    _dateCtrl.text = "";
                                    _timeCtrl.text = "";
                                    _selectedNOT.type = 1;
                                    _selectedNOT.radioGroupValue = data.apiVal;
                                    _selectedNOT.time = null;
                                    _selectedNOT.date = null;
                                  });
                                }))
                            .toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Center(child: Text("Or")),
            SizedBox(height: 20),
            GestureDetector(
              onTap: () => _selectDate(context),
              child: AbsorbPointer(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                  child: TextFormField(
                    textAlign: TextAlign.left,
                    controller: _dateCtrl,
                    keyboardType: TextInputType.datetime,
                    decoration: _inputDecoration(
                        "Please Select Date", Icons.calendar_today),
                    style: TextStyle(fontSize: 16, color: HexColor("#313233")),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            GestureDetector(
              onTap: () => _selectTime(context),
              child: AbsorbPointer(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                  child: TextFormField(
                    textAlign: TextAlign.left,
                    controller: _timeCtrl,
                    keyboardType: TextInputType.datetime,
                    decoration:
                        _inputDecoration("Please Select Time", Icons.timer),
                    style: TextStyle(fontSize: 16, color: HexColor("#313233")),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            CustomFullWidthButton(
              btnTitle: "DONE",
              callback: _onButtonPressed,
              isBtnActive: _isBtnActive,
            ),
            SizedBox(height: 20),
          ],
        ),
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
}

void nextOpeningTimeSheet(
    BuildContext context, Function(SelectedNOT, bool isChecked) callback) {
  showModalBottomSheet(
    shape: AppTheme.bottomSheetShape,
    backgroundColor: Colors.white,
    context: context,
    isScrollControlled: true,
    isDismissible: true,
    builder: (BuildContext bc) {
      return BottomSheet(
        callback: callback,
      );
    },
  );
}

class OpeningTimeList {
  String name;
  int index;
  String apiVal;

  OpeningTimeList({this.name, this.index, this.apiVal});
}

// region Radio button list
List<OpeningTimeList> fList = [
  OpeningTimeList(
    index: 1,
    name: "In Next 1 Hour",
    apiVal: "1",
  ),
  OpeningTimeList(
    index: 2,
    name: "In Next 1.5 Hours",
    apiVal: "2",
  ),
  OpeningTimeList(
    index: 3,
    name: "In Next 2 Hours",
    apiVal: "3",
  ),
];
// endregion

class SelectedNOT {
  //Selected Next Opening Time
  int type; // 1 => Selected from radio group, 2 => Selected from date time,
  String radioGroupValue;
  String date;
  String time;

  SelectedNOT({
    this.type,
    this.radioGroupValue,
    this.date,
    this.time,
  });
}
