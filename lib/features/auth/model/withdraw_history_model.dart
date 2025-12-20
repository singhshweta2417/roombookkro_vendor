class WithdrawHistoryModel {
  bool? status;
  String? message;
  Data? data;

  WithdrawHistoryModel({this.status, this.message, this.data});

  WithdrawHistoryModel.fromJson(Map<String, dynamic> json) {
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
  List<Withdrawals>? withdrawals;
  int? totalPages;
  int? currentPage;
  int? totalRecords;
  Summary? summary;

  Data(
      {this.withdrawals,
        this.totalPages,
        this.currentPage,
        this.totalRecords,
        this.summary});

  Data.fromJson(Map<String, dynamic> json) {
    if (json['withdrawals'] != null) {
      withdrawals = <Withdrawals>[];
      json['withdrawals'].forEach((v) {
        withdrawals!.add(Withdrawals.fromJson(v));
      });
    }
    totalPages = json['totalPages'];
    currentPage = json['currentPage'];
    totalRecords = json['totalRecords'];
    summary =
    json['summary'] != null ? Summary.fromJson(json['summary']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (withdrawals != null) {
      data['withdrawals'] = withdrawals!.map((v) => v.toJson()).toList();
    }
    data['totalPages'] = totalPages;
    data['currentPage'] = currentPage;
    data['totalRecords'] = totalRecords;
    if (summary != null) {
      data['summary'] = summary!.toJson();
    }
    return data;
  }
}

class Withdrawals {
  String? sId;
  int? userId;
  String? orderId;
  int? amount;
  String? transactionType;
  String? paymentMethod;
  String? paymentStatus;
  int? paymentGatewayStatus;
  String? description;
  int? bankId;
  BankDetailsWithdraw? bankDetails;
  String? adminNote;
  String? processedAt;
  String? createdAt;
  String? updatedAt;
  int? iV;

  Withdrawals(
      {this.sId,
        this.userId,
        this.orderId,
        this.amount,
        this.transactionType,
        this.paymentMethod,
        this.paymentStatus,
        this.paymentGatewayStatus,
        this.description,
        this.bankId,
        this.bankDetails,
        this.adminNote,
        this.processedAt,
        this.createdAt,
        this.updatedAt,
        this.iV});

  Withdrawals.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    userId = json['userId'];
    orderId = json['orderId'];
    amount = json['amount'];
    transactionType = json['transactionType'];
    paymentMethod = json['paymentMethod'];
    paymentStatus = json['paymentStatus'];
    paymentGatewayStatus = json['paymentGatewayStatus'];
    description = json['description'];
    bankId = json['bankId'];
    bankDetails = json['bankDetails'] != null
        ? BankDetailsWithdraw.fromJson(json['bankDetails'])
        : null;
    adminNote = json['adminNote'];
    processedAt = json['processedAt'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['userId'] = userId;
    data['orderId'] = orderId;
    data['amount'] = amount;
    data['transactionType'] = transactionType;
    data['paymentMethod'] = paymentMethod;
    data['paymentStatus'] = paymentStatus;
    data['paymentGatewayStatus'] = paymentGatewayStatus;
    data['description'] = description;
    data['bankId'] = bankId;
    if (bankDetails != null) {
      data['bankDetails'] = bankDetails!.toJson();
    }
    data['adminNote'] = adminNote;
    data['processedAt'] = processedAt;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['__v'] = iV;
    return data;
  }
}

class BankDetailsWithdraw {
  int? bankId;
  String? accountHolderName;
  String? bankName;
  String? accountNumber;

  BankDetailsWithdraw(
      {this.bankId, this.accountHolderName, this.bankName, this.accountNumber});

  BankDetailsWithdraw.fromJson(Map<String, dynamic> json) {
    bankId = json['bankId'];
    accountHolderName = json['accountHolderName'];
    bankName = json['bankName'];
    accountNumber = json['accountNumber'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['bankId'] = bankId;
    data['accountHolderName'] = accountHolderName;
    data['bankName'] = bankName;
    data['accountNumber'] = accountNumber;
    return data;
  }
}

class Summary {
  int? totalWithdrawn;
  int? totalPending;

  Summary({this.totalWithdrawn, this.totalPending});

  Summary.fromJson(Map<String, dynamic> json) {
    totalWithdrawn = json['totalWithdrawn'];
    totalPending = json['totalPending'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['totalWithdrawn'] = totalWithdrawn;
    data['totalPending'] = totalPending;
    return data;
  }
}
