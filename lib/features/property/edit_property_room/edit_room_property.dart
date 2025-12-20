import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:room_book_kro_vendor/core/utils/context_extensions.dart';
import 'package:room_book_kro_vendor/core/widgets/custom_app_bar.dart';
import 'package:room_book_kro_vendor/core/widgets/custom_scaffold.dart';
import 'package:room_book_kro_vendor/core/widgets/custom_text_field.dart';
import 'package:room_book_kro_vendor/core/widgets/primary_button.dart';
import 'package:room_book_kro_vendor/features/property/view_model/add_property_view_model.dart';
import '../../../core/constants/app_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../../../generated/assets.dart';
import 'package:room_book_kro_vendor/features/property/property_model.dart';
import '../view_model/room_type_view_model.dart';
import 'edit_room_bottom_sheet.dart';

class FinalEditScreenProperty extends ConsumerStatefulWidget {
  const FinalEditScreenProperty({super.key});

  @override
  ConsumerState<FinalEditScreenProperty> createState() =>
      _FinalEditScreenPropertyState();
}

class _FinalEditScreenPropertyState
    extends ConsumerState<FinalEditScreenProperty> {
  final ImagePicker picker = ImagePicker();
  List<RoomData> roomsList = [];
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController roleController = TextEditingController();
  final TextEditingController userEmailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController checkInController = TextEditingController();
  final TextEditingController checkOutController = TextEditingController();

  bool _isInitialized = false;
  bool payAtProperty = false;
  bool isAvailable = false;

  // ✅ Add these variables for existing images
  List<Map<String, dynamic>> _existingRoomImages = [];
  String? _existingMainImage;
  List<String> _existingPropertyImages = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)!.settings.arguments as Map;
      final selectedPropertyType = args["selectedPropertyTypeId"];
      ref
          .read(getRoomTypeProvider.notifier)
          .roomTypeApi(selectedPropertyType.toString());
      _initializeFormData(args);
    });
  }

  void _initializeFormData(Map args) {
    if (_isInitialized) return;

    final existingData = args["existingPropertyData"] as AddPropertyListData?;

    if (existingData != null) {
      userNameController.text = existingData.owner ?? '';
      roleController.text = existingData.role ?? '';
      userEmailController.text = existingData.email ?? '';
      phoneController.text = existingData.contactNumber ?? '';
      checkInController.text = existingData.checkIn ?? '';
      checkOutController.text = existingData.checkOut ?? '';
      payAtProperty = existingData.payAtProperty ?? false;
      isAvailable = existingData.isAvailable ?? false;
      _existingMainImage = existingData.mainImage;
      _existingPropertyImages = existingData.images?.cast<String>() ?? [];

      if (existingData.rooms != null && existingData.rooms!.isNotEmpty) {
        roomsList = existingData.rooms!.map((room) {
          // ✅ Store existing room images
          final roomIndex = existingData.rooms!.indexOf(room);
          if (room.images != null && room.images!.isNotEmpty) {
            _existingRoomImages.add({
              'roomId': room.roomId,
              'images': room.images!.cast<String>(),
            });
          }

          return RoomData(
            roomTypeName: room.roomType ?? '',
            roomType: room.roomTypeId?.toString() ?? '',
            furnished: room.furnished ?? '',
            occupancy: room.occupancy?.toString() ?? '1',
            price: room.price?.toString() ?? '0',
            availableUnits: room.availableUnits?.toString() ?? '0',
            amenitiesIds:
                room.amenities?.map((a) => a.sId ?? '').toList() ?? [],
            roomImages: [],
            roomPricePerDay: room.roomPricePerDay?.toString() ?? '0',
            isAvailable: true,
          );
        }).toList();
      }

      setState(() {
        _isInitialized = true;
      });
    }
  }

  // ✅ Method to get existing room images
  List<String> _getExistingRoomImages(int roomIndex) {
    if (roomIndex < _existingRoomImages.length) {
      return _existingRoomImages[roomIndex]['images'] ?? [];
    }
    return [];
  }

  String _getTotalAvailableUnits() {
    if (roomsList.isEmpty) return "0";
    int total = 0;
    for (var room in roomsList) {
      final units = int.tryParse(room.availableUnits) ?? 0;
      total += units;
    }
    return total.toString();
  }

  Future<void> _selectTime(
    BuildContext context,
    TextEditingController controller,
  ) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      initialEntryMode: TimePickerEntryMode.dial,
      helpText: 'Select Time',
      cancelText: 'Cancel',
      confirmText: 'Confirm',
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: Theme(
            data: ThemeData.light().copyWith(
              colorScheme: ColorScheme.light(
                primary: AppColors.secondary(ref),
                onPrimary: Colors.white,
                surface: Colors.white,
                onSurface: Colors.black,
                secondary: AppColors.secondary(ref),
                onSecondary: Colors.white,
              ),
              timePickerTheme: TimePickerThemeData(
                backgroundColor: Colors.white,
                hourMinuteShape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: AppColors.secondary(ref).withValues(alpha: 0.2),
                  ),
                ),
                dayPeriodShape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                dayPeriodColor: AppColors.secondary(ref).withValues(alpha: 0.5),
                dayPeriodTextColor: AppColors.text(ref),
                dialHandColor: AppColors.secondary(ref),
                dialBackgroundColor: AppColors.secondary(
                  ref,
                ).withValues(alpha: 0.1),
                dialTextColor: Colors.black87,
                entryModeIconColor: AppColors.secondary(ref),
                helpTextStyle: TextStyle(
                  fontSize: context.sh * 0.025,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  fontFamily: Assets.fontsNotoSansRegular,
                ),
              ),
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                  textStyle: TextStyle(
                    fontSize: context.sh * 0.015,
                    fontWeight: FontWeight.w600,
                    fontFamily: Assets.fontsNotoSansRegular,
                  ),
                ),
              ),
            ),
            child: child!,
          ),
        );
      },
    );

    if (picked != null) {
      final now = DateTime.now();
      final dateTime = DateTime(
        now.year,
        now.month,
        now.day,
        picked.hour,
        picked.minute,
      );

      final formattedTime = DateFormat('hh:mm a').format(dateTime);
      controller.text = formattedTime;
    }
  }

  @override
  void dispose() {
    userNameController.dispose();
    roleController.dispose();
    userEmailController.dispose();
    phoneController.dispose();
    checkInController.dispose();
    checkOutController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map;

    // Extract all arguments
    final propertyId = args["propertyId"];
    final propertyTitle = args["name"] ?? args["propertyTitle"];
    final coordinates = args["coordinates"];
    final pincode = args["pincode"];
    final state = args["state"];
    final city = args["city"];
    final address = args["address"];
    final selectedPropertyType = args["selectedPropertyTypeId"];
    final website = args["website"];
    final description = args["description"];
    final discount = args["discount"];
    final oldMrp = args["oldMrp"];
    final tax = args["tax"];
    final propertyDayPrice = args["propertyDayPrice"];
    final propertyNightPrice = args["propertyNightPrice"];
    final propertyMonthPrice = args["propertyMonthPrice"];
    final flatNo = args["flatNo"] ?? args["landmark"];
    final additionalAddress = args["additionalAddress"];
    final depositAmount = args["depositAmount"];

    final List<String> propertyRules =
        (args["propertyRules"] as List?)?.cast<String>() ?? [];

    // Handle amenities
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

    final roomTypeState = ref.watch(getRoomTypeProvider);
    final Map<int, List<String>> subTypeList = {};
    if (roomTypeState is GetRoomTypeSuccess) {
      final options = roomTypeState.roomType.options ?? [];
      for (var option in options) {
        final propertyTypeId = option.type ?? 0;
        final label = option.label ?? '';
        if (!subTypeList.containsKey(propertyTypeId)) {
          subTypeList[propertyTypeId] = [];
        }
        subTypeList[propertyTypeId]!.add(label);
      }
    }
    final List<File> mainImage =
        (args["mainImage"] as List?)?.cast<File>() ?? [];
    final List<File> propertyImages =
        (args["propertyImages"] as List?)?.cast<File>() ?? [];

    return CustomScaffold(
      appBar: CustomAppBar(
        middle: AppText(
          text: "Edit Rooms",
          fontType: FontType.bold,
          fontSize: AppConstants.twentyTwo,
          color: Colors.black,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.background(ref), Colors.grey.shade50],
          ),
        ),
        child: roomTypeState is GetRoomTypeLoading
            ? const Center(child: CircularProgressIndicator())
            : roomTypeState is GetRoomTypeError
            ? Center(
                child: AppText(
                  text: roomTypeState.error,
                  fontType: FontType.regular,
                  color: Colors.red,
                ),
              )
            : ListView(
                padding: EdgeInsets.symmetric(vertical: context.sh * 0.02),
                children: [
                  // ✅ Property Info Card with Images
                  _buildPropertyImageSection(args),

                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.secondary(ref).withValues(alpha: 0.1),
                          AppColors.secondary(ref).withValues(alpha: 0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.secondary(ref).withValues(alpha: 0.3),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.secondary(
                            ref,
                          ).withValues(alpha: 0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.secondary(ref),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.apartment,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AppText(
                                    text: propertyTitle ?? "Property",
                                    fontType: FontType.bold,
                                    fontSize: 20,
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.location_on,
                                        size: 16,
                                        color: Colors.grey.shade600,
                                      ),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: AppText(
                                          text: "$city, $state • $pincode",
                                          fontType: FontType.regular,
                                          fontSize: 14,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildStatItem(
                                icon: Icons.hotel_outlined,
                                label: "Total Rooms",
                                value: "${roomsList.length}",
                                color: Colors.green,
                              ),
                              Container(
                                height: 40,
                                width: 1,
                                color: Colors.grey.shade300,
                              ),
                              _buildStatItem(
                                icon: Icons.checklist_rounded,
                                label: "Available Units",
                                value: _getTotalAvailableUnits(),
                                color: Colors.blue,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Contact Information Section
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.person_outline,
                              color: AppColors.secondary(ref),
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            const AppText(
                              text: "Contact Information",
                              fontType: FontType.bold,
                              fontSize: 18,
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            AppText(
                              text: "Property Availability",
                              fontType: FontType.bold,
                              fontSize: context.sh*0.017,
                            ),
                            Switch(
                              value: isAvailable,
                              activeThumbColor: AppColors.secondary(ref),
                              activeTrackColor: AppColors.secondary(
                                ref,
                              ).withValues(alpha   : 0.4),
                              inactiveTrackColor: AppColors.secondary(
                                ref,
                              ).withValues(alpha: 0.4),
                              inactiveThumbColor: Colors.grey.withValues(
                                alpha: 0.5,
                              ),
                              onChanged: (value) {
                                setState(() {
                                  isAvailable = value;
                                });
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        CustomTextField(
                          textCapitalization: TextCapitalization.words,
                          controller: userNameController,
                          hintText: "Enter your full name",
                          labelText: "Name",
                          suffixIcon: const Icon(Icons.person),
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          controller: roleController,
                          textCapitalization: TextCapitalization.words,
                          maxLines: 1,
                          hintText: "Enter your role (e.g., Owner, Manager)",
                          labelText: "Role",
                          suffixIcon: const Icon(Icons.work_outline),
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          controller: userEmailController,
                          hintText: "Enter your email address",
                          labelText: "Email",
                          prefixIcon: const Icon(Icons.email_outlined),
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          controller: phoneController,
                          hintText: "Enter your phone number",
                          maxLength: 10,
                          labelText: "Phone Number",
                          prefixIcon: const Icon(Icons.phone_outlined),
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 24),

                        // Check-in and Check-out Times
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              color: AppColors.secondary(ref),
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            const AppText(
                              text: "Property Timing",
                              fontType: FontType.bold,
                              fontSize: 18,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () =>
                                    _selectTime(context, checkInController),
                                child: AbsorbPointer(
                                  child: CustomTextField(
                                    maxLines: 1,
                                    controller: checkInController,
                                    hintText: "Select time",
                                    labelText: "Check-in Time",
                                    suffixIcon: Icon(
                                      Icons.access_time,
                                      color: AppColors.secondary(ref),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: GestureDetector(
                                onTap: () =>
                                    _selectTime(context, checkOutController),
                                child: AbsorbPointer(
                                  child: CustomTextField(
                                    maxLines: 1,
                                    controller: checkOutController,
                                    hintText: "Select time",
                                    labelText: "Check-out Time",
                                    suffixIcon: Icon(
                                      Icons.access_time,
                                      color: AppColors.secondary(ref),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Pay at Property Toggle
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.secondary(
                              ref,
                            ).withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.secondary(
                                ref,
                              ).withValues(alpha: 0.2),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: payAtProperty
                                      ? AppColors.secondary(
                                          ref,
                                        ).withValues(alpha: 0.15)
                                      : Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  Icons.payment,
                                  color: payAtProperty
                                      ? AppColors.secondary(ref)
                                      : Colors.grey.shade600,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const AppText(
                                      text: "Pay at Property",
                                      fontType: FontType.bold,
                                      fontSize: 16,
                                    ),
                                    const SizedBox(height: 2),
                                    AppText(
                                      text:
                                          "Allow customers to pay at property",
                                      fontType: FontType.regular,
                                      fontSize: 13,
                                      color: Colors.grey.shade600,
                                    ),
                                  ],
                                ),
                              ),
                              Switch(
                                value: payAtProperty,
                                activeThumbColor: AppColors.secondary(ref),
                                activeTrackColor: AppColors.secondary(
                                  ref,
                                ).withValues(alpha: 0.4),
                                inactiveTrackColor: AppColors.secondary(
                                  ref,
                                ).withValues(alpha: 0.4),
                                inactiveThumbColor: Colors.grey.withValues(
                                  alpha: 0.5,
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    payAtProperty = value;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Rooms Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const AppText(
                        text: "Your Rooms",
                        fontType: FontType.bold,
                        fontSize: 20,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.secondary(
                            ref,
                          ).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: AppText(
                          text: "${roomsList.length} rooms",
                          fontType: FontType.semiBold,
                          fontSize: 14,
                          color: AppColors.secondary(ref),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Rooms List or Empty State
                  roomsList.isEmpty
                      ? Container(
                          padding: const EdgeInsets.all(40),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.grey.shade300,
                              width: 2,
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.meeting_room_outlined,
                                size: 64,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 16),
                              AppText(
                                text: "No rooms added yet",
                                fontType: FontType.bold,
                                fontSize: 18,
                                color: Colors.grey.shade700,
                              ),
                              const SizedBox(height: 8),
                              AppText(
                                text:
                                    "Tap the button below to add your first room",
                                fontType: FontType.regular,
                                fontSize: 14,
                                color: Colors.grey.shade500,
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        )
                      : Column(
                          children: roomsList.asMap().entries.map((entry) {
                            final idx = entry.key;
                            final r = entry.value;
                            return _buildEnhancedRoomCard(
                              idx,
                              r,
                              selectedPropertyType,
                            );
                          }).toList(),
                        ),
                  const SizedBox(height: 24),

                  // Add New Room Button
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.secondary(
                            ref,
                          ).withValues(alpha: 0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: PrimaryButton(
                      label: "+ Add New Room",
                      onTap: subTypeList.isEmpty
                          ? null
                          : () async {
                              final newRoom =
                                  await showModalBottomSheet<RoomData>(
                                    context: context,
                                    isScrollControlled: true,
                                    backgroundColor: Colors.transparent,
                                    builder: (_) => Container(
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(24),
                                        ),
                                      ),
                                      child: Padding(
                                        padding: EdgeInsets.only(
                                          bottom: MediaQuery.of(
                                            context,
                                          ).viewInsets.bottom,
                                        ),
                                        child: EditRoomBottomSheet(
                                          propertyType: selectedPropertyType,
                                          subTypeList: subTypeList,
                                        ),
                                      ),
                                    ),
                                  );

                              if (newRoom != null) {
                                setState(() => roomsList.add(newRoom));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Row(
                                      children: const [
                                        Icon(
                                          Icons.check_circle,
                                          color: Colors.white,
                                        ),
                                        SizedBox(width: 12),
                                        AppText(
                                          text: "Room added successfully!",
                                          fontType: FontType.semiBold,
                                          color: Colors.white,
                                        ),
                                      ],
                                    ),
                                    backgroundColor: Colors.green,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                );
                              }
                            },
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Submit Button
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        colors: [
                          AppColors.secondary(ref),
                          AppColors.secondary(ref).withValues(alpha: 0.8),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.secondary(
                            ref,
                          ).withValues(alpha: 0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: PrimaryButton(
                      label: "Update Property",
                      isLoading: ref.watch(addPropertyProvider).isLoading,
                      onTap: () {
                        if (roomsList.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: const [
                                  Icon(
                                    Icons.warning_amber,
                                    color: Colors.white,
                                  ),
                                  SizedBox(width: 12),
                                  AppText(
                                    text: "Please add at least one room",
                                    fontType: FontType.semiBold,
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                              backgroundColor: Colors.orange,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          );
                          return;
                        }

                        ref
                            .read(addPropertyProvider.notifier)
                            .updatePropertyApi(
                              residenceId: propertyId.toString(),
                              userName: userNameController.text.toString(),
                              role: roleController.text.toString(),
                              userEmail: userEmailController.text.toString(),
                              phone: phoneController.text.toString(),
                              checkIn: checkInController.text.toString(),
                              checkOut: checkOutController.text.toString(),
                              payAtProperty: payAtProperty,
                              rules: propertyRules,
                              name: propertyTitle ?? "",
                              propertyType: selectedPropertyType.toString(),
                              landmark: flatNo.toString(),
                              additionalAddress: additionalAddress,
                              address: address ?? "",
                              city: city ?? "",
                              state: state ?? "",
                              pincode: pincode?.toString() ?? "",
                              coordinates:
                                  coordinates ?? {"lat": 0.0, "lng": 0.0},
                              mainImage: mainImage,
                              propertyImages: propertyImages,
                              pricePerMonth:
                                  propertyMonthPrice?.toString() ?? "",
                              depositAmount: depositAmount?.toString() ?? "0",
                              amenitiesMain: mainAmenitiesList,
                              website: website?.toString() ?? "",
                              pricePerDay: propertyDayPrice?.toString() ?? "",
                              availableRooms: _getTotalAvailableUnits(),
                              description: description?.toString() ?? "",
                              oldMrp: oldMrp?.toString() ?? "",
                              tax: tax?.toString() ?? "",
                              isAvailable: isAvailable,
                              pricePerNight:
                                  propertyNightPrice?.toString() ?? "",
                              discount: discount?.toString() ?? "",
                              rooms: roomsList,
                              context: context,
                            );
                      },
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
      ),
    );
  }

  // ✅ New method to show property images
  Widget _buildPropertyImageSection(Map args) {
    final hasNewMainImage =
        args["mainImage"] is List && (args["mainImage"] as List).isNotEmpty;
    final hasNewPropertyImages =
        args["propertyImages"] is List &&
        (args["propertyImages"] as List).isNotEmpty;

    return Column(
      children: [
        // Main Image
        if (_existingMainImage != null || hasNewMainImage)
          Container(
            height: 200,
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: hasNewMainImage
                  ? Image.file(
                      (args["mainImage"] as List<File>).first,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    )
                  : _existingMainImage != null
                  ? CachedNetworkImage(
                      imageUrl: _existingMainImage!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      placeholder: (context, url) => Container(
                        color: Colors.grey.shade200,
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppColors.secondary(ref),
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey.shade200,
                        child: const Center(
                          child: Icon(
                            Icons.image_not_supported,
                            color: Colors.grey,
                            size: 50,
                          ),
                        ),
                      ),
                    )
                  : Container(
                      color: Colors.grey.shade200,
                      child: const Center(
                        child: Icon(Icons.image, color: Colors.grey, size: 50),
                      ),
                    ),
            ),
          ),

        // Property Images Grid
        if (_existingPropertyImages.isNotEmpty || hasNewPropertyImages)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 8, bottom: 8),
                  child: AppText(
                    text: "Property Images",
                    fontType: FontType.bold,
                    fontSize: 16,
                  ),
                ),
                SizedBox(
                  height: 100,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      // Show existing images
                      ..._existingPropertyImages.map((imageUrl) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: CachedNetworkImage(
                              imageUrl: imageUrl,
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                width: 100,
                                height: 100,
                                color: Colors.grey.shade200,
                                child: Center(
                                  child: CircularProgressIndicator(
                                    color: AppColors.secondary(ref),
                                    strokeWidth: 2,
                                  ),
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                width: 100,
                                height: 100,
                                color: Colors.grey.shade200,
                                child: const Icon(
                                  Icons.image_not_supported,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),

                      // Show new images
                      if (hasNewPropertyImages)
                        ...(args["propertyImages"] as List<File>).map((file) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(
                                file,
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                            ),
                          );
                        }).toList(),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 6),
        AppText(text: value, fontType: FontType.bold, fontSize: 20),
        AppText(
          text: label,
          fontType: FontType.regular,
          fontSize: 12,
          color: Colors.grey.shade600,
        ),
      ],
    );
  }

  Widget _buildEnhancedRoomCard(int idx, RoomData r, selectedPropertyType) {
    final existingImages = _getExistingRoomImages(idx);
    final hasExistingImages = existingImages.isNotEmpty;
    final hasNewImages = r.roomImages.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Image Section - Show either existing or new images
            if (hasExistingImages || hasNewImages)
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    child: hasNewImages
                        ? Image.file(
                            r.roomImages.first,
                            width: double.infinity,
                            height: 180,
                            fit: BoxFit.cover,
                          )
                        : hasExistingImages
                        ? CachedNetworkImage(
                            imageUrl: existingImages.first,
                            width: double.infinity,
                            height: 180,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              height: 180,
                              color: Colors.grey.shade200,
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: AppColors.secondary(ref),
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              height: 180,
                              color: Colors.grey.shade200,
                              child: const Icon(
                                Icons.image_not_supported,
                                color: Colors.grey,
                                size: 50,
                              ),
                            ),
                          )
                        : Container(
                            height: 180,
                            color: Colors.grey.shade200,
                            child: const Center(
                              child: Icon(
                                Icons.image,
                                color: Colors.grey,
                                size: 50,
                              ),
                            ),
                          ),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.image,
                            color: Colors.white,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          AppText(
                            text: hasNewImages
                                ? "${r.roomImages.length}"
                                : hasExistingImages
                                ? "${existingImages.length}"
                                : "0",
                            color: Colors.white,
                            fontType: FontType.semiBold,
                            fontSize: 12,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              )
            else
              Container(
                height: 180,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.hotel_outlined,
                    color: Colors.grey.shade400,
                    size: 64,
                  ),
                ),
              ),

            // Content Section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppText(
                              text: r.roomTypeName,
                              fontType: FontType.bold,
                              fontSize: 18,
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: AppText(
                                text: r.furnished,
                                fontType: FontType.medium,
                                fontSize: 12,
                                color: Colors.blue.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          _buildActionButton(
                            icon: Icons.edit_outlined,
                            color: Colors.blue,
                            onTap: () =>
                                _editRoom(idx, selectedPropertyType, {}),
                          ),
                          const SizedBox(width: 8),
                          _buildActionButton(
                            icon: Icons.delete_outline,
                            color: Colors.red,
                            onTap: () =>
                                setState(() => roomsList.removeAt(idx)),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _buildInfoChip(
                        icon: Icons.currency_rupee,
                        label: r.price,
                        color: Colors.green,
                      ),
                      _buildInfoChip(
                        icon: Icons.meeting_room,
                        label: "${r.availableUnits} units",
                        color: Colors.orange,
                      ),
                      _buildInfoChip(
                        icon: Icons.people_outline,
                        label: "${r.occupancy} person",
                        color: Colors.purple,
                      ),
                    ],
                  ),
                  if (r.amenitiesIds.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    const Divider(),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          size: 16,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: AppText(
                            text: "${r.amenitiesIds.length} amenities",
                            fontType: FontType.medium,
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 6),
          AppText(
            text: label,
            fontType: FontType.semiBold,
            fontSize: 13,
            color: color,
          ),
        ],
      ),
    );
  }

  Future<void> _editRoom(
    int index,
    selectedPropertyType,
    Map<int, List<String>> subTypeList,
  ) async {
    final existing = roomsList[index];
    final editedRoom = await showModalBottomSheet<RoomData>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: EditRoomBottomSheet(
            propertyType: selectedPropertyType.toString(),
            subTypeList: subTypeList,
            initialRoom: existing,
          ),
        ),
      ),
    );
    if (editedRoom != null) {
      setState(() => roomsList[index] = editedRoom);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 12),
              AppText(
                text: "Room updated successfully!",
                fontType: FontType.semiBold,
                color: Colors.white,
              ),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }
}
