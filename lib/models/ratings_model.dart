import 'dart:convert';

class RatingsModel {
  String totalItems;
  String totalRating;
  List<RatingItem> items;

  RatingsModel({
    this.totalItems,
    this.items,
    this.totalRating,
  });

  Map<String, dynamic> toMap() {
    return {
      'total_items': totalItems,
      'data': items?.map((x) => x?.toMap())?.toList(),
      'total_rating': totalRating
    };
  }

  factory RatingsModel.fromMap(Map<String, dynamic> map) {
    if (map == null) return null;

    return RatingsModel(
        totalItems: map['total_items'],
        items: List<RatingItem>.from(
            map['data']?.map((x) => RatingItem.fromMap(x))),
        totalRating: map['total_rating']);
  }

  String toJson() => json.encode(toMap());

  factory RatingsModel.fromJson(String source) =>
      RatingsModel.fromMap(json.decode(source));
}

class RatingItem {
  String id;
  String review;
  String rating;
  String dateCreated;
  String customerName;
  String customerImage;
  String order_id;

  RatingItem(
      {this.id,
      this.review,
      this.rating,
      this.dateCreated,
      this.customerName,
      this.customerImage,
      this.order_id});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'review': review,
      'rating': rating,
      'dateCreated': dateCreated,
      'customerName': customerName,
      'customerImage': customerImage,
    };
  }

  factory RatingItem.fromMap(Map<String, dynamic> map) {
    if (map == null) return null;
    print(map.toString());
    return RatingItem(
        id: map['id'],
        review: map['review'],
        rating: map['rating'],
        dateCreated: map['date_created'],
        customerName: map['customer_name'],
        customerImage: map['customer_image'],
        order_id: map['order_id']);
  }

  String toJson() => json.encode(toMap());

  factory RatingItem.fromJson(String source) =>
      RatingItem.fromMap(json.decode(source));
}
