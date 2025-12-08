// class OrderedModel {
//   bool? success;
//   Data? data;
//
//   OrderedModel({this.success, this.data});
//
//   OrderedModel.fromJson(Map<String, dynamic> json) {
//     success = json['success'];
//     data = json['data'] != null ? Data.fromJson(json['data']) : null;
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     data['success'] = success;
//     if (this.data != null) {
//       data['data'] = this.data!.toJson();
//     }
//     return data;
//   }
// }
//
// class Data {
//   String? sId;
//   String? userId;
//   String? userType;
//   dynamic residencyId;
//   String? name;
//   String? type;
//   String? address;
//   String? city;
//   String? state;
//   String? pincode;
//   Coordinates? coordinates;
//   String? mainImage;
//   List<String>? images;
//   dynamic depositAmount;
//   List<Rooms>? rooms;
//   List<Amenities>? amenities;
//   List<String>? rules;
//   String? contactNumber;
//   String? email;
//   String? website;
//   dynamic rating;
//   List<Reviews>? reviews;
//   String? description;
//   dynamic availableRooms;
//   bool? isAvailable;
//   String? owner;
//   String? role;
//   String? discount;
//   dynamic oldMrp;
//   dynamic tax;
//   String? createdAt;
//   dynamic iV;
//   dynamic pricePerNight;
//   dynamic pricePerMonth;
//   dynamic pricePerDay;
//   dynamic distance;
//   dynamic distanceText;
//   bool? wishlist;
//
//   Data({
//     this.sId,
//     this.userId,
//     this.userType,
//     this.residencyId,
//     this.name,
//     this.type,
//     this.address,
//     this.city,
//     this.state,
//     this.pincode,
//     this.coordinates,
//     this.mainImage,
//     this.images,
//     this.depositAmount,
//     this.rooms,
//     this.amenities,
//     this.rules,
//     this.contactNumber,
//     this.email,
//     this.website,
//     this.rating,
//     this.reviews,
//     this.description,
//     this.availableRooms,
//     this.isAvailable,
//     this.owner,
//     this.role,
//     this.discount,
//     this.oldMrp,
//     this.tax,
//     this.createdAt,
//     this.iV,
//     this.pricePerNight,
//     this.pricePerMonth,
//     this.pricePerDay,
//     this.distance,
//     this.distanceText,
//     this.wishlist,
//   });
//
//   Data.fromJson(Map<String, dynamic> json) {
//     sId = json['_id'];
//     userId = json['userId'];
//     userType = json['userType'];
//     residencyId = json['residencyId'];
//     name = json['name'];
//     type = json['type'];
//     address = json['address'];
//     city = json['city'];
//     state = json['state'];
//     pincode = json['pincode'];
//     coordinates = json['coordinates'] != null
//         ? Coordinates.fromJson(json['coordinates'])
//         : null;
//     mainImage = json['mainImage'];
//     images = json['images'].cast<String>();
//     depositAmount = json['depositAmount'];
//     if (json['rooms'] != null) {
//       rooms = <Rooms>[];
//       json['rooms'].forEach((v) {
//         rooms!.add(Rooms.fromJson(v));
//       });
//     }
//     if (json['amenities'] != null) {
//       amenities = <Amenities>[];
//       json['amenities'].forEach((v) {
//         amenities!.add(Amenities.fromJson(v));
//       });
//     }
//     rules = json['rules'].cast<String>();
//     contactNumber = json['contactNumber'];
//     email = json['email'];
//     website = json['website'];
//     rating = json['rating'];
//     if (json['reviews'] != null) {
//       reviews = <Reviews>[];
//       json['reviews'].forEach((v) {
//         reviews!.add(Reviews.fromJson(v));
//       });
//     }
//     description = json['description'];
//     availableRooms = json['availableRooms'];
//     isAvailable = json['isAvailable'];
//     owner = json['owner'];
//     role = json['role'];
//     discount = json['discount'];
//     oldMrp = json['oldMrp'];
//     tax = json['tax'];
//     createdAt = json['createdAt'];
//     iV = json['__v'];
//     pricePerNight = json['pricePerNight'];
//     pricePerMonth = json['pricePerMonth'];
//     pricePerDay = json['pricePerDay'];
//     distance = json['distance'];
//     distanceText = json['distanceText'];
//     wishlist = json['wishlist'];
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     data['_id'] = sId;
//     data['userId'] = userId;
//     data['userType'] = userType;
//     data['residencyId'] = residencyId;
//     data['name'] = name;
//     data['type'] = type;
//     data['address'] = address;
//     data['city'] = city;
//     data['state'] = state;
//     data['pincode'] = pincode;
//     if (coordinates != null) {
//       data['coordinates'] = coordinates!.toJson();
//     }
//     data['mainImage'] = mainImage;
//     data['images'] = images;
//     data['depositAmount'] = depositAmount;
//     if (rooms != null) {
//       data['rooms'] = rooms!.map((v) => v.toJson()).toList();
//     }
//     if (amenities != null) {
//       data['amenities'] = amenities!.map((v) => v.toJson()).toList();
//     }
//     data['rules'] = rules;
//     data['contactNumber'] = contactNumber;
//     data['email'] = email;
//     data['website'] = website;
//     data['rating'] = rating;
//     if (reviews != null) {
//       data['reviews'] = reviews!.map((v) => v.toJson()).toList();
//     }
//     data['description'] = description;
//     data['availableRooms'] = availableRooms;
//     data['isAvailable'] = isAvailable;
//     data['owner'] = owner;
//     data['role'] = role;
//     data['discount'] = discount;
//     data['oldMrp'] = oldMrp;
//     data['tax'] = tax;
//     data['createdAt'] = createdAt;
//     data['__v'] = iV;
//     data['pricePerNight'] = pricePerNight;
//     data['pricePerMonth'] = pricePerMonth;
//     data['pricePerDay'] = pricePerDay;
//     data['distance'] = distance;
//     data['distanceText'] = distanceText;
//     data['wishlist'] = wishlist;
//     return data;
//   }
// }
//
// class Coordinates {
//   double? lat;
//   double? lng;
//
//   Coordinates({this.lat, this.lng});
//
//   Coordinates.fromJson(Map<String, dynamic> json) {
//     lat = json['lat'];
//     lng = json['lng'];
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     data['lat'] = lat;
//     data['lng'] = lng;
//     return data;
//   }
// }
//
// class Rooms {
//   dynamic roomId;
//   String? roomType;
//   String? furnished;
//   dynamic occupancy;
//   dynamic price;
//   List<Amenities>? amenities;
//   dynamic availableUnits;
//   List<String>? images;
//   dynamic pricePerDay;
//   String? sId;
//   bool? isAvailable;
//
//   Rooms({
//     this.roomId,
//     this.roomType,
//     this.furnished,
//     this.occupancy,
//     this.price,
//     this.amenities,
//     this.availableUnits,
//     this.images,
//     this.pricePerDay,
//     this.sId,
//     this.isAvailable,
//   });
//
//   Rooms.fromJson(Map<String, dynamic> json) {
//     roomId = json['roomId'];
//     roomType = json['roomType'];
//     furnished = json['furnished'];
//     occupancy = json['occupancy'];
//     price = json['price'];
//     if (json['amenities'] != null) {
//       amenities = <Amenities>[];
//       json['amenities'].forEach((v) {
//         amenities!.add(Amenities.fromJson(v));
//       });
//     }
//     availableUnits = json['availableUnits'];
//     images = json['images'].cast<String>();
//     pricePerDay = json['pricePerDay'];
//     sId = json['_id'];
//     isAvailable = json['isAvailable'];
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     data['roomId'] = roomId;
//     data['roomType'] = roomType;
//     data['furnished'] = furnished;
//     data['occupancy'] = occupancy;
//     data['price'] = price;
//     if (amenities != null) {
//       data['amenities'] = amenities!.map((v) => v.toJson()).toList();
//     }
//     data['availableUnits'] = availableUnits;
//     data['images'] = images;
//     data['pricePerDay'] = pricePerDay;
//     data['_id'] = sId;
//     data['isAvailable'] = isAvailable;
//     return data;
//   }
// }
//
// class Amenities {
//   String? name;
//   String? icon;
//   String? sId;
//
//   Amenities({this.name, this.icon, this.sId});
//
//   Amenities.fromJson(Map<String, dynamic> json) {
//     name = json['name'];
//     icon = json['icon'];
//     sId = json['_id'];
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     data['name'] = name;
//     data['icon'] = icon;
//     data['_id'] = sId;
//     return data;
//   }
// }
//
// class Reviews {
//   String? userId;
//   String? userName;
//   String? userImage;
//   dynamic roomId;
//   String? comment;
//   dynamic rating;
//   String? sId;
//   String? createdAt;
//
//   Reviews({
//     this.userId,
//     this.userName,
//     this.userImage,
//     this.roomId,
//     this.comment,
//     this.rating,
//     this.sId,
//     this.createdAt,
//   });
//
//   Reviews.fromJson(Map<String, dynamic> json) {
//     userId = json['userId'];
//     userName = json['userName'];
//     userImage = json['userImage'];
//     roomId = json['roomId'];
//     comment = json['comment'];
//     rating = json['rating'];
//     sId = json['_id'];
//     createdAt = json['createdAt'];
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     data['userId'] = userId;
//     data['userName'] = userName;
//     data['userImage'] = userImage;
//     data['roomId'] = roomId;
//     data['comment'] = comment;
//     data['rating'] = rating;
//     data['_id'] = sId;
//     data['createdAt'] = createdAt;
//     return data;
//   }
// }
