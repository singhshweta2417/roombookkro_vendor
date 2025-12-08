// file: add_room_property_fixed.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:room_book_kro_vendor/core/utils/context_extensions.dart';
import 'package:room_book_kro_vendor/core/widgets/custom_app_bar.dart';
import 'package:room_book_kro_vendor/core/widgets/custom_container.dart';
import 'package:room_book_kro_vendor/core/widgets/custom_scaffold.dart';
import 'package:room_book_kro_vendor/core/widgets/custom_text_field.dart';
import 'package:room_book_kro_vendor/core/widgets/primary_button.dart';
import 'package:room_book_kro_vendor/features/property/view_model/add_property_view_model.dart';
import '../../../core/constants/app_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';


class AddRoomProperty extends ConsumerStatefulWidget {
  const AddRoomProperty({super.key});

  @override
  ConsumerState<AddRoomProperty> createState() => _AddPropertyScreenState();
}

class _AddPropertyScreenState extends ConsumerState<AddRoomProperty> {
  final ImagePicker picker = ImagePicker();
  final List<RoomData> roomsList = [];
  final Map<String, List<String>> subTypeList = {
    "Hotel": ["Standard", "Deluxe", "Suite"],
    "Resort": ["Cottage", "Villa", "Tent"],
    "Flat": ["1BHK", "2BHK", "3BHK"],
    "PG": ["Single Sharing", "Double Sharing", "Triple Sharing"],
    "Apartment": ["1BHK", "2BHK", "3BHK"],
  };
  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map;
    final propertyTitle = args["propertyTitle"];
    final coordinates = args["coordinates"];
    final pincode = args["pincode"];
    final state = args["state"];
    final city = args["city"];
    final address = args["address"];
    final ownerName = args["ownerName"];
    final ownerRole = args["ownerRole"];
    final email = args["email"];
    final contactNumber = args["contactNumber"];
    final selectedPropertyType = args["selectedPropertyType"];
    final website = args["website"];
    final roomCount = args["roomCount"];
    final description = args["description"];
    final discount = args["discount"];
    final oldMrp = args["oldMrp"];
    final tax = args["tax"];
    final propertyDayPrice = args["propertyDayPrice"];
    final propertyNightPrice = args["propertyNightPrice"];
    final propertyMonthPrice = args["propertyMonthPrice"];
    final flatNo = args["flatNo"];
    final additionalAddress = args["additionalAddress"];

    // Amenities from previous screen — convert to List<String>
    List<String> mainAmenitiesList = [];
    final dynamic amenitiesArg = args["amenities"];
    if (amenitiesArg is Map) {
      mainAmenitiesList = (amenitiesArg.entries
          .where((e) => e.value == true)
          .map((e) => e.key.toString())
          .toList());
    } else if (amenitiesArg is String) {
      mainAmenitiesList = amenitiesArg
          .split(",")
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();
    } else if (amenitiesArg is List) {
      mainAmenitiesList = amenitiesArg.map((e) => e.toString()).toList();
    }

    final bool isAvailable = args["availability"] ?? false;
    final List<File> mainImage =
        (args["mainImage"] as List?)?.cast<File>() ?? [];
    final List<File> propertyImages =
        (args["propertyImages"] as List?)?.cast<File>() ?? [];

    return CustomScaffold(
      appBar: CustomAppBar(
        middle: AppText(
          text: "Add Room",
          fontType: FontType.bold,
          fontSize: AppConstants.twentyTwo,
          color: Colors.black,
        ),
      ),
      child: ListView(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        children: [
          // Summary card
          TCustomContainer(
            padding: const EdgeInsets.all(12),
            borderRadius: BorderRadius.circular(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  text: propertyTitle ?? "Property",
                  fontType: FontType.bold,
                ),
                const SizedBox(height: 6),
                AppText(
                  text: "$city, $state • $pincode",
                  fontType: FontType.regular,
                ),
                const SizedBox(height: 6),
                AppText(
                  text:
                      "Added rooms: ${roomsList.length} • Expected: ${roomCount ?? '—'}",
                  fontType: FontType.regular,
                ),
              ],
            ),
          ),

          SizedBox(height: context.sh * 0.02),

          // Preview list of added rooms
          AppText(text: "Rooms added", fontType: FontType.bold),
          const SizedBox(height: 8),
          roomsList.isEmpty
              ? TCustomContainer(
                  padding: const EdgeInsets.all(16),
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                  child: AppText(
                    text: "No rooms added yet. Tap 'Add Room' to create one.",
                    fontType: FontType.regular,
                  ),
                )
              : Column(
                  children: roomsList
                      .asMap()
                      .entries
                      .map((entry) {
                        final idx = entry.key;
                        final r = entry.value;
                        return TCustomContainer(
                          padding: const EdgeInsets.all(12),
                          borderRadius: BorderRadius.circular(12),
                          lightColor: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (r.roomImages.isNotEmpty)
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.file(
                                    r.roomImages.first,
                                    width: 90,
                                    height: 70,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              else
                                Container(
                                  width: 90,
                                  height: 70,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.hotel,
                                    color: Colors.grey,
                                    size: 30,
                                  ),
                                ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: AppText(
                                            text:
                                                "${r.roomType} • ${r.furnished}",
                                            fontType: FontType.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () => _editRoom(idx,selectedPropertyType),
                                          child: const Padding(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 8.0,
                                            ),
                                            child: Icon(
                                              Icons.edit,
                                              color: Colors.blueAccent,
                                            ),
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () => setState(
                                            () => roomsList.removeAt(idx),
                                          ),
                                          child: const Padding(
                                            padding: EdgeInsets.only(left: 6.0),
                                            child: Icon(
                                              Icons.delete,
                                              color: Colors.redAccent,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    AppText(
                                      text:
                                          "Price: ₹${r.price}  •  Units: ${r.availableUnits}  •  Occ: ${r.occupancy}",
                                      fontType: FontType.regular,
                                      color: Colors.grey.shade700,
                                    ),
                                    const SizedBox(height: 6),
                                    AppText(
                                      text:
                                          "Amenities: ${r.amenities.join(', ')}",
                                      fontType: FontType.regular,
                                      fontSize: 13,
                                      color: Colors.grey.shade600,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      })
                      .toList()
                      .cast<Widget>(),
                ),

          SizedBox(height: context.sh * 0.02),

          // Add Room button (opens bottom sheet)
          PrimaryButton(
            label: "Add Room",
            onTap: () async {
              final newRoom = await showModalBottomSheet<RoomData>(
                context: context,
                isScrollControlled: true,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                builder: (_) => Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                  ),
                  child: AddRoomBottomSheet(
                    propertyType: selectedPropertyType as String?,
                    subTypeList: subTypeList,
                  ),
                ),
              );

              if (newRoom != null) {
                setState(() => roomsList.add(newRoom));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: AppText(
                      text: "Room added",
                      fontType: FontType.regular,
                      color: Colors.white,
                    ),
                  ),
                );
              }
            },
          ),

          SizedBox(height: context.sh * 0.015),

          // Final Submit — call ViewModel with roomsList
          PrimaryButton(
            label: "Submit Property",
            isLoading: ref.watch(addPropertyProvider).isLoading,
            onTap: () {
              if (roomsList.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: AppText(
                      text: "Add at least one room",
                      fontType: FontType.regular,
                        color: Colors.white
                    ),
                  ),
                );
                return;
              }
              final List<String> amenitiesForApi = mainAmenitiesList;
              final List<String> rulesForApi = mainAmenitiesList;
              final depositAmount = args["depositAmount"]?.toString() ?? "0";
              ref.read(addPropertyProvider.notifier).addPropertyApi(
                    name: propertyTitle ?? "",
                    propertyType: selectedPropertyType ?? "",
                    landmark: flatNo,
                    additionalAddress: additionalAddress,
                    address: address ?? "",
                    city: city ?? "",
                    state: state ?? "",
                    pincode: pincode?.toString() ?? "",
                    coordinates: coordinates ?? {"lat": 0.0, "lng": 0.0},
                    mainImage: mainImage,
                    propertyImages: propertyImages,
                    pricePerMonth: propertyMonthPrice?.toString() ?? "",
                    depositAmount: depositAmount,
                    amenitiesMain: amenitiesForApi,
                    rules: rulesForApi,
                    contactNumber: contactNumber?.toString() ?? "",
                    email: email?.toString() ?? "",
                    website: website?.toString() ?? "",
                    pricePerDay: propertyDayPrice?.toString() ?? "",
                    availableRooms:
                        roomCount?.toString() ?? roomsList.length.toString(),
                    owner: ownerName?.toString() ?? "",
                    role: ownerRole?.toString() ?? "",
                    description: description?.toString() ?? "",
                    oldMrp: oldMrp?.toString() ?? "",
                    tax: tax?.toString() ?? "",
                    isAvailable: isAvailable,
                    pricePerNight: propertyNightPrice?.toString() ?? "",
                    discount: discount?.toString() ?? "",
                    rooms: roomsList,
                    context: context,
                  );
            },
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }
  Future<void> _editRoom(int index,selectedPropertyType) async {
    final existing = roomsList[index];
    final editedRoom = await showModalBottomSheet<RoomData>(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: AddRoomBottomSheet(
          propertyType: selectedPropertyType.toString(),
          subTypeList: subTypeList,
          initialRoom: existing,
        ),
      ),
    );

    if (editedRoom != null) {
      setState(() => roomsList[index] = editedRoom);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: AppText(text: "Room updated!", fontType: FontType.regular,color: Colors.white,),
        ),
      );
    }
  }
}


class AddRoomBottomSheet extends ConsumerStatefulWidget {
  final String? propertyType;
  final Map<String, List<String>> subTypeList;
  final RoomData? initialRoom;
  const AddRoomBottomSheet({  super.key,
    this.propertyType,
    required this.subTypeList,
    this.initialRoom,});

  @override
  ConsumerState<AddRoomBottomSheet> createState() => _AddRoomBottomSheetState();
}

class _AddRoomBottomSheetState extends ConsumerState<AddRoomBottomSheet> {

  final ImagePicker picker = ImagePicker();

  String? selectedSubType;
  String selectedFurnished = "";
  final _occupancyCont = TextEditingController();
  final _availableUnitsCont = TextEditingController();
  final _roomPriceController = TextEditingController();
  final _roomPriceDayController = TextEditingController();
  bool isRoomAvailable = true;
  List<File> roomImages = [];
  Map<String, bool> roomAmenitiesMap = {
    "WiFi": false,
    "AC": false,
    "Kitchen": false,
    "TV": false,
    "Breakfast": false,
  };

  @override
  void initState() {
    super.initState();
    if (widget.initialRoom != null) {
      final r = widget.initialRoom!;
      selectedSubType = r.roomType;
      selectedFurnished = r.furnished;
      _occupancyCont.text = r.occupancy;
      _availableUnitsCont.text = r.availableUnits;
      _roomPriceController.text = r.price;
      _roomPriceDayController.text = r.roomPricePerDay;
      isRoomAvailable = r.isAvailable;
      roomImages = List<File>.from(r.roomImages);
      roomAmenitiesMap.updateAll((key, value) => r.amenities.contains(key));
    }
    print(_roomPriceController.text.toString());
    print("_roomPriceController.text.toString()");
  }

  Future<void> pickRoomImages() async {
    try {
      final picked = await picker.pickMultiImage(
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );
      if (picked.isNotEmpty) {
        setState(
          () => roomImages.addAll(picked.map((e) => File(e.path)).toList()),
        );
      }
    } catch (e) {
      print("Pick images error: $e");
    }
  }

  void _removeImage(File f) => setState(() => roomImages.remove(f));

  @override
  Widget build(BuildContext context) {
    final availableSubtypes =
        widget.subTypeList[widget.propertyType ?? ""] ?? [];


    return SafeArea(
      child: Padding(
        padding:  EdgeInsets.symmetric(horizontal: context.sw*0.02, vertical: context.sh*0.05),
        child: SingleChildScrollView(
          child: Column(
            children: [
              AppText(
                text: widget.initialRoom == null ? "Add Room" : "Edit Room",
                fontType: FontType.bold,
                fontSize: 18,
              ),
              const SizedBox(height: 12),

              // Category dropdown
              if (availableSubtypes.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: DropdownButtonFormField<String>(
                    decoration:InputDecoration(
                      labelText: "Category",
                      border: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Colors.grey, // Default border color
                          width: 1.4,
                        ),
                      ),
                      fillColor: AppColors.background(ref),
                    ),
                    initialValue: selectedSubType,
                    items: availableSubtypes
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (v) => setState(() => selectedSubType = v),
                  ),
                ),

              const SizedBox(height: 6),

              // Furnished options
              const Align(
                alignment: Alignment.centerLeft,
                child: AppText(text: "Furnished", fontType: FontType.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: ["Fully Furnished", "Semi Furnished", "Non Furnished"]
                    .map((item) {
                      final sel = selectedFurnished == item;
                      return ChoiceChip(
                        selectedColor: AppColors.secondary(ref),
                        label: AppText(text:item),
                        selected: sel,
                        onSelected: (_) =>
                            setState(() => selectedFurnished = item),
                      );
                    })
                    .toList(),
              ),

              const SizedBox(height: 12),

              CustomTextField(
                controller: _occupancyCont,
                labelText: "Occupancy",
                keyboardType: TextInputType.number,
                customBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                    color: Colors.grey,
                    width: 1.4,
                  ),
                ),
                fillColor: AppColors.background(ref),
              ),
              const SizedBox(height: 8),
              CustomTextField(
                controller: _availableUnitsCont,
                labelText: "Available Units",
                keyboardType: TextInputType.number,
                customBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                    color: Colors.grey,
                    width: 1.4,
                  ),
                ),
                fillColor: AppColors.background(ref),
              ),
              const SizedBox(height: 8),
              CustomTextField(
                controller: _roomPriceController,
                labelText: "Price",
                keyboardType: TextInputType.number,
                suffixIcon: IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.currency_rupee_sharp),
                ),
                customBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                    color: Colors.grey,
                    width: 1.4,
                  ),
                ),
                fillColor: AppColors.background(ref),
              ),
              const SizedBox(height: 8),
              CustomTextField(
                controller: _roomPriceDayController,
                labelText: "Room Price Per Day",
                keyboardType: TextInputType.number,
                suffixIcon: IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.currency_rupee_sharp),
                ),
                customBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                    color: Colors.grey,
                    width: 1.4,
                  ),
                ),
                fillColor: AppColors.background(ref),
              ),
              const SizedBox(height: 12),

              const Align(
                alignment: Alignment.centerLeft,
                child: AppText(text: "Amenities", fontType: FontType.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: roomAmenitiesMap.keys.map((label) {
                  return FilterChip(
                    selectedColor: AppColors.secondary(ref),
                    label: AppText(text: label),
                    selected: roomAmenitiesMap[label]!,
                    onSelected: (v) =>
                        setState(() => roomAmenitiesMap[label] = v),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
              const Align(
                alignment: Alignment.centerLeft,
                child: AppText(text: "Room Images", fontType: FontType.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  ...roomImages.map(
                    (file) => Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            file,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          right: 0,
                          top: 0,
                          child: GestureDetector(
                            onTap: () => _removeImage(file),
                            child: const CircleAvatar(
                              radius: 10,
                              child: Icon(Icons.close, size: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: pickRoomImages,
                    child: TCustomContainer(
                      height: 90,
                      width: 90,
                      border: Border.all(),
                      borderRadius: BorderRadius.circular(8),
                      child: const Icon(Icons.add),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              PrimaryButton(
                label: widget.initialRoom == null ? "Save Room" : "Update Room",
                onTap: () {
                  if (selectedSubType == null ||
                      selectedFurnished.isEmpty ||
                      _occupancyCont.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: AppText(text: "Please fill required fields",color: Colors.white,),
                      ),
                    );
                    return;
                  }

                  final selectedAmenities = roomAmenitiesMap.entries
                      .where((e) => e.value)
                      .map((e) => e.key)
                      .toList();

                  final roomData = RoomData(
                    roomType: selectedSubType!,
                    furnished: selectedFurnished,
                    occupancy: _occupancyCont.text.trim(),
                    price: _roomPriceController.text.trim(),
                    roomPricePerDay: _roomPriceDayController.text.trim(),
                    isAvailable: isRoomAvailable,
                    availableUnits: _availableUnitsCont.text.trim(),
                    amenities: selectedAmenities,
                    roomImages: roomImages,
                  );

                  Navigator.of(context).pop(roomData);
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}


