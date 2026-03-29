import 'package:flutter/material.dart';
import 'package:merchant_delivery/utils/app_theme.dart';

class CustomFullWidthButton extends StatelessWidget {
  final String btnTitle;
  final VoidCallback callback;
  final bool isBtnActive;

  CustomFullWidthButton({
    this.btnTitle,
    this.callback,
    this.isBtnActive = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: RaisedButton(
        color: isBtnActive
            ? AppTheme.btnColor
            : AppTheme.btnColor.withOpacity(0.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        elevation: isBtnActive ? 3 : 0,
//        splashColor: isBtnActive? Colors Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Text(
            btnTitle,
            style: TextStyle(
              fontSize: 24,
              color: isBtnActive
                  ? AppTheme.textColor
                  : AppTheme.textColor.withOpacity(0.5),
            ),
          ),
        ),
        onPressed: isBtnActive ? callback : () => print(1),
      ),
    );
  }
}
