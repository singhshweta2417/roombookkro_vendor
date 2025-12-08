class UserModel {
  String? message;
  User? user;
  String? loginToken;
  int? status;

  UserModel({this.message, this.user, this.loginToken, this.status});

  UserModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    user = json['user'] != null ? User.fromJson(json['user']) : null;
    loginToken = json['loginToken'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['message'] = message;
    if (user != null) {
      data['user'] = user!.toJson();
    }
    data['loginToken'] = loginToken;
    data['status'] = status;
    return data;
  }
}

class User {
  int? userId;
  String? email;
  String? userType;
  String? userName;
  String? phone;
  String? dOB;
  int? userStatus;
  int? adharNumber;
  String? adharFrontUrl;
  String? adharBackUrl;
  String? panNumber;
  String? panImage;

  User({
    this.userId,
    this.email,
    this.userType,
    this.userName,
    this.phone,
    this.dOB,
    this.userStatus,
    this.adharNumber,
    this.adharFrontUrl,
    this.adharBackUrl,
    this.panNumber,
    this.panImage,
  });

  User.fromJson(Map<String, dynamic> json) {
    userId = json['userId'];
    email = json['email'];
    userType = json['user_type'];
    userName = json['userName'];
    phone = json['phone'];
    dOB = json['DOB'];
    userStatus = json['userStatus'];
    adharNumber = json['adharNumber'];
    adharFrontUrl = json['adharFrontUrl'];
    adharBackUrl = json['adharBackUrl'];
    panNumber = json['panNumber'];
    panImage = json['panImage'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['userId'] = userId;
    data['email'] = email;
    data['user_type'] = userType;
    data['userName'] = userName;
    data['phone'] = phone;
    data['DOB'] = dOB;
    data['userStatus'] = userStatus;
    data['adharNumber'] = adharNumber;
    data['adharFrontUrl'] = adharFrontUrl;
    data['adharBackUrl'] = adharBackUrl;
    data['panNumber'] = panNumber;
    data['panImage'] = panImage;
    return data;
  }
}
