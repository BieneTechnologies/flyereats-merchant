import 'dart:async';

import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:merchant_delivery/providers/custom_page_provider.dart';
import 'package:merchant_delivery/utils/app_theme.dart';
import 'package:merchant_delivery/utils/hex_color.dart';
import 'package:merchant_delivery/utils/util_functions.dart';
import 'package:merchant_delivery/widgets/custom_appbar.dart';
import 'package:merchant_delivery/widgets/search_widget.dart';
import 'package:provider/provider.dart';

class FAQScreen extends StatefulWidget {
  @override
  _FAQScreenState createState() => _FAQScreenState();
}

class _FAQScreenState extends State<FAQScreen> {
  TextEditingController _searchKeyCtrl = new TextEditingController();
  Future<void> _future;
  Timer _debounce;

  _getFAQs() async {
    _future = Provider.of<CustomPageProvider>(context, listen: false)
        .getFAQs(context);
  }

  void _onSearchKeyChange(String searchKey) {
    /*_future = Provider.of<CustomPageProvider>(context, listen: false)
        .searchFAQs(searchKey);*/
    if (_debounce?.isActive ?? false) _debounce.cancel();
    _debounce = Timer(const Duration(milliseconds: 50), () {
      _future = Provider.of<CustomPageProvider>(context, listen: false)
          .searchFAQs(_searchKeyCtrl.text);
    });
  }

  _onSearchChanged() {}

  @override
  void initState() {
    _getFAQs();
    _searchKeyCtrl.addListener(_onSearchChanged);
    super.initState();
  }

  @override
  void dispose() {
    _searchKeyCtrl.removeListener(_onSearchChanged);
    _searchKeyCtrl.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.mainBlackColor,
      appBar: MyAppbar(title: "FAQ’s"),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: AppTheme.upperRoundedDecor,
        padding: const EdgeInsets.only(top: 0, left: 0, right: 0),
        child: Column(
          children: [
            Padding(padding: const EdgeInsets.only(top: 20)),
            SearchWidget(
              controller: _searchKeyCtrl,
              hintText: "Search",
              callback: _onSearchKeyChange,
            ),
            Padding(padding: const EdgeInsets.only(top: 20)),
            FutureBuilder(
              future: _future,
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.hasError) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 60.0),
                    child: Center(child: Text("Error Occurred!")),
                  );
                } else if (snapshot.connectionState != ConnectionState.done) {
                  return Expanded(child: loadingWidget(context));
                } else
                  return Consumer<CustomPageProvider>(
                    builder: (context, cpProvider, _) {
                      return Expanded(
                        child: new ListView.builder(
                          itemCount: cpProvider.listFaqs.length,
                          itemBuilder: (BuildContext ctxt, int index) {
                            return Column(
                              children: [
                                Container(
                                  color: HexColor("#F3F3F3"),
                                  child: ExpandablePanel(
                                    tapHeaderToExpand: true,
                                    headerAlignment:
                                        ExpandablePanelHeaderAlignment.center,
                                    header: Container(
                                      child: Padding(
                                        padding: EdgeInsets.only(
                                            left: 20,
                                            right: 20,
                                            top: 10,
                                            bottom: 10),
                                        child: Text(
                                          cpProvider.listFaqs[index].question,
                                          style: new TextStyle(
                                              color: HexColor("#000000"),
                                              fontSize: 16),
                                        ),
                                      ),
                                    ),
                                    expanded: Padding(
                                      padding: const EdgeInsets.only(
                                          top: 20, bottom: 20.0),
                                      child: Text(
                                        cpProvider.listFaqs[index].answer,
                                        softWrap: true,
                                        overflow: TextOverflow.fade,
                                        style: new TextStyle(
                                            color: HexColor("#9C9C9C"),
                                            fontSize: 14),
                                      ),
                                    ),
                                    builder: (_, collapsed, expanded) {
                                      return Container(
                                        child: Padding(
                                          padding: EdgeInsets.only(
                                              left: 20.0, right: 20.0),
                                          child: Expandable(
                                            collapsed: collapsed,
                                            expanded: expanded,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                SizedBox(height: 20),
                              ],
                            );
                          },
                        ),
                      );
                    },
                  );
              },
            ),
          ],
        ),
      ),
    );
  }
}
