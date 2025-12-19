class CreateSessionModel {
  bool? status;
  String? message;
  Data? data;

  CreateSessionModel({this.status, this.message, this.data});

  CreateSessionModel.fromJson(Map<String, dynamic> json) {
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
  String? paymentSessionId;
  String? orderId;
  dynamic amount;

  Data({this.paymentSessionId, this.orderId, this.amount});

  Data.fromJson(Map<String, dynamic> json) {
    paymentSessionId = json['payment_session_id'];
    orderId = json['order_id'];
    amount = json['amount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['payment_session_id'] = paymentSessionId;
    data['order_id'] = orderId;
    data['amount'] = amount;
    return data;
  }
}
