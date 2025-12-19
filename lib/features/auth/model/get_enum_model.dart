class GetEnumModel {
  bool? status;
  String? msg;
  Data? data;

  GetEnumModel({this.status, this.msg, this.data});

  GetEnumModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    msg = json['msg'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['msg'] = msg;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  FurnishedTypeData? furnishedType;
  PriceRangeData? priceRange;
  RatingData? rating;
  PropertyTypeData? propertyType;
  RoomTypeData? roomType;

  Data({
    this.furnishedType,
    this.priceRange,
    this.rating,
    this.propertyType,
    this.roomType,
  });

  Data.fromJson(Map<String, dynamic> json) {
    furnishedType = json['Furnished Type'] != null
        ? FurnishedTypeData.fromJson(json['Furnished Type'])
        : null;
    priceRange = json['Price Range'] != null
        ? PriceRangeData.fromJson(json['Price Range'])
        : null;
    rating = json['Rating'] != null
        ? RatingData.fromJson(json['Rating'])
        : null;
    propertyType = json['Property Type'] != null
        ? PropertyTypeData.fromJson(json['Property Type'])
        : null;
    roomType = json['Room Type'] != null
        ? RoomTypeData.fromJson(json['Room Type'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (furnishedType != null) {
      data['Furnished Type'] = furnishedType!.toJson();
    }
    if (priceRange != null) {
      data['Price Range'] = priceRange!.toJson();
    }
    if (rating != null) {
      data['Rating'] = rating!.toJson();
    }
    if (propertyType != null) {
      data['Property Type'] = propertyType!.toJson();
    }
    if (roomType != null) {
      data['Room Type'] = roomType!.toJson();
    }
    return data;
  }
}

class FurnishedTypeData {
  String? type;
  List<FurnishedOption>? options;

  FurnishedTypeData({this.type, this.options});

  FurnishedTypeData.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    if (json['options'] != null) {
      options = <FurnishedOption>[];
      json['options'].forEach((v) {
        options!.add(FurnishedOption.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['type'] = type;
    if (options != null) {
      data['options'] = options!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class FurnishedOption {
  dynamic id;
  bool? isActive;
  String? label;
  String? value;
  String? sId;

  FurnishedOption({this.isActive, this.label, this.value, this.sId});

  FurnishedOption.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    isActive = json['isActive'];
    label = json['label'];
    value = json['value'];
    sId = json['_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['isActive'] = isActive;
    data['label'] = label;
    data['value'] = value;
    data['_id'] = sId;
    return data;
  }

}

class RatingData {
  String? type;
  List<RatingOption>? options;

  RatingData({this.type, this.options});

  RatingData.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    if (json['options'] != null) {
      options = <RatingOption>[];
      json['options'].forEach((v) {
        options!.add(RatingOption.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['type'] = type;
    if (options != null) {
      data['options'] = options!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class RatingOption {
  bool? isActive;
  String? label;
  String? value;
  String? sId;

  RatingOption({this.isActive, this.label, this.value, this.sId});

  RatingOption.fromJson(Map<String, dynamic> json) {
    isActive = json['isActive'];
    label = json['label'];
    value = json['value'];
    sId = json['_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['isActive'] = isActive;
    data['label'] = label;
    data['value'] = value;
    data['_id'] = sId;
    return data;
  }
}

class PriceRangeData {
  String? type;
  Range? range;

  PriceRangeData({this.type, this.range});

  PriceRangeData.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    range = json['range'] != null ? Range.fromJson(json['range']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['type'] = type;
    if (range != null) {
      data['range'] = range!.toJson();
    }
    return data;
  }
}

class Range {
  dynamic min;
  dynamic max;

  Range({this.min, this.max});

  Range.fromJson(Map<String, dynamic> json) {
    min = json['min'];
    max = json['max'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['min'] = min;
    data['max'] = max;
    return data;
  }
}

class PropertyTypeData {
  String? type;
  List<PropertyTypeOption>? options;

  PropertyTypeData({this.type, this.options});

  PropertyTypeData.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    if (json['options'] != null) {
      options = <PropertyTypeOption>[];
      json['options'].forEach((v) {
        options!.add(PropertyTypeOption.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['type'] = type;
    if (options != null) {
      data['options'] = options!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class PropertyTypeOption {
  bool? isActive;
  dynamic id;
  String? label;
  String? value;
  String? sId;

  PropertyTypeOption({
    this.isActive,
    this.id,
    this.label,
    this.value,
    this.sId,
  });

  PropertyTypeOption.fromJson(Map<String, dynamic> json) {
    isActive = json['isActive'];
    id = json['id'];
    label = json['label'];
    value = json['value'];
    sId = json['_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['isActive'] = isActive;
    data['id'] = id;
    data['label'] = label;
    data['value'] = value;
    data['_id'] = sId;
    return data;
  }
}

class RoomTypeData {
  String? type;
  List<RoomTypeOption>? options;

  RoomTypeData({this.type, this.options});

  RoomTypeData.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    if (json['options'] != null) {
      options = <RoomTypeOption>[];
      json['options'].forEach((v) {
        options!.add(RoomTypeOption.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['type'] = type;
    if (options != null) {
      data['options'] = options!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class RoomTypeOption {
  dynamic id;
  String? label;
  String? value;
  dynamic type;
  bool? isActive;
  String? sId;

  RoomTypeOption({
    this.id,
    this.label,
    this.value,
    this.type,
    this.isActive,
    this.sId,
  });

  RoomTypeOption.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    label = json['label'];
    value = json['value'];
    type = json['type'];
    isActive = json['isActive'];
    sId = json['_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['label'] = label;
    data['value'] = value;
    data['type'] = type;
    data['isActive'] = isActive;
    data['_id'] = sId;
    return data;
  }
}