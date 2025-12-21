import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:room_book_kro_vendor/core/utils/context_extensions.dart';
import 'package:room_book_kro_vendor/core/widgets/custom_app_bar.dart';
import 'package:room_book_kro_vendor/core/widgets/custom_scaffold.dart';
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
  int? selectedRoomForUser=0;

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

  final TextEditingController userNameController = TextEditingController();
  final TextEditingController roleController = TextEditingController();
  final TextEditingController userEmailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController checkInController = TextEditingController();
  final TextEditingController checkOutController = TextEditingController();

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
                dialBackgroundColor: AppColors.secondary(ref).withValues(alpha: 0.1),
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
          text: "Add Rooms & Contact Details",
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red.shade400,
              ),
              const SizedBox(height: 16),
              AppText(
                text: roomTypeState.error,
                fontType: FontType.regular,
                color: Colors.red,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  ref
                      .read(getRoomTypeProvider.notifier)
                      .roomTypeApi(selectedPropertyType.toString());
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary(ref),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
              ),
            ],
          ),
        )
            : ListView(
          padding: EdgeInsets.symmetric(
            horizontal: context.sw * 0.04,
            vertical: context.sh * 0.015,
          ),
          children: [
            _buildPropertySummaryCard(
              propertyTitle,
              city,
              state,
              pincode,
            ),
            const SizedBox(height: 24),

            _buildContactInformationSection(),
            const SizedBox(height: 24),

            _buildYourRoomsSection(
              selectedPropertyType,
              subTypeList,
            ),
            const SizedBox(height: 24),

            _buildActionButtons(
              context,
              selectedPropertyType,
              subTypeList,
              args,
              mainAmenitiesList,
              mainImage,
              propertyImages,
              isAvailable,
              propertyTitle,
              address,
              city,
              state,
              pincode,
              coordinates,
              propertyMonthPrice,
              propertyDayPrice,
              propertyNightPrice,
              website,
              description,
              oldMrp,
              tax,
              discount,
              flatNo,
              additionalAddress,
              propertyRules,
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildPropertySummaryCard(
      String? propertyTitle,
      String? city,
      String? state,
      dynamic pincode,
      ) {
    return Container(
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
            color: AppColors.secondary(ref).withValues(alpha: 0.1),
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
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.secondary(ref).withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
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
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
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
                  height: 50,
                  width: 1,
                  color: Colors.grey.shade300,
                ),
                _buildStatItem(
                  icon: Icons.meeting_room_outlined,
                  label: "Available Units",
                  value: _getTotalAvailableUnits(),
                  color: Colors.blue,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactInformationSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
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
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.secondary(ref).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.person_outline,
                  color: AppColors.secondary(ref),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: AppText(
                  text: "Contact Information",
                  fontType: FontType.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          AppText(
            text: "Property manager or owner details",
            fontSize: 13,
            color: Colors.grey.shade600,
          ),
          const SizedBox(height: 20),
          CustomTextField(
            textCapitalization: TextCapitalization.words,
            controller: userNameController,
            hintText: "Enter full name",
            labelText: "Name",
            suffixIcon: const Icon(Icons.person),
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: roleController,
            textCapitalization: TextCapitalization.words,
            maxLines: 1,
            hintText: "e.g., Owner, Manager",
            labelText: "Role",
            suffixIcon: const Icon(Icons.work_outline),
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: userEmailController,
            hintText: "Enter email address",
            labelText: "Email",
            prefixIcon: const Icon(Icons.email_outlined),
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: phoneController,
            hintText: "Enter phone number",
            maxLength: 10,
            labelText: "Phone Number",
            prefixIcon: const Icon(Icons.phone_outlined),
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 24),

          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.secondary(ref).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.access_time,
                  color: AppColors.secondary(ref),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const AppText(
                text: "Property Timing",
                fontType: FontType.bold,
                fontSize: 16,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => _selectTime(context, checkInController),
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
                  onTap: () => _selectTime(context, checkOutController),
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

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.secondary(ref).withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.secondary(ref).withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: payAtProperty
                        ? AppColors.secondary(ref).withValues(alpha: 0.15)
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
                        text: "Allow customers to pay at property",
                        fontType: FontType.regular,
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: payAtProperty,
                  inactiveThumbColor: AppColors.secondary(ref).withValues(alpha: 0.3),
                  inactiveTrackColor: AppColors.secondary(ref).withValues(alpha: 0.1),
                  activeColor: AppColors.secondary(ref),
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
    );
  }

  Widget _buildYourRoomsSection(
      dynamic selectedPropertyType,
      Map<int, List<String>> subTypeList,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.secondary(ref).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.hotel,
                    color: AppColors.secondary(ref),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const AppText(
                  text: "Your Rooms",
                  fontType: FontType.bold,
                  fontSize: 20,
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: AppColors.secondary(ref).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.secondary(ref).withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.door_front_door,
                    size: 16,
                    color: AppColors.secondary(ref),
                  ),
                  const SizedBox(width: 6),
                  AppText(
                    text: "${roomsList.length}",
                    fontType: FontType.bold,
                    fontSize: 15,
                    color: AppColors.secondary(ref),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        AppText(
          text: roomsList.isEmpty
              ? "Add rooms to showcase your property"
              : "Select one room that will be visible to users",
          fontSize: 13,
          color: Colors.grey.shade600,
        ),
        const SizedBox(height: 16),
        roomsList.isEmpty
            ? _buildEmptyRoomsState(selectedPropertyType, subTypeList)
            : Column(
          children: roomsList.asMap().entries.map((entry) {
            final idx = entry.key;
            final r = entry.value;
            return _buildEnhancedRoomCard(
              idx,
              r,
              selectedPropertyType,
              subTypeList,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildEmptyRoomsState(
      dynamic selectedPropertyType,
      Map<int, List<String>> subTypeList,
      ) {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade300,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.meeting_room_outlined,
              size: 48,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 20),
          const AppText(
            text: "No rooms added yet",
            fontType: FontType.bold,
            fontSize: 18,
            color: Colors.black87,
          ),
          const SizedBox(height: 8),
          AppText(
            text: "Add your first room by tapping the button below",
            fontType: FontType.regular,
            fontSize: 14,
            color: Colors.grey.shade600,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(
      BuildContext context,
      dynamic selectedPropertyType,
      Map<int, List<String>> subTypeList,
      Map args,
      List<String> mainAmenitiesList,
      List<File> mainImage,
      List<File> propertyImages,
      bool isAvailable,
      String? propertyTitle,
      String? address,
      String? city,
      String? state,
      dynamic pincode,
      dynamic coordinates,
      dynamic propertyMonthPrice,
      dynamic propertyDayPrice,
      dynamic propertyNightPrice,
      dynamic website,
      dynamic description,
      dynamic oldMrp,
      dynamic tax,
      dynamic discount,
      dynamic flatNo,
      dynamic additionalAddress,
      List<String> propertyRules,
      ) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: subTypeList.isEmpty
                ? null
                : () async {
              final newRoom = await showModalBottomSheet<RoomData>(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => Container(
                  height: MediaQuery.of(context).size.height * 0.9,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                  ),
                  child: AddRoomBottomSheet(
                    propertyType: selectedPropertyType,
                    subTypeList: subTypeList,
                  ),
                ),
              );

              if (newRoom != null) {
                setState(() {
                  roomsList.add(newRoom);
                  // NEW: Auto-select the first room by default
                  if (roomsList.length == 1) {
                    selectedRoomForUser = 0;
                  }
                });
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(
                            Icons.check_circle,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 12),
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
              }
            },
            icon: const Icon(Icons.add_circle_outline, size: 22),
            label: const AppText(
              text: "Add New Room",
              fontType: FontType.semiBold,
              fontSize: 16,
              color: Colors.white,
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary(ref),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              shadowColor: AppColors.secondary(ref).withValues(alpha: 0.3),
            ),
          ),
        ),
        const SizedBox(height: 16),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: ref.watch(addPropertyProvider).isLoading
                ? null
                : () {
              // NEW: Validate that at least one room is added
              if (roomsList.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(
                          Icons.warning_amber,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 12),
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

              // NEW: Validate that one room is selected for user view
              if (selectedRoomForUser == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(
                          Icons.warning_amber,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: AppText(
                            text: "Please select one room for user view",
                            fontType: FontType.semiBold,
                            color: Colors.white,
                          ),
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
              ref.read(addPropertyProvider.notifier).addPropertyApi(
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
                selectedRoomPrice: selectedRoomForUser.toString(),
                coordinates:
                coordinates ?? {"lat": 0.0, "lng": 0.0},
                mainImage: mainImage,
                propertyImages: propertyImages,
                pricePerMonth: propertyMonthPrice?.toString() ?? "",
                depositAmount: depositAmount,
                amenitiesMain: amenitiesForApi,
                website: website?.toString() ?? "",
                pricePerDay: propertyDayPrice?.toString() ?? "",
                availableRooms: _getTotalAvailableUnits(),
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
            icon: ref.watch(addPropertyProvider).isLoading
                ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
                : const Icon(Icons.check_circle, size: 22),
            label: AppText(
              text: ref.watch(addPropertyProvider).isLoading
                  ? "Submitting..."
                  : "Submit Property",
              fontType: FontType.bold,
              fontSize: 16,
              color: Colors.white,
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade600,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              shadowColor: Colors.green.withValues(alpha: 0.3),
            ),
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
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        const SizedBox(height: 8),
        AppText(text: value, fontType: FontType.bold, fontSize: 20),
        const SizedBox(height: 2),
        AppText(
          text: label,
          fontType: FontType.regular,
          fontSize: 12,
          color: Colors.grey.shade600,
        ),
      ],
    );
  }

  // ✅ FIX: Replace the pricing details display section in _buildEnhancedRoomCard

  Widget _buildEnhancedRoomCard(
      int idx,
      RoomData r,
      dynamic selectedPropertyType,
      Map<int, List<String>> subTypeList,
      ) {
    final bool isSelectedForUser = selectedRoomForUser == idx;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelectedForUser
                ? AppColors.secondary(ref).withValues(alpha: 0.6)
                : Colors.grey.shade200,
            width: isSelectedForUser ? 2.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelectedForUser
                  ? AppColors.secondary(ref).withValues(alpha: 0.2)
                  : Colors.black.withValues(alpha: 0.08),
              blurRadius: isSelectedForUser ? 20 : 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Selection Header (Radio Button Style)
            InkWell(
              onTap: () {
                setState(() {
                  selectedRoomForUser = idx;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelectedForUser
                      ? AppColors.secondary(ref).withValues(alpha: 0.1)
                      : Colors.grey.shade50,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelectedForUser
                              ? AppColors.secondary(ref)
                              : Colors.grey.shade400,
                          width: 2,
                        ),
                        color: Colors.white,
                      ),
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelectedForUser
                              ? AppColors.secondary(ref)
                              : Colors.transparent,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText(
                            text: isSelectedForUser
                                ? "Visible to Users"
                                : "Tap to select for users",
                            fontType: FontType.semiBold,
                            fontSize: 13,
                            color: isSelectedForUser
                                ? AppColors.secondary(ref)
                                : Colors.grey.shade600,
                          ),
                          AppText(
                            text: "Only one room can be selected",
                            fontSize: 11,
                            color: Colors.grey.shade500,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isSelectedForUser
                            ? AppColors.secondary(ref)
                            : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.hotel,
                            color: isSelectedForUser
                                ? Colors.white
                                : Colors.grey.shade600,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          AppText(
                            text: "Room ${idx + 1}",
                            color: isSelectedForUser
                                ? Colors.white
                                : Colors.grey.shade600,
                            fontType: FontType.bold,
                            fontSize: 12,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Image Section
            if (r.roomImages.isNotEmpty)
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.zero,
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
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.hotel_outlined,
                        color: Colors.grey.shade400,
                        size: 64,
                      ),
                      const SizedBox(height: 8),
                      AppText(
                        text: "No Image",
                        color: Colors.grey.shade500,
                        fontSize: 14,
                      ),
                    ],
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
                            const SizedBox(height: 6),
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
                            onTap: () => _showDeleteConfirmation(idx),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
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

                  // ✅ FIX: Updated Pricing Section - Using only backend fields
                  const SizedBox(height: 16),
                  Divider(color: Colors.grey.shade200, thickness: 1),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Icon(
                        Icons.receipt_long,
                        size: 18,
                        color: AppColors.secondary(ref),
                      ),
                      const SizedBox(width: 8),
                      const AppText(
                        text: "Pricing Details",
                        fontType: FontType.bold,
                        fontSize: 15,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Display Main Price
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.green.withValues(alpha: 0.05),
                          Colors.green.withValues(alpha: 0.02),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.green.withValues(alpha: 0.3),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.currency_rupee,
                            color: Colors.green,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const AppText(
                                text: "Main Price",
                                fontType: FontType.bold,
                                fontSize: 14,
                                color: Colors.green,
                              ),
                              if (r.discountRoom != "0" && r.discountRoom.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.shade50,
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(
                                      color: Colors.orange.shade200,
                                    ),
                                  ),
                                  child: AppText(
                                    text: "${r.discountRoom}% OFF",
                                    fontType: FontType.bold,
                                    fontSize: 10,
                                    color: Colors.orange.shade700,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(
                              Icons.currency_rupee,
                              size: 16,
                              color: Colors.green,
                            ),
                            AppText(
                              text: r.price,
                              fontType: FontType.bold,
                              fontSize: 18,
                              color: Colors.green.shade700,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Display Per Day Price if different
                  if (r.roomPricePerDay != r.price && r.roomPricePerDay.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.amber.withValues(alpha: 0.05),
                            Colors.amber.withValues(alpha: 0.02),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.amber.withValues(alpha: 0.3),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.amber.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.wb_sunny,
                              color: Colors.amber,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: AppText(
                              text: "Per Day",
                              fontType: FontType.bold,
                              fontSize: 14,
                              color: Colors.amber,
                            ),
                          ),
                          Row(
                            children: [
                              const Icon(
                                Icons.currency_rupee,
                                size: 16,
                                color: Colors.amber,
                              ),
                              AppText(
                                text: r.roomPricePerDay,
                                fontType: FontType.bold,
                                fontSize: 18,
                                color: Colors.amber.shade700,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                  if (r.amenitiesIds.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Divider(color: Colors.grey.shade200),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          size: 16,
                          color: Colors.green.shade600,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: AppText(
                            text: "${r.amenitiesIds.length} amenities included",
                            fontType: FontType.medium,
                            fontSize: 13,
                            color: Colors.grey.shade700,
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
          border: Border.all(
            color: color.withValues(alpha: 0.3),
          ),
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
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
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

  void _showDeleteConfirmation(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Colors.orange.shade700,
                size: 28,
              ),
              const SizedBox(width: 12),
              const AppText(
                text: "Delete Room?",
                fontType: FontType.bold,
                fontSize: 18,
              ),
            ],
          ),
          content: const AppText(
            text: "Are you sure you want to delete this room? This action cannot be undone.",
            fontSize: 14,
            color: Colors.black87,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: AppText(
                text: "Cancel",
                color: Colors.grey.shade700,
                fontType: FontType.medium,
              ),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  // Update selectedRoomForUser index after deletion
                  if (selectedRoomForUser == index) {
                    selectedRoomForUser = null; // Deselect if deleted room was selected
                  } else if (selectedRoomForUser != null && selectedRoomForUser! > index) {
                    selectedRoomForUser = selectedRoomForUser! - 1; // Adjust index
                  }
                  roomsList.removeAt(index);
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(Icons.delete, color: Colors.white),
                        const SizedBox(width: 12),
                        AppText(
                          text: "Room deleted successfully",
                          fontType: FontType.semiBold,
                          color: Colors.white,
                        ),
                      ],
                    ),
                    backgroundColor: Colors.red.shade600,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const AppText(
                text: "Delete",
                color: Colors.white,
                fontType: FontType.bold,
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _editRoom(
      int index,
      dynamic selectedPropertyType,
      Map<int, List<String>> subTypeList,
      ) async {
    final existing = roomsList[index];
    final editedRoom = await showModalBottomSheet<RoomData>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: AddRoomBottomSheet(
          propertyType: selectedPropertyType,
          subTypeList: subTypeList,
          initialRoom: existing,
        ),
      ),
    );
    if (editedRoom != null) {
      setState(() => roomsList[index] = editedRoom);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                AppText(
                  text: "Room updated successfully!",
                  fontType: FontType.semiBold,
                  color: Colors.white,
                ),
              ],
            ),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
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
}