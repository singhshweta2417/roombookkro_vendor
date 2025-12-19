class ProfileModel {
  String? message;
  dynamic status;
  Profile? profile;

  ProfileModel({this.message, this.status, this.profile});

  ProfileModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    status = json['status'];
    profile =
    json['profile'] != null ? Profile.fromJson(json['profile']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['message'] = message;
    data['status'] = status;
    if (profile != null) {
      data['profile'] = profile!.toJson();
    }
    return data;
  }
}

class Profile {
  dynamic userId;
  String? userType;
  String? username;
  String? email;
  String? dOB;
  String? contact;
  String? userImage;
  String? gender;
  String? maritalStatus;
  dynamic walletBalance;
  dynamic adminDue;
  Null? occupation;
  dynamic userStatus;
  String? fcmToken;
  String? token;
  bool? isVendor;
  dynamic vendorRevenue;
  dynamic vendorOrderCount;
  VendorCounts? vendorCounts;
  bool? vendorVerify;

  Profile(
      {this.userId,
        this.userType,
        this.username,
        this.email,
        this.dOB,
        this.contact,
        this.userImage,
        this.gender,
        this.maritalStatus,
        this.walletBalance,
        this.adminDue,
        this.occupation,
        this.userStatus,
        this.fcmToken,
        this.token,
        this.isVendor,
        this.vendorRevenue,
        this.vendorOrderCount,
        this.vendorCounts,
        this.vendorVerify});

  Profile.fromJson(Map<String, dynamic> json) {
    userId = json['userId'];
    userType = json['userType'];
    username = json['username'];
    email = json['email'];
    dOB = json['DOB'];
    contact = json['contact'];
    userImage = json['userImage'];
    gender = json['gender'];
    maritalStatus = json['maritalStatus'];
    walletBalance = json['walletBalance'];
    adminDue = json['adminDue'];
    occupation = json['occupation'];
    userStatus = json['userStatus'];
    fcmToken = json['fcmToken'];
    token = json['token'];
    isVendor = json['isVendor'];
    vendorRevenue = json['vendorRevenue'];
    vendorOrderCount = json['vendorOrderCount'];
    vendorCounts = json['vendorCounts'] != null
        ? VendorCounts.fromJson(json['vendorCounts'])
        : null;
    vendorVerify = json['vendorVerify'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['userId'] = userId;
    data['userType'] = userType;
    data['username'] = username;
    data['email'] = email;
    data['DOB'] = dOB;
    data['contact'] = contact;
    data['userImage'] = userImage;
    data['gender'] = gender;
    data['maritalStatus'] = maritalStatus;
    data['walletBalance'] = walletBalance;
    data['adminDue'] = adminDue;
    data['occupation'] = occupation;
    data['userStatus'] = userStatus;
    data['fcmToken'] = fcmToken;
    data['token'] = token;
    data['isVendor'] = isVendor;
    data['vendorRevenue'] = vendorRevenue;
    data['vendorOrderCount'] = vendorOrderCount;
    if (vendorCounts != null) {
      data['vendorCounts'] = vendorCounts!.toJson();
    }
    data['vendorVerify'] = vendorVerify;
    return data;
  }
}

class VendorCounts {
  PaymentStatusWise? paymentStatusWise;
  TimeWise? timeWise;

  VendorCounts({this.paymentStatusWise, this.timeWise});

  VendorCounts.fromJson(Map<String, dynamic> json) {
    paymentStatusWise = json['paymentStatusWise'] != null
        ? PaymentStatusWise.fromJson(json['paymentStatusWise'])
        : null;
    timeWise = json['timeWise'] != null
        ? TimeWise.fromJson(json['timeWise'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (paymentStatusWise != null) {
      data['paymentStatusWise'] = paymentStatusWise!.toJson();
    }
    if (timeWise != null) {
      data['timeWise'] = timeWise!.toJson();
    }
    return data;
  }
}

class PaymentStatusWise {
  dynamic pending;
  dynamic completed;
  dynamic rejected;

  PaymentStatusWise({this.pending, this.completed, this.rejected});

  PaymentStatusWise.fromJson(Map<String, dynamic> json) {
    pending = json['pending'];
    completed = json['completed'];
    rejected = json['rejected'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['pending'] = pending;
    data['completed'] = completed;
    data['rejected'] = rejected;
    return data;
  }
}

class TimeWise {
  dynamic upcoming;
  dynamic currentStay;
  dynamic past;
  dynamic canceled;

  TimeWise({this.upcoming, this.currentStay, this.past, this.canceled});

  TimeWise.fromJson(Map<String, dynamic> json) {
    upcoming = json['upcoming'];
    currentStay = json['currentStay'];
    past = json['past'];
    canceled = json['canceled'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['upcoming'] = upcoming;
    data['currentStay'] = currentStay;
    data['past'] = past;
    data['canceled'] = canceled;
    return data;
  }
}
