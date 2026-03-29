import 'package:flutter/material.dart';
import 'package:merchant_delivery/screens/food_menu_on_off/next_opening_time_bottom_sheet.dart';
import 'package:merchant_delivery/utils/hex_color.dart';
import 'package:merchant_delivery/widgets/pick_date_bottom_sheet.dart';

class RadioGroupTime extends StatefulWidget {
  final Function(OpeningTimeList) callback;
  final List fList;

  RadioGroupTime({
    @required this.callback,
    @required this.fList,
  });

  @override
  RadioGroupTimeWidget createState() => RadioGroupTimeWidget();
}

class RadioGroupTimeWidget extends State<RadioGroupTime> {
  int id = 0;

  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Flexible(
          child: Container(
            child: Column(
              children: widget.fList //fList
                  .map((data) => RadioListTile(
                        dense: true,
                        activeColor: HexColor("#2ECC71"),
                        title: Text("${data.name}", style: TextStyle(fontSize: 16)),
                        groupValue: id,
                        value: data.index,
                        onChanged: (val) {
                          widget.callback(data);
                          setState(() {
                            id = data.index;
                          });
                        },
                      ))
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }
}

class RadioGroupPickDate extends StatefulWidget {
  final Function(PickDate) callback;
  final List<PickDate> fList;
  final int initialButton;

  RadioGroupPickDate({
    @required this.callback,
    @required this.fList,
    @required this.initialButton,
  });

  @override
  RadioGroupPickDateWidget createState() => RadioGroupPickDateWidget();
}

class RadioGroupPickDateWidget extends State<RadioGroupPickDate> {
  int id;

  @override
  void initState() {
    debugPrint("Radio button init state");
    setState(() {
      id = widget.initialButton;
    });
    super.initState();
  }

  Widget build(BuildContext context) {
    return Container(
      height: 200,
      child: Column(
        children: <Widget>[
          Flexible(
            child: Container(
              child: Column(
                children: widget.fList //fList
                    .map((data) => RadioListTile(
                          dense: true,
                          activeColor: HexColor("#2ECC71"),
                          title: Text("${data.name}", style: TextStyle(fontSize: 16)),
                          groupValue: id,
                          value: data.index,
                          onChanged: (val) {
                            widget.callback(data);
                            setState(() {
                              id = data.index;
                            });
                          },
                        ))
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
