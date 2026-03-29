import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:merchant_delivery/providers/category_item_provider.dart';
import 'package:merchant_delivery/screens/food_menu_on_off/categories.dart';
import 'package:merchant_delivery/screens/food_menu_on_off/items.dart';
import 'package:merchant_delivery/screens/food_menu_on_off/next_opening_time_bottom_sheet.dart';
import 'package:merchant_delivery/utils/app_theme.dart';
import 'package:merchant_delivery/utils/constants.dart';
import 'package:merchant_delivery/utils/hex_color.dart';
import 'package:merchant_delivery/widgets/custom_appbar.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MenuOnOffNewScreen extends StatefulWidget {
  @override
  _MenuOnOffScreenState createState() => _MenuOnOffScreenState();
}

class _MenuOnOffScreenState extends State<MenuOnOffNewScreen>
    with SingleTickerProviderStateMixin {

  String _merchantName = "";

  TextEditingController _searchKeyCtrlItems = new TextEditingController();
  TextEditingController _searchKeyCtrlCategory = new TextEditingController();

  int _activeTabIndex = 0;
  TabController _tabController;

  void _getMerchantName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _merchantName = prefs.getString(Constants.restaurant_name);

    });
  }

  void _setActiveTabIndex() {
    if (_tabController.indexIsChanging) {
      setState(() {
        _searchKeyCtrlItems.text = "";
        _searchKeyCtrlCategory.text = "";
        _activeTabIndex = _tabController.index;


        if(_activeTabIndex==0){

          FocusScope.of(context).unfocus();
          _searchKeyCtrlItems.clear();

        }else{

          FocusScope.of(context).unfocus();
          _searchKeyCtrlCategory.clear();

        }

      });
    }
  }

  void _timeSelectedCallback(SelectedNOT value, bool isChecked) async {
    final bool result =
        await Provider.of<CategoryItemProvider>(context, listen: false)
            .updateMerchantAvailability(context, value, isChecked);
  }

  bool firstTime = false;
  bool open = false;
  @override
  void initState() {
    _getMerchantName();
    firstTime = true;
    _tabController = new TabController(length: 2, vsync: this);
    _tabController.addListener(_setActiveTabIndex);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.mainBlackColor,
      appBar: MyAppbar(title: _merchantName + "/Menu Setup"),
      body: Container(
        decoration: AppTheme.upperRoundedDecor,
        padding: const EdgeInsets.only(top: 20),
        child: LayoutBuilder(builder: (context, constraints) {

          return ConstrainedBox(
            constraints: BoxConstraints(
                minWidth: constraints.maxWidth,
                minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: SafeArea(
                child: Container(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Container(
                        padding: const EdgeInsets.only(left: 23, right: 23),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Flexible(
                              child: Text(
                                _merchantName + " - Open/Close",
                                style: TextStyle(
                                    fontSize: 18,
                                    color: HexColor("#3C3C3C"),
                                    fontWeight: FontWeight.w500),
                              ),
                            ),
//                          Spacer(),
                            Transform.scale(
                              scale: 0.70,
                              child: CupertinoSwitch(
                                value: !firstTime?Provider.of<CategoryItemProvider>(
                                        context,
                                        listen: true)
                                    .merchantOpen:true,
                                onChanged: (value) {
                                  if (!value) {
                                    nextOpeningTimeSheet(
                                        context, _timeSelectedCallback);
                                  } else {
                                    _timeSelectedCallback(
                                        new SelectedNOT(), false);
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(padding: const EdgeInsets.only(top: 5)),
                      Divider(
                          height: 5, thickness: 1, color: HexColor("#DEDEDE")),
                      Padding(padding: const EdgeInsets.only(top: 20)),
                      // Constants.baseUrl.contains("flyereats.in")?
                      Constants.baseUrl.contains("137.59.54.62")?

                      Expanded(
                        child: new DefaultTabController(
                          length: 2,
                          child: new Scaffold(
                            appBar: new PreferredSize(
                              preferredSize: Size.fromHeight(24),
                              child: Align(
                                alignment: Alignment.center,
                                child: new Container(
                                  color: AppTheme.mainWhiteColor,
                                  height: 30.0,
                                  child: Center(
                                    child: new TabBar(
                                      indicator: UnderlineTabIndicator(
                                        borderSide: BorderSide(
                                            width: 3.0,
                                            color: HexColor("#FFC94B")),
                                        insets: EdgeInsets.symmetric(
                                            horizontal: 16.0),
                                      ),
                                      controller: _tabController,
                                      isScrollable: true,
                                      tabs: [
                                        Tab(
                                          child: Text(
                                            "Items",
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: _activeTabIndex == 0
                                                  ? AppTheme.textColor
                                                  : AppTheme.textColor
                                                      .withOpacity(0.5),
                                            ),
                                          ),
                                        ),
                                        Tab(
                                          child: Text(
                                            "Category",
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: _activeTabIndex == 1
                                                  ? AppTheme.textColor
                                                  : AppTheme.textColor
                                                      .withOpacity(0.5),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            body: Container(
                              color: AppTheme.mainWhiteColor,
                              child: TabBarView(
                                controller: _tabController,
                                children: [
                                  ItemsWidget(_searchKeyCtrlItems),
                                  CategoriesWidget(
                                    controller: _searchKeyCtrlCategory,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ):Container(),
                      // SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
