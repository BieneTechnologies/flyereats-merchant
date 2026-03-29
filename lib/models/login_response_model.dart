class LoginResponseModel {
  int code;
  String msg;
  Details details;

  LoginResponseModel({this.code, this.msg, this.details});

  LoginResponseModel.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    msg = json['msg'];
    details =
    json['details'] != null ? new Details.fromJson(json['details']) : null;
  }
}

class Details {
  String token;
  Info info;

  Details({this.token, this.info});

  Details.fromJson(Map<String, dynamic> json) {
    token = json['token'];
    info = json['info'] != null ? new Info.fromJson(json['info']) : null;
  }
}

class Info {
  String username;
  String restaurantName;
  String contactEmail;
  String userType;
  String merchantId;
  int merchantUserId;

  Info(
      {this.username,
        this.restaurantName,
        this.contactEmail,
        this.userType,
        this.merchantId,
        this.merchantUserId});

  Info.fromJson(Map<String, dynamic> json) {
    username = json['username'];
    restaurantName = json['restaurant_name'];
    contactEmail = json['contact_email'];
    userType = json['user_type'];
    merchantId = json['merchant_id'];
    merchantUserId = json['merchant_user'];
  }

}