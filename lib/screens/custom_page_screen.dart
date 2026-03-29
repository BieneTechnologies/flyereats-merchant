import 'package:flutter/material.dart';
//import 'package:flutter_html_view/flutter_html_view.dart';
import 'package:merchant_delivery/models/custom_page_model.dart';
import 'package:merchant_delivery/providers/custom_page_provider.dart';
import 'package:merchant_delivery/utils/app_theme.dart';
import 'package:merchant_delivery/utils/constants.dart';
import 'package:merchant_delivery/utils/util_functions.dart';
import 'package:merchant_delivery/widgets/custom_appbar.dart';
import 'package:provider/provider.dart';

class CustomPageScreen extends StatefulWidget {
  final PageTitle pageTitle;

  CustomPageScreen({@required this.pageTitle});

  @override
  _CustomPageScreenState createState() => _CustomPageScreenState();
}

class _CustomPageScreenState extends State<CustomPageScreen> {
  String title = "";
  String param = "";

  _setPageTitle() {
    setState(() {
      if (widget.pageTitle == PageTitle.FAQ) {
        title = "FAQ’s";
        param = "1";
      } else if (widget.pageTitle == PageTitle.PRIVACYPOLICY) {
        title = "Privacy Policy";
        param = "3";
      } else {
        title = "Terms and Conditions";
        param = "2";
      }
    });
  }

  @override
  void initState() {
    _setPageTitle();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.mainBlackColor,
      appBar: MyAppbar(title: title),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: AppTheme.upperRoundedDecor,
        padding: const EdgeInsets.only(top: 0, left: 16, right: 16),
        child: SafeArea(
          child: FutureBuilder(
            future: Provider.of<CustomPageProvider>(context, listen: false).getCustomPage(context, param),
            builder: (BuildContext context, AsyncSnapshot<CustomPageModel> snapshot) {
              if (snapshot.hasError) {
                return Container(
                  height: MediaQuery.of(context).size.height / 2,
                  child: Center(child: Text("Error Occurred!")),
                );
              } else if (snapshot.connectionState != ConnectionState.done) {
                return loadingWidget(context);
              } else
                return SingleChildScrollView(
                  child: Container(
                    child: Text(removeAllHtmlTags(snapshot.data.content)),
                  ),
                );
            },
          ),
        ),
      ),
    );
  }

  String removeAllHtmlTags(var htmlText) {
    RegExp exp = RegExp(
        r"<[^>]*>",
        multiLine: true,
        caseSensitive: true
    );

    return htmlText.replaceAll(exp, '');
  }
}
