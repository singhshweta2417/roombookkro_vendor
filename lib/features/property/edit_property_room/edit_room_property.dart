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
import 'package:room_book_kro_vendor/features/property/property_model.dart';

class FinalEditScreenProperty extends ConsumerStatefulWidget {
  const FinalEditScreenProperty({super.key});

  @override
  ConsumerState<FinalEditScreenProperty> createState() =>
      _FinalEditScreenPropertyState();
}

class _FinalEditScreenPropertyState
    extends ConsumerState<FinalEditScreenProperty> {
  final ImagePicker picker = ImagePicker();
  final List<RoomData> roomsList = [];

  final Map<String, List<String>> subTypeList = {
    "Hotel": ["Standard", "Deluxe", "Suite"],
    "Resort": ["Cottage", "Villa", "Tent"],
    "Flat": ["1BHK", "2BHK", "3BHK"],
    "PG": ["Single Sharing", "Double Sharing", "Triple Sharing"],
    "Apartment": ["1BHK", "2BHK", "3BHK"],
  };

  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // ✅ Pre-fill existing rooms (only once)
    if (!_isInitialized) {
      final args = ModalRoute.of(context)?.settings.arguments as Map?;
      final existingData = args?["existingPropertyData"] as Data?;

      if (existingData != null && existingData.rooms != null) {
        setState(() {
          // Convert existing API rooms to RoomData
          for (var room in existingData.rooms!) {
            roomsList.add(
              RoomData(
                roomType: room.roomType ?? "",
                furnished: room.furnished ?? "",
                occupancy: room.occupancy?.toString() ?? "1",
                price: room.price?.toString() ?? "0",
                roomPricePerDay: room.roomPricePerDay?.toString() ?? "0",
                isAvailable: room.isAvailable ?? true,
                availableUnits: room.availableUnits?.toString() ?? "1",
                amenities:
                    room.amenities
                        ?.map((a) => a.name?.toString() ?? "")
                        .toList() ??
                    [],
                roomImages: [], // Existing images are network URLs, not Files
                networkImages:
                    room.images ?? [], // Store network URLs separately
              ),
            );
          }
        });
      }
      _isInitialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map;

    // ✅ Get property ID (null if adding new property)
    final String? propertyId = args["propertyId"];
    final Data? existingPropertyData = args["existingPropertyData"];
    final isEditing = propertyId != null;

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
          text: "Edit Property - Add Rooms",
          fontType: FontType.bold,
          fontSize: AppConstants.twentyTwo,
          color: Colors.black,
        ),
      ),
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
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
                      "Added rooms: $roomCount • Expected: ${roomCount ?? '—'}",
                  fontType: FontType.regular,
                ),
              ],
            ),
          ),

          SizedBox(height: context.sh * 0.02),

          // Preview list of added rooms
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppText(text: "Rooms added", fontType: FontType.bold),
              if (isEditing && existingPropertyData?.rooms != null)
                AppText(
                  text: "(${existingPropertyData!.rooms!.length} existing)",
                  fontSize: 12,
                  color: Colors.grey,
                ),
            ],
          ),
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
                          margin: const EdgeInsets.only(bottom: 12),
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
                              // ✅ Show room image (File or Network)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: r.roomImages.isNotEmpty
                                    ? Image.file(
                                        r.roomImages.first,
                                        width: 90,
                                        height: 70,
                                        fit: BoxFit.cover,
                                      )
                                    : (r.networkImages?.isNotEmpty == true
                                          ? Image.network(
                                              r.networkImages!.first,
                                              width: 90,
                                              height: 70,
                                              fit: BoxFit.cover,
                                            )
                                          : Container(
                                              width: 90,
                                              height: 70,
                                              decoration: BoxDecoration(
                                                color: Colors.grey.shade100,
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: const Icon(
                                                Icons.hotel,
                                                color: Colors.grey,
                                                size: 30,
                                              ),
                                            )),
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
                                          onTap: () => _editRoom(
                                            idx,
                                            selectedPropertyType,
                                          ),
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
                shape: const RoundedRectangleBorder(
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
                  const SnackBar(
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

          /// ✅ Final Submit — Update or Add based on propertyId
          PrimaryButton(
            label: "Update Property",
            isLoading: ref.watch(addPropertyProvider).isLoading,
            onTap: () {
              if (roomsList.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: AppText(
                      text: "Add at least one room",
                      fontType: FontType.regular,
                      color: Colors.white,
                    ),
                  ),
                );
                return;
              }
              final List<String> amenitiesForApi = mainAmenitiesList;
              final List<String> rulesForApi = mainAmenitiesList;
              final depositAmount = args["depositAmount"]?.toString() ?? "0";

              ref
                  .read(addPropertyProvider.notifier)
                  .updatePropertyApi(
                    propertyId: propertyId.toString(),
                    residenceId: existingPropertyData?.residencyId.toString()?? "",
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
                    existingMainImage: existingPropertyData?.mainImage,
                    existingPropertyImages: existingPropertyData?.images,
                  );
            },
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Future<void> _editRoom(int index, selectedPropertyType) async {
    final existing = roomsList[index];
    final editedRoom = await showModalBottomSheet<RoomData>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
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
        const SnackBar(
          content: AppText(
            text: "Room updated!",
            fontType: FontType.regular,
            color: Colors.white,
          ),
        ),
      );
    }
  }
}

class AddRoomBottomSheet extends ConsumerStatefulWidget {
  final String? propertyType;
  final Map<String, List<String>> subTypeList;
  final RoomData? initialRoom;

  const AddRoomBottomSheet({
    super.key,
    this.propertyType,
    required this.subTypeList,
    this.initialRoom,
  });

  @override
  ConsumerState<AddRoomBottomSheet> createState() =>
      _AddRoomBottomSheetState();
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
  }

  @override
  void dispose() {
    _occupancyCont.dispose();
    _availableUnitsCont.dispose();
    _roomPriceController.dispose();
    _roomPriceDayController.dispose();
    super.dispose();
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

    return Container(
      decoration: BoxDecoration(
        color: AppColors.background(ref),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ✅ Header with drag handle
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Expanded(
                          child: AppText(
                            text: widget.initialRoom == null
                                ? "Add New Room"
                                : "Edit Room",
                            fontType: FontType.bold,
                            fontSize: 20,
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(
                            Icons.close,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(height: 1, color: Colors.grey[300]),
                ],
              ),
            ),

            // ✅ Scrollable content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ✅ Room Type Section
                    _buildSectionTitle("Room Details"),
                    const SizedBox(height: 12),

                    // Category dropdown
                    if (availableSubtypes.isNotEmpty)
                      _buildDropdown(
                        label: "Room Category*",
                        value: selectedSubType,
                        items: availableSubtypes,
                        onChanged: (v) => setState(() => selectedSubType = v),
                      ),

                    const SizedBox(height: 16),

                    // ✅ Furnished options
                    const AppText(
                      text: "Furnished Type*",
                      fontType: FontType.semiBold,
                      fontSize: 14,
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        "Fully Furnished",
                        "Semi Furnished",
                        "Non Furnished"
                      ].map((item) {
                        final sel = selectedFurnished == item;
                        return ChoiceChip(
                          selectedColor: AppColors.secondary(ref),
                          backgroundColor: Colors.grey[100],
                          label: AppText(
                            text: item,
                            fontSize: 13,
                            color: sel ? Colors.white : Colors.black87,
                          ),
                          selected: sel,
                          onSelected: (_) =>
                              setState(() => selectedFurnished = item),
                          side: BorderSide(
                            color: sel
                                ? AppColors.secondary(ref)
                                : Colors.grey[300]!,
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 24),

                    // ✅ Occupancy & Units
                    _buildSectionTitle("Capacity & Availability"),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _occupancyCont,
                            label: "Occupancy*",
                            hint: "e.g., 2",
                            prefixIcon: Icons.person_outline,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildTextField(
                            controller: _availableUnitsCont,
                            label: "Available Units*",
                            hint: "e.g., 5",
                            prefixIcon: Icons.meeting_room_outlined,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // ✅ Pricing Section
                    _buildSectionTitle("Pricing"),
                    const SizedBox(height: 12),

                    _buildTextField(
                      controller: _roomPriceController,
                      label: "Price per Month*",
                      hint: "Enter monthly rent",
                      prefixIcon: Icons.currency_rupee,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: _roomPriceDayController,
                      label: "Price per Day*",
                      hint: "Enter daily rent",
                      prefixIcon: Icons.currency_rupee,
                      keyboardType: TextInputType.number,
                    ),

                    const SizedBox(height: 24),

                    // ✅ Amenities Section
                    _buildSectionTitle("Room Amenities"),
                    const SizedBox(height: 12),

                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: roomAmenitiesMap.keys.map((label) {
                        final isSelected = roomAmenitiesMap[label]!;
                        return FilterChip(
                          selectedColor: AppColors.secondary(ref),
                          backgroundColor: Colors.grey[100],
                          label: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _getAmenityIcon(label),
                                size: 16,
                                color:
                                isSelected ? Colors.white : Colors.black54,
                              ),
                              const SizedBox(width: 6),
                              AppText(
                                text: label,
                                fontSize: 13,
                                color:
                                isSelected ? Colors.white : Colors.black87,
                              ),
                            ],
                          ),
                          selected: isSelected,
                          onSelected: (v) =>
                              setState(() => roomAmenitiesMap[label] = v),
                          side: BorderSide(
                            color: isSelected
                                ? AppColors.secondary(ref)
                                : Colors.grey[300]!,
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 24),

                    // ✅ Room Images Section
                    _buildSectionTitle("Room Images"),
                    const SizedBox(height: 8),
                    AppText(
                      text: "Add at least 3 photos for better visibility",
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(height: 12),

                    // Images grid
                    if (roomImages.isNotEmpty)
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                        itemCount: roomImages.length,
                        itemBuilder: (context, index) {
                          final file = roomImages[index];
                          return Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(
                                  file,
                                  width: double.infinity,
                                  height: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                right: 4,
                                top: 4,
                                child: GestureDetector(
                                  onTap: () => _removeImage(file),
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.2),
                                          blurRadius: 4,
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      size: 14,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),

                    const SizedBox(height: 12),

                    // Add images button
                    GestureDetector(
                      onTap: pickRoomImages,
                      child: Container(
                        height: 120,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.grey[300]!,
                            width: 2,
                            style: BorderStyle.solid,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_photo_alternate_outlined,
                              size: 40,
                              color: AppColors.secondary(ref),
                            ),
                            const SizedBox(height: 8),
                            AppText(
                              text: roomImages.isEmpty
                                  ? "Add Room Photos"
                                  : "Add More Photos",
                              fontType: FontType.medium,
                              color: Colors.grey[700],
                            ),
                            const SizedBox(height: 4),
                            AppText(
                              text: "Tap to upload",
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // ✅ Bottom Action Buttons
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  if (widget.initialRoom != null) ...[
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: BorderSide(color: Colors.grey[300]!),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const AppText(
                          text: "Cancel",
                          fontType: FontType.medium,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    flex: 2,
                    child: PrimaryButton(
                      label: widget.initialRoom == null
                          ? "Add Room"
                          : "Update Room",
                      onTap: _saveRoom,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ Save room method
  void _saveRoom() {
    if (selectedSubType == null ||
        selectedFurnished.isEmpty ||
        _occupancyCont.text.trim().isEmpty ||
        _availableUnitsCont.text.trim().isEmpty ||
        _roomPriceController.text.trim().isEmpty ||
        _roomPriceDayController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: AppText(
            text: "Please fill all required fields",
            color: Colors.white,
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (roomImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: AppText(
            text: "Please add at least one room image",
            color: Colors.white,
          ),
          backgroundColor: Colors.orange,
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
      networkImages: widget.initialRoom?.networkImages,
    );

    Navigator.of(context).pop(roomData);
  }

  // ✅ Helper: Section Title
  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: AppColors.secondary(ref),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        AppText(
          text: title,
          fontType: FontType.bold,
          fontSize: 16,
        ),
      ],
    );
  }

  // ✅ Helper: TextField
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    IconData? prefixIcon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          text: label,
          fontType: FontType.semiBold,
          fontSize: 14,
        ),
        const SizedBox(height: 8),
        CustomTextField(
          controller: controller,
          hintText: hint,
          keyboardType: keyboardType,
          prefixIcon: prefixIcon != null
              ? Icon(prefixIcon, size: 20, color: Colors.grey[600])
              : null,
          customBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!, width: 1.5),
          ),
          fillColor: Colors.white,
        ),
      ],
    );
  }

  // ✅ Helper: Dropdown
  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          text: label,
          fontType: FontType.semiBold,
          fontSize: 14,
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          decoration: InputDecoration(
            hintText: "Select category",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!, width: 1.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.secondary(ref), width: 2),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          value: value,
          items: items
              .map((e) => DropdownMenuItem(
            value: e,
            child: AppText(text: e),
          ))
              .toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  // ✅ Helper: Get amenity icon
  IconData _getAmenityIcon(String amenity) {
    switch (amenity.toLowerCase()) {
      case 'wifi':
        return Icons.wifi;
      case 'ac':
        return Icons.ac_unit;
      case 'kitchen':
        return Icons.kitchen_outlined;
      case 'tv':
        return Icons.tv;
      case 'breakfast':
        return Icons.restaurant_outlined;
      default:
        return Icons.check_circle_outline;
    }
  }
}
