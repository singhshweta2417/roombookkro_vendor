class StaticsModel {
  dynamic status;
  String? vendorId;
  dynamic year;
  dynamic totalVendorRevenue;
  List<MonthData>? months;

  StaticsModel({
    this.status,
    this.vendorId,
    this.year,
    this.totalVendorRevenue,
    this.months,
  });

  factory StaticsModel.fromJson(Map<String, dynamic> json) {
    return StaticsModel(
      status: json['status'],
      vendorId: json['vendorId'],
      year: json['year'],
      totalVendorRevenue: json['totalVendorRevenue'],
      months: json['months'] != null
          ? (json['months'] as List).map((e) => MonthData.fromJson(e)).toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'vendorId': vendorId,
      'year': year,
      'totalVendorRevenue': totalVendorRevenue,
      'months': months?.map((e) => e.toJson()).toList(),
    };
  }
}

class MonthData {
  String? key;
  MonthDetails? details;

  MonthData({this.key, this.details});

  factory MonthData.fromJson(Map<String, dynamic> json) {
    String monthKey = json.keys.first;
    return MonthData(
      key: monthKey,
      details: MonthDetails.fromJson(json[monthKey]),
    );
  }

  Map<String, dynamic> toJson() {
    return {key!: details!.toJson()};
  }
}

class MonthDetails {
  String? month;
  dynamic vendorRevenue;
  dynamic commission;
  dynamic totalAmount;

  MonthDetails({
    this.month,
    this.vendorRevenue,
    this.commission,
    this.totalAmount,
  });

  factory MonthDetails.fromJson(Map<String, dynamic> json) {
    return MonthDetails(
      month: json['month'],
      vendorRevenue: json['vendorRevenue'],
      commission: json['commission'],
      totalAmount: json['totalAmount'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'month': month,
      'vendorRevenue': vendorRevenue,
      'commission': commission,
      'totalAmount': totalAmount,
    };
  }
}
