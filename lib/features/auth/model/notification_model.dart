class NotificationModel {
  bool? status;
  String? msg;
  int? total;
  List<Data>? data;

  NotificationModel({this.status, this.msg, this.total, this.data});

  NotificationModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    msg = json['msg'];
    total = json['total'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['msg'] = msg;
    data['total'] = total;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  String? type;
  String? orderId;
  String? userId;
  int? residencyId;
  String? checkInDate;
  String? checkOutDate;
  int? totalAmount;
  int? finalAmount;
  String? cupponCode;
  int? paymentStatus;
  String? bookingFor;
  int? nog;
  bool? isChildren;
  int? childrenNumber;
  String? createdAt;
  String? sId;
  String? label;
  String? description;
  bool? isGlobal;
  int? iV;
  String? code;
  String? discountType;
  int? discountValue;
  int? minOrderAmount;
  dynamic expiresAt;

  Data(
      {this.type,
        this.orderId,
        this.userId,
        this.residencyId,
        this.checkInDate,
        this.checkOutDate,
        this.totalAmount,
        this.finalAmount,
        this.cupponCode,
        this.paymentStatus,
        this.bookingFor,
        this.nog,
        this.isChildren,
        this.childrenNumber,
        this.createdAt,
        this.sId,
        this.label,
        this.description,
        this.isGlobal,
        this.iV,
        this.code,
        this.discountType,
        this.discountValue,
        this.minOrderAmount,
        this.expiresAt});

  Data.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    orderId = json['orderId'];
    userId = json['userId'];
    residencyId = json['residencyId'];
    checkInDate = json['checkInDate'];
    checkOutDate = json['checkOutDate'];
    totalAmount = json['totalAmount'];
    finalAmount = json['finalAmount'];
    cupponCode = json['cupponCode'];
    paymentStatus = json['paymentStatus'];
    bookingFor = json['bookingFor'];
    nog = json['nog'];
    isChildren = json['isChildren'];
    childrenNumber = json['childrenNumber'];
    createdAt = json['createdAt'];
    sId = json['_id'];
    label = json['label'];
    description = json['description'];
    isGlobal = json['isGlobal'];
    iV = json['__v'];
    code = json['code'];
    discountType = json['discountType'];
    discountValue = json['discountValue'];
    minOrderAmount = json['minOrderAmount'];
    expiresAt = json['expiresAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['type'] = type;
    data['orderId'] = orderId;
    data['userId'] = userId;
    data['residencyId'] = residencyId;
    data['checkInDate'] = checkInDate;
    data['checkOutDate'] = checkOutDate;
    data['totalAmount'] = totalAmount;
    data['finalAmount'] = finalAmount;
    data['cupponCode'] = cupponCode;
    data['paymentStatus'] = paymentStatus;
    data['bookingFor'] = bookingFor;
    data['nog'] = nog;
    data['isChildren'] = isChildren;
    data['childrenNumber'] = childrenNumber;
    data['createdAt'] = createdAt;
    data['_id'] = sId;
    data['label'] = label;
    data['description'] = description;
    data['isGlobal'] = isGlobal;
    data['__v'] = iV;
    data['code'] = code;
    data['discountType'] = discountType;
    data['discountValue'] = discountValue;
    data['minOrderAmount'] = minOrderAmount;
    data['expiresAt'] = expiresAt;
    return data;
  }
}
