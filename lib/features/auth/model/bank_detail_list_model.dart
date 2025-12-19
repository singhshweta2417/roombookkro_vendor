class BankDetailsListModel {
  bool? status;
  String? message;
  Data? data;

  BankDetailsListModel({this.status, this.message, this.data});

  BankDetailsListModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  int? userId;
  int? totalAccounts;
  List<BankDetails>? bankDetails;

  Data({this.userId, this.totalAccounts, this.bankDetails});

  Data.fromJson(Map<String, dynamic> json) {
    userId = json['userId'];
    totalAccounts = json['totalAccounts'];
    if (json['bankDetails'] != null) {
      bankDetails = <BankDetails>[];
      json['bankDetails'].forEach((v) {
        bankDetails!.add(BankDetails.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['userId'] = userId;
    data['totalAccounts'] = totalAccounts;
    if (bankDetails != null) {
      data['bankDetails'] = bankDetails!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class BankDetails {
  String? sId;
  int? userId;
  String? accountHolderName;
  String? accountNumber;
  String? ifscCode;
  String? bankName;
  String? branchName;
  String? accountType;
  bool? isDefault;
  bool? isActive;
  bool? isVerified;
  String? createdAt;
  String? updatedAt;
  int? bankId;
  int? iV;
  String? verifiedAt;

  BankDetails(
      {this.sId,
        this.userId,
        this.accountHolderName,
        this.accountNumber,
        this.ifscCode,
        this.bankName,
        this.branchName,
        this.accountType,
        this.isDefault,
        this.isActive,
        this.isVerified,
        this.createdAt,
        this.updatedAt,
        this.bankId,
        this.iV,
        this.verifiedAt});

  BankDetails.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    userId = json['userId'];
    accountHolderName = json['accountHolderName'];
    accountNumber = json['accountNumber'];
    ifscCode = json['ifscCode'];
    bankName = json['bankName'];
    branchName = json['branchName'];
    accountType = json['accountType'];
    isDefault = json['isDefault'];
    isActive = json['isActive'];
    isVerified = json['isVerified'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    bankId = json['bankId'];
    iV = json['__v'];
    verifiedAt = json['verifiedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['userId'] = userId;
    data['accountHolderName'] = accountHolderName;
    data['accountNumber'] = accountNumber;
    data['ifscCode'] = ifscCode;
    data['bankName'] = bankName;
    data['branchName'] = branchName;
    data['accountType'] = accountType;
    data['isDefault'] = isDefault;
    data['isActive'] = isActive;
    data['isVerified'] = isVerified;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['bankId'] = bankId;
    data['__v'] = iV;
    data['verifiedAt'] = verifiedAt;
    return data;
  }
}
