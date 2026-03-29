import 'package:flutter/material.dart';
import 'package:merchant_delivery/providers/user_provider.dart';
import 'package:merchant_delivery/utils/app_theme.dart';
import 'package:merchant_delivery/utils/hex_color.dart';
import 'package:merchant_delivery/widgets/custom_full_width_button.dart';
import 'package:merchant_delivery/widgets/custom_text_form_field.dart';
import 'package:provider/provider.dart';

void forgotPasswordSheet(BuildContext context) {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _emailCtrl = new TextEditingController();
  void _onButtonPressed() async {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState.validate()) {
      debugPrint("CONTINUE form valid ${_emailCtrl.text}");
      final bool resetPwdResult =
          await Provider.of<UserProvider>(context, listen: false)
              .forgotPassword(context, _emailCtrl.text);
      if (resetPwdResult) {
        //Navigator.pop(context);
        checkEmailWarningSheet(context);
      }
    }
  }

  void _onSubmit(String value) {
    _onButtonPressed();
  }

  showModalBottomSheet(
    shape: AppTheme.bottomSheetShape,
    backgroundColor: Colors.white,
    context: context,
    isScrollControlled: true,
    builder: (BuildContext bc) {
      return Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context)
                .viewInsets
                .bottom), // Moves to upper when keyboard opened
        child: Container(
          height: 320, //MediaQuery.of(context),
          child: ListView(
            shrinkWrap: true,
            children: <Widget>[
              SizedBox(height: 35),
              Center(
                child: Text(
                  "Forgot Password",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: HexColor("#3C3C3C")),
                ),
              ),
              SizedBox(height: 20),
              Center(
                child: Text(
                  "Enter Your Registered Email Id",
                  style: TextStyle(fontSize: 16, color: HexColor("#3C3C3C")),
                ),
              ),
              SizedBox(height: 20),
              Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    SizedBox(height: 25),
                    CustomTextFormField(
                      onSubmittedCallback: _onSubmit,
                      validationCallback: _validateEmail,
                      hintText: "Email address",
                      controller: _emailCtrl,
                    ),
                    SizedBox(height: 25),
                    CustomFullWidthButton(
                      btnTitle: "CONTINUE",
                      callback: _onButtonPressed,
                    ),
                    SizedBox(height: 25),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

void checkEmailWarningSheet(BuildContext context) {
  void _onButtonPressed() {
    debugPrint("OK button pressed");
    Navigator.pop(context); //Navigates to login screen
  }

  showModalBottomSheet(
    shape: AppTheme.bottomSheetShape,
    backgroundColor: Colors.white,
    context: context,
    builder: (BuildContext bc) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SizedBox(height: 35),
            Text(
              "Please Check Your Email Id To Reset Your Password",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: HexColor("#3C3C3C")),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            CustomFullWidthButton(
              btnTitle: "OK",
              callback: _onButtonPressed,
            ),
            SizedBox(height: 25),
          ],
        ),
      );
    },
  );
}

String _validateEmail(String value) {
  bool emailValid = RegExp(
          r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
      .hasMatch(value);
  if (value.isEmpty) {
    return "Please enter the registered email";
  } else if (!emailValid) {
    return "Please enter valid email";
  }
  return null;
}
