class ItemsWithCategoryModel {
  String id;
  String categoryName;
  int availability;

  List<Items> items;

  ItemsWithCategoryModel({this.id, this.categoryName, this.availability, this.items });

  ItemsWithCategoryModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    categoryName = json['category_name'];
    availability = json['availability'];
    if (json['items'] != null) {
      items = new List<Items>();
      json['items'].forEach((v) {
        items.add(new Items.fromJson(v));
      });
    }
  }
}

class Items {
  String itemId;
  String itemName;
  String availability;
  List<Price> price;

  Items({this.itemId, this.itemName, this.availability, this.price});

  Items.fromJson(Map<String, dynamic> json) {
    itemId = json['item_id'];
    itemName = json['item_name'];
    availability = json['not_available'];
    if (json['price'] != null) {
      price = new List<Price>();
      json['price'].forEach((v) {
        price.add(new Price.fromJson(v));
      });
    }
  }
}

class Price {
  String sizeId;
  String sizeName;
  String price;
  String currencyCode;

  Price({this.sizeId, this.sizeName, this.price, this.currencyCode});

  Price.fromJson(Map<String, dynamic> json) {
    sizeId = json['size_id'];
    sizeName = json['size_name'];
    price = json['price'];
    currencyCode = json['currency_code'];
  }
}
