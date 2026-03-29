import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:merchant_delivery/providers/order_provider.dart';
import 'package:merchant_delivery/providers/user_provider.dart';
import 'package:merchant_delivery/utils/constants.dart';
import 'package:merchant_delivery/utils/util_functions.dart';
import 'package:merchant_delivery/widgets/custom_full_width_button.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import './forgot_password.dart';
import '../utils/app_theme.dart';
import '../widgets/custom_text_form_field.dart';


class LoginScreen extends StatefulWidget {

  @override
  _LoginScreenState createState() => _LoginScreenState();

}

class _LoginScreenState extends State<LoginScreen> {



  final _formKey = GlobalKey<FormState>();
  TextEditingController _userNameCtrl = new TextEditingController();
  TextEditingController _pwdCtrl = new TextEditingController();
  FocusNode passwordFocusNode = new FocusNode();
  FocusNode usernameFocusNode = new FocusNode();
  bool _isBtnActive = false;

  String _validateUsername(String value) {
    if (value.isEmpty) {
      return "Please enter the username";
    }
    return null;
  }

  String _validatePassword(String value) {
    if (value.isEmpty) {
      return "Please enter the password";
    }
    return null;
  }

  _onUsernameSubmit(String value) {
    passwordFocusNode.requestFocus();
  }

  _onPasswordSubmit(String value) {
    if (_pwdCtrl.text != null &&
        _pwdCtrl.text.trim() != "" &&
        _userNameCtrl.text != null &&
        _userNameCtrl.text.trim() != "") {
      _onStartButtonClicked();
    } else {
      usernameFocusNode.requestFocus();
    }
  }

  _onUsernameChanged(String value) {
    if (value != null &&
        value.trim() != "" &&
        _pwdCtrl.text != null &&
        _pwdCtrl.text.trim() != "") {
      setState(() {
        _isBtnActive = true;
      });
    } else {
      setState(() {
        _isBtnActive = false;
      });
    }
  }

  _onPwdChanged(String value) {
    if (value != null &&
        value.trim() != "" &&
        _userNameCtrl.text != null &&
        _userNameCtrl.text.trim() != "") {
      setState(() {
        _isBtnActive = true;
      });
    } else {
      setState(() {
        _isBtnActive = false;
      });
    }
  }

  void _onStartButtonClicked() async {

    if (_isBtnActive) {

      FocusScope.of(context).unfocus();
      if (_formKey.currentState.validate()) {

        final bool isAuthSuccess =
            await Provider.of<UserProvider>(context, listen: false)
                .authenticateUser(context, _userNameCtrl.text, _pwdCtrl.text);
        if (isAuthSuccess) {
          // Set logged in, if user logged in, the user will be navigated to Home Screen
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setBool(Constants.isLoggedIn, true);

          Future.delayed(Duration(milliseconds: 500), () {
            Navigator.pushNamed(context, '/home');
          });

        }
      }
    }

  }



  @override
  void dispose() {
    _userNameCtrl.dispose();
    _pwdCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mqData = MediaQuery.of(context).size;
    double screenRatio = 1;
    if (mqData.height < 500) {
      screenRatio = 1.45;
    } else if (mqData.height > 500 && mqData.height < 600) {
      screenRatio = 1.03;
    }
    return WillPopScope(
      onWillPop: () => onWillPop(context),
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Container(
                child: Stack(
                  children: <Widget>[
                    Container(
                      height: mqData.height * screenRatio,
                      decoration: BoxDecoration(
                        color: AppTheme.textColor,
                      ),
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      top: 60,
                      child: Container(
                        height: 100,
                        child: Image.asset('assets/images/fly_eaters.png'),
                      ),
                    ),
                    Positioned.fill(
                      top: 180,
                      child: Container(
                        decoration: AppTheme.upperRoundedDecor,
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: <Widget>[
                              SizedBox(height: 35),
                              Text(
                                "Login",
                                style: TextStyle(
                                    fontSize: 24, fontWeight: FontWeight.w600),
                              ),
                              SizedBox(height: 80),
                              CustomTextFormField(
                                controller: _userNameCtrl,
                                hintText: "User name",
                                onSubmittedCallback: _onUsernameSubmit,
                                validationCallback: _validateUsername,
                                onChangeCallback: _onUsernameChanged,
                                focusNode: usernameFocusNode,
                              ),
                              SizedBox(height: 20),
                              CustomTextFormField(
                                controller: _pwdCtrl,
                                hintText: "Password",
                                isPwd: true,
                                validationCallback: _validatePassword,
                                onChangeCallback: _onPwdChanged,
                                focusNode: passwordFocusNode,
                                onSubmittedCallback: _onPasswordSubmit,
                              ),
                              SizedBox(height: 12),
                              Padding(
                                padding: const EdgeInsets.only(right: 20),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: <Widget>[
                                    Material(
                                      color: Colors.white,
                                      child: InkWell(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(10)),
                                        splashColor: Colors.grey,
                                        onTap: () {
                                          debugPrint("Forgot password");
                                          forgotPasswordSheet(context);
                                        },
                                        child: Container(
                                          width: 120,
                                          height: 25,
                                          child: Center(
                                            child: Text(
                                              "Forgot Password",
                                              style: TextStyle(
                                                  color: AppTheme.textColor,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600),
                                              textAlign: TextAlign.right,
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              SizedBox(height: 25),
                              CustomFullWidthButton(
                                btnTitle: "START",
                                callback: _onStartButtonClicked,
                                isBtnActive: _isBtnActive,
                              ),
                              SizedBox(height: 25),
                            ],
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
