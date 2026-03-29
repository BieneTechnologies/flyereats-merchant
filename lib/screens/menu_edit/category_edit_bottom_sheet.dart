import 'package:flutter/material.dart';
import 'package:merchant_delivery/models/items_category_model.dart';
import 'package:merchant_delivery/providers/category_item_provider.dart';
import 'package:merchant_delivery/utils/app_theme.dart';
import 'package:merchant_delivery/utils/hex_color.dart';
import 'package:merchant_delivery/utils/util_functions.dart';
import 'package:merchant_delivery/widgets/custom_full_width_button.dart';
import 'package:provider/provider.dart';

void updateCategoryBottomSheet(BuildContext context, ItemsWithCategoryModel model) {
  showModalBottomSheet(
    shape: AppTheme.bottomSheetShape,
    backgroundColor: Colors.white,
    context: context,
    isScrollControlled: true,
    isDismissible: true,
    builder: (BuildContext bc) {
      return UpdateCategoryBottomSheet(model: model); // Send parameter
    },
  );
}

class UpdateCategoryBottomSheet extends StatefulWidget {
  final ItemsWithCategoryModel model;

  UpdateCategoryBottomSheet({@required this.model});

  @override
  _UpdateCategoryBottomSheetState createState() => _UpdateCategoryBottomSheetState();
}

class _UpdateCategoryBottomSheetState extends State<UpdateCategoryBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _currentNameCtrl;
  bool _isBtnActive = false;

  _onButtonClicked() async {
    if (_isBtnActive) {
      FocusScope.of(context).unfocus();
      final bool updateResult = await Provider.of<CategoryItemProvider>(context, listen: false).updateCategoryName(context, widget.model.id, _currentNameCtrl.text);
      if (updateResult) {
        Navigator.popUntil(context, ModalRoute.withName('/editMenu'));
        showMyFlushbar(context, "Successful");
      }
    }
  }

  @override
  void initState() {
    _currentNameCtrl = new TextEditingController(text: widget.model.categoryName);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom), // Moves to upper when keyboard opened
      child: Container(
        height: 250,
        padding: const EdgeInsets.only(top: 20, left: 16, right: 16),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Text("Edit", style: new TextStyle(color: HexColor("#3C3C3C"), fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 27),
                  //CustomTextFormField(controller: _currentNameCtrl,  callback: _validateForm),
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
                        if (value.trim() != widget.model.categoryName && value.trim() != "" && value != null) {
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
                          return "Please enter category name";
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(height: 20),
                  CustomFullWidthButton(
                    btnTitle: "UPDATE",
                    callback: _onButtonClicked,
                    isBtnActive: _isBtnActive,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
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
