import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:room_book_kro_vendor/core/routes/app_routes.dart';
import 'package:room_book_kro_vendor/features/property/property_room/add_room_bottom_sheet.dart';
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

  Future<void> addPropertyApi({
    required String name,
    required String propertyType,
    required String address,
    required String city,
    required String state,
    required String pincode,
    required String userName,
    required String userEmail,
    required String role,
    required String phone,
    required Map<String, dynamic> coordinates,
    required List<File> mainImage,
    required List<File> propertyImages,
    required String pricePerMonth,
    required String depositAmount,
    required List<String> amenitiesMain,
    required List<String> rules,
    required String website,
    required String pricePerDay,
    required String availableRooms,
    required String additionalAddress,
    required String landmark,
    required String description,
    required String oldMrp,
    required bool payAtProperty,
    required String checkIn,
    required String checkOut,
    required String tax,
    required bool isAvailable,
    required String pricePerNight,
    required String discount,
    required String selectedRoomPrice,
    required List<RoomData> rooms,
    required BuildContext context,
  }) async
  {
    try {
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
        "selectedRoomPrice": selectedRoomPrice,
        "payAtProperty": payAtProperty,
        "checkIn": checkIn,
        "checkOut": checkOut,
        "pincode": pincode,
        "pricePerMonth": pricePerMonth,
        "depositAmount": depositAmount,
        "contactNumber": phone,
        "email": userEmail,
        "website": website,
        "pricePerDay": pricePerDay,
        "availableRooms": availableRooms,
        "owner": userName,
        "role": role,
        "description": description,
        "discount": discount,
        "oldMrp": oldMrp,
        "tax": tax,
        "pricePerNight": pricePerNight,
      };
      print(basicFields);
      print("basicFields🥳🥳");
      basicFields.forEach((key, value) {
        if (value.toString().isNotEmpty) {
          formData.fields.add(MapEntry(key, value.toString()));
        }
      });
      formData.fields.add(MapEntry('coordinates', jsonEncode(coordinates)));
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
      formData.fields.add(
        MapEntry('propertyAmenityIds', amenitiesMain.join(',')),
      );
      formData.fields.add(MapEntry('rules', rules.join(',')));
      for (int r = 0; r < rooms.length; r++) {
        final room = rooms[r];
        formData.fields.add(MapEntry("roomType[$r]", room.roomType));
        formData.fields.add(MapEntry("furnished[$r]", room.furnished));
        formData.fields.add(MapEntry("occupancy[$r]", room.occupancy));
        formData.fields.add(MapEntry("price[$r]", room.price));
        formData.fields.add(
          MapEntry("roomPricePerDay[$r]", room.roomPricePerDay),
        );
        formData.fields.add(
          MapEntry("discountRoom[$r]", room.discountRoom),
        );
        formData.fields.add(
          MapEntry("availableUnits[$r]", room.availableUnits),
        );
        formData.fields.add(
          MapEntry("isAvailable[$r]", room.isAvailable.toString()),
        );
        formData.fields.add(
          MapEntry("roomAmenityIds[$r]", room.amenitiesIds.join(",")),
        );
        formData.fields.add(
          MapEntry(
            "roomAmenitiesCount[$r]",
            room.amenitiesIds.length.toString(),
          ),
        );
        for (int i = 0; i < room.roomImages.length; i++) {
          final file = room.roomImages[i];
          if (await file.exists()) {
            formData.files.add(
              MapEntry(
                "roomImages[$r]",
                await MultipartFile.fromFile(
                  file.path,
                  filename: "room_${r}_image_$i.jpg",
                ),
              ),
            );
          }
        }
        formData.fields.add(
          MapEntry("roomImagesCount[$r]", room.roomImages.length.toString()),
        );
      }
      final response = await _addPropertyRepo.addPropertyApi(formData);
      if (response["success"] == true) {
        print("sdkjbskdjbc");
        super.state = AddPropertySuccess(
          message: response["message"].toString(),
        );
        Utils.show(response["message"].toString(), context);
        await Future.delayed(const Duration(milliseconds: 300));

        if (context.mounted) {
          // Replace '/bottomNavigation' with your actual route name
          Navigator.of(context).pushNamedAndRemoveUntil(
            AppRoutes.bottomNavigationPage, // or '/bottom' or whatever your route is
                (route) => false,
          );

          // Set Property tab after navigation
          Future.delayed(const Duration(milliseconds: 100), () {
            ref.read(bottomNavProvider.notifier).setIndex(2);
          });}
        // await Future.delayed(Duration(milliseconds: 100));
        // ref.read(bottomNavProvider.notifier).setIndex(2);
        // if (context.mounted) {
        //   Navigator.of(context).popUntil((route) => route.isFirst);
        // }
      } else {
        print("sdbfcjsd");
        super.state = AddPropertyError(response["message"].toString());
        Utils.show(response["message"].toString(), context);
      }
    } catch (e) {
      print("sdbjsdbks");
      super.state = AddPropertyError(e.toString());
      Utils.show(e.toString(), context);
      print(e.toString());
    }
  }

  ///
  Future<void> updatePropertyApi({
    required String name,
    required String propertyType,
    required String userName,
    required String userEmail,
    required String role,
    required String phone,
    required String residenceId,
    required String address,
    required String city,
    required String state,
    required String pincode,
    required Map<String, dynamic> coordinates,
    required List<File> mainImage,
    required List<File> propertyImages,
    required bool payAtProperty,
    required String pricePerMonth,
    required String selectedRoomPrice,
    required String depositAmount,
    required List<String> amenitiesMain,
    required List<String> rules,
    required String website,
    required String pricePerDay,
    required String availableRooms,
    required String additionalAddress,
    required String landmark,
    required String description,
    required String oldMrp,
    required String tax,
    required String checkIn,
    required String checkOut,
    required bool isAvailable,
    required String pricePerNight,
    required String discount,
    required List<RoomData> rooms,
    required BuildContext context,
  }) async
  {
    try {
      super.state = const AddPropertyLoading();
      final userPref = ref.read(userViewModelProvider);
      final userID = await userPref.getUserId();
      final formData = FormData();
      final basicFields = {
        "userId": userID.toString(),
        "userType": "1",
        "name": name,
        "type": propertyType,
        "payAtProperty": payAtProperty,
        "address": address,
        "additionalAddress": additionalAddress,
        "landmark": landmark,
        "selectedRoomPrice": selectedRoomPrice,
        "city": city,
        "state": state,
        "pincode": pincode,
        "checkIn": checkIn,
        "checkOut": checkOut,
        "pricePerMonth": pricePerMonth,
        "depositAmount": depositAmount,
        "contactNumber": phone ?? '',
        "email": userEmail ?? '',
        "website": website,
        "pricePerDay": pricePerDay,
        "availableRooms": availableRooms,
        "owner": userName ?? '',
        "role": role ?? '',
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
      formData.fields.add(
        MapEntry('propertyAmenityIds', amenitiesMain.join(',')),
      );
      formData.fields.add(MapEntry('rules', rules.join(',')));
      for (int r = 0; r < rooms.length; r++) {
        final room = rooms[r];
        formData.fields.add(MapEntry("roomType[$r]", room.roomType));
        formData.fields.add(MapEntry("furnished[$r]", room.furnished));
        formData.fields.add(MapEntry("occupancy[$r]", room.occupancy));
        formData.fields.add(MapEntry("price[$r]", room.price));
        formData.fields.add(
          MapEntry("roomPricePerDay[$r]", room.roomPricePerDay),
        );
        formData.fields.add(
          MapEntry("discountRoom[$r]", room.discountRoom),
        );
        formData.fields.add(
          MapEntry("availableUnits[$r]", room.availableUnits),
        );
        formData.fields.add(
          MapEntry("isAvailable[$r]", room.isAvailable.toString()),
        );

        // room amenity ids
        formData.fields.add(
          MapEntry("roomAmenityIds[$r]", room.amenitiesIds.join(",")),
        );

        // Count field for amenities
        formData.fields.add(
          MapEntry(
            "roomAmenitiesCount[$r]",
            room.amenitiesIds.length.toString(),
          ),
        );

        // upload room images
        for (int i = 0; i < room.roomImages.length; i++) {
          final file = room.roomImages[i];
          if (await file.exists()) {
            formData.files.add(
              MapEntry(
                "roomImages[$r]",
                await MultipartFile.fromFile(
                  file.path,
                  filename: "room_${r}_image_$i.jpg",
                ),
              ),
            );
          }
        }

        // image count field
        formData.fields.add(
          MapEntry("roomImagesCount[$r]", room.roomImages.length.toString()),
        );
      }
      final response = await _updatePropertyRepo.updatePropertyApi(
        formData,
        residenceId,
      );
      if (response["success"] == true) {
        super.state = AddPropertySuccess(
          message: response["message"].toString(),
        );
        Utils.show(response["message"].toString(), context);
        await Future.delayed(const Duration(milliseconds: 300));

        if (context.mounted) {
          Navigator.of(context).pushNamedAndRemoveUntil(
            AppRoutes.bottomNavigationPage,
                (route) => false,
          );

          // Set Property tab after navigation
          Future.delayed(const Duration(milliseconds: 100), () {
            ref.read(bottomNavProvider.notifier).setIndex(2);
          });}
        // await Future.delayed(Duration(milliseconds: 100));
        // ref.read(bottomNavProvider.notifier).setIndex(2);
        // if (context.mounted) {
        //   Navigator.of(context).popUntil((route) => route.isFirst);
        // }
      } else {
        super.state = AddPropertyError(response["message"].toString());
        Utils.show(response["message"].toString(), context);
      }
    } catch (e) {
      super.state = AddPropertyError(e.toString());
    }
  }
}

class RoomData {
  final String roomType;
  final String roomTypeName;
  final String furnished;
  final String occupancy;
  final String price; // Main price (backend ke liye)
  final String roomPricePerDay; // Per day price (backend ke liye)
  final String discountRoom; // Discount % (backend ke liye)
  final bool isAvailable;
  final String availableUnits;
  final List<String> amenitiesIds;
  final List<File> roomImages;
  final List<String>? existingImages;

  RoomData({
    required this.roomType,
    required this.roomTypeName,
    required this.furnished,
    required this.occupancy,
    required this.price,
    required this.roomPricePerDay,
    required this.isAvailable,
    required this.availableUnits,
    required this.discountRoom,
    required this.amenitiesIds,
    required this.roomImages,
    this.existingImages,
  });

  Map<String, dynamic> toJson() {
    return {
      "roomType": roomType,
      "furnished": furnished,
      "occupancy": occupancy,
      "price": price,
      "discountRoom": discountRoom,
      "roomPricePerDay": roomPricePerDay,
      "isAvailable": isAvailable,
      "availableUnits": availableUnits,
      "roomAmenityIds": amenitiesIds,
    };
  }
}

// PricingData class sirf UI ke liye hai (backend ko nahi jaata)
class PricingData {
  final String mrp;
  final String discount;
  final String finalPrice;

  PricingData({
    required this.mrp,
    required this.discount,
    required this.finalPrice,
  });

  Map<String, dynamic> toJson() {
    return {
      "mrp": mrp,
      "discount": discount,
      "finalPrice": finalPrice,
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
