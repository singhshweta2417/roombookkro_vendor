class CreateSessionModel {
  String? message;
  String? paymentSessionId;
  String? orderId;
  String? paymentLink;
  FullData? fullData;

  CreateSessionModel(
      {this.message,
        this.paymentSessionId,
        this.orderId,
        this.paymentLink,
        this.fullData});

  CreateSessionModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    paymentSessionId = json['payment_session_id'];
    orderId = json['order_id'];
    paymentLink = json['payment_link'];
    fullData = json['full_data'] != null
        ? FullData.fromJson(json['full_data'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['message'] = message;
    data['payment_session_id'] = paymentSessionId;
    data['order_id'] = orderId;
    data['payment_link'] = paymentLink;
    if (fullData != null) {
      data['full_data'] = fullData!.toJson();
    }
    return data;
  }
}

class FullData {
  int? cfOrderId;
  String? createdAt;
  CustomerDetails? customerDetails;
  String? entity;
  int? orderAmount;
  String? orderCurrency;
  String? orderExpiryTime;
  String? orderId;
  OrderMeta? orderMeta;
  String? orderNote;
  String? orderStatus;
  dynamic orderTags;
  String? paymentSessionId;
  Payments? payments;
  Payments? refunds;
  Payments? settlements;
  dynamic terminalData;

  FullData(
      {this.cfOrderId,
        this.createdAt,
        this.customerDetails,
        this.entity,
        this.orderAmount,
        this.orderCurrency,
        this.orderExpiryTime,
        this.orderId,
        this.orderMeta,
        this.orderNote,
        this.orderStatus,
        this.orderTags,
        this.paymentSessionId,
        this.payments,
        this.refunds,
        this.settlements,
        this.terminalData});

  FullData.fromJson(Map<String, dynamic> json) {
    cfOrderId = json['cf_order_id'];
    createdAt = json['created_at'];
    customerDetails = json['customer_details'] != null
        ? CustomerDetails.fromJson(json['customer_details'])
        : null;
    entity = json['entity'];
    orderAmount = json['order_amount'];
    orderCurrency = json['order_currency'];
    orderExpiryTime = json['order_expiry_time'];
    orderId = json['order_id'];
    orderMeta = json['order_meta'] != null
        ? OrderMeta.fromJson(json['order_meta'])
        : null;
    orderNote = json['order_note'];
    orderStatus = json['order_status'];
    orderTags = json['order_tags'];
    paymentSessionId = json['payment_session_id'];
    payments = json['payments'] != null
        ? Payments.fromJson(json['payments'])
        : null;
    refunds =
    json['refunds'] != null ? Payments.fromJson(json['refunds']) : null;
    settlements = json['settlements'] != null
        ? Payments.fromJson(json['settlements'])
        : null;
    terminalData = json['terminal_data'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['cf_order_id'] = cfOrderId;
    data['created_at'] = createdAt;
    if (customerDetails != null) {
      data['customer_details'] = customerDetails!.toJson();
    }
    data['entity'] = entity;
    data['order_amount'] = orderAmount;
    data['order_currency'] = orderCurrency;
    data['order_expiry_time'] = orderExpiryTime;
    data['order_id'] = orderId;
    if (orderMeta != null) {
      data['order_meta'] = orderMeta!.toJson();
    }
    data['order_note'] = orderNote;

    data['order_status'] = orderStatus;
    data['order_tags'] = orderTags;
    data['payment_session_id'] = paymentSessionId;
    if (payments != null) {
      data['payments'] = payments!.toJson();
    }
    if (refunds != null) {
      data['refunds'] = refunds!.toJson();
    }
    if (settlements != null) {
      data['settlements'] = settlements!.toJson();
    }
    data['terminal_data'] = terminalData;
    return data;
  }
}

class CustomerDetails {
  String? customerId;
  dynamic customerName;
  String? customerEmail;
  String? customerPhone;
  dynamic customerUid;

  CustomerDetails(
      {this.customerId,
        this.customerName,
        this.customerEmail,
        this.customerPhone,
        this.customerUid});

  CustomerDetails.fromJson(Map<String, dynamic> json) {
    customerId = json['customer_id'];
    customerName = json['customer_name'];
    customerEmail = json['customer_email'];
    customerPhone = json['customer_phone'];
    customerUid = json['customer_uid'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['customer_id'] = customerId;
    data['customer_name'] = customerName;
    data['customer_email'] = customerEmail;
    data['customer_phone'] = customerPhone;
    data['customer_uid'] = customerUid;
    return data;
  }
}

class OrderMeta {
  String? returnUrl;
  String? notifyUrl;
  dynamic paymentMethods;

  OrderMeta({this.returnUrl, this.notifyUrl, this.paymentMethods});

  OrderMeta.fromJson(Map<String, dynamic> json) {
    returnUrl = json['return_url'];
    notifyUrl = json['notify_url'];
    paymentMethods = json['payment_methods'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['return_url'] = returnUrl;
    data['notify_url'] = notifyUrl;
    data['payment_methods'] = paymentMethods;
    return data;
  }
}

class Payments {
  String? url;

  Payments({this.url});

  Payments.fromJson(Map<String, dynamic> json) {
    url = json['url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['url'] = url;
    return data;
  }
}
