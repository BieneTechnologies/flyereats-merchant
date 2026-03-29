import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:merchant_delivery/models/ratings_model.dart';
import 'package:merchant_delivery/providers/rating_provider.dart';
import 'package:merchant_delivery/utils/app_theme.dart';
import 'package:merchant_delivery/utils/hex_color.dart';
import 'package:merchant_delivery/utils/util_functions.dart';
import 'package:merchant_delivery/widgets/custom_appbar.dart';
import 'package:merchant_delivery/widgets/drawer.dart';
import 'package:provider/provider.dart';

class MyRatingsScreen extends StatefulWidget {
  @override
  _MyRatingsScreenState createState() => _MyRatingsScreenState();
}

class _MyRatingsScreenState extends State<MyRatingsScreen> {
  Future<RatingsProvider> _future;

  @override
  void initState() {
    _future =
        Provider.of<RatingsProvider>(context, listen: false).firstPage(context);

    super.initState();
  }

  _pop() {
    Navigator.of(context).pop();
  }

  DateFormat formatter = new DateFormat("LLL dd. yyyy");
  Widget totalRating = new Material();
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => _pop(),
      child: Scaffold(
        backgroundColor: AppTheme.mainBlackColor,
        appBar: AppBar(
          backgroundColor: AppTheme.mainBlackColor,
          elevation: 0,
          title: FutureBuilder(
              future: _future,
              builder: (BuildContext context,
                  AsyncSnapshot<RatingsProvider> snapshot) {
                if (snapshot.hasError) {
                  return Container(
                    height: MediaQuery.of(context).size.height / 2,
                    child: Center(child: Text("Error Occurred!")),
                  );
                } else if (snapshot.connectionState != ConnectionState.done) {
                  return loadingWidget(context);
                } else {
                  return Text("Reviews (" +
                      snapshot.data.model.totalItems.toString() +
                      ")");
                }
              }),
          centerTitle: false,
          leading: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Icon(Icons.keyboard_arrow_left),
          ),
          actions: [
            FutureBuilder(
                future: _future,
                builder: (BuildContext context,
                    AsyncSnapshot<RatingsProvider> snapshot) {
                  if (snapshot.hasError) {
                    return Material();
                  } else if (snapshot.connectionState != ConnectionState.done) {
                    return Material();
                  } else {
                    return _rating(int.parse(
                        snapshot.data.model.totalRating.substring(0, 1)));
                  }
                })
          ],
        ),
        body: Container(
          height: MediaQuery.of(context).size.height,
          width: double.infinity,
          padding:
              const EdgeInsets.only(top: 30, bottom: 10, left: 10, right: 10),
          decoration: AppTheme.upperRoundedDecor,
          child: SafeArea(
//              minimum: const EdgeInsets.only(right: 20, left: 20, bottom: 16),
            child: FutureBuilder(
                future: _future,
                builder: (BuildContext context,
                    AsyncSnapshot<RatingsProvider> snapshot) {
                  if (snapshot.hasError) {
                    return Container(
                      height: MediaQuery.of(context).size.height / 2,
                      child: Center(child: Text("Error Occurred!")),
                    );
                  } else if (snapshot.connectionState != ConnectionState.done) {
                    return Center(child: loadingWidget(context));
                  } else {
                    return ListView.builder(
                        itemCount: snapshot.data.model.items.length + 1,
                        itemBuilder: (context, index) {
                          if (index < snapshot.data.model.items.length) {
                            return _ratingItem(
                                snapshot.data.model.items[index]);
                          } else {
                            if (snapshot.data.model.items.length <
                                int.parse(snapshot.data.model.totalItems)) {
                              return Center(
                                child: TextButton(
                                  child: Text("Load more..."),
                                  onPressed: () => nextPage(),
                                ),
                              );
                            } else {
                              return Material();
                            }
                          }
                        });
                  }
                }),
          ),
        ),
      ),
    );
  }

  Widget _ratingItem(RatingItem item) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
              flex: 1,
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.white,
                backgroundImage: NetworkImage(
                  item.customerImage,
                ),
              ),
            ),
            SizedBox(width: 20),
            Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(height: 10),
                    Text(item.customerName + " - " + item.order_id,
                        style: TextStyle(
                            fontSize: 23,
                            color: Colors.grey[800],
                            fontWeight: FontWeight.bold)),
                    SizedBox(height: 15),
                    Text(item.review,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        )),
                    SizedBox(height: 15),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          color: Colors.grey[800],
                          size: 16,
                        ),
                        SizedBox(width: 7),
                        Text(formatter.format(DateTime.parse(item.dateCreated)),
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            )),
                        SizedBox(width: 15),
                        Icon(
                          Icons.watch_later_outlined,
                          color: Colors.grey[800],
                          size: 16,
                        ),
                        SizedBox(width: 7),
                        Text("08:30 PM",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ))
                      ],
                    ),
                    SizedBox(height: 15),
                    _rating(int.parse(item.rating.substring(0, 1)))
                  ],
                ))
          ],
        ),
        SizedBox(height: 20),
        Container(width: double.infinity, height: 1, color: Colors.grey[850]),
        SizedBox(height: 20),
      ],
    );
  }

  Widget _rating(int stars) {
    return Row(
      children: List<Widget>.generate(5, (index) {
        return index < stars
            ? Icon(
                Icons.star,
                color: Colors.amberAccent[700],
                size: 26,
              )
            : Icon(
                Icons.star_border,
                color: Colors.grey,
                size: 26,
              );
      }),
    );
  }

  nextPage() {
    _future.then((value) {
      value.nextPage(context).then((value) {
        setState(() {});
      });
    });
  }
}
