import 'package:flutter/material.dart';

import '../utils/app_theme.dart';

class CustomTextFormField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool isPwd;
  final Function(String) validationCallback;
  final Function(String) onChangeCallback;
  final Function(String) onSubmittedCallback;
  final FocusNode focusNode;

  CustomTextFormField({
    @required this.controller,
    @required this.hintText,
    @required this.validationCallback,
    this.onChangeCallback,
    this.onSubmittedCallback,
    this.focusNode,
    this.isPwd = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 20, right: 20),
      child: TextFormField(
        controller: controller,
        obscureText: isPwd,
        onFieldSubmitted: onSubmittedCallback,
        focusNode: focusNode,
//        inputFormatters: [maskFormatter],
        style: TextStyle(color: AppTheme.textColor),
        keyboardType: TextInputType.text,
        textInputAction: TextInputAction.done,
        onChanged: (value) => onChangeCallback(value),
        decoration: _inputDecoration(hintText),
        validator: (value) => validationCallback(value),
      ),
    );
  }

  InputDecoration _inputDecoration(String labelText) {
    return InputDecoration(
//      labelText: labelText,
      hintText: labelText,
      labelStyle: TextStyle(color: AppTheme.textColor.withOpacity(0.5)),
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
