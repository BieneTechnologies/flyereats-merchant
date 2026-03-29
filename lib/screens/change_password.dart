import 'package:flutter/material.dart';
import 'package:merchant_delivery/providers/user_provider.dart';
import 'package:merchant_delivery/utils/app_theme.dart';
import 'package:merchant_delivery/utils/util_functions.dart';
import 'package:merchant_delivery/widgets/custom_appbar.dart';
import 'package:merchant_delivery/widgets/custom_full_width_button.dart';
import 'package:merchant_delivery/widgets/custom_text_form_field.dart';
import 'package:provider/provider.dart';

class ChangePasswordScreen extends StatefulWidget {
  @override
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _currentPwdCtrl = new TextEditingController();
  TextEditingController _newPwdCtrl = new TextEditingController();
  TextEditingController _newPwdRptCtrl = new TextEditingController();
  bool _isBtnActive = false;

  String _validateCurrentPassword(String value) {
    if (value.isEmpty) {
      return "Please enter the current password";
    }
    return null;
  }

  String _validateNewPassword(String value) {
    if (value.isEmpty) {
      return "Please enter the new password";
    }
    return null;
  }

  String _validateNewRepeatPassword(String value) {
    if (value.isEmpty) {
      return "Please re-enter the new password";
    }
    return null;
  }

  FocusNode rePassNode = new FocusNode();

  _onButtonClicked() async {
    if (_formKey.currentState.validate()) {
      final map = {
        'oldPassword': _currentPwdCtrl.text,
        'newPassword': _newPwdCtrl.text,
        'confirmPassword': _newPwdRptCtrl.text,
      };

      _currentPwdCtrl.text = "";
      _newPwdCtrl.text = "";
      _newPwdRptCtrl.text = "";

      rePassNode.unfocus();

      final bool result =
          await Provider.of<UserProvider>(context, listen: false)
              .changePassword(context, map);
    }
  }

  @override
  void dispose() {
    _currentPwdCtrl.dispose();
    _newPwdCtrl.dispose();
    _newPwdRptCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.mainBlackColor,
      appBar: MyAppbar(title: "Change Password"),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: AppTheme.upperRoundedDecor,
        padding: const EdgeInsets.only(top: 20, left: 16, right: 16),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  SizedBox(height: 20),
                  CustomTextFormField(
                      controller: _currentPwdCtrl,
                      hintText: "Enter Existing Password",
                      validationCallback: _validateCurrentPassword,
                      isPwd: true),
                  SizedBox(height: 20),
                  CustomTextFormField(
                      controller: _newPwdCtrl,
                      hintText: "Enter New Password",
                      validationCallback: _validateNewPassword,
                      isPwd: true),
                  SizedBox(height: 20),
                  CustomTextFormField(
                      controller: _newPwdRptCtrl,
                      hintText: "Re-enter New Password",
                      validationCallback: _validateNewRepeatPassword,
                      focusNode: rePassNode,
                      isPwd: true),
                  SizedBox(height: 20),
                  CustomFullWidthButton(
                      btnTitle: "CHANGE PASSWORD", callback: _onButtonClicked),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
