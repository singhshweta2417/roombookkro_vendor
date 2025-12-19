class DepositHistoryModel {
  bool? status;
  String? message;
  Data? data;

  DepositHistoryModel({this.status, this.message, this.data});

  DepositHistoryModel.fromJson(Map<String, dynamic> json) {
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
  List<Transactions>? transactions;
  int? totalPages;
  int? currentPage;
  int? totalTransactions;

  Data(
      {this.transactions,
        this.totalPages,
        this.currentPage,
        this.totalTransactions});

  Data.fromJson(Map<String, dynamic> json) {
    if (json['transactions'] != null) {
      transactions = <Transactions>[];
      json['transactions'].forEach((v) {
        transactions!.add(Transactions.fromJson(v));
      });
    }
    totalPages = json['totalPages'];
    currentPage = json['currentPage'];
    totalTransactions = json['totalTransactions'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (transactions != null) {
      data['transactions'] = transactions!.map((v) => v.toJson()).toList();
    }
    data['totalPages'] = totalPages;
    data['currentPage'] = currentPage;
    data['totalTransactions'] = totalTransactions;
    return data;
  }
}

class Transactions {
  String? sId;
  int? userId;
  int? amount;
  String? orderId;
  String? paymentStatus;
  int? paymentGatewayStatus;
  String? createdAt;
  String? updatedAt;
  int? iV;
  String? transactionType;
  String? paymentMethod;
  String? description;
  int? bankId;
  Null? bankDetails;
  String? adminNote;
  String? processedAt;
  String? paymentTime;
  String? transactionId;

  Transactions(
      {this.sId,
        this.userId,
        this.amount,
        this.orderId,
        this.paymentStatus,
        this.paymentGatewayStatus,
        this.createdAt,
        this.updatedAt,
        this.iV,
        this.transactionType,
        this.paymentMethod,
        this.description,
        this.bankId,
        this.bankDetails,
        this.adminNote,
        this.processedAt,
        this.paymentTime,
        this.transactionId});

  Transactions.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    userId = json['userId'];
    amount = json['amount'];
    orderId = json['orderId'];
    paymentStatus = json['paymentStatus'];
    paymentGatewayStatus = json['paymentGatewayStatus'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
    transactionType = json['transactionType'];
    paymentMethod = json['paymentMethod'];
    description = json['description'];
    bankId = json['bankId'];
    bankDetails = json['bankDetails'];
    adminNote = json['adminNote'];
    processedAt = json['processedAt'];
    paymentTime = json['paymentTime'];
    transactionId = json['transactionId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['userId'] = userId;
    data['amount'] = amount;
    data['orderId'] = orderId;
    data['paymentStatus'] = paymentStatus;
    data['paymentGatewayStatus'] = paymentGatewayStatus;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['__v'] = iV;
    data['transactionType'] = transactionType;
    data['paymentMethod'] = paymentMethod;
    data['description'] = description;
    data['bankId'] = bankId;
    data['bankDetails'] = bankDetails;
    data['adminNote'] = adminNote;
    data['processedAt'] = processedAt;
    data['paymentTime'] = paymentTime;
    data['transactionId'] = transactionId;
    return data;
  }
}
