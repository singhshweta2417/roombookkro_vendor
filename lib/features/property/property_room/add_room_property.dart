import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:room_book_kro_vendor/core/utils/context_extensions.dart';
import 'package:room_book_kro_vendor/core/widgets/custom_app_bar.dart';
import 'package:room_book_kro_vendor/core/widgets/custom_scaffold.dart';
import 'package:room_book_kro_vendor/core/widgets/primary_button.dart';
import 'package:room_book_kro_vendor/features/property/view_model/add_property_view_model.dart';
import '../../../core/constants/app_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../generated/assets.dart';
import '../view_model/room_type_view_model.dart';
import 'add_room_bottom_sheet.dart';

class AddRoomProperty extends ConsumerStatefulWidget {
  const AddRoomProperty({super.key});

  @override
  ConsumerState<AddRoomProperty> createState() => _AddPropertyScreenState();
}

class _AddPropertyScreenState extends ConsumerState<AddRoomProperty> {
  final ImagePicker picker = ImagePicker();
  final List<RoomData> roomsList = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)!.settings.arguments as Map;
      final selectedPropertyType = args["selectedPropertyTypeId"];
      ref
          .read(getRoomTypeProvider.notifier)
          .roomTypeApi(selectedPropertyType.toString());
    });
  }

  // Controllers for new fields
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController roleController = TextEditingController();
  final TextEditingController userEmailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController checkInController = TextEditingController();
  final TextEditingController checkOutController = TextEditingController();

  // Toggle for Pay at Property
  bool payAtProperty = false;

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
    final now = DateTime.now();
    final dateTime = DateTime(
      now.year,
      now.month,
      now.day,
      picked!.hour,
      picked.minute,
    );

    final formattedTime =
    DateFormat('hh:mm a').format(dateTime); // 12-hour with AM/PM

    controller.text = formattedTime;

    // if (picked != null) {
    //   final formattedTime = picked.format(context);
    //   controller.text = formattedTime;
    // }
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map;
    final propertyTitle = args["propertyTitle"];
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
    final flatNo = args["flatNo"];
    final additionalAddress = args["additionalAddress"];
    final List<String> propertyRules =
        (args["propertyRules"] as List?)?.cast<String>() ?? [];
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

    final bool isAvailable = args["availability"] ?? false;
    final List<File> mainImage =
        (args["mainImage"] as List?)?.cast<File>() ?? [];
    final List<File> propertyImages =
        (args["propertyImages"] as List?)?.cast<File>() ?? [];

    return CustomScaffold(
      appBar: CustomAppBar(
        middle: AppText(
          text: "Add Rooms",
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
                children: [
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
                  // User Information Section
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
                        const SizedBox(height: 20),
                        CustomTextField(
                          textCapitalization: TextCapitalization.words,
                          controller: userNameController,
                          hintText: "Enter your full name",
                          labelText: "Name",
                          suffixIcon: Icon(Icons.person),
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          controller: roleController,
                          textCapitalization: TextCapitalization.words,
                          maxLines: 1,
                          hintText: "Enter your role (e.g., Owner, Manager)",
                          labelText: "Role",
                          suffixIcon: Icon(Icons.work_outline),
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          controller: userEmailController,
                          hintText: "Enter your email address",
                          labelText: "Email",
                          prefixIcon: Icon(Icons.email_outlined),
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          controller: phoneController,
                          hintText: "Enter your phone number",
                          maxLength: 10,
                          labelText: "Phone Number",
                          prefixIcon: Icon(Icons.phone_outlined),
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
                                    AppText(
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
                                activeTrackColor: AppColors.secondary(ref).withValues(alpha: 0.4),
                                inactiveTrackColor: AppColors.secondary(ref).withValues(alpha: 0.4),
                                inactiveThumbColor: Colors.grey.withValues(alpha: 0.5),
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
                  roomsList.isEmpty
                      ? Container(
                          padding: const EdgeInsets.all(40),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.grey.shade300,
                              width: 2,
                              style: BorderStyle.solid,
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
                                        child: AddRoomBottomSheet(
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
                      label: "Submit Property",
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
                        final List<String> amenitiesForApi = mainAmenitiesList;
                        final depositAmount =
                            args["depositAmount"]?.toString() ?? "0";
                        ref
                            .read(addPropertyProvider.notifier)
                            .addPropertyApi(
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
                              depositAmount: depositAmount,
                              amenitiesMain: amenitiesForApi,
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
            // Image Section
            if (r.roomImages.isNotEmpty)
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    child: Image.file(
                      r.roomImages.first,
                      width: double.infinity,
                      height: 180,
                      fit: BoxFit.cover,
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
                            text: "${r.roomImages.length}",
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
                            onTap: () => _editRoom(
                              idx,
                              selectedPropertyType,
                              subTypeList,
                            ),
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
          child: AddRoomBottomSheet(
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
