class AddPropertyListModel {
  bool? success;
  dynamic propertyCount;
  dynamic overallRoomCount;
  dynamic availablePropertiesCount;
  dynamic verifiedPropertiesCount;
  List<AddPropertyListData>? data;

  AddPropertyListModel({
    this.success,
    this.propertyCount,
    this.overallRoomCount,
    this.availablePropertiesCount,
    this.verifiedPropertiesCount,
    this.data,
  });

  AddPropertyListModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    propertyCount = json['propertyCount'];
    overallRoomCount = json['overallRoomCount'];
    availablePropertiesCount = json['availablePropertiesCount'];
    verifiedPropertiesCount = json['verifiedPropertiesCount'];
    if (json['data'] != null) {
      data = <AddPropertyListData>[];
      json['data'].forEach((v) {
        data!.add(AddPropertyListData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    data['propertyCount'] = propertyCount;
    data['overallRoomCount'] = overallRoomCount;
    data['availablePropertiesCount'] = availablePropertiesCount;
    data['verifiedPropertiesCount'] = verifiedPropertiesCount;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class AddPropertyListData {
  dynamic sId;
  dynamic userId;
  dynamic userType;
  dynamic residencyId;
  dynamic name;
  dynamic type;
  dynamic address;
  dynamic city;
  dynamic state;
  dynamic pincode;
  Coordinates? coordinates;
  dynamic mainImage;
  List<String>? images;
  dynamic pricePerNight;
  dynamic pricePerMonth;
  dynamic propertyTypeId;
  dynamic pricePerDay;
  dynamic depositAmount;
  List<Rooms>? rooms;
  List<Amenities>? amenities;
  List<String>? rules;
  dynamic contactNumber;
  dynamic email;
  dynamic website;
  dynamic rating;
  List<Reviews>? reviews;
  bool? verifyProperty;
  dynamic commision;
  dynamic description;
  dynamic availableRooms;
  bool? isAvailable;
  dynamic owner;
  dynamic role;
  dynamic discount;
  dynamic additionalAddress;
  dynamic oldMrp;
  dynamic tax;
  dynamic createdAt;
  dynamic iV;
  dynamic totalRooms;

  AddPropertyListData({
    this.sId,
    this.userId,
    this.userType,
    this.residencyId,
    this.name,
    this.type,
    this.address,
    this.city,
    this.state,
    this.pincode,
    this.coordinates,
    this.mainImage,
    this.images,
    this.pricePerNight,
    this.pricePerMonth,
    this.pricePerDay,
    this.depositAmount,
    this.rooms,
    this.amenities,
    this.rules,
    this.contactNumber,
    this.propertyTypeId,
    this.email,
    this.website,
    this.rating,
    this.reviews,
    this.verifyProperty,
    this.commision,
    this.description,
    this.availableRooms,
    this.isAvailable,
    this.owner,
    this.role,
    this.discount,
    this.additionalAddress,
    this.oldMrp,
    this.tax,
    this.createdAt,
    this.iV,
    this.totalRooms,
  });

  AddPropertyListData.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    userId = json['userId'];
    userType = json['userType'];
    residencyId = json['residencyId'];
    name = json['name'];
    type = json['type'];
    address = json['address'];
    city = json['city'];
    state = json['state'];
    propertyTypeId = json['propertyTypeId'];
    pincode = json['pincode'];
    coordinates = json['coordinates'] != null
        ? Coordinates.fromJson(json['coordinates'])
        : null;
    mainImage = json['mainImage'];
    images = json['images'].cast<String>();
    pricePerNight = json['pricePerNight'];
    pricePerMonth = json['pricePerMonth'];
    pricePerDay = json['pricePerDay'];
    depositAmount = json['depositAmount'];
    if (json['rooms'] != null) {
      rooms = <Rooms>[];
      json['rooms'].forEach((v) {
        rooms!.add(Rooms.fromJson(v));
      });
    }
    if (json['amenities'] != null) {
      amenities = <Amenities>[];
      json['amenities'].forEach((v) {
        amenities!.add(Amenities.fromJson(v));
      });
    }
    rules = json['rules'].cast<String>();
    contactNumber = json['contactNumber'];
    email = json['email'];
    website = json['website'];
    rating = json['rating'];
    if (json['reviews'] != null) {
      reviews = <Reviews>[];
      json['reviews'].forEach((v) {
        reviews!.add(Reviews.fromJson(v));
      });
    }
    verifyProperty = json['verifyProperty'];
    commision = json['commision'];
    description = json['description'];
    availableRooms = json['availableRooms'];
    isAvailable = json['isAvailable'];
    owner = json['owner'];
    role = json['role'];
    discount = json['discount'];
    additionalAddress = json['additionalAddress'];
    oldMrp = json['oldMrp'];
    tax = json['tax'];
    createdAt = json['createdAt'];
    iV = json['__v'];
    totalRooms = json['totalRooms'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['userId'] = userId;
    data['userType'] = userType;
    data['residencyId'] = residencyId;
    data['name'] = name;
    data['type'] = type;
    data['address'] = address;
    data['city'] = city;
    data['propertyTypeId'] = propertyTypeId;
    data['state'] = state;
    data['pincode'] = pincode;
    if (coordinates != null) {
      data['coordinates'] = coordinates!.toJson();
    }
    data['mainImage'] = mainImage;
    data['images'] = images;
    data['pricePerNight'] = pricePerNight;
    data['pricePerMonth'] = pricePerMonth;
    data['pricePerDay'] = pricePerDay;
    data['depositAmount'] = depositAmount;
    if (rooms != null) {
      data['rooms'] = rooms!.map((v) => v.toJson()).toList();
    }
    if (amenities != null) {
      data['amenities'] = amenities!.map((v) => v.toJson()).toList();
    }
    data['rules'] = rules;
    data['contactNumber'] = contactNumber;
    data['email'] = email;
    data['website'] = website;
    data['rating'] = rating;
    if (reviews != null) {
      data['reviews'] = reviews!.map((v) => v.toJson()).toList();
    }
    data['verifyProperty'] = verifyProperty;
    data['commision'] = commision;
    data['description'] = description;
    data['availableRooms'] = availableRooms;
    data['isAvailable'] = isAvailable;
    data['owner'] = owner;
    data['role'] = role;
    data['discount'] = discount;
    data['additionalAddress'] = additionalAddress;
    data['oldMrp'] = oldMrp;
    data['tax'] = tax;
    data['createdAt'] = createdAt;
    data['__v'] = iV;
    data['totalRooms'] = totalRooms;
    return data;
  }
}

class Coordinates {
  dynamic lat;
  dynamic lng;

  Coordinates({this.lat, this.lng});

  Coordinates.fromJson(Map<String, dynamic> json) {
    lat = json['lat'];
    lng = json['lng'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['lat'] = lat;
    data['lng'] = lng;
    return data;
  }
}

class Rooms {
  dynamic roomId;
  dynamic roomType;
  dynamic roomTypeId;
  dynamic furnished;
  dynamic occupancy;
  dynamic price;
  dynamic roomPricePerDay;
  List<Amenities>? amenities;
  dynamic availableUnits;
  List<String>? images;
  bool? isAvailable;
  dynamic sId;

  Rooms({
    this.roomId,
    this.roomType,
    this.roomTypeId,
    this.furnished,
    this.occupancy,
    this.price,
    this.roomPricePerDay,
    this.amenities,
    this.availableUnits,
    this.images,
    this.isAvailable,
    this.sId,
  });

  Rooms.fromJson(Map<String, dynamic> json) {
    roomId = json['roomId'];
    roomType = json['roomType'];
    roomTypeId = json['roomTypeId'];
    furnished = json['furnished'];
    occupancy = json['occupancy'];
    price = json['price'];
    roomPricePerDay = json['roomPricePerDay'];
    if (json['amenities'] != null) {
      amenities = <Amenities>[];
      json['amenities'].forEach((v) {
        amenities!.add(Amenities.fromJson(v));
      });
    }
    availableUnits = json['availableUnits'];
    images = json['images'].cast<String>();
    isAvailable = json['isAvailable'];
    sId = json['_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['roomId'] = roomId;
    data['roomType'] = roomType;
    data['roomTypeId'] = roomTypeId;
    data['furnished'] = furnished;
    data['occupancy'] = occupancy;
    data['price'] = price;
    data['roomPricePerDay'] = roomPricePerDay;
    if (amenities != null) {
      data['amenities'] = amenities!.map((v) => v.toJson()).toList();
    }
    data['availableUnits'] = availableUnits;
    data['images'] = images;
    data['isAvailable'] = isAvailable;
    data['_id'] = sId;
    return data;
  }
}

class Amenities {
  String? name;
  String? icon;
  String? sId;

  Amenities({this.name, this.icon, this.sId});

  Amenities.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    icon = json['icon'];
    sId = json['_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['icon'] = icon;
    data['_id'] = sId;
    return data;
  }
}

class Reviews {
  dynamic userId;
  dynamic userName;
  dynamic userImage;
  dynamic roomId;
  dynamic comment;
  dynamic rating;
  dynamic sId;
  dynamic createdAt;

  Reviews({
    this.userId,
    this.userName,
    this.userImage,
    this.roomId,
    this.comment,
    this.rating,
    this.sId,
    this.createdAt,
  });

  Reviews.fromJson(Map<String, dynamic> json) {
    userId = json['userId'];
    userName = json['userName'];
    userImage = json['userImage'];
    roomId = json['roomId'];
    comment = json['comment'];
    rating = json['rating'];
    sId = json['_id'];
    createdAt = json['createdAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['userId'] = userId;
    data['userName'] = userName;
    data['userImage'] = userImage;
    data['roomId'] = roomId;
    data['comment'] = comment;
    data['rating'] = rating;
    data['_id'] = sId;
    data['createdAt'] = createdAt;
    return data;
  }
}
