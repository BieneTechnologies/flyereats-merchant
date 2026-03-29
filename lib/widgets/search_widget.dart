import 'package:flutter/material.dart';

import '../utils/app_theme.dart';

class SearchWidget extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final Function(String) callback;
  final double padding;

  SearchWidget({
    @required this.controller,
    @required this.hintText,
    @required this.callback,
    this.padding = 20.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: padding),
      child: TextFormField(
        controller: controller,
        style: TextStyle(color: AppTheme.textColor),
        keyboardType: TextInputType.text,
        textInputAction: TextInputAction.done,
        decoration: _inputDecoration(hintText),
        // onChanged: (value) => callback(value),
        onEditingComplete: () {
          FocusScope.of(context).unfocus();
          callback(controller.text.toString());
        }
      ),
    );
  }

  InputDecoration _inputDecoration(String labelText) {
    return InputDecoration(
      hintText: labelText,
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
