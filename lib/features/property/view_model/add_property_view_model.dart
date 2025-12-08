import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../../core/utils/utils.dart';
import '../../auth/data/user_view.dart';
import '../../bottom/bottom_screen.dart';
import '../repo/add_property_repo.dart';
import '../repo/update_property_repo.dart';

class AddPropertyViewModel extends StateNotifier<AddPropertyState> {
  final AddPropertyRepository _addPropertyRepo;
  final UpdatePropertyRepository _updatePropertyRepo;
  final Ref ref;

  AddPropertyViewModel(
      this._addPropertyRepo,
      this._updatePropertyRepo,
      this.ref,
      ) : super(const AddPropertyInitial());

  // ✅ ADD PROPERTY METHOD (Original with prints)
  Future<void> addPropertyApi({
    required String name,
    required String propertyType,
    required String address,
    required String city,
    required String state,
    required String pincode,
    required Map<String, dynamic> coordinates,
    required List<File> mainImage,
    required List<File> propertyImages,
    required String pricePerMonth,
    required String depositAmount,
    required List<String> amenitiesMain,
    required List<String> rules,
    required String contactNumber,
    required String email,
    required String website,
    required String pricePerDay,
    required String availableRooms,
    required String owner,
    required String role,
    required String additionalAddress,
    required String landmark,
    required String description,
    required String oldMrp,
    required String tax,
    required bool isAvailable,
    required String pricePerNight,
    required String discount,
    required List<RoomData> rooms,
    required BuildContext context,
  }) async {
    try {
      // ✅ Set loading state
      super.state = const AddPropertyLoading();

      final userPref = ref.read(userViewModelProvider);
      final userID = await userPref.getUserId();
      final formData = FormData();
      final basicFields = {
        "userId": userID.toString(),
        "userType": "1",
        "name": name,
        "type": propertyType,
        "address": address,
        "additionalAddress": additionalAddress,
        "landmark": landmark,
        "city": city,
        "state": state,
        "pincode": pincode,
        "pricePerMonth": pricePerMonth,
        "depositAmount": depositAmount,
        "contactNumber": contactNumber,
        "email": email,
        "website": website,
        "pricePerDay": pricePerDay,
        "availableRooms": availableRooms,
        "owner": owner,
        "role": role,
        "description": description,
        "amenitiesMain": amenitiesMain,
        "discount": discount,
        "oldMrp": oldMrp,
        "tax": tax,
        "pricePerNight": pricePerNight,
      };

      basicFields.forEach((key, value) {
        if (value.toString().isNotEmpty) {
          formData.fields.add(MapEntry(key, value.toString()));
        }
      });

      formData.fields.add(MapEntry('coordinates', jsonEncode(coordinates)));

      // Main Image
      for (int i = 0; i < mainImage.length; i++) {
        final file = mainImage[i];
        if (await file.exists()) {
          final multipartFile = await MultipartFile.fromFile(
            file.path,
            filename: 'main_image_$i.jpg',
          );
          formData.files.add(MapEntry("mainImage", multipartFile));
        }
      }

      // Property Images
      for (int i = 0; i < propertyImages.length; i++) {
        final file = propertyImages[i];
        if (await file.exists()) {
          final multipartFile = await MultipartFile.fromFile(
            file.path,
            filename: 'property_image_$i.jpg',
          );
          formData.files.add(MapEntry("images", multipartFile));
        }
      }

      formData.fields.add(MapEntry('amenitiesMain', jsonEncode(amenitiesMain)));
      formData.fields.add(MapEntry('rules', jsonEncode(rules)));
      for (int r = 0; r < rooms.length; r++) {
        final room = rooms[r];

        formData.fields.add(MapEntry("roomType[$r]", room.roomType));
        formData.fields.add(MapEntry("furnished[$r]", room.furnished));
        formData.fields.add(MapEntry("occupancy[$r]", room.occupancy));
        formData.fields.add(MapEntry("price[$r]", room.price));
        formData.fields.add(
          MapEntry("roomPricePerDay[$r]", room.roomPricePerDay),
        );
        print("   📤 Sending roomPricePerDay[$r] = ${room.roomPricePerDay}");

        formData.fields.add(
          MapEntry("availableUnits[$r]", room.availableUnits),
        );
        formData.fields.add(
          MapEntry("amenities.name[$r]", jsonEncode(room.amenities)),
        );

        for (int i = 0; i < room.roomImages.length; i++) {
          final file = room.roomImages[i];
          if (await file.exists()) {
            final multipartFile = await MultipartFile.fromFile(
              file.path,
              filename: "room_${r}_image_$i.jpg",
            );
            formData.files.add(MapEntry("roomImages[$r]", multipartFile));
          }
        }
      }
      print("\n🏠 ===== ADD PROPERTY API END =====\n");

      final response = await _addPropertyRepo.addPropertyApi(formData);

      print("📥 API Response: ${response.toString()}");

      if (response["success"] == true) {
        super.state = AddPropertySuccess(
          message: response["message"].toString(),
        );
        Utils.show(response["message"].toString(), context);

        ref.read(bottomNavProvider.notifier).setIndex(2);
      } else {
        super.state = AddPropertyError(response["message"].toString());
        Utils.show(response["message"].toString(), context);
      }
    } catch (e) {
      print("❌ Error in addPropertyApi: $e");
      super.state = AddPropertyError(e.toString());
      Utils.show("Error: ${e.toString()}", context);
    }
  }

  // ✅ UPDATE PROPERTY METHOD (with prints)
  Future<void> updatePropertyApi({
    required String propertyId,
    required String residenceId,
    required String name,
    required String propertyType,
    required String address,
    required String city,
    required String state,
    required String pincode,
    required Map<String, dynamic> coordinates,
    required List<File> mainImage,
    required List<File> propertyImages,
    required String pricePerMonth,
    required String depositAmount,
    required List<String> amenitiesMain,
    required List<String> rules,
    required String contactNumber,
    required String email,
    required String website,
    required String pricePerDay,
    required String availableRooms,
    required String owner,
    required String role,
    required String additionalAddress,
    required String landmark,
    required String description,
    required String oldMrp,
    required String tax,
    required bool isAvailable,
    required String pricePerNight,
    required String discount,
    required List<RoomData> rooms,
    required BuildContext context,
    String? existingMainImage,
    List<String>? existingPropertyImages,
  }) async {
    try {
      // ✅ Set loading state
      super.state = const AddPropertyLoading();

      final userPref = ref.read(userViewModelProvider);
      final userID = await userPref.getUserId();
      final formData = FormData();

      print("🔄 ===== UPDATE PROPERTY API START =====");
      print("🆔 Property ID: $propertyId");
      print("🏠 Residence ID: $residenceId");
      print("📋 Property Type: $propertyType");
      print("💰 Price Per Month: $pricePerMonth");
      print("💵 Price Per Day: $pricePerDay");
      print("🌙 Price Per Night: $pricePerNight");
      print("🏨 Total Rooms: ${rooms.length}");

      final basicFields = {
        "propertyId": propertyId,
        "userId": userID.toString(),
        "userType": "1",
        "name": name,
        "type": propertyType,
        "address": address,
        "additionalAddress": additionalAddress,
        "landmark": landmark,
        "city": city,
        "state": state,
        "pincode": pincode,
        "pricePerMonth": pricePerMonth,
        "depositAmount": depositAmount,
        "contactNumber": contactNumber,
        "email": email,
        "website": website,
        "pricePerDay": pricePerDay,
        "availableRooms": availableRooms,
        "owner": owner,
        "role": role,
        "description": description,
        "discount": discount,
        "oldMrp": oldMrp,
        "tax": tax,
        "pricePerNight": pricePerNight,
      };

      basicFields.forEach((key, value) {
        if (value.toString().isNotEmpty) {
          formData.fields.add(MapEntry(key, value.toString()));
        }
      });

      formData.fields.add(MapEntry('coordinates', jsonEncode(coordinates)));

      // Main Image
      if (mainImage.isNotEmpty) {
        for (int i = 0; i < mainImage.length; i++) {
          final file = mainImage[i];
          if (await file.exists()) {
            final multipartFile = await MultipartFile.fromFile(
              file.path,
              filename: 'main_image_$i.jpg',
            );
            formData.files.add(MapEntry("mainImage", multipartFile));
            print("📤 Uploading new main image");
          }
        }
      } else if (existingMainImage != null && existingMainImage.isNotEmpty) {
        formData.fields.add(MapEntry("existingMainImage", existingMainImage));
        print("✅ Keeping existing main image");
      }

      // Property Images
      if (propertyImages.isNotEmpty) {
        for (int i = 0; i < propertyImages.length; i++) {
          final file = propertyImages[i];
          if (await file.exists()) {
            final multipartFile = await MultipartFile.fromFile(
              file.path,
              filename: 'property_image_$i.jpg',
            );
            formData.files.add(MapEntry("images", multipartFile));
            print("📤 Uploading new property image $i");
          }
        }
      } else if (existingPropertyImages != null &&
          existingPropertyImages.isNotEmpty) {
        formData.fields.add(
          MapEntry("existingImages", jsonEncode(existingPropertyImages)),
        );
        print("✅ Keeping existing property images");
      }

      formData.fields.add(MapEntry('amenitiesMain', jsonEncode(amenitiesMain)));
      formData.fields.add(MapEntry('rules', jsonEncode(rules)));

      // Rooms with detailed prints
      print("\n🚪 ===== ROOMS DATA (UPDATE) =====");
      for (int r = 0; r < rooms.length; r++) {
        final room = rooms[r];

        print("\n📌 Room ${r + 1}:");
        print("   🏷️  Room Type: ${room.roomType}");
        print("   🪑 Furnished: ${room.furnished}");
        print("   👥 Occupancy: ${room.occupancy}");
        print("   💰 Price (Monthly): ${room.price}");
        print("   💵 Room Price Per Day: ${room.roomPricePerDay}");
        print("   ✅ Available Units: ${room.availableUnits}");
        print("   🎯 Amenities: ${room.amenities}");
        print("   🖼️  New Images: ${room.roomImages.length}");
        print("   🌐 Existing Images: ${room.networkImages?.length ?? 0}");

        formData.fields.add(MapEntry("roomType[$r]", room.roomType));
        formData.fields.add(MapEntry("furnished[$r]", room.furnished));
        formData.fields.add(MapEntry("occupancy[$r]", room.occupancy));
        formData.fields.add(MapEntry("price[$r]", room.price));
        formData.fields.add(
          MapEntry("roomPricePerDay[$r]", room.roomPricePerDay),
        );
        print("   📤 Sending roomPricePerDay[$r] = ${room.roomPricePerDay}");

        formData.fields.add(
          MapEntry("availableUnits[$r]", room.availableUnits),
        );
        formData.fields.add(
          MapEntry("amenities.name[$r]", jsonEncode(room.amenities)),
        );

        // Upload new room images
        if (room.roomImages.isNotEmpty) {
          for (int i = 0; i < room.roomImages.length; i++) {
            final file = room.roomImages[i];
            if (await file.exists()) {
              final multipartFile = await MultipartFile.fromFile(
                file.path,
                filename: "room_${r}_image_$i.jpg",
              );
              formData.files.add(MapEntry("roomImages[$r]", multipartFile));
              print("   📤 Uploading room $r image $i");
            }
          }
        }

        // Keep existing room images
        if (room.networkImages != null && room.networkImages!.isNotEmpty) {
          formData.fields.add(
            MapEntry("existingRoomImages[$r]", jsonEncode(room.networkImages)),
          );
          print("   ✅ Keeping ${room.networkImages!.length} existing room $r images");
        }
      }
      print("\n🔄 ===== UPDATE PROPERTY API END =====\n");

      // Call update API
      final response = await _updatePropertyRepo.updatePropertyApi(
        formData,
        residenceId,
      );

      print("📥 Update API Response: ${response.toString()}");

      if (response["success"] == true) {
        super.state = AddPropertySuccess(
          message: response["message"].toString(),
        );
        Utils.show(response["message"].toString(), context);

        // Navigate back to property list
        Navigator.of(context).popUntil((route) => route.isFirst);
        ref.read(bottomNavProvider.notifier).setIndex(2);
      } else {
        super.state = AddPropertyError(response["message"].toString());
        Utils.show(response["message"].toString(), context);
      }
    } catch (e) {
      super.state = AddPropertyError(e.toString());
      Utils.show("Error: ${e.toString()}", context);
      print("❌ Update Error: $e");
    }
  }
}

// ✅ Room Data Model (Updated with networkImages)
class RoomData {
  final String roomType;
  final String furnished;
  final String occupancy;
  final String price;
  final String roomPricePerDay;
  final bool isAvailable;
  final String availableUnits;
  final List<String> amenities;
  final List<File> roomImages;
  final List<String>? networkImages;

  RoomData({
    required this.roomType,
    required this.furnished,
    required this.occupancy,
    required this.price,
    required this.roomPricePerDay,
    required this.isAvailable,
    required this.availableUnits,
    required this.amenities,
    required this.roomImages,
    this.networkImages,
  });

  Map<String, dynamic> toJson() {
    return {
      "roomType": roomType,
      "furnished": furnished,
      "occupancy": occupancy,
      "price": price,
      "roomPricePerDay": roomPricePerDay,
      "isAvailable": isAvailable,
      "availableUnits": availableUnits,
      "amenities": amenities,
    };
  }
}

// State Classes
abstract class AddPropertyState {
  final bool isLoading;
  const AddPropertyState({this.isLoading = false});
}

class AddPropertyInitial extends AddPropertyState {
  const AddPropertyInitial() : super(isLoading: false);
}

class AddPropertyLoading extends AddPropertyState {
  const AddPropertyLoading() : super(isLoading: true);
}

class AddPropertySuccess extends AddPropertyState {
  final String message;
  const AddPropertySuccess({required this.message}) : super(isLoading: false);
}

class AddPropertyError extends AddPropertyState {
  final String error;
  const AddPropertyError(this.error) : super(isLoading: false);
}

// ✅ Provider
final addPropertyProvider =
StateNotifierProvider<AddPropertyViewModel, AddPropertyState>((ref) {
  final addPropRepo = ref.read(addPropertyRepoProvider);
  final updatePropRepo = ref.read(updatePropertyRepoProvider);
  return AddPropertyViewModel(addPropRepo, updatePropRepo, ref);
});