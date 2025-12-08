class OrderHistoryModel {
  final bool status;
  final String msg;
  final OrderHistoryData data;

  OrderHistoryModel({
    required this.status,
    required this.msg,
    required this.data,
  });

  factory OrderHistoryModel.fromJson(Map<String, dynamic> json) =>
      OrderHistoryModel(
        status: json['status'],
        msg: json['msg'],
        data: OrderHistoryData.fromJson(json['data']),
      );

  Map<String, dynamic> toJson() => {
    'status': status,
    'msg': msg,
    'data': data.toJson(),
  };
}

class OrderHistoryData {
  final PaymentStatusWise paymentStatusWise;
  final TimeWise timeWise;

  OrderHistoryData({
    required this.paymentStatusWise,
    required this.timeWise,
  });

  factory OrderHistoryData.fromJson(Map<String, dynamic> json) =>
      OrderHistoryData(
        paymentStatusWise:
        PaymentStatusWise.fromJson(json['paymentStatusWise']),
        timeWise: TimeWise.fromJson(json['timeWise']),
      );

  Map<String, dynamic> toJson() => {
    'paymentStatusWise': paymentStatusWise.toJson(),
    'timeWise': timeWise.toJson(),
  };
}

class PaymentStatusWise {
  final List<Order> pending;
  final List<Order> completed;
  final List<Order> rejected;

  PaymentStatusWise({
    required this.pending,
    required this.completed,
    required this.rejected,
  });

  factory PaymentStatusWise.fromJson(Map<String, dynamic> json) =>
      PaymentStatusWise(
        pending:
        List<Order>.from(json['pending'].map((x) => Order.fromJson(x))),
        completed:
        List<Order>.from(json['completed'].map((x) => Order.fromJson(x))),
        rejected:
        List<Order>.from(json['rejected'].map((x) => Order.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
    'pending': pending.map((x) => x.toJson()).toList(),
    'completed': completed.map((x) => x.toJson()).toList(),
    'rejected': rejected.map((x) => x.toJson()).toList(),
  };
}

class TimeWise {
  final List<Order> upcoming;
  final List<Order> currentStay;
  final List<Order> past;
  final List<Order> cancelled;

  TimeWise({
    required this.upcoming,
    required this.currentStay,
    required this.past,
    required this.cancelled,
  });

  factory TimeWise.fromJson(Map<String, dynamic> json) => TimeWise(
    upcoming:
    List<Order>.from(json['upcoming'].map((x) => Order.fromJson(x))),
    currentStay:
    List<Order>.from(json['currentStay'].map((x) => Order.fromJson(x))),
    past: List<Order>.from(json['past'].map((x) => Order.fromJson(x))),
    cancelled:
    List<Order>.from(json['canceled'].map((x) => Order.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    'upcoming': upcoming.map((x) => x.toJson()).toList(),
    'currentStay': currentStay.map((x) => x.toJson()).toList(),
    'past': past.map((x) => x.toJson()).toList(),
    'canceled': cancelled.map((x) => x.toJson()).toList(),
  };
}

class Order {
  final dynamic isChildren;
  final dynamic childrenNumber;
  final dynamic id;
  final dynamic userId;
  final dynamic residencyId;
  final dynamic roomId;
  final dynamic nor;
  final dynamic checkInDate;
  final dynamic checkOutDate;
  final dynamic totalAmount;
  final dynamic status;
  final dynamic nog;
  final dynamic bookingFor;
  final dynamic discount;
  final dynamic finalAmount;
  final dynamic cupponCode;
  final dynamic paymentMethod;
  final dynamic orderId;
  final dynamic paymentStatus;
  final dynamic createdAt;
  final dynamic v;
  final dynamic residencyName;
  final dynamic roomType;
  final dynamic residencyImage;
  final dynamic contactNumber;
  final Coordinates? coordinates;
  final dynamic address;
  final dynamic userName;
  final dynamic userEmail;
  final dynamic userPhone;

  Order({
    this.isChildren,
    this.childrenNumber,
    this.id,
    this.userId,
    this.residencyId,
    this.roomId,
    this.nor,
    this.checkInDate,
    this.checkOutDate,
    this.totalAmount,
    this.status,
    this.nog,
    this.bookingFor,
    this.discount,
    this.finalAmount,
    this.cupponCode,
    this.paymentMethod,
    this.orderId,
    this.paymentStatus,
    this.createdAt,
    this.v,
    this.residencyName,
    this.roomType,
    this.residencyImage,
    this.contactNumber,
    this.coordinates,
    this.address,
    this.userName,
    this.userEmail,
    this.userPhone,
  });

  factory Order.fromJson(Map<String, dynamic> json) => Order(
    isChildren: json['isChildren'],
    childrenNumber: json['childrenNumber'],
    id: json['_id'],
    userId: json['userId'],
    residencyId: json['residencyId'],
    roomId: json['roomId'],
    nor: json['nor'],
    checkInDate: json['checkInDate'],
    checkOutDate: json['checkOutDate'],
    totalAmount: json['totalAmount'],
    status: json['status'],
    nog: json['nog'],
    bookingFor: json['bookingFor'],
    discount: json['discount'],
    finalAmount: json['finalAmount'],
    cupponCode: json['cupponCode'],
    paymentMethod: json['paymentMethod'],
    orderId: json['orderId'],
    paymentStatus: json['paymentStatus'],
    createdAt: json['createdAt'],
    v: json['__v'],
    residencyName: json['residencyName'],
    roomType: json['roomType'],
    residencyImage: json['residencyImage'],
    contactNumber: json['contactNumber'],
    coordinates: json['coordinates'] != null
        ? Coordinates.fromJson(json['coordinates'])
        : null,
    address: json['address'],
    userName: json['userName'],
    userEmail: json['userEmail'],
    userPhone: json['userPhone'],
  );

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'isChildren': isChildren,
      'childrenNumber': childrenNumber,
      '_id': id,
      'userId': userId,
      'residencyId': residencyId,
      'roomId': roomId,
      'nor': nor,
      'checkInDate': checkInDate,
      'checkOutDate': checkOutDate,
      'totalAmount': totalAmount,
      'status': status,
      'nog': nog,
      'bookingFor': bookingFor,
      'discount': discount,
      'finalAmount': finalAmount,
      'cupponCode': cupponCode,
      'paymentMethod': paymentMethod,
      'orderId': orderId,
      'paymentStatus': paymentStatus,
      'createdAt': createdAt,
      '__v': v,
      'residencyName': residencyName,
      'roomType': roomType,
      'residencyImage': residencyImage,
      'contactNumber': contactNumber,
      'address': address,
      'userName': userName,
      'userEmail': userEmail,
      'userPhone': userPhone,
    };

    if (coordinates != null) {
      data['coordinates'] = coordinates!.toJson();
    }
    return data;
  }
}

class Coordinates {
  final dynamic lat;
  final dynamic lng;

  Coordinates({this.lat, this.lng});

  factory Coordinates.fromJson(Map<String, dynamic> json) => Coordinates(
    lat: json['lat'],
    lng: json['lng'],
  );

  Map<String, dynamic> toJson() => {
    'lat': lat,
    'lng': lng,
  };
}
