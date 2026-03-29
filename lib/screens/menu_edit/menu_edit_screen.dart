import 'dart:async';

import 'package:flutter/material.dart';
import 'package:merchant_delivery/models/items_category_model.dart';
import 'package:merchant_delivery/providers/category_item_provider.dart';
import 'package:merchant_delivery/screens/menu_edit/category_edit_bottom_sheet.dart';
import 'package:merchant_delivery/screens/menu_edit/item_edit_bottom_sheet.dart';
import 'package:merchant_delivery/utils/app_theme.dart';
import 'package:merchant_delivery/utils/hex_color.dart';
import 'package:merchant_delivery/utils/util_functions.dart';
import 'package:merchant_delivery/widgets/custom_appbar.dart';
import 'package:merchant_delivery/widgets/search_widget.dart';
import 'package:provider/provider.dart';

class MenuEditScreen extends StatefulWidget {
  @override
  _MenuEditScreenState createState() => _MenuEditScreenState();
}

class _MenuEditScreenState extends State<MenuEditScreen> {

  TextEditingController _searchKeyCtrl = new TextEditingController();
  Future<void> _future;
  Timer _debounce;


  _getCategoryWithItems() async {
    _future = Provider.of<CategoryItemProvider>(context, listen: false)
        .getCategoryWithItems(context, "");
  }

  @override
  void initState() {
    _getCategoryWithItems();
    _searchKeyCtrl.addListener(_onSearchChanged);
    print("edit edit edity edit");
    super.initState();
  }

  void _onSearchKeyChange(String value) {
//    _future = Provider.of<CategoryItemProvider>(context, listen: false).getCategoryWithItems(context, value);
    if (_searchKeyCtrl.text.length > 0) {
      if (_debounce?.isActive ?? false) _debounce.cancel();
      _debounce = Timer(const Duration(milliseconds: 500), () {
        debugPrint(" _searchKeyCtrl.text ${_searchKeyCtrl.text}");
        setState(() {
          _future = Provider.of<CategoryItemProvider>(context, listen: false)
          .getCategoryWithItems(context, _searchKeyCtrl.text);
        });
      });
    }
  }

  _onSearchChanged() {}

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
      appBar: MyAppbar(title: "Menu Edit"),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: AppTheme.upperRoundedDecor,
        child: Column(
          children: [
            Padding(padding: const EdgeInsets.only(top: 35)),
            SearchWidget(
              controller: _searchKeyCtrl,
              hintText: "Search Item",
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
                  return Consumer<CategoryItemProvider>(
                    builder: (context, ciProvider, _) {
                      return Expanded(
                        child: ListView.builder(
                          itemCount: ciProvider.itemsWithCategory.length,
                          itemBuilder: (context, i) {
                            return new ExpandableListView(
                              model: ciProvider.itemsWithCategory[i],
                              searchController: _searchKeyCtrl,
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

class ExpandableListView extends StatefulWidget {
  final ItemsWithCategoryModel model;
  final TextEditingController searchController;
  const ExpandableListView(
      {Key key, @required this.model, @required this.searchController})
      : super(key: key);

  @override
  _ExpandableListViewState createState() => new _ExpandableListViewState();
}

class _ExpandableListViewState extends State<ExpandableListView> {
  bool expandFlag = true;

  _onCategoryEditClicked(ItemsWithCategoryModel model) {
    widget.searchController.text = "";
    updateCategoryBottomSheet(context, model);
  }

  _onItemEditClicked(Items item /*, {Price selectedPrice}*/) {
    widget.searchController.text = "";
    updateItemBottomSheet(context, item /*, selectedPrice*/);
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
      margin: new EdgeInsets.symmetric(vertical: 5.0),
      child: new Column(
        children: <Widget>[
          new Container(
            color: HexColor("#F3F3F3"),
            child: new Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: new Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    child: Row(
                      children: [
                        new Text(
                          widget.model.categoryName +
                              " (${widget.model.items.length})",
                          style: new TextStyle(
                            fontWeight: FontWeight.bold,
                            color: HexColor("#3C3C3C").withOpacity(0.7),
                            fontSize: 18,
                          ),
                        ),
                        Padding(padding: const EdgeInsets.only(left: 16)),
                        GestureDetector(
                          onTap: () {
                            _onCategoryEditClicked(widget.model);
                          },
                          child: new Icon(
                            Icons.mode_edit,
                            color: HexColor("#000000").withOpacity(0.5),
                            size: 20,
                          ),
                        )
                      ],
                    ),
                  ),
                  new IconButton(
                      icon: new Container(
                        child: new Center(
                          child: new Icon(
                            expandFlag
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
                            color: HexColor("#000000"), // Colors.white,
                            size: 25.0,
                          ),
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          expandFlag = !expandFlag;
                        });
                      }),
                ],
              ),
            ),
          ),
          new ExpandableContainer(
            expanded: expandFlag,
            expandedHeight: widget.model.items.length < 5
                ? (60 * widget.model.items.length).toDouble()
                : 300,
            child: new ListView.builder(
              itemBuilder: (BuildContext context, int index) {
                return /*widget.model.items[index].price.length != 0
                    ? _displaySizeNameWithPrice(widget.model.items[index])
                    : */
                    Container(
                  padding: const EdgeInsets.symmetric(horizontal: 23),
                  decoration: new BoxDecoration(
                    border:
                        new Border.all(width: 1, color: HexColor("#DEDEDE")),
                    color: Colors.white,
                  ),
                  child: new ListTile(
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: new Text(
                            widget.model.items[index].itemName,
                            style: new TextStyle(
                                fontWeight: FontWeight.w500,
                                color: HexColor("#3C3C3C")),
                          ),
                        ),
                      ],
                    ),
                    trailing: Padding(
                      padding: const EdgeInsets.only(left: 18.0),
                      child: GestureDetector(
                        onTap: () {
                          _onItemEditClicked(widget.model.items[index]);
                        },
                        child: new Icon(
                          Icons.mode_edit,
                          color: HexColor("#000000").withOpacity(0.5),
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                );
              },
              itemCount: widget.model.items.length,
            ),
          )
        ],
      ),
    );
  }

  _displaySizeNameWithPrice(Items item) {
    return Column(
      children: item.price
          .map(
            (price) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 23),
              decoration: new BoxDecoration(
                border: new Border.all(width: 1, color: HexColor("#DEDEDE")),
                color: Colors.white,
              ),
              child: ListTile(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: new Text(
                        item.itemName + " " + price.sizeName,
                        style: new TextStyle(
                            fontWeight: FontWeight.w500,
                            color: HexColor("#3C3C3C")),
                      ),
                    ),
                    RichText(
                      text: TextSpan(
                        text: price.currencyCode,
                        style: TextStyle(
                          color: HexColor("#000000").withOpacity(0.5),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        children: <TextSpan>[
                          TextSpan(
                            text: ' ' + price.price,
                            style: TextStyle(
                                color: HexColor("#3C3C3C"),
                                fontSize: 21,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                trailing: Padding(
                  padding: const EdgeInsets.only(left: 18.0),
                  child: GestureDetector(
                    onTap: () =>
                        _onItemEditClicked(item /*, selectedPrice: price*/),
                    child: new Icon(
                      Icons.mode_edit,
                      color: HexColor("#000000").withOpacity(0.5),
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class ExpandableContainer extends StatelessWidget {
  final bool expanded;
  final double collapsedHeight;
  final double expandedHeight;
  final Widget child;

  ExpandableContainer({
    @required this.child,
    this.collapsedHeight = 0.0,
    this.expandedHeight = 300.0,
    this.expanded = true,
  });

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return new AnimatedContainer(
      duration: new Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      width: screenWidth,
      height: expanded ? expandedHeight : collapsedHeight,
      child: new Container(
        child: child,
      ),
    );
  }
}
