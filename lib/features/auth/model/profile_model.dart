class ProfileModel {
  String? message;
  int? status;
  Profile? profile;

  ProfileModel({this.message, this.status, this.profile});

  ProfileModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    status = json['status'];
    profile =
    json['profile'] != null ? new Profile.fromJson(json['profile']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['message'] = this.message;
    data['status'] = this.status;
    if (this.profile != null) {
      data['profile'] = this.profile!.toJson();
    }
    return data;
  }
}

class Profile {
  int? userId;
  String? username;
  String? email;
  String? dOB;
  String? contact;
  String? userImage;
  String? gender;
  String? maritalStatus;
  int? walletBalance;
  dynamic occupation;
  int? userStatus;
  String? fcmToken;
  String? token;
  bool? isVendor;
  int? vendorRevenue;
  int? vendorOrderCount;
  VendorCounts? vendorCounts;

  Profile(
      {this.userId,
        this.username,
        this.email,
        this.dOB,
        this.contact,
        this.userImage,
        this.gender,
        this.maritalStatus,
        this.walletBalance,
        this.occupation,
        this.userStatus,
        this.fcmToken,
        this.token,
        this.isVendor,
        this.vendorRevenue,
        this.vendorOrderCount,
        this.vendorCounts});

  Profile.fromJson(Map<String, dynamic> json) {
    userId = json['userId'];
    username = json['username'];
    email = json['email'];
    dOB = json['DOB'];
    contact = json['contact'];
    userImage = json['userImage'];
    gender = json['gender'];
    maritalStatus = json['maritalStatus'];
    walletBalance = json['walletBalance'];
    occupation = json['occupation'];
    userStatus = json['userStatus'];
    fcmToken = json['fcmToken'];
    token = json['token'];
    isVendor = json['isVendor'];
    vendorRevenue = json['vendorRevenue'];
    vendorOrderCount = json['vendorOrderCount'];
    vendorCounts = json['vendorCounts'] != null
        ? new VendorCounts.fromJson(json['vendorCounts'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['userId'] = this.userId;
    data['username'] = this.username;
    data['email'] = this.email;
    data['DOB'] = this.dOB;
    data['contact'] = this.contact;
    data['userImage'] = this.userImage;
    data['gender'] = this.gender;
    data['maritalStatus'] = this.maritalStatus;
    data['walletBalance'] = this.walletBalance;
    data['occupation'] = this.occupation;
    data['userStatus'] = this.userStatus;
    data['fcmToken'] = this.fcmToken;
    data['token'] = this.token;
    data['isVendor'] = this.isVendor;
    data['vendorRevenue'] = this.vendorRevenue;
    data['vendorOrderCount'] = this.vendorOrderCount;
    if (this.vendorCounts != null) {
      data['vendorCounts'] = this.vendorCounts!.toJson();
    }
    return data;
  }
}

class VendorCounts {
  PaymentStatusWise? paymentStatusWise;
  TimeWise? timeWise;

  VendorCounts({this.paymentStatusWise, this.timeWise});

  VendorCounts.fromJson(Map<String, dynamic> json) {
    paymentStatusWise = json['paymentStatusWise'] != null
        ? new PaymentStatusWise.fromJson(json['paymentStatusWise'])
        : null;
    timeWise = json['timeWise'] != null
        ? new TimeWise.fromJson(json['timeWise'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.paymentStatusWise != null) {
      data['paymentStatusWise'] = this.paymentStatusWise!.toJson();
    }
    if (this.timeWise != null) {
      data['timeWise'] = this.timeWise!.toJson();
    }
    return data;
  }
}

class PaymentStatusWise {
  int? pending;
  int? completed;
  int? rejected;

  PaymentStatusWise({this.pending, this.completed, this.rejected});

  PaymentStatusWise.fromJson(Map<String, dynamic> json) {
    pending = json['pending'];
    completed = json['completed'];
    rejected = json['rejected'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['pending'] = this.pending;
    data['completed'] = this.completed;
    data['rejected'] = this.rejected;
    return data;
  }
}

class TimeWise {
  int? upcoming;
  int? currentStay;
  int? past;
  int? canceled;

  TimeWise({this.upcoming, this.currentStay, this.past, this.canceled});

  TimeWise.fromJson(Map<String, dynamic> json) {
    upcoming = json['upcoming'];
    currentStay = json['currentStay'];
    past = json['past'];
    canceled = json['canceled'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['upcoming'] = this.upcoming;
    data['currentStay'] = this.currentStay;
    data['past'] = this.past;
    data['canceled'] = this.canceled;
    return data;
  }
}
