// import 'dart:convert';
// import 'dart:io';
// import 'package:dio/dio.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_riverpod/legacy.dart';
// import '../../../core/utils/utils.dart';
// import '../../auth/data/user_view.dart';
// import '../../bottom/bottom_screen.dart';
// import '../../profile/view_model/profile_view_model.dart';
// import '../repo/update_property_repo.dart';
//
// class UpdatePropertyViewModel extends StateNotifier<AddPropertyState> {
//   final UpdatePropertyRepository _updatePropertyRepo;
//   final Ref ref;
//
//   UpdatePropertyViewModel(
//       this._updatePropertyRepo,
//       this.ref,
//       ) : super(const AddPropertyInitial());
//
//   Future<void> updatePropertyApi({
//     required String name,
//     required String residenceId,
//     required String propertyType,
//     required String address,
//     required String city,
//     required String state,
//     required String pincode,
//     required Map<String, dynamic> coordinates,
//     required List<File> mainImage,
//     required List<File> propertyImages,
//     required String pricePerMonth,
//     required String depositAmount,
//     required List<String> amenitiesMain,
//     required String website,
//     required String pricePerDay,
//     required String availableRooms,
//     required String additionalAddress,
//     required String landmark,
//     required String description,
//     required String oldMrp,
//     required String tax,
//     required bool isAvailable,
//     required String pricePerNight,
//     required String discount,
//     required List<RoomData> rooms,
//     required BuildContext context,
//   }) async {
//     try {
//       super.state = const AddPropertyLoading();
//       final profileState = ref.read(updateProvider);
//       String? userName;
//       String? userEmail;
//       String? role;
//       String? phone;
//       if (profileState is ProfileSuccess && profileState.profile != null) {
//         userName = profileState.profile!.username;
//         userName = profileState.profile!.email;
//         userName = profileState.profile!.occupation;
//         userName = profileState.profile!.contact;
//       }
//       final userPref = ref.read(userViewModelProvider);
//       final userID = await userPref.getUserId();
//       final formData = FormData();
//       final basicFields = {
//         "userId": userID.toString(),
//         "userType": "1",
//         "name": name,
//         "type": propertyType,
//         "address": address,
//         "additionalAddress": additionalAddress,
//         "landmark": landmark,
//         "city": city,
//         "state": state,
//         "pincode": pincode,
//         "pricePerMonth": pricePerMonth,
//         "depositAmount": depositAmount,
//         "contactNumber": phone??'',
//         "email": userEmail??'',
//         "website": website,
//         "pricePerDay": pricePerDay,
//         "availableRooms": availableRooms,
//         "owner":userName??'',
//         "role": role??'',
//         "description": description,
//         "discount": discount,
//         "oldMrp": oldMrp,
//         "tax": tax,
//         "pricePerNight": pricePerNight,
//       };
//       basicFields.forEach((key, value) {
//         if (value.toString().isNotEmpty) {
//           formData.fields.add(MapEntry(key, value.toString()));
//         }
//       });
//       formData.fields.add(MapEntry('coordinates', jsonEncode(coordinates)));
//       for (int i = 0; i < mainImage.length; i++) {
//         final file = mainImage[i];
//         if (await file.exists()) {
//           final multipartFile = await MultipartFile.fromFile(
//             file.path,
//             filename: 'main_image_$i.jpg',
//           );
//           formData.files.add(MapEntry("mainImage", multipartFile));
//         }
//       }
//       for (int i = 0; i < propertyImages.length; i++) {
//         final file = propertyImages[i];
//         if (await file.exists()) {
//           final multipartFile = await MultipartFile.fromFile(
//             file.path,
//             filename: 'property_image_$i.jpg',
//           );
//           formData.files.add(MapEntry("images", multipartFile));
//         }
//       }
//       formData.fields.add(
//         MapEntry('propertyAmenityIds', amenitiesMain.join(',')),
//       );
//       for (int r = 0; r < rooms.length; r++) {
//         final room = rooms[r];
//         formData.fields.add(MapEntry("roomType[$r]", room.roomType));
//         formData.fields.add(MapEntry("furnished[$r]", room.furnished));
//         formData.fields.add(MapEntry("occupancy[$r]", room.occupancy));
//         formData.fields.add(MapEntry("price[$r]", room.price));
//         formData.fields.add(
//           MapEntry("roomPricePerDay[$r]", room.roomPricePerDay),
//         );
//         formData.fields.add(
//           MapEntry("availableUnits[$r]", room.availableUnits),
//         );
//         formData.fields.add(
//           MapEntry("isAvailable[$r]", room.isAvailable.toString()),
//         );
//         formData.fields.add(
//           MapEntry("roomAmenityIds[$r]", room.amenitiesIds.join(",")),
//         );
//         formData.fields.add(
//           MapEntry(
//             "roomAmenitiesCount[$r]",
//             room.amenitiesIds.length.toString(),
//           ),
//         );
//         for (int i = 0; i < room.roomImages.length; i++) {
//           final file = room.roomImages[i];
//           if (await file.exists()) {
//             formData.files.add(
//               MapEntry(
//                 "roomImages[$r]",
//                 await MultipartFile.fromFile(
//                   file.path,
//                   filename: "room_${r}_image_$i.jpg",
//                 ),
//               ),
//             );
//           }
//         }
//         formData.fields.add(
//           MapEntry("roomImagesCount[$r]", room.roomImages.length.toString()),
//         );
//       }
//       final response = await _updatePropertyRepo.updatePropertyApi(formData, residenceId);
//       if (response["success"] == true) {
//         super.state = AddPropertySuccess(
//           message: response["message"].toString(),
//         );
//         Utils.show(response["message"].toString(), context);
//         await Future.delayed(Duration(milliseconds: 100));
//         ref.read(bottomNavProvider.notifier).setIndex(2);
//         if (context.mounted) {
//           Navigator.of(context).popUntil((route) => route.isFirst);
//         }
//       } else {
//         super.state = AddPropertyError(response["message"].toString());
//         Utils.show(response["message"].toString(), context);
//       }
//     } catch (e) {
//       super.state = AddPropertyError(e.toString());
//     }
//   }
//
//   ///
//   Future<void> updatePropertyApi({
//     required String name,
//     required String propertyType,
//     required String residenceId,
//     required String address,
//     required String city,
//     required String state,
//     required String pincode,
//     required Map<String, dynamic> coordinates,
//     required List<File> mainImage,
//     required List<File> propertyImages,
//     required String pricePerMonth,
//     required String depositAmount,
//     required List<String> amenitiesMain,
//     required String contactNumber,
//     required String email,
//     required String website,
//     required String pricePerDay,
//     required String availableRooms,
//     required String owner,
//     required String role,
//     required String additionalAddress,
//     required String landmark,
//     required String description,
//     required String oldMrp,
//     required String tax,
//     required bool isAvailable,
//     required String pricePerNight,
//     required String discount,
//     required List<RoomData> rooms,
//     required BuildContext context,
//   }) async {
//     try {
//       super.state = const AddPropertyLoading();
//       final userPref = ref.read(userViewModelProvider);
//       final userID = await userPref.getUserId();
//       final formData = FormData();
//       final basicFields = {
//         "userId": userID.toString(),
//         "userType": "1",
//         "name": name,
//         "type": propertyType,
//         "address": address,
//         "additionalAddress": additionalAddress,
//         "landmark": landmark,
//         "city": city,
//         "state": state,
//         "pincode": pincode,
//         "pricePerMonth": pricePerMonth,
//         "depositAmount": depositAmount,
//         "contactNumber": contactNumber,
//         "email": email,
//         "website": website,
//         "pricePerDay": pricePerDay,
//         "availableRooms": availableRooms,
//         "owner": owner,
//         "role": role,
//         "description": description,
//         "discount": discount,
//         "oldMrp": oldMrp,
//         "tax": tax,
//         "pricePerNight": pricePerNight,
//       };
//       basicFields.forEach((key, value) {
//         if (value.toString().isNotEmpty) {
//           formData.fields.add(MapEntry(key, value.toString()));
//         }
//       });
//       formData.fields.add(MapEntry('coordinates', jsonEncode(coordinates)));
//       for (int i = 0; i < mainImage.length; i++) {
//         final file = mainImage[i];
//         if (await file.exists()) {
//           final multipartFile = await MultipartFile.fromFile(
//             file.path,
//             filename: 'main_image_$i.jpg',
//           );
//           formData.files.add(MapEntry("mainImage", multipartFile));
//         }
//       }
//       for (int i = 0; i < propertyImages.length; i++) {
//         final file = propertyImages[i];
//         if (await file.exists()) {
//           final multipartFile = await MultipartFile.fromFile(
//             file.path,
//             filename: 'property_image_$i.jpg',
//           );
//           formData.files.add(MapEntry("images", multipartFile));
//         }
//       }
//       formData.fields.add(
//         MapEntry('propertyAmenityIds', amenitiesMain.join(',')),
//       );
//       for (int r = 0; r < rooms.length; r++) {
//         final room = rooms[r];
//         formData.fields.add(MapEntry("roomType[$r]", room.roomType));
//         formData.fields.add(MapEntry("furnished[$r]", room.furnished));
//         formData.fields.add(MapEntry("occupancy[$r]", room.occupancy));
//         formData.fields.add(MapEntry("price[$r]", room.price));
//         formData.fields.add(
//           MapEntry("roomPricePerDay[$r]", room.roomPricePerDay),
//         );
//         formData.fields.add(
//           MapEntry("availableUnits[$r]", room.availableUnits),
//         );
//         formData.fields.add(
//           MapEntry("isAvailable[$r]", room.isAvailable.toString()),
//         );
//
//         // room amenity ids
//         formData.fields.add(
//           MapEntry("roomAmenityIds[$r]", room.amenitiesIds.join(",")),
//         );
//
//         // Count field for amenities
//         formData.fields.add(
//           MapEntry(
//             "roomAmenitiesCount[$r]",
//             room.amenitiesIds.length.toString(),
//           ),
//         );
//
//         // upload room images
//         for (int i = 0; i < room.roomImages.length; i++) {
//           final file = room.roomImages[i];
//           if (await file.exists()) {
//             formData.files.add(
//               MapEntry(
//                 "roomImages[$r]",
//                 await MultipartFile.fromFile(
//                   file.path,
//                   filename: "room_${r}_image_$i.jpg",
//                 ),
//               ),
//             );
//           }
//         }
//
//         // image count field
//         formData.fields.add(
//           MapEntry("roomImagesCount[$r]", room.roomImages.length.toString()),
//         );
//       }
//       final response = await _updatePropertyRepo.updatePropertyApi(
//         formData,
//         residenceId,
//       );
//       if (response["success"] == true) {
//         super.state = AddPropertySuccess(
//           message: response["message"].toString(),
//         );
//         Utils.show(response["message"].toString(), context);
//         await Future.delayed(Duration(milliseconds: 100));
//         ref.read(bottomNavProvider.notifier).setIndex(2);
//         if (context.mounted) {
//           Navigator.of(context).popUntil((route) => route.isFirst);
//         }
//       } else {
//         super.state = AddPropertyError(response["message"].toString());
//         Utils.show(response["message"].toString(), context);
//       }
//     } catch (e) {
//       super.state = AddPropertyError(e.toString());
//     }
//   }
// }
//
// class RoomData {
//   final String roomType;
//   final String furnished;
//   final String occupancy;
//   final String price;
//   final String roomPricePerDay;
//   final bool isAvailable;
//   final String availableUnits;
//   final List<String> amenitiesIds;
//   final List<File> roomImages;
//   final List<String>? networkImages;
//
//   RoomData({
//     required this.roomType,
//     required this.furnished,
//     required this.occupancy,
//     required this.price,
//     required this.roomPricePerDay,
//     required this.isAvailable,
//     required this.availableUnits,
//     required this.amenitiesIds,
//     required this.roomImages,
//     this.networkImages,
//   });
//
//   Map<String, dynamic> toJson() {
//     return {
//       "roomType": roomType,
//       "furnished": furnished,
//       "occupancy": occupancy,
//       "price": price,
//       "roomPricePerDay": roomPricePerDay,
//       "isAvailable": isAvailable,
//       "availableUnits": availableUnits,
//       "roomAmenityIds": amenitiesIds,
//     };
//   }
// }
//
// // State Classes
// abstract class AddPropertyState {
//   final bool isLoading;
//   const AddPropertyState({this.isLoading = false});
// }
//
// class AddPropertyInitial extends AddPropertyState {
//   const AddPropertyInitial() : super(isLoading: false);
// }
//
// class AddPropertyLoading extends AddPropertyState {
//   const AddPropertyLoading() : super(isLoading: true);
// }
//
// class AddPropertySuccess extends AddPropertyState {
//   final String message;
//   const AddPropertySuccess({required this.message}) : super(isLoading: false);
// }
//
// class AddPropertyError extends AddPropertyState {
//   final String error;
//   const AddPropertyError(this.error) : super(isLoading: false);
// }
//
// // ✅ Provider
// final updatePropertyProvider =
// StateNotifierProvider<UpdatePropertyViewModel, AddPropertyState>((ref) {
//   final updatePropRepo = ref.read(updatePropertyRepoProvider);
//   return UpdatePropertyViewModel(updatePropRepo, ref);
// });
