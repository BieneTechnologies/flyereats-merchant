import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:provider/provider.dart';

import 'package:merchant_delivery/models/items_category_model.dart';
import 'package:merchant_delivery/providers/category_item_provider.dart';
import 'package:merchant_delivery/screens/food_menu_on_off/next_opening_time_bottom_sheet.dart';
import 'package:merchant_delivery/utils/hex_color.dart';
import 'package:merchant_delivery/utils/util_functions.dart';
import 'package:merchant_delivery/widgets/search_widget.dart';

class ItemsWidget extends StatefulWidget {
  TextEditingController controller;

  ItemsWidget(
    this.controller,
  );

  @override
  _ItemsWidgetState createState() => _ItemsWidgetState();
}

class _ItemsWidgetState extends State<ItemsWidget> {
  TextEditingController _searchKeyCtrl = new TextEditingController();
  Future<void> _future;
  Timer _debounce;

  _getCategoryWithItems(String searchKey) async {
    _future = Provider.of<CategoryItemProvider>(context, listen: false)
        .getCategoryWithItems(context, searchKey);
  }

  void _onSearchKeyChange(String value) {
//    _future = Provider.of<CategoryItemProvider>(context, listen: false).getCategoryWithItems(context, value);
    if (_searchKeyCtrl.text.length > 0) {
      if (_debounce?.isActive ?? false) _debounce.cancel();
      _debounce = Timer(const Duration(milliseconds: 500), () {
        setState(() {
          _future = Provider.of<CategoryItemProvider>(context, listen: false)
              .getCategoryWithItems(context, _searchKeyCtrl.text);
        });
      });
    }
  }

  _onSearchChanged() {}

  @override
  void initState() {
    _getCategoryWithItems("");

    _searchKeyCtrl = widget.controller;
    _searchKeyCtrl.addListener(_onSearchChanged);
    super.initState();
  }

  @override
  void dispose() {
    // _searchKeyCtrl.text = "";
    // _searchKeyCtrl.removeListener(_onSearchChanged);
    // _searchKeyCtrl.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(padding: const EdgeInsets.only(top: 20)),
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
                    child: new ListView.builder(
                      itemCount: ciProvider.itemsWithCategory.length,
                      itemBuilder: (BuildContext ctxt, int index) {
                        return AnimationConfiguration.staggeredList(
                          position: index,
                          duration: const Duration(milliseconds: 120),
                          child: SlideAnimation(
                            verticalOffset: 50.0,
                            child: FadeInAnimation(
                              child: CategoryItem(
                                  allItems:ciProvider.itemsWithCategory,
                                  model: ciProvider.itemsWithCategory[index],
                                  index: index),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
          },
        ),
      ],
    );
  }
}

class CategoryItem extends StatefulWidget {
  final List<ItemsWithCategoryModel> allItems;
  final ItemsWithCategoryModel model;
  final int index;

  CategoryItem({@required this.allItems,@required this.model, @required this.index});

  @override
  _CategoryItemState createState() => _CategoryItemState();
}

class _CategoryItemState extends State<CategoryItem> {
  String _statusChangedItemId = "";

  void _timeSelectedCallback(SelectedNOT value, bool isOn) async {
    var item = widget.model.items
        .where((element) => element.itemId == _statusChangedItemId)
        .first;


    widget.allItems.forEach((element) {
      element.items.forEach((itemElement) {
        if(itemElement.itemId==_statusChangedItemId){
          setState((){
            itemElement.availability = !isOn ? "1" : "0";
          });
        }
      });

    });

    // setState(() {
    //   item.availability = !isOn ? "1" : "0";
    // });

    final bool result =
        await Provider.of<CategoryItemProvider>(context, listen: false)
            .updateItemAvailability(context, value, isOn,
                itemId: _statusChangedItemId);

    if (result) {
      showMyFlushbar(context, "success");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(padding: EdgeInsets.only(top: widget.index == 0 ? 0 : 20)),
        Container(
          color: HexColor("#F3F3F3"),
          padding:
              const EdgeInsets.only(top: 6, bottom: 6, left: 20, right: 20),
          width: double.infinity,
          child: Text(
            widget.model.categoryName,
            style: TextStyle(
                color: HexColor("#3C3C3C").withOpacity(0.7),
                fontSize: 18,
                fontWeight: FontWeight.w500),
          ),
        ),
        _convertItemsToWidget(widget.model.items, context),
      ],
    );
  }

  _convertItemsToWidget(List<Items> items, BuildContext context) {
    return Column(
      children: items.map((item) {
        return Column(
          children: [
            Container(
              padding: const EdgeInsets.only(
                  left: 23, right: 23, top: 17, bottom: 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                      child: Text(item.itemName,
                          style: TextStyle(
                              fontSize: 18,
                              color: HexColor("#3C3C3C"),
                              fontWeight: FontWeight.w500))),
                  Transform.scale(
                    scale: 0.70,
                    child: CupertinoSwitch(
                      value: item.availability == "1" ? true : false,
                      onChanged: (value) {
                        setState(() {
                          _statusChangedItemId = item.itemId;
                        });
                        if (!value) {
                          nextOpeningTimeSheet(context, _timeSelectedCallback);
                        } else {
                          _timeSelectedCallback(new SelectedNOT(), false);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 23),
              child:
                  Divider(height: 5, thickness: 1, color: HexColor("#DEDEDE")),
            ),
          ],
        );
      }).toList(),
    );
  }
}
