import 'package:flutter/material.dart';
import 'package:merchant_delivery/models/items_category_model.dart';
import 'package:merchant_delivery/providers/category_item_provider.dart';
import 'package:merchant_delivery/utils/app_theme.dart';
import 'package:merchant_delivery/utils/hex_color.dart';
import 'package:merchant_delivery/utils/util_functions.dart';
import 'package:merchant_delivery/widgets/custom_full_width_button.dart';
import 'package:provider/provider.dart';

// 1. Open Only name update if price is null
// 2. Open Name + SizeName and price update

//item.price.length

void updateItemBottomSheet(BuildContext context, Items item) {
  showModalBottomSheet(
    shape: AppTheme.bottomSheetShape,
    backgroundColor: Colors.white,
    context: context,
    isScrollControlled: true,
    isDismissible: true,
    builder: (BuildContext bc) {
      return UpdateItemBottomSheet(model: item);
    },
  );
}

class UpdateItemBottomSheet extends StatefulWidget {
  final Items model;

  UpdateItemBottomSheet({@required this.model});

  @override
  _UpdateItemBottomSheetState createState() => _UpdateItemBottomSheetState();
}

class _UpdateItemBottomSheetState extends State<UpdateItemBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _currentNameCtrl;

  // This list of controllers can be used to set and get the text from/to the TextFields
  Map<Price, TextEditingController> _priceTxtControllers = {};

  var _sizePrices = <Widget>[];

  bool _isBtnActive = false;

  _initSizePrices() {
    widget.model.price.forEach((size) {
      var textEditingController = new TextEditingController(text: size.price);
      _priceTxtControllers.putIfAbsent(size, () => textEditingController);
      return _sizePrices.add(
        Container(
          padding: const EdgeInsets.only(left: 20, right: 20),
          margin: const EdgeInsets.only(bottom: 20),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  size.sizeId != "0" ? size.sizeName : "Amount",
                  style:
                      new TextStyle(fontSize: 18, color: HexColor("#3C3C3C")),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 15, right: 15),
                child: Text(size.currencyCode),
              ),
              Container(
                width: 120,
                child: TextFormField(
                  controller: textEditingController,
                  style: TextStyle(color: AppTheme.textColor),
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  decoration: _inputDecoration(),
                  onChanged: (value) {
                    if (value.trim() == "" || value == null) {
                      setState(() {
                        _isBtnActive = false;
                      });
                    }
                    if (value.trim() != size.price &&
                        value.trim() != "" &&
                        value != null) {
                      setState(() {
                        _isBtnActive = true;
                      });
                    } else {
                      setState(() {
                        _isBtnActive = false;
                      });
                    }
                  },
                  validator: (value) {
                    if (value.trim() == "" || value == null) {
                      setState(() {
                        _isBtnActive = false;
                      });
                      return "Please enter Item Size Price";
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  _onButtonClicked() async {
    if (_isBtnActive) {
      FocusScope.of(context).unfocus();
      Map<String, String> price = {};
      _priceTxtControllers.forEach((key, value) {
        price[key.sizeId.toString()] = value.text;
      });

      final bool updateResult =
          await Provider.of<CategoryItemProvider>(context, listen: false)
              .updateItemNameWithSizePrice(
                  context, widget.model.itemId, _currentNameCtrl.text, price);
      if (updateResult) {
        Navigator.popUntil(context, ModalRoute.withName('/editMenu'));
        showMyFlushbar(context, "Successful");
      }
    }
  }

  double _calculateContainerHeight() {
    switch (_sizePrices.length) {
      case 0:
        return 220;
      case 1:
        return MediaQuery.of(context).size.height * 0.45;
      case 2:
        return MediaQuery.of(context).size.height * 0.50;
      case 3:
        return MediaQuery.of(context).size.height * 0.55;
      default:
        return MediaQuery.of(context).size.height * 0.85;
    }
  }

  @override
  void initState() {
    _currentNameCtrl = new TextEditingController(text: widget.model.itemName);
    if (widget.model.price.length != 0) {
      _initSizePrices();
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
      child: Container(
          height: _calculateContainerHeight(),
          padding: const EdgeInsets.only(top: 20, left: 16, right: 16),
          child: SingleChildScrollView(
            child: SafeArea(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Text("Edit",
                        style: new TextStyle(
                            color: HexColor("#3C3C3C"),
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                    SizedBox(height: 27),
                    // region Edit Item Name Field
                    Container(
                      padding: const EdgeInsets.only(left: 20, right: 20),
                      child: TextFormField(
                        controller: _currentNameCtrl,
                        style: TextStyle(color: AppTheme.textColor),
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.done,
                        decoration: _inputDecoration(),
                        onChanged: (value) {
                          if (value.trim() == "" || value == null) {
                            setState(() {
                              _isBtnActive = false;
                            });
                          }
                          if (value.trim() != widget.model.itemName &&
                              value.trim() != "" &&
                              value != null) {
                            setState(() {
                              _isBtnActive = true;
                            });
                          } else {
                            setState(() {
                              _isBtnActive = false;
                            });
                          }
                        },
                        validator: (value) {
                          if (value.trim() == "" || value == null) {
                            setState(() {
                              _isBtnActive = false;
                            });
                            return "Please enter Item name";
                          }
                          return null;
                        },
                      ),
                    ),
                    // endregion
                    SizedBox(height: 24),
                    Column(children: _sizePrices),
                    // region update button
                    Padding(
                      padding: const EdgeInsets.only(bottom: 0.0),
                      child: CustomFullWidthButton(
                        btnTitle: "UPDATE",
                        callback: _onButtonClicked,
                        isBtnActive: _isBtnActive,
                      ),
                    ),
                    SizedBox(height: 24),
                    // endregion
                  ],
                ),
              ),
            ),
          )),
    );
  }

  InputDecoration _inputDecoration() {
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
      focusedErrorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.red, width: 1.0),
        borderRadius: BorderRadius.circular(AppTheme.formCornerRadius),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.red, width: 1.0),
        borderRadius: BorderRadius.circular(AppTheme.formCornerRadius),
      ),
    );
  }
}

/*textFormFields.add(
        TextFormField(
          controller: textEditingController,
          style: TextStyle(color: AppTheme.textColor),
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.done,
          decoration: _inputDecoration(),
          onChanged: (value) {
            if (value.trim() == "" || value == null) {
              setState(() {
                _isBtnActive = false;
              });
            }
            if (value.trim() != size.price && value.trim() != "" && value != null) {
              setState(() {
                _isBtnActive = true;
              });
            } else {
              setState(() {
                _isBtnActive = false;
              });
            }
          },
          validator: (value) {
            if (value.trim() == "" || value == null) {
              setState(() {
                _isBtnActive = false;
              });
              return "Please enter Item Size Price";
            }
            return null;
          },
        ),
      );*/
